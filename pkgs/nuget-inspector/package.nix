{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  zlib,
  openssl,
  icu,
}:

let
  version = "0.10.0";

  # Upstream publishes self-contained .NET publish trees as release assets.
  targets = {
    x86_64-linux = {
      asset = "linux-x64";
      hash = "sha256-O7B693YJxYQpzfMTLswHNYo0+N6yNBKQla45HWs9skQ=";
    };
    aarch64-linux = {
      asset = "linux-arm64";
      hash = "sha256-tE/mvlcEf+lmFj64d34NDxWZMnHqcOUNHhpDMfgAEy0=";
    };
  };

  target =
    targets.${stdenv.hostPlatform.system}
      or (throw "nuget-inspector: no prebuilt release asset for ${stdenv.hostPlatform.system}");
in
stdenv.mkDerivation {
  pname = "nuget-inspector";
  inherit version;

  src = fetchurl {
    url = "https://github.com/aboutcode-org/nuget-inspector/releases/download/v${version}/nuget-inspector-v${version}-${target.asset}.tar.gz";
    inherit (target) hash;
  };

  nativeBuildInputs = [ autoPatchelfHook ];

  # The native host (apphost plus the .NET runtime libraries) is linked against
  # libstdc++, zlib and (via dlopen) OpenSSL/ICU.
  buildInputs = [
    stdenv.cc.cc.lib
    zlib
    openssl
    icu
  ];

  # libcoreclrtraceptprovider.so links against the LTTng .so.0 ABI, which only
  # existed in lttng-ust < 2.13. The provider is dlopened on demand when LTTng
  # tracing is requested and is never loaded during normal inspection runs.
  autoPatchelfIgnoreMissingDeps = [ "liblttng-ust.so.0" ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/nuget-inspector $out/bin
    cp -r . $out/lib/nuget-inspector/
    ln -s $out/lib/nuget-inspector/nuget-inspector $out/bin/nuget-inspector

    runHook postInstall
  '';

  meta = {
    description = "Inspect NuGet packages and resolve their dependencies";
    homepage = "https://github.com/aboutcode-org/nuget-inspector";
    changelog = "https://github.com/aboutcode-org/nuget-inspector/blob/v${version}/CHANGELOG.rst";
    license = lib.licenses.asl20;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "nuget-inspector";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
}
