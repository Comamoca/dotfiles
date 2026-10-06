{ pkgs }:
let
  opensrc = import ../pkgs/opensrc { inherit pkgs; };
  vite-plus = import ../pkgs/vite-plus { inherit pkgs; };
  efm-langserver = import ../pkgs/efm-langserver { inherit pkgs; };
  ort = import ../pkgs/ort { inherit pkgs; };
  license-efm = import ../pkgs/license-efm { inherit pkgs; };
in
with pkgs;
[
  # Development tools
  gleam.bin.latest
  deno."2.5.4"
  nodejs_24
  bun
  uv
  vite-plus

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
  efm-langserver
  luau

  # Debug Adapter Protocol
  (pkgs.lib.hiPrio elixir-ls)
  lldb
  vscode-extensions.vadimcn.vscode-lldb # codelldb for Rust debugging

  opensrc

  # kakehashi: Tree-sitterハイライトと埋め込みコードへのLSPブリッジ
  # (ランタイムでのTree-sitterパーサーコンパイルにCコンパイラが必要)
  kakehashi
  gcc
  ort
  license-efm
  docker-sbx
]
