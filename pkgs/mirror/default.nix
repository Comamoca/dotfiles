{ pkgs }:
let
  wl-mirror = import ../wl-mirror { inherit pkgs; };

  # スクリプト本体は bin/scripts/mirror を唯一の原本として読み込む。
  # writeShellApplication が独自の shebang を付けるため、原本の shebang は落とす。
  script = builtins.replaceStrings [ "#!/usr/bin/env bash\n" ] [ "" ] (
    builtins.readFile ../../bin/scripts/mirror
  );
in
pkgs.writeShellApplication {
  name = "mirror";

  # systemctl / systemd-run は意図的に runtimeInputs へ入れていない。
  # user bus を触るクライアントは起動中の systemd と同じものを使うべきなので、
  # PATH 上の system 版 (/run/current-system/sw/bin) に任せる。
  runtimeInputs = [
    wl-mirror
    pkgs.wlr-randr
    pkgs.jq
    pkgs.fzf
    pkgs.rofi
    pkgs.libnotify
  ];

  text = script;

  meta = with pkgs.lib; {
    description = "wl-mirror で任意の出力へ画面をミラーリングする TUI";
    platforms = platforms.linux;
    mainProgram = "mirror";
  };
}
