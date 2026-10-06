{
  lib,
  stdenvNoCC,
  fetchurl,
  makeWrapper,
  nodejs,
}:

let
  version = "1.8.14";
in
stdenvNoCC.mkDerivation {
  pname = "bower";
  inherit version;

  # 1.8.14 is the last 1.x release; upstream is deprecated and the npm tarball
  # already vendors every runtime dependency under lib/node_modules, so no npm
  # install step is needed.
  src = fetchurl {
    url = "https://registry.npmjs.org/bower/-/bower-${version}.tgz";
    hash = "sha256-AN89zG6LOk3XZok0og5g5vwMQml5AZIXk4jJKFU6P34=";
  };

  nativeBuildInputs = [ makeWrapper ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/node_modules
    cp -r . $out/lib/node_modules/bower

    makeWrapper ${lib.getExe nodejs} $out/bin/bower \
      --add-flags $out/lib/node_modules/bower/bin/bower

    runHook postInstall
  '';

  meta = {
    description = "Package manager for the web (browser package manager)";
    homepage = "https://bower.io";
    license = lib.licenses.mit;
    mainProgram = "bower";
    platforms = lib.platforms.all;
  };
}
