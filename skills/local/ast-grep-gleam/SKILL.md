---
name: ast-grep-gleam
description: Use when searching Gleam source code with ast-grep by node kind or structural pattern - covers setup requirements, working search methods, and known limitations of pattern matching
---

# ast-grep for Gleam

## Overview

ast-grep can search Gleam source code structurally, but requires a custom language config via `sgconfig.yml`. The `--pattern` metavariable syntax is unreliable for Gleam; use `--inline-rules` with `kind:` instead.

## Requirements

A `sgconfig.yml` must exist in the project root with the Gleam tree-sitter parser path:

```yaml
customLanguages:
  gleam:
    extensions:
      - gleam
    libraryPath: /path/to/gleam.so
```

On NixOS, find the `.so` path:
```bash
find /nix/store -name "gleam.so" 2>/dev/null | head -5
```

Before running any search, verify the `.so` file exists at the configured path.

## How to Search

Always use `ast-grep scan --inline-rules` with `kind:` to match by AST node type:

```bash
ast-grep scan --inline-rules '
id: <descriptive-id>
language: gleam
rule:
  kind: <node-kind>
' <target-dir>/
```

### Verified Examples

```bash
# Find all function definitions
ast-grep scan --inline-rules '
id: find-functions
language: gleam
rule:
  kind: function
' src/

# Find all case expressions
ast-grep scan --inline-rules '
id: find-case
language: gleam
rule:
  kind: case
' src/

# Find all let bindings
ast-grep scan --inline-rules '
id: find-let
language: gleam
rule:
  kind: let
' src/
```

### Combining Rules

You can combine `kind` with other rule fields like `has`, `inside`, or `regex` for more precise matching:

```bash
# Find public functions only
ast-grep scan --inline-rules '
id: find-pub-functions
language: gleam
rule:
  kind: function
  has:
    kind: visibility_modifier
' src/

# Find functions whose name matches a pattern
ast-grep scan --inline-rules '
id: find-functions-named
language: gleam
rule:
  kind: function
  has:
    kind: identifier
    regex: "^do_"
' src/
```

## Discovering Node Types

To find the correct `kind` value for any Gleam construct, use `--debug-query=ast`:

```bash
ast-grep run --lang gleam --debug-query=ast --pattern 'let' /path/to/file.gleam
```

This prints tree-sitter node names (e.g., `let`, `function`, `identifier`, `case`).

## Known Limitation

`--pattern 'let $VAR = $VAL'` does **NOT** work reliably for Gleam. Metavariables like `$VAR` get parsed as constructor names (uppercase), producing ERROR nodes. Always use `--inline-rules` + `kind:` instead.

## Quick Reference

| Goal | `kind` value |
|------|-------------|
| Function definitions | `function` |
| Case expressions | `case` |
| Variable declarations | `let` |
| Identifiers | `identifier` |
| Type definitions | `type_definition` |
| Import statements | `import` |
| Debug node types | `--debug-query=ast --pattern 'keyword'` |
