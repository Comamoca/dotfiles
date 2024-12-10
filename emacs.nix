{ pkgs, epkgs }:
let
  hydra-posframe = pkgs.emacsPackages.trivialBuild {
    pname = "hydra-posframe";
    version = "master";
    src = pkgs.fetchFromGitHub {
      owner = "Ladicle";
      repo = "hydra-posframe";
      rev = "master";
      sha256 = "sha256-9nVBnpaWZIYNDvS2WWBED0HsIRIv4AR4as6wEe463tI=";
    };

    buildInputs = with pkgs.emacsPackages; [ hydra posframe ];
  };

  typst-preview = pkgs.emacsPackages.trivialBuild {
    pname = "typst-preview";
    version = "master";
    src = pkgs.fetchFromGitHub {
      owner = "havarddj";
      repo = "typst-preview.el";
      rev = "master";
      sha256 = "sha256-AJRWw8c13C6hfwO28hXERN4cIc6cFTbNBcz2EzqqScg=";
    };

    buildInputs = with pkgs.emacsPackages; [ websocket ];
  };
in {
  epkgs = with epkgs; [
    vterm
    catppuccin-theme
    vertico
    orderless
    hotfuzz 
    consult
    consult
    embark-consult
    consult-ghq
    evil
    puni 
    highlight-indent-guides
    treesit-auto
    org
    org-journal
    org-roam
    org-roam-ui
    magit
    ddskk 
    slime 
    sly 
    sly-asdf
    eglot
    lua-mode
    corfu
    cape 
    kind-icon
    all-the-icons
    hydra
    hydra-posframe
    kind-icon
    all-the-icons
    transient-dwim
    neotree 
    google-translate
    wakatime-mode
    typst-preview
    nix-mode
    gleam-ts-mode
    markdown-mode
    projectile 
    migemo
    nyan-mode
    yasnippet
    yasnippet-snippets
    yatemplate 
    request
    expand-region
  ];
}
