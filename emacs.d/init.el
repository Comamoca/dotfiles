
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

(leaf vertico-directory :ensure t)

;; Fuzzy match for vertico
(leaf orderless :ensure t)

;; Yet another completion style
(leaf hotfuzz :ensure t)

;; completion style config
(setq completion-styles '(hotfuzz orderless basic)
      completion-category-overrides '((file (styles basic partial-completion))))

;; Sources for vertico
(leaf consult :ensure t)
(leaf consult-dir :ensure t)
(leaf embark-consult :ensure t
  :bind
  ((minibuffer-mode-map
    :package emacs
    ("M-." . embark-dwin)
    ("C-." . embark-act))))

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

   (define-key evil-normal-state-map (kbd "C-k") #'evil-scroll-up)
   (define-key evil-normal-state-map (kbd "C-j") #'evil-scroll-down)

   (define-key evil-normal-state-map (kbd "M-g") #'projectile-switch-project)
   (define-key evil-normal-state-map (kbd "C-l") #'consult-line)
   (define-key evil-normal-state-map (kbd "SPC k") #'avy-goto-line)

   (define-key evil-normal-state-map (kbd "C-i") #'consult-buffer)
   (define-key evil-normal-state-map (kbd "C-.") #'embark-act)

   (define-key evil-normal-state-map (kbd "C-p") #'puni-slurp-forward)
   (define-key evil-normal-state-map (kbd "C-n") #'puni-barf-forward)

   ;; (define-key evil-normal-state-map (kbd "C-j") #'evil-scroll-down)
   :init
   (evil-mode 1))

;; key-chord library for evil's 
(leaf key-chord :ensure t)

;; For edit
(leaf puni :ensure t
  :init
  (puni-global-mode))

(leaf highlight-indent-guides :ensure t)

;; Treesitter
(leaf treesit-auto
  :ensure t
  :config
  (setq treesit-auto-install t)
  (global-treesit-auto-mode))

(leaf treesit
  :config
  (setq treesit-font-lock-level 4))

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

  (setq org-publish-use-timestamps-flag nil)
  (setq org-publish-project-alist
	'(("Diary"
	   :base-directory "~/.ghq/github.com/Comamoca/org/diary"
	   :base-extension "org"  
	   :recursive t
	   :publishing-directory  "~/.ghq/github.com/Comamoca/org/dist"
	   :publishing-function org-html-publish-to-html
	   :include ("index.org")
	   :exclude ()
	   )
	  ("Note"
	   :base-directory "~/.ghq/github.com/Comamoca/org/note"
	   :base-extension "org"  
	   :recursive t
	   :publishing-directory  "~/.ghq/github.com/Comamoca/org/note/dist"
	   :publishing-function org-html-publish-to-html
	   :auto-sitemap t
	   :include ("index.org")
	   :exclude ()
	   :html-head "<link rel=\"stylesheet\" href=\"https://unpkg.com/mvp.css\">"
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
  (global-set-key (kbd "C-x C-j") 'skk-mode)
  (global-set-key (kbd "<henkan>") 'skk-kakutei)
  (global-set-key (kbd "<muhenkan>") 'skk-latin-mode))

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
  (setq corfu-auto-prefix 1)
  :init
  (global-corfu-mode))


;; Completin soruce
(leaf cape :ensure t
  :init
  (add-to-list 'completion-at-point-functions #'cape-dabbrev)
  (add-to-list 'completion-at-point-functions #'cape-file)
  (add-to-list 'completion-at-point-functions #'cape-history)
  (add-to-list 'completion-at-point-functions #'cape-keyword)
  (add-to-list 'completion-at-point-functions #'cape-elisp-block)
  (add-to-list 'completion-at-point-functions #'cape-line)

  ;; For markdown
  (add-to-list 'markdown-mode-hook (lambda ()
				  (add-hook 'completion-at-point-functions #'cape-emoji))))

;; with icon
(leaf kind-icon :ensure t
  :custom (kind-icon-default-face 'corfu-default)
  :config
  (add-to-list 'corfu-margin-formatters #'kind-icon-margin-formatter))

;; Hydra
(leaf hydra :ensure t)
(leaf major-mode-hydra :ensure t)

;; Translate
(leaf google-translate
  :ensure t
  :require t
  :custom
  (google-translate-translation-directions-alist . '(("en" . "ja")
                                                     ("ja" . "en"))))

;; Nix support
(leaf nix-mode :ensure t)

;; Gleam support
(leaf gleam-ts-mode :ensure t)

;; Projectile
(leaf projectile :ensure t
  :init
  (when (executable-find "ghq")
  (setq projectile-known-projects
        (mapcar
         (lambda (x) (abbreviate-file-name x))
	 (split-string (shell-command-to-string "ghq list --full-path"))))))

;; Migemo
(leaf migemo :ensure t
  ;; :hook (after-init-hook . migemo-init)
  :custom
  `((migemo-command . "cmigemo")
    (migemo-dictionary . "/usr/share/cmigemo/utf-8/migemo-dict"))
  :config
  (setq migemo- "~/.migemo/utf-8/migemo-dict") 
  (setq migemo-user-dictionary nil)
  (setq migemo-regex-dictionary nil)
  (setq migemo-coding-system 'utf-8-unix)
  :init
  (migemo-init))

;; Nyan-mode
(leaf nyan-mode :ensure t
  :init
  (nyan-start-animation))

;; Snippets
(leaf yasnippet :ensure t
  :config
  (setq yas-snippet-dirs '("~/emacs.d/snippets/"))
  (yas-global-mode 1))

;; Snippet collections
(leaf yasnippet-snippets :ensure t)

;; Templates
(leaf yatemplate :ensure t
  :cofig)

;; Filer
(leaf direx :ensure t)

;; HTTP Request
(leaf request :ensure t)

;; Expand region
(leaf expand-region :ensure t
  :config
  (global-set-key (kbd "C-=") 'er/expand-region))
 
;; ================ My extentions ================ 

(defun gitmoji-completion ()
  "Completion source for gitmoji"
  (let ((bounds (bounds-of-thing-at-point 'word)))
    (when bounds
      (let* ((gitmoji-file-path "~/.emacs.d/gitmoji.json")
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
					      (gethash "code" item)) gitmojis))))
	(list (car bounds) (cdr bounds)
	      gitmoji-codes
	      :exclusive 'no)))))

;; Enable at git-commit-mode
(add-hook 'git-commit-mode-hook (lambda ()
				 (setq-local completion-at-point-functions #'gitmoji-completion)))

;; Display character count in modeline
(defun update-buffer-char-count ()
  (interactive)
  (format "[%d 文字]" (buffer-size)))

(defun mode-line-format-update ()
  (interactive)
  (setq mode-line-format
	(append mode-line-format
		'((:eval (update-buffer-char-count))))))

;; For diary
(setq blog-repo "/home/coma/.ghq/github.com/Comamoca/blog/")

(defun latest-diary ()
  "Open latest diary. This function call in `src/blog/` directory at blog repository."
  (interactive)
  (let* ((date (format-time-string "%Y-%m-%d"))
	 (file-name (format "%s-diary.md" date))
	 (path (concat (expand-file-name blog-repo "/src/blog/") file-name)))
    (cd blog-repo)
    (find-file file-name)))

(defun consult-diary ()
  (interactive)
  (let* ((diaries (sort-by-date (cl-remove-if-not (lambda (str) (string-match-p "-diary.md" str))
						 (directory-files (expand-file-name blog-repo "src/blog")))))
	 (diary (consult--read diaries :sort nil)))

    (find-file (expand-file-name diary blog-repo))))

(defun extract-date (path)
  (if (string-match "\\([0-9]\\{4\\}-[0-9]\\{2\\}-[0-9]\\{2\\}\\)" path)
                   (match-string 1 path)))

(defun sort-by-date (diaries)
  (sort diaries (lambda (a b)
		       (let ((date-a (extract-date a))
			     (date-b (extract-date b)))
			 (string> date-a date-b)))))

;; ================ My configuratons ================ 

(electric-pair-mode 1)

(hl-line-mode)

(setq vc-follow-symlinks t)

(setq ring-bell-function 'ignore)

;; Disable menu bar and tool bar
(menu-bar-mode -1)
(tool-bar-mode 0)

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
(put 'downcase-region 'disabled nil)
