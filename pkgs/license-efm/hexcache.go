package main

import (
	"archive/tar"
	"io"
	"os"
	"path/filepath"
	"regexp"
	"strings"
)

// hexCacheLicence looks the outer checksum of a hex package up in the shared
// gleam hex cache, where every downloaded package is stored as
// <outer_checksum>.tar.
func hexCacheLicence(checksum string) (string, bool) {
	names := []string{checksum, strings.ToLower(checksum)}
	for _, dir := range hexCacheDirs() {
		for _, name := range names {
			path := filepath.Join(dir, name+".tar")
			if !isFile(path) {
				continue
			}
			licences, err := hexTarballLicences(path)
			if err != nil || len(licences) == 0 {
				continue
			}
			return strings.Join(licences, " OR "), true
		}
	}
	return "", false
}

// hexCacheDirs returns the directories gleam keeps downloaded hex tarballs in.
func hexCacheDirs() []string {
	root := os.Getenv("GLEAM_CACHE")
	if root == "" {
		cache := os.Getenv("XDG_CACHE_HOME")
		if cache == "" {
			home, err := os.UserHomeDir()
			if err != nil {
				return nil
			}
			cache = filepath.Join(home, ".cache")
		}
		root = filepath.Join(cache, "gleam")
	}
	return []string{filepath.Join(root, "hex", "hexpm", "packages")}
}

// hexTarballLicences reads the license list from the metadata.config of a hex
// package tarball.
func hexTarballLicences(path string) ([]string, error) {
	f, err := os.Open(path)
	if err != nil {
		return nil, err
	}
	defer f.Close()

	entries := tar.NewReader(f)
	for {
		header, err := entries.Next()
		if err == io.EOF {
			return nil, nil
		}
		if err != nil {
			return nil, err
		}
		if filepath.Base(header.Name) != "metadata.config" {
			continue
		}
		body, err := io.ReadAll(io.LimitReader(entries, 1<<20))
		if err != nil {
			return nil, err
		}
		return parseHexMetadata(string(body)), nil
	}
}

var (
	reHexLicences = regexp.MustCompile(`<<"licenses">>\s*,\s*\[([^\]]*)\]`)
	reHexString   = regexp.MustCompile(`<<"([^"]*)"`)
)

// parseHexMetadata picks the licenses of an Erlang term file as hex writes it,
// for example `{<<"licenses">>, [<<"Apache-2.0"/utf8>>]}.`.
func parseHexMetadata(body string) []string {
	match := reHexLicences.FindStringSubmatch(body)
	if match == nil {
		return nil
	}
	var licences []string
	for _, item := range reHexString.FindAllStringSubmatch(match[1], -1) {
		if item[1] != "" {
			licences = append(licences, item[1])
		}
	}
	return licences
}

// installedLicence reads the licence an installed package declares in its own
// gleam.toml, which is the copy the hex tarball shipped.
func installedLicence(dir string) (string, bool) {
	file, err := parseGleamToml(filepath.Join(dir, gleamFile))
	if err != nil || file.licence == "" {
		return "", false
	}
	return file.licence, true
}

// licenceFiles are the file names that mark a licence inside an installed
// package.
var licenceFiles = []string{
	"LICENCE", "LICENSE", "COPYING",
	"LICENCE.md", "LICENSE.md", "COPYING.md",
	"LICENCE.txt", "LICENSE.txt",
}

func hasLicenceFile(dir string) bool {
	for _, name := range licenceFiles {
		if isFile(filepath.Join(dir, name)) {
			return true
		}
	}
	return false
}
