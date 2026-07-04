;; -*- lexical-binding: t -*-

;; <leaf-install-code>
(eval-and-compile
  ;; このEmacsビルドは tree-sitter 非対応
  ;; astro-ts-mode の autoload が (treesit-ready-p 'astro) を呼ぶので事前に定義
  (unless (fboundp 'treesit-ready-p)
    (defalias 'treesit-ready-p (lambda (&rest _) nil)))
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
    :config
    (leaf-keywords-init)))
;; </leaf-install-code>

;; ================================================
;; 起動時間計測
;; ================================================

(defconst my/before-load-init-time (current-time)
  "Time when init.el started loading.")

(defun my/load-init-time ()
  "Loading time of user init files including time for `after-init-hook'."
  (let ((time1 (float-time
                (time-subtract after-init-time my/before-load-init-time)))
        (time2 (float-time
                (time-subtract (current-time) my/before-load-init-time)))
        (inhibit-message nil))
    (message (concat "Loading init files: %.0f [msec], "
                     "of which %.0f [msec] for `after-init-hook'.")
             (* 1000 time1) (* 1000 (- time2 time1)))))
(add-hook 'after-init-hook #'my/load-init-time t)

(defun my/emacs-init-time ()
  "Emacs booting time in msec."
  (interactive)
  (let ((inhibit-message nil))
    (message "Emacs booting time: %.0f [msec] = `emacs-init-time'."
             (* 1000
                (float-time (time-subtract after-init-time before-init-time))))))
(add-hook 'after-init-hook #'my/emacs-init-time)



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
        completion-auto-help nil
        completion-category-overrides '((file (styles basic partial-completion))))
  :init 
  (vertico-mode))

(leaf vertico-posframe
  :after (vertico posframe)
  :config
  (defun my/vertico-posframe-get-size (buffer)
    "Width: 2/3 of frame, Height: 1.5x vertico-count."
    (let* ((width (round (* (frame-width) 0.55)))
           (height (round (* (+ vertico-count 1) 1.5))))
      (list :width width :height height
            :min-width width :min-height height
            :max-width width :max-height height)))
  (setq vertico-posframe-size-function #'my/vertico-posframe-get-size)
  (vertico-posframe-mode 1)

  ;; posframe が surrogate minibuffer frame を作成する関係で、
  ;; delete-window → delete-frame 時に "Attempt to delete a surrogate minibuffer frame"
  ;; エラーが発生してウィンドウが閉じれなくなるのを防ぐ
  (advice-add 'delete-frame :around
              (lambda (orig-fun frame &optional force)
                "Suppress 'Attempt to delete a surrogate minibuffer frame' error."
                (condition-case err
                    (funcall orig-fun frame force)
                  (error
                   (if (string-match-p "Attempt to delete a surrogate minibuffer frame"
                                       (error-message-string err))
                       (message "Surrogate minibuffer frame: 削除をスキップしました")
                     (signal (car err) (cdr err))))))))

;; Completion Styles
(leaf orderless)

(leaf hotfuzz)

;; Completing read functions
(leaf consult
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
	  ("C-h" . evil-delete-backward-char-and-join)))
  :config
  (setq evil-backspace-join-lines t)
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
  (push '("\\.cshtml\\'" . web-mode) auto-mode-alist)
  (push '("\\.cs\\'" . csharp-ts-mode) auto-mode-alist)
  (push '("\\.ex\\'" . elixir-ts-mode) auto-mode-alist)
  (push '("\\.gleam\\'" . gleam-ts-mode) auto-mode-alist)
  (push '("\\.js\\'" . js-ts-mode) auto-mode-alist)
  (push '("\\.mjs\\'" . js-ts-mode) auto-mode-alist)
  (push '("\\.ts\\'" . typescript-ts-mode) auto-mode-alist)
  (push '("\\.tsx\\'" . tsx-ts-mode) auto-mode-alist)
  (push '("\\.rust\\'" . rust-ts-mode) auto-mode-alist)
  (push '("\\.typ\\'" . typst-ts-mode) auto-mode-alist) 
  (push '("\\.dat$" . ledger-mode) auto-mode-alist)
  (push '("\\.yaml" . yaml-ts-mode) auto-mode-alist)
  (push '("\\.html" . html-ts-mode) auto-mode-alist)
  (push '("\\.rs" . rust-ts-mode) auto-mode-alist)
  (push '("\\.yml" . yaml-ts-mode) auto-mode-alist)
  (push '("templates" . lisp-data-mode) auto-mode-alist)
  (push '(".aiderrules" . markdown-mode) auto-mode-alist)
  (push '("Dockerfile" . dockerfile-ts-mode) auto-mode-alist))

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

;; Calendar 
(leaf calendar)

;; org-mode
(leaf org
  :after text-mode calendar-mode
  :custom
  ((org-todo-keywords .
		      '((sequence "TODO(t)" "NEXT(n)" "IN-PROGRESS(i)" "WAIT(w@/!)" "SOMEDAY(s)" "|" "DONE(d!)" "CANCELED(c@)")))
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
  

  :hook
  (org-mode . org-nix-shell-mode)
  :config
  (set-language-environment "Japanese")
  (prefer-coding-system 'utf-8)
  (set-default 'buffer-file-coding-system 'utf-8)
  (setq org-confirm-babel-evaluate nil)

  (org-babel-do-load-languages
   'org-babel-load-languages
   '((C . t)
     (shell . t)
     (python . t)
     (clojure . t)
     (hy . t)
     (ruby . t)
     (sparql . t)
     (ledger . t)
     (verb . t)
     (gleam . t)))
  :bind ((:calendar-mode-map
          ("C-c c" . org-capture-from-calendar))))

(add-hook 'org-mode-hook
          (lambda ()
            (evil-define-key 'normal org-mode-map (kbd "TAB") #'org-cycle)
            (evil-define-key 'normal org-mode-map (kbd "C-<return>") (lambda ()
                                                                       (interactive)
                                                                       (vterm-toggle-insert-cd)
                                                                       (vterm-toggle-insert-cd)))))

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
   `(org-roam-index-file . ,(expand-file-name "index.org" org-roam-directory))
   (org-roam-capture-templates .
			       '(("d" "default" plain
				  "%?"
				  :if-new (file+head "%<%Y%m%d%H%M%S>-${slug}.org"
						     "#+title: ${title}\n")
				  :unnarrowed t)
				 ("r" "reference" plain
				  "%?"
				  :if-new (file+head "%<%Y%m%d%H%M%S>-${slug}.org"
						     "#+title: ${title}\n#+filetags: :reference:\n")
				  :unnarrowed t))))
  :config
  (org-roam-db-autosync-mode))

;; Deft
;; For search roam files.
(leaf deft
  :after org-roam-mode
  :custom
  ((deft-extensions . '("txt" "tex" "org"))
   `(deft-directory . ,(expand-file-name "roam" org-directory))))

(leaf org-roam-ui)

;; org-capture から org-roam ノートを作成するための設定
(with-eval-after-load 'org-roam
  (defun my/org-roam-capture-target ()
    "Create a new org-roam node file and set it as the org-capture target."
    (interactive)
    (let* ((title (read-string "Title: "))
           (slug (org-roam-node-slugify title))
           (file (expand-file-name
                  (format "%s-%s.org"
                          (format-time-string "%Y%m%d%H%M%S")
                          slug)
                  org-roam-directory)))
      (find-file file)
      (insert "#+title: " title "\n\n")
      (org-id-get-create)
      (goto-char (point-min))))

  ;; 古い "r" エントリがあれば削除してから追加
  (setq org-capture-templates
        (seq-remove (lambda (tmpl) (string= (car tmpl) "r"))
                    org-capture-templates))
  (add-to-list 'org-capture-templates
               '("r" "Roam" plain (function my/org-roam-capture-target)
                 "%?"
                 :unnarrowed t) t))

;; org-bullets
(leaf org-bullets
  :after org)

;; org-modern
(leaf org-modern
  :after
  :init
  (with-eval-after-load 'org (global-org-modern-mode)))

;; org-transclusion — リンク先の内容をインライン展開
(leaf org-transclusion
  :after org
  :bind (:org-mode-map
         ("C-c t" . org-transclusion-mode))
  :config
  (setq org-transclusion-exclude-elements '(property-drawer keyword))
  ;; org-roam の ID リンクに対して transclusion を有効化
  (add-to-list 'org-transclusion-extensions 'org-roam)
  :init
  (with-eval-after-load 'org
    (require 'org-transclusion)
    (require 'org-transclusion-org-roam nil t)))

;; org-babel
(leaf ob-hy)

(leaf ob-gleam)

(leaf org-nix-shell)

(leaf om-dash
  :require t)

;; howm

(leaf howm
  :init
  (require 'howm-org)
  :require t
  :config
  (setq howm-file-name-format "%Y-%m-%d.org"))

;; ================================================
;; Project notes - per-file org storage
;; org-project-capture の機能をカスタムコードで置き換え
;; プロジェクトごとに org/project/<project-name>.org で管理
;; ================================================

(defvar my/project-notes-dir
  (expand-file-name "project" org-directory)
  "Directory for per-project org note files.")

(defun my/worktree-main-repo-name (root)
  "If ROOT is a git worktree, return the main repo's directory name.
Otherwise return nil."
  (when-let* ((git-file (expand-file-name ".git" root))
              ((file-regular-p git-file)))
    (with-temp-buffer
      (insert-file-contents git-file)
      (goto-char (point-min))
      (when (looking-at "gitdir: \\(.+\\)$")
        (let* ((gitdir-path (match-string-no-properties 1))
               (main-repo (file-name-directory
                           (directory-file-name
                            (file-name-directory
                             (directory-file-name
                              (file-name-directory gitdir-path)))))))
          (file-name-nondirectory (directory-file-name main-repo)))))))

(defun my/project-notes-file ()
  "Return the org file path for the current projectile project.
Uses author/repo.org format (e.g. Comamoca/dotfiles.org) to avoid
collisions between forked repositories.
Git worktrees resolve to the main repo's org file."
  (when-let* ((root (projectile-project-root))
              (dir (directory-file-name root))
              (components (split-string dir "/" t))
              (repo (or (my/worktree-main-repo-name root)
                        (car (last components))))
              (author (car (last components 2))))
    (if (and author repo)
        (let ((dir-path (expand-file-name author my/project-notes-dir)))
          (make-directory dir-path t)
          (expand-file-name (concat repo ".org") dir-path))
      ;; fallback: just use basename
      (make-directory my/project-notes-dir t)
      (expand-file-name (concat repo ".org") my/project-notes-dir))))

(defun my/open-project-notes ()
  "Open the org file for the current projectile project.
Creates the file with default headings if it doesn't exist.
Sets `default-directory' to the projectile project root so that
subsequent operations (e.g. org-capture, compile) run in the
project context."
  (interactive)
  (let* ((file-path (my/project-notes-file))
         ;; Capture the project root BEFORE find-file changes the buffer context.
         ;; After find-file, projectile-project-root returns nil because
         ;; the notes file is outside any projectile project.
         (project-root (and file-path (projectile-project-root))))
    (if file-path
        (progn
          (find-file file-path)
          ;; bind current directory to projectile project root
          (when project-root
            (setq default-directory (file-name-as-directory project-root)))
          (when (= (buffer-size) 0)
            (insert (format "#+title: %s\n\n* Tasks\n\n* Notes\n\n"
                            (file-name-base (buffer-file-name))))))
      (message "Not in a project"))))

(defun my/capture-project-todo ()
  "Capture a TODO into the current projectile project's org file."
  (interactive)
  (let ((file-path (my/project-notes-file)))
    (if file-path
        (org-capture nil "P")
      (message "Not in a project"))))

(defun my/project-notes-agenda ()
  "Show agenda for the current project's notes file."
  (interactive)
  (let* ((file-path (my/project-notes-file))
         (org-agenda-files (if file-path (list file-path))))
    (if file-path
        (org-agenda nil "a")
      (message "Not in a project"))))

;; Add capture template for project entries
(with-eval-after-load 'org-capture
  (add-to-list 'org-capture-templates
               '("P" "Project" entry
                 (file my/project-notes-file)
                 "* TODO %?\n%U\n%a\n" :prepend t :empty-lines 1)
               t))

;; Keybindings
(global-set-key (kbd "C-c n p") #'my/open-project-notes)
(global-set-key (kbd "C-c n t") #'my/capture-project-todo)
(global-set-key (kbd "C-c n a") #'my/project-notes-agenda)

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

(leaf kuro
  :config
  (setq kuro-module-binary-path
        (expand-file-name "libkuro_core.so"
                          (file-name-directory (locate-library "kuro")))))

(leaf vterm
  :config
  (evil-define-key 'insert vterm-mode-map (kbd "C-l") 'vterm-clear))

;; Common Lisp
(leaf slime
  :config
  (defvar inferior-lisp-program "sbcl"))

(leaf sly
  :config)

(leaf sly-asdf)

;; Clojure
(leaf cider)

(leaf kaocha-runner
  :after cider-mode)

;; flycheck（入力中の頻繁なチェックを抑制してCPU負荷を削減）
(leaf flycheck
  :hook
  (after-init . global-flycheck-mode)
  ((text-mode-hook markdown-mode-hook gfm-mode-hook org-mode-hook) . flycheck-mode)
  :custom ((flycheck-display-errors-delay . 0.5)
           (flycheck-idle-change-delay . 1.0)  ; デフォルト0.5秒→1秒に延長
           (flycheck-idle-buffer-switch-delay . 1.0)
           (flycheck-indication-mode . 'left-margin))
  :config
  (add-hook 'flycheck-mode-hook #'flycheck-set-indication-mode)
  ;; *scratch* バッファでは flycheck を無効化
  ;; flycheck-global-modes の '(not ...) は after-change-major-mode-hook
  ;; 経由の新規バッファには効くが、global-flycheck-mode 有効化時点で
  ;; 既存の *scratch* には適用されない。明示的に無効化する。
  (setq flycheck-global-modes '(not lisp-interaction-mode))
  (defun my/flycheck-disable-in-scratch (&rest _)
    "Disable flycheck in *scratch* buffer if it exists."
    (let ((buf (get-buffer "*scratch*")))
      (when buf
        (with-current-buffer buf
          (flycheck-mode -1)))))
  ;; デーモン接続時（emacsclient -c）に *scratch* が表示されたら無効化
  (add-hook 'server-after-make-frame-hook #'my/flycheck-disable-in-scratch)
  ;; global-flycheck-mode 有効化直後の既存 *scratch* も無効化
  (global-flycheck-mode 1)
  (my/flycheck-disable-in-scratch))

(leaf flycheck-posframe
  :after flycheck
  :config (add-hook 'flycheck-mode-hook #'flycheck-posframe-mode))

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
  (push '("enh-ruby" . "ruby") copilot-major-mode-alist)
  (push '("typescript-ts-mode" . "typescript") copilot-major-mode-alist))

;; LSP
;; lsp-mode
(leaf lsp-mode
  :hook
  (csharp-ts-mode . lsp-deferred)
  (elixir-ts-mode . lsp-deferred)
  (gleam-ts-mode . lsp-deferred)
  (js-ts-mode . lsp-deferred)
  (typescript-ts-mode . lsp-deferred)
  (tsx-ts-mode . lsp-deferred)
  (go-ts-mode . lsp-deferred)
  (rust-ts-mode . lsp-deferred)
  (python-ts-mode . lsp-deferred)
  (php-mode . lsp-deferred)
  (scala-mode . lsp-deferred)
  (lua-mode . lsp-deferred)
  :custom
  ((lsp-completion-provider . :capf))   ;; :none → :capf (corfuと併用する標準設定)
  :config
  ;; gc-cons-threshold はグローバルGC管理(my/gc-*)に委譲
  (setq read-process-output-max (* 1024 1024))
  (setq lsp-idle-delay 1.0)
  (setq lsp-after-command-idle-delay 0.5)  ; post-command負荷低減

  (define-key evil-normal-state-map (kbd "K") 'lsp-ui-doc-glance)

  (push '(nix-mode . "nil") lsp-language-id-configuration)
  (push '(python-mode . "python") lsp-language-id-configuration)
  (with-eval-after-load 'lsp-mode
    (push 'semgrep-ls lsp-disabled-clients)))

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
  "Prepend emacs-lsp-booster command to lsp CMD.
Uses --json-object-type hashtable to match Nix-compiled lsp-mode (lsp-use-plists=nil)."
  (let ((orig-result (funcall old-fn cmd test?)))
    (if (and (not test?)                             ;; for check lsp-server-present?
             (not (file-remote-p default-directory)) ;; see lsp-resolve-final-command, it would add extra shell wrapper
             (not (functionp 'json-rpc-connection))  ;; native json-rpc
             (executable-find "emacs-lsp-booster"))
        (progn
          (when-let ((command-from-exec-path (executable-find (car orig-result))))  ;; resolve command from exec-path (in case not found in $PATH)
            (setcar orig-result command-from-exec-path))
          (message "Using emacs-lsp-booster for %s!" orig-result)
          ;; Nix の lsp-mode は hashtable でコンパイル済みのため --json-object-type hashtable を指定
          (append (list "emacs-lsp-booster" "--json-object-type" "hashtable" "--") orig-result))
      orig-result)))

(advice-add 'lsp-resolve-final-command :around #'lsp-booster--advice-final-command)

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
   (corfu-auto . t)
   (corfu-auto-prefix . 1)
   (corfu-auto-delay . 0.3))      ; 0→0.3sに延長してpost-command負荷を低減

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
  :after corfu
  :config
  ;; lsp-mode のキャッシュ問題と二重補完を防止
  (advice-add #'lsp-completion-at-point :around #'cape-wrap-buster)
  ;; LSP 補完時のハングを防止
  (advice-add #'lsp-completion-at-point :around #'cape-wrap-noninterruptible))



;; with icon
(leaf kind-icon
  :custom (kind-icon-default-face 'corfu-default)
  :config
  (push #'kind-icon-margin-formatter corfu-margin-formatters))

(leaf all-the-icons
  :init
  (setq-default neo-theme (if (display-graphic-p) 'icons 'arrow)))

;; Hydra
(leaf hydra
  :init
  ;; For hydra
  (define-key evil-normal-state-map (kbd "SPC w") #'manage-window-hydra/body)
  (define-key evil-normal-state-map (kbd "SPC s") #'hydra-spotify/body))

(leaf hydra-posframe
  :after hydra
  :config
  (setq hydra-posframe-parameters
        '((internal-border-width . 10)
          (no-accept-focus . t)))
  :init
  (hydra-posframe-mode 1))

(leaf major-mode-hydra)

;; A hydra for controlling spotify.
(defun smudge-vertico--fetch-all-playlist-tracks (playlist page callback &optional accumulated)
  "Fetch all tracks from PLAYLIST across all pages, then call CALLBACK with all tracks.
Starts from PAGE and accumulates into ACCUMULATED list."
  (smudge-api-playlist-tracks
   playlist
   page
   (lambda (json)
     (let* ((tracks (smudge-api-get-playlist-tracks json))
            (total (gethash "total" json))
            (all (append (or accumulated nil) (or tracks nil)))
            (fetched-count (length all)))
       (if (or (null tracks)
               (not total)
               (>= fetched-count total))
           (funcall callback all)
         (smudge-vertico--fetch-all-playlist-tracks playlist (1+ page) callback all))))))

(defun smudge-vertico--fetch-all-my-playlists (user-id page callback &optional accumulated)
  "Fetch all playlists for USER-ID across all pages, then call CALLBACK.
Starts from PAGE and accumulates into ACCUMULATED list."
  (smudge-api-user-playlists
   user-id
   page
   (lambda (json)
     (let* ((items (smudge-api-get-items json))
            (total (gethash "total" json))
            (all (append (or accumulated nil) (or items nil)))
            (fetched-count (length all)))
       (if (or (null items)
               (not total)
               (>= fetched-count total))
           (funcall callback all)
         (smudge-vertico--fetch-all-my-playlists user-id (1+ page) callback all))))))

(defun smudge-vertico-search-playlist-track ()
  "Show my playlists via vertico, select one, show all its tracks, then play."
  (interactive)
  (smudge-api-current-user
   (lambda (user)
     (smudge-vertico--fetch-all-my-playlists
      (smudge-api-get-item-id user)
      1
      (lambda (playlists)
        (if-let* ((choices (mapcar (lambda (p)
                                     (cons (smudge-api-get-item-name p) p))
                                   playlists))
                  (selected-name (completing-read "Playlist: " choices nil t))
                  (selected (cdr (assoc selected-name choices))))
            (smudge-vertico--fetch-all-playlist-tracks
             selected
             1
             (lambda (tracks)
               (if-let* ((track-choices
                          (mapcar (lambda (trk)
                                    (cons (format "%s - %s"
                                                  (smudge-api-get-item-name trk)
                                                  (smudge-api-get-track-artist-name trk))
                                          trk))
                                  tracks))
                         (selected-track-name
                          (completing-read "Track: " track-choices nil t))
                         (selected-track
                          (cdr (assoc selected-track-name track-choices))))
                   (progn
                     (smudge-controller-play-track selected-track selected)
                     (message "Now playing: %s - %s"
                              (smudge-api-get-item-name selected-track)
                              (smudge-api-get-track-artist-name selected-track)))
                 (message "No tracks found in this playlist."))))
          (message "No playlists found.")))))))

(defhydra hydra-spotify (:hint nil)
  "
^Search^                  ^Control^               ^Manage^
^^^^^^^^-----------------------------------------------------------------
_t_: Track               _SPC_: Play/Pause        _+_: Volume up
_m_: My Playlists        _n_  : Next Track        _-_: Volume down
_u_: User Playlists      _r_  : Repeat            _d_: Device
_/_: Playlist Search     _s_  : Shuffle           _q_: Quit
"
  ("/" smudge-vertico-search-playlist-track :exit nil)
  ("t" smudge-track-search :exit t)
  ("m" smudge-my-playlists :exit t)
  ("u" smudge-user-playlists :exit t)
  ("SPC" smudge-controller-toggle-play :exit nil)
  ("n" smudge-controller-next-track :exit nil)
  ("p" smudge-controller-previous-track :exit nil)
  ("r" smudge-controller-toggle-repeat :exit nil)
  ("s" smudge-controller-toggle-shuffle :exit nil)
  ("+" smudge-controller-volume-up :exit nil)
  ("-" smudge-controller-volume-down :exit nil)
  ("x" smudge-controller-volume-mute-unmute :exit nil)
  ("d" smudge-select-device :exit nil)
  ("q" quit-window "quit" :color blue))

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


;; Transient dispatcher
(leaf transient-dwim
  :bind ("C-=" . transient-dwim-dispatch))

;; Projectile
(leaf projectile
  :require t
  :config
  (projectile-mode +1)
  (push ".git" projectile-project-root-files)
  (setq projectile-project-root-files-bottom-up
	'("Cargo.toml" "gleam.toml" "flake.nix"))
  ;; .gitignore を尊重するため git ls-files ベースの indexing を使用
  (setq projectile-indexing-method 'hybrid)
  ;; ghq の owner/repo レイアウトでは depth=2 で全リポジトリに到達する
  ;; それ以上深くするとリポジトリ内部 (node_modules/ 等) に入り込む
  (setq projectile-project-search-path
	`(,(cons (expand-file-name "~/.ghq/github.com/") 2)))

  :bind ((:projectile-mode-map
          ("C-c p" . projectile-command-map))))

;; Perspective workspace management
(leaf perspective
  :custom
  ((persp-auto-save-opt . 1))
  :config
  (setq persp-suppress-no-prefix-key-warning t)
  (setq persp-save-dir (expand-file-name "perspectives/" user-emacs-directory))
  (make-directory persp-save-dir t)
  (persp-mode 1))

;; Perspective x Projectile bridge
(leaf persp-projectile
  :after (perspective projectile)
  :custom
  ((persp-projectile-project-persp-creator . 'my/persp-projectile-creator))
  :bind ((:projectile-mode-map
          ("C-c p p" . projectile-persp-switch-project))))

;; Git worktree をメインリポジトリと同じ perspective で扱う
;; worktrunk が作成した worktree (e.g. dotfiles.test-feature) も
;; "dotfiles" perspective に統合される
(defun my/persp-projectile-creator (project)
  "Return perspective name for PROJECT.
For git worktrees, use the main repository's directory name
so they share the same perspective as the main repo."
  (let ((root (if (listp project) (car project) project)))
    (or (my/worktree-main-repo-name root)
        (projectile-project-name project))))

;; treemacs-projectile: `treemacs-projectile-mode` was removed in newer versions.
;; Projectile integration is now built into treemacs core via
;; `treemacs-project-follow-mode` (enabled below).
(leaf treemacs-projectile
  :after treemacs)

;; Tree file explorer (Treemacs)
(defun my/treemacs-show-project ()
  "Open treemacs at current projectile project root.
Forces re-root even if treemacs was already open on a different project."
  (interactive)
  (if (projectile-project-root)
      (treemacs-add-and-display-current-project-exclusively)
    (treemacs)))

;; SPC f で treemacs を起動 (leaf の :bind は eval-after-load でラップされるため
;; treemacs 未ロード時にキーが無効になる → 直接 define-key する)
(evil-define-key 'normal 'global (kbd "SPC f") #'my/treemacs-show-project)

(leaf treemacs
  :config
  (treemacs-project-follow-mode 1)
  (evil-define-key 'normal 'treemacs-mode-map (kbd "SPC f") #'treemacs))

(leaf treemacs-evil 
  :config
  ;; Neotree 時代のキーバインドを再現
  (define-key evil-treemacs-state-map (kbd "q") #'treemacs-quit)
  (define-key evil-treemacs-state-map (kbd "g") #'treemacs-refresh)
  (define-key evil-treemacs-state-map (kbd "l") #'treemacs-RET-action)
  (define-key evil-treemacs-state-map (kbd "N") #'treemacs-create-file)
  (define-key evil-treemacs-state-map (kbd "K") #'treemacs-create-dir)
  (define-key evil-treemacs-state-map (kbd "D") #'treemacs-delete)
  (define-key evil-treemacs-state-map (kbd "M") #'treemacs-rename)
  (define-key evil-treemacs-state-map (kbd "H") #'treemacs-toggle-hidden-files))

;; Treemacs x Perspective integration
;; 使うときは (treemacs-perspective-mode 1) を明示的に有効化
(leaf treemacs-perspective
  :after (treemacs perspective))

;; Translate
(leaf google-translate
  :require t
  :custom
  (google-translate-translation-directions-alist . '(("en" . "ja")
                                                     ("ja" . "en"))))
;; Wakatime
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
  (setq migemo-dictionary "~/.migemo/utf-8/migemo-dict") 
  (setq migemo-user-dictionary nil)
  (setq migemo-regex-dictionary nil)
  (setq migemo-coding-system 'utf-8-unix)

  ;; Evil の / 検索でも migemo を効かせる
  (with-eval-after-load 'evil
    (advice-add 'evil-isearch-function :around
		(lambda (orig-fun)
		  (if migemo-isearch-enable-p
		      (migemo-search-fun-function)
		    (funcall orig-fun))))))

;; direnv
(leaf direnv
  :config
  (direnv-mode))

(leaf nyan-mode
  :config
  (add-hook 'server-after-make-frame-hook
            (lambda ()
	      (when (display-graphic-p)
                (nyan-mode 1)))))

;; Snippets
(leaf tempel
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
                                  (setq-local completion-at-point-functions
					      (cons #'tempel-complete
                                                    completion-at-point-functions))))

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

  (push '(number . +grugru--getter-number) grugru-getter-alist)

  (grugru-define-global
   'number
   (lambda (arg &optional rev)
     (let ((num (string-to-number arg)))
       (number-to-string (if rev (- num 1) (+ num 1)))))))

(leaf sublimity)

(leaf iscroll)

(leaf folding-mode
  :if (locate-library "folding-mode")
  :require t)

(leaf rg)

(leaf open-junk-file
  :custom
  (open-junk-file-format . "/tmp/junk/%Y_%m_%d_%H%M%S.")
  :bind (("C-x j" . open-junk-file)))

(leaf fold-this)

(leaf alert
  :config
  (setq alert-default-style 'libnotify))

(leaf aas
  ;; :hook (text-mode . aas-activate-for-major-mode)
  :init
  (with-eval-after-load 'aas
    (aas-set-snippets 'global)
    (aas-set-snippets 'markdown-mode)
    (aas-set-snippets 'prog-mode)))

;; AI
(defvar openrouter-apikey nil "OpenRouter API key.")
(defvar figma-apikey nil "Figma API key.")

;; authinfo.gpg の復号に Emacs 組み込みの auth-source を使用。
;; gpg-agent のキャッシュと連携し、キャッシュがない時はミニバッファで
;; パスワード入力を求める。一度入力すれば gpg-agent がキャッシュする。
;; loopback モードにより pinentry-qt ではなく Emacs minibuffer を使用。
(setq epg-pinentry-mode 'loopback)

(defvar my/auth-source-cache nil
  "Alist of (machine . password) parsed from authinfo.gpg.")

(defun my/authinfo-parse ()
  "Parse ~/.authinfo.gpg into my/auth-source-cache.
Uses Emacs built-in auth-source which integrates with EPA for GPG decryption.
Returns t on success, nil on failure (e.g. user cancelled passphrase prompt)."
  (condition-case err
      (progn
        ;; authinfo.gpg を auth-sources に一時設定して復号
        (let ((auth-sources '("~/.authinfo.gpg"))
              (auth-source-do-cache nil))
          (setq my/auth-source-cache
                (mapcar
                 (lambda (entry)
                   (let* ((mach (plist-get entry :host))
                          (secret (plist-get entry :secret))
                          (pass (if (functionp secret)
                                    (funcall secret)
                                  secret)))
                     (cons mach pass)))
                 (auth-source-search :max 100 :require '(:secret))))
          t))
    (quit (message "authinfo.gpg の復号がキャンセルされました")
          nil)
    (error (message "authinfo.gpg の復号に失敗: %s" (error-message-string err))
           nil)))

(defun get-secret (key)
  "Retrieve secret for KEY from cached authinfo.
On first call, parses ~/.authinfo.gpg (may prompt for GPG passphrase)."
  (unless my/auth-source-cache
    (my/authinfo-parse))
  (cdr (assoc key my/auth-source-cache)))

;; ECA
(leaf eca
  :require t
  :config
  (setq eca-custom-command '("~/.bin/eca")))

(leaf mcp
  :after gptel)

(leaf gptel-integration
  :after mcp)

(defvar my/gptel-opencode-configured nil)

(defun my/gptel-setup-opencode-backend ()
  "Configure gptel to use OpenCode Go backend.
Must be called after `opencode-go-apikey' is set."
  (when (and (boundp 'opencode-go-apikey) opencode-go-apikey
             (not my/gptel-opencode-configured))
    (setq gptel-model 'deepseek-v4-flash
          gptel-backend (gptel-make-openai "OpenCode Go"
                          :host "opencode.ai"
                          :endpoint "/zen/go/v1/chat/completions"
                          :stream t
                          :key opencode-go-apikey
                          :models '(deepseek-v4-flash
                                    deepseek-v4-pro
                                    kimi-k2.5
                                    kimi-k2.6
                                    qwen3.7-plus
                                    glm-5.1
                                    glm-5.2
                                    mimo-v2.5
                                    mimo-v2.5-pro
                                    minimax-m2.7)))
    (setq my/gptel-opencode-configured t)))

;; デーモン起動時に1回だけ全APIキーを読み込む（フレーム生成のたびに
;; gpg --decrypt が走るのを防ぐ）
(defun my/load-secrets ()
  "Load all API keys from authinfo.gpg once at daemon startup."
  (setenv "GEMINI_API_KEY" (get-secret "gemini.google.com"))
  (setenv "OPENROUTER_API_KEY" (get-secret "openrouter.ai"))
  (setenv "ZAI_API_KEY" (get-secret "z.ai"))
  (setq wakatime-api-key (get-secret "wakatime"))
  (setq openrouter-apikey (get-secret "openrouter.ai"))
  (setq opencode-go-apikey (get-secret "opencode"))
  (setq gemini-apikey (get-secret "gemini.google.com"))
  (setq figma-apikey (get-secret "figma-apikey"))
  (setq claude-shell-api-token (get-secret "openrouter.ai"))
  (setq smudge-oauth2-client-secret (get-secret "spotify-secret"))
  (setq smudge-oauth2-client-id (get-secret "spotify-id"))
  (my/gptel-setup-opencode-backend))
(my/load-secrets)

(leaf gptel
  :config
  (setq gptel-send-key (kbd "C-j"))
  ;; 初回読み込み時に既に API key が設定済みなら即座にbackendを構成
  (my/gptel-setup-opencode-backend)

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

  )

(leaf gptel-integrations
  :after gptel
  :init
  (require 'gptel-integrations))

;; AI codeing
(leaf aider
  :require t
  :custom
  ((aider-args . '("--watch-files" "--model" "zai/glm-4.5"))))

(leaf aidermacs
  :require t
  :custom
  ((aidermacs-default-model . "zai/glm-4.5")
   (aidermacs-watch-files . t))
  :config
  (setq aidermacs-watch-files t)
  (setq aidermacs-extra-args '("--yes-always" "--model" "zai/glm-4.5"))
  (setq aidermacs-backend 'vterm))

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
            ("serena" . (:command "uvx" :args ("--from" "git+https://github.com/oraios/serena" "serena" "start-mcp-server")))))))

;; :hook (server-after-make-frame-hook . #'mcp-hub-start-all-server)

;; minimap: デフォルト無効化（常時表示はredisplayの倍増を引き起こす）
(leaf minimap
  :custom ((minimap-window-location . 'right)
           (minimap-minimum-width . 20)
           (minimap-major-modes . '(prog-mode
                                    markdown-mode
                                    html-mode
                                    fundamental-mode)))
  :bind ("C-x m" . minimap-mode))

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

;; Zenn CLI
(defvar zenn-cli-executable "zenn")

(defun zenn-cli--project-root ()
  (or (and (fboundp 'projectile-project-root)
           (ignore-errors (projectile-project-root)))
      default-directory))

(defun zenn-cli-p ()
  (let ((root (zenn-cli--project-root)))
    (or (file-directory-p (expand-file-name "articles" root))
        (file-directory-p (expand-file-name "books" root))
        (and (file-exists-p (expand-file-name "package.json" root))
             (with-temp-buffer
	       (insert-file-contents (expand-file-name "package.json" root))
	       (search-forward "zenn-cli" nil t))))))

(defmacro zenn-cli--with-check (&rest body)
  `(if (zenn-cli-p)
       (progn ,@body)
     (message "このディレクトリはZennリポジトリではありません。`zenn init' で初期化してください。")))

(defun zenn-cli--build-args (&rest flag-val-pairs)
  "Build CLI arg string from alternating FLAG VALUE pairs.
VALUE can be nil (skip), t (flag only), or a non-empty string (flag + value)."
  (let (parts)
    (while flag-val-pairs
      (let ((flag (pop flag-val-pairs))
            (val  (pop flag-val-pairs)))
        (cond
         ((null val))
         ((eq val t) (push flag parts))
         ((and (stringp val) (not (string-empty-p val)))
          (push (concat flag " " (shell-quote-argument val)) parts)))))
    (string-join (nreverse parts) " ")))

(defun zenn-cli--run (subcmd args)
  (let ((default-directory (zenn-cli--project-root))
        (cmd (concat zenn-cli-executable " " subcmd
                     (if (string-empty-p args) "" (concat " " args)))))
    (compile cmd)))

(defun zenn-cli--run-async (subcmd args)
  (let ((default-directory (zenn-cli--project-root))
        (cmd (concat zenn-cli-executable " " subcmd
                     (if (string-empty-p args) "" (concat " " args))))
        (buf (format "*zenn %s*" subcmd)))
    (async-shell-command cmd buf)
    (message "zenn %s を起動しました" subcmd)))

(defun zenn-cli-init ()
  (interactive)
  (let ((default-directory (zenn-cli--project-root)))
    (compile (concat zenn-cli-executable " init"))))

(defun zenn-cli-preview ()
  (interactive)
  (zenn-cli--with-check
   (let* ((port  (read-string "ポート番号 (デフォルト: 8000): "))
          (host  (read-string "ホスト名 (省略可): "))
          (open  (y-or-n-p "起動時にブラウザを開く? "))
          (watch (y-or-n-p "ホットリロードを有効にする? "))
          (args  (zenn-cli--build-args
                  "--port"  (if (string-empty-p port) nil port)
                  "--host"  (if (string-empty-p host) nil host)
                  "--open"  (if open t nil)
                  "--no-watch" (if watch nil t))))
     (zenn-cli--run-async "preview" args))))

(defun zenn-cli-new-article ()
  (interactive)
  (zenn-cli--with-check
   (let* ((slug  (read-string "スラッグ (12〜50字, 省略可): "))
          (title (read-string "タイトル (省略可): "))
          (type  (completing-read "タイプ: " '("tech" "idea") nil t))
          (emoji (read-string "絵文字 (1文字, 省略可): "))
          (pub   (y-or-n-p "公開設定を true にする? "))
          (pubname (read-string "Publication名 (省略可): "))
          (args  (zenn-cli--build-args
                  "--slug"             (if (string-empty-p slug) nil slug)
                  "--title"            (if (string-empty-p title) nil title)
                  "--type"             (if (string-empty-p type) nil type)
                  "--emoji"            (if (string-empty-p emoji) nil emoji)
                  "--published"        (if pub "true" "false")
                  "--publication-name" (if (string-empty-p pubname) nil pubname))))
     (zenn-cli--run "new:article" args))))

(defun zenn-cli-new-book ()
  (interactive)
  (zenn-cli--with-check
   (let* ((slug    (read-string "スラッグ (12〜50字, 省略可): "))
          (title   (read-string "タイトル (省略可): "))
          (summary (read-string "紹介文 (省略可): "))
          (price   (read-string "価格 (0 または 200〜5000, 省略可): "))
          (pub     (y-or-n-p "公開設定を true にする? "))
          (args    (zenn-cli--build-args
                    "--slug"      (if (string-empty-p slug) nil slug)
                    "--title"     (if (string-empty-p title) nil title)
                    "--summary"   (if (string-empty-p summary) nil summary)
                    "--price"     (if (string-empty-p price) nil price)
                    "--published" (if pub "true" "false"))))
     (zenn-cli--run "new:book" args))))

(defun zenn-cli-list-articles ()
  (interactive)
  (zenn-cli--with-check
   (let* ((fmt  (completing-read "フォーマット (省略可): " '("" "tsv" "json") nil t))
          (args (zenn-cli--build-args "--format" (if (string-empty-p fmt) nil fmt))))
     (zenn-cli--run "list:articles" args))))

(defun zenn-cli-list-books ()
  (interactive)
  (zenn-cli--with-check
   (let* ((fmt  (completing-read "フォーマット (省略可): " '("" "tsv" "json") nil t))
          (args (zenn-cli--build-args "--format" (if (string-empty-p fmt) nil fmt))))
     (zenn-cli--run "list:books" args))))

(defun zenn-cli-version ()
  (interactive)
  (message "%s" (string-trim
                 (shell-command-to-string (concat zenn-cli-executable " --version")))))

(pretty-hydra-define zenn-cli-hydra
  (:separator "-" :title "Zenn CLI" :foreign-key warn :quit-key "q" :exit t)
  ("New"
   (("a" zenn-cli-new-article "新しい記事")
    ("b" zenn-cli-new-book    "新しい本"))

   "List"
   (("la" zenn-cli-list-articles "記事一覧")
    ("lb" zenn-cli-list-books    "本一覧"))

   "Other"
   (("p" zenn-cli-preview "プレビュー")
    ("i" zenn-cli-init    "初期化")
    ("v" zenn-cli-version "バージョン"))))

(define-key evil-normal-state-map (kbd "SPC z") #'zenn-cli-hydra/body)

(leaf verb
  :require t)

(leaf quickrun
  :require t
  :config
  (quickrun-add-command "gleam"
    '((:command . "gleam")
      (:exec    . ("gleam run"))
      (:remove  . ("build")))
    :default "gleam"))

(leaf smartchr
  :require t
  :config
  (define-key evil-insert-state-map (kbd ">")
	      (smartchr '( ">" "-> " "|>" "<>" "<-"))))

(leaf smudge
  :require t)

(leaf ox-typst
  :after org-mode)

(leaf agent-shell
  :init
  ;; テキストバッファ（ファイル）を初めて開いた時に agent-shell をロード
  (defun my/load-agent-shell-once ()
    (require 'agent-shell)
    (remove-hook 'find-file-hook #'my/load-agent-shell-once))
  (add-hook 'find-file-hook #'my/load-agent-shell-once)
  :hook
  (agent-shell-mode-hook . (lambda ()
                             (setq bidi-inhibit-bpa t)
                             (setq bidi-display-reordering nil)))
  :config
  (setq agent-shell-opencode-default-model-id "opencode-go/deepseek-v4-pro")
  (setq agent-shell-anthropic-authentication
	(agent-shell-anthropic-make-authentication :login t))
  (setq agent-shell-anthropic-claude-acp-command
	`("env" "--unset=CLAUDECODE" ,(executable-find "claude-agent-acp")))
  (setq agent-shell-anthropic-claude-environment
	`(,(format "CLAUDE_CODE_EXECUTABLE=%s"
		   (expand-file-name "~/.nix-profile/bin/.claude-wrapped"))))
  ;; evil に奪われるので evil-define-key で設定
  ;; RET で改行、C-j で送信
  (evil-define-key 'insert agent-shell-mode-map
    (kbd "RET") #'newline
    (kbd "C-j") #'shell-maker-submit)

  (evil-define-key 'normal agent-shell-mode-map
    (kbd "C-h") #'agent-shell-help-menu))

;; Claude code
(leaf claude-code
  :hook
  ((claude-code--start . sm-setup-claude-faces)))

(leaf claude-shell
  :require t)

(leaf dirvish)

(leaf sparql-mode)

(leaf claudemacs
  :bind ((:evil-normal-state-map
          ("SPC c" . claudemacs-transient-menu))))

(leaf exec-path-from-shell
  :require t
  :init
  (exec-path-from-shell-initialize)) 

(leaf emmet-mode
  :config
  (evil-define-key 'insert emmet-mode-keymap (kbd "C-l") 'emmet-expand-line)
  :hook
  (html-ts-mode . emmet-mode))

(leaf apheleia
  :require t
  :init
  (apheleia-global-mode +1))

(leaf gerbil-mode
  :hook ((inferior-scheme-mode-hook . gambit-inferior-mode)))

(leaf tramps3
  :require t)

(leaf consult-ghq
  :require t)

;; Dashboard: ランダム画像表示のためのヘルパー関数
(defvar my/dashboard-image-dir (expand-file-name "~/Pictures/shinycolors-jacket")
  "Directory containing dashboard banner images.")

(defvar my/dashboard-image-cache nil
  "Cached list of full paths to image files in `my/dashboard-image-dir'.")

(defun my/dashboard-image-list ()
  "Return cached list of image file paths under `my/dashboard-image-dir'.
Rebuilds cache when nil or invalid (e.g. stale non-list value)."
  (unless (and my/dashboard-image-cache (listp my/dashboard-image-cache))
    (setq my/dashboard-image-cache
          (when (file-directory-p my/dashboard-image-dir)
            (directory-files my/dashboard-image-dir t
                             "\\.\\(jpg\\|jpeg\\|png\\|webp\\)\\'"))))
  (when (listp my/dashboard-image-cache)
    my/dashboard-image-cache))

(defun my/dashboard-random-image ()
  "Return a random image path from `my/dashboard-image-dir'.
Returns nil when directory is empty or missing."
  (when-let* ((files (my/dashboard-image-list))
	      (_ (not (null files))))
    (nth (random (length files)) files)))

(defun my/dashboard-on-banner-p ()
  "Return non-nil if point is on or near the dashboard banner image.
Scans up to 10 characters around point to find an image display property."
  (cl-loop for offset from -10 to 10
           for pos = (+ (point) offset)
           when (and (> pos (point-min)) (< pos (point-max)))
           thereis (when-let ((display (get-char-property pos 'display)))
                     (imagep display))))

(defun my/dashboard-randomize-banner ()
  "Set a new random banner image and refresh the dashboard."
  (interactive)
  (when-let ((img (my/dashboard-random-image)))
    (setq dashboard-startup-banner img)
    (setq dashboard-banner-logo-title (or (my/dashboard-album-name) "SHINY COLORS"))
    (dashboard-refresh-buffer)))

(defun my/dashboard-album-name ()
  "Extract album name from `dashboard-startup-banner' filename.
Format: ALBUM__TRACK.jpg → \"ALBUM\" (underscores replaced with spaces).
When ALBUM is \"OTHER\" or \"アニメ\", extract the song name instead."
  (when-let* ((banner dashboard-startup-banner)
	      (fname (file-name-base banner))
	      (sep-pos (string-match "__" fname))
	      (prefix (substring fname 0 sep-pos))
	      (track  (substring fname (+ sep-pos 2)))
	      (name   (cond
		       ((string= prefix "アニメ")
                        ;; 最後の[...]内の曲名を抽出
                        (if (string-match "\\[\\([^]]*\\)\\][^]]*$" track)
                            (match-string 1 track)
                          track))
		       ((string= prefix "OTHER") track)
		       (t prefix))))
    (replace-regexp-in-string "_" " " name)))

(setq my/dashboard-welcome-messages
      '("Hello, World!"
        "Welcome back!"
        "Happy Hacking!"))

(defun my/dashboard-reload-welcome ()
  "Reload `dashboard-footer-messages' from `my/dashboard-welcome-messages' and refresh."
  (interactive)
  (setq dashboard-footer-messages my/dashboard-welcome-messages)
  (when-let ((buf (get-buffer dashboard-buffer-name)))
    (with-current-buffer buf
      (let ((inhibit-read-only t))
        (dashboard-refresh-buffer))))
  (message "Welcome messages reloaded"))

(defun my/dashboard-update-banner-title ()
  "Set `dashboard-banner-logo-title' based on the current banner image."
  (setq dashboard-banner-logo-title (or (my/dashboard-album-name) "SHINY COLORS")))

(leaf dashboard
  :require t
  :config
  (setq dashboard-startup-banner (or (my/dashboard-random-image)
                                     (expand-file-name "~/Pictures/shinycolors-jacket/BRILLI@NT_WING__BRILLI@NT_WING_04_夢咲きAfter_school.jpg")))
  (my/dashboard-update-banner-title)
  ;; ウェルカムメッセージ（フッター）
  (setq dashboard-footer-messages my/dashboard-welcome-messages)
  ;; 全ジャケットを幅300pxに統一（高さはアスペクト比で自動計算）
  (setq dashboard-image-banner-max-width 0)
  (setq dashboard-image-banner-max-height 0)
  (setq dashboard-image-extra-props '(:width 300))
  ;; webp がアニメーション扱いでサイズ指定を無視されるのを防ぐ
  (advice-add 'dashboard--image-animated-p :override
	      (lambda (path) (eq 'gif (image-type path))))
  ;; RET: バナー画像上 → ランダム切替 / agenda項目 → ファイルを開く / それ以外 → evil標準動作
  (with-eval-after-load 'evil
    (evil-define-key 'normal dashboard-mode-map (kbd "RET")
      (lambda ()
        (interactive)
        (cond
         ((my/dashboard-on-banner-p)
          (my/dashboard-randomize-banner))
         ((get-text-property (point) 'dashboard-agenda-file)
          (let ((file (get-text-property (point) 'dashboard-agenda-file))
                (loc (get-text-property (point) 'dashboard-agenda-loc)))
            (when (and file (numberp loc))
	      (let ((buffer (find-file-other-window file)))
                (with-current-buffer buffer
                  (goto-char loc)
                  (recenter-top-bottom))))))
         (t
          (call-interactively #'evil-ret)))))))

(leaf minimal-dashboard
  :require t
  :config
  (setq minimal-dashboard-buffer-name "Dashboard")
  (setq minimal-dashboard-image-path "~/Pictures/image/hokura.jpg")
  (setq minimal-dashboard-text "Welcome to Emacs!")
  (setq minimal-dashboard-image-scale 0.3)
  (setq minimal-dashboard-enable-resize-handling t)
  (setq minimal-dashboard-modeline-shown nil)
  (setq minimal-dashboard--cached-text nil))

;; フレーム新規作成時にdashboardを表示（scratchpadフレームは除外）
;; emacsclient -c -F '((name . "emacs-scratch"))' で起動したフレームは
;; scratchバッファのままにする
(defun my/after-make-frame-show-dashboard (&optional frame)
  "Show dashboard in new FRAME, unless it's the scratchpad frame.
Picks a random banner image each time."
  (let ((f (or frame (selected-frame))))
    (unless (string= (frame-parameter f 'name) "emacs-scratch")
      (with-selected-frame f
        ;; 古い dashboard バッファを破棄して完全に再生成
        (when-let ((buf (get-buffer "*dashboard*")))
          (kill-buffer buf))
        ;; 起動ごとにランダムな画像を選択 & アルバム名を表示
        (when-let ((img (my/dashboard-random-image)))
          (setq dashboard-startup-banner img))
        (my/dashboard-update-banner-title)
        (dashboard-refresh-buffer)))))

;; フレーム生成時に dashboard を表示（alpha-background の可視化より先に
;; コンテンツを準備するため、prepend で先頭に追加）
(add-hook 'server-after-make-frame-hook #'my/after-make-frame-show-dashboard)

;; ================ my extentions ================

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
(defun ghq-create-project (project-name)
  (interactive "sghq directory name: ")
  (let ((cmd (mapconcat #'shell-quote-argument
			(list "ghq" "create" project-name)
			" ")))
    (shell-command-to-string cmd)))

(defun is-node-project ()
  (file-exists-p (expand-file-name "package.json" (project-root (project-current)))))                       

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
    (shell-command (concat "open " "'" url "'"))))

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

;; Display character count in modeline
(defun update-buffer-char-count ()
  (interactive)
  (format " [%d] " (buffer-size)))

(defun mode-line-time ()
  ;; 更新間隔を60秒に設定（毎秒更新はtimer-event-handlerの負荷になる）
  (setq display-time-interval 60)
  (setq display-time-string-forms
	'((format "%s/%s %s:%s" (string-to-number month) (string-to-number day) 24-hours minutes seconds)))
  (setq display-time-day-and-date t)
  (display-time-mode t))

(defun mode-line-format-update ()
  (interactive)
  (setq-default mode-line-format
                (append (default-value 'mode-line-format)
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
  (find-file (or user-init-file
                 (expand-file-name "init.el" user-emacs-directory))))

(defun toggle-truncate-lines ()
  "折り返し表示をトグル動作します."
  (interactive)
  (if truncate-lines
      (setq truncate-lines nil)
    (setq truncate-lines t))
  (recenter))

;; ================ My configuratons ================ 

(leaf server
  :require t
  :init
  (unless (server-running-p)
    (server-start)))

(setq browse-url-browser-function 'browse-url-firefox)

;; Enable auto revert（全体ではなく必要なモードのみ個別有効化）
;; (global-auto-revert-mode 1)  ;; 全バッファ監視は負荷が高い
;; 必要に応じて dired-mode / vterm などで個別に有効化

;; load-path
(push "~/.emacs.d/lisp/my-package" load-path)

;; Ediff
(setq ediff-window-setup-function 'ediff-setup-windows-plain)

;; Font
(push '(font . "UDEV Gothic NF-14") default-frame-alist)

;; For auth-info
;; Emacs 30 では auth-source-backend の EIEIO 初期化に互換性問題があるため
;; auth-sources の明示的設定を削除（デフォルト動作に任せる）
;; (setq auth-sources '("~/.emacs.d/.authinfo.gpg"))
(setq create-lockfiles nil)

;; scratch バッファの初期メジャーモード
(setq initial-major-mode 'emacs-lisp-mode)
;; デーモンでは scratch バッファが init.el 読み込み前に作成されるため、
;; 既存の *scratch* も明示的に emacs-lisp-mode に変更
(with-current-buffer "*scratch*"
  (emacs-lisp-mode))

;; ================================================
;; パフォーマンス最適化設定
;; ================================================

;; redisplay最適化（最大の問題: redisplay_internal が70%のCPUを消費）
;; redisplay-skip-fontification-on-input は lsp-mode の補完 UI に干渉するため無効化
;; (setq redisplay-skip-fontification-on-input t)
(setq fast-but-imprecise-scrolling t)           ; スクロール中の精度より速度を優先

;; jit-lock最適化（シンタックスハイライトの遅延処理）
(setq jit-lock-stealth-time 1.0)     ; アイドル時のバックグラウンド処理開始を遅らせる
(setq jit-lock-stealth-nice 0.2)     ; バックグラウンド処理の間隔
;; jit-lock-defer-time は補完（corfu/eglot）の表示タイミングに干渉するため無効化
;; (setq jit-lock-defer-time 0.1)
(setq jit-lock-chunk-size 1000)      ; 一度に処理するチャンクサイズ

;; スクロール最適化
(setq scroll-conservatively 101)
(setq scroll-margin 0)
(setq scroll-preserve-screen-position t)

;; フレームのリサイズを抑制（redisplayの原因）
(setq frame-inhibit-implied-resize t)
(setq frame-resize-pixelwise t)

;; GC: gcmh ライクな管理（入力中は高閾値、アイドル時にGC実行）
(defvar my/gc-high-threshold (* 128 1024 1024) "入力中のGC閾値")
(defvar my/gc-low-threshold  (* 8 1024 1024)  "アイドル時のGC閾値")

(defun my/gc-set-high-threshold ()
  "入力中は高閾値にしてGCを抑制。"
  (setq gc-cons-threshold my/gc-high-threshold)
  (when (boundp 'my/gc-idle-timer)
    (when (timerp my/gc-idle-timer)
      (cancel-timer my/gc-idle-timer))
    (setq my/gc-idle-timer nil)))

(defun my/gc-idle-collect ()
  "アイドル時に低閾値+GC実行。"
  (setq gc-cons-threshold my/gc-low-threshold)
  (when (and (fboundp 'memory-use-stats)
             (> (car (memory-use-stats)) (* 32 1024 1024)))
    (garbage-collect))
  (setq my/gc-idle-timer nil))

(defun my/gc-schedule-idle-gc ()
  "5秒間入力がなければアイドルGCをスケジュール。"
  (when (boundp 'my/gc-idle-timer)
    (when (timerp my/gc-idle-timer)
      (cancel-timer my/gc-idle-timer)))
  (setq my/gc-idle-timer (run-with-idle-timer 5 nil #'my/gc-idle-collect)))

(add-hook 'pre-command-hook #'my/gc-set-high-threshold)
(add-hook 'post-command-hook #'my/gc-schedule-idle-gc)

;; For lsp-mode
(setq read-process-output-max (* 1024 1024))

;; Key mapping
(evil-define-key 'normal 'global (kbd "C-o")
  (lambda ()
    (interactive)
    (if (projectile-project-p)
        (projectile-find-file)
      (call-interactively #'find-file))))
(evil-define-key 'normal 'global (kbd "SPC l") #'toggle-truncate-lines)

(global-set-key (kbd "C-c C-r") 'window-resizer)

(define-key global-map (kbd "M-g") 'projectile-persp-switch-project)
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
(add-hook 'org-mode-hook
	  (lambda ()
            (define-key evil-insert-state-map (kbd "C-h") #'org-insert-heading)))

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

(setq warning-minimum-level :error)

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

;; フレーム透過を遅延適用（PGTKでは透過が背景色描画より先に効いて
;; 空っぽの透明窓が数秒表示されるのを防ぐため、default-frame-alist では
;; なく server-after-make-frame-functions でクライアント接続後に設定する）
;; また、visibility . nil でフレームを不可視にしてから表示することで、
;; 背景色が正しく適用される前にフレームが表示されるのを防ぐ（Emacs 30.2 PGTK の既知の問題）
(defun my/apply-alpha-background (&optional frame)
  "Apply alpha-background 85 to FRAME after client connects and buffer is ready."
  (let ((f (or frame (selected-frame))))
    ;; まずフレームを不可視にする
    (set-frame-parameter f 'visibility nil)
    ;; 短い遅延を入れてバッファの準備を待つ
    (run-with-idle-timer 0.05 nil
			 (lambda ()
			   (when (frame-live-p f)
			     (with-selected-frame f
			       ;; 初期バッファを確保（scratch バッファなど）
			       (unless (buffer-name (current-buffer))
				 (switch-to-buffer "*scratch*"))
			       ;; 再描画を強制
			       (redisplay)
			       ;; フレームを可視化
			       (make-frame-visible f)
			       ;; 透過を適用
			       (set-frame-parameter f 'alpha-background 85)))))))

;; server-after-make-frame-hook に登録（emacsclient接続時のみ）
(add-hook 'server-after-make-frame-hook #'my/apply-alpha-background)

;; ================================================

(leaf leaf
  :config
  (leaf leaf-convert)
  (leaf leaf-tree
    :custom ((imenu-list-size . 30)
             (imenu-list-position . 'left))))

(leaf macrostep
  :bind (("C-c e" . macrostep-expand)))

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
	 nano-popup nano-read nano-theme nix-mode nix-ts-mode
	 nyan-mode oauth2 ob-hy open-junk-file orderless org-journal
	 org-modern org-nix-shell org-roam-ui ox-typst ox-zenn plz
	 projectile puni reformatter request rg ruby-electric
	 scala-mode scala-ts-mode sharper shell-maker slime sly-asdf
	 sublimity tempel-collection transient-dwim treesit-auto
	 undo-tree vertico vterm-toggle wakatime-mode web-mode
	 yasnippet-capf yasnippet-snippets yatemplate))
 '(skk-jisyo-edit-user-accepts-editing t))
(custom-set-faces)
