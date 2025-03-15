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

;; embark
(leaf embark
  :config
  (evil-define-key 'normal 'insert (kbd "C-.") 'embark-act)
  (define-key evil-normal-state-map (kbd "C--") #'embark-export))

;; Sources for vertico
(leaf consult :require t)
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
  :defer-config
  ;; (define-key evil-insert-state-map "jk" #'evil-normal-state)
  ;; (define-key evil-normal-state-map (kbd "S-j") nil)
  ;; (define-key evil-normal-state-map (kbd "S-j") #'evil-scroll-down)

  (define-key evil-normal-state-map (kbd "C-k") #'evil-scroll-up)
  (define-key evil-normal-state-map (kbd "C-j") #'evil-scroll-down)

  (define-key evil-normal-state-map (kbd "M-g") #'projectile-switch-project)
  (define-key evil-normal-state-map (kbd "C-o") #'projectile-find-file)

  (define-key evil-normal-state-map (kbd "C-l") #'consult-line)
  (define-key evil-normal-state-map (kbd "C-i") #'consult-buffer) 

  (define-key evil-normal-state-map (kbd "SPC k") #'avy-goto-line)
  (define-key evil-insert-state-map (kbd "C-h") #'delete-backward-char)

  ;; (define-key evil-normal-state-map (kbd "C-j") #'evil-scroll-down)
  :init
  (evil-mode 1))


;; For edit
(leaf puni
  :config
  (global-set-key (kbd "C--") 'puni-expand-region)
  (define-key evil-normal-state-map (kbd "s") nil) 
  (define-key evil-normal-state-map (kbd "sd") #'puni-splice)
  (define-key evil-insert-state-map (kbd "C-i") #'puni-mark-sexp-at-point)
  (define-key evil-normal-state-map (kbd "C-p") #'puni-slurp-forward)
  (define-key evil-normal-state-map (kbd "C-n") #'puni-barf-forward)

  :init
  (puni-global-mode))

(leaf highlight-indent-guides)

;; Treesitter
(leaf treesit-auto
  :custom
  (treesit-auto-install 'prompt)
  :init
  (setq treesit-auto-install t)
  (treesit-auto-add-to-auto-mode-alist 'all)
  (global-treesit-auto-mode))

(leaf treesit
  :init
  (add-to-list 'auto-mode-alist '("\\.cshtml\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.cs\\'" . csharp-ts-mode))
  (add-to-list 'auto-mode-alist '("\\.ex\\'" . elixir-ts-mode))
  (add-to-list 'auto-mode-alist '("\\.gleam\\'" . gleam-ts-mode))
  (add-to-list 'auto-mode-alist '("\\.ts\\'" . typescript-ts-mode))
  (add-to-list 'auto-mode-alist '("\\.tsx\\'" . tsx-ts-mode))
  (add-to-list 'auto-mode-alist '("\\.rust\\'" . rust-ts-mode))
  (add-to-list 'auto-mode-alist '("\\.typ\\'" . typst-ts-mode)) 
  (add-to-list 'auto-mode-alist '("\\.dat$" . ledger-mode))
  (add-to-list 'auto-mode-alist '("\\.yaml" . yaml-ts-mode))
  (add-to-list 'auto-mode-alist '("\\.yml" . yaml-ts-mode))
  (add-to-list 'auto-mode-alist '("templates" . lisp-data-mode))
  (add-to-list 'auto-mode-alist '("Dockerfile" . dockerfile-ts-mode))

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

  ;; org-calendar
  (define-key calendar-mode-map (kbd "C-c c") 'org-capture-from-calendar)

  ;; org-capture
  (setq org-capture-templates
	'(("d" "Diary" plain (file diary-file-path)
	   "** 今日やったこと\n\n** 明日以降やりたいこと")
	  ("m" "Memo" plain (file memo-file-path) "")
	  ))

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
   '((C . t)
     (shell . t)
     (python . t)
     (clojure . t)
     (hy . t)
     (ruby . t)
     (ledger . t))))

;; (add-hook 'org-mode-hook (lambda ()
;; 			   (define-key 'evil-normal-state-map (kbd "M-v") #'org-paste-image)))

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
  (setq org-roam-directory (expand-file-name "roam" org-directory))
  (setq org-roam-db-location (expand-file-name "~/.emacs.d/org-roam/database.db"))
  (setq org-roam-index-file (expand-file-name "index.org" org-roam-directory))
  (setq org-roam-directory (expand-file-name "roam" org-directory))
  ;; :init
  (org-roam-db-autosync-mode))

;; Deft
;; For search roam files.
(leaf deft
  :after (org-roam-mode)
  :config
  (setq deft-directory (expand-file-name "roam" org-directory))
  (setq deft-extensions '("txt" "tex" "org")))

(leaf org-roam-ui)

;; org-bullets
(leaf org-bullets
  :hook org-mode-hook (org-bullets-mode 1))

;; org-modern
(leaf org-modern
  :init
  ;; (with-eval-after-load 'org (global-org-modern-mode))
  )

(leaf org-modern-indent)

;; For nix develop
(leaf org-nix-shell)

;; Magit
(leaf magit
  :config
  (global-set-key (kbd "C-x g") 'magit-status)
  (define-key magit-mode-map (kbd "/") 'isearch-forward)
  (define-key magit-mode-map (kbd "C-"))
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

;; Common Lisp
(leaf slime
  :config
  (defvar inferior-lisp-program "sbcl"))

(leaf sly
  :config)
  ;; (defvar inferior-lisp-program "sbcl")

(leaf sly-asdf)

;; Clojure
(leaf cider)

(leaf kaocha-runner
  :after (cider-mode))
  

;; flycheck
(leaf flycheck
  :hook
  (after-init . global-flycheck-mode)
  ((text-mode-hook markdown-mode-hook gfm-mode-hook org-mode-hook) . flycheck-mode)
  :custom ((flycheck-display-errors-delay . 0.3)
           (flycheck-indication-mode . 'left-margin))
  :config
  (add-hook 'flycheck-mode-hook #'flycheck-set-indication-mode)
  :hook
  (global-flycheck-mode))

(leaf flycheck-pos-tip)
(leaf flycheck-inline
  :hook (flycheck-mode-hook . flycheck-inline-mode))

;; for textlint
(flycheck-define-checker textlint
  "A linter for prose."
  :command ("textlint" "--format" "unix" source-inplace)
  :error-patterns
  ((warning line-start (file-name) ":" line ":" column ": "
      (id (one-or-more (not (any " "))))
      (message (one-or-more not-newline)
        (zero-or-more "\n" (any " ") (one-or-more not-newline)))
      line-end))
  :modes (text-mode markdown-mode gfm-mode org-mode web-mode))

;; Copilot
(leaf copilot
  :config
  (add-to-list 'copilot-major-mode-alist '("enh-ruby" . "ruby"))
  (add-to-list 'copilot-major-mode-alist '("typescript-ts-mode" . "typescript"))

  ;; keymap
  (define-key copilot-completion-map (kbd "TAB") #'copilot-accept-completion))


;; LSP
;; (leaf lsp-bridge :require t
;;   :config
;;   (setq acm-enable-capf t)
;;   :init
;;   (global-lsp-bridge-mode))


(leaf lsp-mode :require t
  :config
  (define-key evil-normal-state-map (kbd "K") 'lsp-ui-doc-glance)
  :hook
  (add-hook 'prog-mode-hook #'lsp-deferred)
  ;; (add-hook 'prog-mode-hook #'lsp-deferred)
  )

;; Eglot
;; (defun node-project-p ()
;;   (let ((p-root (car (last (project-current)))))
;;     (file-exists-p (concat p-root "package.json"))))

;; (defun es-server-program (_)
;;   (message (node-project-p))
;;   (cond ((node-project-p) '("typescript-language-server" "--stdio"))
;; 	(t '("deno" "lsp" :initializationOptions (:enable t :lint t)))))

;; (defun my/eglot-capf ()
;;     (setq-local completion-at-point-functions
;; 		(list (cape-capf-super
;; 		       #'eglot-completion-at-point
;; 		       #'cape-file))))

;; (leaf eglot
;;   ;; eglot-completion-at-point 
;;   :config
;;   (add-to-list 'eglot-server-programs '((js-mode typescript-mode) . es-server-program))

;;   :hook
;;   (elixir-ts-mode . eglot-ensure)
;;   (c++-mode . eglot-ensure)
;;   (lua-ts-mode . eglot-ensure)
;;   (gleam-ts-mode . eglot-ensure)
;;   (nix-ts-mode . eglot-ensure)
;;   (python-ts-mode . eglot-ensure)
;;   (typescript-ts-mode . eglot-ensure)
;;   (typst-ts-mode . eglot-ensure)
;;   (scala-ts-mode . eglot-ensure)
;;   ;; (eglot-managed-mode-hook . #'my/eglot-capf)
;;   )

;; (add-hook 'eglot-managed-mode-hook #'my/eglot-capf)

;; LSP Booster
(defun lsp-booster--advice-json-parse (old-fn &rest args)
  "Try to parse bytecode instead of json."
  (or
   (when (equal (following-char) ?#)
     (let ((bytecode (read (current-buffer))))
       (when (byte-code-function-p bytecode)
         (funcall bytecode))))
   (apply old-fn args)))

(advice-add (if (progn (require 'json)
                       (fboundp 'json-parse-buffer))
                'json-parse-buffer
              'json-read)
            :around
            #'lsp-booster--advice-json-parse)

(defun lsp-booster--advice-final-command (old-fn cmd &optional test?)
  "Prepend emacs-lsp-booster command to lsp CMD."
  (let ((orig-result (funcall old-fn cmd test?)))
    (if (and (not test?)                             ;; for check lsp-server-present?
             (not (file-remote-p default-directory)) ;; see lsp-resolve-final-command, it would add extra shell wrapper
             lsp-use-plists
             (not (functionp 'json-rpc-connection))  ;; native json-rpc
             (executable-find "emacs-lsp-booster"))
        (progn
          (when-let ((command-from-exec-path (executable-find (car orig-result))))  ;; resolve command from exec-path (in case not found in $PATH)
            (setcar orig-result command-from-exec-path))
          (message "Using emacs-lsp-booster for %s!" orig-result)
          (cons "emacs-lsp-booster" orig-result))
      orig-result)))

(advice-add 'lsp-resolve-final-command :around #'lsp-booster--advice-final-command)

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

;; Completion soruce
(leaf cape :after corfu)


  ;; (add-to-list 'completion-at-point-functions #'cape-line)


;; with icon
(leaf kind-icon
  :custom (kind-icon-default-face 'corfu-default)
  :config
  (add-to-list 'corfu-margin-formatters #'kind-icon-margin-formatter))

(leaf all-the-icons
  :init
  (setq-default neo-theme (if (display-graphic-p) 'icons 'arrow)))

;; Hydra
(leaf hydra)
(leaf hydra-posframe
  ;; :require t
  ;; :vc (:url "https://github.com/Ladicle/hydra-posframe")

  :init
  ;; For hydra
  (define-key evil-normal-state-map (kbd "SPC w") #'manage-window-hydra/body)

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
    (evil-define-key 'normal neotree-mode-map (kbd "RET") 'neotree-enter)
    (evil-define-key 'normal neotree-mode-map (kbd "h") 'neotree-enter)
    (evil-define-key 'normal neotree-mode-map (kbd "g") 'neotree-refresh)
    (evil-define-key 'normal neotree-mode-map (kbd "j") 'neotree-next-line)
    (evil-define-key 'normal neotree-mode-map (kbd "k") 'neotree-previous-line)
    (evil-define-key 'normal neotree-mode-map (kbd "A") 'neotree-stretch-toggle)
    (evil-define-key 'normal neotree-mode-map (kbd "H") 'neotree-hidden-file-toggle)
    (evil-define-key 'normal neotree-mode-map (kbd "N") 'neotree-create-node)
    (evil-define-key 'normal neotree-mode-map (kbd "K") 'neotree-create-node)
    (evil-define-key 'normal neotree-mode-map (kbd "D") 'neotree-delete-node)
    (evil-define-key 'normal neotree-mode-map (kbd "M") 'neotree-rename-node))
  
  ;; For neotree
  (define-key evil-normal-state-map (kbd "SPC f") #'neotree-toggle))
  

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

;; Typst

;; Preview
(leaf typst-preview
  ;; :vc (:url "https://github.com/havarddj/typst-preview.el")
  ;; :require t
  :config
  (setq typst-preview-browser "firefox"))

;; Ruby support
(leaf inf-ruby)

(leaf enh-ruby-mode)

;; Python support
(add-hook 'python-ts-mode-hook (lambda ()
				 (require 'python-mode)))

;; Language supports

;; dotnet
(leaf dotnet
  :after csharp-mode)

;; C#
(leaf csharp-mode)

;; Nix support
(leaf nix-mode
  :hook
  (nix-ts-mode))

;; Scala suppport
;; (leaf scala-ts-mode
;;   :config
;;   (add-to-list 'auto-mode-alist '("\\.scala\\'" . scala-mode)))

(leaf scala-mode
  :interpreter ("scala" . scala-mode))

(leaf sbt-mode
  :commands sbt-start sbt-command
  :config
  (substitute-key-definition
   'minibuffer-complete-word
   'self-insert-command
   minibuffer-local-completion-map)

   (setq sbt:program-options '("-Dsbt.supershell=false")))

;; Astro support
(leaf astro-ts-mode)

;; Elixir support
(leaf inf-elixir)
(leaf mix)

(leaf elixir-ts-mode
  :hook ((elixir-ts-mode . mix-minor-mode)))

;; KDL supports
(leaf kdl-ts-mode)

;; Gleam support
(leaf gleam-ts-mode :require t)

;; Markdown suppot
(leaf markdown-mode
  :hook
  (add-to-list 'completion-at-point-functions #'cape-emoji))

;; Projectile
(defun update-projectlist ()
  (interactive)
  (setq projectile-known-projects
         (mapcar
          (lambda (x) (abbreviate-file-name x))
          (split-string (shell-command-to-string "ghq list --full-path")))))

(leaf projectile 
  :init
  (when (executable-find "ghq")
   (update-projectlist)))

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

(leaf tempel
  :config
  (defun tempel-setup-capf ()
    (setq-local completion-at-point-functions
                (cons #'tempel-complete
                      completion-at-point-functions)))

  (add-hook 'conf-mode-hook 'tempel-setup-capf)
  (add-hook 'prog-mode-hook 'tempel-setup-capf)
  (add-hook 'text-mode-hook 'tempel-setup-capf)

  (add-hook 'markdown-mode-hook (lambda ()
				  (setq-local
				   completion-at-point-functions
				   #'tempel-complete
				   )))

  (add-hook 'git-commit-mode-hook (lambda ()
				    (setup-gitmoji)
				    (setq-local completion-at-point-functions
						(list (cape-capf-super
						       #'tempel-complete
						       #'gitmoji-completion))))))

(leaf tempel-collection)

;; HTTP Request
(leaf request)
(leaf plz)

(autoload 'newsticker-start "newsticker" "Start Newsticker" t)
(autoload 'newsticker-show-news "newsticker" "Goto Newsticker buffer" t)

(setq newsticker-url-list
      '(("Gleam Weekly" "https://gleamweekly.com/atom.xml")
        ("Zenn Gleam" "https://zenn.dev/topics/gleam/feed")
	("Gleam Releases" "https://github.com/gleam-lang/gleam/releases.atom")
	("Zenn Trend" "https://zenn.dev/feed")
	("Zenn Emacs" "https://zenn.dev/topics/emacs/feed")
        ("Zenn TS" "https://zenn.dev/topics/typescript/feed")
        ("Zenn CL" "https://zenn.dev/topics/commonlisp/feed")
        ("Zenn Deno" "https://zenn.dev/topics/deno/feed")
        ("Zenn Bun" "https://zenn.dev/topics/bun/feed")
        ("Zenn Rust" "https://zenn.dev/topics/rust/feed")
        ("Zenn Vim" "https://zenn.dev/topics/vim/feed")
        ("Zenn Neovim" "https://zenn.dev/topics/neovim/feed")
        ("Zenn Scheme" "https://zenn.dev/topics/scheme/feed")
        ("Zenn Hono" "https://zenn.dev/topics/hono/feed")
        ("Zenn React" "https://zenn.dev/topics/react/feed")
        ("Zenn GCP" "https://zenn.dev/topics/googlecloud/feed")
        ("Zenn AWS" "https://zenn.dev/topics/aws/feed")
        ("TechFeed" "https://techfeed.io/feeds/categories/all")
	("Hacker News" "https://hnrss.org/frontpage")
        ("輪ごむの空き箱" "https://wagomu.me/rss.xml")))

;; newsticker keybinds
(evil-define-key 'normal newsticker-treeview-mode-map (kbd "o") 'newsticker-treeview-browse-url)
(evil-define-key 'normal newsticker-treeview-mode-map (kbd "q") 'newsticker-treeview-quit)

(evil-define-key 'normal newsticker-treeview-list-mode-map (kbd "o") 'newsticker-treeview-browse-url)
(evil-define-key 'normal newsticker-treeview-list-mode-map (kbd "q") 'newsticker-treeview-quit)

(evil-define-key 'normal newsticker-treeview-mode-map (kbd "j") 'newsticker-treeview-next-feed)
(evil-define-key 'normal newsticker-treeview-mode-map (kbd "k") 'newsticker-treeview-prev-feed)

(evil-define-key 'normal newsticker-treeview-mode-map (kbd "n") 'newsticker-treeview-next-item)
(evil-define-key 'normal newsticker-treeview-mode-map (kbd "p") 'newsticker-treeview-prev-item)

(leaf eww
  :config
  (evil-define-key 'normal eww-mode-map
    (kbd "r") 'eww-reload))

(leaf gptel
  :config
  (setq
     ;; gptel-model 'gemini-1.5-flash-8b
     ;; gptel-backend (gptel-make-gemini "Gemini"
     ;; 		     :key "AIzaSyAc48YOf5odBCNfHwTBNbO0_Z2efhoT5pQ"
     ;; 		     :stream t))

  gptel-model 'starcoder2
  gptel-backend (gptel-make-ollama "Ollama"
                 :host "localhost:11434"
                 :stream t
                 :models '(starcoder2))))

(leaf dash)

(leaf editorconfig
  :config
  (editorconfig-mode 1))

(leaf reformatter
  :config
  (reformatter-define dprint
    :program "dprint" :args `("fmt" "--stdin" ,buffer-file-name))
  (reformatter-define deno
    :program "deno" :args `("fmt" ,buffer-file-name)))

(leaf ledger
  :config)

(leaf grugru
  :config
  ;; ref: https://github.com/ROCKTAKEY/grugru/issues/44
  (defun +grugru--getter-number ()
    (if (string-match-p "^-?\\(?:[0-9]*[.]\\)?[0-9]+$" (thing-at-point 'word))
	(bounds-of-thing-at-point 'number)))

  (add-to-list 'grugru-getter-alist '(number . +grugru--getter-number))

  (grugru-define-global
   'number
   (lambda (arg &optional rev)
     (let ((num (string-to-number arg)))
       (number-to-string (if rev (- num 1) (+ num 1))))))

  (define-key evil-normal-state-map (kbd "C-a") 'grugru)
  (define-key evil-normal-state-map (kbd "C-x") 'grugru-backward)
  )

(leaf good-scroll
  :init
  (good-scroll-mode 1))

(leaf sublimity
  )

(leaf iscroll)


;; ================ My extentions ================ 


(defun nyan-region ()
  "選択範囲をにゃーんで置換する"
  (interactive)
  (when (use-region-p)
    (let* ((beg (region-beginning))
           (end (region-end))
	   (len (- end beg)))
      (delete-region beg end)
      (cond ((= len 1) (insert "にゃ"))
	    ((= len 2) (insert "にゃん"))
	    (t (insert (format "にゃ%sん" (make-string (- len 3) ?ー))))))))

(defun blackening-region ()
  "選択範囲を█で置換する"
  (interactive)
  (when (use-region-p)
    (let ((beg (region-beginning))
          (end (region-end)))
      (delete-region beg end)
      (insert (make-string (- end beg) ?█)))))

(defun fortune ()
  (require 'plz)

  (let-alist (plz 'get "https://api.yasunori.dev/awesome/random" :as #'json-read)
    (format "%s \n『%s』 by %s" .content .title .senpan)))

(defun open-google ()
  (interactive)
  (require 'url-util)

  (let* ((query (read-from-minibuffer "query? > "))
	 (url (concat "https://www.google.com/search?client=firefox-b-d&q=" (url-hexify-string query))))
  
    (shell-command (concat "open " "'" url "'"))))

(defun home-manager ()
  (interactive)
  (let ((default-directory (expand-file-name "~/.ghq/github.com/Comamoca/dotfiles"))
	(proc (start-process "home-manager-process"
			     "*home-manager*"
			     "home-manager"
			     "switch"
			     "--flake"
			     ".#Home"
			     "-b"
			     "backup")))))

    ;; (set-process-sentinel proc
    ;;                           (lambda (process event)
    ;;                             (when (string= event "finished\n"))))


(defun notify-send (title msg)
  ;; " -i " notify-icon
  (let ((cmd (mapconcat #'shell-quote-argument (list "notify-send"
						     title
						     msg) " ")))
    (shell-command-to-string cmd)))

(defun all (pred lst)
  "Returns t if all elements of the list satisfy the predicate."
  (catch 'done
    (dolist (item lst t)
      (unless (funcall pred item)
        (throw 'done nil)))))

;; 起動時にJSONファイルをパースした結果を予め用意しておく
(setq gitmoji--json-data (let* ((gitmoji-file-path "~/.data/gitmoji.json")
				(gitmoji-file (with-temp-buffer
						(insert-file-contents gitmoji-file-path)
						(buffer-substring-no-properties (point-min) (point-max))))
				(gitmoji-json (json-parse-string gitmoji-file)))

			   gitmoji-json))

(defun setup-gitmoji ()
  (interactive)
  (unless (boundp 'gitmoji--codes) 

    (setq gitmoji--codes
	  (let* ((gitmojis (gethash "gitmojis" gitmoji--json-data))
		 (gitmoji-codes (mapcar (lambda (item)
					  ;; Remove leading “:”
					  (substring item 1))
					(mapcar (lambda (item)
						  (gethash "code" item)) gitmojis))))
	    gitmoji-codes)))
  gitmoji--codes)

(defun gitmoji-completion ()
  (when-let ((bounds (bounds-of-thing-at-point 'symbol)))
    (list (car bounds) (cdr bounds) (setup-gitmoji))))

;; Collect gitmoji when startup
;; (add-hook 'emacs-startup-hook 'setup-gitmoji)
;; Enable at git-commit-mode

;; Display character count in modeline
(defun update-buffer-char-count ()
  (interactive)
  (format " [%d] " (buffer-size)))

(defun mode-line-time ()
  ;; Update every second
  (setq display-time-interval 1)
  (setq display-time-string-forms
   '((format "%s/%s %s:%s" (string-to-number month) (string-to-number day) 24-hours minutes seconds)))
  (setq display-time-day-and-date t)
  (display-time-mode t))

(defun mode-line-format-update ()
  (interactive)
  (setq-default mode-line-format
   (append mode-line-format
     '((:eval (update-buffer-char-count))
       (:eval (mode-line-time))))))
       

;; For diary
(setq blog-repo "/home/coma/.ghq/github.com/Comamoca/blog/")

(defun latest-diary ()
  "Open latest diary. This function call in `src/blog/` directory at blog repository."
  (interactive)
  (let* ((date (format-time-string "%Y-%m-%d"))
         (file-name (format "%s-diary.md" date))
         (path (concat (expand-file-name "src/blog/" blog-repo) file-name))
	 (buf (find-file path)))
    ;; (projectile-switch-project-by-name "blog")
    
    (if (= (buffer-size) 0)
	(tempel-insert 'diary))))

(defun new-blog-article ()
  "Open latest diary. This function call in `src/blog/` directory at blog repository."
  (interactive)
  (let* ((date (format-time-string "%Y-%m-%d"))
         (title (read-string "title > "))
         (file-name (format "%s-%s.md" date title))
         (path (concat (expand-file-name "src/blog/" blog-repo) file-name)))
    ;; (projectile-switch-project-by-name "blog")
    (find-file path)))

(defun consult-diary ()
  (interactive)
  (let* ((diary-dir (expand-file-name "src/blog" blog-repo))
         (diaries (sort-by-date (cl-remove-if-not (lambda (str) (string-match-p "-diary.md" str))
                                 (directory-files diary-dir))))
         (diary (consult--read diaries :sort nil)))

    (find-file (expand-file-name diary diary-dir))))

(defun consult-blog ()
  (interactive)
  (let* ((diary-dir (expand-file-name "src/blog" blog-repo))
         (diaries (sort-by-date (cl-remove-if-not (lambda (str)
                                                   (or (string-match "[0-9]\\{4\\}-[0-9]\\{2\\}-[0-9]\\{2\\}-" str)
                                                    (string-match-p "-diary.md" str
                                                                              (directory-files diary-dir)
                                                      (diary (consult--read diaries :sort nil)))))))))

    (find-file (expand-file-name diary diary-dir))))

(defun extract-date (path)
  (if (string-match "\\([0-9]\\{4\\}-[0-9]\\{2\\}-[0-9]\\{2\\}\\)" path)
      (match-string 1 path)))

(defun sort-by-date (diaries)
  (sort diaries (lambda (a b)
                 (let ((date-a (extract-date a))
                       (date-b (extract-date b)))
                  (string> date-a date-b)))))

(defun org-paste-image ()
  (interactive)
  (setq filename (concat
                  (expand-file-name (format-time-string "%Y-%m-%d-%H%M%S")
                   "~/.ghq/github.com/Comamoca/org/imgs") ".png"))
  (shell-command (concat  "wl-paste -t image/png > " filename))
  (insert (concat "[[" filename "]]"))
  (org-display-inline-images))

(defun blog-paste-image ()
  (interactive)
  (setq filename (concat
                  (expand-file-name (format-time-string "%Y-%m-%d-%H%M%S")
                   "~/.ghq/github.com/Comamoca/blog/src/images") ".png"))
  (shell-command (concat  "wl-paste -t image/png > " filename))
  (insert (concat "![](" filename ")"))
  (org-display-inline-images))


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

;; consult for org-roam
(defun consult-roam ()
  (interactive)
  (let* ((node-items (mapcar (lambda (node)
			       (cons (org-roam-node-title node) node)) (org-roam-node-list)))
	 (select-node-title (consult--read
			     (mapcar #'car node-items)))
	 (select-node (cdr (assoc select-node-title node-items))))

    (find-file (org-roam-node-file select-node))))

;; Search
(leaf rg
  :require t)

(leaf open-junk-file
  :bind (("C-x j" . open-junk-file))
  :config
  (setq open-junk-file-format "/tmp/junk/%Y_%m_%d_%H%M%S."))


;; nano-tools
;; (leaf nano-theme)
;; (leaf nano-popup)

;; (leaf nano-box
;;   :init
;;   (nano-box))

;; (leaf nano-theme
;;   :preface
;;   :config
;;   (load-theme 'nano-dark))

;; (leaf nano-modeline
;;   :config
;;   (add-hook 'prog-mode-hook            #'nano-modeline-prog-mode)
;;   (add-hook 'text-mode-hook            #'nano-modeline-text-mode)
;;   (add-hook 'org-mode-hook             #'nano-modeline-org-mode)
;;   (add-hook 'pdf-view-mode-hook        #'nano-modeline-pdf-mode)
;;   (add-hook 'mu4e-headers-mode-hook    #'nano-modeline-mu4e-headers-mode)
;;   (add-hook 'mu4e-view-mode-hook       #'nano-modeline-mu4e-message-mode)
;;   (add-hook 'elfeed-show-mode-hook     #'nano-modeline-elfeed-entry-mode)
;;   (add-hook 'elfeed-search-mode-hook   #'nano-modeline-elfeed-search-mode)
;;   (add-hook 'term-mode-hook            #'nano-modeline-term-mode)
;;   (add-hook 'xwidget-webkit-mode-hook  #'nano-modeline-xwidget-mode)
;;   (add-hook 'messages-buffer-mode-hook #'nano-modeline-message-mode)
;;   (add-hook 'org-capture-mode-hook     #'nano-modeline-org-capture-mode)
;;   (add-hook 'org-agenda-mode-hook      #'nano-modeline-org-agenda-mode)
;; )

;; (setq-default fringes-outside-margins t)
;; (setq window-margins nil)

;; (defun my/display-buffer-box (window)
;;   (with-current-buffer (window-buffer window)
;;     (nano-box-on)))

;; (setq display-buffer-alist '(((derived-mode . (prog-mode))
;; 			      display-buffer-reuse-window
;; 			      display-buffer-same-window
;; 			      (body-function . my/display-buffer-box))))

;; ================ My configuratons ================

(setq create-lockfiles nil)

;; Key mapping
(define-key global-map (kbd "C-x s") 'blackening-region)
(define-key global-map (kbd "C-;") 'comment-dwim)

;; Enable debug
;; (setq debug-on-error t)

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
 '(custom-safe-themes
   '("94bed81ca0be98f58d2cfa2676221c492c8fd5f76b40abd9d73ac00c0d0c9711"
     "de8f2d8b64627535871495d6fe65b7d0070c4a1eb51550ce258cd240ff9394b0"
     "1781e8bccbd8869472c09b744899ff4174d23e4f7517b8a6c721100288311fa5"
     default))
 '(default-input-method "japanese" nil nil "Customized with leaf in `skk' block at `/home/coma/.emacs.d/init.el'")
 '(package-selected-packages '(typst-mode typst-ts-mode))
 '(package-vc-selected-packages
   '((typst-mode :url "https://git.sr.ht/~meow_king/typst-mode")
     (typst-ts-mode :url "https://git.sr.ht/~meow_king/typst-ts-mode")
     (showkey :url "https://github.com/emacsmirror/showkey")
     (hydra-posframe :url "https://github.com/Ladicle/hydra-posframe")
     (typst-preview :url
        "https://github.com/havarddj/typst-preview.el")))
 '(skk-jisyo-edit-user-accepts-editing t))
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
(put 'erase-buffer 'disabled nil)
