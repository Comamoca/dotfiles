{
  config,
  pkgs,
  lib,
  modulesPath,
  ...
}:

let
  user = "guest";
  password = "guest";
  # SSID = "mywifi";
  # SSIDpassword = "mypassword";
  # interface = "wlan0";
  hostname = "raspi";
in
{
  nixpkgs.hostPlatform = "aarch64-linux";

  imports = [
    "${modulesPath}/installer/sd-card/sd-image-aarch64.nix"
    "${modulesPath}/profiles/minimal.nix"
  ];

  # SDイメージのカーネルモジュールリストから存在しないモジュールを除外
  nixpkgs.overlays = [
    (final: prev: {
      makeModulesClosure = x:
        prev.makeModulesClosure (x // {
          allowMissing = true;
        });
    })
  ];

  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_rpi4;
    initrd = {
      # dw-hdmiモジュールが存在しない問題を回避するため、デフォルトモジュールを無効化
      includeDefaultModules = false;
      availableKernelModules = [
        "xhci_pci"
        "usbhid"
        "usb_storage"
        "sd_mod"
        "mmc_block"
      ];
      kernelModules = [ ];
    };
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };

  networking = {
    useNetworkd = true;
    useDHCP = true;

    hostName = hostname;
    wireless = {
      # enable = true;
      # networks."${SSID}".psk = SSIDpassword;
      # interfaces = [ interface ];
    };
  };

  systemd.network.networks."eth0" = {
    matchConfig.Name = "eth0";
    gateway = [ "192.168.10.1" ];
    dns = [ "1.1.1.1" ];
    address = [
      "192.168.10.50/24"
    ];
  };

  environment.systemPackages = with pkgs; [ vim ];

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  users.users.coma = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINZWLYeAZNYt2ZHjJl4zd6rsS+2LT9uL4AqUJid6gikl coma@comabook"
    ];
  };

  security.sudo.wheelNeedsPassword = false;
  time.timeZone = "Asia/Tokyo";

  hardware.enableRedistributableFirmware = true;

  # Flakesとnix-commandを有効化
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "25.05";
}
