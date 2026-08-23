{ pkgs, ... }:
{
  projectRootFile = "flake.nix";
  programs = {
    nixfmt.enable = true;
    taplo.enable = true;
    deno = {
      enable = true;
      # deno-overlay は pkgs.deno をバージョン集合に置き換えるため、
      # オーバーレイ非適用時(flake checks)は素の package にフォールバックする。
      package = pkgs.deno."2.5.4" or pkgs.deno;
    };
    stylua.enable = true;
  };

  settings.formatter = {
    "stylua".options = [
      "--indent-type"
      "Spaces"
      "--indent-width"
      "2"
    ];
  };
}
