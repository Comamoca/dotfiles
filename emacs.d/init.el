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
    :init
    ;; optional packages if you want to use :hydra, :el-get, :blackout,,,
    :config
    ;; initialize leaf-keywords.el
    (leaf-keywords-init)))
;; </leaf-install-code>

;; ================================================

;; Theme
(leaf catppuccin-theme 
  :preface
  :config
  (load-theme 'catppuccin t))

;; Fuzzy finder
(leaf vertico
  :config
  (defvar vertico-count 10)
  :init 
  (vertico-mode))

;; (leaf vertico-directory :ensure t)

;; Fuzzy match for vertico
(leaf orderless)

;; Yet another completion style
(leaf hotfuzz)

;; Completion style config
(setq completion-styles '(orderless hotfuzz basic)
      completion-category-overrides '((file (styles basic partial-completion))))

;; Sources for vertico
(leaf consult)
(leaf consult-dir)
(leaf embark-consult
  :bind
  ((minibuffer-mode-map
    :package emacs
    ("M-." . embark-dwin)
    ("C-." . embark-act))))

(leaf consult-ghq 
  :url "https://github.com/tomoya/consult-ghq"
  :config
  (defvar consult-ghq-find-function #'consult-find))

;; affe
(leaf affe)

;; Emacs evil-mode
(leaf evil
   :config
   ;; (define-key evil-insert-state-map "jk" #'evil-normal-state)
   ;; (define-key evil-normal-state-map (kbd "S-j") nil)
   ;; (define-key evil-normal-state-map (kbd "S-j") #'evil-scroll-down)

   (define-key evil-normal-state-map (kbd "C-k") #'evil-scroll-up)
   (define-key evil-normal-state-map (kbd "C-j") #'evil-scroll-down)

   (define-key evil-normal-state-map (kbd "M-g") #'projectile-switch-project)
   (define-key evil-normal-state-map (kbd "C-l") #'consult-line)
   (define-key evil-normal-state-map (kbd "SPC k") #'avy-goto-line)

   (define-key evil-normal-state-map (kbd "C-i") #'consult-buffer)
   (define-key evil-normal-state-map (kbd "C-o") #'projectile-find-file)
   (define-key evil-normal-state-map (kbd "C-.") #'embark-act)

   ;; Puni
   (define-key evil-normal-state-map (kbd "C-p") #'puni-slurp-forward)
   (define-key evil-normal-state-map (kbd "C-n") #'puni-barf-forward)

   (define-key evil-normal-state-map (kbd "s") nil)
   (define-key evil-normal-state-map (kbd "sd") #'puni-splice)

   (define-key evil-insert-state-map (kbd "C-i") #'puni-mark-sexp-at-point) 

   (global-set-key (kbd "C--") 'puni-expand-region)

   ;; For hydra
   (define-key evil-normal-state-map (kbd "SPC w") #'manage-window-hydra/body)

   ;; For neotree
   (define-key evil-normal-state-map (kbd "SPC f") #'neotree-toggle)
   ;; (define-key evil-normal-state-map (kbd "C-j") #'evil-scroll-down)
   :init
   (evil-mode 1))

;; For edit
(leaf puni
  :init
  (puni-global-mode))

(leaf highlight-indent-guides)

;; Treesitter
(leaf treesit-auto
  :config
  (setq treesit-auto-install t)
  :global-minor-mode global-treesit-auto-mode)


(leaf treesit
  :config
  (setq treesit-font-lock-level 4))

;; for envrc
(leaf envrc)

;; org-mode
(setq org-directory (expand-file-name "~/.ghq/github.com/Comamoca/org"))
(setq org-todo-keywords
  '((sequence "TODO(t)" "PENDING(p)" "|" "DONE(d)" "CANCELED(c)")))

(leaf org
  :hook
  (org-capture-before-finalize-hook)
  (org-mode . org-nix-shell-mode)
  :config
  (set-language-environment "Japanese")
  (prefer-coding-system 'utf-8)
  (set-default 'buffer-file-coding-system 'utf-8) 
  (setq org-default-notes-file "notes.org")
  (setq diary-file-path (format-time-string "diary/%Y/%m-%d.org"))
  (setq memo-file-path (format-time-string "memo/%Y/%m/%d.org"))

  ;; org-capture
  (setq org-capture-templates
   '(("d" "Diary" plain (file diary-file-path)
      "** 今日やったこと\n\n** 明日以降やりたいこと")

     ("m" "Memo" plain (file memo-file-path) "")))

  (setq diary-path (concat org-directory "/diary"))

  (setq org-publish-use-timestamps-flag nil)
  (setq org-publish-project-alist
   '(("Diary"
      :base-directory "~/.ghq/github.com/Comamoca/org/diary"
      :base-extension "org"  
      :recursive t
      :publishing-directory  "~/.ghq/github.com/Comamoca/org/dist"
      :publishing-function org-html-publish-to-html
      :include ("index.org")
      :exclude ())
     
     ("Note"
      :base-directory "~/.ghq/github.com/Comamoca/org/note"
      :base-extension "org"  
      :recursive t
      :publishing-directory  "~/.ghq/github.com/Comamoca/org/note/dist"
      :publishing-function org-html-publish-to-html
      :auto-sitemap t
      :include ("index.org")
      :exclude ()
      :html-head "<link rel=\"stylesheet\" href=\"https://unpkg.com/mvp.css\">")))

;; org-babel
(setq org-confirm-babel-evaluate nil)
(setq python-shell-interpreter "python3")
  (org-babel-do-load-languages
   'org-babel-load-languages
   '(
     (C . t)
     (shell . t)
     (python . t)
     (clojure . t)
     (hy . t)
     (ruby . t)
     ))
  )

(leaf ob-hy)

(leaf org-journal
  :hook
  org-journal-after-header-create-hook
  :config
  (setq org-journal-time-format "")
  (setq org-journal-time-prefix "")
  (setq org-journal-dir (concat org-directory (format-time-string "/diary/%Y")))
  (setq org-journal-file-format (format-time-string "%m-%d.org")) 

  (add-hook 'org-journal-after-header-create-hook 'org-journal-date-format-func)

  (defun org-journal-date-format-func ()
    (insert-file-contents (concat org-directory "/templates/diary.org"))))

;; org-roam
(leaf org-roam
  :config
  (setq org-roam-db-location (expand-file-name "~/.emacs.d/org-roam/database.db"))
  (setq org-roam-directory (expand-file-name "roam" org-directory))
  (setq org-roam-index-file (expand-file-name "index.org" org-roam-directory))
  ;; :init
  (org-roam-db-autosync-mode))

(leaf org-roam-ui)

;; org-modern
(leaf org-modern
  :init
  (with-eval-after-load 'org (global-org-modern-mode)))

(leaf org-modern-indent)

;; For nix develop
(leaf org-nix-shell)

;; Magit
(leaf magit
  :config
  (global-set-key (kbd "C-x g") 'magit-status)
  (setq transient-default-level 5))

;; SKK
(leaf ddskk
  :custom ((default-input-method . "japanease-skk"))
  :config
  (skk-latin-mode 1)
  (global-set-key (kbd "C-x C-j") 'skk-mode)
  (global-set-key (kbd "<henkan>") 'skk-kakutei)
  (global-set-key (kbd "<muhenkan>") 'skk-latin-mode)
  (leaf ddskk-posframe :global-minor-mode t))

;; Lisp
(leaf slime
  :config
  (defvar inferior-lisp-program "sbcl"))

(leaf sly
  :config)
  ;; (defvar inferior-lisp-program "sbcl")
  

(leaf sly-asdf)

;; LSP
(leaf eglot
  :hook
  ((c++-mode
    lua-mode
    gleam-ts-mode
    nix-ts-mode)
   . eglot-ensure))

;; Lua support
(leaf lua-mode)

;; Completion
(leaf corfu
  :config
  (setq corfu-auto t)
  (setq corfu-auto-prefix 1)
  :init
  (global-corfu-mode))

;; Cursor moation
(leaf avy)


;; Completin soruce
(leaf cape
  :init
  (add-to-list 'completion-at-point-functions #'cape-elisp-block)
  (add-to-list 'completion-at-point-functions #'cape-dabbrev)
  (add-to-list 'completion-at-point-functions #'cape-file)
  (add-to-list 'completion-at-point-functions #'cape-history)
  (add-to-list 'completion-at-point-functions #'cape-keyword)
  (add-to-list 'completion-at-point-functions #'yasnippet-capf))
  ;; (add-to-list 'completion-at-point-functions #'cape-line)


;; with icon
(leaf kind-icon
  :custom (kind-icon-default-face 'corfu-default)
  :config
  (add-to-list 'corfu-margin-formatters #'kind-icon-margin-formatter))

(leaf all-the-icons
  :init
  (setq neo-theme (if (display-graphic-p) 'icons 'arrow)))

;; Hydra
(leaf hydra)
(leaf hydra-posframe
  ;; :require t
  ;; :vc (:url "https://github.com/Ladicle/hydra-posframe")
  :hook
  (add-hook 'after-init-hook 'hydra-posframe-mode))
(leaf major-mode-hydra)

;; For Nix
(pretty-hydra-define nix-flake-hydra
  (:separator "-" :title "Nix Flake" :forigen-key warn :quit-key "q" :exit t)
  ("Build"
   (("b" nix-flake-build-default "Build"))

   "Update"
   (("u" nix-flake-update "Update"))))
    

;; For manage window
(pretty-hydra-define manage-window-hydra
  (:separator "-" :title "Manage window" :forigen-key warn :quit-key "q" :exit t)
  ("1"
   (("a" delete-other-windows "Delte other windwos"))

   "2"
   (("s" split-window-below "Horizontal split"))

   "3"
   (("d" split-window-right "Vertical split"))

   "0"
   (("f" delete-window "Delete window"))))

(pretty-hydra-define org-hydra
  (:separator "-" :title "Nix Flake" :forigen-key warn :quit-key "q" :exit t)
  ("Roam"
   (("a" org-roam-node-find "Roam"))

   "Capture"
   (("s" org-capture "Capture"))))
    

;; (pretty-hydra-define org-roam-hydra
;;   (:separator "-" :title "org-roam" :forigen-key warn :quit-key "q" :exit t)
;;   ("Find"
;;    (("a" 'org-roam-node-find "Find node"))

;;    ""
;;    (("s" 'org-roam- ""))

;;    ""
;;    (("d"  ""))

;;    ""
;;    (("f"  ""))
;;     ))

;; Transient dispatcher
(leaf transient-dwim
  :bind ("C-=" . transient-dwim-dispatch))

;; Tree filer
(leaf neotree
  :custom
  (neo-smart-open . t)
  (projectile-switch-project-action . 'neotree-projectile-action)
  :config
  (progn
    (evil-define-key 'normal neotree-mode-map (kbd "q") 'neotree-hide)
    (evil-define-key 'normal neotree-mode-map (kbd "l") 'neotree-enter)
    (evil-define-key 'normal neotree-mode-map (kbd "h") 'neotree-enter)
    (evil-define-key 'normal neotree-mode-map (kbd "g") 'neotree-refresh)
    (evil-define-key 'normal neotree-mode-map (kbd "j") 'neotree-next-line)
    (evil-define-key 'normal neotree-mode-map (kbd "k") 'neotree-previous-line)
    (evil-define-key 'normal neotree-mode-map (kbd "A") 'neotree-stretch-toggle)
    (evil-define-key 'normal neotree-mode-map (kbd "H") 'neotree-hidden-file-toggle)
    (evil-define-key 'normal neotree-mode-map (kbd "N") 'neotree-create-node)
    (evil-define-key 'normal neotree-mode-map (kbd "K") 'neotree-create-node)
    (evil-define-key 'normal neotree-mode-map (kbd "D") 'neotree-delete-node)
    (evil-define-key 'normal neotree-mode-map (kbd "M") 'neotree-rename-node)))
  

;; Translate
(leaf google-translate
  :require t
  :custom
  (google-translate-translation-directions-alist . '(("en" . "ja")
                                                     ("ja" . "en"))))
;; Wakatime
(leaf wakatime-mode
  :init
  (global-wakatime-mode))

;; Typst support

;; (leaf typst-ts-mode
;;   :vc (:url "https://codeberg.org/meow_king/typst-ts-mode")
;;   :require t)

;; Preview
(leaf typst-preview
  ;; :vc (:url "https://github.com/havarddj/typst-preview.el")
  ;; :require t
  :config
  (setq typst-preview-browser "firefox"))

;; Python support

;; Nix support
(leaf nix-mode)

;; Gleam support
(leaf gleam-ts-mode
  :config
  (add-to-list 'auto-mode-alist '("\\.gleam\\'" . gleam-ts-mode)))

;; Markdown suppot
(leaf markdown-mode
  :hook
  (add-to-list 'completion-at-point-functions #'cape-emoji))

;; Projectile
(leaf projectile 
  :init
  (when (executable-find "ghq")
   (setq projectile-known-projects
         (mapcar
          (lambda (x) (abbreviate-file-name x))
          (split-string (shell-command-to-string "ghq list --full-path"))))))

;; Migemo
(leaf migemo
  :hook (after-init-hook . migemo-init)
  :custom
  `((migemo-command . "cmigemo")
    (migemo-dictionary . "/usr/share/cmigemo/utf-8/migemo-dict"))
  :config
  (setq migemo- "~/.migemo/utf-8/migemo-dict") 
  (setq migemo-user-dictionary nil)
  (setq migemo-regex-dictionary nil)
  (setq migemo-coding-system 'utf-8-unix))

;; direnv
(leaf direnv
  :config
  (direnv-mode))

;; Nyan-mode
(leaf nyan-mode
  :init
  (progn (nyan-mode)
   (nyan-start-animation)))

;; Snippets
(leaf yasnippet
  :config
  (setq yas-snippet-dirs '("~/emacs.d/snippets/"))
  (yas-global-mode 1))

;; Snippet collections
(leaf yasnippet-snippets)

;; Templates
(leaf yatemplate)

;; Complation
(leaf yasnippet-capf) 

;; HTTP Request
(leaf request)

;; Gauche
(defun gauche-mode ()
  (interactive)

  (kill-all-local-variables)
  (setq mode-name "gauche")
  (setq major-mode 'gauche-mode) 

  (modify-coding-system-alist 'process "gosh" '(utf-8 . utf-8))

  (if (executable-find "gosh")
      (setq scheme-program-mode "gosh -i")
    (message "gosh is not found"))

  (run-hooks 'gauche-mode-hook))

;; ================ My extentions ================ 

(setq gitmoji--codes (lambda ()
		      (gitmoji-file-path "~/.emacs.d/gitmoji.json")
		      (gitmoji-file 
		       (with-temp-buffer
			 (insert-file-contents gitmoji-file-path)
			 (buffer-substring-no-properties (point-min) (point-max))))
		      (gitmoji-json (json-parse-string gitmoji-file))
		      (gitmojis (gethash "gitmojis" gitmoji-json))
		      (gitmoji-codes (mapcar (lambda (item)
					       ;; Remove leading “:”
					       (substring item 1))
					     (mapcar (lambda (item)
						       (gethash "code" item)) gitmojis)))))

(defun gitmoji-completion ()
  "Completion source for gitmoji"
  (let ((bounds (bounds-of-thing-at-point 'word)))
    (when bounds
      list (car bounds) (cdr bounds)
              gitmoji--codes
              :exclusive 'no)))

;; Enable at git-commit-mode
(add-hook 'git-commit-mode-hook (lambda ()
                                 (setq-local completion-at-point-functions #'gitmoji-completion)))

;; Display character count in modeline
(defun update-buffer-char-count ()
  (interactive)
  (format " [%d 文字] " (buffer-size)))

(defun mode-line-time ()
  ;; Update every second
  (setq display-time-interval 1)
  (setq display-time-string-forms
	'((format "%s:%s:%s" 24-hours minutes seconds)))
  (setq display-time-day-and-date t)
  (display-time-mode t))

(defun mode-line-format-update ()
  (interactive)
  (setq-default mode-line-format
   (append mode-line-format
	   '((:eval (update-buffer-char-count))
	     (:eval (mode-line-time))
	     ))))

;; For diary
(setq blog-repo "/home/coma/.ghq/github.com/Comamoca/blog/")

(defun latest-diary ()
  "Open latest diary. This function call in `src/blog/` directory at blog repository."
  (interactive)
  (let* ((date (format-time-string "%Y-%m-%d"))
         (file-name (format "%s-diary.md" date))
         (path (concat (expand-file-name "src/blog/" blog-repo) file-name)))
    (projectile-switch-project-by-name "blog")
    (find-file path)))

(defun new-blog-article ()
  "Open latest diary. This function call in `src/blog/` directory at blog repository."
  (interactive)
  (let* ((date (format-time-string "%Y-%m-%d"))
	 (title (read-string "title > "))
         (file-name (format "%s-%s.md" date title))
         (path (concat (expand-file-name "src/blog/" blog-repo) file-name)))
    (projectile-switch-project-by-name "blog")
    (find-file path)))

(defun consult-diary ()
  (interactive)
  (let* ((diary-dir (expand-file-name "src/blog" blog-repo))
         (diaries (sort-by-date (cl-remove-if-not (lambda (str) (string-match-p "-diary.md" str))
                                 (directory-files diary-dir))))
         (diary (consult--read diaries :sort nil)))

    (find-file (expand-file-name diary diary-dir))))

(defun extract-date (path)
  (if (string-match "\\([0-9]\\{4\\}-[0-9]\\{2\\}-[0-9]\\{2\\}\\)" path)
      (match-string 1 path)))

(defun sort-by-date (diaries)
  (sort diaries (lambda (a b)
                 (let ((date-a (extract-date a))
                       (date-b (extract-date b)))
                  (string> date-a date-b)))))

(defun org-screenshot ()
  (interactive)
  (setq filename (concat
		  (expand-file-name (format-time-string "%Y-%m-%d-%H%M%S")
				    "~/.ghq/github.com/Comamoca/org/imgs") ".png"))
  ;; (call-process "wl-paste -t image/png" nil nil nil filename)
  (shell-command (concat  "wl-paste -t image/png > " filename))
  (insert (concat "[[" filename "]]"))
  (org-display-inline-images))

;; ================ My configuratons ================ 

;; Custom modeline
(mode-line-format-update)

;; Keymap

;; When org-mode
(add-hook 'org-mode
	  (lambda ()
	    (local-set-key evil-insert-state-map (kbd "C-h") #'org-insert-heading)))

;; Byte compile
(leaf *byte-compile
  :config
  (add-hook 'after-save-hook 'my/recompile-directory)
  (defun my/recompile-directory ()
    (interactive)
    (when (string-equal (file-truename (buffer-file-name))
           (file-truename user-init-file))
      (byte-recompile-file (expand-file-name "~/.emacs.d/init.el") 0))))

(electric-pair-mode 1)

(global-hl-line-mode t)

(setq vc-follow-symlinks t)
(setq browse-url-generic-program "firefox")
(setq ring-bell-function 'ignore)

(setq display-warning-minimum-level :error)

;; Disable to create backupfile
(setq make-backup-files nil)

;; Disable to auto save
(setq auto-save-default nil)

;; Font
(add-to-list 'default-frame-alist
             '(font . "UDEV Gothic NFLG-13.5"))

;; Pinentry Emacs
(defun pinentry-emacs (desc prompt ok error)
  (let ((str (read-passwd (concat (replace-regexp-in-string "%22" "\"" (replace-regexp-in-string "%0A" "\n" desc)) prompt ": "))))
    str))

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
  (leaf leaf-convert)
  (leaf leaf-tree
    :custom ((imenu-list-size . 30)
             (imenu-list-position . 'left))))

(leaf macrostep
  :bind (("C-c e" . macrostep-expand)))


;; (provide 'init)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default-input-method "japanese" nil nil "Customized with leaf in `skk' block at `/home/coma/.emacs.d/init.el'")
 '(package-selected-packages nil)
 '(package-vc-selected-packages
   '((showkey :url "https://github.com/emacsmirror/showkey")
     (hydra-posframe :url "https://github.com/Ladicle/hydra-posframe")
     (typst-preview :url
        "https://github.com/havarddj/typst-preview.el")
     (typst-ts-mode :url "https://git.sr.ht/~meow_king/typst-ts-mode"))))
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
(put 'downcase-region 'disabled nil)
