{
  config,
  pkgs,
  ...
}:
# Orca (https://onorca.dev/, stablyai/orca) を home-manager ベースで導入する。
#
# - 実体: inputs.llm-agents (github:numtide/llm-agents.nix) の
#   shared-nixpkgs overlay が公開する pkgs.llm-agents.orca。Electron 製の
#   ADE (agentic development environment) で、GUI の `orca-ide` と CLI の
#   `orca` が $out/bin に入る。バージョンは flake.lock の llm-agents で
#   pin される (現在 1.4.248)。
# - サーバー: 上流 `orca serve service install` が書き出す systemd user
#   unit (stablyai/orca の src/cli/runtime/serve-service-unit.ts) と同じ
#   内容を home-manager から宣言的に出す。`orca serve` はデスクトップ
#   ウィンドウを開かない headless ランタイムサーバーで、`--supervise`
#   付きなら再起動の待ち時間を自分で伸ばしながら管理し、他の Orca
#   (デスクトップアプリ) が同じプロファイルを serve 中は exit 3 ではなく
#   待機し続ける。15 分に 6 回失敗すると exit 0 で諦めて manager も止まる
#   (StartLimit* はその上流側ブレーキに揃えた保険)。
# - ポート: 指定しない。既定で 6768 を使い、取られていれば空きポートへ
#   移る (上流 service install の既定と同じ)。
# - ペアリング: サービスのログにペアリングリンクを出さないため
#   `--no-pairing`。クライアントのペアはデスクトップアプリから行うか、
#   サービスを止めて端末から `orca serve` を実行する (上流の運用指針)。
# - KillMode=process: systemd は supervisor だけを殺す。server は
#   supervisor が停止し、terminal daemon (別の user scope) は生存する
#   (上流の unit 生成コードのコメント通り)。home-manager switch で
#   unit が書き換わっても agent の terminal は落ちない。
# - ORCA_USER_DATA_PATH: user manager の環境で既定プロファイル
#   (~/.config/orca) 以外が解決されるのを防ぐため、上流と同じく明示する。
# - ログ: serve は状態行 (server ready / endpoint 等) を stdout に出す
#   ので、journalctl --user -u orca-serve から読める。詳細ログは
#   ~/.config/orca/logs/ に書かれる。ペアリングリンクだけは
#   --no-pairing により log に出ない (上流の設計)。
# - 名前: orca-serve.service。`orca.service` にすると /etc/systemd/user/
#   orca.service (GNOME のスクリーンリーダー Orca。nixpkgs の別物で
#   名前が衝突している) を ~/.config 側から黙って上書きしてしまうため、
#   上流と同じ orca-serve の名前を使う。
# - 起動: WantedBy=default.target (ログイン時に自動起動)。マシン起動直後
#   (ログイン前) からも稼働させたい場合は linger が必要
#   (`loginctl enable-linger coma`、NixOS 側なら users.users.coma.linger
#   = true。raspi/omniroute.nix が同手法)。comabook は他の常駐サービス
#   (omniroute / omnigent / dsh-web / forgejo ...) も default.target 運用
#   なので揃えてある。linger を入れると他の全 user unit の起動タイミングも
#   変わるため、このモジュールでは入れない。
# - 自己インストールされる CLI shim (~/.config/orca/linux-orca-cli-shim/)
#   は orca がバージョン固定のストアパスへ exec する。Orca のターミナル
#   から起動したプロセスツリーでは PATH の先頭に来て、nix 側の `orca` を
#   遮ることがある。宣言側の orca が正本なので、shim の更新は nix 側
#   orca-ide の起動時に任せる (Orca Settings からの再インストールでも可)。
let
  orca = pkgs.llm-agents.orca;

  # 上流の service install が unit に埋める PATH 相当。systemd user
  # service の素の PATH は貧弱なので、home profile とシステムのパスを
  # 明示する。`orca` の wrapper が git / xclip / xdotool / xdg-utils /
  # xvfb などをこの後ろに足す。
  servicePath = "${config.home.profileDirectory}/bin:/run/current-system/sw/bin:/usr/bin:/bin:/run/wrappers/bin";
in
{
  home.packages = [ orca ];

  systemd.user.services.orca-serve = {
    Unit = {
      Description = "Orca server (orca serve --supervise)";
      StartLimitIntervalSec = 900;
      StartLimitBurst = 5;
    };
    Service = {
      Type = "simple";
      ExecStart = "${orca}/bin/orca serve --supervise --no-pairing";
      Environment = [
        "ORCA_USER_DATA_PATH=${config.home.homeDirectory}/.config/orca"
        "PATH=${servicePath}"
      ];
      Restart = "on-failure";
      RestartSec = 10;
      TimeoutStopSec = 90;
      # supervisor だけを殺す (server は supervisor が止め、terminal daemon
      # は user scope 側で生き残る)。上流の renderSystemdUnit と同じ値。
      KillMode = "process";
    };
    Install.WantedBy = [ "default.target" ];
  };
}
