{ pkgs, lib }:
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

  src = sources.picoclaw.src;
  version = sources.picoclaw.version;
in
pkgs.buildGoModule {
  pname = "picoclaw";
  inherit version;

  src = "${src}";

  proxyVendor = true;
  vendorHash = "sha256-dVXjMzn2ClQJRTuhdpDNHvbzKuHThtfjZ4xiBz56I8E=";

  buildInputs = [ pkgs.olm ];

  preBuild = ''
    go generate ./...
  '';

  ldflags = [
    "-s"
    "-w"
    "-X github.com/sipeed/picoclaw/pkg/config.Version=dev"
  ];

  # Skip tests that require external codex binary
  checkFlags =
    let
      flaky = [
        "TestGetVersion"
        "TestCodexCliProvider_MockCLI_Success"
        "TestCodexCliProvider_MockCLI_Error"
        "TestCodexCliProvider_MockCLI_WithModel"
        "TestGatewayStopRefusesNonGatewayAttachedProcess"
        "TestGatewayStatusIgnoresAndRemovesPidFileForNonGatewayProcess"
      ];
    in
    [ "-skip=^${builtins.concatStringsSep "$|^" flaky}$" ];

  meta = with lib; {
    description = "Tiny, Fast, and Deployable anywhere - automate the mundane, unleash your creativity";
    homepage = "https://github.com/sipeed/picoclaw";
    license = licenses.mit;
    mainProgram = "picoclaw";
    platforms = platforms.linux;
  };
}
