{
  lib,
  stdenvNoCC,
  fetchurl,
}:

let
  # ort 93.0.0 の .env.versions (BOMBOM_VERSION) に合わせる。
  version = "1.1.1";

  # Upstream は静的リンク済みの単一バイナリだけを配布する (リリースに tarball も
  # ソース向けのビルド手順も無い)。ort がサブプロセスとして呼ぶだけのツールなので、
  # ソースから Erlang/rebar3 ツールチェインを引き込まずにそのまま使う。
  sources = {
    x86_64-linux = {
      url = "https://github.com/erlef/bombom/releases/download/${version}/bombom-linux-amd64.bin";
      hash = "sha256-vWSXwoz7d+wXNNUjLbhqhfPpRqmBFxDXQ6PBqh3WaT0=";
    };
    aarch64-linux = {
      url = "https://github.com/erlef/bombom/releases/download/${version}/bombom-linux-arm64.bin";
      hash = "sha256-1YMsuwhGp2UV6xjkxIJpwDcmzAPuqCxX1v0A4cigbRs=";
    };
  };

  system = stdenvNoCC.hostPlatform.system;

  source = sources.${system} or (throw "bombom: upstream publishes no prebuilt binary for ${system}");
in
stdenvNoCC.mkDerivation {
  pname = "bombom";
  inherit version;

  src = fetchurl source;

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 $src $out/bin/bombom

    runHook postInstall
  '';

  meta = {
    description = "Erlang CLI SBOM generator used by OSS Review Toolkit's rebar3 analyzer";
    homepage = "https://github.com/erlef/bombom";
    changelog = "https://github.com/erlef/bombom/releases/tag/${version}";
    license = lib.licenses.asl20;
    maintainers = [ ];
    mainProgram = "bombom";
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [
      "aarch64-linux"
      "x86_64-linux"
    ];
  };
}
