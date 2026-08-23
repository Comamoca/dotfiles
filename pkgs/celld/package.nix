{
  lib,
  stdenv,
  stdenvNoCC,
  fetchurl,
  gzip,
  autoPatchelfHook,
  makeWrapper,
  esbuild,
}:

let
  version = "0.3.0";

  # Assets published by the upstream install script:
  #   $release_base/download/v$version/celld-$target.gz
  sources = {
    "x86_64-linux" = {
      target = "x86_64-unknown-linux-gnu";
      hash = "sha256-y/z6X211UbUxb29MnXdRx0GpuiojBd3o1ctNGzf7NKY=";
    };
    "aarch64-linux" = {
      target = "aarch64-unknown-linux-gnu";
      hash = "sha256-iKNQcBRECPkCA2B2t/iN84VIzk3aBz//J6bdH20rrig=";
    };
    "aarch64-darwin" = {
      target = "aarch64-apple-darwin";
      hash = "sha256-/BnZ/V7UKWVkdhkOoj9evb6hhTiwlv38SpE9Lgz1UdQ=";
    };
  };

  source =
    sources.${stdenvNoCC.hostPlatform.system}
      or (throw "celld: no prebuilt release exists for ${stdenvNoCC.hostPlatform.system} yet");
in
stdenvNoCC.mkDerivation {
  pname = "celld";
  inherit version;

  src = fetchurl {
    url = "https://github.com/denoland/celld/releases/download/v${version}/celld-${source.target}.gz";
    inherit (source) hash;
  };

  # The asset is a bare gzipped ELF/Mach-O binary, not an archive.
  dontUnpack = true;

  nativeBuildInputs = [
    gzip
    makeWrapper
  ]
  ++ lib.optional stdenv.hostPlatform.isLinux autoPatchelfHook;

  buildInputs = lib.optional stdenv.hostPlatform.isLinux stdenv.cc.cc.libgcc;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    gzip -dc $src > $out/bin/celld
    chmod 755 $out/bin/celld

    runHook postInstall
  '';

  # `celld deploy` shells out to esbuild.
  postFixup = ''
    wrapProgram $out/bin/celld --prefix PATH : ${lib.makeBinPath [ esbuild ]}
  '';

  meta = {
    description = "Self-hosted, distributed Durable Objects daemon";
    homepage = "https://github.com/denoland/celld";
    license = lib.licenses.asl20;
    mainProgram = "celld";
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = lib.attrNames sources;
  };
}
