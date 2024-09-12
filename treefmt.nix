{ pkgs, ... }:
{
  projectRootFile = "flake.nix";
  programs = {
    nixfmt.enable = true;
    taplo.enable = true;
    deno.enable = true;
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
