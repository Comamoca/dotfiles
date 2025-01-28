{
  pkgs,
  epkgs,
  nurpkgs,
}:
let
  slite = pkgs.emacsPackages.trivialBuild {
    pname = "slite";
    version = "main";
    src = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/tdrhq/slite/refs/heads/main/slite.el";
      hash = "sha256-ohVZUSpHNDLna6BmFtgtUSKV7Pj6Nj+67imVWXWn+mQ=";
    };
    buildInputs = with pkgs.emacsPackages; [ ];
  };

  hydra-posframe = pkgs.emacsPackages.trivialBuild {
    pname = "hydra-posframe";
    version = "master";
    src = pkgs.fetchFromGitHub {
      owner = "Ladicle";
      repo = "hydra-posframe";
      rev = "master";
      sha256 = "sha256-9nVBnpaWZIYNDvS2WWBED0HsIRIv4AR4as6wEe463tI=";
    };

    buildInputs = with pkgs.emacsPackages; [
      hydra
      posframe
    ];
  };

  typst-ts-mode = pkgs.emacsPackages.trivialBuild {
    pname = "typst-ts-mode";
    version = "main";
    src = pkgs.fetchgit {
      url = "https://git.sr.ht/~meow_king/typst-ts-mode";
      hash = "sha256-0RAJ/Td3G7FDvzf7t8csNs/uc07WUPGvMo8ako5iyl0=";
    };

    buildInputs = with pkgs.emacsPackages; [ ];
  };

  typst-mode = pkgs.emacsPackages.trivialBuild rec {
    pname = "typst-mode";
    version = "main";
    src = pkgs.fetchFromGitHub {
      owner = "Ziqi-Yang";
      repo = "typst-mode.el";
      rev = "master";
      sha256 = "sha256-mqkcNDgx7lc6kUSFFwSATRT+UcOglkeu+orKLiU9Ldg=";
    };

    buildInputs = with pkgs.emacsPackages; [ polymode ];
  };

  typst-preview = pkgs.emacsPackages.trivialBuild {
    pname = "typst-preview";
    version = "master";
    src = pkgs.fetchFromGitHub {
      owner = "havarddj";
      repo = "typst-preview.el";
      rev = "master";
      sha256 = "sha256-c64dRQ7Glkx+QQNWRos33y8nGZDujDk8tGEhb5PMsR0=";
    };

    buildInputs = with pkgs.emacsPackages; [ websocket ];
  };

  org-modern-indent = pkgs.emacsPackages.trivialBuild {
    pname = "org-modern-indent";
    version = "master";
    src = pkgs.fetchFromGitHub {
      owner = "jdtsmith";
      repo = "org-modern-indent";
      rev = "master";
      sha256 = "sha256-9aaaPGCvt51FknRKB5zT8AdHjhH/sQMc1IyQS3KnJsU=";
    };

    buildInputs = with pkgs.emacsPackages; [ compat ];
  };

  skk-capf = pkgs.emacsPackages.trivialBuild {
    pname = "skk-capf";
    version = "master";
    src = pkgs.fetchFromGitHub {
      owner = "myuhe";
      repo = "skk-capf";
      rev = "master";
      sha256 = "sha256-IVkEFRwV2SaIH4xVnTqm2YtNeQ08G2GEiPF9+Kgj3Cc=";
    };

    buildInputs = with pkgs.emacsPackages; [ compat ];
  };

  python-mode = pkgs.emacsPackages.trivialBuild {
    pname = "python-mode";
    version = "master";
    src = pkgs.fetchFromGitHub {
      owner = "emacsmirror";
      repo = "python-mode";
      rev = "master";
      sha256 = "sha256-beYxefE0YDhEI6ZQXNQkZAnYoAabtbn+CwDr+u/hiac=";
    };

    buildInputs = with pkgs.emacsPackages; [ compat ];
  };
in
{
  epkgs = with epkgs; [
    vterm
    catppuccin-theme
    vertico
    orderless
    hotfuzz

    consult
    affe

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
    deft

    org-modern
    org-modern-indent
    org-nix-shell

    magit
    ddskk

    slime
    sly
    sly-asdf
    # nurpkgs.emacs-slite.slite

    cider
    cider-hydra
    cider-eval-sexp-fu
    kaocha-runner

    eglot

    corfu
    cape

    kind-icon
    all-the-icons

    hydra
    hydra-posframe
    major-mode-hydra

    kind-icon
    all-the-icons
    transient-dwim
    neotree
    google-translate
    wakatime-mode

    typst-preview
    typst-ts-mode
    typst-mode

    lua-mode
    nix-mode
    nix-ts-mode
    gleam-ts-mode
    markdown-mode

    projectile
    migemo
    nyan-mode

    yasnippet
    yatemplate
    yasnippet-snippets
    yasnippet-capf

    request
    macrostep

    leaf
    leaf-keywords
    leaf-tree
    leaf-convert

    ddskk
    ddskk-posframe

    direnv
    skk-capf

    avy

    python-mode
    enh-ruby-mode
    ruby-electric

    # for org-babel
    ob-hy
    envrc

    flycheck
    flycheck-pos-tip
    flycheck-inline

    nano-theme
    nurpkgs.nano-tools.box
    nurpkgs.nano-tools.read
    nurpkgs.nano-tools.modeline
    nurpkgs.nano-tools.journal
    nurpkgs.nano-tools.popup

    inf-ruby

    slite

    scala-ts-mode
    scala-mode

    gptel

    elixir-mode

    smartparens
    evil-smartparens
  ];
}
