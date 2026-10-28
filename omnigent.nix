{
  config,
  lib,
  pkgs,
  ...
}:
# Omnigent (https://omnigent.ai/) を systemd user service で常駐させる。
#
# - 実体: pkgs/omnigent (上流タグ v0.19.1 のソース + workspace SDK + uv.lock に
#   固定した依存を PyPI からビルド。web UI は sdist のビルド済み資産)。
#   flake の overlay で `pkgs.omnigent` として公開している。
# - 待ち受け: 127.0.0.1:14197
#   dsh-web の 14198 と同じ命名則 (先頭の 0 を除いた 14159 帯を避け、
#   アプリ名のアルファベット順位を下 2 桁に埋める)。ここでは `OMNIG` の
#   G=7 を末尾に置いて 14197 にした。一般的な Web 開発ポート
#   (3000 / 4200 / 5173 / 8000 / 8080 …) とは重ならない。
#   なお TCP のポートは 65535 までなので、桁数は 5 桁に収める。
#   上流の `omni server` は既定で 6767 番を使うので、必ず `--port` で明示する。
#   環境変数 PORT も同じ値で渡す。
# - 外部公開: https://omnigent.comamoca.dev (Cloudflare Tunnel
#   `cloudflared-omnigent`, home.nix)。ingress は
#   omnigent.comamoca.dev → http://127.0.0.1:14197。待ち受けは 127.0.0.1
#   のままにする (トンネルが同一ホストの cloudflared から繋ぐだけなので、
#   公開はトンネルの ingress が担う)。
# - 状態: ~/.local/share/omnigent (DB / artifacts / logs) と ~/.omnigent
#   (config.yaml)。`omni` CLI は ~/.omnigent/config.yaml の `server` を見て
#   systemd が起動したサーバーへ接続する。このファイルは Omnigent 自身も
#   書き換える (host_id など) ので、symlink ではなく実体ファイルを activation
#   で用意し、`server` の行だけを宣言側の値に揃える。
# - LLM: OmniRoute (127.0.0.1:20128) を唯一の上流にし、既定モデルを
#   static-thrifty にする。認証情報は sops の OMNIROUTE_API_KEY
#   (/run/user/1000/omniroute.env) を EnvironmentFile で読み、OpenAI 互換
#   クライアントが読む `OPENAI_API_KEY` に `OMNIROUTE_API_KEY` を展開する
#   (`${OMNIROUTE_API_KEY}` 記法は systemd が対応している)。
#
# - harness: Omnigent は 3 系統でハーネスを扱う。
#   1. ネイティブ組み込み (`claude` / `codex` / `opencode` / `pi`)。CLI の
#      ログイン状態をそのまま使い、追加設定は要らない。
#   2. ACP 組み込み行 (`jcode` など)。上流の acp_cli_harnesses.py に固定の
#      arvg が入っている。
#   3. `acp:` ユーザー定義。`~/.omnigent/config.yaml` の `acp.agents` に
#      `{name, command, model?, env_passthrough?}` を並べると
#      `--harness acp:<slug>` で使える。ここで宣言するのは、上流に対応行が
#      *無い* もの (dsh の ACP サーバー, omp, pi-acp) に限る。
#      `acp:` エージェントの spawn 環境は deny-by-default なので、鍵を env から
#      読むものは `env_passthrough` に変数名を書く (値は書かない)。
#
# - 認証 (トンネル越し): Omnigent の既定は header モードで、ループバック待ち受け
#   なら `OMNIGENT_LOCAL_SINGLE_USER=1` を自動で立てる (未認証リクエストが
#   そのまま "local" ユーザーになる)。待ち受けを 127.0.0.1 のままにする以上、
#   この既定のままだと Cloudflare Tunnel 経由のリクエストも owner 権限になる。
#   そこでサーバーには `OMNIGENT_AUTH_PROVIDER=header` を明示し、
#   `OMNIGENT_AUTH_HEADER=Cf-Access-Authenticated-User-Email` を要求させる。
#   ヘッダを注入できるのは手前の Cloudflare Access だけなので、トンネル越しの
#   ユーザー ID は Access の承認済みメールアドレスになる。ヘッダの無い
#   リクエストは 401 で落ち、`local` ユーザーへのフォールバックは働かない。
#   そのためローカルの `omni` CLI はこのサーバーを直接使えない (公開ホストを
#   経由するか、自分のメールを `Cf-Access-Authenticated-User-Email` で送る)。
let
  home = config.home.homeDirectory;

  # ポート番号はここだけに書く。
  port = 14197;

  # トンネル越しの公開ホスト名。cloudflared-omnigent (home.nix) の ingress と
  # Cloudflare Access アプリ "omnigent" がこのホスト名を指す。
  publicHost = "omnigent.comamoca.dev";
  publicUrl = "https://${publicHost}";

  dataDir = "${home}/.local/share/omnigent";
  configHome = "${home}/.omnigent";

  # Cloudflare Access アプリ "omnigent" が許可しているメールアドレス。
  # サーバーは `OMNIGENT_AUTH_HEADER=Cf-Access-Authenticated-User-Email` を
  # 要求するので、Access を通らないローカルの `omni` CLI はこの値を自分で
  # 送る。Cloudflare 側は Access を通ったリクエストのこのヘッダを自分で
  # 付ける/上書きするので、外部から他人の ID を名乗ることはできない。
  # ここを変えるときは Access のポリシーも同じ値に揃える。
  localUserId = "comamoca.dev@gmail.com";

  omnirouteEnv = config.sops.secrets."omniroute".path;
  omnirouteBase = "http://127.0.0.1:20128/v1";
  defaultModel = "static-thrifty";

  # 上流に組み込み行が無いハーネスを ACP エージェントとして登録する。
  # name から slug が決まる (小文字化し英数字以外を `-` に潰す) ので、
  # `--harness acp:deepseek-harness` のように参照する。
  acpAgents = [
    {
      # dsh の ACP サーバー。`~/.dsh/profiles/acp` の patch 層で OmniRoute を
      # 指してあるので、鍵は OMNIROUTE_API_KEY だけ渡せば足りる。
      # dsh は DSH_PERMISSION_MODE でしかサンドボックス/承認を変えられない。
      # dsh は nix profile 経由 (pkgs.dsh は無い) なので、ストアパスではなく
      # PATH 解決のベア名で書く。omnigent.service / 端末の双方で見つかる。
      name = "DeepSeek Harness";
      command = "dsh --profile acp";
      env_passthrough = [
        "OMNIROUTE_API_KEY"
        "DSH_PERMISSION_MODE"
      ];
    }
    {
      # oh-my-pi (pi のフォーク)。`pi` と同じモデル/認証設定を ~/.pi ではなく
      # ~/.omp に持つが、ACP サーバーは自分で立ち上がる。システムプロンプトは
      # 完全に自前で持ち、Omnigent 側の注入と衝突するので切る。
      name = "oh-my-pi";
      command = "${home}/.bin/omp acp";
      inject_system_prompt = false;
      env_passthrough = [ "OMNIROUTE_API_KEY" ];
    }
    {
      # pi 本体は ACP 非対応なので、コミュニティ製アダプタ pi-acp 経由で繋ぐ。
      # pi-acp は `pi` を子プロセスとして起動し、~/.pi の設定をそのまま使う。
      # 鍵は ~/.pi/agent/models.json の apiKey コマンドが omniroute.env から
      # 読むので、ここでは渡さない。
      name = "Pi";
      command = "${home}/.bun/bin/pi-acp";
    }
    {
      # jcode は上流に組み込み ACP 行 (acp_cli_harnesses.py) があるが、この
      # ビルドの runner では `acp:jcode` が「not configured」で解決できなかった。
      # `acp.agents` に明示登録して同じ口から入れる。
      # 鍵は ~/.jcode/config.toml の `env_file = "omniroute.env"` を jcode 自身が
      # 読むので、ここでは渡さない。
      name = "jcode";
      command = "${home}/.local/bin/jcode acp";
    }
  ];
