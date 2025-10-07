;; -*- lexical-binding: t -*-

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

;; MiniBuffer UI
(leaf vertico
  :require orderless
  :config
  (defvar vertico-count 10)
  ;; Completion style config
  (setq completion-styles '(orderless basic)
	completion-category-overrides '((file (styles basic partial-completion))))
  :init 
  (vertico-mode))

;; Completion Styles
(leaf orderless)

(leaf hotfuzz)

;; Completing read functions
(leaf consult
  :require t
  :after evil
  :bind ((:evil-normal-state-map
          ("C-l" . consult-line)
	  ("SPC i" . consult-buffer)))
  :bind* (("C-." . embark-act)))

(leaf consult-dir)

;; Embark
(leaf embark
  :after evil
  :bind ((:evil-normal-state-map
          ("C-." . embark-act)
          ("C--" . embark-export))
         (:evil-insert-state-map
          ("C-." . embark-act))))

;; affe
(leaf affe)

;; For consult
(leaf embark-consult
  :bind ((:minibuffer-mode-map
          ("M-." . embark-dwin)
          ("C-." . embark-act))))

;; Vim Keybind
(leaf evil
  :require t
  :bind ((:evil-normal-state-map
          ("C-k" . evil-scroll-up)
          ("C-j" . evil-scroll-down))
         (:evil-insert-state-map
	  ;; ("C-j" . newline-and-indent)
          ("C-h" . backward-char)))
  
  :config
  (evil-mode 1))

;; Structured editing 
(leaf puni
  :config
  (global-set-key (kbd "C--") 'puni-expand-region)
  :bind ((:evil-insert-state-map
          ("s" . nil)
	  ;; ("sd" . puni-splice)
          ("C-l" . puni-mark-sexp-at-point)
          ("C-p" . puni-slurp-forward)
          ("C-n" . puni-barf-forward)))
  :init
  (puni-global-mode))

;; Indent guides
(leaf highlight-indent-guides)

;; Treesitter
(leaf treesit
  :custom
  ((treesit-font-lock-level . 4))
  :config
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
  (add-to-list 'auto-mode-alist '(".aiderrules" . markdown-mode))
  (add-to-list 'auto-mode-alist '("Dockerfile" . dockerfile-ts-mode)))

(leaf treesit-auto
  :require t
  :custom
  ((treesit-auto-install . t)
   (treesit-extra-load-path . `(,(expand-file-name "~/.cache/dpp/_generated/nvim-treesitter/parser"))))
  :config  
  (global-treesit-auto-mode)
  ;; (treesit-auto-install 'prompt)
  ;; (treesit-auto-add-to-auto-mode-alist 'all)


  ;; for envrc
  (leaf envrc)

  ;; Calendar 
  (leaf calendar)

  ;; org-mode
  (leaf org
    :after calendar-mode
    :custom
    ((org-todo-keywords .
			'((sequence "TODO(t)" "PENDING(p)" "|" "DONE(d)" "CANCELED(c)")))
     (org-default-notes-file . "notes.org")
     `(org-directory . ,(expand-file-name "~/.ghq/github.com/Comamoca/org"))
     `(diary-file-path . ,(format-time-string "diary/%Y/%m-%d.org"))
     `(memo-file-path . ,(format-time-string "memo/%Y/%m/%d.org"))
     `(diary-path . ,(concat org-directory "/diary"))
     (org-publish-use-timestamps-flag . nil)

     ;; org-capture
     (org-capture-templates .
			    '(("d" "Diary" plain (file diary-file-path)
			       "** 今日やったこと\n\n** 明日以降やりたいこと")
			      ("m" "Memo" plain (file memo-file-path) "")))

     (org-publish-project-alist .
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
				   :html-head "<link rel=\"stylesheet\" href=\"https://unpkg.com/mvp.css\">"))))   
    
    ;;  ;; org-babel
    ;;  (org-confirm-babel-evaluate . nil)
    ;;  (python-shell-interpreter . "python3"))
    :hook
    (org-capture-before-finalize-hook)
    (org-mode . org-nix-shell-mode)
    :config
    (set-language-environment "Japanese")
    (prefer-coding-system 'utf-8)
    (set-default 'buffer-file-coding-system 'utf-8)

    (org-babel-do-load-languages
     'org-babel-load-languages
     '((C . t)
       (shell . t)
       (python . t)
       (clojure . t)
       (hy . t)
       (ruby . t)
       (sparql . t)
       (ledger . t)))
    :bind ((:calendar-mode-map
            ("C-c c" . org-capture-from-calendar))))

  (add-hook 'org-mode-hook
            (lambda ()
              (evil-define-key 'normal org-mode-map (kbd "TAB") #'org-cycle)
	      (evil-define-key 'normal org-mode-map (kbd "C-<return>") (lambda ()
									 (interactive)
									 (vterm-toggle-insert-cd)
									 (vterm-toggle-insert-cd)))))

  ;; org-calendar
  ;; (with-eval-after-load 'calendar
  ;;     (define-key calendar-mode-map (kbd "C-c c") 'org-capture-from-calendar))


  ;; org-journal
  (leaf org-journal
    :after org
    :custom
    ((org-journal-time-format . "")
     (org-journal-time-prefix . "")
     `(org-journal-dir . ,(concat org-directory (format-time-string "/diary/%Y")))
     `(org-journal-file-format . ,(format-time-string "%m-%d.org"))) 
    :hook
    org-journal-after-header-create-hook
    :config
    (add-hook 'org-journal-after-header-create-hook (lambda ()
                                                      (insert-file-contents (concat org-directory "/templates/diary.org")))))


  ;; org-roam
  (leaf org-roam
    :after org
    :custom
    (`(org-roam-directory . ,(expand-file-name "roam" org-directory))
     `(org-roam-db-location . ,(expand-file-name "~/.emacs.d/org-roam/database.db"))
     `(org-roam-index-file . ,(expand-file-name "index.org" org-roam-directory)))
    (org-roam-db-autosync-mode))

  ;; Deft
  ;; For search roam files.
  (leaf deft
    :after org-roam-mode
    :custom
    ((deft-extensions . '("txt" "tex" "org"))
     `(deft-directory . ,(expand-file-name "roam" org-directory))))

  (leaf org-roam-ui)

  ;; org-bullets
  (leaf org-bullets
    :after org)
  ;; :init
  ;; (org-bullets-mode 1)


  ;; org-modern
  (leaf org-modern
    :after
    :init
    (with-eval-after-load 'org (global-org-modern-mode)))

  (leaf org-modern-indent)

  ;; org-babel
  (leaf ob-hy)

  (leaf org-nix-shell)

  ;; Magit
  (leaf magit
    :custom
    ((transient-default-level . 5))
    ;; TODO: magitのコミットバッファに入った時にcorfuを有効化するhookを追加
    :bind ((:global-map
            ("C-x g" . magit-status))
           (:magit-mode-map
            ("/" . isearch-forward))))

  ;; Forge
  (leaf forge
    :ensure t
    :after magit)

  ;; SKK
  (leaf ddskk
    :custom ((default-input-method . "japanease-skk")
             (skk-auto-insert-paren . t)
             (skk-comp-mode . t)
             (skk-delete-implies-kakutei . nil))
    :config
    (skk-latin-mode 1)
    (global-set-key (kbd "C-x C-j") 'skk-mode)
    (global-set-key (kbd "<henkan>") 'skk-kakutei)
    (global-set-key (kbd "<muhenkan>") 'skk-latin-mode))

  (leaf ddskk-posframe
    :global-minor-mode t)

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
    :after cider-mode)

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
    :bind ((:copilot-completion-map
            ("TAB" . copilot-accept-completion)))
    :config
    (add-to-list 'copilot-major-mode-alist '("enh-ruby" . "ruby"))
    (add-to-list 'copilot-major-mode-alist '("typescript-ts-mode" . "typescript")))

  ;; LSP
  (leaf lsp-bridge
    :require t
    :custom
    ((acm-enable-capf . t)
     (lsp-bridge-nix-lsp-server . "nil"))
    :config
    ;; (setq lsp-bridge-multi-lang-server-extension-list
    ;; 	(cl-remove-if (lambda (item)
    ;; 			(equal (car item) '("ts" "tsx")))
    ;;                     lsp-bridge-multi-lang-server-extension-list))

    ;; (setq lsp-bridge-multi-lang-server-extension-list
    ;; 	(mapcar (lambda (item)
    ;; 		  (cond
    ;; 		   ((equal )))) lsp-bridge-multi-lang-server-extension-list))

    ;; (when (file-exists-p (expand-file-name "package.json" project-path))
    ;; 	    "typescript-language-server"
    ;; 	    "deno")

    (defun lsp-bridge-setup-for-ts-js-mode ()
      (setq lsp-bridge-get-single-lang-server-by-project
	    (lambda (project-path file-path)
	      (let* ((ext (file-name-extension (or buffer-file-name "")))
		     (is-ts-file (or (= ext "ts") (= ext "tsx")))
		     (is-js-file (or (= ext "js") (= ext "jsx"))))
		(if (and (or is-ts-file is-js-file)  (file-exists-p (expand-file-name "package.json" project-path)))
		    "typescript-language-server"
		  "deno")
		))))

    (add-hook 'typescript-ts-mode 'lsp-bridge-setup-for-ts-js-mode)
    (add-hook 'javascript-mode 'lsp-bridge-setup-for-ts-js-mode)

    ;; (setq lsp-bridge-get-single-lang-server-by-project
    ;; 	(lambda (project-path file-path)
    ;; 	  (when (or (string-suffix-p ".ts" file-path)
    ;; 		    (string-suffix-p ".tsx" file-path))
    ;; 	    "deno")))

    :init 
    ;; (global-lsp-bridge-mode)
    )

  ;; lso-mode
  (leaf lsp-mode
    :require t
    :custom
    ((lsp-completion-provider . :none))
    :config
    (setq lsp-idle-delay 1.0)
    (setenv "LSP_USE_PLISTS" "true") 

    (define-key evil-normal-state-map (kbd "K") 'lsp-ui-doc-glance)

    (add-to-list 'lsp-language-id-configuration
		 '(nix-mode . "nil")
		 '(python-mode . "python"))

    (defun corfu-lsp-setup ()
      (setq completion-at-point-functions '(lsp-completion-at-point))
      (setq-local completion-styles '(orderless)
		  completion-category-defaults nil))

    ;; (add-hook 'lsp-mode-hook #'corfu-lsp-setup)
    ;; (add-hook 'prog-mode-hook #'lsp-deferred)
    (with-eval-after-load 'lsp-mode
      (add-to-list 'lsp-disabled-clients 'semgrep-ls))
    )

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

  ;; Eglot
  (defun deno-project-p ()
    "Predicate for determining if the open project is a Deno one."
    (let ((p-root (nth 2 (project-current))))
      (or (file-exists-p (expand-file-name "deno.json" default-directory))
	  (file-exists-p (expand-file-name "deno.jsonc" default-directory)))))

  (defun node-project-p ()
    "Predicate for determining if the open project is a Deno one."
    (let ((p-root (nth 2 (project-current))))
      (file-exists-p (expand-file-name "package.json" default-directory))))

  (defun es-server-program (_)
    "Decide which server to use for ECMA Script based on project characteristics."
    (cond ((deno-project-p) '("lspx" "--lsp" "deno" "lsp" :initializationOptions (:enable t :lint t)))
          ((node-project-p) '("lspx" "--lsp" "typescript-language-server" "--stdio"))
          (t nil)))

  (leaf eglot
    :hook
    (c++-mode . eglot-ensure)
    (sh-mode . eglot-ensure)
    (python-mode . eglot-ensure)
    (html-mode . eglot-ensure)
    (cmake-mode . eglot-ensure)
    (bitbake-mode . eglot-ensure)
    (typescript-ts-mode . eglot-ensure)
    :config
    ;; (add-to-list 'eglot-server-programs '((bitbake-mode) "bitbake-language-server"))
    ;; (add-to-list 'eglot-server-programs '((js-mode typescript-mode) . es-server-program))
    ;; (add-to-list 'eglot-server-programs '(gleam-ts-mode . ("lspx" "--lsp" "gleam lsp")))

    (setq eglot-server-programs
          (append
           '(
	     (haskell-mode . ("haskell-language-server-wrapper"))
	     (gleam-ts-mode . ("lspx" "--lsp" "gleam lsp")))
           eglot-server-programs))

    :bind (("M-t" . xref-find-definitions)
           ("M-r" . xref-find-references)
           ("C-t" . xref-go-back)))

  ;; (leaf eglot-booster
  ;;   :after eglot
  ;;   ;; :init (eglot-booster-mode)
  ;;   )

  ;; Auto Formatting
  (leaf reformatter
    :config 
    (reformatter-define dprint
      :program "dprint" :args `("fmt" "--stdin" ,buffer-file-name))
    (reformatter-define gleam
      :program "gleam" :args `("format" "--stdin"))
    (reformatter-define deno
      :program "deno" :args `("fmt" ,buffer-file-name))
    (reformatter-define black
      :program "black" :args '("-"))
    (reformatter-define nixfmt
      :program "nixfmt-rfcstyle" :args '("-")))

  ;; Lua support
  (leaf lua-mode)

  ;; Completion
  (leaf corfu
    :custom
    ((corfu-cycle . t)
     (corfu-auto . t )
     (corfu-auto-prefix . 1))

    :config
    (with-eval-after-load 'corfu
      (define-key corfu-map (kbd "C-n") #'corfu-next)
      (define-key corfu-map (kbd "C-p") #'corfu-previous))

    :init
    (global-corfu-mode))

  ;; Cursor moation
  (leaf avy
    :config
    (define-key evil-normal-state-map (kbd "SPC k") #'avy-goto-line))

  ;; Completion soruce
  (leaf cape
    :after corfu)


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

  ;; Projectile
  (leaf projectile
    :require t
    :config
    (projectile-mode +1)
    :bind ((:projectile-mode-map
            ("C-c p" . projectile-command-map))))

  ;; Tree filer
  (leaf neotree
    :custom
    (neo-smart-open . t)
    (neo-autorefresh . t)
    (neo-auto-indent-point . t)
    (neo-show-updir-line . nil)
    (projectile-switch-project-action . 'neotree-projectile-action)
    :config
    (progn
      (add-hook 'find-file-hook (lambda ()
                                  (when (and (buffer-file-name)
                                             (get-buffer "*NeoTree*")
                                             (projectile-project-p))
                                    (neotree-dir (projectile-project-root)))))
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
  (add-hook 'server-after-make-frame-hook
            (lambda ()
              (setq wakatime-api-key (get-secret "wakatime"))))

  (leaf wakatime-mode
    :config
    (setq wakatime-cli-path (string-trim (shell-command-to-string "which wakatime-cli")))
    :init
    (global-wakatime-mode))

  ;; Typst
  (leaf typst-ts-mode
    :hook (typst-mode-hook . typst-ts-mode))

  ;; Preview
  (leaf typst-preview
    ;; :vc (:url "https://github.com/havarddj/typst-preview.el")
    ;; :require t
    :config
    (setq typst-preview-browser "firefox"))

  ;; Ruby support
  (leaf inf-ruby)

  (leaf enh-ruby-mode)

  ;; php-mode
  (leaf php-mode)

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
  (leaf gleam-ts-mode
    :require t
    :hook gleam-on-save-mode)

  ;; Markdown suppot
  (leaf markdown-mode
    :bind
    (:markdown-mode-map
     (("<Tab>" . markdown-cycle)))
    :hook
    (markdown-mode . (lambda ()
		       (setq-local completion-at-point-functions
				   (cons #'cape-emoji completion-at-point-functions)))))

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
    :require t
    :bind ((:evil-insert-state-map
            ("M-a" . tempel-done)))
    :config 
    (defun tempel-setup-capf ()
      (setq-local completion-at-point-functions
		  (cons #'tempel-complete
			completion-at-point-functions)))

    (add-hook 'conf-mode-hook 'tempel-setup-capf)
    (add-hook 'prog-mode-hook 'tempel-setup-capf)
    (add-hook 'text-mode-hook 'tempel-setup-capf)

    (add-hook 'markdown-mode-hook (lambda ()
                                    (setq-local completion-at-point-functions #'tempel-complete)))

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

  (leaf editorconfig
    :config
    (editorconfig-mode 1))

  (leaf ledger
    :config)

  (leaf grugru
    :require t
    :after evil
    :bind ((:evil-normal-state-map
            ("C-a" . grugru))
           (:evil-normal-state-map
            ("C-x" . grugru-backward)))
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
	 (number-to-string (if rev (- num 1) (+ num 1)))))))

  (leaf good-scroll
    :init
    (good-scroll-mode 1))

  (leaf sublimity)

  (leaf iscroll)

  (leaf folding-mode
    :require t)

  (leaf rg
    :require t)

  (leaf open-junk-file
    :require t
    :custom
    (open-junk-file-format . "/tmp/junk/%Y_%m_%d_%H%M%S.")
    :bind (("C-x j" . open-junk-file)))

  (leaf fold-this)

  (leaf alert
    :config
    (setq alert-default-style 'libnotify))

  (leaf dashboard
    :config
    (setq dashboard-startup-banner (expand-file-name "~/Pictures/.emacs-logos/gnu_color_resize.png"))
    (setq dashboard-startup-banner 'logo))

  (leaf aas
    ;; :hook (text-mode . aas-activate-for-major-mode)
    :init
    (aas-set-snippets 'global)
    (aas-set-snippets 'markdown-mode)
    (aas-set-snippets 'prog-mode))

  (leaf smartparens
    :config
    (smartparens-global-mode t))

  (leaf vterm
    :config
    (evil-define-key 'insert vterm-mode-map (kbd "C-l") 'vterm-clear))

  (leaf vterm-toggle
    :after evil
    :bind (("C-<return>" . (lambda ()
                             (interactive)
                             (vterm-toggle)
                             (vterm-toggle-insert-cd)))))

  (leaf multi-vterm
    :config
    (setq multi-vterm-dedicated-window-height 50))

  ;; AI
  (add-hook 'server-after-make-frame-hook
            (lambda ()
              (setenv "GEMINI_API_KEY" (get-secret "gemini.google.com"))
              (setenv "OPENROUTER_API_KEY" (get-secret "openrouter.ai"))
              (setq wakatime-api-key (get-secret "wakatime"))
	      (setq openrouter-apikey (get-secret "openrouter.ai"))
              (setq gemini-apikey (get-secret "gemini.google.com"))
	      (setq figma-apikey (get-secret "figma-apikey"))))

  ;; ECA
  (leaf eca
    :require t
    :custom
    ((eca-custom-command "~/.bin/eca"))
    :config)

  ;; (leaf mcp
  ;;   :after gptel
  ;;   :require t)

  ;; (leaf gptel-integration
  ;;   :after mcp
  ;;   :require t)

  ;; (require 'gptel)

  ;; (require 'gptel-integration)

  (leaf gptel
    :config
    ;; (setq
    ;;  gptel-model 'starcoder2
    ;;  gptel-backend (gptel-make-ollama "Ollama"
    ;;                 :host "localhost:11434"
    ;;                 :stream t
    ;;                 :models '(starcoder2)))

    ;; (setq
    ;;  gptel-model 'gemini-2.5-flash
    ;;  gptel-backend (gptel-make-gemini "Gemini"
    ;;                  :key gemini-apikey
    ;;                  :stream t))  

    (setq gptel-model 'openai/gpt-4.1
	  gptel-backend (gptel-make-openai "OpenRouter"
			  :host "openrouter.ai"
			  :endpoint "/api/v1/chat/completions"
			  :stream t
			  :key openrouter-apikey
			  :models '(openai/gpt-4o-search-preview
				    openai/gpt-4.1
				    openai/gpt-3.5-turbo 
				    google/palm-2-codechat-bison-32k
				    google/gemini-pro)))

    (gptel-make-tool
     :function (lambda (filepath)
		 (with-temp-buffer
		   (insert-file-contents (expand-file-name filepath))
		   (buffer-string)))
     :name "read_file"
     :description "Read and display the contents of a file"
     :args (list '(:name "filepath"
			 :type string
			 :description "Path to the file to read. Supports relative paths and ~."))
     :category "filesystem")

    (gptel-make-tool
     :function (lambda (url)
		 (with-current-buffer (url-retrieve-synchronously url)
		   (goto-char (point-min))
		   (forward-paragraph)
		   (let ((dom (libxml-parse-html-region (point) (point-max))))
                     (run-at-time 0 nil #'kill-buffer (current-buffer))
                     (with-temp-buffer
                       (shr-insert-document dom)
                       (buffer-substring-no-properties (point-min) (point-max))))))
     :name "read_url"
     :description "Fetch and read the contents of a URL"
     :args (list '(:name "url"
			 :type string
			 :description "The URL to read"))
     :category "web")

    (gptel-make-tool
     :function (lambda (filepath)
		 (with-temp-buffer
		   (insert-file-contents (expand-file-name filepath))
		   (buffer-string)))
     :name "read_file"
     :description "Read and display the contents of a file"
     :args (list '(:name "filepath"
			 :type string
			 :description "Path to the file to read. Supports relative paths and ~."))
     :category "filesystem"))

  (leaf gptel-integrations
    :require t
    :after gptel
    :init
    (require 'gptel-integrations))

  ;; AI codeing
  (leaf aider
    :require t
    :custom
    ((aider-args . '("--watch-files" "--model" "gemini/gemini-2.0-flash"))))

  (leaf aidermacs
    :require t
    :config
    (setq aidermacs-watch-files t)
    (setq aidermacs-extra-args '("--yes-always"))

    :custom
    ((aidermacs-default-model . "openrouter/anthropic/claude-3.7-sonnet")
     (setq aidermacs-backend 'vterm)
     (aidermacs-watch-files . t)))

  ;; (aidermacs-default-model . "gemini/gemini-2.5-flash-preview-04-17")


  (leaf mcp-hub
    :require t
    :config
    (let ((figma-api-key (concat "--figma-api-key=" figma-apikey))
	  (home (getenv "HOME")))
      (setq mcp-hub-servers
	    `(("filesystem" . (:command "npx" :args ("-y" "@modelcontextprotocol/server-filesystem" ,home)))
              ("fetch" . (:command "uvx" :args ("mcp-server-fetch")))
	      ("awesome-yasunori" . (:command "npx" :args ("mcp-remote" "https://api.yasunori.dev/awesome/mcp")))
	      ("imasparql" . (:command "npx" :args ("mcp-remote" "https://gitmcp.io/imas/imasparql")))
	      ("figma" . (:command "npx" :args ("-y" "figma-developer-mcp" ,figma-api-key "--stdio")))
	      ("claude_code" . (:command "claude" :args ("mcp" "serve")))
	      ("serena" . (:command "uvx" :args ("--from" "git+https://github.com/oraios/serena" "serena" "start-mcp-server"))))))

    ;; :hook (server-after-make-frame-hook . #'mcp-hub-start-all-server)
    )


  (leaf minimap
    :require t
    :custom ((minimap-window-location . 'right)
             (minimap-minimum-width . 20)
             (minimap-major-modes . '(prog-mode
                                      markdown-mode
                                      html-mode
                                      fundamental-mode)))
    :bind ("C-x m" . minimap-mode)
    :config
    (minimap-mode 1))

  (leaf rainbow-delimiters
    :hook
    (prog-mode-hook . rainbow-delimiters-mode))

  (leaf ox-zenn
    :after org
    :require t ox-publish
    :defun zenn/f-parent org-publish
    :defvar org-publish-project-alist
    :preface
    (defvar zenn/org-dir "~/.ghq/github.com/Comamoca/zenn/org")

    (defun zenn/org-publish (arg)
      "Publish zenn blog files."
      (interactive "P")
      (let ((force (or (equal '(4) arg) (equal '(64) arg)))
            (async (or (equal '(16) arg) (equal '(64) arg))))
	(org-publish "zenn" arg force async)))

    :config
    (setf
     (alist-get "zenn" org-publish-project-alist nil nil #'string=)
     (list
      :base-directory (expand-file-name "" zenn/org-dir)
      :base-extension "org"
      :publishing-directory (expand-file-name "../" zenn/org-dir)
      :recursive t
      :publishing-function 'org-zenn-publish-to-markdown)))

  (leaf verb)

  (leaf quickrun
    :require t)

  (leaf smartchr
    :require t
    :config
    (define-key evil-insert-state-map (kbd ">")
		(smartchr '( ">" "-> " "|>" "<>" "<-" ))))

  (add-hook 'server-after-make-frame-hook
	    (lambda ()
	      (setq smudge-oauth2-client-secret (get-secret "spotify-secret"))
	      (setq smudge-oauth2-client-id (get-secret "spotify-id"))))

  (leaf smudge
    :require t)

  (leaf ox-typst
    :after org-mode)

  ;; Claude code
  (leaf claude-code
    :require t
    :config
    (claude-code-mode)
    :hook
    ((claude-code--start . sm-setup-claude-faces))
    :init
    (claude-code-mode))

  (leaf claude-shell
    :require t
    :config
    (setq claude-shell-api-token (get-secret "openrouter.ai")))

  (leaf dirvish)

  (leaf sparql-mode)

  (leaf claudemacs
    :require t
    :bind ((:evil-normal-state-map
            ("SPC c" . claudemacs-transient-menu))))

  (leaf exec-path-from-shell
    :require t
    :init
    (exec-path-from-shell-initialize))

  (leaf zenn-cli
    :require t
    :config
    (defcustom zenn-cli-command "npx"
      "Command to execute Zenn CLI"
      :type 'string
      :group 'zenn-cli)

    (defcustom zenn-cli-subcommand "zenn"
      "Zenn CLI subcommand"
      :type 'string
      :group 'zenn-cli)
    (setq zenn-cli-command "/usr/local/bin/zenn")
    (setq zenn-cli-subcommand "")
    :custom ((zenn-cli-default-directory . "~/.ghq/github.com/Comamoca/zenn")))

  (leaf emmet-mode
    :config
    (evil-define-key 'insert emmet-mode-keymap (kbd "C-l") 'emmet-expand-line)
    :hook
    (html-ts-mode . emmet-mode))

  (leaf tabspace-mode
    :require t)

  (leaf elscreen
    :require t)

  (leaf apheleia
    :require t
    :init
    (apheleia-global-mode +1))

  (leaf gerbil-mode
    :hook ((inferior-scheme-mode-hook . gambit-inferior-mode))
    :require t)

  ;; ================ My extentions ================

  (defun my/set-pwd-to-project-root ()
    "Set `default-directory` to the root of the current project."
    (when-let ((project (project-current)))
      (setq default-directory (project-root project))))

  (add-hook 'find-file-hook #'my/set-pwd-to-project-root)


  (defun window-resizer ()
    "Control window size and position."
    (interactive)
    (let ((window-obj (selected-window))
          (current-width (window-width))
          (current-height (window-height))
          (dx (if (= (nth 0 (window-edges)) 0) 1
		-1))
          (dy (if (= (nth 1 (window-edges)) 0) 1
		-1))
          action c)
      (catch 'end-flag
	(while t
          (setq action
		(read-key-sequence-vector (format "size[%dx%d]"
                                                  (window-width)
                                                  (window-height))))
          (setq c (aref action 0))
          (cond ((= c ?l)
		 (enlarge-window-horizontally dx))
		((= c ?h)
		 (shrink-window-horizontally dx))
		((= c ?j)
		 (enlarge-window dy))
		((= c ?k)
		 (shrink-window dy))
		;; otherwise
		(t
		 (let ((last-command-char (aref action 0))
                       (command (key-binding action)))
                   (when command
                     (call-interactively command)))
		 (message "Quit")
		 (throw 'end-flag t)))))))

  ;; Modules

  ;; workspace.el
  ;; (setq my-workspace-project-backend 'project)
  ;; (setq  my-workspace-auto-update t)
  ;; (load (expand-file-name "workspace.el" (f-parent user-init-file)))

  ;; Functions
  (defun ghq-create-project (prpject-name)
    (interactive "sghq directory name: ")
    (let ((cmd (mapconcat #'shell-quote-argument
			  (list "ghq" "create" prpject-name)
			  " ")))
      (shell-command-to-string cmd)))

  (defun is-node-project ()
    (file-exists-p (expand-file-name "package.json" (project-root (project-current)))))

  (defun get-secret (host)
    "Wrapper functino for auth-info"
    (require 'ht) 
    (let* ((found (cl-first (auth-source-search :host host
						:user "coma")))
           (credentials (when found
			  (eval `(ht ,@(--map `(,it ,(plist-get found it))
                                              '(:user :secret :save-function))))))
           (secret (when credentials
                     (ht-get credentials :secret))))

      (if (not secret)
	  (progn (message (format "Does not found %s credential." host))
		 "")
	(if (functionp secret)
            (funcall secret)
	  secret))))

  (defun nyan-region ()
    "選択範囲をにゃーんで置換する"
    (interactive)
    (when (use-region-p)
      (let* ((beg (region-beginning))
             (end (region-end))
             (len (- end beg)))
	(delete-region beg end)
	(cond
	 ((= len 1) (insert "にゃ"))
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
      (shell-command (concat "open " "'" url "'")))))

(defun home-manager ()
  (interactive)
  (start-process "home-manager-process"
		 "*home-manager*"
		 "home-manager"
		 "switch"
		 "--flake"
		 ".#Home"
		 "--impure"
		 "-b"
		 "backup"))

;; (set-process-sentinel proc
;;                           (lambda (process event)
;;                             (when (string= event "finished\n"))))

(defun all (pred lst)
  "Returns t if all elements of the list satisfy the predicate."
  (catch 'done
    (dolist (item lst t)
      (unless (funcall pred item)
        (throw 'done nil)))))

(defun setup-gitmoji-data ()
  (require 'digs)
  (let* ((gitmoji-file-path (expand-file-name "~/.data/gitmoji.json"))
         (json-data (with-temp-buffer
		      (insert-file-contents gitmoji-file-path)
		      (json-parse-string (buffer-string) :object-type 'hash-table)))
         (gitmoji-codes (make-hash-table)))
    (mapcar (lambda (item) 
	      (substring (digs-hash item "code") 1))
	    (digs-hash json-data "gitmojis"))))

(defun setup-gitmoji ()
  (interactive)
  (unless (boundp 'gitmoji--codes) 
    (setq gitmoji--codes (setup-gitmoji-data)))
  gitmoji--codes)

(setup-gitmoji)
(defun gitmoji-completion ()
  (let ((beg (save-excursion (skip-chars-backward "a-zA-Z") (point)))
        (end (point))
        (candidates gitmoji--codes))
    (list beg end candidates :exclusive 'no)))

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

(defun date-to-tempalte (year month day)
  (let* ((time (encode-time 0 0 0 day month year))
	 (yymmdd (format-time-string "%Y-%m-%d" time))
	 (date (format-time-string "%-m/%-d" time))
	 (us-date (format-time-string "%b %-d %Y" time))
	 (tmpl `("---"
		 ,(format "title: '%sの日報'" yymmdd)
		 ,(format "description: '%sの日報をお届けいたします。'" date)
		 ,(format "pubDate: '%s'" us-date)
		 "emoji: 🦊"
		 "tags: []"
		 "draft: false"
		 "---"
		 "\n"
		 "## 今日やったこと"
		 "\n"
		 "## 明日以降やりたいこと")))
    (mapconcat #'identity tmpl "\n")))

(defun create-diary-path (year month day)
  (let* ((time (encode-time 0 0 0 day month year))
	 (date-str (format-time-string "%Y-%m-%d" time))
	 (file-name (format "%s-diary.md" date-str))
	 (path (concat (expand-file-name "src/blog/" blog-repo) file-name))) 
    path))

(defun create-and-insert-diary (path text)
  (find-file path)
  (if (= (buffer-size) 0)
      (insert text)))

;; calendar-modeで選んだ日付から日報を作る
(defun create-diary-from-calendar ()
  (interactive)
  (let* ((date (calendar-cursor-to-date))
	 ;; (9 14 2025)
	 (month (nth 0 date))
	 (day (nth 1 date))
	 (year (nth 2 date))
	 (path (create-diary-path year month day))
	 (template (date-to-tempalte year month day)))

    (create-and-insert-diary path template)))

;; 今日の日付で日報を作る
(defun latest-diary ()
  "Open latest diary. This function call in `src/blog/` directory at blog repository."
  (interactive)
  (let* ((now (current-time))
	 (decoded (decode-time now))
	 (day    (nth 3 decoded))
	 (month  (nth 4 decoded))
	 (year   (nth 5 decoded)) 
	 (path (create-diary-path year month day))
	 (template (date-to-tempalte year month day)))
    (create-and-insert-diary path template)))

(defun new-blog-article ()
  "Open latest diary. This function call in `src/blog/` directory at blog repository."
  (interactive)
  (let* ((date (format-time-string "%Y-%m-%d"))
         (slug (read-string "slug > "))
         (file-name (format "%s-%s.md" date slug))
         (path (concat (expand-file-name "src/blog/" blog-repo) file-name)))
    ;; (projectile-switch-project-by-name "blog")
    (find-file path)
    (if (= (buffer-size) 0)
	(tempel-insert 'article))))

(defun consult-diary ()
  (interactive)
  (let* ((src-dir (expand-file-name "src/blog" blog-repo))
         (files (directory-files src-dir))
         (articles (cl-remove-if-not (lambda (file)
				       (string-match "-diary.md$" file))
				     files))
         (selected (completing-read "blog " articles)))
    (find-file (expand-file-name selected src-dir))))

(defun consult-article ()
  (interactive)
  (let* ((src-dir (expand-file-name "src/blog" blog-repo))
         (files (directory-files src-dir))
         (articles (cl-remove-if (lambda (file)
                                   (string-match "-diary.md$" file))
                                 files)) 
         (selected (completing-read "blog " articles)))
    (find-file (expand-file-name selected src-dir)))) 

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
  (setq fullpath (concat
                  (expand-file-name (format-time-string "%Y-%m-%d-%H%M%S")
				    "~/.ghq/github.com/Comamoca/blog/src/img") ".png"))
  (shell-command (concat  "wl-paste -t image/png > " fullpath))
  (insert (concat "![](/img/" (file-name-nondirectory fullpath) ")"))
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
                               (cons (org-roam-node-title node) node))
                             (org-roam-node-list)))
         (select-node-title (consult--read
                             (mapcar #'car node-items)))
         (select-node (cdr (assoc select-node-title node-items))))
    (find-file (org-roam-node-file select-node))))

;; Pinentry Emacs
(defun pinentry-emacs (desc prompt ok error)
  (let ((str (read-passwd (concat (replace-regexp-in-string "%22" "\"" (replace-regexp-in-string "%0A" "\n" desc)) prompt ": "))))
    str))

;; initel function that behaves like `:e $MYVIMRC`
(defun initel ()
  (interactive)
  (find-file user-init-file))

(defun toggle-truncate-lines ()
  "折り返し表示をトグル動作します."
  (interactive)
  (if truncate-lines
      (setq truncate-lines nil)
    (setq truncate-lines t))
  (recenter))


;; ================ My configuratons ================

;; Enable auto revert
(global-auto-revert-mode 1)

;; load-path
(add-to-list 'load-path "~/.emacs.d/lisp/my-package")

;; Ediff
(setq ediff-window-setup-function 'ediff-setup-windows-plain)

;; Font
(add-to-list 'default-frame-alist
             '(font . "UDEV Gothic NF-14"))

;; For auth-info
(setq auth-sources '("~/.emacs.d/.authinfo.gpg"))
(setq create-lockfiles nil)

;; For lsp-mode
(setq gc-cons-threshold 100000000)
(setq read-process-output-max (* 1024 1024))

;; Key mapping
(evil-define-key 'normal 'global (kbd "C-o") 'projectile-find-file)
(evil-define-key 'normal 'global (kbd "SPC l") #'toggle-truncate-lines)
(global-set-key (kbd "C-c C-r") 'window-resizer)


(define-key global-map (kbd "M-g") 'consult-ghq-find)
(define-key global-map (kbd "C-x s") 'blackening-region)
(define-key global-map (kbd "C-;") 'comment-dwim)
(define-key evil-insert-state-map (kbd "C-h") #'my/minibuffer-backspace)

;; minibuffer
(defun my/minibuffer-backspace ()
  (interactive)
  (delete-backward-char 1))

(define-key minibuffer-local-map (kbd "C-h") #'my/minibuffer-backspace)
(define-key minibuffer-local-ns-map (kbd "C-h") #'my/minibuffer-backspace)
(define-key minibuffer-local-completion-map (kbd "C-h") #'my/minibuffer-backspace)
(define-key minibuffer-local-must-match-map (kbd "C-h") #'my/minibuffer-backspace)
(define-key minibuffer-local-isearch-map (kbd "C-h") #'my/minibuffer-backspace)

;; Enable debug
(setq debug-on-error nil)

;; Custom modeline
(mode-line-format-update)

;; When org-mode
(add-hook 'org-mode
	  (lambda ()
	    (local-set-key evil-insert-state-map (kbd "C-h") #'org-insert-heading)))

(add-hook 'org-mode-hook
          (lambda ()
            (add-hook 'after-save-hook
		      (lambda ()
			(when (file-exists-p (concat (file-name-sans-extension (buffer-file-name)) ".html"))
			  (org-html-export-to-html))
                        
			(when (file-exists-p (concat (file-name-sans-extension (buffer-file-name)) ".md"))
			  (org-md-export-to-markdown)))
		      
		      
		      nil t)))


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
(put 'narrow-to-region 'disabled nil)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(aas ace-window acm affe aidermacs alert all-the-icons apheleia
	 astro-ts-mode calfw calfw-cal calfw-gcal calfw-ical calfw-org
	 cape catppuccin-theme cider-eval-sexp-fu cider-hydra
	 consult-gh-forge consult-ghq corfu dashboard ddskk-posframe
	 deft dimmer direnv dotnet eat editorconfig eldoc-box
	 elixir-mode embark-consult enh-ruby-mode envrc evil-ledger
	 evil-smartparens flycheck-inline flycheck-ledger
	 flycheck-pos-tip focus gleam-ts-mode gnuplot gnuplot-mode
	 god-mode good-scroll google-translate gptel grugru
	 haskell-mode highlight-indent-guides hotfuzz inf-elixir
	 inf-ruby iscroll kaocha-runner kind-icon leaf-convert
	 leaf-tree lsp-bridge lsp-ui lua-mode major-mode-hydra migemo
	 minimap mix multi-vterm nano-box nano-journal nano-modeline
	 nano-popup nano-read nano-theme neotree nix-mode nix-ts-mode
	 nyan-mode oauth2 ob-hy open-junk-file orderless org-journal
	 org-modern org-nix-shell org-roam-ui ox-typst ox-zenn plz
	 projectile puni reformatter request rg ruby-electric
	 scala-mode scala-ts-mode sharper shell-maker slime sly-asdf
	 sublimity tempel-collection transient-dwim treesit-auto
	 undo-tree vertico vterm-toggle wakatime-mode web-mode
	 yasnippet-capf yasnippet-snippets yatemplate))
 '(skk-jisyo-edit-user-accepts-editing t))
(custom-set-faces)
;; custom-set-faces was added by Custom.
;; If you edit it by hand, you could mess it up, so be careful.
;; Your init file should contain only one such instance.
;; If there is more than one, they won't work right.

;; custom-set-faces was added by Custom.
;; If you edit it by hand, you could mess it up, so be careful.
;; Your init file should contain only one such instance.
;; If there is more than one, they won't work right. 
