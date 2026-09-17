# 外部パッケージ集合 (nur-packages) を名前空間付きの属性として提供するオーバーレイ。
# カスタム Emacs の解決はタスク 7.1 で対応する。
inputs: final: prev: {
  nur = inputs.nur-packages.legacyPackages.${final.stdenv.hostPlatform.system};
}
