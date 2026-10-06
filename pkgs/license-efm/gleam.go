package main

import (
	"errors"
	"os"
	"path/filepath"
	"regexp"
	"strings"
	"unicode/utf8"
)

const (
	gleamFile    = "gleam.toml"
	manifestFile = "manifest.toml"

	buildDir    = "build"
	packagesDir = "packages"

	// Gleam spells the licence field of gleam.toml the British way.
	licenceKey = "licences"
)

// pkgRef identifies the package a licence is looked up for.
type pkgRef struct {
	name     string
	source   string // "hex", "git", ...
	checksum string // hex outer checksum; empty for git dependencies
}

// manifestPkg is a single entry of the packages array of manifest.toml with the
// position it occupies in that file.
type manifestPkg struct {
	pkgRef
	line int
	col  int
}

// depEntry is a dependency declared in a gleam.toml.
type depEntry struct {
	name string
	line int
	col  int
}

// gleamToml is the part of a gleam.toml this tool cares about: the licence the
// file declares for its own package, and the dependencies it lists.
type gleamToml struct {
	licence     string
	licenceLine int
	licenceCol  int
	deps        []depEntry
}

// resolver answers "which licence does this package have" from local state
// only: the resolved dependency tree under build/packages and the shared hex
// cache. Nothing is fetched.
type resolver struct {
	root string
}

func newResolver(root string) *resolver {
	return &resolver{root: root}
}

// manifestDiagnostics reports the licence of every package listed in a
// manifest.toml.
func (r *resolver) manifestDiagnostics(target string) ([]diagnostic, error) {
	pkgs, err := parseManifest(target)
	if err != nil {
		return nil, err
	}
	diags := make([]diagnostic, 0, len(pkgs))
	for _, p := range pkgs {
		diags = append(diags, r.licenceDiagnostic(target, p.line, p.col, p.pkgRef))
	}
	return diags, nil
}

// gleamDiagnostics reports the licence a gleam.toml declares for its own
// package and the licence of each dependency it lists. Dependencies are
// resolved through the project manifest when one exists, which supplies the
// exact version and hex checksum of every resolved package.
func (r *resolver) gleamDiagnostics(target string) ([]diagnostic, error) {
	file, err := parseGleamToml(target)
	if err != nil {
		return nil, err
	}

	resolved := map[string]manifestPkg{}
	if path := filepath.Join(r.root, manifestFile); isFile(path) {
		pkgs, err := parseManifest(path)
		if err != nil {
			return nil, err
		}
		for _, p := range pkgs {
			resolved[p.name] = p
		}
	}

	var diags []diagnostic
	if file.licence != "" {
		diags = append(diags, diagnostic{
			file:     target,
			line:     file.licenceLine,
			col:      file.licenceCol,
			severity: severityInfo,
			message:  file.licence,
		})
	}
	for _, dep := range file.deps {
		ref := pkgRef{name: dep.name}
		if p, ok := resolved[dep.name]; ok {
			ref = p.pkgRef
		}
		diags = append(diags, r.licenceDiagnostic(target, dep.line, dep.col, ref))
	}
	return diags, nil
}

func (r *resolver) licenceDiagnostic(file string, line, col int, p pkgRef) diagnostic {
	if expr, ok := r.licence(p); ok {
		return diagnostic{file: file, line: line, col: col, severity: severityInfo, message: expr}
	}
	return diagnostic{
		file:     file,
		line:     line,
		col:      col,
		severity: severityWarning,
		message:  unknownLicenceMessage(r.licenceReason(p)),
	}
}

// licence resolves the licence expression of p from the metadata of the
// installed package or, failing that, from the hex cache.
func (r *resolver) licence(p pkgRef) (string, bool) {
	if expr, ok := installedLicence(filepath.Join(r.root, buildDir, packagesDir, p.name)); ok {
		return expr, true
	}
	if p.checksum != "" {
		if expr, ok := hexCacheLicence(p.checksum); ok {
			return expr, true
		}
	}
	return "", false
}

// licenceReason explains why the licence of p could not be determined.
func (r *resolver) licenceReason(p pkgRef) string {
	dir := filepath.Join(r.root, buildDir, packagesDir, p.name)
	switch {
	case hasLicenceFile(dir):
		return "licence file present but no SPDX metadata"
	case p.source == "git":
		return "git dependency without licence metadata"
	case !isDir(dir):
		return "not downloaded"
	}
	return "no licence metadata"
}

