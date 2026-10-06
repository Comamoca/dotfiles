package main

import (
	"errors"
	"flag"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"sort"
)

const (
	defaultFormat = "%f:%l:%c: %t: %m"

	severityInfo    = 'I'
	severityWarning = 'W'

	exitOK          = 0
	exitDiagnostics = 1
	exitError       = 2
)

const usageText = `license-efm - print package licences in efm (errorformat) style

usage: license-efm [flags] path...

  Every path is a package manifest (gleam.toml, manifest.toml) or a directory
  holding one. Licence metadata is read from local state only - the resolved
  dependency tree under build/packages and the shared hex cache - so no
  registry is queried.

  Output is one line per package, written as

    <file>:<line>:<col>: <severity>: <message>

  which is what efm-langserver parses with the lint-format
  "%f:%l:%c: %t: %m". Diagnostics point at the line the package occupies in the
  manifest: the licence expression on success, for example

    /home/u/proj/manifest.toml:6:12: I: Apache-2.0

  and a warning when nothing could be resolved, for example

    /home/u/proj/manifest.toml:21:13: W: unknown licence (not downloaded)

flags:
  -root dir     project root; detected by walking up from each path by default
  -format tmpl  output template (default "` + defaultFormat + `")

exit status:
  0  every licence was resolved
  1  at least one licence could not be determined
  2  usage or i/o error
`

func main() {
	os.Exit(run(os.Args[1:], os.Stdout, os.Stderr))
}

func run(args []string, stdout, stderr io.Writer) int {
	flags := flag.NewFlagSet("license-efm", flag.ContinueOnError)
	flags.SetOutput(stderr)
	flags.Usage = func() { io.WriteString(stderr, usageText) }

	root := flags.String("root", "", "project root directory")
	format := flags.String("format", defaultFormat, "output template")

	if err := flags.Parse(args); err != nil {
		if errors.Is(err, flag.ErrHelp) {
			return exitOK
		}
		return exitError
	}
	paths := flags.Args()
	if len(paths) == 0 {
		flags.Usage()
		return exitError
	}

	status := exitOK
	var diags []diagnostic
	for _, path := range paths {
		found, err := scan(path, *root)
		if err != nil {
			fmt.Fprintf(stderr, "license-efm: %v\n", err)
			status = exitError
			continue
		}
		diags = append(diags, found...)
	}

	sort.SliceStable(diags, func(i, j int) bool {
		if diags[i].file != diags[j].file {
			return diags[i].file < diags[j].file
		}
		if diags[i].line != diags[j].line {
			return diags[i].line < diags[j].line
		}
		return diags[i].col < diags[j].col
	})

	for _, d := range diags {
		fmt.Fprintln(stdout, d.format(*format))
		if d.severity == severityWarning && status == exitOK {
			status = exitDiagnostics
		}
	}
	return status
}

// scan collects the licence diagnostics of the manifest named by path.
// Directories are resolved to the manifest of the project they hold.
func scan(path, root string) ([]diagnostic, error) {
	abs, err := filepath.Abs(path)
	if err != nil {
		return nil, err
	}
	info, err := os.Stat(abs)
	if err != nil {
		return nil, err
	}

	if !info.IsDir() {
		switch filepath.Base(abs) {
		case gleamFile, manifestFile:
			return scanFile(abs, filepath.Dir(abs), root)
		default:
			// Not a package manifest: nothing to report.
			return nil, nil
		}
	}

	target := filepath.Join(abs, manifestFile)
	if !isFile(target) {
		target = filepath.Join(abs, gleamFile)
	}
	if !isFile(target) {
		return nil, fmt.Errorf("%s: no %s or %s", abs, gleamFile, manifestFile)
	}
	return scanFile(target, abs, root)
}

// scanFile reports the licences declared by target. start is the directory the
// search for the project root begins at.
func scanFile(target, start, root string) ([]diagnostic, error) {
	if root == "" {
		detected, err := findRoot(start)
		if err != nil {
			return nil, fmt.Errorf("%s: %w", target, err)
		}
		root = detected
	} else if abs, err := filepath.Abs(root); err != nil {
		return nil, err
	} else {
		root = abs
	}

	res := newResolver(root)
	if filepath.Base(target) == manifestFile {
		return res.manifestDiagnostics(target)
	}
	return res.gleamDiagnostics(target)
}
