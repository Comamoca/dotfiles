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
  SSID = "WIFI_SSID_PLACEHOLDER";
  SSIDpassword = "WIFI_PASSWORD_PLACEHOLDER";
  interface = "wlan0";
  hostname = "raspi";

  opensrc = import ../packages/opensrc.nix { inherit pkgs; };
in
{
  nixpkgs.hostPlatform = "aarch64-linux";
  nixpkgs.config.allowUnfree = true;

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
      libqmi = prev.libqmi.overrideAttrs (old: {
        mesonFlags = (old.mesonFlags or [ ]) ++ [ "-Dgtk_doc=false" ];
      });
    })
  ];

  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_rpi3;
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
    claude-code
    opensrc
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
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.trusted-users = [ "root" "coma" ];

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
    };
    templates."hermes-env" = {
      content = ''
        OPENROUTER_API_KEY=${config.sops.placeholder."OPENROUTER_API_KEY"}
        TELEGRAM_BOT_TOKEN=${config.sops.placeholder."TELEGRAM_BOT_TOKEN"}
        TELEGRAM_ALLOWED_USERS=${config.sops.placeholder."TELEGRAM_ALLOWED_USERS"}

        R2_ACCESS_KEY_ID=${config.sops.placeholder."R2_ACCESS_KEY_ID"}
        R2_SECRET_ACCESS_KEY=${config.sops.placeholder."R2_SECRET_ACCESS_KEY"}
        R2_ENDPOINT=${config.sops.placeholder."R2_ENDPOINT"}
      '';
    };
  };

  services.hermes-agent = {
    enable = true;
    extraDependencyGroups = [ "messaging" ];
    settings = {
      model = {
        default = "google/gemini-3-flash-preview";
        base_url = "https://openrouter.ai/api/v1";
      };
      toolsets = [ "all" ];
      telegram = {
        require_mention = false;
        reactions = true;
      };
    };
    environmentFiles = [ config.sops.templates."hermes-env".path ];
    addToSystemPackages = true;
    documents = {
      "USER.md"                    = "${inputs.openclaw-workspace}/USER.md";
      "AGENTS.md"                  = "${inputs.openclaw-workspace}/AGENTS.md";
      "IDENTITY.md"                = "${inputs.openclaw-workspace}/IDENTITY.md";
      "TOOLS.md"                   = "${inputs.openclaw-workspace}/TOOLS.md";
      "skill-gleam-search.md"      = "${inputs.openclaw-workspace}/skills/gleam-package-search/SKILL.md";
      "skill-location.md"          = "${inputs.openclaw-workspace}/skills/location/SKILL.md";
      "skill-sfeed.md"             = "${inputs.openclaw-workspace}/skills/sfeed/SKILL.md";
      "skill-todo.md"              = "${inputs.openclaw-workspace}/skills/todo/SKILL.md";
      "skill-url-summarizer.md"    = "${inputs.openclaw-workspace}/skills/url-summarizer/SKILL.md";
    };
  };

  system.activationScripts.hermes-soul = {
    text = ''
      mkdir -p /var/lib/hermes/.hermes
      cp ${inputs.openclaw-workspace}/SOUL.md /var/lib/hermes/.hermes/SOUL.md
      chown hermes:hermes /var/lib/hermes/.hermes/SOUL.md
      chmod 640 /var/lib/hermes/.hermes/SOUL.md
    '';
    deps = [ "users" "groups" ];
  };

  system.stateVersion = "25.05";
}
