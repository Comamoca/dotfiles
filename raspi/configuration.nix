{
  config,
  pkgs,
  lib,
  inputs,
  modulesPath,
  ...
}:

let
  user = "guest";
  password = "guest";
  hostname = "raspi";

  opensrc = import ../packages/opensrc.nix { inherit pkgs; };
  picoclaw = import ../packages/picoclaw.nix { inherit pkgs; };
in
{
  nixpkgs.hostPlatform = "aarch64-linux";
  nixpkgs.config.allowUnfree = true;

  boot.kernelPackages = pkgs.linuxPackages_rpi3;
  nixpkgs.config.permittedInsecurePackages = [ "olm-3.2.16" ];

  imports = [
    "${modulesPath}/installer/sd-card/sd-image-aarch64.nix"
    "${modulesPath}/profiles/minimal.nix"
    # inputs.nixos-hardware.nixosModules.raspberry-pi-3
  ];

  boot = {
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
    usePredictableInterfaceNames = false;
    hostName = hostname;
    networkmanager.enable = true;
  };

  environment.systemPackages = with pkgs; [
    vim
    networkmanager
    docker-compose
    gh
    opencode
    opensrc
  ] ++ [
    picoclaw
  ];

  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
  };

  services.tailscale = {
    enable = true;
    extraUpFlags = [ "--ssh" ];
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  users.users.coma = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "docker" "hermes" ];
    initialPassword = "changeme";
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

  hardware.enableRedistributableFirmware = true;

  services.dbus.implementation = "dbus";

  systemd.services.nscd.startLimitIntervalSec = lib.mkForce 0;

  # Flakesとnix-commandを有効化
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "root" "coma" ];
    max-jobs = 1;
    cores = 1;
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

  sops = {
    defaultSopsFile = ../secrets/raspi/hermes.yaml;
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    secrets = {
      "OPENROUTER_API_KEY" = { };
      "TELEGRAM_BOT_TOKEN" = { };
      "TELEGRAM_ALLOWED_USERS" = { };

      "R2_ACCESS_KEY_ID" = { };
      "R2_SECRET_ACCESS_KEY" = { };
      "R2_ENDPOINT" = { };
      "OPENCODE_GO_API_KEY" = {}; 

      "WIFI_SSID" = { };
      "WIFI_PASSWORD" = { };
    };
    templates."openclaw-env" = {
      content = ''
        OPENROUTER_API_KEY=${config.sops.placeholder."OPENROUTER_API_KEY"}
        TELEGRAM_BOT_TOKEN=${config.sops.placeholder."TELEGRAM_BOT_TOKEN"}
        TELEGRAM_ALLOWED_USERS=${config.sops.placeholder."TELEGRAM_ALLOWED_USERS"}
        OPENCODE_GO_API_KEY=${config.sops.placeholder."OPENCODE_GO_API_KEY"}

        R2_ACCESS_KEY_ID=${config.sops.placeholder."R2_ACCESS_KEY_ID"}
        R2_SECRET_ACCESS_KEY=${config.sops.placeholder."R2_SECRET_ACCESS_KEY"}
        R2_ENDPOINT=${config.sops.placeholder."R2_ENDPOINT"}
      '';
    };
    # templates."hermes-env" = {
    #   content = ''
    #     OPENROUTER_API_KEY=${config.sops.placeholder."OPENROUTER_API_KEY"}
    #     TELEGRAM_BOT_TOKEN=${config.sops.placeholder."TELEGRAM_BOT_TOKEN"}
    #     TELEGRAM_ALLOWED_USERS=${config.sops.placeholder."TELEGRAM_ALLOWED_USERS"}
    #     OPENCODE_GO_API_KEY=${config.sops.placeholder."OPENCODE_GO_API_KEY"}
    # 
    #     R2_ACCESS_KEY_ID=${config.sops.placeholder."R2_ACCESS_KEY_ID"}
    #     R2_SECRET_ACCESS_KEY=${config.sops.placeholder."R2_SECRET_ACCESS_KEY"}
    #     R2_ENDPOINT=${config.sops.placeholder."R2_ENDPOINT"}
    #   '';
    #     };

    templates."wifi-nmconnection" = {
      content = ''
        [connection]
        id=${config.sops.placeholder."WIFI_SSID"}
        type=wifi
        interface-name=wlan0
        autoconnect=true

        [wifi]
        mode=infrastructure
        ssid=${config.sops.placeholder."WIFI_SSID"}

        [wifi-security]
        key-mgmt=wpa-psk
        psk=${config.sops.placeholder."WIFI_PASSWORD"}

        [ipv4]
        method=auto

        [ipv6]
        method=auto
      '';
    };

    templates."picoclaw-config" = {
      content = ''
        {
          "version": 3,
          "agents": {
            "defaults": {
              "workspace": "/var/lib/picoclaw/workspace",
              "restrict_to_workspace": true,
              "model_name": "openrouter/google/gemini-3-flash-preview"
            }
          },
          "model_list": [
            {
              "model_name": "openrouter/google/gemini-3-flash-preview",
              "model": "openrouter/google/gemini-3-flash-preview",
              "api_keys": ["${config.sops.placeholder."OPENROUTER_API_KEY"}"],
              "api_base": "https://openrouter.ai/api/v1"
            }
          ]
        }
      '';
    };
  };

  # sopsテンプレートからNetworkManager WiFi接続プロファイルを配置
  system.activationScripts.wifi-nmconnection = {
    text = ''
      mkdir -p /etc/NetworkManager/system-connections/
      cp ${config.sops.templates."wifi-nmconnection".path} /etc/NetworkManager/system-connections/home-wifi.nmconnection
      chmod 600 /etc/NetworkManager/system-connections/home-wifi.nmconnection
    '';
    deps = [ "setupSecrets" ];
  };

  systemd.services.picoclaw = {
    description = "picoclaw AI assistant gateway";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "simple";
      ExecStart = "${picoclaw}/bin/picoclaw gateway";
      Environment = "PICOCLAW_HOME=/var/lib/picoclaw";
      Restart = "always";
      RestartSec = 10;
      User = "picoclaw";
      Group = "picoclaw";
      StateDirectory = "picoclaw";
      StateDirectoryMode = "0750";
      UMask = "0077";
    };

    preStart = ''
      ln -sf ${config.sops.templates."picoclaw-config".path} /var/lib/picoclaw/config.json
    '';
  };

  users.users.picoclaw = {
    isSystemUser = true;
    group = "picoclaw";
    home = "/var/lib/picoclaw";
    createHome = true;
  };
  users.groups.picoclaw = { };

  # services.openclaw-gateway = {
  #   enable = true;
  #   package = pkgs.openclaw-gateway;
  #   environmentFiles = [ config.sops.templates."openclaw-env".path ];
  #   config = {
  #     agents.defaults.model.primary = "openrouter/google/gemini-3-flash-preview";
  #     channels.telegram.enabled = true;
  #   };
  # };

  system.activationScripts.picoclaw-workspace = {
    text = ''
      dir=/var/lib/picoclaw/workspace
      mkdir -p "$dir/skills"
      for f in AGENTS.md SOUL.md TOOLS.md USER.md IDENTITY.md; do
        src=${inputs.openclaw-workspace}/"$f"
        [ -f "$src" ] && cp "$src" "$dir/$f"
      done
      cp -r ${inputs.openclaw-workspace}/skills/. "$dir/skills/"
      chown -R picoclaw:picoclaw /var/lib/picoclaw
    '';
    deps = [ "users" "groups" ];
  };

  system.stateVersion = "25.05";
}
