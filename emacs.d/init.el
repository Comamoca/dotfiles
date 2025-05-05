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

;; theme
(leaf catppuccin-theme 
  :preface
  :config
  (load-theme 'catppuccin t))

;; minibuffer ui
(leaf vertico
  :require orderless
  :config
  (defvar vertico-count 10)
  ;; completion style config
  (setq completion-styles '(orderless basic)
	completion-category-overrides '((file (styles basic partial-completion))))
  :init 
  (vertico-mode))

;; completion styles
(leaf orderless)

(leaf hotfuzz)

;; completing read functions
(leaf consult
  :require t
  :after evil
  :bind ((:evil-normal-state-map
	  ("c-l" . consult-line)
	  ("c-i" . consult-buffer)))
  :bind* (("c-." . embark-act)))

(leaf consult-dir)

;; embark
(leaf embark
  :after evil
  :bind ((:evil-normal-state-map
	  ("c-." . embark-act)
	  ("c--" . embark-export))
	 (:evil-insert-state-map
	  ("c-." . embark-act))))

;; affe
(leaf affe)

;; for consult
(leaf embark-consult
  :bind ((:minibuffer-mode-map
	  ("m-." . embark-dwin)
	  ("c-." . embark-act))))

;; vim keybind
(leaf evil
  :require t
  :bind ((:evil-normal-state-map
	  ("c-k" . evil-scroll-up)
	  ("c-j" . evil-scroll-down))
	 (:evil-insert-state-map
	  ;; ("c-j" . newline-and-indent)
	  ("c-h" . backward-char)))
;; -*- lexical-binding: t -*-
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

;; theme
(leaf catppuccin-theme 
  :preface
  :config
  (load-theme 'catppuccin t))

;; minibuffer ui
(leaf vertico
  :require orderless
  :config
  (defvar vertico-count 10)
  ;; completion style config
  (setq completion-styles '(orderless basic)
	completion-category-overrides '((file (styles basic partial-completion))))
  :init 
  (vertico-mode))

;; completion styles
(leaf orderless)

(leaf hotfuzz)

;; completing read functions
(leaf consult
  :require t
  :after evil
  :bind ((:evil-normal-state-map
	  ("c-l" . consult-line)
	  ("c-i" . consult-buffer)))
  :bind* (("c-." . embark-act)))

(leaf consult-dir)

;; embark
(leaf embark
  :after evil
  :bind ((:evil-normal-state-map
	  ("c-." . embark-act)
	  ("c--" . embark-export))
	 (:evil-insert-state-map
	  ("c-." . embark-act))))

;; affe
(leaf affe)

;; for consult
(leaf embark-consult
  :bind ((:minibuffer-mode-map
	  ("m-." . embark-dwin)
	  ("c-." . embark-act))))

;; vim keybind
(leaf evil
  :require t
  :bind ((:evil-normal-state-map
	  ("c-k" . evil-scroll-up)
	  ("c-j" . evil-scroll-down))
	 (:evil-insert-state-map
	  ;; ("c-j" . newline-and-indent)
	  ("c-h" . backward-char)))
 
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

;; theme
(leaf catppuccin-theme 
  :preface
  :config
  (load-theme 'catppuccin t))

;; minibuffer ui
(leaf vertico
  :require orderless
  :config
  (defvar vertico-count 10)
  ;; completion style config
  (setq completion-styles '(orderless basic)
	completion-category-overrides '((file (styles basic partial-completion))))
  :init 
  (vertico-mode))

;; completion styles
(leaf orderless)

(leaf hotfuzz)

;; completing read functions
(leaf consult
  :require t
  :after evil
  :bind ((:evil-normal-state-map
	  ("c-l" . consult-line)
	  ("c-i" . consult-buffer)))
  :bind* (("c-." . embark-act)))

(leaf consult-dir)

;; embark
(leaf embark
  :after evil
  :bind ((:evil-normal-state-map
	  ("c-." . embark-act)
	  ("c--" . embark-export))
	 (:evil-insert-state-map
	  ("c-." . embark-act))))

;; affe
(leaf affe)

;; for consult
(leaf embark-consult
  :bind ((:minibuffer-mode-map
	  ("m-." . embark-dwin)
	  ("c-." . embark-act))))

;; vim keybind
(leaf evil
  :require t
  :bind ((:evil-normal-state-map
	  ("c-k" . evil-scroll-up)
	  ("c-j" . evil-scroll-down))
	 (:evil-insert-state-map
	  ;; ("c-j" . newline-and-indent)
	  ("c-h" . backward-char)))
 
  :config
  (evil-mode 1))

;; structured editing 
(leaf puni
  :config
  (global-set-key (kbd "c--") 'puni-expand-region)
  :bind ((:evil-insert-state-map
	  ("s" . nil)
	  ;; ("sd" . puni-splice)
	  ("c-i" . puni-mark-sexp-at-point)
	  ("c-p" . puni-slurp-forward)
	  ("c-n" . puni-barf-forward)))
  :init
  (puni-global-mode))

;; indent guides
(leaf highlight-indent-guides)

;; treesitter
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
  (add-to-list 'auto-mode-alist '("dockerfile" . dockerfile-ts-mode)))

(leaf treesit-auto
  :require t
  :custom
  ((treesit-auto-install . t)
   (treesit-extra-load-path . `(,(expand-file-name "~/.cache/dpp/_generated/nvim-treesitter/parser"))))
  :config  
  (global-treesit-auto-mode)
  ;; (treesit-auto-install 'prompt)
  ;; (treesit-auto-add-to-auto-mode-alist 'all)
  )

;; for envrc
(leaf envrc)

;; calendar 
(leaf calendar)

;; org-mode
(leaf org
  :after calendar-mode
  :custom
  ((org-todo-keywords .
		      '((sequence "todo(t)" "pending(p)" "|" "done(d)" "canceled(c)")))
   (org-default-notes-file . "notes.org")
   `(org-directory . ,(expand-file-name "~/.ghq/github.com/comamoca/org"))
   `(diary-file-path . ,(format-time-string "diary/%y/%m-%d.org"))
   `(memo-file-path . ,(format-time-string "memo/%y/%m/%d.org"))
   `(diary-path . ,(concat org-directory "/diary"))
   (org-publish-use-timestamps-flag . nil)

   ;; org-capture
   (org-capture-templates .
			  '(("d" "diary" plain (file diary-file-path)
			     "** 今日やったこと\n\n** 明日以降やりたいこと")
			    ("m" "memo" plain (file memo-file-path) "")))

   (org-publish-project-alist .
			      '(("diary"
				 :base-directory "~/.ghq/github.com/comamoca/org/diary"
				 :base-extension "org"  
				 :recursive t
				 :publishing-directory  "~/.ghq/github.com/comamoca/org/dist"
				 :publishing-function org-html-publish-to-html
				 :include ("index.org")
				 :exclude ())
     
				("note"
				 :base-directory "~/.ghq/github.com/comamoca/org/note"
				 :base-extension "org"  
				 :recursive t
				 :publishing-directory  "~/.ghq/github.com/comamoca/org/note/dist"
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
  (set-language-environment "japanese")
  (prefer-coding-system 'utf-8)
  (set-default 'buffer-file-coding-system 'utf-8)

  (org-babel-do-load-languages
   'org-babel-load-languages
   '((c . t)
     (shell . t)
     (python . t)
     (clojure . t)
     (hy . t)
     (ruby . t)
     (ledger . t)))
  :bind ((:calendar-mode-map
	  ("c-c c" . org-capture-from-calendar)))
  :init
  ;; org-calendar
  ;; (with-eval-after-load 'calendar
  ;;     (define-key calendar-mode-map (kbd "c-c c") 'org-capture-from-calendar))
  )

;; org-journal
(leaf org-journal
  :after org
  :custom
  ((org-journal-time-format . "")
   (org-journal-time-prefix . "")
   `(org-journal-dir . ,(concat org-directory (format-time-string "/diary/%y")))
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

;; deft
;; for search roam files.
(leaf deft
  :after org-roam-mode
  :custom
  ((deft-extensions . '("txt" "tex" "org"))
   `(deft-directory . ,(expand-file-name "roam" org-directory))))

(leaf org-roam-ui)

;; org-bullets
(leaf org-bullets
  :after org
  ;; :init
  ;; (org-bullets-mode 1)
  )

;; org-modern
(leaf org-modern
  :after
  :init
  (with-eval-after-load 'org (global-org-modern-mode)))

(leaf org-modern-indent)

;; org-babel
(leaf ob-hy)

(leaf org-nix-shell)

;; magit
(leaf magit
  :custom
  ((transient-default-level . 5))
  :bind ((:global-map
	  ("c-x g" . magit-status))
	 (:magit-mode-map
	  ("/" . isearch-forward))))

;; forge
(leaf forge
  :after magit)

;; skk
(leaf ddskk
  :custom ((default-input-method . "japanease-skk")
	   (skk-auto-insert-paren . t)
	   (skk-comp-mode . t)
	   (skk-delete-implies-kakutei . nil))
  :config
  (skk-latin-mode 1)
  (global-set-key (kbd "c-x c-j") 'skk-mode)
  (global-set-key (kbd "<henkan>") 'skk-kakutei)
  (global-set-key (kbd "<muhenkan>") 'skk-latin-mode))

(leaf ddskk-posframe
  :global-minor-mode t)

;; common lisp
(leaf slime
  :config
  (defvar inferior-lisp-program "sbcl"))

(leaf sly
  :config)
  ;; (defvar inferior-lisp-program "sbcl")

(leaf sly-asdf)

;; clojure
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
  "a linter for prose."
  :command ("textlint" "--format" "unix" source-inplace)
  :error-patterns
  ((warning line-start (file-name) ":" line ":" column ": "
      (id (one-or-more (not (any " "))))
      (message (one-or-more not-newline)
        (zero-or-more "\n" (any " ") (one-or-more not-newline)))
      line-end))
  :modes (text-mode markdown-mode gfm-mode org-mode web-mode))

;; copilot
(leaf copilot
  :bind ((:copilot-completion-map
	  ("tab" . copilot-accept-completion)))
  :config
  (add-to-list 'copilot-major-mode-alist '("enh-ruby" . "ruby"))
  (add-to-list 'copilot-major-mode-alist '("typescript-ts-mode" . "typescript")))

;; lsp
(leaf lsp-bridge
  :require t
  :custom
  ((acm-enable-capf . t)
   (acm-frame-background-dark-color . "#313244"))
  :config
  (setq lsp-bridge-get-single-lang-server-by-project
	(lambda (project-path file-path)
	  (message project-path)
	  (when (or (expand-file-name "package.json" project-path))
	    "typescript-language-server")
	  "deno"))
  :init
  (global-lsp-bridge-mode))



;; lso-mode
;; (leaf lsp-mode
;;   :require t
;;   :custom
;;   ((lsp-completion-provider . :none))
;;   :config
;;   (setenv "lsp_use_plists" "true")

;;   (define-key evil-normal-state-map (kbd "k") 'lsp-ui-doc-glance)

;;   (add-to-list 'lsp-language-id-configuration
;; 	       '(nix-mode . "nil")
;; 	       '(python-mode . "python"))

;;   (defun corfu-lsp-setup ()
;;     (setq completion-at-point-functions '(lsp-completion-at-point))
;;     (setq-local completion-styles '(orderless)
;; 		completion-category-defaults nil))

;;   (add-hook 'lsp-mode-hook #'corfu-lsp-setup)
;;   (add-hook 'prog-mode-hook #'lsp-deferred))

;; ;; lsp booster
;; (defun lsp-booster--advice-json-parse (old-fn &rest args)
;;   "try to parse bytecode instead of json."
;;   (or
;;    (when (equal (following-char) ?#)
;;      (let ((bytecode (read (current-buffer))))
;;        (when (byte-code-function-p bytecode)
;;          (funcall bytecode))))
;;    (apply old-fn args)))

;; (advice-add (if (progn (require 'json)
;;                        (fboundp 'json-parse-buffer))
;;                 'json-parse-buffer
;;               'json-read)
;;             :around
;;             #'lsp-booster--advice-json-parse)

;; (defun lsp-booster--advice-final-command (old-fn cmd &optional test?)
;;   "prepend emacs-lsp-booster command to lsp cmd."
;;   (let ((orig-result (funcall old-fn cmd test?)))
;;     (if (and (not test?)                             ;; for check lsp-server-present?
;;              (not (file-remote-p default-directory)) ;; see lsp-resolve-final-command, it would add extra shell wrapper
;;              lsp-use-plists
;;              (not (functionp 'json-rpc-connection))  ;; native json-rpc
;;              (executable-find "emacs-lsp-booster"))
;;         (progn
;;           (when-let ((command-from-exec-path (executable-find (car orig-result))))  ;; resolve command from exec-path (in case not found in $path)
;;             (setcar orig-result command-from-exec-path))
;;           (message "using emacs-lsp-booster for %s!" orig-result)
;;           (cons "emacs-lsp-booster" orig-result))
;;       orig-result)))

;; (advice-add 'lsp-resolve-final-command :around #'lsp-booster--advice-final-command)

;; eglot
;; (defun deno-project-p ()
;;   "predicate for determining if the open project is a deno one."
;;   (let ((p-root (nth 2 (project-current))))
;;     (or (file-exists-p (expand-file-name "deno.json" default-directory))
;; 	(file-exists-p (expand-file-name "deno.jsonc" default-directory)))))

;; (defun node-project-p ()
;;   "predicate for determining if the open project is a deno one."
;;   (let ((p-root (nth 2 (project-current))))
;;     (file-exists-p (expand-file-name "package.json" default-directory))))

;; (defun es-server-program (_)
;;   "decide which server to use for ecma script based on project characteristics."
;;   (cond ((deno-project-p) '("deno" "lsp" :initializationoptions (:enable t :lint t)))
;;         ((node-project-p) '("typescript-language-server" "--stdio"))
;;         (t nil)))

;; (leaf eglot
;;   :hook
;;   (c++-mode . eglot-ensure)
;;   (sh-mode . eglot-ensure)
;;   (python-mode . eglot-ensure)
;;   (html-mode . eglot-ensure)
;;   (cmake-mode . eglot-ensure)
;;   (bitbake-mode . eglot-ensure)
;;   (typescript-ts-mode . eglot-ensure)
;;   :config
;;   ;; (add-to-list 'eglot-server-programs '((bitbake-mode) "bitbake-language-server"))
;;   (add-to-list 'eglot-server-programs '((js-mode typescript-mode) . es-server-program))
;;   (add-to-list 'eglot-server-programs '(gleam-ts-mode . ("lspx" "--lsp" "gleam lsp")))
;;   :bind (("m-t" . xref-find-definitions)
;; 	 ("m-r" . xref-find-references)
;; 	 ("c-t" . xref-go-back)))

;; (leaf eglot-booster
;;   :after eglot
;;   :config (eglot-booster-mode))

;; auto formatting
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
 
;; lua support
(leaf lua-mode)

;; completion
(leaf corfu
  :custom
  ((corfu-cycle . t)
  (corfu-auto . t)
  (corfu-auto-prefix . 1))
  :init
  (global-corfu-mode))


;; cursor moation
(leaf avy
  :config
  (define-key evil-normal-state-map (kbd "spc k") #'avy-goto-line))

;; completion soruce
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

;; hydra
(leaf hydra)
(leaf hydra-posframe
  ;; :require t
  ;; :vc (:url "https://github.com/ladicle/hydra-posframe")

  :init
  ;; for hydra
  (define-key evil-normal-state-map (kbd "spc w") #'manage-window-hydra/body)

  :hook
  (add-hook 'after-init-hook 'hydra-posframe-mode))

(leaf major-mode-hydra)

;; for nix
(pretty-hydra-define nix-flake-hydra
  (:separator "-" :title "nix flake" :forigen-key warn :quit-key "q" :exit t)
  ("build"
   (("b" nix-flake-build-default "build"))

   "update"
   (("u" nix-flake-update "update"))))

;; for manage window
(pretty-hydra-define manage-window-hydra
  (:separator "-" :title "manage window" :forigen-key warn :quit-key "q" :exit t)
  ("1"
   (("a" delete-other-windows "delte other windwos"))

   "2"
   (("s" split-window-below "horizontal split"))

   "3"
   (("d" split-window-right "vertical split"))

   "0"
   (("f" delete-window "delete window"))))

(pretty-hydra-define org-hydra
  (:separator "-" :title "nix flake" :forigen-key warn :quit-key "q" :exit t)
  ("roam"
   (("a" org-roam-node-find "roam"))

   "capture"
   (("s" org-capture "capture"))))
    

;; (pretty-hydra-define org-roam-hydra
;;   (:separator "-" :title "org-roam" :forigen-key warn :quit-key "q" :exit t)
;;   ("find"
;;    (("a" 'org-roam-node-find "find node"))

;;    ""
;;    (("s" 'org-roam- ""))

;;    ""
;;    (("d"  ""))

;;    ""
;;    (("f"  ""))
;;     ))

;; transient dispatcher
(leaf transient-dwim
  :bind ("c-=" . transient-dwim-dispatch))

;; tree filer
(leaf neotree
  :custom
  (neo-smart-open . t)
  (projectile-switch-project-action . 'neotree-projectile-action)
  :config
  (progn
    (evil-define-key 'normal neotree-mode-map (kbd "q") 'neotree-hide)
    (evil-define-key 'normal neotree-mode-map (kbd "l") 'neotree-enter)
    (evil-define-key 'normal neotree-mode-map (kbd "ret") 'neotree-enter)
    (evil-define-key 'normal neotree-mode-map (kbd "h") 'neotree-enter)
    (evil-define-key 'normal neotree-mode-map (kbd "g") 'neotree-refresh)
    (evil-define-key 'normal neotree-mode-map (kbd "j") 'neotree-next-line)
    (evil-define-key 'normal neotree-mode-map (kbd "k") 'neotree-previous-line)
    (evil-define-key 'normal neotree-mode-map (kbd "a") 'neotree-stretch-toggle)
    (evil-define-key 'normal neotree-mode-map (kbd "h") 'neotree-hidden-file-toggle)
    (evil-define-key 'normal neotree-mode-map (kbd "n") 'neotree-create-node)
    (evil-define-key 'normal neotree-mode-map (kbd "k") 'neotree-create-node)
    (evil-define-key 'normal neotree-mode-map (kbd "d") 'neotree-delete-node)
    (evil-define-key 'normal neotree-mode-map (kbd "m") 'neotree-rename-node))
  
  ;; for neotree
  (define-key evil-normal-state-map (kbd "spc f") #'neotree-toggle))
  

;; translate
(leaf google-translate
  :require t
  :custom
  (google-translate-translation-directions-alist . '(("en" . "ja")
                                                     ("ja" . "en"))))
;; wakatime
(leaf wakatime-mode
  :init
  (global-wakatime-mode))

;; typst

;; preview
(leaf typst-preview
  ;; :vc (:url "https://github.com/havarddj/typst-preview.el")
  ;; :require t
  :config
  (setq typst-preview-browser "firefox"))

;; ruby support
(leaf inf-ruby)

(leaf enh-ruby-mode)

;; python support
(add-hook 'python-ts-mode-hook (lambda ()
				 (require 'python-mode)))

;; language supports

;; dotnet
(leaf dotnet
  :after csharp-mode)

;; c#
(leaf csharp-mode)

;; nix support
(leaf nix-mode
  :hook
  (nix-ts-mode))

;; scala suppport
(leaf scala-mode
  :interpreter ("scala" . scala-mode))


(leaf sbt-mode
  :commands sbt-start sbt-command
  :config
  (substitute-key-definition
   'minibuffer-complete-word
   'self-insert-command
   minibuffer-local-completion-map)

   (setq sbt:program-options '("-dsbt.supershell=false")))

;; astro support
(leaf astro-ts-mode)

;; elixir support
(leaf inf-elixir)
(leaf mix)

(leaf elixir-ts-mode
  :hook ((elixir-ts-mode . mix-minor-mode)))

;; kdl supports
(leaf kdl-ts-mode)

;; gleam support
(leaf gleam-ts-mode
  :require t
  :hook gleam-on-save-mode)

;; markdown suppot
(leaf markdown-mode
  :hook
  (add-to-list 'completion-at-point-functions #'cape-emoji))

;; projectile
(defun update-projectlist ()
  (interactive)
  (setq projectile-known-projects
         (mapcar
          (lambda (x) (abbreviate-file-name x))
          (split-string (shell-command-to-string "ghq list --full-path")))))

(leaf projectile 
  :config
  (define-key evil-normal-state-map (kbd "m-g") #'projectile-switch-project)
  (define-key evil-normal-state-map (kbd "c-o") #'projectile-find-file)
  :init
  (when (executable-find "ghq")
   (update-projectlist)))

;; migemo
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

;; nyan-mode
(leaf nyan-mode
  :init
  (progn (nyan-mode)
   (nyan-start-animation)))

;; snippets
(leaf tempel
  :require t
  :bind ((:evil-insert-state-map
	  ("m-a" . tempel-done)))
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

;; http request
(leaf request)
(leaf plz)

(autoload 'newsticker-start "newsticker" "start newsticker" t)
(autoload 'newsticker-show-news "newsticker" "goto newsticker buffer" t)

(setq newsticker-url-list
      '(("gleam weekly" "https://gleamweekly.com/atom.xml")
        ("zenn gleam" "https://zenn.dev/topics/gleam/feed")
	("gleam releases" "https://github.com/gleam-lang/gleam/releases.atom")
	("zenn trend" "https://zenn.dev/feed")
	("zenn emacs" "https://zenn.dev/topics/emacs/feed")
        ("zenn ts" "https://zenn.dev/topics/typescript/feed")
        ("zenn cl" "https://zenn.dev/topics/commonlisp/feed")
        ("zenn deno" "https://zenn.dev/topics/deno/feed")
        ("zenn bun" "https://zenn.dev/topics/bun/feed")
        ("zenn rust" "https://zenn.dev/topics/rust/feed")
        ("zenn vim" "https://zenn.dev/topics/vim/feed")
        ("zenn neovim" "https://zenn.dev/topics/neovim/feed")
        ("zenn scheme" "https://zenn.dev/topics/scheme/feed")
        ("zenn hono" "https://zenn.dev/topics/hono/feed")
        ("zenn react" "https://zenn.dev/topics/react/feed")
        ("zenn gcp" "https://zenn.dev/topics/googlecloud/feed")
        ("zenn aws" "https://zenn.dev/topics/aws/feed")
        ("techfeed" "https://techfeed.io/feeds/categories/all")
	("hacker news" "https://hnrss.org/frontpage")
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
	  ("c-a" . grugru))
	 (:evil-normal-state-map
	  ("c-x" . grugru-backward)))
  :config
  ;; ref: https://github.com/rocktakey/grugru/issues/44
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

;; (leaf folding-mode :require t)

(leaf rg
  :require t)

(leaf open-junk-file
  :require t
  :custom
  (open-junk-file-format . "/tmp/junk/%y_%m_%d_%h%m%s.")
  :bind (("c-x j" . open-junk-file)))

(leaf fold-this)

(leaf alert
  :config
  (setq alert-default-style 'libnotify))

(leaf dashboard
  :config
  (setq dashboard-startup-banner (expand-file-name "~/pictures/.emacs-logos/gnu_color_resize.png"))
  (setq dashboard-startup-banner 'logo))

(leaf aas
  ;; :hook (text-mode . aas-activate-for-major-mode)
  ;; :init
  ;; (aas-set-snippets 'global)
  ;; (aas-set-snippets 'markdown-mode)
  ;; (aas-set-snippets 'prog-mode)
  )

(leaf smartparens
  :config
  (smartparens-global-mode t))

(leaf vterm)

(leaf vterm-toggle
  :after evil
  :bind (("c-<return>" . (lambda ()
			   (interactive)
			   (vterm-toggle-insert-cd)
			   (vterm-toggle-insert-cd)))))

(leaf multi-vterm
  :config
  (setq multi-vterm-dedicated-window-height 50))

;; ai
(add-hook 'server-after-make-frame-hook
          (lambda ()
            (setenv "gemini_api_key" (get-secret "gemini.google.com"))
            (setenv "openrouter_api_key" (get-secret "openrouter.ai"))
	    (setq gemini-apikey (get-secret "gemini.google.com"))))

(leaf gptel
  :config
  (setq
   ;; gptel-model 'starcoder2
   ;; gptel-backend (gptel-make-ollama "ollama"
   ;;                :host "localhost:11434"
   ;;                :stream t
   ;;                :models '(starcoder2)))

   gptel-model 'gemini-2.5-flash
   gptel-backend (gptel-make-gemini "gemini"
		   :key gemini-apikey
		   :stream t)))

;; ai codeing
(leaf aider
  :require t
  :custom
  (;; (aider-args . '("--watch-files" "--model" "gemini/gemini-2.0-flash"))
   (aider-args . '("--watch-files" "--model" "openrouter/anthropic/claude-3.5-sonnet"))
   ))

(leaf aidermacs
  :require t
  :config
  (setq aidermacs-watch-files t)
  :custom
  (;; (aidermacs-default-model . "gemini/gemini-2.0-flash")
   (aidermacs-default-model . "gemini/gemini-2.5-pro-preview-03-25")
   (aidermacs-watch-files . t)))
;; (aidermacs-default-model . "gemini/gemini-2.5-flash-preview-04-17")


(leaf mcp)

(leaf minimap
  :require t
  :custom ((minimap-window-location . 'right)
	   (minimap-minimum-width . 20)
	   (minimap-major-modes . '(prog-mode
				    markdown-mode
				    html-mode
				    fundamental-mode)))
  :bind ("c-x m" . minimap-mode)
  :config
  (minimap-mode 1))

(leaf rainbow-delimiters
  :hook
  (prog-mode-hook . rainbow-delimiters-mode))

(leaf ox-zenn
  :after org
  :require t)

(leaf verb)

(leaf quickrun)

;; ================ my extentions ================

(defun get-secret (host)
  "wrapper functino for auth-info"
  (require 'ht) 
  (let* ((found (cl-first (auth-source-search :host host
					      :user "coma")))
	 (credentials (when found
			(eval `(ht ,@(--map `(,it ,(plist-get found it))
                                            '(:user :secret :save-function))))))
	 (secret (when credentials
                   (ht-get credentials :secret))))

    (if (not secret)
	(progn (message (format "does not found %s credential." host))
	       "")
      (if (functionp secret)
          (funcall secret)
	secret))))

;; (defun nyan-region ()
;;   "選択範囲をにゃーんで置換する"
;;   (interactive)
;;   (when (use-region-p)
;;     (let* ((beg (region-beginning))
;;            (end (region-end)))
;;      (len (- end beg)
;;       (delete-region beg end)
;;       (cond ((= len 1) (insert "にゃ")))
;;       ((= len 2) (insert "にゃん"))
;;       (t (insert (format "にゃ%sん" (make-string (- len 3) ?ー))))))))

;; (defun nyan-region ()
;;   "選択範囲をにゃーんで置換する"
;;   (interactive)
;;   (when (use-region-p)
;;     (let* ((beg (region-beginning))
;;            (end (region-end))
;;            (len (- end beg)))
;;       (delete-region beg end)
;;       (cond ((= len 1) (insert "にゃ"))
;;             ((= len 2) (insert "にゃん"))
;;             (t (insert (format "にゃ%sん" (make-string (- len 3) ?ー))))))))

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

  (let* ((query (read-from-minibuffer "query? > ")))
   (url (concat "https://www.google.com/search?client=firefox-b-d&q=" (url-hexify-string query))
  
    (shell-command (concat "open " "'" url "'")))))

(defun home-manager ()
  (interactive)
  (start-process "home-manager-process"
     "*home-manager*"
     "home-manager"
     "switch"
     "--flake"
     ".#home"
     "-b"
     "backup"))

    ;; (set-process-sentinel proc
    ;;                           (lambda (process event)
    ;;                             (when (string= event "finished\n"))))

(defun all (pred lst)
  "returns t if all elements of the list satisfy the predicate."
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
  (let ((beg (save-excursion (skip-chars-backward "a-za-z") (point)))
        (end (point))
        (candidates gitmoji--codes))
    (list beg end candidates :exclusive 'no)))

;; collect gitmoji when startup
;; (add-hook 'emacs-startup-hook 'setup-gitmoji)
;; enable at git-commit-mode

;; display character count in modeline
(defun update-buffer-char-count ()
  (interactive)
  (format " [%d] " (buffer-size)))

(defun mode-line-time ()
  ;; update every second
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

;; for diary
(setq blog-repo "/home/coma/.ghq/github.com/comamoca/blog/")

(defun latest-diary ()
  "open latest diary. this function call in `src/blog/` directory at blog repository."
  (interactive)
  (let* ((date (format-time-string "%y-%m-%d"))
         (file-name (format "%s-diary.md" date))
         (path (concat (expand-file-name "src/blog/" blog-repo) file-name)))
    (find-file path)
    (if (= (buffer-size) 0)
	(tempel-insert 'diary))))

(defun new-blog-article ()
  "open latest diary. this function call in `src/blog/` directory at blog repository."
  (interactive)
  (let* ((date (format-time-string "%y-%m-%d"))
         (slug (read-string "slug > "))
         (file-name (format "%s-%s.md" date slug))
         (path (concat (expand-file-name "src/blog/" blog-repo) file-name)))
    ;; (projectile-switch-project-by-name "blog")
    (find-file path)))

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
	 (mdfiles (cl-remove-if-not (lambda (file) 
                                      (string-match "\\.md$" file))
                                    files))
	 (articles (cl-remove-if (lambda (file)
                                   (string-match "-diary\\.md$" file))
                                 mdfiles))
	 (selected (completing-read "blog " articles)))
    (find-file (expand-file-name selected src-dir)))) 

(defun org-paste-image ()
  (interactive)
  (setq filename (concat
                  (expand-file-name (format-time-string "%y-%m-%d-%h%m%s")
                   "~/.ghq/github.com/comamoca/org/imgs") ".png"))
  (shell-command (concat  "wl-paste -t image/png > " filename))
  (insert (concat "[[" filename "]]"))
  (org-display-inline-images))

(defun blog-paste-image ()
  (interactive)
  (setq fullpath (concat
                  (expand-file-name (format-time-string "%y-%m-%d-%h%m%s")
				    "~/.ghq/github.com/comamoca/blog/src/images") ".png"))
  (shell-command (concat  "wl-paste -t image/png > " fullpath))
  (insert (concat "![](/images/" (file-name-nondirectory fullpath) ")"))
  (org-display-inline-images))


;; gauche
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
                             (mapcar #'car node-items)
                             :prompt "Node: "))
         (select-node (cdr (assoc select-node-title node-items))))
    (find-file (org-roam-node-file select-node))))

;; pinentry emacs
(defun pinentry-emacs (desc prompt ok error)
  (let ((str (read-passwd (concat (replace-regexp-in-string "%22" "\"" (replace-regexp-in-string "%0a" "\n" desc)) prompt ": "))))
    str))

;; initel function that behaves like `:e $myvimrc`
(defun initel ()
  (interactive)
  (find-file user-init-file))

;; ================ my configuratons ================

;; ediff
(setq ediff-window-setup-function 'ediff-setup-windows-plain)

;; font
(add-to-list 'default-frame-alist
                       '(font . "udev gothic nf-14"))

;; for auth-info
(setq auth-sources '("~/.emacs.d/.authinfo.gpg"))
(setq create-lockfiles nil)

;; for lsp-mode
(setq gc-cons-threshold 100000000)
(setq read-process-output-max (* 1024 1024))

;; key mapping
(define-key global-map (kbd "c-x s") 'blackening-region)
(define-key global-map (kbd "c-;") 'comment-dwim)

;; minibuffe
(define-key minibuffer-local-map (kbd "c-h") 'delete-char)
(define-key minibuffer-local-ns-map (kbd "c-h") 'delete-char)
(define-key minibuffer-local-completion-map (kbd "c-h") 'delete-char)
(define-key minibuffer-local-must-match-map (kbd "c-h") 'delete-char)
(define-key minibuffer-local-filename-completion-map (kbd "c-h") 'delete-char)

;; enable debug
(setq debug-on-error nil)

;; custom modeline
(mode-line-format-update)

;; when org-mode
(add-hook 'org-mode
    (lambda ()
      (local-set-key evil-insert-state-map (kbd "c-h") #'org-insert-heading)))

(electric-pair-mode 1)

(global-hl-line-mode t)

(setq vc-follow-symlinks t)
(setq browse-url-generic-program "firefox")
(setq ring-bell-function 'ignore)

(setq display-warning-minimum-level :error)

;; disable to create backupfile
(setq make-backup-files nil)

;; disable to auto save
(setq auto-save-default nil)

;; copy & paste with wl-clipboard
;; ref: https://gist.github.com/yorickvp/6132f237fbc289a45c808d8d75e0e1fb
(setenv "wayland_display" "wayland-1")

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
  :bind (("c-c e" . macrostep-expand)))

;; (provide 'init)
(put 'narrow-to-region 'disabled nil)
(custom-set-variables
 ;; custom-set-variables was added by custom.
 ;; if you edit it by hand, you could mess it up, so be careful.
 ;; your init file should contain only one such instance.
 ;; if there is more than one, they won't work right.
 '(skk-jisyo-edit-user-accepts-editing t))
(custom-set-faces)
 ;; custom-set-faces was added by custom.
 ;; if you edit it by hand, you could mess it up, so be careful.
 ;; your init file should contain only one such instance.
 ;; if there is more than one, they won't work right.
 

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

;; theme
(leaf catppuccin-theme 
  :preface
  :config
  (load-theme 'catppuccin t))

;; minibuffer ui
(leaf vertico
  :require orderless
  :config
  (defvar vertico-count 10)
  ;; completion style config
  (setq completion-styles '(orderless basic)
	completion-category-overrides '((file (styles basic partial-completion))))
  :init 
  (vertico-mode))

;; completion styles
(leaf orderless)

(leaf hotfuzz)

;; completing read functions
(leaf consult
  :require t
  :after evil
  :bind ((:evil-normal-state-map
	  ("c-l" . consult-line)
	  ("c-i" . consult-buffer)))
  :bind* (("c-." . embark-act)))

(leaf consult-dir)

;; embark
(leaf embark
  :after evil
  :bind ((:evil-normal-state-map
	  ("c-." . embark-act)
	  ("c--" . embark-export))
	 (:evil-insert-state-map
	  ("c-." . embark-act))))

;; affe
(leaf affe)

;; for consult
(leaf embark-consult
  :bind ((:minibuffer-mode-map
	  ("m-." . embark-dwin)
	  ("c-." . embark-act))))

;; vim keybind
(leaf evil
  :require t
  :bind ((:evil-normal-state-map
	  ("c-k" . evil-scroll-up)
	  ("c-j" . evil-scroll-down))
	 (:evil-insert-state-map
	  ;; ("c-j" . newline-and-indent)
	  ("c-h" . backward-char)))
 
  :config
  (evil-mode 1))

;; structured editing 
(leaf puni
  :config
  (global-set-key (kbd "c--") 'puni-expand-region)
  :bind ((:evil-insert-state-map
	  ("s" . nil)
	  ;; ("sd" . puni-splice)
	  ("c-i" . puni-mark-sexp-at-point)
	  ("c-p" . puni-slurp-forward)
	  ("c-n" . puni-barf-forward)))
  :init
  (puni-global-mode))

;; indent guides
(leaf highlight-indent-guides)

;; treesitter
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
  (add-to-list 'auto-mode-alist '("dockerfile" . dockerfile-ts-mode)))

(leaf treesit-auto
  :require t
  :custom
  ((treesit-auto-install . t)
   (treesit-extra-load-path . `(,(expand-file-name "~/.cache/dpp/_generated/nvim-treesitter/parser"))))
  :config  
  (global-treesit-auto-mode)
  ;; (treesit-auto-install 'prompt)
  ;; (treesit-auto-add-to-auto-mode-alist 'all)
  )

;; for envrc
(leaf envrc)

;; calendar 
(leaf calendar)

;; org-mode
(leaf org
  :after calendar-mode
  :custom
  ((org-todo-keywords .
		      '((sequence "todo(t)" "pending(p)" "|" "done(d)" "canceled(c)")))
   (org-default-notes-file . "notes.org")
   `(org-directory . ,(expand-file-name "~/.ghq/github.com/comamoca/org"))
   `(diary-file-path . ,(format-time-string "diary/%y/%m-%d.org"))
   `(memo-file-path . ,(format-time-string "memo/%y/%m/%d.org"))
   `(diary-path . ,(concat org-directory "/diary"))
   (org-publish-use-timestamps-flag . nil)

   ;; org-capture
   (org-capture-templates .
			  '(("d" "diary" plain (file diary-file-path)
			     "** 今日やったこと\n\n** 明日以降やりたいこと")
			    ("m" "memo" plain (file memo-file-path) "")))

   (org-publish-project-alist .
			      '(("diary"
				 :base-directory "~/.ghq/github.com/comamoca/org/diary"
				 :base-extension "org"  
				 :recursive t
				 :publishing-directory  "~/.ghq/github.com/comamoca/org/dist"
				 :publishing-function org-html-publish-to-html
				 :include ("index.org")
				 :exclude ())
     
				("note"
				 :base-directory "~/.ghq/github.com/comamoca/org/note"
				 :base-extension "org"  
				 :recursive t
				 :publishing-directory  "~/.ghq/github.com/comamoca/org/note/dist"
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
  (set-language-environment "japanese")
  (prefer-coding-system 'utf-8)
  (set-default 'buffer-file-coding-system 'utf-8)

  (org-babel-do-load-languages
   'org-babel-load-languages
   '((c . t)
     (shell . t)
     (python . t)
     (clojure . t)
     (hy . t)
     (ruby . t)
     (ledger . t)))
  :bind ((:calendar-mode-map
	  ("c-c c" . org-capture-from-calendar)))
  :init
  ;; org-calendar
  ;; (with-eval-after-load 'calendar
  ;;     (define-key calendar-mode-map (kbd "c-c c") 'org-capture-from-calendar))
  )

;; org-journal
(leaf org-journal
  :after org
  :custom
  ((org-journal-time-format . "")
   (org-journal-time-prefix . "")
   `(org-journal-dir . ,(concat org-directory (format-time-string "/diary/%y")))
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

;; deft
;; for search roam files.
(leaf deft
  :after org-roam-mode
  :custom
  ((deft-extensions . '("txt" "tex" "org"))
   `(deft-directory . ,(expand-file-name "roam" org-directory))))

(leaf org-roam-ui)

;; org-bullets
(leaf org-bullets
  :after org
  ;; :init
  ;; (org-bullets-mode 1)
  )

;; org-modern
(leaf org-modern
  :after
  :init
  (with-eval-after-load 'org (global-org-modern-mode)))

(leaf org-modern-indent)

;; org-babel
(leaf ob-hy)

(leaf org-nix-shell)

;; magit
(leaf magit
  :custom
  ((transient-default-level . 5))
  :bind ((:global-map
	  ("c-x g" . magit-status))
	 (:magit-mode-map
	  ("/" . isearch-forward))))

;; forge
(leaf forge
  :after magit)

;; skk
(leaf ddskk
  :custom ((default-input-method . "japanease-skk")
	   (skk-auto-insert-paren . t)
	   (skk-comp-mode . t)
	   (skk-delete-implies-kakutei . nil))
  :config
  (skk-latin-mode 1)
  (global-set-key (kbd "c-x c-j") 'skk-mode)
  (global-set-key (kbd "<henkan>") 'skk-kakutei)
  (global-set-key (kbd "<muhenkan>") 'skk-latin-mode))

(leaf ddskk-posframe
  :global-minor-mode t)

;; common lisp
(leaf slime
  :config
  (defvar inferior-lisp-program "sbcl"))

(leaf sly
  :config)
  ;; (defvar inferior-lisp-program "sbcl")

(leaf sly-asdf)

;; clojure
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
  "a linter for prose."
  :command ("textlint" "--format" "unix" source-inplace)
  :error-patterns
  ((warning line-start (file-name) ":" line ":" column ": "
      (id (one-or-more (not (any " "))))
      (message (one-or-more not-newline)
        (zero-or-more "\n" (any " ") (one-or-more not-newline)))
      line-end))
  :modes (text-mode markdown-mode gfm-mode org-mode web-mode))

;; copilot
(leaf copilot
  :bind ((:copilot-completion-map
	  ("tab" . copilot-accept-completion)))
  :config
  (add-to-list 'copilot-major-mode-alist '("enh-ruby" . "ruby"))
  (add-to-list 'copilot-major-mode-alist '("typescript-ts-mode" . "typescript")))

;; lsp
(leaf lsp-bridge
  :require t
  :custom
  ((acm-enable-capf . t)
   (acm-frame-background-dark-color . "#313244"))
  :config
  (setq lsp-bridge-get-single-lang-server-by-project
	(lambda (project-path file-path)
	  (message project-path)
	  (when (or (expand-file-name "package.json" project-path))
	    "typescript-language-server")
	  "deno"))
  :init
  (global-lsp-bridge-mode))



;; lso-mode
;; (leaf lsp-mode
;;   :require t
;;   :custom
;;   ((lsp-completion-provider . :none))
;;   :config
;;   (setenv "lsp_use_plists" "true")

;;   (define-key evil-normal-state-map (kbd "k") 'lsp-ui-doc-glance)

;;   (add-to-list 'lsp-language-id-configuration
;; 	       '(nix-mode . "nil")
;; 	       '(python-mode . "python"))

;;   (defun corfu-lsp-setup ()
;;     (setq completion-at-point-functions '(lsp-completion-at-point))
;;     (setq-local completion-styles '(orderless)
;; 		completion-category-defaults nil))

;;   (add-hook 'lsp-mode-hook #'corfu-lsp-setup)
;;   (add-hook 'prog-mode-hook #'lsp-deferred))

;; ;; lsp booster
;; (defun lsp-booster--advice-json-parse (old-fn &rest args)
;;   "try to parse bytecode instead of json."
;;   (or
;;    (when (equal (following-char) ?#)
;;      (let ((bytecode (read (current-buffer))))
;;        (when (byte-code-function-p bytecode)
;;          (funcall bytecode))))
;;    (apply old-fn args)))

;; (advice-add (if (progn (require 'json)
;;                        (fboundp 'json-parse-buffer))
;;                 'json-parse-buffer
;;               'json-read)
;;             :around
;;             #'lsp-booster--advice-json-parse)

;; (defun lsp-booster--advice-final-command (old-fn cmd &optional test?)
;;   "prepend emacs-lsp-booster command to lsp cmd."
;;   (let ((orig-result (funcall old-fn cmd test?)))
;;     (if (and (not test?)                             ;; for check lsp-server-present?
;;              (not (file-remote-p default-directory)) ;; see lsp-resolve-final-command, it would add extra shell wrapper
;;              lsp-use-plists
;;              (not (functionp 'json-rpc-connection))  ;; native json-rpc
;;              (executable-find "emacs-lsp-booster"))
;;         (progn
;;           (when-let ((command-from-exec-path (executable-find (car orig-result))))  ;; resolve command from exec-path (in case not found in $path)
;;             (setcar orig-result command-from-exec-path))
;;           (message "using emacs-lsp-booster for %s!" orig-result)
;;           (cons "emacs-lsp-booster" orig-result))
;;       orig-result)))

;; (advice-add 'lsp-resolve-final-command :around #'lsp-booster--advice-final-command)

;; eglot
;; (defun deno-project-p ()
;;   "predicate for determining if the open project is a deno one."
;;   (let ((p-root (nth 2 (project-current))))
;;     (or (file-exists-p (expand-file-name "deno.json" default-directory))
;; 	(file-exists-p (expand-file-name "deno.jsonc" default-directory)))))

;; (defun node-project-p ()
;;   "predicate for determining if the open project is a deno one."
;;   (let ((p-root (nth 2 (project-current))))
;;     (file-exists-p (expand-file-name "package.json" default-directory))))

;; (defun es-server-program (_)
;;   "decide which server to use for ecma script based on project characteristics."
;;   (cond ((deno-project-p) '("deno" "lsp" :initializationoptions (:enable t :lint t)))
;;         ((node-project-p) '("typescript-language-server" "--stdio"))
;;         (t nil)))

;; (leaf eglot
;;   :hook
;;   (c++-mode . eglot-ensure)
;;   (sh-mode . eglot-ensure)
;;   (python-mode . eglot-ensure)
;;   (html-mode . eglot-ensure)
;;   (cmake-mode . eglot-ensure)
;;   (bitbake-mode . eglot-ensure)
;;   (typescript-ts-mode . eglot-ensure)
;;   :config
;;   ;; (add-to-list 'eglot-server-programs '((bitbake-mode) "bitbake-language-server"))
;;   (add-to-list 'eglot-server-programs '((js-mode typescript-mode) . es-server-program))
;;   (add-to-list 'eglot-server-programs '(gleam-ts-mode . ("lspx" "--lsp" "gleam lsp")))
;;   :bind (("m-t" . xref-find-definitions)
;; 	 ("m-r" . xref-find-references)
;; 	 ("c-t" . xref-go-back)))

;; (leaf eglot-booster
;;   :after eglot
;;   :config (eglot-booster-mode))

;; auto formatting
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
 
;; lua support
(leaf lua-mode)

;; completion
(leaf corfu
  :custom
  ((corfu-cycle . t)
  (corfu-auto . t)
  (corfu-auto-prefix . 1))
  :init
  (global-corfu-mode))


;; cursor moation
(leaf avy
  :config
  (define-key evil-normal-state-map (kbd "spc k") #'avy-goto-line))

;; completion soruce
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

;; hydra
(leaf hydra)
(leaf hydra-posframe
  ;; :require t
  ;; :vc (:url "https://github.com/ladicle/hydra-posframe")

  :init
  ;; for hydra
  (define-key evil-normal-state-map (kbd "spc w") #'manage-window-hydra/body)

  :hook
  (add-hook 'after-init-hook 'hydra-posframe-mode))

(leaf major-mode-hydra)

;; for nix
(pretty-hydra-define nix-flake-hydra
  (:separator "-" :title "nix flake" :forigen-key warn :quit-key "q" :exit t)
  ("build"
   (("b" nix-flake-build-default "build"))

   "update"
   (("u" nix-flake-update "update"))))

;; for manage window
(pretty-hydra-define manage-window-hydra
  (:separator "-" :title "manage window" :forigen-key warn :quit-key "q" :exit t)
  ("1"
   (("a" delete-other-windows "delte other windwos"))

   "2"
   (("s" split-window-below "horizontal split"))

   "3"
   (("d" split-window-right "vertical split"))

   "0"
   (("f" delete-window "delete window"))))

(pretty-hydra-define org-hydra
  (:separator "-" :title "nix flake" :forigen-key warn :quit-key "q" :exit t)
  ("roam"
   (("a" org-roam-node-find "roam"))

   "capture"
   (("s" org-capture "capture"))))
    

;; (pretty-hydra-define org-roam-hydra
;;   (:separator "-" :title "org-roam" :forigen-key warn :quit-key "q" :exit t)
;;   ("find"
;;    (("a" 'org-roam-node-find "find node"))

;;    ""
;;    (("s" 'org-roam- ""))

;;    ""
;;    (("d"  ""))

;;    ""
;;    (("f"  ""))
;;     ))

;; transient dispatcher
(leaf transient-dwim
  :bind ("c-=" . transient-dwim-dispatch))

;; tree filer
(leaf neotree
  :custom
  (neo-smart-open . t)
  (projectile-switch-project-action . 'neotree-projectile-action)
  :config
  (progn
    (evil-define-key 'normal neotree-mode-map (kbd "q") 'neotree-hide)
    (evil-define-key 'normal neotree-mode-map (kbd "l") 'neotree-enter)
    (evil-define-key 'normal neotree-mode-map (kbd "ret") 'neotree-enter)
    (evil-define-key 'normal neotree-mode-map (kbd "h") 'neotree-enter)
    (evil-define-key 'normal neotree-mode-map (kbd "g") 'neotree-refresh)
    (evil-define-key 'normal neotree-mode-map (kbd "j") 'neotree-next-line)
    (evil-define-key 'normal neotree-mode-map (kbd "k") 'neotree-previous-line)
    (evil-define-key 'normal neotree-mode-map (kbd "a") 'neotree-stretch-toggle)
    (evil-define-key 'normal neotree-mode-map (kbd "h") 'neotree-hidden-file-toggle)
    (evil-define-key 'normal neotree-mode-map (kbd "n") 'neotree-create-node)
    (evil-define-key 'normal neotree-mode-map (kbd "k") 'neotree-create-node)
    (evil-define-key 'normal neotree-mode-map (kbd "d") 'neotree-delete-node)
    (evil-define-key 'normal neotree-mode-map (kbd "m") 'neotree-rename-node))
  
  ;; for neotree
  (define-key evil-normal-state-map (kbd "spc f") #'neotree-toggle))
  

;; translate
(leaf google-translate
  :require t
  :custom
  (google-translate-translation-directions-alist . '(("en" . "ja")
                                                     ("ja" . "en"))))
;; wakatime
(leaf wakatime-mode
  :init
  (global-wakatime-mode))

;; typst

;; preview
(leaf typst-preview
  ;; :vc (:url "https://github.com/havarddj/typst-preview.el")
  ;; :require t
  :config
  (setq typst-preview-browser "firefox"))

;; ruby support
(leaf inf-ruby)

(leaf enh-ruby-mode)

;; python support
(add-hook 'python-ts-mode-hook (lambda ()
				 (require 'python-mode)))

;; language supports

;; dotnet
(leaf dotnet
  :after csharp-mode)

;; c#
(leaf csharp-mode)

;; nix support
(leaf nix-mode
  :hook
  (nix-ts-mode))

;; scala suppport
(leaf scala-mode
  :interpreter ("scala" . scala-mode))


(leaf sbt-mode
  :commands sbt-start sbt-command
  :config
  (substitute-key-definition
   'minibuffer-complete-word
   'self-insert-command
   minibuffer-local-completion-map)

   (setq sbt:program-options '("-dsbt.supershell=false")))

;; astro support
(leaf astro-ts-mode)

;; elixir support
(leaf inf-elixir)
(leaf mix)

(leaf elixir-ts-mode
  :hook ((elixir-ts-mode . mix-minor-mode)))

;; kdl supports
(leaf kdl-ts-mode)

;; gleam support
(leaf gleam-ts-mode
  :require t
  :hook gleam-on-save-mode)

;; markdown suppot
(leaf markdown-mode
  :hook
  (add-to-list 'completion-at-point-functions #'cape-emoji))

;; projectile
(defun update-projectlist ()
  (interactive)
  (setq projectile-known-projects
         (mapcar
          (lambda (x) (abbreviate-file-name x))
          (split-string (shell-command-to-string "ghq list --full-path")))))

(leaf projectile 
  :config
  (define-key evil-normal-state-map (kbd "m-g") #'projectile-switch-project)
  (define-key evil-normal-state-map (kbd "c-o") #'projectile-find-file)
  :init
  (when (executable-find "ghq")
   (update-projectlist)))

;; migemo
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

;; nyan-mode
(leaf nyan-mode
  :init
  (progn (nyan-mode)
   (nyan-start-animation)))

;; snippets
(leaf tempel
  :require t
  :bind ((:evil-insert-state-map
	  ("m-a" . tempel-done)))
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

;; http request
(leaf request)
(leaf plz)

(autoload 'newsticker-start "newsticker" "start newsticker" t)
(autoload 'newsticker-show-news "newsticker" "goto newsticker buffer" t)

(setq newsticker-url-list
      '(("gleam weekly" "https://gleamweekly.com/atom.xml")
        ("zenn gleam" "https://zenn.dev/topics/gleam/feed")
	("gleam releases" "https://github.com/gleam-lang/gleam/releases.atom")
	("zenn trend" "https://zenn.dev/feed")
	("zenn emacs" "https://zenn.dev/topics/emacs/feed")
        ("zenn ts" "https://zenn.dev/topics/typescript/feed")
        ("zenn cl" "https://zenn.dev/topics/commonlisp/feed")
        ("zenn deno" "https://zenn.dev/topics/deno/feed")
        ("zenn bun" "https://zenn.dev/topics/bun/feed")
        ("zenn rust" "https://zenn.dev/topics/rust/feed")
        ("zenn vim" "https://zenn.dev/topics/vim/feed")
        ("zenn neovim" "https://zenn.dev/topics/neovim/feed")
        ("zenn scheme" "https://zenn.dev/topics/scheme/feed")
        ("zenn hono" "https://zenn.dev/topics/hono/feed")
        ("zenn react" "https://zenn.dev/topics/react/feed")
        ("zenn gcp" "https://zenn.dev/topics/googlecloud/feed")
        ("zenn aws" "https://zenn.dev/topics/aws/feed")
        ("techfeed" "https://techfeed.io/feeds/categories/all")
	("hacker news" "https://hnrss.org/frontpage")
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
	  ("c-a" . grugru))
	 (:evil-normal-state-map
	  ("c-x" . grugru-backward)))
  :config
  ;; ref: https://github.com/rocktakey/grugru/issues/44
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

;; (leaf folding-mode :require t)

(leaf rg
  :require t)

(leaf open-junk-file
  :require t
  :custom
  (open-junk-file-format . "/tmp/junk/%y_%m_%d_%h%m%s.")
  :bind (("c-x j" . open-junk-file)))

(leaf fold-this)

(leaf alert
  :config
  (setq alert-default-style 'libnotify))

(leaf dashboard
  :config
  (setq dashboard-startup-banner (expand-file-name "~/pictures/.emacs-logos/gnu_color_resize.png"))
  (setq dashboard-startup-banner 'logo))

(leaf aas
  ;; :hook (text-mode . aas-activate-for-major-mode)
  ;; :init
  ;; (aas-set-snippets 'global)
  ;; (aas-set-snippets 'markdown-mode)
  ;; (aas-set-snippets 'prog-mode)
  )

(leaf smartparens
  :config
  (smartparens-global-mode t))

(leaf vterm)

(leaf vterm-toggle
  :after evil
  :bind (("c-<return>" . (lambda ()
			   (interactive)
			   (vterm-toggle-insert-cd)
			   (vterm-toggle-insert-cd)))))

(leaf multi-vterm
  :config
  (setq multi-vterm-dedicated-window-height 50))

;; ai
 add-hook 'server-after-make-frame-hook
          (lambda ()
            (setenv "gemini_api_key" (get-secret "gemini.google.com")
            (setenv "openrouter_api_key" (get-secret "openrouter.ai"))
	    (setq gemini-apikey (get-secret "gemini.google.com"))))

(leaf gptel
  :config
  (setq
   ;; gptel-model 'starcoder2
   ;; gptel-backend (gptel-make-ollama "ollama"
   ;;                :host "localhost:11434"
   ;;                :stream t
   ;;                :models '(starcoder2)))

   gptel-model 'gemini-2.5-flash
   gptel-backend (gptel-make-gemini "gemini"
		   :key gemini-apikey
		   :stream t)))

;; ai codeing
(leaf aider
  :require t
  :custom
  (;; (aider-args . '("--watch-files" "--model" "gemini/gemini-2.0-flash"))
   (aider-args . '("--watch-files" "--model" "openrouter/anthropic/claude-3.5-sonnet"))
   ))

(leaf aidermacs
  :require t
  :config
  (setq aidermacs-watch-files t)
  :custom
  (;; (aidermacs-default-model . "gemini/gemini-2.0-flash")
   (aidermacs-default-model . "gemini/gemini-2.5-pro-preview-03-25")
   (aidermacs-watch-files . t)))
;; (aidermacs-default-model . "gemini/gemini-2.5-flash-preview-04-17")


(leaf mcp)

(leaf minimap
  :require t
  :custom ((minimap-window-location . 'right)
	   (minimap-minimum-width . 20)
	   (minimap-major-modes . '(prog-mode
				    markdown-mode
				    html-mode
				    fundamental-mode)))
  :bind ("c-x m" . minimap-mode)
  :config
  (minimap-mode 1))

(leaf rainbow-delimiters
  :hook
  (prog-mode-hook . rainbow-delimiters-mode))

(leaf ox-zenn
  :after org
  :require t)

(leaf verb)

(leaf quickrun)

;; ================ my extentions ================

(defun get-secret (host)
  "wrapper functino for auth-info"
  (require 'ht) 
  (let* ((found (cl-first (auth-source-search :host host
					      :user "coma")))
	 (credentials (when found
			(eval `(ht ,@(--map `(,it ,(plist-get found it))
                                            '(:user :secret :save-function))))))
	 (secret (when credentials
                   (ht-get credentials :secret))))

    (if (not secret)
	(progn (message (format "does not found %s credential." host))
	       "")
      (if (functionp secret)
          (funcall secret)
	secret))))

;; (defun nyan-region ()
;;   "選択範囲をにゃーんで置換する"
;;   (interactive)
;;   (when (use-region-p)
;;     (let* ((beg (region-beginning))
;;            (end (region-end)))
;;      (len (- end beg)
;;       (delete-region beg end)
;;       (cond ((= len 1) (insert "にゃ")))
;;       ((= len 2) (insert "にゃん"))
;;       (t (insert (format "にゃ%sん" (make-string (- len 3) ?ー))))))))

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

  (let* ((query (read-from-minibuffer "query? > ")))
   (url (concat "https://www.google.com/search?client=firefox-b-d&q=" (url-hexify-string query))
  
    (shell-command (concat "open " "'" url "'")))))

(defun home-manager ()
  (interactive)
  (start-process "home-manager-process"
     "*home-manager*"
     "home-manager"
     "switch"
     "--flake"
     ".#home"
     "-b"
     "backup"))

    ;; (set-process-sentinel proc
    ;;                           (lambda (process event)
    ;;                             (when (string= event "finished\n"))))

(defun all (pred lst)
  "returns t if all elements of the list satisfy the predicate."
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
  (let ((beg (save-excursion (skip-chars-backward "a-za-z") (point)))
        (end (point))
        (candidates gitmoji--codes))
    (list beg end candidates :exclusive 'no)))

;; collect gitmoji when startup
;; (add-hook 'emacs-startup-hook 'setup-gitmoji)
;; enable at git-commit-mode

;; display character count in modeline
(defun update-buffer-char-count ()
  (interactive)
  (format " [%d] " (buffer-size)))

(defun mode-line-time ()
  ;; update every second
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

;; for diary
(setq blog-repo "/home/coma/.ghq/github.com/comamoca/blog/")

(defun latest-diary ()
  "open latest diary. this function call in `src/blog/` directory at blog repository."
  (interactive)
  (let* ((date (format-time-string "%y-%m-%d"))
         (file-name (format "%s-diary.md" date))
         (path (concat (expand-file-name "src/blog/" blog-repo) file-name)))
    (find-file path)
    (if (= (buffer-size) 0)
	(tempel-insert 'diary))))

(defun new-blog-article ()
  "open latest diary. this function call in `src/blog/` directory at blog repository."
  (interactive)
  (let* ((date (format-time-string "%y-%m-%d"))
         (slug (read-string "slug > "))
         (file-name (format "%s-%s.md" date slug))
         (path (concat (expand-file-name "src/blog/" blog-repo) file-name)))
    ;; (projectile-switch-project-by-name "blog")
    (find-file path)))

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
	 (mdfiles (cl-remove-if-not (lambda (file))))
	 (articles (cl-remove-if (lambda (file)))
		   (string-match "-diary.md$" file
				 files))
	 (selected (completing-read "blog " articles)))
    (find-file (expand-file-name selected src-dir)))) 

(defun org-paste-image ()
  (interactive)
  (setq filename (concat
                  (expand-file-name (format-time-string "%y-%m-%d-%h%m%s")
                   "~/.ghq/github.com/comamoca/org/imgs") ".png"))
  (shell-command (concat  "wl-paste -t image/png > " filename))
  (insert (concat "[[" filename "]]"))
  (org-display-inline-images))

(defun blog-paste-image ()
  (interactive)
  (setq fullpath (concat
                  (expand-file-name (format-time-string "%y-%m-%d-%h%m%s")
				    "~/.ghq/github.com/comamoca/blog/src/images") ".png"))
  (shell-command (concat  "wl-paste -t image/png > " fullpath))
  (insert (concat "![](/images/" (file-name-nondirectory fullpath) ")"))
  (org-display-inline-images))


;; gauche
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
  (let* ((node-items (mapcar (lambda (node)))
             (cons (org-roam-node-title node) node)) (org-roam-node-list))
   (select-node-title (consult--read)
        (mapcar #'car node-items))
   (select-node (cdr (assoc select-node-title node-items))

    (find-file (org-roam-node-file select-node)))))

;; pinentry emacs
(defun pinentry-emacs (desc prompt ok error)
  (let ((str (read-passwd (concat (replace-regexp-in-string "%22" "\"" (replace-regexp-in-string "%0a" "\n" desc)) prompt ": "))))
    str))

;; initel function that behaves like `:e $myvimrc`
(defun initel ()
  (interactive)
  (find-file user-init-file))

;; ================ my configuratons ================

;; ediff
(setq ediff-window-setup-function 'ediff-setup-windows-plain)

;; font
(add-to-list 'default-frame-alist
                       '(font . "udev gothic nf-14"))

;; for auth-info
(setq auth-sources '("~/.emacs.d/.authinfo.gpg"))
(setq create-lockfiles nil)

;; for lsp-mode
(setq gc-cons-threshold 100000000)
(setq read-process-output-max (* 1024 1024))

;; key mapping
(define-key global-map (kbd "c-x s") 'blackening-region)
(define-key global-map (kbd "c-;") 'comment-dwim)

;; minibuffe
(define-key minibuffer-local-map (kbd "c-h") 'delete-char)
(define-key minibuffer-local-ns-map (kbd "c-h") 'delete-char)
(define-key minibuffer-local-completion-map (kbd "c-h") 'delete-char)
(define-key minibuffer-local-must-match-map (kbd "c-h") 'delete-char)
(define-key minibuffer-local-filename-completion-map (kbd "c-h") 'delete-char)

;; enable debug
(setq debug-on-error nil)

;; custom modeline
(mode-line-format-update)

;; when org-mode
(add-hook 'org-mode
    (lambda ()
      (local-set-key evil-insert-state-map (kbd "c-h") #'org-insert-heading)))

(electric-pair-mode 1)

(global-hl-line-mode t)

(setq vc-follow-symlinks t)
(setq browse-url-generic-program "firefox")
(setq ring-bell-function 'ignore)

(setq display-warning-minimum-level :error)

;; disable to create backupfile
(setq make-backup-files nil)

;; disable to auto save
(setq auto-save-default nil)

;; copy & paste with wl-clipboard
;; ref: https://gist.github.com/yorickvp/6132f237fbc289a45c808d8d75e0e1fb
(setenv "wayland_display" "wayland-1")

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
  :bind (("c-c e" . macrostep-expand)))

;; (provide 'init)
(put 'narrow-to-region 'disabled nil)
(custom-set-variables
 ;; custom-set-variables was added by custom.
 ;; if you edit it by hand, you could mess it up, so be careful.
 ;; your init file should contain only one such instance.
 ;; if there is more than one, they won't work right.
 '(skk-jisyo-edit-user-accepts-editing t))
(custom-set-faces)
 ;; custom-set-faces was added by custom.
 ;; if you edit it by hand, you could mess it up, so be careful.
 ;; your init file should contain only one such instance.
 ;; if there is more than one, they won't work right.
 

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

;; theme
(leaf catppuccin-theme 
  :preface
  :config
  (load-theme 'catppuccin t))

;; minibuffer ui
(leaf vertico
  :require orderless
  :config
  (defvar vertico-count 10)
  ;; completion style config
  (setq completion-styles '(orderless basic)
	completion-category-overrides '((file (styles basic partial-completion))))
  :init 
  (vertico-mode))

;; completion styles
(leaf orderless)

(leaf hotfuzz)

;; completing read functions
(leaf consult
  :require t
  :after evil
  :bind ((:evil-normal-state-map
	  ("c-l" . consult-line)
	  ("c-i" . consult-buffer)))
  :bind* (("c-." . embark-act)))

(leaf consult-dir)

;; embark
(leaf embark
  :after evil
  :bind ((:evil-normal-state-map
	  ("c-." . embark-act)
	  ("c--" . embark-export))
	 (:evil-insert-state-map
	  ("c-." . embark-act))))

;; affe
(leaf affe)

;; for consult
(leaf embark-consult
  :bind ((:minibuffer-mode-map
	  ("m-." . embark-dwin)
	  ("c-." . embark-act))))

;; vim keybind
(leaf evil
  :require t
  :bind ((:evil-normal-state-map
	  ("c-k" . evil-scroll-up)
	  ("c-j" . evil-scroll-down))
	 (:evil-insert-state-map
	  ;; ("c-j" . newline-and-indent)
	  ("c-h" . backward-char)))
 
  :config
  (evil-mode 1))

;; structured editing 
(leaf puni
  :config
  (global-set-key (kbd "c--") 'puni-expand-region)
  :bind ((:evil-insert-state-map
	  ("s" . nil)
	  ;; ("sd" . puni-splice)
	  ("c-i" . puni-mark-sexp-at-point)
	  ("c-p" . puni-slurp-forward)
	  ("c-n" . puni-barf-forward)))
  :init
  (puni-global-mode))

;; indent guides
(leaf highlight-indent-guides)

;; treesitter
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
  (add-to-list 'auto-mode-alist '("dockerfile" . dockerfile-ts-mode)))

(leaf treesit-auto
  :require t
  :custom
  ((treesit-auto-install . t)
   (treesit-extra-load-path . `(,(expand-file-name "~/.cache/dpp/_generated/nvim-treesitter/parser"))))
  :config  
  (global-treesit-auto-mode)
  ;; (treesit-auto-install 'prompt)
  ;; (treesit-auto-add-to-auto-mode-alist 'all)
  )

;; for envrc
(leaf envrc)

;; calendar 
(leaf calendar)

;; org-mode
(leaf org
  :after calendar-mode
  :custom
  ((org-todo-keywords .
		      '((sequence "todo(t)" "pending(p)" "|" "done(d)" "canceled(c)")))
   (org-default-notes-file . "notes.org")
   `(org-directory . ,(expand-file-name "~/.ghq/github.com/comamoca/org"))
   `(diary-file-path . ,(format-time-string "diary/%y/%m-%d.org"))
   `(memo-file-path . ,(format-time-string "memo/%y/%m/%d.org"))
   `(diary-path . ,(concat org-directory "/diary"))
   (org-publish-use-timestamps-flag . nil)

   ;; org-capture
   (org-capture-templates .
			  '(("d" "diary" plain (file diary-file-path)
			     "** 今日やったこと\n\n** 明日以降やりたいこと")
			    ("m" "memo" plain (file memo-file-path) "")))

   (org-publish-project-alist .
			      '(("diary"
				 :base-directory "~/.ghq/github.com/comamoca/org/diary"
				 :base-extension "org"  
				 :recursive t
				 :publishing-directory  "~/.ghq/github.com/comamoca/org/dist"
				 :publishing-function org-html-publish-to-html
				 :include ("index.org")
				 :exclude ())
     
				("note"
				 :base-directory "~/.ghq/github.com/comamoca/org/note"
				 :base-extension "org"  
				 :recursive t
				 :publishing-directory  "~/.ghq/github.com/comamoca/org/note/dist"
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
  (set-language-environment "japanese")
  (prefer-coding-system 'utf-8)
  (set-default 'buffer-file-coding-system 'utf-8)

  (org-babel-do-load-languages
   'org-babel-load-languages
   '((c . t)
     (shell . t)
     (python . t)
     (clojure . t)
     (hy . t)
     (ruby . t)
     (ledger . t)))
  :bind ((:calendar-mode-map
	  ("c-c c" . org-capture-from-calendar)))
  :init
  ;; org-calendar
  ;; (with-eval-after-load 'calendar
  ;;     (define-key calendar-mode-map (kbd "c-c c") 'org-capture-from-calendar))
  )

;; org-journal
(leaf org-journal
  :after org
  :custom
  ((org-journal-time-format . "")
   (org-journal-time-prefix . "")
   `(org-journal-dir . ,(concat org-directory (format-time-string "/diary/%y")))
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

;; deft
;; for search roam files.
(leaf deft
  :after org-roam-mode
  :custom
  ((deft-extensions . '("txt" "tex" "org"))
   `(deft-directory . ,(expand-file-name "roam" org-directory))))

(leaf org-roam-ui)

;; org-bullets
(leaf org-bullets
  :after org
  ;; :init
  ;; (org-bullets-mode 1)
  )

;; org-modern
(leaf org-modern
  :after
  :init
  (with-eval-after-load 'org (global-org-modern-mode)))

(leaf org-modern-indent)

;; org-babel
(leaf ob-hy)

(leaf org-nix-shell)

;; magit
(leaf magit
  :custom
  ((transient-default-level . 5))
  :bind ((:global-map
	  ("c-x g" . magit-status))
	 (:magit-mode-map
	  ("/" . isearch-forward))))

;; forge
(leaf forge
  :after magit)

;; skk
(leaf ddskk
  :custom ((default-input-method . "japanease-skk")
	   (skk-auto-insert-paren . t)
	   (skk-comp-mode . t)
	   (skk-delete-implies-kakutei . nil))
  :config
  (skk-latin-mode 1)
  (global-set-key (kbd "c-x c-j") 'skk-mode)
  (global-set-key (kbd "<henkan>") 'skk-kakutei)
  (global-set-key (kbd "<muhenkan>") 'skk-latin-mode))

(leaf ddskk-posframe
  :global-minor-mode t)

;; common lisp
(leaf slime
  :config
  (defvar inferior-lisp-program "sbcl"))

(leaf sly
  :config)
  ;; (defvar inferior-lisp-program "sbcl")

(leaf sly-asdf)

;; clojure
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
  "a linter for prose."
  :command ("textlint" "--format" "unix" source-inplace)
  :error-patterns
  ((warning line-start (file-name) ":" line ":" column ": "
      (id (one-or-more (not (any " "))))
      (message (one-or-more not-newline)
        (zero-or-more "\n" (any " ") (one-or-more not-newline)))
      line-end))
  :modes (text-mode markdown-mode gfm-mode org-mode web-mode))

;; copilot
(leaf copilot
  :bind ((:copilot-completion-map
	  ("tab" . copilot-accept-completion)))
  :config
  (add-to-list 'copilot-major-mode-alist '("enh-ruby" . "ruby"))
  (add-to-list 'copilot-major-mode-alist '("typescript-ts-mode" . "typescript")))

;; lsp
(leaf lsp-bridge
  :require t
  :custom
  ((acm-enable-capf . t)
   (acm-frame-background-dark-color . "#313244"))
  :config
  (setq lsp-bridge-get-single-lang-server-by-project
	(lambda (project-path file-path)
	  (message project-path)
	  (when (or (expand-file-name "package.json" project-path))
	    "typescript-language-server")
	  "deno"))
  :init
  (global-lsp-bridge-mode))



;; lso-mode
;; (leaf lsp-mode
;;   :require t
;;   :custom
;;   ((lsp-completion-provider . :none))
;;   :config
;;   (setenv "lsp_use_plists" "true")

;;   (define-key evil-normal-state-map (kbd "k") 'lsp-ui-doc-glance)

;;   (add-to-list 'lsp-language-id-configuration
;; 	       '(nix-mode . "nil")
;; 	       '(python-mode . "python"))

;;   (defun corfu-lsp-setup ()
;;     (setq completion-at-point-functions '(lsp-completion-at-point))
;;     (setq-local completion-styles '(orderless)
;; 		completion-category-defaults nil))

;;   (add-hook 'lsp-mode-hook #'corfu-lsp-setup)
;;   (add-hook 'prog-mode-hook #'lsp-deferred))

;; ;; lsp booster
;; (defun lsp-booster--advice-json-parse (old-fn &rest args)
;;   "try to parse bytecode instead of json."
;;   (or
;;    (when (equal (following-char) ?#)
;;      (let ((bytecode (read (current-buffer))))
;;        (when (byte-code-function-p bytecode)
;;          (funcall bytecode))))
;;    (apply old-fn args)))

;; (advice-add (if (progn (require 'json)
;;                        (fboundp 'json-parse-buffer))
;;                 'json-parse-buffer
;;               'json-read)
;;             :around
;;             #'lsp-booster--advice-json-parse)

;; (defun lsp-booster--advice-final-command (old-fn cmd &optional test?)
;;   "prepend emacs-lsp-booster command to lsp cmd."
;;   (let ((orig-result (funcall old-fn cmd test?)))
;;     (if (and (not test?)                             ;; for check lsp-server-present?
;;              (not (file-remote-p default-directory)) ;; see lsp-resolve-final-command, it would add extra shell wrapper
;;              lsp-use-plists
;;              (not (functionp 'json-rpc-connection))  ;; native json-rpc
;;              (executable-find "emacs-lsp-booster"))
;;         (progn
;;           (when-let ((command-from-exec-path (executable-find (car orig-result))))  ;; resolve command from exec-path (in case not found in $path)
;;             (setcar orig-result command-from-exec-path))
;;           (message "using emacs-lsp-booster for %s!" orig-result)
;;           (cons "emacs-lsp-booster" orig-result))
;;       orig-result)))

;; (advice-add 'lsp-resolve-final-command :around #'lsp-booster--advice-final-command)

;; eglot
;; (defun deno-project-p ()
;;   "predicate for determining if the open project is a deno one."
;;   (let ((p-root (nth 2 (project-current))))
;;     (or (file-exists-p (expand-file-name "deno.json" default-directory))
;; 	(file-exists-p (expand-file-name "deno.jsonc" default-directory)))))

;; (defun node-project-p ()
;;   "predicate for determining if the open project is a deno one."
;;   (let ((p-root (nth 2 (project-current))))
;;     (file-exists-p (expand-file-name "package.json" default-directory))))

;; (defun es-server-program (_)
;;   "decide which server to use for ecma script based on project characteristics."
;;   (cond ((deno-project-p) '("deno" "lsp" :initializationoptions (:enable t :lint t)))
;;         ((node-project-p) '("typescript-language-server" "--stdio"))
;;         (t nil)))

;; (leaf eglot
;;   :hook
;;   (c++-mode . eglot-ensure)
;;   (sh-mode . eglot-ensure)
;;   (python-mode . eglot-ensure)
;;   (html-mode . eglot-ensure)
;;   (cmake-mode . eglot-ensure)
;;   (bitbake-mode . eglot-ensure)
;;   (typescript-ts-mode . eglot-ensure)
;;   :config
;;   ;; (add-to-list 'eglot-server-programs '((bitbake-mode) "bitbake-language-server"))
;;   (add-to-list 'eglot-server-programs '((js-mode typescript-mode) . es-server-program))
;;   (add-to-list 'eglot-server-programs '(gleam-ts-mode . ("lspx" "--lsp" "gleam lsp")))
;;   :bind (("m-t" . xref-find-definitions)
;; 	 ("m-r" . xref-find-references)
;; 	 ("c-t" . xref-go-back)))

;; (leaf eglot-booster
;;   :after eglot
;;   :config (eglot-booster-mode))

;; auto formatting
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
 
;; lua support
(leaf lua-mode)

;; completion
(leaf corfu
  :custom
  ((corfu-cycle . t)
  (corfu-auto . t)
  (corfu-auto-prefix . 1))
  :init
  (global-corfu-mode))


;; cursor moation
(leaf avy
  :config
  (define-key evil-normal-state-map (kbd "spc k") #'avy-goto-line))

;; completion soruce
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

;; hydra
(leaf hydra)
(leaf hydra-posframe
  ;; :require t
  ;; :vc (:url "https://github.com/ladicle/hydra-posframe")

  :init
  ;; for hydra
  (define-key evil-normal-state-map (kbd "spc w") #'manage-window-hydra/body)

  :hook
  (add-hook 'after-init-hook 'hydra-posframe-mode))

(leaf major-mode-hydra)

;; for nix
(pretty-hydra-define nix-flake-hydra
  (:separator "-" :title "nix flake" :forigen-key warn :quit-key "q" :exit t)
  ("build"
   (("b" nix-flake-build-default "build"))

   "update"
   (("u" nix-flake-update "update"))))

;; for manage window
(pretty-hydra-define manage-window-hydra
  (:separator "-" :title "manage window" :forigen-key warn :quit-key "q" :exit t)
  ("1"
   (("a" delete-other-windows "delte other windwos"))

   "2"
   (("s" split-window-below "horizontal split"))

   "3"
   (("d" split-window-right "vertical split"))

   "0"
   (("f" delete-window "delete window"))))

(pretty-hydra-define org-hydra
  (:separator "-" :title "nix flake" :forigen-key warn :quit-key "q" :exit t)
  ("roam"
   (("a" org-roam-node-find "roam"))

   "capture"
   (("s" org-capture "capture"))))
    

;; (pretty-hydra-define org-roam-hydra
;;   (:separator "-" :title "org-roam" :forigen-key warn :quit-key "q" :exit t)
;;   ("find"
;;    (("a" 'org-roam-node-find "find node"))

;;    ""
;;    (("s" 'org-roam- ""))

;;    ""
;;    (("d"  ""))

;;    ""
;;    (("f"  ""))
;;     ))

;; transient dispatcher
(leaf transient-dwim
  :bind ("c-=" . transient-dwim-dispatch))

;; tree filer
(leaf neotree
  :custom
  (neo-smart-open . t)
  (projectile-switch-project-action . 'neotree-projectile-action)
  :config
  (progn
    (evil-define-key 'normal neotree-mode-map (kbd "q") 'neotree-hide)
    (evil-define-key 'normal neotree-mode-map (kbd "l") 'neotree-enter)
    (evil-define-key 'normal neotree-mode-map (kbd "ret") 'neotree-enter)
    (evil-define-key 'normal neotree-mode-map (kbd "h") 'neotree-enter)
    (evil-define-key 'normal neotree-mode-map (kbd "g") 'neotree-refresh)
    (evil-define-key 'normal neotree-mode-map (kbd "j") 'neotree-next-line)
    (evil-define-key 'normal neotree-mode-map (kbd "k") 'neotree-previous-line)
    (evil-define-key 'normal neotree-mode-map (kbd "a") 'neotree-stretch-toggle)
    (evil-define-key 'normal neotree-mode-map (kbd "h") 'neotree-hidden-file-toggle)
    (evil-define-key 'normal neotree-mode-map (kbd "n") 'neotree-create-node)
    (evil-define-key 'normal neotree-mode-map (kbd "k") 'neotree-create-node)
    (evil-define-key 'normal neotree-mode-map (kbd "d") 'neotree-delete-node)
    (evil-define-key 'normal neotree-mode-map (kbd "m") 'neotree-rename-node))
  
  ;; for neotree
  (define-key evil-normal-state-map (kbd "spc f") #'neotree-toggle))
  

;; translate
(leaf google-translate
  :require t
  :custom
  (google-translate-translation-directions-alist . '(("en" . "ja")
                                                     ("ja" . "en"))))
;; wakatime
(leaf wakatime-mode
  :init
  (global-wakatime-mode))

;; typst

;; preview
(leaf typst-preview
  ;; :vc (:url "https://github.com/havarddj/typst-preview.el")
  ;; :require t
  :config
  (setq typst-preview-browser "firefox"))

;; ruby support
(leaf inf-ruby)

(leaf enh-ruby-mode)

;; python support
(add-hook 'python-ts-mode-hook (lambda ()
				 (require 'python-mode)))

;; language supports

;; dotnet
(leaf dotnet
  :after csharp-mode)

;; c#
(leaf csharp-mode)

;; nix support
(leaf nix-mode
  :hook
  (nix-ts-mode))

;; scala suppport
(leaf scala-mode
  :interpreter ("scala" . scala-mode))


(leaf sbt-mode
  :commands sbt-start sbt-command
  :config
  (substitute-key-definition
   'minibuffer-complete-word
   'self-insert-command
   minibuffer-local-completion-map)

   (setq sbt:program-options '("-dsbt.supershell=false")))

;; astro support
(leaf astro-ts-mode)

;; elixir support
(leaf inf-elixir)
(leaf mix)

(leaf elixir-ts-mode
  :hook ((elixir-ts-mode . mix-minor-mode)))

;; kdl supports
(leaf kdl-ts-mode)

;; gleam support
(leaf gleam-ts-mode
  :require t
  :hook gleam-on-save-mode)

;; markdown suppot
(leaf markdown-mode
  :hook
  (add-to-list 'completion-at-point-functions #'cape-emoji))

;; projectile
(defun update-projectlist ()
  (interactive)
  (setq projectile-known-projects
         (mapcar
          (lambda (x) (abbreviate-file-name x))
          (split-string (shell-command-to-string "ghq list --full-path")))))

(leaf projectile 
  :config
  (define-key evil-normal-state-map (kbd "m-g") #'projectile-switch-project)
  (define-key evil-normal-state-map (kbd "c-o") #'projectile-find-file)
  :init
  (when (executable-find "ghq")
   (update-projectlist)))

;; migemo
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

;; nyan-mode
(leaf nyan-mode
  :init
  (progn (nyan-mode)
   (nyan-start-animation)))

;; snippets
(leaf tempel
  :require t
  :bind ((:evil-insert-state-map
	  ("m-a" . tempel-done)))
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

;; http request
(leaf request)
(leaf plz)

(autoload 'newsticker-start "newsticker" "start newsticker" t)
(autoload 'newsticker-show-news "newsticker" "goto newsticker buffer" t)

(setq newsticker-url-list
      '(("gleam weekly" "https://gleamweekly.com/atom.xml")
        ("zenn gleam" "https://zenn.dev/topics/gleam/feed")
	("gleam releases" "https://github.com/gleam-lang/gleam/releases.atom")
	("zenn trend" "https://zenn.dev/feed")
	("zenn emacs" "https://zenn.dev/topics/emacs/feed")
        ("zenn ts" "https://zenn.dev/topics/typescript/feed")
        ("zenn cl" "https://zenn.dev/topics/commonlisp/feed")
        ("zenn deno" "https://zenn.dev/topics/deno/feed")
        ("zenn bun" "https://zenn.dev/topics/bun/feed")
        ("zenn rust" "https://zenn.dev/topics/rust/feed")
        ("zenn vim" "https://zenn.dev/topics/vim/feed")
        ("zenn neovim" "https://zenn.dev/topics/neovim/feed")
        ("zenn scheme" "https://zenn.dev/topics/scheme/feed")
        ("zenn hono" "https://zenn.dev/topics/hono/feed")
        ("zenn react" "https://zenn.dev/topics/react/feed")
        ("zenn gcp" "https://zenn.dev/topics/googlecloud/feed")
        ("zenn aws" "https://zenn.dev/topics/aws/feed")
        ("techfeed" "https://techfeed.io/feeds/categories/all")
	("hacker news" "https://hnrss.org/frontpage")
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
	  ("c-a" . grugru))
	 (:evil-normal-state-map
	  ("c-x" . grugru-backward)))
  :config
  ;; ref: https://github.com/rocktakey/grugru/issues/44
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

;; (leaf folding-mode :require t)

(leaf rg
  :require t)

(leaf open-junk-file
  :require t
  :custom
  (open-junk-file-format . "/tmp/junk/%y_%m_%d_%h%m%s.")
  :bind (("c-x j" . open-junk-file)))

(leaf fold-this)

(leaf alert
  :config
  (setq alert-default-style 'libnotify))

(leaf dashboard
  :config
  (setq dashboard-startup-banner (expand-file-name "~/pictures/.emacs-logos/gnu_color_resize.png"))
  (setq dashboard-startup-banner 'logo))

(leaf aas
  ;; :hook (text-mode . aas-activate-for-major-mode)
  ;; :init
  ;; (aas-set-snippets 'global)
  ;; (aas-set-snippets 'markdown-mode)
  ;; (aas-set-snippets 'prog-mode)
  )

(leaf smartparens
  :config
  (smartparens-global-mode t))

(leaf vterm)

(leaf vterm-toggle
  :after evil
  :bind (("c-<return>" . (lambda ()
			   (interactive)
			   (vterm-toggle-insert-cd)
			   (vterm-toggle-insert-cd)))))

(leaf multi-vterm
  :config
  (setq multi-vterm-dedicated-window-height 50))

;; ai
 add-hook 'server-after-make-frame-hook
          (lambda ()
            (setenv "gemini_api_key" (get-secret "gemini.google.com")
            (setenv "openrouter_api_key" (get-secret "openrouter.ai"))
	    (setq gemini-apikey (get-secret "gemini.google.com"))))

(leaf gptel
  :config
  (setq
   ;; gptel-model 'starcoder2
   ;; gptel-backend (gptel-make-ollama "ollama"
   ;;                :host "localhost:11434"
   ;;                :stream t
   ;;                :models '(starcoder2)))

   gptel-model 'gemini-2.5-flash
   gptel-backend (gptel-make-gemini "gemini"
		   :key gemini-apikey
		   :stream t)))

;; ai codeing
(leaf aider
  :require t
  :custom
  (;; (aider-args . '("--watch-files" "--model" "gemini/gemini-2.0-flash"))
   (aider-args . '("--watch-files" "--model" "openrouter/anthropic/claude-3.5-sonnet"))
   ))

(leaf aidermacs
  :require t
  :config
  (setq aidermacs-watch-files t)
  :custom
  (;; (aidermacs-default-model . "gemini/gemini-2.0-flash")
   (aidermacs-default-model . "gemini/gemini-2.5-pro-preview-03-25")
   (aidermacs-watch-files . t)))
;; (aidermacs-default-model . "gemini/gemini-2.5-flash-preview-04-17")


(leaf mcp)

(leaf minimap
  :require t
  :custom ((minimap-window-location . 'right)
	   (minimap-minimum-width . 20)
	   (minimap-major-modes . '(prog-mode
				    markdown-mode
				    html-mode
				    fundamental-mode)))
  :bind ("c-x m" . minimap-mode)
  :config
  (minimap-mode 1))

(leaf rainbow-delimiters
  :hook
  (prog-mode-hook . rainbow-delimiters-mode))

(leaf ox-zenn
  :after org
  :require t)

(leaf verb)

(leaf quickrun)

;; ================ my extentions ================

(defun get-secret (host)
  "wrapper functino for auth-info"
  (require 'ht) 
  (let* ((found (cl-first (auth-source-search :host host
					      :user "coma")))
	 (credentials (when found
			(eval `(ht ,@(--map `(,it ,(plist-get found it))
                                            '(:user :secret :save-function))))))
	 (secret (when credentials
                   (ht-get credentials :secret))))

    (if (not secret)
	(progn (message (format "does not found %s credential." host))
	       "")
      (if (functionp secret)
          (funcall secret)
	secret))))

;; (defun nyan-region ()
;;   "選択範囲をにゃーんで置換する"
;;   (interactive)
;;   (when (use-region-p)
;;     (let* ((beg (region-beginning))
;;            (end (region-end)))
;;      (len (- end beg)
;;       (delete-region beg end)
;;       (cond ((= len 1) (insert "にゃ")))
;;       ((= len 2) (insert "にゃん"))
;;       (t (insert (format "にゃ%sん" (make-string (- len 3) ?ー))))))))

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

  (let* ((query (read-from-minibuffer "query? > ")))
   (url (concat "https://www.google.com/search?client=firefox-b-d&q=" (url-hexify-string query))
  
    (shell-command (concat "open " "'" url "'")))))

(defun home-manager ()
  (interactive)
  (start-process "home-manager-process"
     "*home-manager*"
     "home-manager"
     "switch"
     "--flake"
     ".#home"
     "-b"
     "backup"))

    ;; (set-process-sentinel proc
    ;;                           (lambda (process event)
    ;;                             (when (string= event "finished\n"))))

(defun all (pred lst)
  "returns t if all elements of the list satisfy the predicate."
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
  (let ((beg (save-excursion (skip-chars-backward "a-za-z") (point)))
        (end (point))
        (candidates gitmoji--codes))
    (list beg end candidates :exclusive 'no)))

;; collect gitmoji when startup
;; (add-hook 'emacs-startup-hook 'setup-gitmoji)
;; enable at git-commit-mode

;; display character count in modeline
(defun update-buffer-char-count ()
  (interactive)
  (format " [%d] " (buffer-size)))

(defun mode-line-time ()
  ;; update every second
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

;; for diary
(setq blog-repo "/home/coma/.ghq/github.com/comamoca/blog/")

(defun latest-diary ()
  "open latest diary. this function call in `src/blog/` directory at blog repository."
  (interactive)
  (let* ((date (format-time-string "%y-%m-%d"))
         (file-name (format "%s-diary.md" date))
         (path (concat (expand-file-name "src/blog/" blog-repo) file-name)))
    (find-file path)
    (if (= (buffer-size) 0)
	(tempel-insert 'diary))))

(defun new-blog-article ()
  "open latest diary. this function call in `src/blog/` directory at blog repository."
  (interactive)
  (let* ((date (format-time-string "%y-%m-%d"))
         (slug (read-string "slug > "))
         (file-name (format "%s-%s.md" date slug))
         (path (concat (expand-file-name "src/blog/" blog-repo) file-name)))
    ;; (projectile-switch-project-by-name "blog")
    (find-file path)))

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
	 (mdfiles (cl-remove-if-not (lambda (file))))
	 (articles (cl-remove-if (lambda (file)))
		   (string-match "-diary.md$" file
				 files))
	 (selected (completing-read "blog " articles)))
    (find-file (expand-file-name selected src-dir)))) 

(defun org-paste-image ()
  (interactive)
  (setq filename (concat
                  (expand-file-name (format-time-string "%y-%m-%d-%h%m%s")
                   "~/.ghq/github.com/comamoca/org/imgs") ".png"))
  (shell-command (concat  "wl-paste -t image/png > " filename))
  (insert (concat "[[" filename "]]"))
  (org-display-inline-images))

(defun blog-paste-image ()
  (interactive)
  (setq fullpath (concat
                  (expand-file-name (format-time-string "%y-%m-%d-%h%m%s")
				    "~/.ghq/github.com/comamoca/blog/src/images") ".png"))
  (shell-command (concat  "wl-paste -t image/png > " fullpath))
  (insert (concat "![](/images/" (file-name-nondirectory fullpath) ")"))
  (org-display-inline-images))


;; gauche
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
  (let* ((node-items (mapcar (lambda (node)))
             (cons (org-roam-node-title node) node)) (org-roam-node-list))
   (select-node-title (consult--read)
        (mapcar #'car node-items))
   (select-node (cdr (assoc select-node-title node-items))

    (find-file (org-roam-node-file select-node)))))

;; pinentry emacs
(defun pinentry-emacs (desc prompt ok error)
  (let ((str (read-passwd (concat (replace-regexp-in-string "%22" "\"" (replace-regexp-in-string "%0a" "\n" desc)) prompt ": "))))
    str))

;; initel function that behaves like `:e $myvimrc`
(defun initel ()
  (interactive)
  (find-file user-init-file))

;; ================ my configuratons ================

;; ediff
(setq ediff-window-setup-function 'ediff-setup-windows-plain)

;; font
(add-to-list 'default-frame-alist
                       '(font . "udev gothic nf-14"))

;; for auth-info
(setq auth-sources '("~/.emacs.d/.authinfo.gpg"))
(setq create-lockfiles nil)

;; for lsp-mode
(setq gc-cons-threshold 100000000)
(setq read-process-output-max (* 1024 1024))

;; key mapping
(define-key global-map (kbd "c-x s") 'blackening-region)
(define-key global-map (kbd "c-;") 'comment-dwim)

;; minibuffe
(define-key minibuffer-local-map (kbd "c-h") 'delete-char)
(define-key minibuffer-local-ns-map (kbd "c-h") 'delete-char)
(define-key minibuffer-local-completion-map (kbd "c-h") 'delete-char)
(define-key minibuffer-local-must-match-map (kbd "c-h") 'delete-char)
(define-key minibuffer-local-filename-completion-map (kbd "c-h") 'delete-char)

;; enable debug
(setq debug-on-error nil)

;; custom modeline
(mode-line-format-update)

;; when org-mode
(add-hook 'org-mode
    (lambda ()
      (local-set-key evil-insert-state-map (kbd "c-h") #'org-insert-heading)))

(electric-pair-mode 1)

(global-hl-line-mode t)

(setq vc-follow-symlinks t)
(setq browse-url-generic-program "firefox")
(setq ring-bell-function 'ignore)

(setq display-warning-minimum-level :error)

;; disable to create backupfile
(setq make-backup-files nil)

;; disable to auto save
(setq auto-save-default nil)

;; copy & paste with wl-clipboard
;; ref: https://gist.github.com/yorickvp/6132f237fbc289a45c808d8d75e0e1fb
(setenv "wayland_display" "wayland-1")

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
  :bind (("c-c e" . macrostep-expand)))

;; (provide 'init)
(put 'narrow-to-region 'disabled nil)
(custom-set-variables
 ;; custom-set-variables was added by custom.
 ;; if you edit it by hand, you could mess it up, so be careful.
 ;; your init file should contain only one such instance.
 ;; if there is more than one, they won't work right.
 '(skk-jisyo-edit-user-accepts-editing t))
(custom-set-faces)
 ;; custom-set-faces was added by custom.
 ;; if you edit it by hand, you could mess it up, so be careful.
 ;; your init file should contain only one such instance.
 ;; if there is more than one, they won't work right.
 

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

;; theme
(leaf catppuccin-theme 
  :preface
  :config
  (load-theme 'catppuccin t))

;; minibuffer ui
(leaf vertico
  :require orderless
  :config
  (defvar vertico-count 10)
  ;; completion style config
  (setq completion-styles '(orderless basic)
	completion-category-overrides '((file (styles basic partial-completion))))
  :init 
  (vertico-mode))

;; completion styles
(leaf orderless)

(leaf hotfuzz)

;; completing read functions
(leaf consult
  :require t
  :after evil
  :bind ((:evil-normal-state-map
	  ("c-l" . consult-line)
	  ("c-i" . consult-buffer)))
  :bind* (("c-." . embark-act)))

(leaf consult-dir)

;; embark
(leaf embark
  :after evil
  :bind ((:evil-normal-state-map
	  ("c-." . embark-act)
	  ("c--" . embark-export))
	 (:evil-insert-state-map
	  ("c-." . embark-act))))

;; affe
(leaf affe)

;; for consult
(leaf embark-consult
  :bind ((:minibuffer-mode-map
	  ("m-." . embark-dwin)
	  ("c-." . embark-act))))

;; vim keybind
(leaf evil
  :require t
  :bind ((:evil-normal-state-map
	  ("c-k" . evil-scroll-up)
	  ("c-j" . evil-scroll-down))
	 (:evil-insert-state-map
	  ;; ("c-j" . newline-and-indent)
	  ("c-h" . backward-char)))
 
  :config
  (evil-mode 1))

;; structured editing 
(leaf puni
  :config
  (global-set-key (kbd "c--") 'puni-expand-region)
  :bind ((:evil-insert-state-map
	  ("s" . nil)
	  ;; ("sd" . puni-splice)
	  ("c-i" . puni-mark-sexp-at-point)
	  ("c-p" . puni-slurp-forward)
	  ("c-n" . puni-barf-forward)))
  :init
  (puni-global-mode))

;; indent guides
(leaf highlight-indent-guides)

;; treesitter
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
  (add-to-list 'auto-mode-alist '("dockerfile" . dockerfile-ts-mode)))

(leaf treesit-auto
  :require t
  :custom
  ((treesit-auto-install . t)
   (treesit-extra-load-path . `(,(expand-file-name "~/.cache/dpp/_generated/nvim-treesitter/parser"))))
  :config  
  (global-treesit-auto-mode)
  ;; (treesit-auto-install 'prompt)
  ;; (treesit-auto-add-to-auto-mode-alist 'all)
  )

;; for envrc
(leaf envrc)

;; calendar 
(leaf calendar)

;; org-mode
(leaf org
  :after calendar-mode
  :custom
  ((org-todo-keywords .
		      '((sequence "todo(t)" "pending(p)" "|" "done(d)" "canceled(c)")))
   (org-default-notes-file . "notes.org")
   `(org-directory . ,(expand-file-name "~/.ghq/github.com/comamoca/org"))
   `(diary-file-path . ,(format-time-string "diary/%y/%m-%d.org"))
   `(memo-file-path . ,(format-time-string "memo/%y/%m/%d.org"))
   `(diary-path . ,(concat org-directory "/diary"))
   (org-publish-use-timestamps-flag . nil)

   ;; org-capture
   (org-capture-templates .
			  '(("d" "diary" plain (file diary-file-path)
			     "** 今日やったこと\n\n** 明日以降やりたいこと")
			    ("m" "memo" plain (file memo-file-path) "")))

   (org-publish-project-alist .
			      '(("diary"
				 :base-directory "~/.ghq/github.com/comamoca/org/diary"
				 :base-extension "org"  
				 :recursive t
				 :publishing-directory  "~/.ghq/github.com/comamoca/org/dist"
				 :publishing-function org-html-publish-to-html
				 :include ("index.org")
				 :exclude ())
     
				("note"
				 :base-directory "~/.ghq/github.com/comamoca/org/note"
				 :base-extension "org"  
				 :recursive t
				 :publishing-directory  "~/.ghq/github.com/comamoca/org/note/dist"
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
  (set-language-environment "japanese")
  (prefer-coding-system 'utf-8)
  (set-default 'buffer-file-coding-system 'utf-8)

  (org-babel-do-load-languages
   'org-babel-load-languages
   '((c . t)
     (shell . t)
     (python . t)
     (clojure . t)
     (hy . t)
     (ruby . t)
     (ledger . t)))
  :bind ((:calendar-mode-map
	  ("c-c c" . org-capture-from-calendar)))
  :init
  ;; org-calendar
  ;; (with-eval-after-load 'calendar
  ;;     (define-key calendar-mode-map (kbd "c-c c") 'org-capture-from-calendar))
  )

;; org-journal
(leaf org-journal
  :after org
  :custom
  ((org-journal-time-format . "")
   (org-journal-time-prefix . "")
   `(org-journal-dir . ,(concat org-directory (format-time-string "/diary/%y")))
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

;; deft
;; for search roam files.
(leaf deft
  :after org-roam-mode
  :custom
  ((deft-extensions . '("txt" "tex" "org"))
   `(deft-directory . ,(expand-file-name "roam" org-directory))))

(leaf org-roam-ui)

;; org-bullets
(leaf org-bullets
  :after org
  ;; :init
  ;; (org-bullets-mode 1)
  )

;; org-modern
(leaf org-modern
  :after
  :init
  (with-eval-after-load 'org (global-org-modern-mode)))

(leaf org-modern-indent)

;; org-babel
(leaf ob-hy)

(leaf org-nix-shell)

;; magit
(leaf magit
  :custom
  ((transient-default-level . 5))
  :bind ((:global-map
	  ("c-x g" . magit-status))
	 (:magit-mode-map
	  ("/" . isearch-forward))))

;; forge
(leaf forge
  :after magit)

;; skk
(leaf ddskk
  :custom ((default-input-method . "japanease-skk")
	   (skk-auto-insert-paren . t)
	   (skk-comp-mode . t)
	   (skk-delete-implies-kakutei . nil))
  :config
  (skk-latin-mode 1)
  (global-set-key (kbd "c-x c-j") 'skk-mode)
  (global-set-key (kbd "<henkan>") 'skk-kakutei)
  (global-set-key (kbd "<muhenkan>") 'skk-latin-mode))

(leaf ddskk-posframe
  :global-minor-mode t)

;; common lisp
(leaf slime
  :config
  (defvar inferior-lisp-program "sbcl"))

(leaf sly
  :config)
  ;; (defvar inferior-lisp-program "sbcl")

(leaf sly-asdf)

;; clojure
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
  "a linter for prose."
  :command ("textlint" "--format" "unix" source-inplace)
  :error-patterns
  ((warning line-start (file-name) ":" line ":" column ": "
      (id (one-or-more (not (any " "))))
      (message (one-or-more not-newline)
        (zero-or-more "\n" (any " ") (one-or-more not-newline)))
      line-end))
  :modes (text-mode markdown-mode gfm-mode org-mode web-mode))

;; copilot
(leaf copilot
  :bind ((:copilot-completion-map
	  ("tab" . copilot-accept-completion)))
  :config
  (add-to-list 'copilot-major-mode-alist '("enh-ruby" . "ruby"))
  (add-to-list 'copilot-major-mode-alist '("typescript-ts-mode" . "typescript")))

;; lsp
(leaf lsp-bridge
  :require t
  :custom
  ((acm-enable-capf . t)
   (acm-frame-background-dark-color . "#313244"))
  :config
  (setq lsp-bridge-get-single-lang-server-by-project
	(lambda (project-path file-path)
	  (message project-path)
	  (when (or (expand-file-name "package.json" project-path))
	    "typescript-language-server")
	  "deno"))
  :init
  (global-lsp-bridge-mode))



;; lso-mode
;; (leaf lsp-mode
;;   :require t
;;   :custom
;;   ((lsp-completion-provider . :none))
;;   :config
;;   (setenv "lsp_use_plists" "true")

;;   (define-key evil-normal-state-map (kbd "k") 'lsp-ui-doc-glance)

;;   (add-to-list 'lsp-language-id-configuration
;; 	       '(nix-mode . "nil")
;; 	       '(python-mode . "python"))

;;   (defun corfu-lsp-setup ()
;;     (setq completion-at-point-functions '(lsp-completion-at-point))
;;     (setq-local completion-styles '(orderless)
;; 		completion-category-defaults nil))

;;   (add-hook 'lsp-mode-hook #'corfu-lsp-setup)
;;   (add-hook 'prog-mode-hook #'lsp-deferred))

;; ;; lsp booster
;; (defun lsp-booster--advice-json-parse (old-fn &rest args)
;;   "try to parse bytecode instead of json."
;;   (or
;;    (when (equal (following-char) ?#)
;;      (let ((bytecode (read (current-buffer))))
;;        (when (byte-code-function-p bytecode)
;;          (funcall bytecode))))
;;    (apply old-fn args)))

;; (advice-add (if (progn (require 'json)
;;                        (fboundp 'json-parse-buffer))
;;                 'json-parse-buffer
;;               'json-read)
;;             :around
;;             #'lsp-booster--advice-json-parse)

;; (defun lsp-booster--advice-final-command (old-fn cmd &optional test?)
;;   "prepend emacs-lsp-booster command to lsp cmd."
;;   (let ((orig-result (funcall old-fn cmd test?)))
;;     (if (and (not test?)                             ;; for check lsp-server-present?
;;              (not (file-remote-p default-directory)) ;; see lsp-resolve-final-command, it would add extra shell wrapper
;;              lsp-use-plists
;;              (not (functionp 'json-rpc-connection))  ;; native json-rpc
;;              (executable-find "emacs-lsp-booster"))
;;         (progn
;;           (when-let ((command-from-exec-path (executable-find (car orig-result))))  ;; resolve command from exec-path (in case not found in $path)
;;             (setcar orig-result command-from-exec-path))
;;           (message "using emacs-lsp-booster for %s!" orig-result)
;;           (cons "emacs-lsp-booster" orig-result))
;;       orig-result)))

;; (advice-add 'lsp-resolve-final-command :around #'lsp-booster--advice-final-command)

;; eglot
;; (defun deno-project-p ()
;;   "predicate for determining if the open project is a deno one."
;;   (let ((p-root (nth 2 (project-current))))
;;     (or (file-exists-p (expand-file-name "deno.json" default-directory))
;; 	(file-exists-p (expand-file-name "deno.jsonc" default-directory)))))

;; (defun node-project-p ()
;;   "predicate for determining if the open project is a deno one."
;;   (let ((p-root (nth 2 (project-current))))
;;     (file-exists-p (expand-file-name "package.json" default-directory))))

;; (defun es-server-program (_)
;;   "decide which server to use for ecma script based on project characteristics."
;;   (cond ((deno-project-p) '("deno" "lsp" :initializationoptions (:enable t :lint t)))
;;         ((node-project-p) '("typescript-language-server" "--stdio"))
;;         (t nil)))

;; (leaf eglot
;;   :hook
;;   (c++-mode . eglot-ensure)
;;   (sh-mode . eglot-ensure)
;;   (python-mode . eglot-ensure)
;;   (html-mode . eglot-ensure)
;;   (cmake-mode . eglot-ensure)
;;   (bitbake-mode . eglot-ensure)
;;   (typescript-ts-mode . eglot-ensure)
;;   :config
;;   ;; (add-to-list 'eglot-server-programs '((bitbake-mode) "bitbake-language-server"))
;;   (add-to-list 'eglot-server-programs '((js-mode typescript-mode) . es-server-program))
;;   (add-to-list 'eglot-server-programs '(gleam-ts-mode . ("lspx" "--lsp" "gleam lsp")))
;;   :bind (("m-t" . xref-find-definitions)
;; 	 ("m-r" . xref-find-references)
;; 	 ("c-t" . xref-go-back)))

;; (leaf eglot-booster
;;   :after eglot
;;   :config (eglot-booster-mode))

;; auto formatting
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
 
;; lua support
(leaf lua-mode)

;; completion
(leaf corfu
  :custom
  ((corfu-cycle . t)
  (corfu-auto . t)
  (corfu-auto-prefix . 1))
  :init
  (global-corfu-mode))


;; cursor moation
(leaf avy
  :config
  (define-key evil-normal-state-map (kbd "spc k") #'avy-goto-line))

;; completion soruce
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

;; hydra
(leaf hydra)
(leaf hydra-posframe
  ;; :require t
  ;; :vc (:url "https://github.com/ladicle/hydra-posframe")

  :init
  ;; for hydra
  (define-key evil-normal-state-map (kbd "spc w") #'manage-window-hydra/body)

  :hook
  (add-hook 'after-init-hook 'hydra-posframe-mode))

(leaf major-mode-hydra)

;; for nix
(pretty-hydra-define nix-flake-hydra
  (:separator "-" :title "nix flake" :forigen-key warn :quit-key "q" :exit t)
  ("build"
   (("b" nix-flake-build-default "build"))

   "update"
   (("u" nix-flake-update "update"))))

;; for manage window
(pretty-hydra-define manage-window-hydra
  (:separator "-" :title "manage window" :forigen-key warn :quit-key "q" :exit t)
  ("1"
   (("a" delete-other-windows "delte other windwos"))

   "2"
   (("s" split-window-below "horizontal split"))

   "3"
   (("d" split-window-right "vertical split"))

   "0"
   (("f" delete-window "delete window"))))

(pretty-hydra-define org-hydra
  (:separator "-" :title "nix flake" :forigen-key warn :quit-key "q" :exit t)
  ("roam"
   (("a" org-roam-node-find "roam"))

   "capture"
   (("s" org-capture "capture"))))
    

;; (pretty-hydra-define org-roam-hydra
;;   (:separator "-" :title "org-roam" :forigen-key warn :quit-key "q" :exit t)
;;   ("find"
;;    (("a" 'org-roam-node-find "find node"))

;;    ""
;;    (("s" 'org-roam- ""))

;;    ""
;;    (("d"  ""))

;;    ""
;;    (("f"  ""))
;;     ))

;; transient dispatcher
(leaf transient-dwim
  :bind ("c-=" . transient-dwim-dispatch))

;; tree filer
(leaf neotree
  :custom
  (neo-smart-open . t)
  (projectile-switch-project-action . 'neotree-projectile-action)
  :config
  (progn
    (evil-define-key 'normal neotree-mode-map (kbd "q") 'neotree-hide)
    (evil-define-key 'normal neotree-mode-map (kbd "l") 'neotree-enter)
    (evil-define-key 'normal neotree-mode-map (kbd "ret") 'neotree-enter)
    (evil-define-key 'normal neotree-mode-map (kbd "h") 'neotree-enter)
    (evil-define-key 'normal neotree-mode-map (kbd "g") 'neotree-refresh)
    (evil-define-key 'normal neotree-mode-map (kbd "j") 'neotree-next-line)
    (evil-define-key 'normal neotree-mode-map (kbd "k") 'neotree-previous-line)
    (evil-define-key 'normal neotree-mode-map (kbd "a") 'neotree-stretch-toggle)
    (evil-define-key 'normal neotree-mode-map (kbd "h") 'neotree-hidden-file-toggle)
    (evil-define-key 'normal neotree-mode-map (kbd "n") 'neotree-create-node)
    (evil-define-key 'normal neotree-mode-map (kbd "k") 'neotree-create-node)
    (evil-define-key 'normal neotree-mode-map (kbd "d") 'neotree-delete-node)
    (evil-define-key 'normal neotree-mode-map (kbd "m") 'neotree-rename-node))
  
  ;; for neotree
  (define-key evil-normal-state-map (kbd "spc f") #'neotree-toggle))
  

;; translate
(leaf google-translate
  :require t
  :custom
  (google-translate-translation-directions-alist . '(("en" . "ja")
                                                     ("ja" . "en"))))
;; wakatime
(leaf wakatime-mode
  :init
  (global-wakatime-mode))

;; typst

;; preview
(leaf typst-preview
  ;; :vc (:url "https://github.com/havarddj/typst-preview.el")
  ;; :require t
  :config
  (setq typst-preview-browser "firefox"))

;; ruby support
(leaf inf-ruby)

(leaf enh-ruby-mode)

;; python support
(add-hook 'python-ts-mode-hook (lambda ()
				 (require 'python-mode)))

;; language supports

;; dotnet
(leaf dotnet
  :after csharp-mode)

;; c#
(leaf csharp-mode)

;; nix support
(leaf nix-mode
  :hook
  (nix-ts-mode))

;; scala suppport
(leaf scala-mode
  :interpreter ("scala" . scala-mode))


(leaf sbt-mode
  :commands sbt-start sbt-command
  :config
  (substitute-key-definition
   'minibuffer-complete-word
   'self-insert-command
   minibuffer-local-completion-map)

   (setq sbt:program-options '("-dsbt.supershell=false")))

;; astro support
(leaf astro-ts-mode)

;; elixir support
(leaf inf-elixir)
(leaf mix)

(leaf elixir-ts-mode
  :hook ((elixir-ts-mode . mix-minor-mode)))

;; kdl supports
(leaf kdl-ts-mode)

;; gleam support
(leaf gleam-ts-mode
  :require t
  :hook gleam-on-save-mode)

;; markdown suppot
(leaf markdown-mode
  :hook
  (add-to-list 'completion-at-point-functions #'cape-emoji))

;; projectile
(defun update-projectlist ()
  (interactive)
  (setq projectile-known-projects
         (mapcar
          (lambda (x) (abbreviate-file-name x))
          (split-string (shell-command-to-string "ghq list --full-path")))))

(leaf projectile 
  :config
  (define-key evil-normal-state-map (kbd "m-g") #'projectile-switch-project)
  (define-key evil-normal-state-map (kbd "c-o") #'projectile-find-file)
  :init
  (when (executable-find "ghq")
   (update-projectlist)))

;; migemo
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

;; nyan-mode
(leaf nyan-mode
  :init
  (progn (nyan-mode)
   (nyan-start-animation)))

;; snippets
(leaf tempel
  :require t
  :bind ((:evil-insert-state-map
	  ("m-a" . tempel-done)))
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

;; http request
(leaf request)
(leaf plz)

(autoload 'newsticker-start "newsticker" "start newsticker" t)
(autoload 'newsticker-show-news "newsticker" "goto newsticker buffer" t)

(setq newsticker-url-list
      '(("gleam weekly" "https://gleamweekly.com/atom.xml")
        ("zenn gleam" "https://zenn.dev/topics/gleam/feed")
	("gleam releases" "https://github.com/gleam-lang/gleam/releases.atom")
	("zenn trend" "https://zenn.dev/feed")
	("zenn emacs" "https://zenn.dev/topics/emacs/feed")
        ("zenn ts" "https://zenn.dev/topics/typescript/feed")
        ("zenn cl" "https://zenn.dev/topics/commonlisp/feed")
        ("zenn deno" "https://zenn.dev/topics/deno/feed")
        ("zenn bun" "https://zenn.dev/topics/bun/feed")
        ("zenn rust" "https://zenn.dev/topics/rust/feed")
        ("zenn vim" "https://zenn.dev/topics/vim/feed")
        ("zenn neovim" "https://zenn.dev/topics/neovim/feed")
        ("zenn scheme" "https://zenn.dev/topics/scheme/feed")
        ("zenn hono" "https://zenn.dev/topics/hono/feed")
        ("zenn react" "https://zenn.dev/topics/react/feed")
        ("zenn gcp" "https://zenn.dev/topics/googlecloud/feed")
        ("zenn aws" "https://zenn.dev/topics/aws/feed")
        ("techfeed" "https://techfeed.io/feeds/categories/all")
	("hacker news" "https://hnrss.org/frontpage")
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
	  ("c-a" . grugru))
	 (:evil-normal-state-map
	  ("c-x" . grugru-backward)))
  :config
  ;; ref: https://github.com/rocktakey/grugru/issues/44
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

;; (leaf folding-mode :require t)

(leaf rg
  :require t)

(leaf open-junk-file
  :require t
  :custom
  (open-junk-file-format . "/tmp/junk/%y_%m_%d_%h%m%s.")
  :bind (("c-x j" . open-junk-file)))

(leaf fold-this)

(leaf alert
  :config
  (setq alert-default-style 'libnotify))

(leaf dashboard
  :config
  (setq dashboard-startup-banner (expand-file-name "~/pictures/.emacs-logos/gnu_color_resize.png"))
  (setq dashboard-startup-banner 'logo))

(leaf aas
  ;; :hook (text-mode . aas-activate-for-major-mode)
  ;; :init
  ;; (aas-set-snippets 'global)
  ;; (aas-set-snippets 'markdown-mode)
  ;; (aas-set-snippets 'prog-mode)
  )

(leaf smartparens
  :config
  (smartparens-global-mode t))

(leaf vterm)

(leaf vterm-toggle
  :after evil
  :bind (("c-<return>" . (lambda ()
			   (interactive)
			   (vterm-toggle-insert-cd)
			   (vterm-toggle-insert-cd)))))

(leaf multi-vterm
  :config
  (setq multi-vterm-dedicated-window-height 50))

;; ai
 add-hook 'server-after-make-frame-hook
          (lambda ()
            (setenv "gemini_api_key" (get-secret "gemini.google.com")
            (setenv "openrouter_api_key" (get-secret "openrouter.ai"))
	    (setq gemini-apikey (get-secret "gemini.google.com"))))

(leaf gptel
  :config
  (setq
   ;; gptel-model 'starcoder2
   ;; gptel-backend (gptel-make-ollama "ollama"
   ;;                :host "localhost:11434"
   ;;                :stream t
   ;;                :models '(starcoder2)))

   gptel-model 'gemini-2.5-flash
   gptel-backend (gptel-make-gemini "gemini"
		   :key gemini-apikey
		   :stream t)))

;; ai codeing
(leaf aider
  :require t
  :custom
  (;; (aider-args . '("--watch-files" "--model" "gemini/gemini-2.0-flash"))
   (aider-args . '("--watch-files" "--model" "openrouter/anthropic/claude-3.5-sonnet"))
   ))

(leaf aidermacs
  :require t
  :config
  (setq aidermacs-watch-files t)
  :custom
  (;; (aidermacs-default-model . "gemini/gemini-2.0-flash")
   (aidermacs-default-model . "gemini/gemini-2.5-pro-preview-03-25")
   (aidermacs-watch-files . t)))
;; (aidermacs-default-model . "gemini/gemini-2.5-flash-preview-04-17")


(leaf mcp)

(leaf minimap
  :require t
  :custom ((minimap-window-location . 'right)
	   (minimap-minimum-width . 20)
	   (minimap-major-modes . '(prog-mode
				    markdown-mode
				    html-mode
				    fundamental-mode)))
  :bind ("c-x m" . minimap-mode)
  :config
  (minimap-mode 1))

(leaf rainbow-delimiters
  :hook
  (prog-mode-hook . rainbow-delimiters-mode))

(leaf ox-zenn
  :after org
  :require t)

(leaf verb)

(leaf quickrun)

;; ================ my extentions ================

(defun get-secret (host)
  "wrapper functino for auth-info"
  (require 'ht) 
  (let* ((found (cl-first (auth-source-search :host host
					      :user "coma")))
	 (credentials (when found
			(eval `(ht ,@(--map `(,it ,(plist-get found it))
                                            '(:user :secret :save-function))))))
	 (secret (when credentials
                   (ht-get credentials :secret))))

    (if (not secret)
	(progn (message (format "does not found %s credential." host))
	       "")
      (if (functionp secret)
          (funcall secret)
	secret))))

;; (defun nyan-region ()
;;   "選択範囲をにゃーんで置換する"
;;   (interactive)
;;   (when (use-region-p)
;;     (let* ((beg (region-beginning))
;;            (end (region-end)))
;;      (len (- end beg)
;;       (delete-region beg end)
;;       (cond ((= len 1) (insert "にゃ")))
;;       ((= len 2) (insert "にゃん"))
;;       (t (insert (format "にゃ%sん" (make-string (- len 3) ?ー))))))))

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

  (let* ((query (read-from-minibuffer "query? > ")))
   (url (concat "https://www.google.com/search?client=firefox-b-d&q=" (url-hexify-string query))
  
    (shell-command (concat "open " "'" url "'")))))

(defun home-manager ()
  (interactive)
  (start-process "home-manager-process"
     "*home-manager*"
     "home-manager"
     "switch"
     "--flake"
     ".#home"
     "-b"
     "backup"))

    ;; (set-process-sentinel proc
    ;;                           (lambda (process event)
    ;;                             (when (string= event "finished\n"))))

(defun all (pred lst)
  "returns t if all elements of the list satisfy the predicate."
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
  (let ((beg (save-excursion (skip-chars-backward "a-za-z") (point)))
        (end (point))
        (candidates gitmoji--codes))
    (list beg end candidates :exclusive 'no)))

;; collect gitmoji when startup
;; (add-hook 'emacs-startup-hook 'setup-gitmoji)
;; enable at git-commit-mode

;; display character count in modeline
(defun update-buffer-char-count ()
  (interactive)
  (format " [%d] " (buffer-size)))

(defun mode-line-time ()
  ;; update every second
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

;; for diary
(setq blog-repo "/home/coma/.ghq/github.com/comamoca/blog/")

(defun latest-diary ()
  "open latest diary. this function call in `src/blog/` directory at blog repository."
  (interactive)
  (let* ((date (format-time-string "%y-%m-%d"))
         (file-name (format "%s-diary.md" date))
         (path (concat (expand-file-name "src/blog/" blog-repo) file-name)))
    (find-file path)
    (if (= (buffer-size) 0)
	(tempel-insert 'diary))))

(defun new-blog-article ()
  "open latest diary. this function call in `src/blog/` directory at blog repository."
  (interactive)
  (let* ((date (format-time-string "%y-%m-%d"))
         (slug (read-string "slug > "))
         (file-name (format "%s-%s.md" date slug))
         (path (concat (expand-file-name "src/blog/" blog-repo) file-name)))
    ;; (projectile-switch-project-by-name "blog")
    (find-file path)))

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
	 (mdfiles (cl-remove-if-not (lambda (file))))
	 (articles (cl-remove-if (lambda (file)))
		   (string-match "-diary.md$" file
				 files))
	 (selected (completing-read "blog " articles)))
    (find-file (expand-file-name selected src-dir)))) 

(defun org-paste-image ()
  (interactive)
  (setq filename (concat
                  (expand-file-name (format-time-string "%y-%m-%d-%h%m%s")
                   "~/.ghq/github.com/comamoca/org/imgs") ".png"))
  (shell-command (concat  "wl-paste -t image/png > " filename))
  (insert (concat "[[" filename "]]"))
  (org-display-inline-images))

(defun blog-paste-image ()
  (interactive)
  (setq fullpath (concat
                  (expand-file-name (format-time-string "%y-%m-%d-%h%m%s")
				    "~/.ghq/github.com/comamoca/blog/src/images") ".png"))
  (shell-command (concat  "wl-paste -t image/png > " fullpath))
  (insert (concat "![](/images/" (file-name-nondirectory fullpath) ")"))
  (org-display-inline-images))


;; gauche
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
  (let* ((node-items (mapcar (lambda (node)))
             (cons (org-roam-node-title node) node)) (org-roam-node-list))
   (select-node-title (consult--read)
        (mapcar #'car node-items))
   (select-node (cdr (assoc select-node-title node-items))

    (find-file (org-roam-node-file select-node)))))

;; pinentry emacs
(defun pinentry-emacs (desc prompt ok error)
  (let ((str (read-passwd (concat (replace-regexp-in-string "%22" "\"" (replace-regexp-in-string "%0a" "\n" desc)) prompt ": "))))
    str))

;; initel function that behaves like `:e $myvimrc`
(defun initel ()
  (interactive)
  (find-file user-init-file))

;; ================ my configuratons ================

;; ediff
(setq ediff-window-setup-function 'ediff-setup-windows-plain)

;; font
(add-to-list 'default-frame-alist
                       '(font . "udev gothic nf-14"))

;; for auth-info
(setq auth-sources '("~/.emacs.d/.authinfo.gpg"))
(setq create-lockfiles nil)

;; for lsp-mode
(setq gc-cons-threshold 100000000)
(setq read-process-output-max (* 1024 1024))

;; key mapping
(define-key global-map (kbd "c-x s") 'blackening-region)
(define-key global-map (kbd "c-;") 'comment-dwim)

;; minibuffe
(define-key minibuffer-local-map (kbd "c-h") 'delete-char)
(define-key minibuffer-local-ns-map (kbd "c-h") 'delete-char)
(define-key minibuffer-local-completion-map (kbd "c-h") 'delete-char)
(define-key minibuffer-local-must-match-map (kbd "c-h") 'delete-char)
(define-key minibuffer-local-filename-completion-map (kbd "c-h") 'delete-char)

;; enable debug
(setq debug-on-error nil)

;; custom modeline
(mode-line-format-update)

;; when org-mode
(add-hook 'org-mode
    (lambda ()
      (local-set-key evil-insert-state-map (kbd "c-h") #'org-insert-heading)))

(electric-pair-mode 1)

(global-hl-line-mode t)

(setq vc-follow-symlinks t)
(setq browse-url-generic-program "firefox")
(setq ring-bell-function 'ignore)

(setq display-warning-minimum-level :error)

;; disable to create backupfile
(setq make-backup-files nil)

;; disable to auto save
(setq auto-save-default nil)

;; copy & paste with wl-clipboard
;; ref: https://gist.github.com/yorickvp/6132f237fbc289a45c808d8d75e0e1fb
(setenv "wayland_display" "wayland-1")

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
  :bind (("c-c e" . macrostep-expand)))

;; (provide 'init)
(put 'narrow-to-region 'disabled nil)
(custom-set-variables
 ;; custom-set-variables was added by custom.
 ;; if you edit it by hand, you could mess it up, so be careful.
 ;; your init file should contain only one such instance.
 ;; if there is more than one, they won't work right.
 '(skk-jisyo-edit-user-accepts-editing t))
(custom-set-faces)
 ;; custom-set-faces was added by custom.
 ;; if you edit it by hand, you could mess it up, so be careful.
 ;; your init file should contain only one such instance.
 ;; if there is more than one, they won't work right.
 

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

;; theme
(leaf catppuccin-theme 
  :preface
  :config
  (load-theme 'catppuccin t))

;; minibuffer ui
(leaf vertico
  :require orderless
  :config
  (defvar vertico-count 10)
  ;; completion style config
  (setq completion-styles '(orderless basic)
	completion-category-overrides '((file (styles basic partial-completion))))
  :init 
  (vertico-mode))

;; completion styles
(leaf orderless)

(leaf hotfuzz)

;; completing read functions
(leaf consult
  :require t
  :after evil
  :bind ((:evil-normal-state-map
	  ("c-l" . consult-line)
	  ("c-i" . consult-buffer)))
  :bind* (("c-." . embark-act)))

(leaf consult-dir)

;; embark
(leaf embark
  :after evil
  :bind ((:evil-normal-state-map
	  ("c-." . embark-act)
	  ("c--" . embark-export))
	 (:evil-insert-state-map
	  ("c-." . embark-act))))

;; affe
(leaf affe)

;; for consult
(leaf embark-consult
  :bind ((:minibuffer-mode-map
	  ("m-." . embark-dwin)
	  ("c-." . embark-act))))

;; vim keybind
(leaf evil
  :require t
  :bind ((:evil-normal-state-map
	  ("c-k" . evil-scroll-up)
	  ("c-j" . evil-scroll-down))
	 (:evil-insert-state-map
	  ;; ("c-j" . newline-and-indent)
	  ("c-h" . backward-char)))
 
  :config
  (evil-mode 1))

;; structured editing 
(leaf puni
  :config
  (global-set-key (kbd "c--") 'puni-expand-region)
  :bind ((:evil-insert-state-map
	  ("s" . nil)
	  ;; ("sd" . puni-splice)
	  ("c-i" . puni-mark-sexp-at-point)
	  ("c-p" . puni-slurp-forward)
	  ("c-n" . puni-barf-forward)))
  :init
  (puni-global-mode))

;; indent guides
(leaf highlight-indent-guides)

;; treesitter
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
  (add-to-list 'auto-mode-alist '("dockerfile" . dockerfile-ts-mode)))

(leaf treesit-auto
  :require t
  :custom
  ((treesit-auto-install . t)
   (treesit-extra-load-path . `(,(expand-file-name "~/.cache/dpp/_generated/nvim-treesitter/parser"))))
  :config  
  (global-treesit-auto-mode)
  ;; (treesit-auto-install 'prompt)
  ;; (treesit-auto-add-to-auto-mode-alist 'all)
  )

;; for envrc
(leaf envrc)

;; calendar 
(leaf calendar)

;; org-mode
(leaf org
  :after calendar-mode
  :custom
  ((org-todo-keywords .
		      '((sequence "todo(t)" "pending(p)" "|" "done(d)" "canceled(c)")))
   (org-default-notes-file . "notes.org")
   `(org-directory . ,(expand-file-name "~/.ghq/github.com/comamoca/org"))
   `(diary-file-path . ,(format-time-string "diary/%y/%m-%d.org"))
   `(memo-file-path . ,(format-time-string "memo/%y/%m/%d.org"))
   `(diary-path . ,(concat org-directory "/diary"))
   (org-publish-use-timestamps-flag . nil)

   ;; org-capture
   (org-capture-templates .
			  '(("d" "diary" plain (file diary-file-path)
			     "** 今日やったこと\n\n** 明日以降やりたいこと")
			    ("m" "memo" plain (file memo-file-path) "")))

   (org-publish-project-alist .
			      '(("diary"
				 :base-directory "~/.ghq/github.com/comamoca/org/diary"
				 :base-extension "org"  
				 :recursive t
				 :publishing-directory  "~/.ghq/github.com/comamoca/org/dist"
				 :publishing-function org-html-publish-to-html
				 :include ("index.org")
				 :exclude ())
     
				("note"
				 :base-directory "~/.ghq/github.com/comamoca/org/note"
				 :base-extension "org"  
				 :recursive t
				 :publishing-directory  "~/.ghq/github.com/comamoca/org/note/dist"
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
  (set-language-environment "japanese")
  (prefer-coding-system 'utf-8)
  (set-default 'buffer-file-coding-system 'utf-8)

  (org-babel-do-load-languages
   'org-babel-load-languages
   '((c . t)
     (shell . t)
     (python . t)
     (clojure . t)
     (hy . t)
     (ruby . t)
     (ledger . t)))
  :bind ((:calendar-mode-map
	  ("c-c c" . org-capture-from-calendar)))
  :init
  ;; org-calendar
  ;; (with-eval-after-load 'calendar
  ;;     (define-key calendar-mode-map (kbd "c-c c") 'org-capture-from-calendar))
  )

;; org-journal
(leaf org-journal
  :after org
  :custom
  ((org-journal-time-format . "")
   (org-journal-time-prefix . "")
   `(org-journal-dir . ,(concat org-directory (format-time-string "/diary/%y")))
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

;; deft
;; for search roam files.
(leaf deft
  :after org-roam-mode
  :custom
  ((deft-extensions . '("txt" "tex" "org"))
   `(deft-directory . ,(expand-file-name "roam" org-directory))))

(leaf org-roam-ui)

;; org-bullets
(leaf org-bullets
  :after org
  ;; :init
  ;; (org-bullets-mode 1)
  )

;; org-modern
(leaf org-modern
  :after
  :init
  (with-eval-after-load 'org (global-org-modern-mode)))

(leaf org-modern-indent)

;; org-babel
(leaf ob-hy)

(leaf org-nix-shell)

;; magit
(leaf magit
  :custom
  ((transient-default-level . 5))
  :bind ((:global-map
	  ("c-x g" . magit-status))
	 (:magit-mode-map
	  ("/" . isearch-forward))))

;; forge
(leaf forge
  :after magit)

;; skk
(leaf ddskk
  :custom ((default-input-method . "japanease-skk")
	   (skk-auto-insert-paren . t)
	   (skk-comp-mode . t)
	   (skk-delete-implies-kakutei . nil))
  :config
  (skk-latin-mode 1)
  (global-set-key (kbd "c-x c-j") 'skk-mode)
  (global-set-key (kbd "<henkan>") 'skk-kakutei)
  (global-set-key (kbd "<muhenkan>") 'skk-latin-mode))

(leaf ddskk-posframe
  :global-minor-mode t)

;; common lisp
(leaf slime
  :config
  (defvar inferior-lisp-program "sbcl"))

(leaf sly
  :config)
  ;; (defvar inferior-lisp-program "sbcl")

(leaf sly-asdf)

;; clojure
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
  "a linter for prose."
  :command ("textlint" "--format" "unix" source-inplace)
  :error-patterns
  ((warning line-start (file-name) ":" line ":" column ": "
      (id (one-or-more (not (any " "))))
      (message (one-or-more not-newline)
        (zero-or-more "\n" (any " ") (one-or-more not-newline)))
      line-end))
  :modes (text-mode markdown-mode gfm-mode org-mode web-mode))

;; copilot
(leaf copilot
  :bind ((:copilot-completion-map
	  ("tab" . copilot-accept-completion)))
  :config
  (add-to-list 'copilot-major-mode-alist '("enh-ruby" . "ruby"))
  (add-to-list 'copilot-major-mode-alist '("typescript-ts-mode" . "typescript")))

;; lsp
(leaf lsp-bridge
  :require t
  :custom
  ((acm-enable-capf . t)
   (acm-frame-background-dark-color . "#313244"))
  :config
  (setq lsp-bridge-get-single-lang-server-by-project
	(lambda (project-path file-path)
	  (message project-path)
	  (when (or (expand-file-name "package.json" project-path))
	    "typescript-language-server")
	  "deno"))
  :init
  (global-lsp-bridge-mode))



;; lso-mode
;; (leaf lsp-mode
;;   :require t
;;   :custom
;;   ((lsp-completion-provider . :none))
;;   :config
;;   (setenv "lsp_use_plists" "true")

;;   (define-key evil-normal-state-map (kbd "k") 'lsp-ui-doc-glance)

;;   (add-to-list 'lsp-language-id-configuration
;; 	       '(nix-mode . "nil")
;; 	       '(python-mode . "python"))

;;   (defun corfu-lsp-setup ()
;;     (setq completion-at-point-functions '(lsp-completion-at-point))
;;     (setq-local completion-styles '(orderless)
;; 		completion-category-defaults nil))

;;   (add-hook 'lsp-mode-hook #'corfu-lsp-setup)
;;   (add-hook 'prog-mode-hook #'lsp-deferred))

;; ;; lsp booster
;; (defun lsp-booster--advice-json-parse (old-fn &rest args)
;;   "try to parse bytecode instead of json."
;;   (or
;;    (when (equal (following-char) ?#)
;;      (let ((bytecode (read (current-buffer))))
;;        (when (byte-code-function-p bytecode)
;;          (funcall bytecode))))
;;    (apply old-fn args)))

;; (advice-add (if (progn (require 'json)
;;                        (fboundp 'json-parse-buffer))
;;                 'json-parse-buffer
;;               'json-read)
;;             :around
;;             #'lsp-booster--advice-json-parse)

;; (defun lsp-booster--advice-final-command (old-fn cmd &optional test?)
;;   "prepend emacs-lsp-booster command to lsp cmd."
;;   (let ((orig-result (funcall old-fn cmd test?)))
;;     (if (and (not test?)                             ;; for check lsp-server-present?
;;              (not (file-remote-p default-directory)) ;; see lsp-resolve-final-command, it would add extra shell wrapper
;;              lsp-use-plists
;;              (not (functionp 'json-rpc-connection))  ;; native json-rpc
;;              (executable-find "emacs-lsp-booster"))
;;         (progn
;;           (when-let ((command-from-exec-path (executable-find (car orig-result))))  ;; resolve command from exec-path (in case not found in $path)
;;             (setcar orig-result command-from-exec-path))
;;           (message "using emacs-lsp-booster for %s!" orig-result)
;;           (cons "emacs-lsp-booster" orig-result))
;;       orig-result)))

;; (advice-add 'lsp-resolve-final-command :around #'lsp-booster--advice-final-command)

;; eglot
;; (defun deno-project-p ()
;;   "predicate for determining if the open project is a deno one."
;;   (let ((p-root (nth 2 (project-current))))
;;     (or (file-exists-p (expand-file-name "deno.json" default-directory))
;; 	(file-exists-p (expand-file-name "deno.jsonc" default-directory)))))

;; (defun node-project-p ()
;;   "predicate for determining if the open project is a deno one."
;;   (let ((p-root (nth 2 (project-current))))
;;     (file-exists-p (expand-file-name "package.json" default-directory))))

;; (defun es-server-program (_)
;;   "decide which server to use for ecma script based on project characteristics."
;;   (cond ((deno-project-p) '("deno" "lsp" :initializationoptions (:enable t :lint t)))
;;         ((node-project-p) '("typescript-language-server" "--stdio"))
;;         (t nil)))

;; (leaf eglot
;;   :hook
;;   (c++-mode . eglot-ensure)
;;   (sh-mode . eglot-ensure)
;;   (python-mode . eglot-ensure)
;;   (html-mode . eglot-ensure)
;;   (cmake-mode . eglot-ensure)
;;   (bitbake-mode . eglot-ensure)
;;   (typescript-ts-mode . eglot-ensure)
;;   :config
;;   ;; (add-to-list 'eglot-server-programs '((bitbake-mode) "bitbake-language-server"))
;;   (add-to-list 'eglot-server-programs '((js-mode typescript-mode) . es-server-program))
;;   (add-to-list 'eglot-server-programs '(gleam-ts-mode . ("lspx" "--lsp" "gleam lsp")))
;;   :bind (("m-t" . xref-find-definitions)
;; 	 ("m-r" . xref-find-references)
;; 	 ("c-t" . xref-go-back)))

;; (leaf eglot-booster
;;   :after eglot
;;   :config (eglot-booster-mode))

;; auto formatting
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
 
;; lua support
(leaf lua-mode)

;; completion
(leaf corfu
  :custom
  ((corfu-cycle . t)
  (corfu-auto . t)
  (corfu-auto-prefix . 1))
  :init
  (global-corfu-mode))


;; cursor moation
(leaf avy
  :config
  (define-key evil-normal-state-map (kbd "spc k") #'avy-goto-line))

;; completion soruce
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

;; hydra
(leaf hydra)
(leaf hydra-posframe
  ;; :require t
  ;; :vc (:url "https://github.com/ladicle/hydra-posframe")

  :init
  ;; for hydra
  (define-key evil-normal-state-map (kbd "spc w") #'manage-window-hydra/body)

  :hook
  (add-hook 'after-init-hook 'hydra-posframe-mode))

(leaf major-mode-hydra)

;; for nix
(pretty-hydra-define nix-flake-hydra
  (:separator "-" :title "nix flake" :forigen-key warn :quit-key "q" :exit t)
  ("build"
   (("b" nix-flake-build-default "build"))

   "update"
   (("u" nix-flake-update "update"))))

;; for manage window
(pretty-hydra-define manage-window-hydra
  (:separator "-" :title "manage window" :forigen-key warn :quit-key "q" :exit t)
  ("1"
   (("a" delete-other-windows "delte other windwos"))

   "2"
   (("s" split-window-below "horizontal split"))

   "3"
   (("d" split-window-right "vertical split"))

   "0"
   (("f" delete-window "delete window"))))

(pretty-hydra-define org-hydra
  (:separator "-" :title "nix flake" :forigen-key warn :quit-key "q" :exit t)
  ("roam"
   (("a" org-roam-node-find "roam"))

   "capture"
   (("s" org-capture "capture"))))
    

;; (pretty-hydra-define org-roam-hydra
;;   (:separator "-" :title "org-roam" :forigen-key warn :quit-key "q" :exit t)
;;   ("find"
;;    (("a" 'org-roam-node-find "find node"))

;;    ""
;;    (("s" 'org-roam- ""))

;;    ""
;;    (("d"  ""))

;;    ""
;;    (("f"  ""))
;;     ))

;; transient dispatcher
(leaf transient-dwim
  :bind ("c-=" . transient-dwim-dispatch))

;; tree filer
(leaf neotree
  :custom
  (neo-smart-open . t)
  (projectile-switch-project-action . 'neotree-projectile-action)
  :config
  (progn
    (evil-define-key 'normal neotree-mode-map (kbd "q") 'neotree-hide)
    (evil-define-key 'normal neotree-mode-map (kbd "l") 'neotree-enter)
    (evil-define-key 'normal neotree-mode-map (kbd "ret") 'neotree-enter)
    (evil-define-key 'normal neotree-mode-map (kbd "h") 'neotree-enter)
    (evil-define-key 'normal neotree-mode-map (kbd "g") 'neotree-refresh)
    (evil-define-key 'normal neotree-mode-map (kbd "j") 'neotree-next-line)
    (evil-define-key 'normal neotree-mode-map (kbd "k") 'neotree-previous-line)
    (evil-define-key 'normal neotree-mode-map (kbd "a") 'neotree-stretch-toggle)
    (evil-define-key 'normal neotree-mode-map (kbd "h") 'neotree-hidden-file-toggle)
    (evil-define-key 'normal neotree-mode-map (kbd "n") 'neotree-create-node)
    (evil-define-key 'normal neotree-mode-map (kbd "k") 'neotree-create-node)
    (evil-define-key 'normal neotree-mode-map (kbd "d") 'neotree-delete-node)
    (evil-define-key 'normal neotree-mode-map (kbd "m") 'neotree-rename-node))
  
  ;; for neotree
  (define-key evil-normal-state-map (kbd "spc f") #'neotree-toggle))
  

;; translate
(leaf google-translate
  :require t
  :custom
  (google-translate-translation-directions-alist . '(("en" . "ja")
                                                     ("ja" . "en"))))
;; wakatime
(leaf wakatime-mode
  :init
  (global-wakatime-mode))

;; typst

;; preview
(leaf typst-preview
  ;; :vc (:url "https://github.com/havarddj/typst-preview.el")
  ;; :require t
  :config
  (setq typst-preview-browser "firefox"))

;; ruby support
(leaf inf-ruby)

(leaf enh-ruby-mode)

;; python support
(add-hook 'python-ts-mode-hook (lambda ()
				 (require 'python-mode)))

;; language supports

;; dotnet
(leaf dotnet
  :after csharp-mode)

;; c#
(leaf csharp-mode)

;; nix support
(leaf nix-mode
  :hook
  (nix-ts-mode))

;; scala suppport
(leaf scala-mode
  :interpreter ("scala" . scala-mode))


(leaf sbt-mode
  :commands sbt-start sbt-command
  :config
  (substitute-key-definition
   'minibuffer-complete-word
   'self-insert-command
   minibuffer-local-completion-map)

   (setq sbt:program-options '("-dsbt.supershell=false")))

;; astro support
(leaf astro-ts-mode)

;; elixir support
(leaf inf-elixir)
(leaf mix)

(leaf elixir-ts-mode
  :hook ((elixir-ts-mode . mix-minor-mode)))

;; kdl supports
(leaf kdl-ts-mode)

;; gleam support
(leaf gleam-ts-mode
  :require t
  :hook gleam-on-save-mode)

;; markdown suppot
(leaf markdown-mode
  :hook
  (add-to-list 'completion-at-point-functions #'cape-emoji))

;; projectile
(defun update-projectlist ()
  (interactive)
  (setq projectile-known-projects
         (mapcar
          (lambda (x) (abbreviate-file-name x))
          (split-string (shell-command-to-string "ghq list --full-path")))))

(leaf projectile 
  :config
  (define-key evil-normal-state-map (kbd "m-g") #'projectile-switch-project)
  (define-key evil-normal-state-map (kbd "c-o") #'projectile-find-file)
  :init
  (when (executable-find "ghq")
   (update-projectlist)))

;; migemo
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

;; nyan-mode
(leaf nyan-mode
  :init
  (progn (nyan-mode)
   (nyan-start-animation)))

;; snippets
(leaf tempel
  :require t
  :bind ((:evil-insert-state-map
	  ("m-a" . tempel-done)))
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

;; http request
(leaf request)
(leaf plz)

(autoload 'newsticker-start "newsticker" "start newsticker" t)
(autoload 'newsticker-show-news "newsticker" "goto newsticker buffer" t)

(setq newsticker-url-list
      '(("gleam weekly" "https://gleamweekly.com/atom.xml")
        ("zenn gleam" "https://zenn.dev/topics/gleam/feed")
	("gleam releases" "https://github.com/gleam-lang/gleam/releases.atom")
	("zenn trend" "https://zenn.dev/feed")
	("zenn emacs" "https://zenn.dev/topics/emacs/feed")
        ("zenn ts" "https://zenn.dev/topics/typescript/feed")
        ("zenn cl" "https://zenn.dev/topics/commonlisp/feed")
        ("zenn deno" "https://zenn.dev/topics/deno/feed")
        ("zenn bun" "https://zenn.dev/topics/bun/feed")
        ("zenn rust" "https://zenn.dev/topics/rust/feed")
        ("zenn vim" "https://zenn.dev/topics/vim/feed")
        ("zenn neovim" "https://zenn.dev/topics/neovim/feed")
        ("zenn scheme" "https://zenn.dev/topics/scheme/feed")
        ("zenn hono" "https://zenn.dev/topics/hono/feed")
        ("zenn react" "https://zenn.dev/topics/react/feed")
        ("zenn gcp" "https://zenn.dev/topics/googlecloud/feed")
        ("zenn aws" "https://zenn.dev/topics/aws/feed")
        ("techfeed" "https://techfeed.io/feeds/categories/all")
	("hacker news" "https://hnrss.org/frontpage")
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
	  ("c-a" . grugru))
	 (:evil-normal-state-map
	  ("c-x" . grugru-backward)))
  :config
  ;; ref: https://github.com/rocktakey/grugru/issues/44
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

;; (leaf folding-mode :require t)

(leaf rg
  :require t)

(leaf open-junk-file
  :require t
  :custom
  (open-junk-file-format . "/tmp/junk/%y_%m_%d_%h%m%s.")
  :bind (("c-x j" . open-junk-file)))

(leaf fold-this)

(leaf alert
  :config
  (setq alert-default-style 'libnotify))

(leaf dashboard
  :config
  (setq dashboard-startup-banner (expand-file-name "~/pictures/.emacs-logos/gnu_color_resize.png"))
  (setq dashboard-startup-banner 'logo))

(leaf aas
  ;; :hook (text-mode . aas-activate-for-major-mode)
  ;; :init
  ;; (aas-set-snippets 'global)
  ;; (aas-set-snippets 'markdown-mode)
  ;; (aas-set-snippets 'prog-mode)
  )

(leaf smartparens
  :config
  (smartparens-global-mode t))

(leaf vterm)

(leaf vterm-toggle
  :after evil
  :bind (("c-<return>" . (lambda ()
			   (interactive)
			   (vterm-toggle-insert-cd)
			   (vterm-toggle-insert-cd)))))

(leaf multi-vterm
  :config
  (setq multi-vterm-dedicated-window-height 50))

;; ai
 add-hook 'server-after-make-frame-hook
          (lambda ()
            (setenv "gemini_api_key" (get-secret "gemini.google.com")
            (setenv "openrouter_api_key" (get-secret "openrouter.ai"))
	    (setq gemini-apikey (get-secret "gemini.google.com"))))

(leaf gptel
  :config
  (setq
   ;; gptel-model 'starcoder2
   ;; gptel-backend (gptel-make-ollama "ollama"
   ;;                :host "localhost:11434"
   ;;                :stream t
   ;;                :models '(starcoder2)))

   gptel-model 'gemini-2.5-flash
   gptel-backend (gptel-make-gemini "gemini"
		   :key gemini-apikey
		   :stream t)))

;; ai codeing
(leaf aider
  :require t
  :custom
  (;; (aider-args . '("--watch-files" "--model" "gemini/gemini-2.0-flash"))
   (aider-args . '("--watch-files" "--model" "openrouter/anthropic/claude-3.5-sonnet"))
   ))

(leaf aidermacs
  :require t
  :config
  (setq aidermacs-watch-files t)
  :custom
  (;; (aidermacs-default-model . "gemini/gemini-2.0-flash")
   (aidermacs-default-model . "gemini/gemini-2.5-pro-preview-03-25")
   (aidermacs-watch-files . t)))
;; (aidermacs-default-model . "gemini/gemini-2.5-flash-preview-04-17")


(leaf mcp)

(leaf minimap
  :require t
  :custom ((minimap-window-location . 'right)
	   (minimap-minimum-width . 20)
	   (minimap-major-modes . '(prog-mode
				    markdown-mode
				    html-mode
				    fundamental-mode)))
  :bind ("c-x m" . minimap-mode)
  :config
  (minimap-mode 1))

(leaf rainbow-delimiters
  :hook
  (prog-mode-hook . rainbow-delimiters-mode))

(leaf ox-zenn
  :after org
  :require t)

(leaf verb)

(leaf quickrun)

;; ================ my extentions ================

(defun get-secret (host)
  "wrapper functino for auth-info"
  (require 'ht) 
  (let* ((found (cl-first (auth-source-search :host host
					      :user "coma")))
	 (credentials (when found
			(eval `(ht ,@(--map `(,it ,(plist-get found it))
                                            '(:user :secret :save-function))))))
	 (secret (when credentials
                   (ht-get credentials :secret))))

    (if (not secret)
	(progn (message (format "does not found %s credential." host))
	       "")
      (if (functionp secret)
          (funcall secret)
	secret))))

;; (defun nyan-region ()
;;   "選択範囲をにゃーんで置換する"
;;   (interactive)
;;   (when (use-region-p)
;;     (let* ((beg (region-beginning))
;;            (end (region-end)))
;;      (len (- end beg)
;;       (delete-region beg end)
;;       (cond ((= len 1) (insert "にゃ")))
;;       ((= len 2) (insert "にゃん"))
;;       (t (insert (format "にゃ%sん" (make-string (- len 3) ?ー))))))))

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

  (let* ((query (read-from-minibuffer "query? > ")))
   (url (concat "https://www.google.com/search?client=firefox-b-d&q=" (url-hexify-string query))
  
    (shell-command (concat "open " "'" url "'")))))

(defun home-manager ()
  (interactive)
  (start-process "home-manager-process"
     "*home-manager*"
     "home-manager"
     "switch"
     "--flake"
     ".#home"
     "-b"
     "backup"))

    ;; (set-process-sentinel proc
    ;;                           (lambda (process event)
    ;;                             (when (string= event "finished\n"))))

(defun all (pred lst)
  "returns t if all elements of the list satisfy the predicate."
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
  (let ((beg (save-excursion (skip-chars-backward "a-za-z") (point)))
        (end (point))
        (candidates gitmoji--codes))
    (list beg end candidates :exclusive 'no)))

;; collect gitmoji when startup
;; (add-hook 'emacs-startup-hook 'setup-gitmoji)
;; enable at git-commit-mode

;; display character count in modeline
(defun update-buffer-char-count ()
  (interactive)
  (format " [%d] " (buffer-size)))

(defun mode-line-time ()
  ;; update every second
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

;; for diary
(setq blog-repo "/home/coma/.ghq/github.com/comamoca/blog/")

(defun latest-diary ()
  "open latest diary. this function call in `src/blog/` directory at blog repository."
  (interactive)
  (let* ((date (format-time-string "%y-%m-%d"))
         (file-name (format "%s-diary.md" date))
         (path (concat (expand-file-name "src/blog/" blog-repo) file-name)))
    (find-file path)
    (if (= (buffer-size) 0)
	(tempel-insert 'diary))))

(defun new-blog-article ()
  "open latest diary. this function call in `src/blog/` directory at blog repository."
  (interactive)
  (let* ((date (format-time-string "%y-%m-%d"))
         (slug (read-string "slug > "))
         (file-name (format "%s-%s.md" date slug))
         (path (concat (expand-file-name "src/blog/" blog-repo) file-name)))
    ;; (projectile-switch-project-by-name "blog")
    (find-file path)))

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
	 (mdfiles (cl-remove-if-not (lambda (file))))
	 (articles (cl-remove-if (lambda (file)))
		   (string-match "-diary.md$" file
				 files))
	 (selected (completing-read "blog " articles)))
    (find-file (expand-file-name selected src-dir)))) 

(defun org-paste-image ()
  (interactive)
  (setq filename (concat
                  (expand-file-name (format-time-string "%y-%m-%d-%h%m%s")
                   "~/.ghq/github.com/comamoca/org/imgs") ".png"))
  (shell-command (concat  "wl-paste -t image/png > " filename))
  (insert (concat "[[" filename "]]"))
  (org-display-inline-images))

(defun blog-paste-image ()
  (interactive)
  (setq fullpath (concat
                  (expand-file-name (format-time-string "%y-%m-%d-%h%m%s")
				    "~/.ghq/github.com/comamoca/blog/src/images") ".png"))
  (shell-command (concat  "wl-paste -t image/png > " fullpath))
  (insert (concat "![](/images/" (file-name-nondirectory fullpath) ")"))
  (org-display-inline-images))


;; gauche
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
  (let* ((node-items (mapcar (lambda (node)))
             (cons (org-roam-node-title node) node)) (org-roam-node-list))
   (select-node-title (consult--read)
        (mapcar #'car node-items))
   (select-node (cdr (assoc select-node-title node-items))

    (find-file (org-roam-node-file select-node)))))

;; pinentry emacs
(defun pinentry-emacs (desc prompt ok error)
  (let ((str (read-passwd (concat (replace-regexp-in-string "%22" "\"" (replace-regexp-in-string "%0a" "\n" desc)) prompt ": "))))
    str))

;; initel function that behaves like `:e $myvimrc`
(defun initel ()
  (interactive)
  (find-file user-init-file))

;; ================ my configuratons ================

;; ediff
(setq ediff-window-setup-function 'ediff-setup-windows-plain)

;; font
(add-to-list 'default-frame-alist
                       '(font . "udev gothic nf-14"))

;; for auth-info
(setq auth-sources '("~/.emacs.d/.authinfo.gpg"))
(setq create-lockfiles nil)

;; for lsp-mode
(setq gc-cons-threshold 100000000)
(setq read-process-output-max (* 1024 1024))

;; key mapping
(define-key global-map (kbd "c-x s") 'blackening-region)
(define-key global-map (kbd "c-;") 'comment-dwim)

;; minibuffe
(define-key minibuffer-local-map (kbd "c-h") 'delete-char)
(define-key minibuffer-local-ns-map (kbd "c-h") 'delete-char)
(define-key minibuffer-local-completion-map (kbd "c-h") 'delete-char)
(define-key minibuffer-local-must-match-map (kbd "c-h") 'delete-char)
(define-key minibuffer-local-filename-completion-map (kbd "c-h") 'delete-char)

;; enable debug
(setq debug-on-error nil)

;; custom modeline
(mode-line-format-update)

;; when org-mode
(add-hook 'org-mode
    (lambda ()
      (local-set-key evil-insert-state-map (kbd "c-h") #'org-insert-heading)))

(electric-pair-mode 1)

(global-hl-line-mode t)

(setq vc-follow-symlinks t)
(setq browse-url-generic-program "firefox")
(setq ring-bell-function 'ignore)

(setq display-warning-minimum-level :error)

;; disable to create backupfile
(setq make-backup-files nil)

;; disable to auto save
(setq auto-save-default nil)

;; copy & paste with wl-clipboard
;; ref: https://gist.github.com/yorickvp/6132f237fbc289a45c808d8d75e0e1fb
(setenv "wayland_display" "wayland-1")

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
  :bind (("c-c e" . macrostep-expand)))

;; (provide 'init)
(put 'narrow-to-region 'disabled nil)
(custom-set-variables
 ;; custom-set-variables was added by custom.
 ;; if you edit it by hand, you could mess it up, so be careful.
 ;; your init file should contain only one such instance.
 ;; if there is more than one, they won't work right.
 '(skk-jisyo-edit-user-accepts-editing t))
(custom-set-faces)
 ;; custom-set-faces was added by custom.
 ;; if you edit it by hand, you could mess it up, so be careful.
 ;; your init file should contain only one such instance.
 ;; if there is more than one, they won't work right.
 

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

;; theme
(leaf catppuccin-theme 
  :preface
  :config
  (load-theme 'catppuccin t))

;; minibuffer ui
(leaf vertico
  :require orderless
  :config
  (defvar vertico-count 10)
  ;; completion style config
  (setq completion-styles '(orderless basic)
	completion-category-overrides '((file (styles basic partial-completion))))
  :init 
  (vertico-mode))

;; completion styles
(leaf orderless)

(leaf hotfuzz)

;; completing read functions
(leaf consult
  :require t
  :after evil
  :bind ((:evil-normal-state-map
	  ("c-l" . consult-line)
	  ("c-i" . consult-buffer)))
  :bind* (("c-." . embark-act)))

(leaf consult-dir)

;; embark
(leaf embark
  :after evil
  :bind ((:evil-normal-state-map
	  ("c-." . embark-act)
	  ("c--" . embark-export))
	 (:evil-insert-state-map
	  ("c-." . embark-act))))

;; affe
(leaf affe)

;; for consult
(leaf embark-consult
  :bind ((:minibuffer-mode-map
	  ("m-." . embark-dwin)
	  ("c-." . embark-act))))

;; vim keybind
(leaf evil
  :require t
  :bind ((:evil-normal-state-map
	  ("c-k" . evil-scroll-up)
	  ("c-j" . evil-scroll-down))
	 (:evil-insert-state-map
	  ;; ("c-j" . newline-and-indent)
	  ("c-h" . backward-char)))
 
  :config
  (evil-mode 1))

;; structured editing 
(leaf puni
  :config
  (global-set-key (kbd "c--") 'puni-expand-region)
  :bind ((:evil-insert-state-map
	  ("s" . nil)
	  ;; ("sd" . puni-splice)
	  ("c-i" . puni-mark-sexp-at-point)
	  ("c-p" . puni-slurp-forward)
	  ("c-n" . puni-barf-forward)))
  :init
  (puni-global-mode))

;; indent guides
(leaf highlight-indent-guides)

;; treesitter
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
  (add-to-list 'auto-mode-alist '("dockerfile" . dockerfile-ts-mode)))

(leaf treesit-auto
  :require t
  :custom
  ((treesit-auto-install . t)
   (treesit-extra-load-path . `(,(expand-file-name "~/.cache/dpp/_generated/nvim-treesitter/parser"))))
  :config  
  (global-treesit-auto-mode)
  ;; (treesit-auto-install 'prompt)
  ;; (treesit-auto-add-to-auto-mode-alist 'all)
  )

;; for envrc
(leaf envrc)

;; calendar 
(leaf calendar)

;; org-mode
(leaf org
  :after calendar-mode
  :custom
  ((org-todo-keywords .
		      '((sequence "todo(t)" "pending(p)" "|" "done(d)" "canceled(c)")))
   (org-default-notes-file . "notes.org")
   `(org-directory . ,(expand-file-name "~/.ghq/github.com/comamoca/org"))
   `(diary-file-path . ,(format-time-string "diary/%y/%m-%d.org"))
   `(memo-file-path . ,(format-time-string "memo/%y/%m/%d.org"))
   `(diary-path . ,(concat org-directory "/diary"))
   (org-publish-use-timestamps-flag . nil)

   ;; org-capture
   (org-capture-templates .
			  '(("d" "diary" plain (file diary-file-path)
			     "** 今日やったこと\n\n** 明日以降やりたいこと")
			    ("m" "memo" plain (file memo-file-path) "")))

   (org-publish-project-alist .
			      '(("diary"
				 :base-directory "~/.ghq/github.com/comamoca/org/diary"
				 :base-extension "org"  
				 :recursive t
				 :publishing-directory  "~/.ghq/github.com/comamoca/org/dist"
				 :publishing-function org-html-publish-to-html
				 :include ("index.org")
				 :exclude ())
     
				("note"
				 :base-directory "~/.ghq/github.com/comamoca/org/note"
				 :base-extension "org"  
				 :recursive t
				 :publishing-directory  "~/.ghq/github.com/comamoca/org/note/dist"
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
  (set-language-environment "japanese")
  (prefer-coding-system 'utf-8)
  (set-default 'buffer-file-coding-system 'utf-8)

  (org-babel-do-load-languages
   'org-babel-load-languages
   '((c . t)
     (shell . t)
     (python . t)
     (clojure . t)
     (hy . t)
     (ruby . t)
     (ledger . t)))
  :bind ((:calendar-mode-map
	  ("c-c c" . org-capture-from-calendar)))
  :init
  ;; org-calendar
  ;; (with-eval-after-load 'calendar
  ;;     (define-key calendar-mode-map (kbd "c-c c") 'org-capture-from-calendar))
  )

;; org-journal
(leaf org-journal
  :after org
  :custom
  ((org-journal-time-format . "")
   (org-journal-time-prefix . "")
   `(org-journal-dir . ,(concat org-directory (format-time-string "/diary/%y")))
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

;; deft
;; for search roam files.
(leaf deft
  :after org-roam-mode
  :custom
  ((deft-extensions . '("txt" "tex" "org"))
   `(deft-directory . ,(expand-file-name "roam" org-directory))))

(leaf org-roam-ui)

;; org-bullets
(leaf org-bullets
  :after org
  ;; :init
  ;; (org-bullets-mode 1)
  )

;; org-modern
(leaf org-modern
  :after
  :init
  (with-eval-after-load 'org (global-org-modern-mode)))

(leaf org-modern-indent)

;; org-babel
(leaf ob-hy)

(leaf org-nix-shell)

;; magit
(leaf magit
  :custom
  ((transient-default-level . 5))
  :bind ((:global-map
	  ("c-x g" . magit-status))
	 (:magit-mode-map
	  ("/" . isearch-forward))))

;; forge
(leaf forge
  :after magit)

;; skk
(leaf ddskk
  :custom ((default-input-method . "japanease-skk")
	   (skk-auto-insert-paren . t)
	   (skk-comp-mode . t)
	   (skk-delete-implies-kakutei . nil))
  :config
  (skk-latin-mode 1)
  (global-set-key (kbd "c-x c-j") 'skk-mode)
  (global-set-key (kbd "<henkan>") 'skk-kakutei)
  (global-set-key (kbd "<muhenkan>") 'skk-latin-mode))

(leaf ddskk-posframe
  :global-minor-mode t)

;; common lisp
(leaf slime
  :config
  (defvar inferior-lisp-program "sbcl"))

(leaf sly
  :config)
  ;; (defvar inferior-lisp-program "sbcl")

(leaf sly-asdf)

;; clojure
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
  "a linter for prose."
  :command ("textlint" "--format" "unix" source-inplace)
  :error-patterns
  ((warning line-start (file-name) ":" line ":" column ": "
      (id (one-or-more (not (any " "))))
      (message (one-or-more not-newline)
        (zero-or-more "\n" (any " ") (one-or-more not-newline)))
      line-end))
  :modes (text-mode markdown-mode gfm-mode org-mode web-mode))

;; copilot
(leaf copilot
  :bind ((:copilot-completion-map
	  ("tab" . copilot-accept-completion)))
  :config
  (add-to-list 'copilot-major-mode-alist '("enh-ruby" . "ruby"))
  (add-to-list 'copilot-major-mode-alist '("typescript-ts-mode" . "typescript")))

;; lsp
(leaf lsp-bridge
  :require t
  :custom
  ((acm-enable-capf . t)
   (acm-frame-background-dark-color . "#313244"))
  :config
  (setq lsp-bridge-get-single-lang-server-by-project
	(lambda (project-path file-path)
	  (message project-path)
	  (when (or (expand-file-name "package.json" project-path))
	    "typescript-language-server")
	  "deno"))
  :init
  (global-lsp-bridge-mode))



;; lso-mode
;; (leaf lsp-mode
;;   :require t
;;   :custom
;;   ((lsp-completion-provider . :none))
;;   :config
;;   (setenv "lsp_use_plists" "true")

;;   (define-key evil-normal-state-map (kbd "k") 'lsp-ui-doc-glance)

;;   (add-to-list 'lsp-language-id-configuration
;; 	       '(nix-mode . "nil")
;; 	       '(python-mode . "python"))

;;   (defun corfu-lsp-setup ()
;;     (setq completion-at-point-functions '(lsp-completion-at-point))
;;     (setq-local completion-styles '(orderless)
;; 		completion-category-defaults nil))

;;   (add-hook 'lsp-mode-hook #'corfu-lsp-setup)
;;   (add-hook 'prog-mode-hook #'lsp-deferred))

;; ;; lsp booster
;; (defun lsp-booster--advice-json-parse (old-fn &rest args)
;;   "try to parse bytecode instead of json."
;;   (or
;;    (when (equal (following-char) ?#)
;;      (let ((bytecode (read (current-buffer))))
;;        (when (byte-code-function-p bytecode)
;;          (funcall bytecode))))
;;    (apply old-fn args)))

;; (advice-add (if (progn (require 'json)
;;                        (fboundp 'json-parse-buffer))
;;                 'json-parse-buffer
;;               'json-read)
;;             :around
;;             #'lsp-booster--advice-json-parse)

;; (defun lsp-booster--advice-final-command (old-fn cmd &optional test?)
;;   "prepend emacs-lsp-booster command to lsp cmd."
;;   (let ((orig-result (funcall old-fn cmd test?)))
;;     (if (and (not test?)                             ;; for check lsp-server-present?
;;              (not (file-remote-p default-directory)) ;; see lsp-resolve-final-command, it would add extra shell wrapper
;;              lsp-use-plists
;;              (not (functionp 'json-rpc-connection))  ;; native json-rpc
;;              (executable-find "emacs-lsp-booster"))
;;         (progn
;;           (when-let ((command-from-exec-path (executable-find (car orig-result))))  ;; resolve command from exec-path (in case not found in $path)
;;             (setcar orig-result command-from-exec-path))
;;           (message "using emacs-lsp-booster for %s!" orig-result)
;;           (cons "emacs-lsp-booster" orig-result))
;;       orig-result)))

;; (advice-add 'lsp-resolve-final-command :around #'lsp-booster--advice-final-command)

;; eglot
;; (defun deno-project-p ()
;;   "predicate for determining if the open project is a deno one."
;;   (let ((p-root (nth 2 (project-current))))
;;     (or (file-exists-p (expand-file-name "deno.json" default-directory))
;; 	(file-exists-p (expand-file-name "deno.jsonc" default-directory)))))

;; (defun node-project-p ()
;;   "predicate for determining if the open project is a deno one."
;;   (let ((p-root (nth 2 (project-current))))
;;     (file-exists-p (expand-file-name "package.json" default-directory))))

;; (defun es-server-program (_)
;;   "decide which server to use for ecma script based on project characteristics."
;;   (cond ((deno-project-p) '("deno" "lsp" :initializationoptions (:enable t :lint t)))
;;         ((node-project-p) '("typescript-language-server" "--stdio"))
;;         (t nil)))

;; (leaf eglot
;;   :hook
;;   (c++-mode . eglot-ensure)
;;   (sh-mode . eglot-ensure)
;;   (python-mode . eglot-ensure)
;;   (html-mode . eglot-ensure)
;;   (cmake-mode . eglot-ensure)
;;   (bitbake-mode . eglot-ensure)
;;   (typescript-ts-mode . eglot-ensure)
;;   :config
;;   ;; (add-to-list 'eglot-server-programs '((bitbake-mode) "bitbake-language-server"))
;;   (add-to-list 'eglot-server-programs '((js-mode typescript-mode) . es-server-program))
;;   (add-to-list 'eglot-server-programs '(gleam-ts-mode . ("lspx" "--lsp" "gleam lsp")))
;;   :bind (("m-t" . xref-find-definitions)
;; 	 ("m-r" . xref-find-references)
;; 	 ("c-t" . xref-go-back)))

;; (leaf eglot-booster
;;   :after eglot
;;   :config (eglot-booster-mode))

;; auto formatting
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
 
;; lua support
(leaf lua-mode)

;; completion
(leaf corfu
  :custom
  ((corfu-cycle . t)
  (corfu-auto . t)
  (corfu-auto-prefix . 1))
  :init
  (global-corfu-mode))


;; cursor moation
(leaf avy
  :config
  (define-key evil-normal-state-map (kbd "spc k") #'avy-goto-line))

;; completion soruce
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

;; hydra
(leaf hydra)
(leaf hydra-posframe
  ;; :require t
  ;; :vc (:url "https://github.com/ladicle/hydra-posframe")

  :init
  ;; for hydra
  (define-key evil-normal-state-map (kbd "spc w") #'manage-window-hydra/body)

  :hook
  (add-hook 'after-init-hook 'hydra-posframe-mode))

(leaf major-mode-hydra)

;; for nix
(pretty-hydra-define nix-flake-hydra
  (:separator "-" :title "nix flake" :forigen-key warn :quit-key "q" :exit t)
  ("build"
   (("b" nix-flake-build-default "build"))

   "update"
   (("u" nix-flake-update "update"))))

;; for manage window
(pretty-hydra-define manage-window-hydra
  (:separator "-" :title "manage window" :forigen-key warn :quit-key "q" :exit t)
  ("1"
   (("a" delete-other-windows "delte other windwos"))

   "2"
   (("s" split-window-below "horizontal split"))

   "3"
   (("d" split-window-right "vertical split"))

   "0"
   (("f" delete-window "delete window"))))

(pretty-hydra-define org-hydra
  (:separator "-" :title "nix flake" :forigen-key warn :quit-key "q" :exit t)
  ("roam"
   (("a" org-roam-node-find "roam"))

   "capture"
   (("s" org-capture "capture"))))
    

;; (pretty-hydra-define org-roam-hydra
;;   (:separator "-" :title "org-roam" :forigen-key warn :quit-key "q" :exit t)
;;   ("find"
;;    (("a" 'org-roam-node-find "find node"))

;;    ""
;;    (("s" 'org-roam- ""))

;;    ""
;;    (("d"  ""))

;;    ""
;;    (("f"  ""))
;;     ))

;; transient dispatcher
(leaf transient-dwim
  :bind ("c-=" . transient-dwim-dispatch))

;; tree filer
(leaf neotree
  :custom
  (neo-smart-open . t)
  (projectile-switch-project-action . 'neotree-projectile-action)
  :config
  (progn
    (evil-define-key 'normal neotree-mode-map (kbd "q") 'neotree-hide)
    (evil-define-key 'normal neotree-mode-map (kbd "l") 'neotree-enter)
    (evil-define-key 'normal neotree-mode-map (kbd "ret") 'neotree-enter)
    (evil-define-key 'normal neotree-mode-map (kbd "h") 'neotree-enter)
    (evil-define-key 'normal neotree-mode-map (kbd "g") 'neotree-refresh)
    (evil-define-key 'normal neotree-mode-map (kbd "j") 'neotree-next-line)
    (evil-define-key 'normal neotree-mode-map (kbd "k") 'neotree-previous-line)
    (evil-define-key 'normal neotree-mode-map (kbd "a") 'neotree-stretch-toggle)
    (evil-define-key 'normal neotree-mode-map (kbd "h") 'neotree-hidden-file-toggle)
    (evil-define-key 'normal neotree-mode-map (kbd "n") 'neotree-create-node)
    (evil-define-key 'normal neotree-mode-map (kbd "k") 'neotree-create-node)
    (evil-define-key 'normal neotree-mode-map (kbd "d") 'neotree-delete-node)
    (evil-define-key 'normal neotree-mode-map (kbd "m") 'neotree-rename-node))
  
  ;; for neotree
  (define-key evil-normal-state-map (kbd "spc f") #'neotree-toggle))
  

;; translate
(leaf google-translate
  :require t
  :custom
  (google-translate-translation-directions-alist . '(("en" . "ja")
                                                     ("ja" . "en"))))
;; wakatime
(leaf wakatime-mode
  :init
  (global-wakatime-mode))

;; typst

;; preview
(leaf typst-preview
  ;; :vc (:url "https://github.com/havarddj/typst-preview.el")
  ;; :require t
  :config
  (setq typst-preview-browser "firefox"))

;; ruby support
(leaf inf-ruby)

(leaf enh-ruby-mode)

;; python support
(add-hook 'python-ts-mode-hook (lambda ()
				 (require 'python-mode)))

;; language supports

;; dotnet
(leaf dotnet
  :after csharp-mode)

;; c#
(leaf csharp-mode)

;; nix support
(leaf nix-mode
  :hook
  (nix-ts-mode))

;; scala suppport
(leaf scala-mode
  :interpreter ("scala" . scala-mode))


(leaf sbt-mode
  :commands sbt-start sbt-command
  :config
  (substitute-key-definition
   'minibuffer-complete-word
   'self-insert-command
   minibuffer-local-completion-map)

   (setq sbt:program-options '("-dsbt.supershell=false")))

;; astro support
(leaf astro-ts-mode)

;; elixir support
(leaf inf-elixir)
(leaf mix)

(leaf elixir-ts-mode
  :hook ((elixir-ts-mode . mix-minor-mode)))

;; kdl supports
(leaf kdl-ts-mode)

;; gleam support
(leaf gleam-ts-mode
  :require t
  :hook gleam-on-save-mode)

;; markdown suppot
(leaf markdown-mode
  :hook
  (add-to-list 'completion-at-point-functions #'cape-emoji))

;; projectile
(defun update-projectlist ()
  (interactive)
  (setq projectile-known-projects
         (mapcar
          (lambda (x) (abbreviate-file-name x))
          (split-string (shell-command-to-string "ghq list --full-path")))))

(leaf projectile 
  :config
  (define-key evil-normal-state-map (kbd "m-g") #'projectile-switch-project)
  (define-key evil-normal-state-map (kbd "c-o") #'projectile-find-file)
  :init
  (when (executable-find "ghq")
   (update-projectlist)))

;; migemo
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

;; nyan-mode
(leaf nyan-mode
  :init
  (progn (nyan-mode)
   (nyan-start-animation)))

;; snippets
(leaf tempel
  :require t
  :bind ((:evil-insert-state-map
	  ("m-a" . tempel-done)))
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

;; http request
(leaf request)
(leaf plz)

(autoload 'newsticker-start "newsticker" "start newsticker" t)
(autoload 'newsticker-show-news "newsticker" "goto newsticker buffer" t)

(setq newsticker-url-list
      '(("gleam weekly" "https://gleamweekly.com/atom.xml")
        ("zenn gleam" "https://zenn.dev/topics/gleam/feed")
	("gleam releases" "https://github.com/gleam-lang/gleam/releases.atom")
	("zenn trend" "https://zenn.dev/feed")
	("zenn emacs" "https://zenn.dev/topics/emacs/feed")
        ("zenn ts" "https://zenn.dev/topics/typescript/feed")
        ("zenn cl" "https://zenn.dev/topics/commonlisp/feed")
        ("zenn deno" "https://zenn.dev/topics/deno/feed")
        ("zenn bun" "https://zenn.dev/topics/bun/feed")
        ("zenn rust" "https://zenn.dev/topics/rust/feed")
        ("zenn vim" "https://zenn.dev/topics/vim/feed")
        ("zenn neovim" "https://zenn.dev/topics/neovim/feed")
        ("zenn scheme" "https://zenn.dev/topics/scheme/feed")
        ("zenn hono" "https://zenn.dev/topics/hono/feed")
        ("zenn react" "https://zenn.dev/topics/react/feed")
        ("zenn gcp" "https://zenn.dev/topics/googlecloud/feed")
        ("zenn aws" "https://zenn.dev/topics/aws/feed")
        ("techfeed" "https://techfeed.io/feeds/categories/all")
	("hacker news" "https://hnrss.org/frontpage")
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
	  ("c-a" . grugru))
	 (:evil-normal-state-map
	  ("c-x" . grugru-backward)))
  :config
  ;; ref: https://github.com/rocktakey/grugru/issues/44
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

;; (leaf folding-mode :require t)

(leaf rg
  :require t)

(leaf open-junk-file
  :require t
  :custom
  (open-junk-file-format . "/tmp/junk/%y_%m_%d_%h%m%s.")
  :bind (("c-x j" . open-junk-file)))

(leaf fold-this)

(leaf alert
  :config
  (setq alert-default-style 'libnotify))

(leaf dashboard
  :config
  (setq dashboard-startup-banner (expand-file-name "~/pictures/.emacs-logos/gnu_color_resize.png"))
  (setq dashboard-startup-banner 'logo))

(leaf aas
  ;; :hook (text-mode . aas-activate-for-major-mode)
  ;; :init
  ;; (aas-set-snippets 'global)
  ;; (aas-set-snippets 'markdown-mode)
  ;; (aas-set-snippets 'prog-mode)
  )

(leaf smartparens
  :config
  (smartparens-global-mode t))

(leaf vterm)

(leaf vterm-toggle
  :after evil
  :bind (("c-<return>" . (lambda ()
			   (interactive)
			   (vterm-toggle-insert-cd)
			   (vterm-toggle-insert-cd)))))

(leaf multi-vterm
  :config
  (setq multi-vterm-dedicated-window-height 50))

;; ai
 add-hook 'server-after-make-frame-hook
          (lambda ()
            (setenv "gemini_api_key" (get-secret "gemini.google.com")
            (setenv "openrouter_api_key" (get-secret "openrouter.ai"))
	    (setq gemini-apikey (get-secret "gemini.google.com"))))

(leaf gptel
  :config
  (setq
   ;; gptel-model 'starcoder2
   ;; gptel-backend (gptel-make-ollama "ollama"
   ;;                :host "localhost:11434"
   ;;                :stream t
   ;;                :models '(starcoder2)))

   gptel-model 'gemini-2.5-flash
   gptel-backend (gptel-make-gemini "gemini"
		   :key gemini-apikey
		   :stream t)))

;; ai codeing
(leaf aider
  :require t
  :custom
  (;; (aider-args . '("--watch-files" "--model" "gemini/gemini-2.0-flash"))
   (aider-args . '("--watch-files" "--model" "openrouter/anthropic/claude-3.5-sonnet"))
   ))

(leaf aidermacs
  :require t
  :config
  (setq aidermacs-watch-files t)
  :custom
  (;; (aidermacs-default-model . "gemini/gemini-2.0-flash")
   (aidermacs-default-model . "gemini/gemini-2.5-pro-preview-03-25")
   (aidermacs-watch-files . t)))
;; (aidermacs-default-model . "gemini/gemini-2.5-flash-preview-04-17")


(leaf mcp)

(leaf minimap
  :require t
  :custom ((minimap-window-location . 'right)
	   (minimap-minimum-width . 20)
	   (minimap-major-modes . '(prog-mode
				    markdown-mode
				    html-mode
				    fundamental-mode)))
  :bind ("c-x m" . minimap-mode)
  :config
  (minimap-mode 1))

(leaf rainbow-delimiters
  :hook
  (prog-mode-hook . rainbow-delimiters-mode))

(leaf ox-zenn
  :after org
  :require t)

(leaf verb)

(leaf quickrun)

;; ================ my extentions ================

(defun get-secret (host)
  "wrapper functino for auth-info"
  (require 'ht) 
  (let* ((found (cl-first (auth-source-search :host host
					      :user "coma")))
	 (credentials (when found
			(eval `(ht ,@(--map `(,it ,(plist-get found it))
                                            '(:user :secret :save-function))))))
	 (secret (when credentials
                   (ht-get credentials :secret))))

    (if (not secret)
	(progn (message (format "does not found %s credential." host))
	       "")
      (if (functionp secret)
          (funcall secret)
	secret))))

;; (defun nyan-region ()
;;   "選択範囲をにゃーんで置換する"
;;   (interactive)
;;   (when (use-region-p)
;;     (let* ((beg (region-beginning))
;;            (end (region-end)))
;;      (len (- end beg)
;;       (delete-region beg end)
;;       (cond ((= len 1) (insert "にゃ")))
;;       ((= len 2) (insert "にゃん"))
;;       (t (insert (format "にゃ%sん" (make-string (- len 3) ?ー))))))))

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

  (let* ((query (read-from-minibuffer "query? > ")))
   (url (concat "https://www.google.com/search?client=firefox-b-d&q=" (url-hexify-string query))
  
    (shell-command (concat "open " "'" url "'")))))

(defun home-manager ()
  (interactive)
  (start-process "home-manager-process"
     "*home-manager*"
     "home-manager"
     "switch"
     "--flake"
     ".#home"
     "-b"
     "backup"))

    ;; (set-process-sentinel proc
    ;;                           (lambda (process event)
    ;;                             (when (string= event "finished\n"))))

(defun all (pred lst)
  "returns t if all elements of the list satisfy the predicate."
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
  (let ((beg (save-excursion (skip-chars-backward "a-za-z") (point)))
        (end (point))
        (candidates gitmoji--codes))
    (list beg end candidates :exclusive 'no)))

;; collect gitmoji when startup
;; (add-hook 'emacs-startup-hook 'setup-gitmoji)
;; enable at git-commit-mode

;; display character count in modeline
(defun update-buffer-char-count ()
  (interactive)
  (format " [%d] " (buffer-size)))

(defun mode-line-time ()
  ;; update every second
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

;; for diary
(setq blog-repo "/home/coma/.ghq/github.com/comamoca/blog/")

(defun latest-diary ()
  "open latest diary. this function call in `src/blog/` directory at blog repository."
  (interactive)
  (let* ((date (format-time-string "%y-%m-%d"))
         (file-name (format "%s-diary.md" date))
         (path (concat (expand-file-name "src/blog/" blog-repo) file-name)))
    (find-file path)
    (if (= (buffer-size) 0)
	(tempel-insert 'diary))))

(defun new-blog-article ()
  "open latest diary. this function call in `src/blog/` directory at blog repository."
  (interactive)
  (let* ((date (format-time-string "%y-%m-%d"))
         (slug (read-string "slug > "))
         (file-name (format "%s-%s.md" date slug))
         (path (concat (expand-file-name "src/blog/" blog-repo) file-name)))
    ;; (projectile-switch-project-by-name "blog")
    (find-file path)))

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
	 (mdfiles (cl-remove-if-not (lambda (file))))
	 (articles (cl-remove-if (lambda (file)))
		   (string-match "-diary.md$" file
				 files))
	 (selected (completing-read "blog " articles)))
    (find-file (expand-file-name selected src-dir)))) 

(defun org-paste-image ()
  (interactive)
  (setq filename (concat
                  (expand-file-name (format-time-string "%y-%m-%d-%h%m%s")
                   "~/.ghq/github.com/comamoca/org/imgs") ".png"))
  (shell-command (concat  "wl-paste -t image/png > " filename))
  (insert (concat "[[" filename "]]"))
  (org-display-inline-images))

(defun blog-paste-image ()
  (interactive)
  (setq fullpath (concat
                  (expand-file-name (format-time-string "%y-%m-%d-%h%m%s")
				    "~/.ghq/github.com/comamoca/blog/src/images") ".png"))
  (shell-command (concat  "wl-paste -t image/png > " fullpath))
  (insert (concat "![](/images/" (file-name-nondirectory fullpath) ")"))
  (org-display-inline-images))


;; gauche
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
  (let* ((node-items (mapcar (lambda (node)))
             (cons (org-roam-node-title node) node)) (org-roam-node-list))
   (select-node-title (consult--read)
        (mapcar #'car node-items))
   (select-node (cdr (assoc select-node-title node-items))

    (find-file (org-roam-node-file select-node)))))

;; pinentry emacs
(defun pinentry-emacs (desc prompt ok error)
  (let ((str (read-passwd (concat (replace-regexp-in-string "%22" "\"" (replace-regexp-in-string "%0a" "\n" desc)) prompt ": "))))
    str))

;; initel function that behaves like `:e $myvimrc`
(defun initel ()
  (interactive)
  (find-file user-init-file))

;; ================ my configuratons ================

;; ediff
(setq ediff-window-setup-function 'ediff-setup-windows-plain)

;; font
(add-to-list 'default-frame-alist
                       '(font . "udev gothic nf-14"))

;; for auth-info
(setq auth-sources '("~/.emacs.d/.authinfo.gpg"))
(setq create-lockfiles nil)

;; for lsp-mode
(setq gc-cons-threshold 100000000)
(setq read-process-output-max (* 1024 1024))

;; key mapping
(define-key global-map (kbd "c-x s") 'blackening-region)
(define-key global-map (kbd "c-;") 'comment-dwim)

;; minibuffe
(define-key minibuffer-local-map (kbd "c-h") 'delete-char)
(define-key minibuffer-local-ns-map (kbd "c-h") 'delete-char)
(define-key minibuffer-local-completion-map (kbd "c-h") 'delete-char)
(define-key minibuffer-local-must-match-map (kbd "c-h") 'delete-char)
(define-key minibuffer-local-filename-completion-map (kbd "c-h") 'delete-char)

;; enable debug
(setq debug-on-error nil)

;; custom modeline
(mode-line-format-update)

;; when org-mode
(add-hook 'org-mode
    (lambda ()
      (local-set-key evil-insert-state-map (kbd "c-h") #'org-insert-heading)))

(electric-pair-mode 1)

(global-hl-line-mode t)

(setq vc-follow-symlinks t)
(setq browse-url-generic-program "firefox")
(setq ring-bell-function 'ignore)

(setq display-warning-minimum-level :error)

;; disable to create backupfile
(setq make-backup-files nil)

;; disable to auto save
(setq auto-save-default nil)

;; copy & paste with wl-clipboard
;; ref: https://gist.github.com/yorickvp/6132f237fbc289a45c808d8d75e0e1fb
(setenv "wayland_display" "wayland-1")

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
  :bind (("c-c e" . macrostep-expand)))

;; (provide 'init)
(put 'narrow-to-region 'disabled nil)
(custom-set-variables
 ;; custom-set-variables was added by custom.
 ;; if you edit it by hand, you could mess it up, so be careful.
 ;; your init file should contain only one such instance.
 ;; if there is more than one, they won't work right.
 '(skk-jisyo-edit-user-accepts-editing t))
(custom-set-faces)
 ;; custom-set-faces was added by custom.
 ;; if you edit it by hand, you could mess it up, so be careful.
 ;; your init file should contain only one such instance.
 ;; if there is more than one, they won't work right.
 
  :config
  (evil-mode 1))

;; structured editing 
(leaf puni
  :config
  (global-set-key (kbd "c--") 'puni-expand-region)
  :bind ((:evil-insert-state-map
	  ("s" . nil)
	  ;; ("sd" . puni-splice)
	  ("c-i" . puni-mark-sexp-at-point)
	  ("c-p" . puni-slurp-forward)
	  ("c-n" . puni-barf-forward)))
  :init
  (puni-global-mode))

;; indent guides
(leaf highlight-indent-guides)

;; treesitter
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
  (add-to-list 'auto-mode-alist '("dockerfile" . dockerfile-ts-mode)))

(leaf treesit-auto
  :require t
  :custom
  ((treesit-auto-install . t)
   (treesit-extra-load-path . `(,(expand-file-name "~/.cache/dpp/_generated/nvim-treesitter/parser"))))
  :config  
  (global-treesit-auto-mode)
  ;; (treesit-auto-install 'prompt)
  ;; (treesit-auto-add-to-auto-mode-alist 'all)
  )

;; for envrc
(leaf envrc)

;; calendar 
(leaf calendar)

;; org-mode
(leaf org
  :after calendar-mode
  :custom
  ((org-todo-keywords .
		      '((sequence "todo(t)" "pending(p)" "|" "done(d)" "canceled(c)")))
   (org-default-notes-file . "notes.org")
   `(org-directory . ,(expand-file-name "~/.ghq/github.com/comamoca/org"))
   `(diary-file-path . ,(format-time-string "diary/%y/%m-%d.org"))
   `(memo-file-path . ,(format-time-string "memo/%y/%m/%d.org"))
   `(diary-path . ,(concat org-directory "/diary"))
   (org-publish-use-timestamps-flag . nil)

   ;; org-capture
   (org-capture-templates .
			  '(("d" "diary" plain (file diary-file-path)
			     "** 今日やったこと\n\n** 明日以降やりたいこと")
			    ("m" "memo" plain (file memo-file-path) "")))

   (org-publish-project-alist .
			      '(("diary"
				 :base-directory "~/.ghq/github.com/comamoca/org/diary"
				 :base-extension "org"  
				 :recursive t
				 :publishing-directory  "~/.ghq/github.com/comamoca/org/dist"
				 :publishing-function org-html-publish-to-html
				 :include ("index.org")
				 :exclude ())
     
				("note"
				 :base-directory "~/.ghq/github.com/comamoca/org/note"
				 :base-extension "org"  
				 :recursive t
				 :publishing-directory  "~/.ghq/github.com/comamoca/org/note/dist"
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
  (set-language-environment "japanese")
  (prefer-coding-system 'utf-8)
  (set-default 'buffer-file-coding-system 'utf-8)

  (org-babel-do-load-languages
   'org-babel-load-languages
   '((c . t)
     (shell . t)
     (python . t)
     (clojure . t)
     (hy . t)
     (ruby . t)
     (ledger . t)))
  :bind ((:calendar-mode-map
	  ("c-c c" . org-capture-from-calendar)))
  :init
  ;; org-calendar
  ;; (with-eval-after-load 'calendar
  ;;     (define-key calendar-mode-map (kbd "c-c c") 'org-capture-from-calendar))
  )

;; org-journal
(leaf org-journal
  :after org
  :custom
  ((org-journal-time-format . "")
   (org-journal-time-prefix . "")
   `(org-journal-dir . ,(concat org-directory (format-time-string "/diary/%y")))
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

;; deft
;; for search roam files.
(leaf deft
  :after org-roam-mode
  :custom
  ((deft-extensions . '("txt" "tex" "org"))
   `(deft-directory . ,(expand-file-name "roam" org-directory))))

(leaf org-roam-ui)

;; org-bullets
(leaf org-bullets
  :after org
  ;; :init
  ;; (org-bullets-mode 1)
  )

;; org-modern
(leaf org-modern
  :after
  :init
  (with-eval-after-load 'org (global-org-modern-mode)))

(leaf org-modern-indent)

;; org-babel
(leaf ob-hy)

(leaf org-nix-shell)

;; magit
(leaf magit
  :custom
  ((transient-default-level . 5))
  :bind ((:global-map
	  ("c-x g" . magit-status))
	 (:magit-mode-map
	  ("/" . isearch-forward))))

;; forge
(leaf forge
  :after magit)

;; skk
(leaf ddskk
  :custom ((default-input-method . "japanease-skk")
	   (skk-auto-insert-paren . t)
	   (skk-comp-mode . t)
	   (skk-delete-implies-kakutei . nil))
  :config
  (skk-latin-mode 1)
  (global-set-key (kbd "c-x c-j") 'skk-mode)
  (global-set-key (kbd "<henkan>") 'skk-kakutei)
  (global-set-key (kbd "<muhenkan>") 'skk-latin-mode))

(leaf ddskk-posframe
  :global-minor-mode t)

;; common lisp
(leaf slime
  :config
  (defvar inferior-lisp-program "sbcl"))

(leaf sly
  :config)
  ;; (defvar inferior-lisp-program "sbcl")

(leaf sly-asdf)

;; clojure
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
  "a linter for prose."
  :command ("textlint" "--format" "unix" source-inplace)
  :error-patterns
  ((warning line-start (file-name) ":" line ":" column ": "
      (id (one-or-more (not (any " "))))
      (message (one-or-more not-newline)
        (zero-or-more "\n" (any " ") (one-or-more not-newline)))
      line-end))
  :modes (text-mode markdown-mode gfm-mode org-mode web-mode))

;; copilot
(leaf copilot
  :bind ((:copilot-completion-map
	  ("tab" . copilot-accept-completion)))
  :config
  (add-to-list 'copilot-major-mode-alist '("enh-ruby" . "ruby"))
  (add-to-list 'copilot-major-mode-alist '("typescript-ts-mode" . "typescript")))

;; lsp
(leaf lsp-bridge
  :require t
  :custom
  ((acm-enable-capf . t)
   (acm-frame-background-dark-color . "#313244"))
  :config
  (setq lsp-bridge-get-single-lang-server-by-project
	(lambda (project-path file-path)
	  (message project-path)
	  (when (or (expand-file-name "package.json" project-path))
	    "typescript-language-server")
	  "deno"))
  :init
  (global-lsp-bridge-mode))



;; lso-mode
;; (leaf lsp-mode
;;   :require t
;;   :custom
;;   ((lsp-completion-provider . :none))
;;   :config
;;   (setenv "lsp_use_plists" "true")

;;   (define-key evil-normal-state-map (kbd "k") 'lsp-ui-doc-glance)

;;   (add-to-list 'lsp-language-id-configuration
;; 	       '(nix-mode . "nil")
;; 	       '(python-mode . "python"))

;;   (defun corfu-lsp-setup ()
;;     (setq completion-at-point-functions '(lsp-completion-at-point))
;;     (setq-local completion-styles '(orderless)
;; 		completion-category-defaults nil))

;;   (add-hook 'lsp-mode-hook #'corfu-lsp-setup)
;;   (add-hook 'prog-mode-hook #'lsp-deferred))

;; ;; lsp booster
;; (defun lsp-booster--advice-json-parse (old-fn &rest args)
;;   "try to parse bytecode instead of json."
;;   (or
;;    (when (equal (following-char) ?#)
;;      (let ((bytecode (read (current-buffer))))
;;        (when (byte-code-function-p bytecode)
;;          (funcall bytecode))))
;;    (apply old-fn args)))

;; (advice-add (if (progn (require 'json)
;;                        (fboundp 'json-parse-buffer))
;;                 'json-parse-buffer
;;               'json-read)
;;             :around
;;             #'lsp-booster--advice-json-parse)

;; (defun lsp-booster--advice-final-command (old-fn cmd &optional test?)
;;   "prepend emacs-lsp-booster command to lsp cmd."
;;   (let ((orig-result (funcall old-fn cmd test?)))
;;     (if (and (not test?)                             ;; for check lsp-server-present?
;;              (not (file-remote-p default-directory)) ;; see lsp-resolve-final-command, it would add extra shell wrapper
;;              lsp-use-plists
;;              (not (functionp 'json-rpc-connection))  ;; native json-rpc
;;              (executable-find "emacs-lsp-booster"))
;;         (progn
;;           (when-let ((command-from-exec-path (executable-find (car orig-result))))  ;; resolve command from exec-path (in case not found in $path)
;;             (setcar orig-result command-from-exec-path))
;;           (message "using emacs-lsp-booster for %s!" orig-result)
;;           (cons "emacs-lsp-booster" orig-result))
;;       orig-result)))

;; (advice-add 'lsp-resolve-final-command :around #'lsp-booster--advice-final-command)

;; eglot
;; (defun deno-project-p ()
;;   "predicate for determining if the open project is a deno one."
;;   (let ((p-root (nth 2 (project-current))))
;;     (or (file-exists-p (expand-file-name "deno.json" default-directory))
;; 	(file-exists-p (expand-file-name "deno.jsonc" default-directory)))))

;; (defun node-project-p ()
;;   "predicate for determining if the open project is a deno one."
;;   (let ((p-root (nth 2 (project-current))))
;;     (file-exists-p (expand-file-name "package.json" default-directory))))

;; (defun es-server-program (_)
;;   "decide which server to use for ecma script based on project characteristics."
;;   (cond ((deno-project-p) '("deno" "lsp" :initializationoptions (:enable t :lint t)))
;;         ((node-project-p) '("typescript-language-server" "--stdio"))
;;         (t nil)))

;; (leaf eglot
;;   :hook
;;   (c++-mode . eglot-ensure)
;;   (sh-mode . eglot-ensure)
;;   (python-mode . eglot-ensure)
;;   (html-mode . eglot-ensure)
;;   (cmake-mode . eglot-ensure)
;;   (bitbake-mode . eglot-ensure)
;;   (typescript-ts-mode . eglot-ensure)
;;   :config
;;   ;; (add-to-list 'eglot-server-programs '((bitbake-mode) "bitbake-language-server"))
;;   (add-to-list 'eglot-server-programs '((js-mode typescript-mode) . es-server-program))
;;   (add-to-list 'eglot-server-programs '(gleam-ts-mode . ("lspx" "--lsp" "gleam lsp")))
;;   :bind (("m-t" . xref-find-definitions)
;; 	 ("m-r" . xref-find-references)
;; 	 ("c-t" . xref-go-back)))

;; (leaf eglot-booster
;;   :after eglot
;;   :config (eglot-booster-mode))

;; auto formatting
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
 
;; lua support
(leaf lua-mode)

;; completion
(leaf corfu
  :custom
  ((corfu-cycle . t)
  (corfu-auto . t)
  (corfu-auto-prefix . 1))
  :init
  (global-corfu-mode))


;; cursor moation
(leaf avy
  :config
  (define-key evil-normal-state-map (kbd "spc k") #'avy-goto-line))

;; completion soruce
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

;; hydra
(leaf hydra)
(leaf hydra-posframe
  ;; :require t
  ;; :vc (:url "https://github.com/ladicle/hydra-posframe")

  :init
  ;; for hydra
  (define-key evil-normal-state-map (kbd "spc w") #'manage-window-hydra/body)

  :hook
  (add-hook 'after-init-hook 'hydra-posframe-mode))

(leaf major-mode-hydra)

;; for nix
(pretty-hydra-define nix-flake-hydra
  (:separator "-" :title "nix flake" :forigen-key warn :quit-key "q" :exit t)
  ("build"
   (("b" nix-flake-build-default "build"))

   "update"
   (("u" nix-flake-update "update"))))

;; for manage window
(pretty-hydra-define manage-window-hydra
  (:separator "-" :title "manage window" :forigen-key warn :quit-key "q" :exit t)
  ("1"
   (("a" delete-other-windows "delte other windwos"))

   "2"
   (("s" split-window-below "horizontal split"))

   "3"
   (("d" split-window-right "vertical split"))

   "0"
   (("f" delete-window "delete window"))))

(pretty-hydra-define org-hydra
  (:separator "-" :title "nix flake" :forigen-key warn :quit-key "q" :exit t)
  ("roam"
   (("a" org-roam-node-find "roam"))

   "capture"
   (("s" org-capture "capture"))))
    

;; (pretty-hydra-define org-roam-hydra
;;   (:separator "-" :title "org-roam" :forigen-key warn :quit-key "q" :exit t)
;;   ("find"
;;    (("a" 'org-roam-node-find "find node"))

;;    ""
;;    (("s" 'org-roam- ""))

;;    ""
;;    (("d"  ""))

;;    ""
;;    (("f"  ""))
;;     ))

;; transient dispatcher
(leaf transient-dwim
  :bind ("c-=" . transient-dwim-dispatch))

;; tree filer
(leaf neotree
  :custom
  (neo-smart-open . t)
  (projectile-switch-project-action . 'neotree-projectile-action)
  :config
  (progn
    (evil-define-key 'normal neotree-mode-map (kbd "q") 'neotree-hide)
    (evil-define-key 'normal neotree-mode-map (kbd "l") 'neotree-enter)
    (evil-define-key 'normal neotree-mode-map (kbd "ret") 'neotree-enter)
    (evil-define-key 'normal neotree-mode-map (kbd "h") 'neotree-enter)
    (evil-define-key 'normal neotree-mode-map (kbd "g") 'neotree-refresh)
    (evil-define-key 'normal neotree-mode-map (kbd "j") 'neotree-next-line)
    (evil-define-key 'normal neotree-mode-map (kbd "k") 'neotree-previous-line)
    (evil-define-key 'normal neotree-mode-map (kbd "a") 'neotree-stretch-toggle)
    (evil-define-key 'normal neotree-mode-map (kbd "h") 'neotree-hidden-file-toggle)
    (evil-define-key 'normal neotree-mode-map (kbd "n") 'neotree-create-node)
    (evil-define-key 'normal neotree-mode-map (kbd "k") 'neotree-create-node)
    (evil-define-key 'normal neotree-mode-map (kbd "d") 'neotree-delete-node)
    (evil-define-key 'normal neotree-mode-map (kbd "m") 'neotree-rename-node))
  
  ;; for neotree
  (define-key evil-normal-state-map (kbd "spc f") #'neotree-toggle))
  

;; translate
(leaf google-translate
  :require t
  :custom
  (google-translate-translation-directions-alist . '(("en" . "ja")
                                                     ("ja" . "en"))))
;; wakatime
(leaf wakatime-mode
  :init
  (global-wakatime-mode))

;; typst

;; preview
(leaf typst-preview
  ;; :vc (:url "https://github.com/havarddj/typst-preview.el")
  ;; :require t
  :config
  (setq typst-preview-browser "firefox"))

;; ruby support
(leaf inf-ruby)

(leaf enh-ruby-mode)

;; python support
(add-hook 'python-ts-mode-hook (lambda ()
				 (require 'python-mode)))

;; language supports

;; dotnet
(leaf dotnet
  :after csharp-mode)

;; c#
(leaf csharp-mode)

;; nix support
(leaf nix-mode
  :hook
  (nix-ts-mode))

;; scala suppport
(leaf scala-mode
  :interpreter ("scala" . scala-mode))


(leaf sbt-mode
  :commands sbt-start sbt-command
  :config
  (substitute-key-definition
   'minibuffer-complete-word
   'self-insert-command
   minibuffer-local-completion-map)

   (setq sbt:program-options '("-dsbt.supershell=false")))

;; astro support
(leaf astro-ts-mode)

;; elixir support
(leaf inf-elixir)
(leaf mix)

(leaf elixir-ts-mode
  :hook ((elixir-ts-mode . mix-minor-mode)))

;; kdl supports
(leaf kdl-ts-mode)

;; gleam support
(leaf gleam-ts-mode
  :require t
  :hook gleam-on-save-mode)

;; markdown suppot
(leaf markdown-mode
  :hook
  (add-to-list 'completion-at-point-functions #'cape-emoji))

;; projectile
(defun update-projectlist ()
  (interactive)
  (setq projectile-known-projects
         (mapcar
          (lambda (x) (abbreviate-file-name x))
          (split-string (shell-command-to-string "ghq list --full-path")))))

(leaf projectile 
  :config
  (define-key evil-normal-state-map (kbd "m-g") #'projectile-switch-project)
  (define-key evil-normal-state-map (kbd "c-o") #'projectile-find-file)
  :init
  (when (executable-find "ghq")
   (update-projectlist)))

;; migemo
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

;; nyan-mode
(leaf nyan-mode
  :init
  (progn (nyan-mode)
   (nyan-start-animation)))

;; snippets
(leaf tempel
  :require t
  :bind ((:evil-insert-state-map
	  ("m-a" . tempel-done)))
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

;; http request
(leaf request)
(leaf plz)

(autoload 'newsticker-start "newsticker" "start newsticker" t)
(autoload 'newsticker-show-news "newsticker" "goto newsticker buffer" t)

(setq newsticker-url-list
      '(("gleam weekly" "https://gleamweekly.com/atom.xml")
        ("zenn gleam" "https://zenn.dev/topics/gleam/feed")
	("gleam releases" "https://github.com/gleam-lang/gleam/releases.atom")
	("zenn trend" "https://zenn.dev/feed")
	("zenn emacs" "https://zenn.dev/topics/emacs/feed")
        ("zenn ts" "https://zenn.dev/topics/typescript/feed")
        ("zenn cl" "https://zenn.dev/topics/commonlisp/feed")
        ("zenn deno" "https://zenn.dev/topics/deno/feed")
        ("zenn bun" "https://zenn.dev/topics/bun/feed")
        ("zenn rust" "https://zenn.dev/topics/rust/feed")
        ("zenn vim" "https://zenn.dev/topics/vim/feed")
        ("zenn neovim" "https://zenn.dev/topics/neovim/feed")
        ("zenn scheme" "https://zenn.dev/topics/scheme/feed")
        ("zenn hono" "https://zenn.dev/topics/hono/feed")
        ("zenn react" "https://zenn.dev/topics/react/feed")
        ("zenn gcp" "https://zenn.dev/topics/googlecloud/feed")
        ("zenn aws" "https://zenn.dev/topics/aws/feed")
        ("techfeed" "https://techfeed.io/feeds/categories/all")
	("hacker news" "https://hnrss.org/frontpage")
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
	  ("c-a" . grugru))
	 (:evil-normal-state-map
	  ("c-x" . grugru-backward)))
  :config
  ;; ref: https://github.com/rocktakey/grugru/issues/44
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

;; (leaf folding-mode :require t)

(leaf rg
  :require t)

(leaf open-junk-file
  :require t
  :custom
  (open-junk-file-format . "/tmp/junk/%y_%m_%d_%h%m%s.")
  :bind (("c-x j" . open-junk-file)))

(leaf fold-this)

(leaf alert
  :config
  (setq alert-default-style 'libnotify))

(leaf dashboard
  :config
  (setq dashboard-startup-banner (expand-file-name "~/pictures/.emacs-logos/gnu_color_resize.png"))
  (setq dashboard-startup-banner 'logo))

(leaf aas
  ;; :hook (text-mode . aas-activate-for-major-mode)
  ;; :init
  ;; (aas-set-snippets 'global)
  ;; (aas-set-snippets 'markdown-mode)
  ;; (aas-set-snippets 'prog-mode)
  )

(leaf smartparens
  :config
  (smartparens-global-mode t))

(leaf vterm)

(leaf vterm-toggle
  :after evil
  :bind (("c-<return>" . (lambda ()
			   (interactive)
			   (vterm-toggle-insert-cd)
			   (vterm-toggle-insert-cd)))))

(leaf multi-vterm
  :config
  (setq multi-vterm-dedicated-window-height 50))

;; ai
 add-hook 'server-after-make-frame-hook
          (lambda ()
            (setenv "gemini_api_key" (get-secret "gemini.google.com")
            (setenv "openrouter_api_key" (get-secret "openrouter.ai"))
	    (setq gemini-apikey (get-secret "gemini.google.com"))))

(leaf gptel
  :config
  (setq
   ;; gptel-model 'starcoder2
   ;; gptel-backend (gptel-make-ollama "ollama"
   ;;                :host "localhost:11434"
   ;;                :stream t
   ;;                :models '(starcoder2)))

   gptel-model 'gemini-2.5-flash
   gptel-backend (gptel-make-gemini "gemini"
		   :key gemini-apikey
		   :stream t)))

;; ai codeing
(leaf aider
  :require t
  :custom
  (;; (aider-args . '("--watch-files" "--model" "gemini/gemini-2.0-flash"))
   (aider-args . '("--watch-files" "--model" "openrouter/anthropic/claude-3.5-sonnet"))
   ))

(leaf aidermacs
  :require t
  :config
  (setq aidermacs-watch-files t)
  :custom
  (;; (aidermacs-default-model . "gemini/gemini-2.0-flash")
   (aidermacs-default-model . "gemini/gemini-2.5-pro-preview-03-25")
   (aidermacs-watch-files . t)))
;; (aidermacs-default-model . "gemini/gemini-2.5-flash-preview-04-17")


(leaf mcp)

(leaf minimap
  :require t
  :custom ((minimap-window-location . 'right)
	   (minimap-minimum-width . 20)
	   (minimap-major-modes . '(prog-mode
				    markdown-mode
				    html-mode
				    fundamental-mode)))
  :bind ("c-x m" . minimap-mode)
  :config
  (minimap-mode 1))

(leaf rainbow-delimiters
  :hook
  (prog-mode-hook . rainbow-delimiters-mode))

(leaf ox-zenn
  :after org
  :require t)

(leaf verb)

(leaf quickrun)

;; ================ my extentions ================

(defun get-secret (host)
  "wrapper functino for auth-info"
  (require 'ht) 
  (let* ((found (cl-first (auth-source-search :host host
					      :user "coma")))
	 (credentials (when found
			(eval `(ht ,@(--map `(,it ,(plist-get found it))
                                            '(:user :secret :save-function))))))
	 (secret (when credentials
                   (ht-get credentials :secret))))

    (if (not secret)
	(progn (message (format "does not found %s credential." host))
	       "")
      (if (functionp secret)
          (funcall secret)
	secret))))

;; (defun nyan-region ()
;;   "選択範囲をにゃーんで置換する"
;;   (interactive)
;;   (when (use-region-p)
;;     (let* ((beg (region-beginning))
;;            (end (region-end)))
;;      (len (- end beg)
;;       (delete-region beg end)
;;       (cond ((= len 1) (insert "にゃ")))
;;       ((= len 2) (insert "にゃん"))
;;       (t (insert (format "にゃ%sん" (make-string (- len 3) ?ー))))))))

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

  (let* ((query (read-from-minibuffer "query? > ")))
   (url (concat "https://www.google.com/search?client=firefox-b-d&q=" (url-hexify-string query))
  
    (shell-command (concat "open " "'" url "'")))))

(defun home-manager ()
  (interactive)
  (start-process "home-manager-process"
     "*home-manager*"
     "home-manager"
     "switch"
     "--flake"
     ".#home"
     "-b"
     "backup"))

    ;; (set-process-sentinel proc
    ;;                           (lambda (process event)
    ;;                             (when (string= event "finished\n"))))

(defun all (pred lst)
  "returns t if all elements of the list satisfy the predicate."
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
  (let ((beg (save-excursion (skip-chars-backward "a-za-z") (point)))
        (end (point))
        (candidates gitmoji--codes))
    (list beg end candidates :exclusive 'no)))

;; collect gitmoji when startup
;; (add-hook 'emacs-startup-hook 'setup-gitmoji)
;; enable at git-commit-mode

;; display character count in modeline
(defun update-buffer-char-count ()
  (interactive)
  (format " [%d] " (buffer-size)))

(defun mode-line-time ()
  ;; update every second
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

;; for diary
(setq blog-repo "/home/coma/.ghq/github.com/comamoca/blog/")

(defun latest-diary ()
  "open latest diary. this function call in `src/blog/` directory at blog repository."
  (interactive)
  (let* ((date (format-time-string "%y-%m-%d"))
         (file-name (format "%s-diary.md" date))
         (path (concat (expand-file-name "src/blog/" blog-repo) file-name)))
    (find-file path)
    (if (= (buffer-size) 0)
	(tempel-insert 'diary))))

(defun new-blog-article ()
  "open latest diary. this function call in `src/blog/` directory at blog repository."
  (interactive)
  (let* ((date (format-time-string "%y-%m-%d"))
         (slug (read-string "slug > "))
         (file-name (format "%s-%s.md" date slug))
         (path (concat (expand-file-name "src/blog/" blog-repo) file-name)))
    ;; (projectile-switch-project-by-name "blog")
    (find-file path)))

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
	 (mdfiles (cl-remove-if-not (lambda (file))))
	 (articles (cl-remove-if (lambda (file)))
		   (string-match "-diary.md$" file
				 files))
	 (selected (completing-read "blog " articles)))
    (find-file (expand-file-name selected src-dir)))) 

(defun org-paste-image ()
  (interactive)
  (setq filename (concat
                  (expand-file-name (format-time-string "%y-%m-%d-%h%m%s")
                   "~/.ghq/github.com/comamoca/org/imgs") ".png"))
  (shell-command (concat  "wl-paste -t image/png > " filename))
  (insert (concat "[[" filename "]]"))
  (org-display-inline-images))

(defun blog-paste-image ()
  (interactive)
  (setq fullpath (concat
                  (expand-file-name (format-time-string "%y-%m-%d-%h%m%s")
				    "~/.ghq/github.com/comamoca/blog/src/images") ".png"))
  (shell-command (concat  "wl-paste -t image/png > " fullpath))
  (insert (concat "![](/images/" (file-name-nondirectory fullpath) ")"))
  (org-display-inline-images))


;; gauche
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
  (let* ((node-items (mapcar (lambda (node)))
             (cons (org-roam-node-title node) node)) (org-roam-node-list))
   (select-node-title (consult--read)
        (mapcar #'car node-items))
   (select-node (cdr (assoc select-node-title node-items))

    (find-file (org-roam-node-file select-node)))))

;; pinentry emacs
(defun pinentry-emacs (desc prompt ok error)
  (let ((str (read-passwd (concat (replace-regexp-in-string "%22" "\"" (replace-regexp-in-string "%0a" "\n" desc)) prompt ": "))))
    str))

;; initel function that behaves like `:e $myvimrc`
(defun initel ()
  (interactive)
  (find-file user-init-file))

;; ================ my configuratons ================

;; ediff
(setq ediff-window-setup-function 'ediff-setup-windows-plain)

;; font
(add-to-list 'default-frame-alist
                       '(font . "udev gothic nf-14"))

;; for auth-info
(setq auth-sources '("~/.emacs.d/.authinfo.gpg"))
(setq create-lockfiles nil)

;; for lsp-mode
(setq gc-cons-threshold 100000000)
(setq read-process-output-max (* 1024 1024))

;; key mapping
(define-key global-map (kbd "c-x s") 'blackening-region)
(define-key global-map (kbd "c-;") 'comment-dwim)

;; minibuffe
(define-key minibuffer-local-map (kbd "c-h") 'delete-char)
(define-key minibuffer-local-ns-map (kbd "c-h") 'delete-char)
(define-key minibuffer-local-completion-map (kbd "c-h") 'delete-char)
(define-key minibuffer-local-must-match-map (kbd "c-h") 'delete-char)
(define-key minibuffer-local-filename-completion-map (kbd "c-h") 'delete-char)

;; enable debug
(setq debug-on-error nil)

;; custom modeline
(mode-line-format-update)

;; when org-mode
(add-hook 'org-mode
    (lambda ()
      (local-set-key evil-insert-state-map (kbd "c-h") #'org-insert-heading)))

(electric-pair-mode 1)

(global-hl-line-mode t)

(setq vc-follow-symlinks t)
(setq browse-url-generic-program "firefox")
(setq ring-bell-function 'ignore)

(setq display-warning-minimum-level :error)

;; disable to create backupfile
(setq make-backup-files nil)

;; disable to auto save
(setq auto-save-default nil)

;; copy & paste with wl-clipboard
;; ref: https://gist.github.com/yorickvp/6132f237fbc289a45c808d8d75e0e1fb
(setenv "wayland_display" "wayland-1")

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
  :bind (("c-c e" . macrostep-expand)))

;; (provide 'init)
(put 'narrow-to-region 'disabled nil)
(custom-set-variables
 ;; custom-set-variables was added by custom.
 ;; if you edit it by hand, you could mess it up, so be careful.
 ;; your init file should contain only one such instance.
 ;; if there is more than one, they won't work right.
 '(skk-jisyo-edit-user-accepts-editing t))
(custom-set-faces)
 ;; custom-set-faces was added by custom.
 ;; if you edit it by hand, you could mess it up, so be careful.
 ;; your init file should contain only one such instance.
 ;; if there is more than one, they won't work right.
 

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

;; theme
(leaf catppuccin-theme 
  :preface
  :config
  (load-theme 'catppuccin t))

;; minibuffer ui
(leaf vertico
  :require orderless
  :config
  (defvar vertico-count 10)
  ;; completion style config
  (setq completion-styles '(orderless basic)
	completion-category-overrides '((file (styles basic partial-completion))))
  :init 
  (vertico-mode))

;; completion styles
(leaf orderless)

(leaf hotfuzz)

;; completing read functions
(leaf consult
  :require t
  :after evil
  :bind ((:evil-normal-state-map
	  ("c-l" . consult-line)
	  ("c-i" . consult-buffer)))
  :bind* (("c-." . embark-act)))

(leaf consult-dir)

;; embark
(leaf embark
  :after evil
  :bind ((:evil-normal-state-map
	  ("c-." . embark-act)
	  ("c--" . embark-export))
	 (:evil-insert-state-map
	  ("c-." . embark-act))))

;; affe
(leaf affe)

;; for consult
(leaf embark-consult
  :bind ((:minibuffer-mode-map
	  ("m-." . embark-dwin)
	  ("c-." . embark-act))))

;; vim keybind
(leaf evil
  :require t
  :bind ((:evil-normal-state-map
	  ("c-k" . evil-scroll-up)
	  ("c-j" . evil-scroll-down))
	 (:evil-insert-state-map
	  ;; ("c-j" . newline-and-indent)
	  ("c-h" . backward-char)))
 
  :config
  (evil-mode 1))

;; structured editing 
(leaf puni
  :config
  (global-set-key (kbd "c--") 'puni-expand-region)
  :bind ((:evil-insert-state-map
	  ("s" . nil)
	  ;; ("sd" . puni-splice)
	  ("c-i" . puni-mark-sexp-at-point)
	  ("c-p" . puni-slurp-forward)
	  ("c-n" . puni-barf-forward)))
  :init
  (puni-global-mode))

;; indent guides
(leaf highlight-indent-guides)

;; treesitter
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
  (add-to-list 'auto-mode-alist '("dockerfile" . dockerfile-ts-mode)))

(leaf treesit-auto
  :require t
  :custom
  ((treesit-auto-install . t)
   (treesit-extra-load-path . `(,(expand-file-name "~/.cache/dpp/_generated/nvim-treesitter/parser"))))
  :config  
  (global-treesit-auto-mode)
  ;; (treesit-auto-install 'prompt)
  ;; (treesit-auto-add-to-auto-mode-alist 'all)
  )

;; for envrc
(leaf envrc)

;; calendar 
(leaf calendar)

;; org-mode
(leaf org
  :after calendar-mode
  :custom
  ((org-todo-keywords .
		      '((sequence "todo(t)" "pending(p)" "|" "done(d)" "canceled(c)")))
   (org-default-notes-file . "notes.org")
   `(org-directory . ,(expand-file-name "~/.ghq/github.com/comamoca/org"))
   `(diary-file-path . ,(format-time-string "diary/%y/%m-%d.org"))
   `(memo-file-path . ,(format-time-string "memo/%y/%m/%d.org"))
   `(diary-path . ,(concat org-directory "/diary"))
   (org-publish-use-timestamps-flag . nil)

   ;; org-capture
   (org-capture-templates .
			  '(("d" "diary" plain (file diary-file-path)
			     "** 今日やったこと\n\n** 明日以降やりたいこと")
			    ("m" "memo" plain (file memo-file-path) "")))

   (org-publish-project-alist .
			      '(("diary"
				 :base-directory "~/.ghq/github.com/comamoca/org/diary"
				 :base-extension "org"  
				 :recursive t
				 :publishing-directory  "~/.ghq/github.com/comamoca/org/dist"
				 :publishing-function org-html-publish-to-html
				 :include ("index.org")
				 :exclude ())
     
				("note"
				 :base-directory "~/.ghq/github.com/comamoca/org/note"
				 :base-extension "org"  
				 :recursive t
				 :publishing-directory  "~/.ghq/github.com/comamoca/org/note/dist"
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
  (set-language-environment "japanese")
  (prefer-coding-system 'utf-8)
  (set-default 'buffer-file-coding-system 'utf-8)

  (org-babel-do-load-languages
   'org-babel-load-languages
   '((c . t)
     (shell . t)
     (python . t)
     (clojure . t)
     (hy . t)
     (ruby . t)
     (ledger . t)))
  :bind ((:calendar-mode-map
	  ("c-c c" . org-capture-from-calendar)))
  :init
  ;; org-calendar
  ;; (with-eval-after-load 'calendar
  ;;     (define-key calendar-mode-map (kbd "c-c c") 'org-capture-from-calendar))
  )

;; org-journal
(leaf org-journal
  :after org
  :custom
  ((org-journal-time-format . "")
   (org-journal-time-prefix . "")
   `(org-journal-dir . ,(concat org-directory (format-time-string "/diary/%y")))
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

;; deft
;; for search roam files.
(leaf deft
  :after org-roam-mode
  :custom
  ((deft-extensions . '("txt" "tex" "org"))
   `(deft-directory . ,(expand-file-name "roam" org-directory))))

(leaf org-roam-ui)

;; org-bullets
(leaf org-bullets
  :after org
  ;; :init
  ;; (org-bullets-mode 1)
  )

;; org-modern
(leaf org-modern
  :after
  :init
  (with-eval-after-load 'org (global-org-modern-mode)))

(leaf org-modern-indent)

;; org-babel
(leaf ob-hy)

(leaf org-nix-shell)

;; magit
(leaf magit
  :custom
  ((transient-default-level . 5))
  :bind ((:global-map
	  ("c-x g" . magit-status))
	 (:magit-mode-map
	  ("/" . isearch-forward))))

;; forge
(leaf forge
  :after magit)

;; skk
(leaf ddskk
  :custom ((default-input-method . "japanease-skk")
	   (skk-auto-insert-paren . t)
	   (skk-comp-mode . t)
	   (skk-delete-implies-kakutei . nil))
  :config
  (skk-latin-mode 1)
  (global-set-key (kbd "c-x c-j") 'skk-mode)
  (global-set-key (kbd "<henkan>") 'skk-kakutei)
  (global-set-key (kbd "<muhenkan>") 'skk-latin-mode))

(leaf ddskk-posframe
  :global-minor-mode t)

;; common lisp
(leaf slime
  :config
  (defvar inferior-lisp-program "sbcl"))

(leaf sly
  :config)
  ;; (defvar inferior-lisp-program "sbcl")

(leaf sly-asdf)

;; clojure
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
  "a linter for prose."
  :command ("textlint" "--format" "unix" source-inplace)
  :error-patterns
  ((warning line-start (file-name) ":" line ":" column ": "
      (id (one-or-more (not (any " "))))
      (message (one-or-more not-newline)
        (zero-or-more "\n" (any " ") (one-or-more not-newline)))
      line-end))
  :modes (text-mode markdown-mode gfm-mode org-mode web-mode))

;; copilot
(leaf copilot
  :bind ((:copilot-completion-map
	  ("tab" . copilot-accept-completion)))
  :config
  (add-to-list 'copilot-major-mode-alist '("enh-ruby" . "ruby"))
  (add-to-list 'copilot-major-mode-alist '("typescript-ts-mode" . "typescript")))

;; lsp
(leaf lsp-bridge
  :require t
  :custom
  ((acm-enable-capf . t)
   (acm-frame-background-dark-color . "#313244"))
  :config
  (setq lsp-bridge-get-single-lang-server-by-project
	(lambda (project-path file-path)
	  (message project-path)
	  (when (or (expand-file-name "package.json" project-path))
	    "typescript-language-server")
	  "deno"))
  :init
  (global-lsp-bridge-mode))



;; lso-mode
;; (leaf lsp-mode
;;   :require t
;;   :custom
;;   ((lsp-completion-provider . :none))
;;   :config
;;   (setenv "lsp_use_plists" "true")

;;   (define-key evil-normal-state-map (kbd "k") 'lsp-ui-doc-glance)

;;   (add-to-list 'lsp-language-id-configuration
;; 	       '(nix-mode . "nil")
;; 	       '(python-mode . "python"))

;;   (defun corfu-lsp-setup ()
;;     (setq completion-at-point-functions '(lsp-completion-at-point))
;;     (setq-local completion-styles '(orderless)
;; 		completion-category-defaults nil))

;;   (add-hook 'lsp-mode-hook #'corfu-lsp-setup)
;;   (add-hook 'prog-mode-hook #'lsp-deferred))

;; ;; lsp booster
;; (defun lsp-booster--advice-json-parse (old-fn &rest args)
;;   "try to parse bytecode instead of json."
;;   (or
;;    (when (equal (following-char) ?#)
;;      (let ((bytecode (read (current-buffer))))
;;        (when (byte-code-function-p bytecode)
;;          (funcall bytecode))))
;;    (apply old-fn args)))

;; (advice-add (if (progn (require 'json)
;;                        (fboundp 'json-parse-buffer))
;;                 'json-parse-buffer
;;               'json-read)
;;             :around
;;             #'lsp-booster--advice-json-parse)

;; (defun lsp-booster--advice-final-command (old-fn cmd &optional test?)
;;   "prepend emacs-lsp-booster command to lsp cmd."
;;   (let ((orig-result (funcall old-fn cmd test?)))
;;     (if (and (not test?)                             ;; for check lsp-server-present?
;;              (not (file-remote-p default-directory)) ;; see lsp-resolve-final-command, it would add extra shell wrapper
;;              lsp-use-plists
;;              (not (functionp 'json-rpc-connection))  ;; native json-rpc
;;              (executable-find "emacs-lsp-booster"))
;;         (progn
;;           (when-let ((command-from-exec-path (executable-find (car orig-result))))  ;; resolve command from exec-path (in case not found in $path)
;;             (setcar orig-result command-from-exec-path))
;;           (message "using emacs-lsp-booster for %s!" orig-result)
;;           (cons "emacs-lsp-booster" orig-result))
;;       orig-result)))

;; (advice-add 'lsp-resolve-final-command :around #'lsp-booster--advice-final-command)

;; eglot
;; (defun deno-project-p ()
;;   "predicate for determining if the open project is a deno one."
;;   (let ((p-root (nth 2 (project-current))))
;;     (or (file-exists-p (expand-file-name "deno.json" default-directory))
;; 	(file-exists-p (expand-file-name "deno.jsonc" default-directory)))))

;; (defun node-project-p ()
;;   "predicate for determining if the open project is a deno one."
;;   (let ((p-root (nth 2 (project-current))))
;;     (file-exists-p (expand-file-name "package.json" default-directory))))

;; (defun es-server-program (_)
;;   "decide which server to use for ecma script based on project characteristics."
;;   (cond ((deno-project-p) '("deno" "lsp" :initializationoptions (:enable t :lint t)))
;;         ((node-project-p) '("typescript-language-server" "--stdio"))
;;         (t nil)))

;; (leaf eglot
;;   :hook
;;   (c++-mode . eglot-ensure)
;;   (sh-mode . eglot-ensure)
;;   (python-mode . eglot-ensure)
;;   (html-mode . eglot-ensure)
;;   (cmake-mode . eglot-ensure)
;;   (bitbake-mode . eglot-ensure)
;;   (typescript-ts-mode . eglot-ensure)
;;   :config
;;   ;; (add-to-list 'eglot-server-programs '((bitbake-mode) "bitbake-language-server"))
;;   (add-to-list 'eglot-server-programs '((js-mode typescript-mode) . es-server-program))
;;   (add-to-list 'eglot-server-programs '(gleam-ts-mode . ("lspx" "--lsp" "gleam lsp")))
;;   :bind (("m-t" . xref-find-definitions)
;; 	 ("m-r" . xref-find-references)
;; 	 ("c-t" . xref-go-back)))

;; (leaf eglot-booster
;;   :after eglot
;;   :config (eglot-booster-mode))

;; auto formatting
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
 
;; lua support
(leaf lua-mode)

;; completion
(leaf corfu
  :custom
  ((corfu-cycle . t)
  (corfu-auto . t)
  (corfu-auto-prefix . 1))
  :init
  (global-corfu-mode))


;; cursor moation
(leaf avy
  :config
  (define-key evil-normal-state-map (kbd "spc k") #'avy-goto-line))

;; completion soruce
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

;; hydra
(leaf hydra)
(leaf hydra-posframe
  ;; :require t
  ;; :vc (:url "https://github.com/ladicle/hydra-posframe")

  :init
  ;; for hydra
  (define-key evil-normal-state-map (kbd "spc w") #'manage-window-hydra/body)

  :hook
  (add-hook 'after-init-hook 'hydra-posframe-mode))

(leaf major-mode-hydra)

;; for nix
(pretty-hydra-define nix-flake-hydra
  (:separator "-" :title "nix flake" :forigen-key warn :quit-key "q" :exit t)
  ("build"
   (("b" nix-flake-build-default "build"))

   "update"
   (("u" nix-flake-update "update"))))

;; for manage window
(pretty-hydra-define manage-window-hydra
  (:separator "-" :title "manage window" :forigen-key warn :quit-key "q" :exit t)
  ("1"
   (("a" delete-other-windows "delte other windwos"))

   "2"
   (("s" split-window-below "horizontal split"))

   "3"
   (("d" split-window-right "vertical split"))

   "0"
   (("f" delete-window "delete window"))))

(pretty-hydra-define org-hydra
  (:separator "-" :title "nix flake" :forigen-key warn :quit-key "q" :exit t)
  ("roam"
   (("a" org-roam-node-find "roam"))

   "capture"
   (("s" org-capture "capture"))))
    

;; (pretty-hydra-define org-roam-hydra
;;   (:separator "-" :title "org-roam" :forigen-key warn :quit-key "q" :exit t)
;;   ("find"
;;    (("a" 'org-roam-node-find "find node"))

;;    ""
;;    (("s" 'org-roam- ""))

;;    ""
;;    (("d"  ""))

;;    ""
;;    (("f"  ""))
;;     ))

;; transient dispatcher
(leaf transient-dwim
  :bind ("c-=" . transient-dwim-dispatch))

;; tree filer
(leaf neotree
  :custom
  (neo-smart-open . t)
  (projectile-switch-project-action . 'neotree-projectile-action)
  :config
  (progn
    (evil-define-key 'normal neotree-mode-map (kbd "q") 'neotree-hide)
    (evil-define-key 'normal neotree-mode-map (kbd "l") 'neotree-enter)
    (evil-define-key 'normal neotree-mode-map (kbd "ret") 'neotree-enter)
    (evil-define-key 'normal neotree-mode-map (kbd "h") 'neotree-enter)
    (evil-define-key 'normal neotree-mode-map (kbd "g") 'neotree-refresh)
    (evil-define-key 'normal neotree-mode-map (kbd "j") 'neotree-next-line)
    (evil-define-key 'normal neotree-mode-map (kbd "k") 'neotree-previous-line)
    (evil-define-key 'normal neotree-mode-map (kbd "a") 'neotree-stretch-toggle)
    (evil-define-key 'normal neotree-mode-map (kbd "h") 'neotree-hidden-file-toggle)
    (evil-define-key 'normal neotree-mode-map (kbd "n") 'neotree-create-node)
    (evil-define-key 'normal neotree-mode-map (kbd "k") 'neotree-create-node)
    (evil-define-key 'normal neotree-mode-map (kbd "d") 'neotree-delete-node)
    (evil-define-key 'normal neotree-mode-map (kbd "m") 'neotree-rename-node))
  
  ;; for neotree
  (define-key evil-normal-state-map (kbd "spc f") #'neotree-toggle))
  

;; translate
(leaf google-translate
  :require t
  :custom
  (google-translate-translation-directions-alist . '(("en" . "ja")
                                                     ("ja" . "en"))))
;; wakatime
(leaf wakatime-mode
  :init
  (global-wakatime-mode))

;; typst

;; preview
(leaf typst-preview
  ;; :vc (:url "https://github.com/havarddj/typst-preview.el")
  ;; :require t
  :config
  (setq typst-preview-browser "firefox"))

;; ruby support
(leaf inf-ruby)

(leaf enh-ruby-mode)

;; python support
(add-hook 'python-ts-mode-hook (lambda ()
				 (require 'python-mode)))

;; language supports

;; dotnet
(leaf dotnet
  :after csharp-mode)

;; c#
(leaf csharp-mode)

;; nix support
(leaf nix-mode
  :hook
  (nix-ts-mode))

;; scala suppport
(leaf scala-mode
  :interpreter ("scala" . scala-mode))


(leaf sbt-mode
  :commands sbt-start sbt-command
  :config
  (substitute-key-definition
   'minibuffer-complete-word
   'self-insert-command
   minibuffer-local-completion-map)

   (setq sbt:program-options '("-dsbt.supershell=false")))

;; astro support
(leaf astro-ts-mode)

;; elixir support
(leaf inf-elixir)
(leaf mix)

(leaf elixir-ts-mode
  :hook ((elixir-ts-mode . mix-minor-mode)))

;; kdl supports
(leaf kdl-ts-mode)

;; gleam support
(leaf gleam-ts-mode
  :require t
  :hook gleam-on-save-mode)

;; markdown suppot
(leaf markdown-mode
  :hook
  (add-to-list 'completion-at-point-functions #'cape-emoji))

;; projectile
(defun update-projectlist ()
  (interactive)
  (setq projectile-known-projects
         (mapcar
          (lambda (x) (abbreviate-file-name x))
          (split-string (shell-command-to-string "ghq list --full-path")))))

(leaf projectile 
  :config
  (define-key evil-normal-state-map (kbd "m-g") #'projectile-switch-project)
  (define-key evil-normal-state-map (kbd "c-o") #'projectile-find-file)
  :init
  (when (executable-find "ghq")
   (update-projectlist)))

;; migemo
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

;; nyan-mode
(leaf nyan-mode
  :init
  (progn (nyan-mode)
   (nyan-start-animation)))

;; snippets
(leaf tempel
  :require t
  :bind ((:evil-insert-state-map
	  ("m-a" . tempel-done)))
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

;; http request
(leaf request)
(leaf plz)

(autoload 'newsticker-start "newsticker" "start newsticker" t)
(autoload 'newsticker-show-news "newsticker" "goto newsticker buffer" t)

(setq newsticker-url-list
      '(("gleam weekly" "https://gleamweekly.com/atom.xml")
        ("zenn gleam" "https://zenn.dev/topics/gleam/feed")
	("gleam releases" "https://github.com/gleam-lang/gleam/releases.atom")
	("zenn trend" "https://zenn.dev/feed")
	("zenn emacs" "https://zenn.dev/topics/emacs/feed")
        ("zenn ts" "https://zenn.dev/topics/typescript/feed")
        ("zenn cl" "https://zenn.dev/topics/commonlisp/feed")
        ("zenn deno" "https://zenn.dev/topics/deno/feed")
        ("zenn bun" "https://zenn.dev/topics/bun/feed")
        ("zenn rust" "https://zenn.dev/topics/rust/feed")
        ("zenn vim" "https://zenn.dev/topics/vim/feed")
        ("zenn neovim" "https://zenn.dev/topics/neovim/feed")
        ("zenn scheme" "https://zenn.dev/topics/scheme/feed")
        ("zenn hono" "https://zenn.dev/topics/hono/feed")
        ("zenn react" "https://zenn.dev/topics/react/feed")
        ("zenn gcp" "https://zenn.dev/topics/googlecloud/feed")
        ("zenn aws" "https://zenn.dev/topics/aws/feed")
        ("techfeed" "https://techfeed.io/feeds/categories/all")
	("hacker news" "https://hnrss.org/frontpage")
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
	  ("c-a" . grugru))
	 (:evil-normal-state-map
	  ("c-x" . grugru-backward)))
  :config
  ;; ref: https://github.com/rocktakey/grugru/issues/44
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

;; (leaf folding-mode :require t)

(leaf rg
  :require t)

(leaf open-junk-file
  :require t
  :custom
  (open-junk-file-format . "/tmp/junk/%y_%m_%d_%h%m%s.")
  :bind (("c-x j" . open-junk-file)))

(leaf fold-this)

(leaf alert
  :config
  (setq alert-default-style 'libnotify))

(leaf dashboard
  :config
  (setq dashboard-startup-banner (expand-file-name "~/pictures/.emacs-logos/gnu_color_resize.png"))
  (setq dashboard-startup-banner 'logo))

(leaf aas
  ;; :hook (text-mode . aas-activate-for-major-mode)
  ;; :init
  ;; (aas-set-snippets 'global)
  ;; (aas-set-snippets 'markdown-mode)
  ;; (aas-set-snippets 'prog-mode)
  )

(leaf smartparens
  :config
  (smartparens-global-mode t))

(leaf vterm)

(leaf vterm-toggle
  :after evil
  :bind (("c-<return>" . (lambda ()
			   (interactive)
			   (vterm-toggle-insert-cd)
			   (vterm-toggle-insert-cd)))))

(leaf multi-vterm
  :config
  (setq multi-vterm-dedicated-window-height 50))

;; ai
 add-hook 'server-after-make-frame-hook
          (lambda ()
            (setenv "gemini_api_key" (get-secret "gemini.google.com")
            (setenv "openrouter_api_key" (get-secret "openrouter.ai"))
	    (setq gemini-apikey (get-secret "gemini.google.com"))))

(leaf gptel
  :config
  (setq
   ;; gptel-model 'starcoder2
   ;; gptel-backend (gptel-make-ollama "ollama"
   ;;                :host "localhost:11434"
   ;;                :stream t
   ;;                :models '(starcoder2)))

   gptel-model 'gemini-2.5-flash
   gptel-backend (gptel-make-gemini "gemini"
		   :key gemini-apikey
		   :stream t)))

;; ai codeing
(leaf aider
  :require t
  :custom
  (;; (aider-args . '("--watch-files" "--model" "gemini/gemini-2.0-flash"))
   (aider-args . '("--watch-files" "--model" "openrouter/anthropic/claude-3.5-sonnet"))
   ))

(leaf aidermacs
  :require t
  :config
  (setq aidermacs-watch-files t)
  :custom
  (;; (aidermacs-default-model . "gemini/gemini-2.0-flash")
   (aidermacs-default-model . "gemini/gemini-2.5-pro-preview-03-25")
   (aidermacs-watch-files . t)))
;; (aidermacs-default-model . "gemini/gemini-2.5-flash-preview-04-17")


(leaf mcp)

(leaf minimap
  :require t
  :custom ((minimap-window-location . 'right)
	   (minimap-minimum-width . 20)
	   (minimap-major-modes . '(prog-mode
				    markdown-mode
				    html-mode
				    fundamental-mode)))
  :bind ("c-x m" . minimap-mode)
  :config
  (minimap-mode 1))

(leaf rainbow-delimiters
  :hook
  (prog-mode-hook . rainbow-delimiters-mode))

(leaf ox-zenn
  :after org
  :require t)

(leaf verb)

(leaf quickrun)

;; ================ my extentions ================

(defun get-secret (host)
  "wrapper functino for auth-info"
  (require 'ht) 
  (let* ((found (cl-first (auth-source-search :host host
					      :user "coma")))
	 (credentials (when found
			(eval `(ht ,@(--map `(,it ,(plist-get found it))
                                            '(:user :secret :save-function))))))
	 (secret (when credentials
                   (ht-get credentials :secret))))

    (if (not secret)
	(progn (message (format "does not found %s credential." host))
	       "")
      (if (functionp secret)
          (funcall secret)
	secret))))

;; (defun nyan-region ()
;;   "選択範囲をにゃーんで置換する"
;;   (interactive)
;;   (when (use-region-p)
;;     (let* ((beg (region-beginning))
;;            (end (region-end)))
;;      (len (- end beg)
;;       (delete-region beg end)
;;       (cond ((= len 1) (insert "にゃ")))
;;       ((= len 2) (insert "にゃん"))
;;       (t (insert (format "にゃ%sん" (make-string (- len 3) ?ー))))))))

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

  (let* ((query (read-from-minibuffer "query? > ")))
   (url (concat "https://www.google.com/search?client=firefox-b-d&q=" (url-hexify-string query))
  
    (shell-command (concat "open " "'" url "'")))))

(defun home-manager ()
  (interactive)
  (start-process "home-manager-process"
     "*home-manager*"
     "home-manager"
     "switch"
     "--flake"
     ".#home"
     "-b"
     "backup"))

    ;; (set-process-sentinel proc
    ;;                           (lambda (process event)
    ;;                             (when (string= event "finished\n"))))

(defun all (pred lst)
  "returns t if all elements of the list satisfy the predicate."
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
  (let ((beg (save-excursion (skip-chars-backward "a-za-z") (point)))
        (end (point))
        (candidates gitmoji--codes))
    (list beg end candidates :exclusive 'no)))

;; collect gitmoji when startup
;; (add-hook 'emacs-startup-hook 'setup-gitmoji)
;; enable at git-commit-mode

;; display character count in modeline
(defun update-buffer-char-count ()
  (interactive)
  (format " [%d] " (buffer-size)))

(defun mode-line-time ()
  ;; update every second
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

;; for diary
(setq blog-repo "/home/coma/.ghq/github.com/comamoca/blog/")

(defun latest-diary ()
  "open latest diary. this function call in `src/blog/` directory at blog repository."
  (interactive)
  (let* ((date (format-time-string "%y-%m-%d"))
         (file-name (format "%s-diary.md" date))
         (path (concat (expand-file-name "src/blog/" blog-repo) file-name)))
    (find-file path)
    (if (= (buffer-size) 0)
	(tempel-insert 'diary))))

(defun new-blog-article ()
  "open latest diary. this function call in `src/blog/` directory at blog repository."
  (interactive)
  (let* ((date (format-time-string "%y-%m-%d"))
         (slug (read-string "slug > "))
         (file-name (format "%s-%s.md" date slug))
         (path (concat (expand-file-name "src/blog/" blog-repo) file-name)))
    ;; (projectile-switch-project-by-name "blog")
    (find-file path)))

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
	 (mdfiles (cl-remove-if-not (lambda (file))))
	 (articles (cl-remove-if (lambda (file)))
		   (string-match "-diary.md$" file
				 files))
	 (selected (completing-read "blog " articles)))
    (find-file (expand-file-name selected src-dir)))) 

(defun org-paste-image ()
  (interactive)
  (setq filename (concat
                  (expand-file-name (format-time-string "%y-%m-%d-%h%m%s")
                   "~/.ghq/github.com/comamoca/org/imgs") ".png"))
  (shell-command (concat  "wl-paste -t image/png > " filename))
  (insert (concat "[[" filename "]]"))
  (org-display-inline-images))

(defun blog-paste-image ()
  (interactive)
  (setq fullpath (concat
                  (expand-file-name (format-time-string "%y-%m-%d-%h%m%s")
				    "~/.ghq/github.com/comamoca/blog/src/images") ".png"))
  (shell-command (concat  "wl-paste -t image/png > " fullpath))
  (insert (concat "![](/images/" (file-name-nondirectory fullpath) ")"))
  (org-display-inline-images))


;; gauche
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
  (let* ((node-items (mapcar (lambda (node)))
             (cons (org-roam-node-title node) node)) (org-roam-node-list))
   (select-node-title (consult--read)
        (mapcar #'car node-items))
   (select-node (cdr (assoc select-node-title node-items))

    (find-file (org-roam-node-file select-node)))))

;; pinentry emacs
(defun pinentry-emacs (desc prompt ok error)
  (let ((str (read-passwd (concat (replace-regexp-in-string "%22" "\"" (replace-regexp-in-string "%0a" "\n" desc)) prompt ": "))))
    str))

;; initel function that behaves like `:e $myvimrc`
(defun initel ()
  (interactive)
  (find-file user-init-file))

;; ================ my configuratons ================

;; ediff
(setq ediff-window-setup-function 'ediff-setup-windows-plain)

;; font
(add-to-list 'default-frame-alist
                       '(font . "udev gothic nf-14"))

;; for auth-info
(setq auth-sources '("~/.emacs.d/.authinfo.gpg"))
(setq create-lockfiles nil)

;; for lsp-mode
(setq gc-cons-threshold 100000000)
(setq read-process-output-max (* 1024 1024))

;; key mapping
(define-key global-map (kbd "c-x s") 'blackening-region)
(define-key global-map (kbd "c-;") 'comment-dwim)

;; minibuffe
(define-key minibuffer-local-map (kbd "c-h") 'delete-char)
(define-key minibuffer-local-ns-map (kbd "c-h") 'delete-char)
(define-key minibuffer-local-completion-map (kbd "c-h") 'delete-char)
(define-key minibuffer-local-must-match-map (kbd "c-h") 'delete-char)
(define-key minibuffer-local-filename-completion-map (kbd "c-h") 'delete-char)

;; enable debug
(setq debug-on-error nil)

;; custom modeline
(mode-line-format-update)

;; when org-mode
(add-hook 'org-mode
    (lambda ()
      (local-set-key evil-insert-state-map (kbd "c-h") #'org-insert-heading)))

(electric-pair-mode 1)

(global-hl-line-mode t)

(setq vc-follow-symlinks t)
(setq browse-url-generic-program "firefox")
(setq ring-bell-function 'ignore)

(setq display-warning-minimum-level :error)

;; disable to create backupfile
(setq make-backup-files nil)

;; disable to auto save
(setq auto-save-default nil)

;; copy & paste with wl-clipboard
;; ref: https://gist.github.com/yorickvp/6132f237fbc289a45c808d8d75e0e1fb
(setenv "wayland_display" "wayland-1")

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
  :bind (("c-c e" . macrostep-expand)))

;; (provide 'init)
(put 'narrow-to-region 'disabled nil)
(custom-set-variables
 ;; custom-set-variables was added by custom.
 ;; if you edit it by hand, you could mess it up, so be careful.
 ;; your init file should contain only one such instance.
 ;; if there is more than one, they won't work right.
 '(skk-jisyo-edit-user-accepts-editing t))
(custom-set-faces)
 ;; custom-set-faces was added by custom.
 ;; if you edit it by hand, you could mess it up, so be careful.
 ;; your init file should contain only one such instance.
 ;; if there is more than one, they won't work right.
 
 
  :config
  (evil-mode 1))

;; structured editing 
(leaf puni
  :config
  (global-set-key (kbd "c--") 'puni-expand-region)
  :bind ((:evil-insert-state-map
	  ("s" . nil)
	  ;; ("sd" . puni-splice)
	  ("c-i" . puni-mark-sexp-at-point)
	  ("c-p" . puni-slurp-forward)
	  ("c-n" . puni-barf-forward)))
  :init
  (puni-global-mode))

;; indent guides
(leaf highlight-indent-guides)

;; treesitter
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
  (add-to-list 'auto-mode-alist '("dockerfile" . dockerfile-ts-mode)))

(leaf treesit-auto
  :require t
  :custom
  ((treesit-auto-install . t)
   (treesit-extra-load-path . `(,(expand-file-name "~/.cache/dpp/_generated/nvim-treesitter/parser"))))
  :config  
  (global-treesit-auto-mode)
  ;; (treesit-auto-install 'prompt)
  ;; (treesit-auto-add-to-auto-mode-alist 'all)
  )

;; for envrc
(leaf envrc)

;; calendar 
(leaf calendar)

;; org-mode
(leaf org
  :after calendar-mode
  :custom
  ((org-todo-keywords .
		      '((sequence "todo(t)" "pending(p)" "|" "done(d)" "canceled(c)")))
   (org-default-notes-file . "notes.org")
   `(org-directory . ,(expand-file-name "~/.ghq/github.com/comamoca/org"))
   `(diary-file-path . ,(format-time-string "diary/%y/%m-%d.org"))
   `(memo-file-path . ,(format-time-string "memo/%y/%m/%d.org"))
   `(diary-path . ,(concat org-directory "/diary"))
   (org-publish-use-timestamps-flag . nil)

   ;; org-capture
   (org-capture-templates .
			  '(("d" "diary" plain (file diary-file-path)
			     "** 今日やったこと\n\n** 明日以降やりたいこと")
			    ("m" "memo" plain (file memo-file-path) "")))

   (org-publish-project-alist .
			      '(("diary"
				 :base-directory "~/.ghq/github.com/comamoca/org/diary"
				 :base-extension "org"  
				 :recursive t
				 :publishing-directory  "~/.ghq/github.com/comamoca/org/dist"
				 :publishing-function org-html-publish-to-html
				 :include ("index.org")
				 :exclude ())
     
				("note"
				 :base-directory "~/.ghq/github.com/comamoca/org/note"
				 :base-extension "org"  
				 :recursive t
				 :publishing-directory  "~/.ghq/github.com/comamoca/org/note/dist"
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
  (set-language-environment "japanese")
  (prefer-coding-system 'utf-8)
  (set-default 'buffer-file-coding-system 'utf-8)

  (org-babel-do-load-languages
   'org-babel-load-languages
   '((c . t)
     (shell . t)
     (python . t)
     (clojure . t)
     (hy . t)
     (ruby . t)
     (ledger . t)))
  :bind ((:calendar-mode-map
	  ("c-c c" . org-capture-from-calendar)))
  :init
  ;; org-calendar
  ;; (with-eval-after-load 'calendar
  ;;     (define-key calendar-mode-map (kbd "c-c c") 'org-capture-from-calendar))
  )

;; org-journal
(leaf org-journal
  :after org
  :custom
  ((org-journal-time-format . "")
   (org-journal-time-prefix . "")
   `(org-journal-dir . ,(concat org-directory (format-time-string "/diary/%y")))
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

;; deft
;; for search roam files.
(leaf deft
  :after org-roam-mode
  :custom
  ((deft-extensions . '("txt" "tex" "org"))
   `(deft-directory . ,(expand-file-name "roam" org-directory))))

(leaf org-roam-ui)

;; org-bullets
(leaf org-bullets
  :after org
  ;; :init
  ;; (org-bullets-mode 1)
  )

;; org-modern
(leaf org-modern
  :after
  :init
  (with-eval-after-load 'org (global-org-modern-mode)))

(leaf org-modern-indent)

;; org-babel
(leaf ob-hy)

(leaf org-nix-shell)

;; magit
(leaf magit
  :custom
  ((transient-default-level . 5))
  :bind ((:global-map
	  ("c-x g" . magit-status))
	 (:magit-mode-map
	  ("/" . isearch-forward))))

;; forge
(leaf forge
  :after magit)

;; skk
(leaf ddskk
  :custom ((default-input-method . "japanease-skk")
	   (skk-auto-insert-paren . t)
	   (skk-comp-mode . t)
	   (skk-delete-implies-kakutei . nil))
  :config
  (skk-latin-mode 1)
  (global-set-key (kbd "c-x c-j") 'skk-mode)
  (global-set-key (kbd "<henkan>") 'skk-kakutei)
  (global-set-key (kbd "<muhenkan>") 'skk-latin-mode))

(leaf ddskk-posframe
  :global-minor-mode t)

;; common lisp
(leaf slime
  :config
  (defvar inferior-lisp-program "sbcl"))

(leaf sly
  :config)
  ;; (defvar inferior-lisp-program "sbcl")

(leaf sly-asdf)

;; clojure
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
  "a linter for prose."
  :command ("textlint" "--format" "unix" source-inplace)
  :error-patterns
  ((warning line-start (file-name) ":" line ":" column ": "
      (id (one-or-more (not (any " "))))
      (message (one-or-more not-newline)
        (zero-or-more "\n" (any " ") (one-or-more not-newline)))
      line-end))
  :modes (text-mode markdown-mode gfm-mode org-mode web-mode))

;; copilot
(leaf copilot
  :bind ((:copilot-completion-map
	  ("tab" . copilot-accept-completion)))
  :config
  (add-to-list 'copilot-major-mode-alist '("enh-ruby" . "ruby"))
  (add-to-list 'copilot-major-mode-alist '("typescript-ts-mode" . "typescript")))

;; lsp
(leaf lsp-bridge
  :require t
  :custom
  ((acm-enable-capf . t)
   (acm-frame-background-dark-color . "#313244"))
  :config
  (setq lsp-bridge-get-single-lang-server-by-project
	(lambda (project-path file-path)
	  (message project-path)
	  (when (or (expand-file-name "package.json" project-path))
	    "typescript-language-server")
	  "deno"))
  :init
  (global-lsp-bridge-mode))



;; lso-mode
;; (leaf lsp-mode
;;   :require t
;;   :custom
;;   ((lsp-completion-provider . :none))
;;   :config
;;   (setenv "lsp_use_plists" "true")

;;   (define-key evil-normal-state-map (kbd "k") 'lsp-ui-doc-glance)

;;   (add-to-list 'lsp-language-id-configuration
;; 	       '(nix-mode . "nil")
;; 	       '(python-mode . "python"))

;;   (defun corfu-lsp-setup ()
;;     (setq completion-at-point-functions '(lsp-completion-at-point))
;;     (setq-local completion-styles '(orderless)
;; 		completion-category-defaults nil))

;;   (add-hook 'lsp-mode-hook #'corfu-lsp-setup)
;;   (add-hook 'prog-mode-hook #'lsp-deferred))

;; ;; lsp booster
;; (defun lsp-booster--advice-json-parse (old-fn &rest args)
;;   "try to parse bytecode instead of json."
;;   (or
;;    (when (equal (following-char) ?#)
;;      (let ((bytecode (read (current-buffer))))
;;        (when (byte-code-function-p bytecode)
;;          (funcall bytecode))))
;;    (apply old-fn args)))

;; (advice-add (if (progn (require 'json)
;;                        (fboundp 'json-parse-buffer))
;;                 'json-parse-buffer
;;               'json-read)
;;             :around
;;             #'lsp-booster--advice-json-parse)

;; (defun lsp-booster--advice-final-command (old-fn cmd &optional test?)
;;   "prepend emacs-lsp-booster command to lsp cmd."
;;   (let ((orig-result (funcall old-fn cmd test?)))
;;     (if (and (not test?)                             ;; for check lsp-server-present?
;;              (not (file-remote-p default-directory)) ;; see lsp-resolve-final-command, it would add extra shell wrapper
;;              lsp-use-plists
;;              (not (functionp 'json-rpc-connection))  ;; native json-rpc
;;              (executable-find "emacs-lsp-booster"))
;;         (progn
;;           (when-let ((command-from-exec-path (executable-find (car orig-result))))  ;; resolve command from exec-path (in case not found in $path)
;;             (setcar orig-result command-from-exec-path))
;;           (message "using emacs-lsp-booster for %s!" orig-result)
;;           (cons "emacs-lsp-booster" orig-result))
;;       orig-result)))

;; (advice-add 'lsp-resolve-final-command :around #'lsp-booster--advice-final-command)

;; eglot
;; (defun deno-project-p ()
;;   "predicate for determining if the open project is a deno one."
;;   (let ((p-root (nth 2 (project-current))))
;;     (or (file-exists-p (expand-file-name "deno.json" default-directory))
;; 	(file-exists-p (expand-file-name "deno.jsonc" default-directory)))))

;; (defun node-project-p ()
;;   "predicate for determining if the open project is a deno one."
;;   (let ((p-root (nth 2 (project-current))))
;;     (file-exists-p (expand-file-name "package.json" default-directory))))

;; (defun es-server-program (_)
;;   "decide which server to use for ecma script based on project characteristics."
;;   (cond ((deno-project-p) '("deno" "lsp" :initializationoptions (:enable t :lint t)))
;;         ((node-project-p) '("typescript-language-server" "--stdio"))
;;         (t nil)))

;; (leaf eglot
;;   :hook
;;   (c++-mode . eglot-ensure)
;;   (sh-mode . eglot-ensure)
;;   (python-mode . eglot-ensure)
;;   (html-mode . eglot-ensure)
;;   (cmake-mode . eglot-ensure)
;;   (bitbake-mode . eglot-ensure)
;;   (typescript-ts-mode . eglot-ensure)
;;   :config
;;   ;; (add-to-list 'eglot-server-programs '((bitbake-mode) "bitbake-language-server"))
;;   (add-to-list 'eglot-server-programs '((js-mode typescript-mode) . es-server-program))
;;   (add-to-list 'eglot-server-programs '(gleam-ts-mode . ("lspx" "--lsp" "gleam lsp")))
;;   :bind (("m-t" . xref-find-definitions)
;; 	 ("m-r" . xref-find-references)
;; 	 ("c-t" . xref-go-back)))

;; (leaf eglot-booster
;;   :after eglot
;;   :config (eglot-booster-mode))

;; auto formatting
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
 
;; lua support
(leaf lua-mode)

;; completion
(leaf corfu
  :custom
  ((corfu-cycle . t)
  (corfu-auto . t)
  (corfu-auto-prefix . 1))
  :init
  (global-corfu-mode))


;; cursor moation
(leaf avy
  :config
  (define-key evil-normal-state-map (kbd "spc k") #'avy-goto-line))

;; completion soruce
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

;; hydra
(leaf hydra)
(leaf hydra-posframe
  ;; :require t
  ;; :vc (:url "https://github.com/ladicle/hydra-posframe")

  :init
  ;; for hydra
  (define-key evil-normal-state-map (kbd "spc w") #'manage-window-hydra/body)

  :hook
  (add-hook 'after-init-hook 'hydra-posframe-mode))

(leaf major-mode-hydra)

;; for nix
(pretty-hydra-define nix-flake-hydra
  (:separator "-" :title "nix flake" :forigen-key warn :quit-key "q" :exit t)
  ("build"
   (("b" nix-flake-build-default "build"))

   "update"
   (("u" nix-flake-update "update"))))

;; for manage window
(pretty-hydra-define manage-window-hydra
  (:separator "-" :title "manage window" :forigen-key warn :quit-key "q" :exit t)
  ("1"
   (("a" delete-other-windows "delte other windwos"))

   "2"
   (("s" split-window-below "horizontal split"))

   "3"
   (("d" split-window-right "vertical split"))

   "0"
   (("f" delete-window "delete window"))))

(pretty-hydra-define org-hydra
  (:separator "-" :title "nix flake" :forigen-key warn :quit-key "q" :exit t)
  ("roam"
   (("a" org-roam-node-find "roam"))

   "capture"
   (("s" org-capture "capture"))))
    

;; (pretty-hydra-define org-roam-hydra
;;   (:separator "-" :title "org-roam" :forigen-key warn :quit-key "q" :exit t)
;;   ("find"
;;    (("a" 'org-roam-node-find "find node"))

;;    ""
;;    (("s" 'org-roam- ""))

;;    ""
;;    (("d"  ""))

;;    ""
;;    (("f"  ""))
;;     ))

;; transient dispatcher
(leaf transient-dwim
  :bind ("c-=" . transient-dwim-dispatch))

;; tree filer
(leaf neotree
  :custom
  (neo-smart-open . t)
  (projectile-switch-project-action . 'neotree-projectile-action)
  :config
  (progn
    (evil-define-key 'normal neotree-mode-map (kbd "q") 'neotree-hide)
    (evil-define-key 'normal neotree-mode-map (kbd "l") 'neotree-enter)
    (evil-define-key 'normal neotree-mode-map (kbd "ret") 'neotree-enter)
    (evil-define-key 'normal neotree-mode-map (kbd "h") 'neotree-enter)
    (evil-define-key 'normal neotree-mode-map (kbd "g") 'neotree-refresh)
    (evil-define-key 'normal neotree-mode-map (kbd "j") 'neotree-next-line)
    (evil-define-key 'normal neotree-mode-map (kbd "k") 'neotree-previous-line)
    (evil-define-key 'normal neotree-mode-map (kbd "a") 'neotree-stretch-toggle)
    (evil-define-key 'normal neotree-mode-map (kbd "h") 'neotree-hidden-file-toggle)
    (evil-define-key 'normal neotree-mode-map (kbd "n") 'neotree-create-node)
    (evil-define-key 'normal neotree-mode-map (kbd "k") 'neotree-create-node)
    (evil-define-key 'normal neotree-mode-map (kbd "d") 'neotree-delete-node)
    (evil-define-key 'normal neotree-mode-map (kbd "m") 'neotree-rename-node))
  
  ;; for neotree
  (define-key evil-normal-state-map (kbd "spc f") #'neotree-toggle))
  

;; translate
(leaf google-translate
  :require t
  :custom
  (google-translate-translation-directions-alist . '(("en" . "ja")
                                                     ("ja" . "en"))))
;; wakatime
(leaf wakatime-mode
  :init
  (global-wakatime-mode))

;; typst

;; preview
(leaf typst-preview
  ;; :vc (:url "https://github.com/havarddj/typst-preview.el")
  ;; :require t
  :config
  (setq typst-preview-browser "firefox"))

;; ruby support
(leaf inf-ruby)

(leaf enh-ruby-mode)

;; python support
(add-hook 'python-ts-mode-hook (lambda ()
				 (require 'python-mode)))

;; language supports

;; dotnet
(leaf dotnet
  :after csharp-mode)

;; c#
(leaf csharp-mode)

;; nix support
(leaf nix-mode
  :hook
  (nix-ts-mode))

;; scala suppport
(leaf scala-mode
  :interpreter ("scala" . scala-mode))


(leaf sbt-mode
  :commands sbt-start sbt-command
  :config
  (substitute-key-definition
   'minibuffer-complete-word
   'self-insert-command
   minibuffer-local-completion-map)

   (setq sbt:program-options '("-dsbt.supershell=false")))

;; astro support
(leaf astro-ts-mode)

;; elixir support
(leaf inf-elixir)
(leaf mix)

(leaf elixir-ts-mode
  :hook ((elixir-ts-mode . mix-minor-mode)))

;; kdl supports
(leaf kdl-ts-mode)

;; gleam support
(leaf gleam-ts-mode
  :require t
  :hook gleam-on-save-mode)

;; markdown suppot
(leaf markdown-mode
  :hook
  (add-to-list 'completion-at-point-functions #'cape-emoji))

;; projectile
(defun update-projectlist ()
  (interactive)
  (setq projectile-known-projects
         (mapcar
          (lambda (x) (abbreviate-file-name x))
          (split-string (shell-command-to-string "ghq list --full-path")))))

(leaf projectile 
  :config
  (define-key evil-normal-state-map (kbd "m-g") #'projectile-switch-project)
  (define-key evil-normal-state-map (kbd "c-o") #'projectile-find-file)
  :init
  (when (executable-find "ghq")
   (update-projectlist)))

;; migemo
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

;; nyan-mode
(leaf nyan-mode
  :init
  (progn (nyan-mode)
   (nyan-start-animation)))

;; snippets
(leaf tempel
  :require t
  :bind ((:evil-insert-state-map
	  ("m-a" . tempel-done)))
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

;; http request
(leaf request)
(leaf plz)

(autoload 'newsticker-start "newsticker" "start newsticker" t)
(autoload 'newsticker-show-news "newsticker" "goto newsticker buffer" t)

(setq newsticker-url-list
      '(("gleam weekly" "https://gleamweekly.com/atom.xml")
        ("zenn gleam" "https://zenn.dev/topics/gleam/feed")
	("gleam releases" "https://github.com/gleam-lang/gleam/releases.atom")
	("zenn trend" "https://zenn.dev/feed")
	("zenn emacs" "https://zenn.dev/topics/emacs/feed")
        ("zenn ts" "https://zenn.dev/topics/typescript/feed")
        ("zenn cl" "https://zenn.dev/topics/commonlisp/feed")
        ("zenn deno" "https://zenn.dev/topics/deno/feed")
        ("zenn bun" "https://zenn.dev/topics/bun/feed")
        ("zenn rust" "https://zenn.dev/topics/rust/feed")
        ("zenn vim" "https://zenn.dev/topics/vim/feed")
        ("zenn neovim" "https://zenn.dev/topics/neovim/feed")
        ("zenn scheme" "https://zenn.dev/topics/scheme/feed")
        ("zenn hono" "https://zenn.dev/topics/hono/feed")
        ("zenn react" "https://zenn.dev/topics/react/feed")
        ("zenn gcp" "https://zenn.dev/topics/googlecloud/feed")
        ("zenn aws" "https://zenn.dev/topics/aws/feed")
        ("techfeed" "https://techfeed.io/feeds/categories/all")
	("hacker news" "https://hnrss.org/frontpage")
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
	  ("c-a" . grugru))
	 (:evil-normal-state-map
	  ("c-x" . grugru-backward)))
  :config
  ;; ref: https://github.com/rocktakey/grugru/issues/44
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

;; (leaf folding-mode :require t)

(leaf rg
  :require t)

(leaf open-junk-file
  :require t
  :custom
  (open-junk-file-format . "/tmp/junk/%y_%m_%d_%h%m%s.")
  :bind (("c-x j" . open-junk-file)))

(leaf fold-this)

(leaf alert
  :config
  (setq alert-default-style 'libnotify))

(leaf dashboard
  :config
  (setq dashboard-startup-banner (expand-file-name "~/pictures/.emacs-logos/gnu_color_resize.png"))
  (setq dashboard-startup-banner 'logo))

(leaf aas
  ;; :hook (text-mode . aas-activate-for-major-mode)
  ;; :init
  ;; (aas-set-snippets 'global)
  ;; (aas-set-snippets 'markdown-mode)
  ;; (aas-set-snippets 'prog-mode)
  )

(leaf smartparens
  :config
  (smartparens-global-mode t))

(leaf vterm)

(leaf vterm-toggle
  :after evil
  :bind (("c-<return>" . (lambda ()
			   (interactive)
			   (vterm-toggle-insert-cd)
			   (vterm-toggle-insert-cd)))))

(leaf multi-vterm
  :config
  (setq multi-vterm-dedicated-window-height 50))

;; ai
(add-hook 'server-after-make-frame-hook
          (lambda ()
            (setenv "gemini_api_key" (get-secret "gemini.google.com")
            (setenv "openrouter_api_key" (get-secret "openrouter.ai"))
	    (setq gemini-apikey (get-secret "gemini.google.com"))))

(leaf gptel
  :config
  (setq
   ;; gptel-model 'starcoder2
   ;; gptel-backend (gptel-make-ollama "ollama"
   ;;                :host "localhost:11434"
   ;;                :stream t
   ;;                :models '(starcoder2)))

   gptel-model 'gemini-2.5-flash
   gptel-backend (gptel-make-gemini "gemini"
		   :key gemini-apikey
		   :stream t)))

;; ai codeing
(leaf aider
  :require t
  :custom
  (;; (aider-args . '("--watch-files" "--model" "gemini/gemini-2.0-flash"))
   (aider-args . '("--watch-files" "--model" "openrouter/anthropic/claude-3.5-sonnet"))
   ))

(leaf aidermacs
  :require t
  :config
  (setq aidermacs-watch-files t)
  :custom
  (;; (aidermacs-default-model . "gemini/gemini-2.0-flash")
   (aidermacs-default-model . "gemini/gemini-2.5-pro-preview-03-25")
   (aidermacs-watch-files . t)))
;; (aidermacs-default-model . "gemini/gemini-2.5-flash-preview-04-17")


(leaf mcp)

(leaf minimap
  :require t
  :custom ((minimap-window-location . 'right)
	   (minimap-minimum-width . 20)
	   (minimap-major-modes . '(prog-mode
				    markdown-mode
				    html-mode
				    fundamental-mode)))
  :bind ("c-x m" . minimap-mode)
  :config
  (minimap-mode 1))

(leaf rainbow-delimiters
  :hook
  (prog-mode-hook . rainbow-delimiters-mode))

(leaf ox-zenn
  :after org
  :require t)

(leaf verb)

(leaf quickrun)

;; ================ my extentions ================

(defun get-secret (host)
  "wrapper functino for auth-info"
  (require 'ht) 
  (let* ((found (cl-first (auth-source-search :host host
					      :user "coma")))
	 (credentials (when found
			(eval `(ht ,@(--map `(,it ,(plist-get found it))
                                            '(:user :secret :save-function))))))
	 (secret (when credentials
                   (ht-get credentials :secret))))

    (if (not secret)
	(progn (message (format "does not found %s credential." host))
	       "")
      (if (functionp secret)
          (funcall secret)
	secret))))

;; (defun nyan-region ()
;;   "選択範囲をにゃーんで置換する"
;;   (interactive)
;;   (when (use-region-p)
;;     (let* ((beg (region-beginning))
;;            (end (region-end)))
;;      (len (- end beg)
;;       (delete-region beg end)
;;       (cond ((= len 1) (insert "にゃ")))
;;       ((= len 2) (insert "にゃん"))
;;       (t (insert (format "にゃ%sん" (make-string (- len 3) ?ー))))))))

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

  (let* ((query (read-from-minibuffer "query? > ")))
   (url (concat "https://www.google.com/search?client=firefox-b-d&q=" (url-hexify-string query))
  
    (shell-command (concat "open " "'" url "'")))))

(defun home-manager ()
  (interactive)
  (start-process "home-manager-process"
     "*home-manager*"
     "home-manager"
     "switch"
     "--flake"
     ".#home"
     "-b"
     "backup"))

    ;; (set-process-sentinel proc
    ;;                           (lambda (process event)
    ;;                             (when (string= event "finished\n"))))

(defun all (pred lst)
  "returns t if all elements of the list satisfy the predicate."
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
  (let ((beg (save-excursion (skip-chars-backward "a-za-z") (point)))
        (end (point))
        (candidates gitmoji--codes))
    (list beg end candidates :exclusive 'no)))

;; collect gitmoji when startup
;; (add-hook 'emacs-startup-hook 'setup-gitmoji)
;; enable at git-commit-mode

;; display character count in modeline
(defun update-buffer-char-count ()
  (interactive)
  (format " [%d] " (buffer-size)))

(defun mode-line-time ()
  ;; update every second
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

;; for diary
(setq blog-repo "/home/coma/.ghq/github.com/comamoca/blog/")

(defun latest-diary ()
  "open latest diary. this function call in `src/blog/` directory at blog repository."
  (interactive)
  (let* ((date (format-time-string "%y-%m-%d"))
         (file-name (format "%s-diary.md" date))
         (path (concat (expand-file-name "src/blog/" blog-repo) file-name)))
    (find-file path)
    (if (= (buffer-size) 0)
	(tempel-insert 'diary))))

(defun new-blog-article ()
  "open latest diary. this function call in `src/blog/` directory at blog repository."
  (interactive)
  (let* ((date (format-time-string "%y-%m-%d"))
         (slug (read-string "slug > "))
         (file-name (format "%s-%s.md" date slug))
         (path (concat (expand-file-name "src/blog/" blog-repo) file-name)))
    ;; (projectile-switch-project-by-name "blog")
    (find-file path)))

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
	 (mdfiles (cl-remove-if-not (lambda (file))))
	 (articles (cl-remove-if (lambda (file)))
		   (string-match "-diary.md$" file
				 files))
	 (selected (completing-read "blog " articles)))
    (find-file (expand-file-name selected src-dir)))) 

(defun org-paste-image ()
  (interactive)
  (setq filename (concat
                  (expand-file-name (format-time-string "%y-%m-%d-%h%m%s")
                   "~/.ghq/github.com/comamoca/org/imgs") ".png"))
  (shell-command (concat  "wl-paste -t image/png > " filename))
  (insert (concat "[[" filename "]]"))
  (org-display-inline-images))

(defun blog-paste-image ()
  (interactive)
  (setq fullpath (concat
                  (expand-file-name (format-time-string "%y-%m-%d-%h%m%s")
				    "~/.ghq/github.com/comamoca/blog/src/images") ".png"))
  (shell-command (concat  "wl-paste -t image/png > " fullpath))
  (insert (concat "![](/images/" (file-name-nondirectory fullpath) ")"))
  (org-display-inline-images))


;; gauche
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
  (let* ((node-items (mapcar (lambda (node)))
             (cons (org-roam-node-title node) node)) (org-roam-node-list))
   (select-node-title (consult--read)
        (mapcar #'car node-items))
   (select-node (cdr (assoc select-node-title node-items))

    (find-file (org-roam-node-file select-node)))))

;; pinentry emacs
(defun pinentry-emacs (desc prompt ok error)
  (let ((str (read-passwd (concat (replace-regexp-in-string "%22" "\"" (replace-regexp-in-string "%0a" "\n" desc)) prompt ": "))))
    str))

;; initel function that behaves like `:e $myvimrc`
(defun initel ()
  (interactive)
  (find-file user-init-file))

;; ================ my configuratons ================

;; ediff
(setq ediff-window-setup-function 'ediff-setup-windows-plain)

;; font
(add-to-list 'default-frame-alist
                       '(font . "udev gothic nf-14"))

;; for auth-info
(setq auth-sources '("~/.emacs.d/.authinfo.gpg"))
(setq create-lockfiles nil)

;; for lsp-mode
(setq gc-cons-threshold 100000000)
(setq read-process-output-max (* 1024 1024))

;; key mapping
(define-key global-map (kbd "c-x s") 'blackening-region)
(define-key global-map (kbd "c-;") 'comment-dwim)

;; minibuffe
(define-key minibuffer-local-map (kbd "c-h") 'delete-char)
(define-key minibuffer-local-ns-map (kbd "c-h") 'delete-char)
(define-key minibuffer-local-completion-map (kbd "c-h") 'delete-char)
(define-key minibuffer-local-must-match-map (kbd "c-h") 'delete-char)
(define-key minibuffer-local-filename-completion-map (kbd "c-h") 'delete-char)

;; enable debug
(setq debug-on-error nil)

;; custom modeline
(mode-line-format-update)

;; when org-mode
(add-hook 'org-mode
    (lambda ()
      (local-set-key evil-insert-state-map (kbd "c-h") #'org-insert-heading)))

(electric-pair-mode 1)

(global-hl-line-mode t)

(setq vc-follow-symlinks t)
(setq browse-url-generic-program "firefox")
(setq ring-bell-function 'ignore)

(setq display-warning-minimum-level :error)

;; disable to create backupfile
(setq make-backup-files nil)

;; disable to auto save
(setq auto-save-default nil)

;; copy & paste with wl-clipboard
;; ref: https://gist.github.com/yorickvp/6132f237fbc289a45c808d8d75e0e1fb
(setenv "wayland_display" "wayland-1")

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
  :bind (("c-c e" . macrostep-expand)))

;; (provide 'init)
(put 'narrow-to-region 'disabled nil)
(custom-set-variables
 ;; custom-set-variables was added by custom.
 ;; if you edit it by hand, you could mess it up, so be careful.
 ;; your init file should contain only one such instance.
 ;; if there is more than one, they won't work right.
 '(skk-jisyo-edit-user-accepts-editing t))
(custom-set-faces)
 ;; custom-set-faces was added by custom.
 ;; if you edit it by hand, you could mess it up, so be careful.
 ;; your init file should contain only one such instance.
 ;; if there is more than one, they won't work right.
 

 
