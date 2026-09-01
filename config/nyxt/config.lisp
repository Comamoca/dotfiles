;;;; Nyxt 設定ファイル (~/.config/nyxt/config.lisp)
;;;; dotfiles: config/nyxt/config.lisp

(in-package #:nyxt-user)

;;; ---------------------------------------------------------------------------
;;; Emacs 連携: 起動時に Slynk サーバ (SLY 用) を立てる
;;;
;;; Emacs 側: M-x sly-connect RET localhost RET 4006 RET
;;; SLIME を使う場合は start-slynk / *slynk-port* を
;;; start-swank / *swank-port* に置き換える (どちらもデフォルト 4006)。
;;;
;;; 注意: これは Nyxt を実行中のユーザ権限で任意コードを実行できる口を
;;; localhost に開く。ポートを外部公開しないこと。
;;; ---------------------------------------------------------------------------

(defun start-slynk-on-startup (browser)
  (declare (ignore browser))
  (nyxt:start-slynk))

(define-configuration browser
  ((after-startup-hook
    (hooks:add-hook %slot-value% 'start-slynk-on-startup))))

;;; ---------------------------------------------------------------------------
;;; vi キーバインド
;;;
;;; vi-normal-mode をデフォルトモードに追加する。
;;;   i      -> vi-insert-mode
;;;   escape -> vi-normal-mode に戻る
;;;   h/j/k/l -> スクロール, gg / G -> 先頭 / 末尾
;;;   :      -> execute-command (Emacs バインドの M-x 相当)
;;;   v      -> visual-mode
;;; ---------------------------------------------------------------------------

(define-configuration buffer
  ((default-modes (append '(nyxt/mode/vi:vi-normal-mode) %slot-value%))))

;;; ---------------------------------------------------------------------------
;;; M-x でコマンドパレット (execute-command) を開く
;;;
;;; vi-normal では ":" が execute-command に割り当てられているが、
;;; override-map に置くことで normal / insert / prompt-buffer のどこでも
;;; ―テキスト入力中も含め― M-x が効くようになる。
;;; override-map は input-buffer のスロットなので、web-buffer /
;;; panel-buffer / prompt-buffer すべてに波及する。
;;; ---------------------------------------------------------------------------

(define-configuration input-buffer
  ((override-map
    (let ((map %slot-value%))
      (define-key map
        "M-x" 'execute-command)
      map))))
