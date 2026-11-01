{
  config,
  pkgs,
  lib,
  modulesPath,
  ...
}:

let
  hostname = "orangepi5";

  # ルートパーティションの UUID。イメージを焼き直しても
  # /dev/disk/by-label/NIXOS_SD で引けるよう、label と併記しておく。
  # 固定値にしておくと deploy-rs で更新するときも fileSystems が揺れない。
  rootFsUUID = "b6f0e1d3-4a94-4b34-9b6a-2a5c6f7d8e01";
in
{
  nixpkgs.hostPlatform = "aarch64-linux";
  nixpkgs.config.allowUnfree = true;

  imports = [
    "${modulesPath}/profiles/minimal.nix"
    # GPT + raw U-Boot の SD イメージ (system.build.sdImage を提供)。
    # nixpkgs の sd-image.nix は MBR 固定で RK3588 の u-boot.itb が入らないため
    # 使わない。詳細は orangepi5/image.nix。
    ./image.nix
  ];

  # RK3588S は mainline Linux で動く。ベンダーカーネル (6.1) ではなく
  # 最新の mainline を使う。Orange Pi 5 の DTB は
  # rk3588s-orangepi-5.dtb として mainline に含まれる。
  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot = {
    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "usbhid"
        "usb_storage"
        "sdhci_of_dwcmshc"
        "sd_mod"
        "mmc_block"
        "nvme"
      ];
      kernelModules = [ ];
    };
    loader.grub.enable = false;

    # U-Boot が読む extlinux.conf を /boot に置く。sdImage 側も同じ populateCmd で
    # イメージ内の /boot/extlinux を作るので、nixos-rebuild 後の再起動でも
    # ブートローダの設定が一致する。
    loader.generic-extlinux-compatible = {
      enable = true;
      configurationLimit = 5;
    };

    # コンソールを両方有効にする。HDMI が出ないときはシリアルで原因を
    # 読めるようにしておく (Orange Pi 5 の UART は 1500000 baud)。
    kernelParams = [
      "console=tty1"
      "console=ttyS2,1500000"
      "earlycon=uart8250,mmio32,0xfeb50000"
    ];
  };

  orangepi5.image = {
    enable = true;
    rootVolumeLabel = "NIXOS_SD";
    rootPartitionUUID = rootFsUUID;
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXOS_SD";
    fsType = "ext4";
    options = [ "noatime" ];
  };

  networking = {
    usePredictableInterfaceNames = false;
    hostName = hostname;
    networkmanager.enable = true;
    # 有線 (stmmac) は NetworkManager に任せる。Wi-Fi (AP6275P, PCIe接続) は
    # モジュールとファームウェアが必要なので、model によっては動かない。
    # まずは有線で到達できる前提にしておく。
  };

  environment.systemPackages =
    with pkgs;
    [
      vim
      networkmanager
      gh
      opencode
      btop
      pciutils
      usbutils
      i2c-tools
      nvme-cli
    ];

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  services.tailscale = {
    enable = true;
    extraUpFlags = [ "--ssh" ];
  };

  users.users.coma = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    # コンソール用パスワードは初回ログイン後に `sudo passwd coma` で設定する。
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGHn646g17wEv7rZoSKQCFNGGyLqVJnQ9mlEn7aQuOLj coma@comabook"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHPL4pgOxCwPRIGRDuIt7KeExLZqNdQ3VsbAqgGeaLNV u0_a588@localhost"
    ];
  };

  security.sudo.wheelNeedsPassword = false;
  time.timeZone = "Asia/Tokyo";

  console = {
    font = "Lat2-Terminus16";
    keyMap = "jp106";
  };

  i18n.defaultLocale = "ja_JP.UTF-8";

  # オンボードの Wi-Fi/Bluetooth モジュール (AP6xxx 系) のファームウェア。
  # 動かなくても有線で運用できるので、失敗しても起動は止めない。
  hardware.enableRedistributableFirmware = true;
  hardware.enableAllFirmware = true;

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [
      "root"
      "coma"
    ];
    # 8 コア / 8GB (または 16GB)。ビルドマシンと揃えるため、
    # 実機でのビルドは控えめにする (deploy-rs が remote build を使う)。
    max-jobs = 4;
    cores = 8;
    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  # 省電力のため、普段はアイドル時のクロックを落とす。mainline の
  # cpufreq は schedutil が既定なので、明示しない。
  powerManagement.enable = lib.mkDefault true;

  system.stateVersion = "25.11";
}
