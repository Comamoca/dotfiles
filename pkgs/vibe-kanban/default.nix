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

  src = sources.vibe-kanban.src;
  version = sources.vibe-kanban.version;
in
pkgs.rustPlatform.buildRustPackage rec {
  pname = "vibe-kanban";
  inherit version src;

  cargoHash = pkgs.lib.fakeHash;

  pnpmDeps = pkgs.pnpm.fetchDeps {
    pname = "${pname}-web";
    inherit version src;
    hash = pkgs.lib.fakeHash;
  };

  nativeBuildInputs = with pkgs; [
    pkg-config
    cmake
    nodejs_22
    pnpm.configHook
  ];

  buildInputs = with pkgs; [
    openssl
    sqlite
    libgit2
    zlib
  ];

  preBuild = ''
    # Build frontend assets (embedded into Rust binary via rust-embed)
    export HOME=$(mktemp -d)
    pnpm install --frozen-lockfile --offline
    pnpm --filter local-web build
  '';

  env = {
    VK_SHARED_API_BASE = "https://api.vibekanban.com";
    VITE_VK_SHARED_API_BASE = "https://api.vibekanban.com";
  };

  doCheck = false;

  meta = with pkgs.lib; {
    description = "AI-powered Kanban board for project management";
    homepage = "https://github.com/BloopAI/vibe-kanban";
    license = licenses.unfree;
    mainProgram = "server";
    maintainers = [ ];
  };
}
