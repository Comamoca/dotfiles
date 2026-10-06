{
  lib,
  stdenvNoCC,
  fetchurl,
}:

let
  version = "1.0.10";

  # Upstream ships statically linked, self-contained tarballs per platform;
  # building from source would only add an entire Rust toolchain to the path
  # of a tool that is invoked as a subprocess by ort.
  sources = {
    x86_64-linux = {
      url = "https://github.com/getprovenant/provenant/releases/download/v${version}/provenant-linux-x86_64.tar.gz";
      hash = "sha256-GG1rLn6vfj2NjTm0+ui0Xx4e318twfZeo6KpAd7nVa0=";
    };
    aarch64-linux = {
      url = "https://github.com/getprovenant/provenant/releases/download/v${version}/provenant-linux-aarch64.tar.gz";
      hash = "sha256-BJV4xdfl7L5K99oj+j3CAzQgNibmzURPNk9lvZ4hKWE=";
    };
    x86_64-darwin = {
      url = "https://github.com/getprovenant/provenant/releases/download/v${version}/provenant-macos-x86_64.tar.gz";
      hash = "sha256-6smBhudV4RO0mUDkIbO+XnpBM3lW2XktSNylAtZClV0=";
    };
    aarch64-darwin = {
      url = "https://github.com/getprovenant/provenant/releases/download/v${version}/provenant-macos-aarch64.tar.gz";
      hash = "sha256-iqHre8eul8PlEsdoMLl7dc5GYn0e2VPPiH3AID9HiTE=";
    };
  };

  system = stdenvNoCC.hostPlatform.system;

  source =
    sources.${system}
      or (throw "provenant: upstream publishes no prebuilt binary for ${system}");
in
stdenvNoCC.mkDerivation {
  pname = "provenant";
  inherit version;

  src = fetchurl source;

  sourceRoot = ".";

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 provenant $out/bin/provenant
    install -Dm644 LICENSE $out/share/doc/provenant/LICENSE
    install -Dm644 NOTICE $out/share/doc/provenant/NOTICE
    install -Dm644 THIRD-PARTY-NOTICES.md $out/share/doc/provenant/THIRD-PARTY-NOTICES.md

    runHook postInstall
  '';

  meta = {
    description = "License, copyright and SBOM scanner (ScanCode-based) used by OSS Review Toolkit";
    longDescription = ''
      Provenant is a fast license, copyright and package detection scanner that
      builds on ScanCode Toolkit license data. OSS Review Toolkit invokes it as
      an external scanner.
    '';
    homepage = "https://github.com/getprovenant/provenant";
    changelog = "https://github.com/getprovenant/provenant/releases/tag/v${version}";
    license = lib.licenses.asl20;
    maintainers = [ ];
    mainProgram = "provenant";
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [
      "aarch64-darwin"
      "aarch64-linux"
      "x86_64-darwin"
      "x86_64-linux"
    ];
  };
}
