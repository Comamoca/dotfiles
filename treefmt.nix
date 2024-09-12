{
  projectRootFile = "flake.nix";
  programs = {
    nixfmt.enable = true;
    taplo.enable = true;
    deno.enable = true;
    stylua = {
      enable = true;
      # options = [
      #   "indent_type=Spaces"
      #   "indent_width=2"
      # ];
    };
    #   stylua = {
    #   command = "${pkgs.stylua}/bin/bash";
    #   options = [
    #       "indent_type=Spaces"
    #       "indent_width=2"
    #   ];
    # };
  };
}
