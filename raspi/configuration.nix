{
  config,
  pkgs,
  lib,
  inputs,
  modulesPath,
  ...
}:

let
  hostname = "raspi";

  opensrc = import ../packages/opensrc.nix { inherit pkgs; };
  picoclaw = import ../packages/picoclaw.nix { inherit pkgs; };
in
{
  nixpkgs.hostPlatform = "aarch64-linux";
  nixpkgs.config.allowUnfree = true;

  nixpkgs.config.permittedInsecurePackages = [ "olm-3.2.16" ];

  imports = [
    # nixpkgs標準のSD image定義 (system.build.sdImage を提供)。
    # config.txt / DTB / ブートローダ設定は nixos-hardware の raspberry-pi-3 が担当する。
    "${modulesPath}/installer/sd-card/sd-image.nix"
    "${modulesPath}/profiles/minimal.nix"
    # OmniRoute (rootless docker + systemd user service)。詳細は raspi/omniroute.nix。
    ./omniroute.nix
  ];

  boot = {
    # nixos-hardware の raspberry-pi-3 が mkDefault で設定する vendor カーネル
    # (linux-rpi, 6.18.50-stable_20260911) をそのまま使う。
    # mainline (linuxPackages_latest) は Pi 3 で HDMI 無出力 / U-Boot での停止
    # (nixpkgs#66960, #97064) を起こす既知の問題があるため、上書きしない。
    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "usbhid"
        "usb_storage"
        "sd_mod"
        "mmc_block"
      ];
      kernelModules = [ ];
    };
    loader.grub.enable = false;
  };

  # nixpkgs 標準の sd-image.nix は populateRootCommands のデフォルトを持たないため、
  # extlinux 構成と NixOS toplevel を rootfs に配置するコマンドを明示する。
  sdImage.populateRootCommands = ''
    mkdir -p ./files/boot
    ${config.boot.loader.generic-extlinux-compatible.populateCmd} -c ${config.system.build.toplevel} -d ./files/boot
  '';

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

  environment.systemPackages =
    with pkgs;
    [
      vim
      networkmanager
      docker-compose
      gh
      opencode
      opensrc
    ]
    ++ [
      picoclaw
    ];

  # docker は rootless のみで動かす (raspi/omniroute.nix)。Pi 3 は 928MiB しか
  # 無いので、root 常駐の dockerd + containerd (~120MiB) を抱えない。
  # systemPackages の docker / docker-compose は rootless デーモン向けの CLI。
  virtualisation.docker.enable = false;

  services.tailscale = {
    enable = true;
    extraUpFlags = [ "--ssh" ];
    authKeyFile = config.sops.secrets.TAILSCALE_AUTH_KEY.path;
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
    extraGroups = [
      "wheel"
      "networkmanager"
      "hermes"
    ];
    # 平文パスワードは設定しない。SSH は公開鍵認証のみ
    # (PasswordAuthentication = false) で、コンソール用パスワードは
    # 初回 SSH ログイン後に `sudo passwd coma` で設定する。
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGHn646g17wEv7rZoSKQCFNGGyLqVJnQ9mlEn7aQuOLj coma@comabook"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHPL4pgOxCwPRIGRDuIt7KeExLZqNdQ3VsbAqgGeaLNV u0_a588@localhost"
    ];
  };

  # hermes-agent を後から有効化したときの所属グループ。
  # users.users.<name>.extraGroups は文字列リストで、groups 側の定義が
  # 無いと静かに捨てられるため、先にグループを用意する。
  users.groups.hermes = { };

  security.sudo.wheelNeedsPassword = false;
  time.timeZone = "Asia/Tokyo";

  console = {
    font = "Lat2-Terminus16";
    keyMap = "jp106";
  };

  i18n.defaultLocale = "ja_JP.UTF-8";

  hardware.enableRedistributableFirmware = true;
  # Pi 3/4 の 64-bit ブートは firmware → U-Boot → extlinux.conf → kernel の順で
  # 起動する。uboot.enable で config.txt に `kernel=u-boot.bin` と
  # `arm_64bit=1` が追加され、u-boot.bin がファームウェアパーティションへ
  # コピーされる (nixpkgs 標準の sd-image-aarch64.nix と同等の構成)。
  hardware.raspberry-pi.firmware.uboot.enable = true;

  # 起動失敗を切り分けられるよう HDMI を強制表示する。
  # nixos-hardware 既定の disable_fw_kms_setup=1 は、ファームウェアが kernel
  # cmdline に video= を注入するのを止めるため、vc4 KMS が立ち上がらないと画面が
  # 真っ黒になり起動状態を確認できない。null を指定して既定行を削除し、video= の
  # 注入を復活させる。
  hardware.raspberry-pi.configtxt.settings = {
    all = {
      disable_fw_kms_setup = lib.mkForce null;
      hdmi_force_hotplug = 1;
    };
    # Pi 3 の mini-UART は core clock 依存で、シリアル診断時にボーレートがずれるため固定する。
    pi3.core_freq = 250;
  };

  services.dbus.implementation = "dbus";

  systemd.services.nscd.startLimitIntervalSec = lib.mkForce 0;

  # Flakesとnix-commandを有効化
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [
      "root"
      "coma"
    ];
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
      "OPENCODE_GO_API_KEY" = { };

      "WIFI_SSID" = { };
      "WIFI_PASSWORD" = { };
      "TAILSCALE_AUTH_KEY" = { };
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
      cp ${
        config.sops.templates."wifi-nmconnection".path
      } /etc/NetworkManager/system-connections/home-wifi.nmconnection
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
    deps = [
      "users"
      "groups"
    ];
  };

  system.stateVersion = "25.05";
}
