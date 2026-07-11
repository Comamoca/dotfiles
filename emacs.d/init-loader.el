;; -*- lexical-binding: t -*-
;; Emacs 32.0.50 PGTK ワークアラウンド: load の代わりに read + eval で init.el を読み込む
;;
;; 問題: Emacs 32.0.50 (pgtk) で (load "...") を使うと
;;       (end-of-file #<killed buffer>) でクラッシュする。
;;       *load* バッファを読み込み中に何かが kill している模様。
;;
;; 対策: 全フォームを先に read してから eval する。
;;       Nix の home.nix で daemon script からこのファイルを load する。
(let* ((el-file (concat (file-name-as-directory (or (getenv "HOME") "~"))
                       ".emacs.d/init.el"))
       (buf (find-file-noselect el-file))
       (forms nil))
  (with-current-buffer buf
    (goto-char (point-min))
    (condition-case nil
        (while t
          (push (read (current-buffer)) forms))
      (end-of-file nil)))
  (kill-buffer buf)
  (setq forms (nreverse forms))
  (message "[init-loader] Loading %d forms from %s" (length forms) el-file)
  (dolist (form forms)
    (eval form t))
  (message "[init-loader] init.el loaded successfully"))
