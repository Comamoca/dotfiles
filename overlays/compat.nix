# 互換性回避策のオーバーレイ。いずれも上流修正後に撤去する。
# 撤去条件は各定義のコメントを参照。
inputs: final: prev: {
  # Shadow deprecated stdenv.is{Linux,Aarch64,Darwin} with the recommended
  # hostPlatform equivalents. Several external overlays still use the old
  # names and would otherwise emit evaluation warnings.
  stdenv = prev.stdenv // {
    isLinux = prev.stdenv.hostPlatform.isLinux;
    isAarch64 = prev.stdenv.hostPlatform.isAarch64;
    isDarwin = prev.stdenv.hostPlatform.isDarwin;
  };

  # WORKAROUND(sodiboo/niri-flake#1851): nixpkgs removed libdisplay-info_0_2
  # (2026-08-04, now a throwing alias) while niri-flake's make-niri asserts
  # version == "0.2.0". Shadow the alias with a real 0.2.0 build via the
  # generic expression still shipped in nixpkgs.
  # Remove once https://github.com/sodiboo/niri-flake/pull/1853 lands.
  libdisplay-info_0_2 = final.callPackage (import
    "${inputs.nixpkgs}/pkgs/by-name/li/libdisplay-info/generic.nix"
    {
      version = "0.2.0";
      hash = "sha256-6xmWBrPHghjok43eIDGeshpUEQTuwWLXNHg7CnBUt3Q=";
    }
  ) { };

  # openldap のフラッキーなテストをスキップ (bottles の依存)
  openldap = prev.openldap.overrideAttrs (_: {
    doCheck = false;
  });
}
