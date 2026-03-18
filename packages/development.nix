{ pkgs }:
with pkgs;
[
  # Development tools
  (import ../pkgs/git-wt { inherit pkgs; })
  gleam.bin.latest
  deno."2.5.4"
  nodejs_24
  bun
  uv

  # Languages
  vlang
  clojure
  babashka
  ruby
  # Common Lisp
  # sbcl'
  # roswell
  # sbclPackages.qlot-cli

  typescript
  typescript-language-server
  luau
]
