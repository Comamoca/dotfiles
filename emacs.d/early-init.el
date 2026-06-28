;; -*- lexical-binding: t -*-

;; tree-sitter 非対応の Emacs ビルド向けに treesit-ready-p を事前定義
;; astro-ts-mode の autoload が (treesit-ready-p 'astro) を呼ぶ
(unless (fboundp 'treesit-ready-p)
  (defalias 'treesit-ready-p (lambda (&rest _) nil)))

;; 起動前にGUI要素を無効化
(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars) default-frame-alist)

;; フレーム背景色を明示指定（テーマ読み込み前にフレームが表示された時の白背景/透明を防ぐ）
;; catppuccin-mocha の背景色 #1e1e2e
;; NOTE: alpha-background は default-frame-alist に入れず、
;;       init.el の after-make-frame-functions で遅延適用する。
;;       PGTK では alpha-background が背景色描画より先に効いてしまい、
;;       透過だけ効いた空っぽの窓が数秒表示されるため。
;; NOTE: visibility . nil でフレームを不可視にしてから表示する。
;;       Emacs 30.2 の PGTK では背景色が正しく適用される前にフレームが表示される
;;       既知の問題がある（bug#80584 は Emacs 31+ で修正済み）。
(push '(background-color . "#1e1e2e") default-frame-alist)
(push '(foreground-color . "#cdd6f4") default-frame-alist)
(push '(visibility . nil) default-frame-alist)

;; 起動時のGC閾値を高めに設定
(setq gc-cons-threshold (* 128 1024 1024))
(setq gc-cons-percentage 0.2)

;; 起動中の不要な再描画を抑制
;; NOTE: emacs-startup-hook はデーモン起動時に既に発火済みのため、
;; デーモンで early-init.el を後読みする場合は直接 nil に設定する
(when (or (daemonp) (not after-init-time))
  (setq-default inhibit-redisplay t)
  (setq-default inhibit-message t))
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq-default inhibit-redisplay nil)
            (setq-default inhibit-message nil)))
;; デーモンでは上記フックが発火しないため、念のためすぐに解除
(when (daemonp)
  (setq-default inhibit-redisplay nil)
  (setq-default inhibit-message nil))

;; ファイル名ハンドラを起動時に一時無効化（起動速度向上）
;; デーモンでは early-init.el が起動完了後に読み込まれるため、
;; file-name-handler-alist を nil にすると復元できず .gpg 復号が壊れる
(unless (daemonp)
  (defvar startup/file-name-handler-alist file-name-handler-alist)
  (setq file-name-handler-alist nil)
  (add-hook 'emacs-startup-hook
            (lambda ()
              (setq file-name-handler-alist startup/file-name-handler-alist))))

;; ネイティブコンパイル最適化設定
(with-eval-after-load 'comp
  (setq native-comp-async-jobs-number 4)
  (setq native-comp-speed 3))

;; init.el / early-init.el をネイティブコンパイル（起動後に非同期で実行）
;; 初回起動時は .eln がないので効果なし、2回目以降で高速化
(add-hook 'emacs-startup-hook
          (lambda ()
            (when (and (fboundp 'native-compile-async)
                       (locate-library "comp"))
              (native-compile-async (expand-file-name "init.el" user-emacs-directory))
              (native-compile-async (expand-file-name "early-init.el" user-emacs-directory)))
            ;; el-get や elpa のパッケージもまとめて native-compile（遅延実行）
            (let ((el-get-dir (expand-file-name "el-get" user-emacs-directory))
                  (elpa-dir (expand-file-name "elpa" user-emacs-directory)))
              (when (file-directory-p el-get-dir)
                (native-compile-async el-get-dir t t))
              (when (file-directory-p elpa-dir)
                (native-compile-async elpa-dir t t)))))
