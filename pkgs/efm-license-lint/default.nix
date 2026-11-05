{
  pkgs,
}:
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

  src = sources.efm-license-lint.src;
in
pkgs.stdenv.mkDerivation (finalAttrs: {
  pname = "efm-license-lint";
  version = sources.efm-license-lint.version;

  inherit src;

  strictDeps = true;

  nativeBuildInputs = [
    pkgs.bun
  ]
  ++ pkgs.lib.optionals pkgs.stdenv.hostPlatform.isLinux [ pkgs.autoPatchelfHook ];

  # `bun build --compile` appends the JavaScript bundle to a copy of the Bun
  # runtime. Stripping that file drops the appended bundle, and the binary
  # stops being an application and falls back to the Bun CLI, so the strip
  # fixup is turned off.
  dontStrip = true;

  buildPhase = ''
    runHook preBuild

    bun ./scripts/build-binary.ts --outfile efm-license-lint

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/libexec/efm-license-lint" "$out/bin"
    install -m755 efm-license-lint "$out/libexec/efm-license-lint/efm-license-lint"
    ln -s ../libexec/efm-license-lint/efm-license-lint "$out/bin/efm-license-lint"

    runHook postInstall
  '';

  meta = with pkgs.lib; {
    description = "Show dependency package licenses in your editor through efm-langserver";
    homepage = "https://github.com/Comamoca/efm-license-lint";
    license = licenses.mit;
    mainProgram = "efm-license-lint";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];
  };
})
