{
  lib,
  stdenv,
  fetchPnpmDeps,
  pnpm_10,
  pnpmConfigHook,
  autoPatchelfHook,
  version,
  cliBinaries,
}:

let
  cliBinary =
    cliBinaries.${stdenv.hostPlatform.system}
      or (throw "vite-plus: unsupported system ${stdenv.hostPlatform.system}");
in
stdenv.mkDerivation (finalAttrs: {
  pname = "vite-plus";
  inherit version;

  src = ./.;

  nativeBuildInputs = [
    pnpm_10
    pnpmConfigHook
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    autoPatchelfHook
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    stdenv.cc.cc.lib
  ];

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    pnpm = pnpm_10;
    hash = "sha256-KQ7XsY9tcLYrbwDnvPar99GnF7E3vv6xRnU7d4w6lCg=";
    fetcherVersion = 3;
    prePnpmInstall = ''
      pnpm config set minimum-release-age 0
    '';
  };

  dontStrip = true;

  installPhase = ''
    runHook preInstall

    dest="$out/libexec/vite-plus/${version}"
    mkdir -p "$dest/bin"

    # Move the pnpm-installed dependency tree as-is; its internal relative
    # symlinks stay valid under the new prefix.
    mv node_modules "$dest/"

    # Extract the platform-specific native CLI binary.
    tar xzf "${cliBinary}" -C "$dest/bin" --strip-components=1
    chmod +x "$dest/bin/vp"

    # The CLI resolves its global vite-plus installation relative to the
    # executable path via ../current/node_modules/vite-plus, so preserve the
    # installer's layout with a version directory and a current symlink.
    ln -sfn "${version}" "$out/libexec/vite-plus/current"

    mkdir -p "$out/bin"
    ln -sfn "../libexec/vite-plus/current/bin/vp" "$out/bin/vp"

    runHook postInstall
  '';

  meta = {
    description = "The Unified Toolchain for the Web";
    homepage = "https://viteplus.dev";
    license = lib.licenses.mit;
    mainProgram = "vp";
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = lib.attrNames cliBinaries;
  };
})
