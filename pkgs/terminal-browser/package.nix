{
  lib,
  stdenv,
  stdenvNoCC,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  electron_43,
  bash,
}:

let
  version = "0.6.0";
  channel = "stable";

  # Assets published by the upstream install script (https://terminal-browser.sh/install):
  #   https://terminal-browser.sh/install/dl/$channel/v$version/terminal-browser-$target.tar.gz
  #
  # darwin-arm64 also exists upstream, but that tarball ships a
  # terminal-browser.app bundle instead of a bare electron directory, so it
  # needs a different install phase than the one below.
  sources = {
    "x86_64-linux" = {
      target = "linux-x64";
      hash = "sha256-fCN1WTYjoSEJYV7KlM6u7OamGTxMyVW6FZIV8PbAn/c=";
    };
    "aarch64-linux" = {
      target = "linux-arm64";
      hash = "sha256-JNBs4m/bhBcRTWFMW/Fu5IGqtXM/SeJPVXynoEGoL0o=";
    };
  };

  source =
    sources.${stdenvNoCC.hostPlatform.system}
      or (throw "terminal-browser: no prebuilt release is packaged for ${stdenvNoCC.hostPlatform.system}");
in
stdenvNoCC.mkDerivation {
  pname = "terminal-browser";
  inherit version;

  src = fetchurl {
    url = "https://terminal-browser.sh/install/dl/${channel}/v${version}/terminal-browser-${source.target}.tar.gz";
    inherit (source) hash;
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  # browser/native/pixel.node is a N-API addon linked against libstdc++.
  buildInputs = [ (lib.getLib stdenv.cc.cc) ];

  dontStrip = true;

  installPhase = ''
    runHook preInstall

    dist=$out/libexec/terminal-browser
    mkdir -p "$dist" $out/bin $out/share/terminal-browser

    cp -R agent-browser assets browser cli scripts VERSION CHANNEL "$dist"/

    # The skills tree is what the upstream installer symlinks into
    # ~/.claude/skills and friends; keep it somewhere addressable.
    cp -R skills $out/share/terminal-browser/skills
    ln -s $out/share/terminal-browser/skills "$dist/skills"

    # The 300 MB electron the tarball bundles is dropped in favour of the
    # nixpkgs build, which is already patched for this system. The CLI looks
    # the runtime up at $TERMINAL_BROWSER_DIST_ROOT/electron/electron and
    # spawns it directly, so the wrapper (not the unwrapped binary) goes there
    # to keep GTK/GIO/gsettings set up.
    mkdir -p "$dist/electron"
    ln -s ${lib.getExe electron_43} "$dist/electron/electron"

    chmod +x "$dist/agent-browser/bin/agent-browser" "$dist/scripts/apparmor.sh"

    makeWrapper ${lib.getExe electron_43} $out/bin/terminal-browser \
      --add-flags "$dist/cli/dist/main.js" \
      --set ELECTRON_RUN_AS_NODE 1 \
      --set TERMINAL_BROWSER_DIST_ROOT "$dist" \
      --suffix PATH : ${lib.makeBinPath [ bash ]}

    runHook postInstall
  '';

  meta = {
    description = "Browser that renders web pages inside a terminal pane";
    homepage = "https://terminal-browser.com";
    downloadPage = "https://terminal-browser.sh/install";
    license = lib.licenses.unfree;
    mainProgram = "terminal-browser";
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = lib.attrNames sources;
  };
}
