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

;; Theme
(leaf catppuccin-theme :ensure t
  :preface
  :config
  (load-theme 'catppuccin t))

;; Fuzzy finder
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

;; Sources for vertico
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

;; org-mode
(leaf org
  :ensure t
  :hook
  org-capture-before-finalize-hook
  :config
  (set-language-environment "Japanese")
  (prefer-coding-system 'utf-8)
  (set-default 'buffer-file-coding-system 'utf-8)
  (setq org-directory (expand-file-name "~/.ghq/github.com/Comamoca/org"))
  (setq org-default-notes-file "notes.org")
  (setq diary-file-path (format-time-string "diary/%Y/%m-%d.org"))

  ;; org-capture
  (setq org-capture-templates
	'(("d" "Diary" plain (file diary-file-path)
	 "** 今日やったこと\n\n** 明日以降やりたいこと")))

  (setq diary-path (concat org-directory "/diary"))

  (setq org-publish-project-alist
	'(("Diary"
	   :base-directory "~/.ghq/github.com/Comamoca/org/diary"
	   :base-extension "org"  
	   :recursive t
	   :publishing-directory  "~/.ghq/github.com/Comamoca/org/dist"
	   :publishing-function org-html-publish-to-html
	   :include ("index.org")
	   :exclude ()
	   )))
  )

(leaf org-journal
  :ensure t
  :hook
  org-journal-after-header-create-hook
  :config
  (setq org-journal-time-format "")
  (setq org-journal-time-prefix "")
  (setq org-journal-dir (concat org-directory (format-time-string "/diary/%Y")))
  (setq org-journal-file-format (format-time-string "%m-%d.org"))
  (setq org-directory (expand-file-name "~/.ghq/github.com/Comamoca/org"))

  (add-hook 'org-journal-after-header-create-hook 'org-journal-date-format-func)

  (defun org-journal-date-format-func ()
    (insert-file-contents (concat org-directory "/templates/diary.org"))))

;; Magit
(leaf magit
  :ensure t
  :config
  (global-set-key (kbd "C-x g") 'magit-status)
  (setq transient-default-level 5))

;; SKK
(leaf ddskk :ensure t
  :config
  (skk-latin-mode 1)
  (global-set-key (kbd "C-x C-j") 'skk-mode))

(leaf skk :ensure ddskk
  :custom ((default-input-method . "japanease-skk"))
  :config
  (leaf ddskk-posframe
    :ensure t
    :global-minor-mode t))

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
  :hook
  emacs-lisp-mode
  lisp-mode
  :config
  (parinfer-rust-preferred-mode "indent")
  :init
  (setq parinfer-rust-auto-download t))

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

;; Hydra
(leaf hydra :ensure t)
(leaf major-mode-hydra :ensure t)

;; Nix support
(leaf nix-mode :ensure t)

;; Gleam support
(leaf gleam-ts-mode :ensure t)

;; ======================= My Configuration =======================

(electric-pair-mode 1)

(hl-line-mode)

(setq vc-follow-symlinks t)

;; Font
(add-to-list 'default-frame-alist
             '(font . "UDEV Gothic NFLG-13.5"))


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
      nil    ; should return nil if we're the current paste owner
    ;; (shell-command-to-string "wl-paste -n | tr -d \r")
    (shell-command-to-string "wl-paste -n")))
    

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
 '(default-input-method "japanese" nil nil "Customized with leaf in `skk' block at `/home/coma/.emacs.d/init.el'")
 '(package-selected-packages
   '(macrostep leaf-tree leaf-convert "jj" evil-insert-state-map
	       define-key 1 evil-mode :init :ensure evil
	       highlight-indent-guides paredit ivy lsp-mode
	       kanagawa-theme blackout el-get hydra leaf-keywords leaf)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:family "UDEV Gothic NFLG" :foundry "TWR" :slant normal :weight regular :height 128 :width normal)))))
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right. 
