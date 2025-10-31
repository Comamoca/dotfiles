{ pkgs, emacs', nurpkgs }:
with pkgs; [
  # Editors
  vim-full
  emacs'
  felix
  micro
  neovim

  # Editor tools
  emacs-lsp-booster
  tree-sitter
]
