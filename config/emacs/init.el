;; <leaf-install-code>
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
    ;; (leaf hydra :ensure t)
    ;; (leaf el-get :ensure t)
    ;; (leaf blackout :ensure t)

    :config
    ;; initialize leaf-keywords.el
    (leaf-keywords-init)))
;; </leaf-install-code>

;; ================================================

;; TODO: 
;; (leaf popwin :ensure t
;;   :config
;;   (setq display-buffer-function 'popwin:display-buffer)
;;   ;; Apropos
;;   (push '("*slime-apropos*") popwin:special-display-config)
;;   ;; Macroexpand
;;   (push '("*slime-macroexpansion*") popwin:special-display-config)
;;   ;; Help
;;   (push '("*slime-description*") popwin:special-display-config)
;;   ;; Compilation
;;   (push '("*slime-compilation*" :noselect t) popwin:special-display-config)
;;   ;; Cross-reference
;;   (push '("*slime-xref*") popwin:special-display-config)
;;   ;; Debugger
;;   (push '(sldb-mode :stick t) popwin:special-display-config)
;;   ;; REPL
;;   (push '(slime-repl-mode) popwin:special-display-config)
;;   ;; Connections
;;   (push '(slime-connection-list-mode) popwin:special-display-config)
;;   :init)

(leaf catppuccin-theme :ensure t
  :preface
  :config
  (load-theme 'catppuccin t))

(leaf vertico :ensure t
  :config
  (defvar vertico-count 10)
  :init 
  (vertico-mode))

;; Fuzzy match for vertico
(leaf orderless
  :ensure t
  :config
  (setq completion-styles '(orderless basic)
	completion-category-overrides '((file (styles basic partial-completion)))))

(leaf consult :ensure t)
(leaf consult-ghq :ensure t
  :url "https://github.com/tomoya/consult-ghq"
  :config
  (defvar consult-ghq-find-function #'consult-find))

;; Emacs evil-mode
(leaf evil
   :ensure t
   :config
   ;; (define-key evil-insert-state-map "jk" #'evil-normal-state)
   ;; (define-key evil-normal-state-map (kbd "S-j") nil)
   ;; (define-key evil-normal-state-map (kbd "S-j") #'evil-scroll-down)
   :init
   (evil-mode 1))

;; key-chord library for evil's 
(leaf key-chord :ensure t)

;; For edit
(leaf paredit :ensure t
  :init
  (paredit-mode))

(leaf highlight-indent-guides :ensure t)


;; SKK
(leaf ddskk :ensure t
  :config
  (skk-latin-mode 1)
  (global-set-key (kbd "C-x C-j") 'skk-mode))

;; Lisp
(leaf slime :ensure t
  :config
  (defvar inferior-lisp-program "sbcl"))

(leaf sly :ensure t
  :config
  ;; (defvar inferior-lisp-program "sbcl")
  )

(leaf sly-contribs :ensure t)
(leaf sly-asdf :ensure t)

(leaf parinfer-rust-mode
  :ensure t
  :hook emacs-lisp-mode lisp-mode)

;; LSP
(leaf eglot
  :ensure t
  :hook
  (c++-mode . eglot-ensure)
  (lua-mode . eglot-ensure))

;; Lua support
(leaf lua-mode :ensure t)

;; Completion
(leaf corfu :ensure t
  :config
  (setq corfu-auto t)
  :init
  (global-corfu-mode))


;; ======================= My Configuration =======================

(electric-pair-mode 1)

(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)

(add-hook 'find-file-hooks 'my/always-enable-skk-latin-mode-hook)

(setq vc-follow-symlinks t)

(add-to-list 'default-frame-alist
             '(font . "UDEV Gothic NFLG-13"))

;; initel function that behaves like `:e $MYVIMRC`
(defun initel ()
  "open init.el"
  (interactive)
  (find-file user-init-file))

;; Copy & Paste with wl-clipboard
;; ref: https://gist.github.com/yorickvP/6132f237fbc289a45c808d8d75e0e1fb
(setenv "WAYLAND_DISPLAY" "wayland-1")

(setq wl-copy-process nil)
(defun wl-copy (text)
  (setq wl-copy-process (make-process :name "wl-copy"
                                      :buffer nil
                                      :command '("wl-copy" "-f" "-n")
				      ;; :command '("wl-copy")
                                      :connection-type 'pipe))
  (process-send-string wl-copy-process text)
  (process-send-eof wl-copy-process))


(defun wl-paste ()
  (if (and wl-copy-process (process-live-p wl-copy-process))
      nil	  ; should return nil if we're the current paste owner
    ;; (shell-command-to-string "wl-paste -n | tr -d \r")
    (shell-command-to-string "wl-paste -n")
    ))

(setq interprogram-cut-function 'wl-copy)
(setq interprogram-paste-function 'wl-paste)

;; ================================================

(leaf leaf
  :config
  (leaf leaf-convert :ensure t)
  (leaf leaf-tree
    :ensure t
    :custom ((imenu-list-size . 30)
             (imenu-list-position . 'left))))

(leaf macrostep
  :ensure t
  :bind (("C-c e" . macrostep-expand)))


(provide 'init)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(macrostep leaf-tree leaf-convert "jj" evil-insert-state-map define-key 1 evil-mode :init :ensure evil highlight-indent-guides paredit ivy lsp-mode kanagawa-theme blackout el-get hydra leaf-keywords leaf)))
(custom-set-faces)
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right. 
