{
  lib,
  stdenvNoCC,
  fetchurl,
  jdk25,
  makeWrapper,
  unzip,
  pkgs,
}:

let
  version = "93.0.0";

  # nixpkgs only provides the top-level `cocoapods` for darwin; elsewhere the
  # Ruby gem is the only build that yields the `pod` executable.
  cocoapods = if pkgs.stdenv.hostPlatform.isDarwin then pkgs.cocoapods else pkgs.rubyPackages.cocoapods;

  # Everything `ort requirements` reports as needed, so that the tools are
  # discoverable on the launcher's PATH. Tools missing from nixpkgs are
  # packaged in this repository alongside ort.
  dependencies = with pkgs; [
    # Package managers
    bazel
    buildozer
    cargo
    conan
    dart # 'dart' for Pub
    fnm
    # gleam-overlay を適用しているので pkgs.gleam はバージョンの attrset。
    # 素の derivation ではないため .bin.latest まで下りる (packages/development.nix と同じ)。
    gleam.bin.latest
    go
    nodejs_24 # 'node' and 'npm'
    bun
    pnpm
    pipenv
    poetry
    sbt
    stack
    swift
    yarn
    phpPackages.composer # 'composer'

    # Scanners
    askalono
    licensee
    python3Packages.scancode-toolkit # 'scancode'

    # Version control systems
    git
    git-repo # 'repo'
    mercurial # 'hg'
  ]
  ++ [
    cocoapods # 'pod'
    (pkgs.callPackage ../abom/package.nix { })
    (pkgs.callPackage ../bombom/package.nix { })
    (pkgs.callPackage ../bower/package.nix { })
    (pkgs.callPackage ../mix_sbom/package.nix { })
    (pkgs.callPackage ../nuget-inspector/package.nix { })
    (pkgs.callPackage ../python-inspector/package.nix { })
    (pkgs.callPackage ../provenant/package.nix { })
  ];
in
stdenvNoCC.mkDerivation {
  pname = "ort";
  inherit version;

  # Upstream Gradle distribution: bin/ort (POSIX launcher), lib/*.jar and an
  # empty plugin/ directory that the launcher puts on the classpath.
  src = fetchurl {
    url = "https://github.com/oss-review-toolkit/ort/releases/download/${version}/ort-${version}.zip";
    hash = "sha256-7q3glM5bG70po0jUIro3pugMfjo8XpXMZlTs/f8iGKA=";
  };

  nativeBuildInputs = [
    makeWrapper
    unzip
  ];

  # The release is pure Java bytecode, but it is compiled for Java 25
  # (class file major version 69), so the launch wrapper must pin a JDK 25
  # runtime instead of relying on whatever `java` happens to be on PATH.
  installPhase = ''
    runHook preInstall

    mkdir -p $out/libexec/ort
    cp -R lib plugin bin $out/libexec/ort/
    chmod +x $out/libexec/ort/bin/ort

    # `bin/ort` infers APP_HOME from its own location, so it must stay next to
    # lib/ and plugin/. The wrapper therefore only supplies JAVA_HOME and the
    # tool PATH, and leaves the launcher's classpath resolution untouched.
    makeWrapper $out/libexec/ort/bin/ort $out/bin/ort \
      --set JAVA_HOME ${jdk25} \
      --prefix PATH : ${lib.makeBinPath (dependencies ++ [ jdk25 ])}

    runHook postInstall
  '';

  passthru.ortDependencies = dependencies;

  meta = {
    description = "The OSS Review Toolkit: a suite of tools to assist with reviewing open source software dependencies";
    homepage = "https://github.com/oss-review-toolkit/ort";
    downloadPage = "https://github.com/oss-review-toolkit/ort/releases/tag/${version}";
    license = lib.licenses.asl20;
    mainProgram = "ort";
    platforms = lib.platforms.unix;
    sourceProvenance = [ lib.sourceTypes.binaryBytecode ];
  };
}
