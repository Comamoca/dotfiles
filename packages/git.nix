{ pkgs }:
with pkgs;
[
  # Git tools
  # (import ../pkgs/git-wt { inherit pkgs; })
  git
  # delta  # Home Managerから管理するため
  lazygit
  tig
  github-cli
  ghq
  worktrunk 
]
