# Orange Pi 5 (RK3588S) 用の SD カードイメージ (GPT + raw U-Boot)。
#
# nixpkgs の sd-image.nix は MBR 固定で、u-boot を「最初のパーティションより
# 前」に書く前提になっている。RK3588 の BootROM は LBA 64 から idbloader を、
# LBA 16384 (8MiB) から u-boot.itb を読むため、MBR の 1MiB 境界では u-boot.itb
# が収まらない。そこで sd-image.nix は使わず、GPT で先頭 16MiB を予約した
# イメージを自前で組む。
#
# 構成は sd-image.nix と同じ「単一の ext4 ルート + その中の /boot/extlinux」。
# Orange Pi 5 にはファームウェア用の FAT パーティションが要らないので、
# sd-image.nix が作る FAT パーティションは作らない。
#
# 参照:
#   U-Boot の Rockchip 向け書き込み位置 (doc/board/rockchip/rockchip.rst)
#   sd-image.nix の populateRootCommands / expand-root-partition
{ config, lib, pkgs, ... }:

let
  cfg = config.orangepi5.image;

  rootfs = pkgs.callPackage "${toString pkgs.path}/nixos/lib/make-ext4-fs.nix" {
    inherit (cfg) storePaths;
    volumeLabel = cfg.rootVolumeLabel;
    uuid = cfg.rootPartitionUUID;
    populateImageCommands = cfg.populateRootCommands;
    compressImage = false;
  };

  image = pkgs.runCommand "${cfg.baseName}.img" {
    nativeBuildInputs = [
      pkgs.buildPackages.coreutils
      pkgs.buildPackages.util-linux
      pkgs.buildPackages.e2fsprogs
      pkgs.buildPackages.gnugrep
      pkgs.buildPackages.diffutils
      pkgs.buildPackages.gawk
      pkgs.buildPackages.zstd
    ];
    meta.description = "Bootable GPT SD card image for the Orange Pi 5 (RK3588S)";
  } ''
    mkdir -p $out/sd-image $out/nix-support
    cp ${rootfs} ./root-fs.img
    chmod u+w ./root-fs.img

    ${pkgs.buildPackages.bash}/bin/bash ${../bin/scripts/orangepi5-sd-image} \
      --rootfs ./root-fs.img \
      --uboot ${cfg.ubootPackage} \
      --out ./${cfg.baseName}.img \
      --label ${cfg.rootVolumeLabel} \
      ${lib.optionalString (cfg.rootPartitionUUID != null)
        "--uuid ${cfg.rootPartitionUUID}"} \
      --reserved-mib ${toString cfg.reservedMiB} \
      --slack-mib ${toString cfg.slackMiB}

    mv ./${cfg.baseName}.img $out/sd-image/${cfg.fileName}
    zstd -T$NIX_BUILD_CORES --rm $out/sd-image/${cfg.fileName}
    echo "file sd-image $out/sd-image/${cfg.fileName}.zst" >> $out/nix-support/hydra-build-products
  '';

