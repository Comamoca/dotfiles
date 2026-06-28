{
  pkgs,
  epkgs,
  nurpkgs,
}:
let
  generated = import ./_sources/generated.nix;
  sources = generated {
    inherit (pkgs)
      fetchurl
      fetchgit
      fetchFromGitHub
      dockerTools
      ;
  };

  ruby-ts-mode = pkgs.emacsPackages.trivialBuild {
    pname = "ruby-ts-mode";
    version = "main";
    src = sources.ruby-ts-mode.src;
    buildInputs = with pkgs.emacsPackages; [
    ];
  };

  php-ts-mode = pkgs.emacsPackages.trivialBuild {
    pname = "php-ts-mode";
    version = "main";
    src = sources.php-ts-mode.src;
    buildInputs = with pkgs.emacsPackages; [
    ];
  };

  om-dash = pkgs.emacsPackages.trivialBuild {
    pname = "om-dash";
    version = "main";
    src = sources.om-dash.src;
    buildInputs = with pkgs.emacsPackages; [
      org-ql
      s
      ts
    ];
  };

  minimal-dashboard = pkgs.emacsPackages.trivialBuild {
    pname = "minimal-dashboard";
    version = "main";
    src = sources.minimal-dashboard.src;
    buildInputs = with pkgs.emacsPackages; [
    ];
  };

  agent-shell-manager = pkgs.emacsPackages.trivialBuild {
    pname = "agent-shell-manager";
    version = "main";
    src = sources.agent-shell-manager.src;
    buildInputs = with pkgs.emacsPackages; [
      agent-shell
      acp
      shell-maker
    ];
  };

  eca = pkgs.emacsPackages.trivialBuild {
    pname = "eca";
    version = "main";
    src = sources.eca.src;
    buildInputs = with pkgs.emacsPackages; [
      dash
      f
      markdown-mode
      compat
    ];
  };

  gerbil-mode = pkgs.emacsPackages.trivialBuild {
    pname = "gerbil-mode";
    version = "main";
    src = sources.gerbil.src;
    buildInputs = with pkgs.emacsPackages; [ ];
  };

  claudemacs = pkgs.emacsPackages.trivialBuild {
    pname = "claudemacs";
    version = "main";
    src = sources.claudemacs.src;
    buildInputs = with pkgs.emacsPackages; [ ];
  };

  claude-code = pkgs.emacsPackages.trivialBuild {
    pname = "claude-code";
    version = "main";
    src = sources.claude-code.src;
    buildInputs = with pkgs.emacsPackages; [
      eat
      transient
      inheritenv
    ];
  };

  smartchr = pkgs.emacsPackages.trivialBuild {
    pname = "smartchr";
    version = "main";
    src = sources.smartchr.src;
    buildInputs = with pkgs.emacsPackages; [
      ert-expectations
    ];
  };

  smudge = pkgs.emacsPackages.trivialBuild {
    pname = "smudge";
    version = "main";
    src = sources.smudge.src;
    buildInputs = with pkgs.emacsPackages; [
      oauth2
      request
      simple-httpd
    ];
  };

  quickrun = pkgs.emacsPackages.trivialBuild {
    pname = "quickrun";
    version = "main";
    src = sources.quickrun.src;
    buildInputs = with pkgs.emacsPackages; [
      ht
    ];
  };

  verb = pkgs.emacsPackages.trivialBuild {
    pname = "verb";
    version = "main";
    src = sources.verb.src;
    buildInputs = with pkgs; [ ];
  };

  rainbow-delimiters = pkgs.emacsPackages.trivialBuild {
    pname = "rainbow-delimiters";
    version = "main";
    src = sources.rainbow-delimiters.src;
    buildInputs = with pkgs; [ ];
  };

  mcp = pkgs.emacsPackages.trivialBuild {
    pname = "mcp";
    version = "main";
    src = sources.mcp.src;
    buildInputs = with pkgs.emacsPackages; [ ];
  };

  digs = pkgs.emacsPackages.trivialBuild {
    pname = "digs";
    version = "main";
    src = sources.digs.src;
    buildInputs = with pkgs.emacsPackages; [ ];
  };

  aider = pkgs.emacsPackages.trivialBuild {
    pname = "aider";
    version = "main";
    src = sources.aider.src;
    buildInputs = with pkgs.emacsPackages; [
      transient
      magit
      markdown-mode
      s
    ];
  };

  folding-mode = pkgs.emacsPackages.trivialBuild {
    pname = "folding-mode";
    version = "main";
    src = sources.folding-mode.src;
    buildInputs = with pkgs.emacsPackages; [ ];
  };

  ob-ledger = pkgs.emacsPackages.trivialBuild {
    pname = "ob-ledger";
    version = "main";
    src = sources.ob-ledger.src;
    buildInputs = with pkgs.emacsPackages; [ org ];
  };

  kdl-ts-mode = pkgs.emacsPackages.trivialBuild {
    pname = "kdl-ts-mode";
    version = "main";
    src = sources.kdl-ts-mode.src;
    buildInputs = with pkgs.emacsPackages; [ ];
  };

  slite = pkgs.emacsPackages.trivialBuild {
    pname = "slite";
    version = "main";
    src = sources.slite.src;
    buildInputs = with pkgs.emacsPackages; [ ];
  };

  hydra-posframe = pkgs.emacsPackages.trivialBuild {
    pname = "hydra-posframe";
    version = "master";
    src = sources.hydra-posframe.src;
    buildInputs = with pkgs.emacsPackages; [
      hydra
      posframe
    ];
  };

  typst-ts-mode = pkgs.emacsPackages.trivialBuild {
    pname = "typst-ts-mode";
    version = "main";
    src = sources.typst-ts-mode.src;
    buildInputs = with pkgs.emacsPackages; [ ];
  };

  typst-mode = pkgs.emacsPackages.trivialBuild rec {
    pname = "typst-mode";
    version = "main";
    src = sources.typst-mode.src;
    buildInputs = with pkgs.emacsPackages; [ polymode ];
  };

  typst-preview = pkgs.emacsPackages.trivialBuild {
    pname = "typst-preview";
    version = "master";
    src = sources.typst-preview.src;
    buildInputs = with pkgs.emacsPackages; [
      websocket
      f
    ];
  };

  org-modern-indent = pkgs.emacsPackages.trivialBuild {
    pname = "org-modern-indent";
    version = "master";
    src = sources.org-modern-indent.src;
    buildInputs = with pkgs.emacsPackages; [ compat ];
  };

  skk-capf = pkgs.emacsPackages.trivialBuild {
    pname = "skk-capf";
    version = "master";
    src = sources.skk-capf.src;
    buildInputs = with pkgs.emacsPackages; [ compat ];
  };

  python-mode = pkgs.emacsPackages.trivialBuild {
    pname = "python-mode";
    version = "master";
    src = sources.python-mode.src;
    buildInputs = with pkgs.emacsPackages; [ compat ];
  };

  gleam-mode = pkgs.emacsPackages.trivialBuild {
    pname = "gleam-mode";
    version = "master";
    src = sources.gleam-mode.src;
    buildInputs = with pkgs.emacsPackages; [
      tree-sitter
      tree-sitter-indent
    ];
  };

  org-bullets = pkgs.emacsPackages.trivialBuild {
    pname = "org-bullets";
    version = "master";
    src = sources.org-bullets.src;
    buildInputs = with pkgs.emacsPackages; [
      tree-sitter
      tree-sitter-indent
    ];
  };

  eglot-booster = pkgs.emacsPackages.trivialBuild {
    pname = "eglot-booster";
    version = "main";
    src = sources.eglot-booster.src;
    buildInputs = with pkgs.emacsPackages; [
      eglot
      jsonrpc
    ];
  };

  copilot = pkgs.emacsPackages.trivialBuild {
    pname = "copilot.el";
    version = "main";
    src = sources.copilot.src;
    buildInputs = with pkgs.emacsPackages; [
      pkgs.nodejs_24
      jsonrpc
      f
      s
      dash
      editorconfig
    ];
  };

  ob-gleam = pkgs.emacsPackages.trivialBuild {
    pname = "ob-gleam";
    version = "main";
    src = sources.ob-gleam.src;
  };

  tramps3 = pkgs.emacsPackages.trivialBuild {
    pname = "tramps3 ";
    version = "main";
    src = sources.tramps3.src;
    buildInputs = with pkgs.emacsPackages; [
      seq
      dash
    ];
  };
  
  nskk = pkgs.emacsPackages.trivialBuild {
    pname = "nskk";
    version = "main";
    src = "${sources.nskk.src}/src";
    buildInputs = with pkgs.emacsPackages; [
    ];
  };

  kuro-native = pkgs.rustPlatform.buildRustPackage {
    pname = "kuro-core";
    version = "main";
    src = sources.kuro.src;
    cargoLock = {
      lockFile = "${sources.kuro.src}/Cargo.lock";
    };
    buildInputs = [ pkgs.emacs ];
    nativeBuildInputs = [ pkgs.pkg-config ];
    cargoBuildFlags = [ "--package" "kuro-core" "--lib" ];
    doCheck = false;
    installPhase = ''
      runHook preInstall
      mkdir -p $out/lib
      find target -name "libkuro_core.so" -not -path "*/deps/*" -exec cp {} $out/lib/ \;
      runHook postInstall
    '';
  };

  kuro = pkgs.emacsPackages.trivialBuild {
    pname = "kuro";
    version = "main";
    src = "${sources.kuro.src}/emacs-lisp";
    postPatch = ''
      # kuro--run-session-setup-fns is a macro that references
      # kuro--session-setup-fns at expansion time, but the defconst is in
      # kuro-lifecycle.el -- not loaded during batch compilation. Convert
      # to a function so the variable is evaluated at runtime instead.
      awk '
        /^\(defmacro kuro--run-session-setup-fns/ {
          print "(defun kuro--run-session-setup-fns ()"
          print "  \"Run the fixed session setup sequence in order.\""
          print "  (dolist (fn kuro--session-setup-fns)"
          print "    (funcall fn)))"
          getline; getline; getline; getline
          next
        }
        { print }
      ' core/kuro-lifecycle-macros.el > _tmp.el
      mv _tmp.el core/kuro-lifecycle-macros.el
    '';
    preBuild = ''
      find . -mindepth 2 -name "*.el" -exec cp --backup=numbered {} . \;
    '';
    postInstall = ''
      cp ${kuro-native}/lib/libkuro_core.so $out/share/emacs/site-lisp/
    '';
  };

  shell-maker = pkgs.emacsPackages.trivialBuild {
    pname = "shell-maker";
    version = "main";
    src = sources.shell-maker.src;
    buildInputs = with pkgs.emacsPackages; [ ];
  };

  acp = pkgs.emacsPackages.trivialBuild {
    pname = "acp";
    version = "main";
    src = sources.acp.src;
    buildInputs = [ shell-maker ];
  };

  agent-shell = pkgs.emacsPackages.trivialBuild {
    pname = "agent-shell";
    version = "main";
    src = sources.agent-shell.src;
    buildInputs = [ shell-maker acp ];
  };
in
{
  epkgs = with epkgs; [
    vterm
    multi-vterm
    vterm-toggle

    catppuccin-theme
    vertico
    vertico-posframe
    orderless
    hotfuzz

    consult
    affe

    embark-consult
    consult-ghq
    evil

    puni
    lispy
    lispyville

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
    om-dash
    org-ql
    org-contrib
    org-project-capture
    org-projectile

    calfw
    calfw-org
    calfw-ical
    calfw-gcal
    calfw-cal

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
    eglot-booster
    eldoc-box

    lsp-mode
    lsp-ui

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
    google-translate
    wakatime-mode

    typst-preview
    typst-ts-mode
    typst-mode
    kotlin-ts-mode
    php-ts-mode
    ruby-ts-mode

    lua-mode
    nix-mode
    nix-ts-mode
    gleam-mode
    gleam-ts-mode
    markdown-mode
    astro-ts-mode

    project
    projectile
    persp-projectile
    migemo
    nyan-mode

    yasnippet
    yatemplate
    yasnippet-snippets
    yasnippet-capf

    request
    macrostep

    leaf
    leaf-manager
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
    ob-ledger
    ob-gleam

    envrc

    flycheck
    flycheck-posframe
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
    inf-elixir
    mix

    smartparens
    evil-smartparens
    plz

    dash

    ox-zenn
    rg

    lsp-bridge

    org-bullets
    editorconfig
    open-junk-file
    reformatter

    copilot
    kdl-ts-mode
    dotnet
    web-mode
    sharper

    ledger-mode
    flycheck-ledger
    evil-ledger

    forge
    consult-gh-forge

    tempel
    tempel-collection
    aas

    grugru
    good-scroll
    sublimity
    iscroll

    folding-mode
    minimap
    dashboard
    god-mode
    dimmer
    focus
    ox-typst
    ace-window
    digs
    undo-tree
    mcp

    gnuplot
    gnuplot-mode

    rainbow-delimiters

    verb
    quickrun
    folding-mode

    oauth2
    smudge
    smartchr

    ox-typst
    eat

    # coding agent
    claude-shell
    shell-maker
    acp
    agent-shell
    agent-shell-manager

    haskell-mode

    dirvish
    claudemacs
    sparql-mode

    exec-path-from-shell

    emmet-mode

    go-mode
    gerbil-mode

    # Formating
    apheleia

    # Aider
    aidermacs
    aider

    # PHP
    php-mode

    # Library
    alert
    dash
    s

    just-mode

    # ECA
    eca

    # Claude Code
    claude-code

    #highlight
    polymode
    poly-markdown 

    tramps3
    consult-ghq

    nskk
    kuro
    sparql-mode

    perspective
    treemacs
    treemacs-evil
    treemacs-projectile
    treemacs-perspective

    minimal-dashboard
    dashboard
    howm

    justl
  ];
}
