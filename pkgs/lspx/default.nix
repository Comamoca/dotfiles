# This package help by @kuuote. Thank you!
{ pkgs }:
let
  generated = import ../../_sources/generated.nix;
  sources = generated {
    inherit (pkgs)
      fetchurl
      fetchgit
      fetchFromGitHub
      dockerTools
      ;
  };

  src = sources.lspx.src;

  deps =
    pkgs.runCommand "lspx-deps"
      {
        inherit src;
        nativeBuildInputs = [
          pkgs.deno
        ];

        outputHash = "sha256-cUhCMm0563JNaDQM8NZ1W4oDCy3UjzMp6hP2C0CYncs=";
        outputHashAlgo = "sha256";
        outputHashMode = "recursive";
      }

      ''
        unpackPhase
        cd source
        HOME="$(mktemp -d)"

        # deno cache --frozen=true --vendor=true main.ts
        deno cache --vendor=true main.ts
	
        # 一意じゃないと思われるデータの削除
        for path in vendor/jsr.io/*/*/meta.json; do
          echo '{"versions":{}}' > $path
        done

        rm -f node_modules/.deno/.deno.lock.poll
        mkdir -p $out
        cp -a node_modules $out/
        cp -a vendor $out/
      '';

  vendored = pkgs.symlinkJoin {
    name = "lspx-vendored";
    paths = [
      src
      deps
    ];
  };

  rawScript = pkgs.writeShellScriptBin "lspx" ''
    deno run --frozen=true --allow-env --allow-run --vendor=true --cached-only --node-modules-dir=manual "${vendored}/main.ts" "$@"
  '';

in
pkgs.runCommand "lspx"
  {
    buildInputs = [ pkgs.makeWrapper ];
  }
  ''
    mkdir -p $out/bin
    makeWrapper ${rawScript}/bin/lspx "$out/bin/lspx"
  ''