func unknownLicenceMessage(reason string) string {
	if reason == "" {
		return "unknown licence"
	}
	return "unknown licence (" + reason + ")"
}

// findRoot walks up from dir to the project it belongs to. Hex dependencies
// carry their own gleam.toml under build/packages, so those directories are
// skipped in favour of the project that downloaded them.
func findRoot(dir string) (string, error) {
	dir = filepath.Clean(dir)
	for {
		if !inBuildPackages(dir) && (isFile(filepath.Join(dir, gleamFile)) || isFile(filepath.Join(dir, manifestFile))) {
			return dir, nil
		}
		parent := filepath.Dir(dir)
		if parent == dir {
			return "", errors.New("no gleam.toml or manifest.toml in this directory or any parent")
		}
		dir = parent
	}
}

// inBuildPackages reports whether dir is a `<project>/build/packages/<name>`
// directory.
func inBuildPackages(dir string) bool {
	parts := strings.Split(filepath.ToSlash(filepath.Clean(dir)), "/")
	if len(parts) < 3 {
		return false
	}
	tail := parts[len(parts)-3:]
	return tail[0] == buildDir && tail[1] == packagesDir
}

// manifest field matchers. Gleam writes every entry of the packages array as a
// single line of inline table whose keys are unique and whose values carry no
// quotes, so matching field-wise is unambiguous.
var (
	reEntryName     = regexp.MustCompile(`\bname\s*=\s*"([^"]*)"`)
	reEntrySource   = regexp.MustCompile(`\bsource\s*=\s*"([^"]*)"`)
	reEntryChecksum = regexp.MustCompile(`\bouter_checksum\s*=\s*"([^"]*)"`)
)

// parseManifest reads the packages array of a manifest.toml.
func parseManifest(target string) ([]manifestPkg, error) {
	lines, err := readLines(target)
	if err != nil {
		return nil, err
	}

	var (
		pkgs    []manifestPkg
		inArray bool
		entry   []string
		line    int
		depth   int
	)
	for i, raw := range lines {
		text := strings.TrimSpace(raw)
		if !inArray {
			if strings.HasPrefix(text, "packages") && strings.Contains(text, "[") {
				inArray = !strings.Contains(text, "]")
			}
			continue
		}
		if entry == nil {
			switch {
			case text == "" || strings.HasPrefix(text, "#"):
				continue
			case strings.HasPrefix(text, "]"):
				inArray = false
				continue
			}
			line = i + 1
		}
		entry = append(entry, text)
		depth += nestingDelta(text)
		if depth > 0 {
			continue
		}
		if p, ok := parseManifestEntry(strings.Join(entry, " "), entry[0], line); ok {
			pkgs = append(pkgs, p)
		}
		entry, line, depth = nil, 0, 0
	}
	return pkgs, nil
}

// parseManifestEntry reads one inline table of the packages array. head is the
// line the entry starts on, used to locate the package name for the reported
// position.
func parseManifestEntry(entry, head string, line int) (manifestPkg, bool) {
	name := matchField(reEntryName, entry)
	if name == "" {
		return manifestPkg{}, false
	}
	p := manifestPkg{
		pkgRef: pkgRef{
			name:     name,
			source:   matchField(reEntrySource, entry),
			checksum: matchField(reEntryChecksum, entry),
		},
		line: line,
		col:  1,
	}
	if loc := reEntryName.FindStringSubmatchIndex(head); loc != nil {
		p.col = utf8.RuneCountInString(head[:loc[2]]) + 1
	}
	return p, true
}

func matchField(re *regexp.Regexp, s string) string {
	if m := re.FindStringSubmatch(s); m != nil {
		return m[1]
	}
	return ""
}

var reSectionHeader = regexp.MustCompile(`^\[([^\[\]]*)\]$`)

