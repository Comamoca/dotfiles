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

  src = sources.takt.src;
  version = sources.takt.version;

  node_modules = pkgs.stdenvNoCC.mkDerivation {
    pname = "takt-node_modules";
    inherit version src;

    nativeBuildInputs = [
      pkgs.bun
      pkgs.writableTmpDirAsHomeHook
    ];

    dontConfigure = true;

    buildPhase = ''
      runHook preBuild

      export BUN_INSTALL_CACHE_DIR=$(mktemp -d)

      bun install \
        --frozen-lockfile \
        --ignore-scripts \
        --no-progress \
        --production

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/node_modules
      cp -R ./node_modules $out

      runHook postInstall
    '';

    dontFixup = true;

    outputHash = "sha256-8mV1FLh6qJ2no8ZYjAYma5jfI3HGcDF16Q/TKmA3LTE=";
    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
  };
in
pkgs.stdenvNoCC.mkDerivation {
  pname = "takt";
  inherit version src;

  nativeBuildInputs = [
    pkgs.bun
    pkgs.nodejs
    pkgs.typescript
    pkgs.writableTmpDirAsHomeHook
  ];

  configurePhase = ''
    runHook preConfigure

    cp -R ${node_modules}/node_modules .
    patchShebangs node_modules

    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild

    bun run build

    runHook postBuild
  '';

  postPatch = ''
    substituteInPlace bin/takt \
      --replace-fail '#!/usr/bin/env node' '#!/usr/bin/env bun'
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/lib/takt

    cp -R dist $out/lib/takt/dist
    cp -R bin $out/lib/takt/bin
    cp -R ${node_modules}/node_modules $out/lib/takt/node_modules
    cp package.json $out/lib/takt/

    ln -s $out/lib/takt/bin/takt $out/bin/takt

    runHook postInstall
  '';

  meta = with pkgs.lib; {
    description = "AI Agent Piece Orchestration tool";
    homepage = "https://github.com/nrslib/takt";
    license = licenses.mit;
    mainProgram = "takt";
  };
}
