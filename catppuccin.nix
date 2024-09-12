{ fetchFromGitHub }:

{
  fish = fetchFromGitHub {
    name = "fish";
    owner = "catppuccin";
    repo = "fish";
    rev = "1iqmchnz0gglwsxrqcm300754s84gsxrbwmfxh5mdlm16gcr9n5r";
    hash = "sha256-udiU2TOh0lYL7K7ylbt+BGlSDgCjMpy75vQ98C1kFcc=";
  };
}