// parseGleamToml reads the licence declaration and the dependency lists of a
// gleam.toml.
func parseGleamToml(target string) (*gleamToml, error) {
	lines, err := readLines(target)
	if err != nil {
		return nil, err
	}

	file := &gleamToml{}
	section := ""
	pending := 0 // nesting depth of a dependency value continued over lines
	for i := 0; i < len(lines); i++ {
		text := strings.TrimSpace(lines[i])
		if text == "" || strings.HasPrefix(text, "#") {
			continue
		}
		if m := reSectionHeader.FindStringSubmatch(text); m != nil {
			section = strings.TrimSpace(m[1])
			pending = 0
			continue
		}
		if pending > 0 {
			pending += nestingDelta(text)
			continue
		}

		key, value, ok := splitAssignment(text)
		if !ok {
			continue
		}
		key = unquoteKey(key)

		if section == "" && key == licenceKey && file.licence == "" {
			start := i
			for nestingDelta(value) > 0 && i+1 < len(lines) {
				i++
				value += " " + strings.TrimSpace(lines[i])
			}
			if licences := parseLicences(value); len(licences) > 0 {
				file.licence = strings.Join(licences, " OR ")
				file.licenceLine = start + 1
				file.licenceCol = strings.Index(lines[start], key) + 1
			}
			continue
		}

		if section == "dependencies" || section == "dev-dependencies" {
			file.deps = append(file.deps, depEntry{
				name: key,
				line: i + 1,
				col:  strings.Index(lines[i], key) + 1,
			})
			pending += nestingDelta(value)
		}
	}
	return file, nil
}

// splitAssignment splits `key = value` at the first assignment outside quotes.
func splitAssignment(text string) (key, value string, ok bool) {
	quote := byte(0)
	for i := 0; i < len(text); i++ {
		c := text[i]
		switch {
		case quote != 0:
			if c == quote {
				quote = 0
			}
		case c == '"' || c == '\'':
			quote = c
		case c == '=':
			key = strings.TrimSpace(text[:i])
			if key == "" {
				return "", "", false
			}
			return key, strings.TrimSpace(text[i+1:]), true
		}
	}
	return "", "", false
}

// unquoteKey strips the quotes of a quoted TOML key.
func unquoteKey(key string) string {
	if len(key) >= 2 && (key[0] == '"' || key[0] == '\'') && key[len(key)-1] == key[0] {
		return key[1 : len(key)-1]
	}
	return key
}

// parseLicences reads the licence list of a gleam.toml value, which is either a
// TOML array of strings or, in older manifests, a single string.
func parseLicences(value string) []string {
	if strings.HasPrefix(value, "[") {
		return parseStringArray(value)
	}
	if s := unquoteKey(value); s != value {
		return []string{s}
	}
	return nil
}

// parseStringArray reads the quoted strings of a TOML array such as
// `["MIT", "Apache-2.0"]`, ignoring anything that is not a string.
func parseStringArray(s string) []string {
	var out []string
	for i := 0; i < len(s); i++ {
		quote := s[i]
		if quote != '"' && quote != '\'' {
			continue
		}
		start := i + 1
		i++
		for i < len(s) {
			if s[i] == '\\' && quote == '"' {
				i += 2
				continue
			}
			if s[i] == quote {
				break
			}
			i++
		}
		if i >= len(s) {
			break
		}
		if text := s[start:i]; text != "" {
			out = append(out, text)
		}
	}
	return out
}

// nestingDelta reports how much the brackets of s are unbalanced. Quoted parts
// are ignored.
func nestingDelta(s string) int {
	delta, quote := 0, byte(0)
	for i := 0; i < len(s); i++ {
		c := s[i]
		switch {
		case quote != 0:
			if c == quote {
				quote = 0
			}
		case c == '"' || c == '\'':
			quote = c
		case c == '[', c == '{':
			delta++
		case c == ']', c == '}':
			delta--
		}
	}
	return delta
}

func readLines(path string) ([]string, error) {
	body, err := os.ReadFile(path)
	if err != nil {
		return nil, err
	}
	text := strings.ReplaceAll(string(body), "\r\n", "\n")
	return strings.Split(strings.TrimSuffix(text, "\n"), "\n"), nil
}

func isFile(path string) bool {
	info, err := os.Stat(path)
	return err == nil && info.Mode().IsRegular()
}

func isDir(path string) bool {
	info, err := os.Stat(path)
	return err == nil && info.IsDir()
}
