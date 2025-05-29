# This package help by @kuuote. Thank you!
{ pkgs }:
        let
  generated = import ../_sources/generated.nix;
  sources = generated {
    inherit (pkgs)
      fetchurl
      fetchgit
      fetchFromGitHub
      dockerTools
      ;
  };

          deps =
            pkgs.runCommand "lspx-deps"
              {
                src = sources.lspx.src;
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
                deno cache --frozen=true --vendor=true main.ts
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

	in {
          lspx = pkgs.writeShellScript "lspx" ''
            deno run --allow-env --allow-run --vendor=true --cached-only --node-modules-dir=manual "${vendored}/main.ts" "$@"
          '';
}
