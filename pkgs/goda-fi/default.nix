{ pkgs }:
let
  # coma の goda-fi.vim 設定 (Go モジュール)。本体は config/nvim/goda-fi。
  # ここでは go.mod / go.sum / main.go だけを持つ最小のソースツリーを作る。
  src = pkgs.lib.cleanSourceWith {
    src = ../../config/nvim/goda-fi;
    filter =
      path: type:
      let
        base = baseNameOf path;
      in
      type == "directory" || builtins.elem base [ "go.mod" "go.sum" "main.go" ];
  };
in
pkgs.buildGoModule {
  pname = "goda-fi-config";
  version = "0.1.0";

  inherit src;

  # go.sum のハッシュではなく vendor した依存のハッシュ。
  vendorHash = "sha256-ULLh87oUCUFgXKRtMxPEemEoeR7qaqNDrZltVDCBtR0=";

  # go.mod の go ディレクティブ (1.26.10) は nixpkgs の go でそのまま読める。
  # goda-fi.vim は $out/bin の実行ファイルを直接起動するので名前を固定する。
  subPackages = [ "." ];
  postInstall = ''
    mv $out/bin/goda-fi-config $out/bin/goda-fi
  '';

  meta = with pkgs.lib; {
    description = "coma's goda-fi.vim configuration binary";
    homepage = "https://github.com/Shougo/goda-fi.vim";
    license = licenses.mit;
    mainProgram = "goda-fi";
  };
}
