;; ========== leaf.el setup start  ==========     
(eval-and-compile
  (customize-set-variable
   'package-archives '(("org" . "https://orgmode.org/elpa/")
                       ("melpa" . "https://melpa.org/packages/")
                       ("gnu" . "https://elpa.gnu.org/packages/")))
  (package-initialize)
  (unless (package-installed-p 'leaf)
    (package-refresh-contents)
    (package-install 'leaf))

  (leaf leaf-keywords
    :ensure t
    :init
    ;; optional packages if you want to use :hydra, :el-get, :blackout,,,
    ;;(leaf hydra :ensure t)
    ;;(leaf el-get :ensure t)
    ;;(leaf blackout :ensure t)

    :config
    ;; initialize leaf-keywords.el
    (leaf-keywords-init)))

;; ========== leaf.el setup end  ==========

;; Now you can use leaf!

;; (leaf leaf-tree :ensure t)
;; (leaf leaf-convert :ensure t)
;; (leaf transient-dwim
;;   :ensure t
;;   :bind (("M-=" . transient-dwim-dispatch)))

(leaf kanagawa-theme :ensure t
  :preface
  :config
  (load-theme 'kanagawa t))

(leaf lsp-mode :ensure t)
(leaf ivy :ensure t)
(leaf paredit :ensure t)
(leaf highlight-indent-guides :ensure t)

(leaf company-go :ensure t)

(leaf company
  :ensure t
  :init
  (global-company-mode)
  (setq company-idle-delay 0.3)
  (setq company-minimum-prefix-length 1)
  (setq company-transformers '(company-sort-by-occurrence))
  :bind
  (:map company-active-map
	("C-n". company-select-next)))

(leaf meow
  :ensure t
  :config
  (defun meow-setup nil
    )

  (meow-setup)
  (meow-global-mode 1)
  )

;; Emacs evil-mode
 (leaf evil
   :ensure t
   :init
   (evil-mode 1)
   (define-key evil-insert-state-map "jj" #'evil-normal-state))

;; Follow symlinks
(setq vc-follow-symlinks t)


(defun initel ()
  "open init.el"
  (interactive)
  (find-file user-init-file))


;; Copy & Paste with wl-clipboard
;; ref: https://gist.github.com/yorickvP/6132f237fbc289a45c808d8d75e0e1fb
(setq wl-copy-process nil)
(defun wl-copy (text)
  (setq wl-copy-process (make-process :name "wl-copy"
                                      :buffer nil
                                      :command '("wl-copy" "-f" "-n")
                                      :connection-type 'pipe))
  (process-send-string wl-copy-process text)
  (process-send-eof wl-copy-process))
(defun wl-paste ()
  (if (and wl-copy-process (process-live-p wl-copy-process))
      nil ; should return nil if we're the current paste owner
      (shell-command-to-string "wl-paste -n | tr -d \r")))

(setq interprogram-paste-function 'wl-paste)