in
{
  home.packages = [ pkgs.omnigent ];

  # DB / artifacts / logs の置き場。中身は実行時に作られる。
  home.file."${dataDir}/.keep".text = "";

  # `~/.omnigent/config.yaml` は Nix ストアへの symlink にしない。Omnigent は
  # このファイルを自分で書き換える (host の `host_id` / `name` を追記する) ので、
  # 読み取り専用のストアに張ると
  # `OSError: [Errno 30] Read-only file system` で host デーモンが落ちる。
  # 代わりに activation で実体のファイルを作る。中身は
  #   - `server`: 常駐サーバーの URL (宣言側が正本。食い違えば書き直す)
  #   - `providers.omniroute`: OmniRoute を OpenAI 互換プロバイダとして登録
  #   - `acp.agents`: 上流に組み込み行が無いハーネス (dsh / omp / pi)
  #   実際の書き込みは pkgs.omnigent の `omni-config` (PyYAML を使える Python で
  #   動く小さな CLI) に任せ、`omni config set` が追記したキーは残す。
  # `acp.agents` は丸ごと上書きする (ユーザー定義の正本がこの nix なので、
  # `omni config acp` での追記は次の switch で失われる点に注意)。
  home.activation.omnigentConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    runtimeDir="${configHome}"
    config="$runtimeDir/config.yaml"

    $DRY_RUN_CMD mkdir -p "$runtimeDir"
    # 以前の世代が張ったストアへの symlink を剥がす。
    if [ -L "$config" ]; then
      $DRY_RUN_CMD rm -f "$config"
    fi

    $DRY_RUN_CMD ${pkgs.omnigent}/bin/omni-config \
      "$config" "${toString port}" "${omnirouteBase}" "${defaultModel}" \
      ${lib.escapeShellArg (builtins.toJSON acpAgents)}
  '';

  # プロバイダの API キーは設定ファイルに書かず、Omnigent 自身の
  # シークレットストアから読む (`providers.omniroute.openai.api_key_ref` が
  # `keychain:omniroute`)。ストアは OS keyring ではなく **ファイル**
  # (`~/.omnigent/secrets.json`, 0600) を使う。keyring のバックエンドが無い
  # 環境で `NoKeyringError` になり、ランナー (ホストデーモンが起動する子
  # プロセス) からも同じストアを読む必要があるためである。
  #
  # 鍵の正本は sops が復号する /run/user/1000/omniroute.env。activation で
  # それをストアへ流し込む。sops の復号は activation より後に走ることがある
  # ので、ファイルが無いときは何もしない (次の switch で入る)。
  home.activation.omnigentSecret = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    envFile="${omnirouteEnv}"

    if [[ -n "''${DRY_RUN_CMD:-}" ]]; then
      exit 0
    fi

    if [[ -f "$envFile" ]]; then
      key=$(sed -n 's/^OMNIROUTE_API_KEY=//p' "$envFile" | head -n 1)
      if [[ -n "$key" ]]; then
        OMNIGENT_DISABLE_KEYRING=1 OMNIGENT_CONFIG_HOME="${configHome}" \
          ${pkgs.omnigent}/bin/omni-secret omniroute "$key" || \
          echo "omnigentSecret: シークレットの登録に失敗しました" >&2
      fi
    fi
  '';

  # harness (claude / codex / pi) に渡す既定のモデル名と上流。
  # OmniRoute の combo 名をそのまま使う。`omni run` は端末セッションから
  # 起動され、systemd のサービス環境は継承しないので、対話用は
  # `home.sessionVariables` 側で配る (`systemd.user.sessionVariables` は
  # シェルへは伝播しない)。
  home.sessionVariables = {
    OMNIGENT_MODEL = defaultModel;
    OPENAI_BASE_URL = omnirouteBase;
    # `keychain:` 参照をファイルバックエンドで解決する (上のコメント参照)。
    # 端末から起動したランナーもこの設定で同じストアを読む。
    OMNIGENT_DISABLE_KEYRING = "1";
    # サーバーのヘッダ認証を CLI 側から満たす。Omnigent は
    # `OMNIGENT_DATABRICKS_EXTRA_HEADERS` (JSON オブジェクト) の中身を
    # リクエストヘッダに折り込む (`omnigent/cli_auth.py`)。PKG 側の
    # `chat-server-headers.patch` がこの値を `OmnigentClient` にも通す。
    OMNIGENT_DATABRICKS_EXTRA_HEADERS = builtins.toJSON {
      "Cf-Access-Authenticated-User-Email" = localUserId;
    };
  };

  systemd.user.services.omnigent = {
    Unit = {
      Description = "Omnigent meta-harness server (127.0.0.1:${toString port})";
      After = [
        "network-online.target"
        "sops-nix.service"
        "omniroute.service"
      ];
      Wants = [
        "network-online.target"
        "omniroute.service"
      ];
      # switch で稼働中のサーバーを落とさない。
      X-SwitchMethod = "keep-old";
    };
    Service = {
      Type = "simple";
      ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p ${dataDir} ${configHome}";
      ExecStart = "${pkgs.omnigent}/bin/omni server --host 127.0.0.1 --port ${toString port}";
      WorkingDirectory = home;
      EnvironmentFile = [ omnirouteEnv ];
      Environment = [
        "PORT=${toString port}"
        "OMNIGENT_DATA_DIR=${dataDir}"
        "OMNIGENT_CONFIG_HOME=${configHome}"
        "OMNIGENT_MODEL=${defaultModel}"
        "OPENAI_BASE_URL=${omnirouteBase}"
        "OPENAI_API_KEY=\${OMNIROUTE_API_KEY}"
        "OMNIGENT_DISABLE_KEYRING=1"
        # ヘッダ認証モードを明示する。上書きしないと、ループバック待ち受けの
        # 既定で `OMNIGENT_LOCAL_SINGLE_USER=1` が立ち、未認証リクエストが
        # ローカルユーザーになる (`omni server` は provider が明示されている
        # ときだけマーカーを立てない)。
        "OMNIGENT_AUTH_PROVIDER=header"
        "OMNIGENT_AUTH_HEADER=Cf-Access-Authenticated-User-Email"
        # トンネル越しの公開ホストを WebSocket の Origin 許可リストに足す。
        # ヘッダ認証は非ローカルモードなので Origin は素通しが既定だが、
        # 将来 allowlist を有効にしても公開ホストから繋がるようにしておく。
        "OMNIGENT_WS_ALLOWED_ORIGINS=${publicUrl}"
        "PATH=${config.home.profileDirectory}/bin:/run/current-system/sw/bin:/usr/bin:/bin:/run/wrappers/bin"
      ];
      Restart = "on-failure";
      RestartSec = 5;
      # harness が tmux / 子プロセスを多く作るので上限を緩める。
      LimitNOFILE = 65536;
    };
    Install.WantedBy = [ "default.target" ];
  };
}