in
{
  options.orangepi5.image = {
    enable = lib.mkEnableOption "the Orange Pi 5 SD card image builder";

    ubootPackage = lib.mkOption {
      type = lib.types.package;
      default = pkgs.ubootOrangePi5;
      defaultText = lib.literalExpression "pkgs.ubootOrangePi5";
      description = ''
        u-boot パッケージ。`idbloader.img` と `u-boot.itb` を含むこと。
      '';
    };

    baseName = lib.mkOption {
      type = lib.types.str;
      default = "orangepi5";
      description = "イメージのファイル名 (拡張子を除いた部分)。";
    };

    fileName = lib.mkOption {
      type = lib.types.str;
      default = "nixos-image-orangepi5.img";
      description = "出力するイメージのファイル名。`.zst` が付く。";
    };

    rootVolumeLabel = lib.mkOption {
      type = lib.types.str;
      default = "NIXOS_SD";
      description = "ルートパーティションのボリュームラベル。`/dev/disk/by-label` と一致させる。";
    };

    rootPartitionUUID = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "ルートファイルシステムの UUID。null なら自動生成。";
    };

    storePaths = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ config.system.build.toplevel ];
      description = "イメージの Nix store に含める derivation。";
    };

    populateRootCommands = lib.mkOption {
      type = lib.types.lines;
      default = ''
        mkdir -p ./files/boot
        ${config.boot.loader.generic-extlinux-compatible.populateCmd} -c ${config.system.build.toplevel} -d ./files/boot
      '';
      defaultText = lib.literalExpression ''
        mkdir -p ./files/boot
        config.boot.loader.generic-extlinux-compatible.populateCmd -c config.system.build.toplevel -d ./files/boot
      '';
      description = ''
        ルートパーティションの中身 (./files) を作るコマンド。/boot/extlinux を
        ここで用意する。
      '';
    };

    reservedMiB = lib.mkOption {
      type = lib.types.ints.positive;
      default = 16;
      description = ''
        先頭で GPT と U-Boot のために予約するサイズ (MiB)。u-boot.itb は
        LBA 16384 から始まるので、8MiB より大きくする必要がある。
      '';
    };

    slackMiB = lib.mkOption {
      type = lib.types.ints.positive;
      default = 512;
      description = ''
        ルートパーティションの後ろに空けておくサイズ (MiB)。初回起動時に
        `expand-root-partition` がここから広げる。
      '';
    };

    expandOnBoot = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        初回起動時にルートパーティションを SD カード全体まで広げるか。
        nixPathRegistrationFile がある初回だけ動く (sd-image.nix と同じ)。
      '';
    };

    nixPathRegistrationFile = lib.mkOption {
      type = lib.types.str;
      default = "/nix-path-registration";
      description = "nix-store --load-db に渡すファイルの位置。";
    };
  };

  config = lib.mkIf cfg.enable {
    system.build.image = image;
    system.build.sdImage = image;

    # 注意: nixpkgs の sd-image.nix が宣言する image.baseName / fileName /
    # filePath / extension はここでは宣言していない (このモジュールは
    # sd-image.nix を import しない)。代入すると
    # `The option image.baseName does not exist` で評価が落ちる。
    # 出力先は上の image derivation が直接決める。

    system.nixos.tags = [ "orangepi5" ];

    boot.loader.generic-extlinux-compatible.enable = lib.mkDefault true;

    systemd.services.expand-root-partition = lib.mkIf cfg.expandOnBoot {
      description = "Grow the root partition and filesystem to fill the SD card";
      unitConfig = {
        DefaultDependencies = false;
        ConditionPathExists = cfg.nixPathRegistrationFile;
      };
      wantedBy = [ "sysinit.target" ];
      before = [
        "sysinit.target"
        "shutdown.target"
        "register-nix-paths.service"
      ];
      after = [ "local-fs.target" ];
      conflicts = [ "shutdown.target" ];
      restartIfChanged = false;
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      # sfdisk -N は GPT でも末尾の空き領域まで伸ばす。パーティション番号は
      # 1 固定 (このイメージはルート 1 本しか作らない)。
      script = ''
        rootPart=$(${lib.getExe' pkgs.util-linux "findmnt"} -n -o SOURCE /)
        bootDevice=$(${lib.getExe' pkgs.util-linux "lsblk"} -npo PKNAME "$rootPart")
        # partition number は lsblk の PARTN から取る。以前は `MAJ:MIN` の
        # minor 部を使っていたが、これは「minor == パーティション番号」という
        # 偶然に依存していて (mmcblk0p1 で 1:1 になるだけ)、パーティションが
        # 増えるとずれる。
        partNum=$(${lib.getExe' pkgs.util-linux "lsblk"} -npo PARTN "$rootPart")

        echo ",+," | ${lib.getExe' pkgs.util-linux "sfdisk"} -N"$partNum" --no-reread "$bootDevice"
        ${lib.getExe' pkgs.parted "partprobe"}
        ${lib.getExe' pkgs.e2fsprogs "resize2fs"} "$rootPart"
      '';
    };

    # 初回起動で Nix store を DB に登録する (sd-image.nix と同じ)。これが無いと
    # イメージ内の store path が「存在するが登録されていない」状態になる。
    systemd.services.register-nix-paths = {
      description = "Register Nix Store Paths";
      unitConfig = {
        DefaultDependencies = false;
        ConditionPathExists = cfg.nixPathRegistrationFile;
      };
      wantedBy = [ "sysinit.target" ];
      before = [
        "sysinit.target"
        "shutdown.target"
        "nix-daemon.socket"
        "nix-daemon.service"
      ];
      after = [ "local-fs.target" ];
      conflicts = [ "shutdown.target" ];
      restartIfChanged = false;
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        ${lib.getExe' config.nix.package.out "nix-store"} --load-db < ${cfg.nixPathRegistrationFile}

        # nixos-rebuild also requires a "system" profile and an /etc/NIXOS tag.
        touch /etc/NIXOS
        ${lib.getExe' config.nix.package.out "nix-env"} -p /nix/var/nix/profiles/system --set /run/current-system

        # Prevents this from running on later boots.
        rm -f ${cfg.nixPathRegistrationFile}
      '';
    };

    assertions = [
      {
        # `config.sdImage.enable` は sd-image.nix を import した時にしか存在
        # しない。ここでは import しないのが前提なので、参照すると
        # `attribute 'sdImage' missing` で評価が落ちる。オプションの有無で見る。
        assertion = !(config ? sdImage);
        message = ''
          orangepi5.image と nixpkgs の sdImage は排他。ファームウェア用 FAT
          パーティションを作らない構成なので、sd-image.nix を import しないこと。
        '';
      }
    ];
  };
}
