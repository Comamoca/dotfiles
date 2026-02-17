;; -*- lexical-binding: t -*-

;; 起動前にGUI要素を無効化（with-eval-after-loadではなく直接無効化）
;; これにより初期描画コストを大幅に削減
(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars) default-frame-alist)

;; 起動時のGC閾値を最大化（後でinit.elで通常値に戻す）
(setq gc-cons-threshold most-positive-fixnum)
(setq gc-cons-percentage 0.6)

;; 起動中の不要な再描画を抑制
(setq-default inhibit-redisplay t)
(setq-default inhibit-message t)
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq-default inhibit-redisplay nil)
            (setq-default inhibit-message nil)))

;; ファイル名ハンドラを起動時に一時無効化（起動速度向上）
(defvar startup/file-name-handler-alist file-name-handler-alist)
(setq file-name-handler-alist nil)
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq file-name-handler-alist startup/file-name-handler-alist)))
