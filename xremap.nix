{ pkgs }:
rec {
  xremap-config = {
    modmap = [
      {
        name = "Global";
        remap = {
          Enter = {
            held = "Alt_R";
            alone = "Enter";
          };
          KatakanaHiragana = "Ctrl_R";
          Alt_L = "Super_L";
          Super_L = "Alt_L";
        };
      }
    ];
  };
  xremap-config-yaml = (pkgs.formats.yaml { }).generate "config.yml" xremap-config;
}
