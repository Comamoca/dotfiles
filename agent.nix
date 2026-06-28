{ config, pkgs, lib, ... }:
{
  nixpkgs.config.allowUnfree = true;
  networking.useHostResolvConf = lib.mkForce false;
  services.resolved.enable = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  environment.systemPackages = with pkgs; [
    git
    claude-agent-acp
  ];

  users.users.coma = {
    isNormalUser = true;
    description = "coma";
    extraGroups = [ "wheel" "networkmanager" ];
    packages = with pkgs; [
      git
      claude-agent-acp
    ];
  };

  system.stateVersion = "24.11";
}

