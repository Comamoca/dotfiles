;; -*- lexical-binding: t -*-

;; Nix の emacsWithPackages が全パッケージの load-path を管理しているが、
;; autoload / theme-path の設定には package-initialize が必須。
;; leaf のインストールチェックは Nix 管理のため不要（emacs.nix L517 に含まれる）。
;; treesit-ready-p の事前定義は autoload のエラー防止に必要（Emacs tree-sitter 非対応ビルド用）。
(unless (fboundp 'treesit-ready-p)
  (defalias 'treesit-ready-p (lambda (&rest _) nil)))

(customize-set-variable
 'package-archives '(("org" . "https://orgmode.org/elpa/")
                     ("melpa" . "https://melpa.org/packages/")
                     ("gnu" . "https://elpa.gnu.org/packages/")))
(package-initialize)

(leaf leaf-keywords
  :init
  :config
  (leaf-keywords-init))

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

  ;; posframe などの子フレームが surrogate minibuffer frame を作成する関係で、
  ;; delete-frame 時に "Attempt to delete a surrogate minibuffer frame"
  ;; エラーが発生するのを防ぐ。
  ;; 対象フレームの子フレームを先に削除してから本体を削除する。
  ;; それでも surrogate の関係で削除できない場合は静かにスキップする。
  (advice-add 'delete-frame :around
              (lambda (orig-fun frame &optional force)
                "Delete child frames before deleting FRAME to avoid
surrogate minibuffer frame errors."
                (let ((frame (or frame (selected-frame))))
                  ;; 対象フレームの子フレームを先に削除
                  (dolist (f (frame-list))
                    (when (and (frame-live-p f)
                               (not (eq f frame))
                               (eq (frame-parent f) frame))
                      (let ((delete-frame-functions nil))
                        (ignore-errors (delete-frame f force)))))
                  ;; 本体の削除
                  (condition-case err
                      (funcall orig-fun frame force)
                    (error
                     (unless (string-match-p "Attempt to delete a surrogate minibuffer frame"
                                             (error-message-string err))
                       (signal (car err) (cdr err)))))))))


;; Completion Styles
(leaf orderless)

(leaf hotfuzz)

;; Completing read functions
(leaf consult
  :require t
  :init
  ;; consult-buffer 等は consult ロード済みを前提とするため、
  ;; evil のキーマップが存在してからバインドする（:after evil 相当）
  (with-eval-after-load 'evil
    (define-key evil-normal-state-map (kbd "C-l") #'consult-line)
    (define-key evil-normal-state-map (kbd "SPC i") #'consult-buffer))
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

(leaf ace-window
  :bind ((:evil-normal-state-map
          ("C-w C-w" . ace-window)))
  :config
  (setq aw-keys '(?a ?s ?d ?f ?h ?j ?k ?l)))

;; Structured editing 
(leaf puni
  :bind (("C--" . puni-expand-region)
         (:evil-insert-state-map
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
  ((treesit-auto-install . nil)
   ;; emacs-daemon は --init-directory=/tmp/emacsd-{name} で起動するため
   ;; user-emacs-directory が /tmp 以下になり、treesit のデフォルト検索先
   ;; (user-emacs-directory/tree-sitter) が Nix 管理下の
   ;; ~/.emacs.d/tree-sitter (home.nix の createTreeSitterGrammars 参照) を
   ;; 見なくなる。ここで明示的に加える。
   (treesit-extra-load-path . `(,(expand-file-name "~/.emacs.d/tree-sitter"))))
  :config  
  (global-treesit-auto-mode)
  ;; (treesit-auto-install 'prompt)
  ;; (treesit-auto-add-to-auto-mode-alist 'all)
  )

;; Amber language (.ab) — no tree-sitter grammar / package exists yet,
;; so a minimal derived mode is enough to get lsp-mode to attach.
(define-derived-mode amber-mode prog-mode "Amber"
  "Major mode for editing Amber (.ab) source files."
  (setq-local comment-start "// ")
  (setq-local comment-end ""))

(add-to-list 'auto-mode-alist '("\\.ab\\'" . amber-mode))

;; for envrc
(leaf envrc)

;; Calendar 
(leaf calendar)

;; org-mode
(leaf org
  :after text-mode calendar
  :custom
  ((org-todo-keywords .
		      '((sequence "TODO(t)" "NEXT(n)" "PROG(i)" "WAIT(w@/!)" "|" "DONE(d!)" "CANCELED(c@)")))
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

;; org-mode の改行: electric-indent-mode によって
;; `org-indent-line' がリスト項目の本文位置(2桁)までインデントしてしまい、
;; 続けて "- " を打つとネストが深くなる。現在行のインデントを引き継ぐようにする。
(defun my/org-return-keep-indent ()
  "現在行のインデントを引き継いで改行する `org-return'。
表とソースブロックの中では通常の `org-return' の挙動を保つ。"
  (interactive)
  (if (or (org-at-table-p) (org-in-src-block-p))
      (call-interactively #'org-return)
    (let ((indent (current-indentation)))
      (call-interactively #'org-return)
      (indent-line-to indent))))

(defconst my/org-empty-item-re
  "^[ \t]*\\(?:[-+*]\\|\\(?:[0-9]+\\|[A-Za-z]\\)[.)]\\)\\(?:[ \t]+\\[[ X-]\\]\\)?[ \t]*$"
  "本文が空の箇条書き項目にマッチする。")

(defun my/org-return-list-item ()
  "箇条書きの中で改行したら次の項目を自動で挿入する。
番号付きリストの採番とチェックボックスは `org-insert-item' が引き継ぐ。
本文が空の項目で改行した場合は項目を削除してリストを抜ける。
表とソースブロックの中では通常の `org-return'、
それ以外では `my/org-return-keep-indent' の挙動になる。
箇条書きの中で普通に改行したいときは C-j (`org-return-and-maybe-indent')。"
  (interactive)
  (cond
   ((or (org-at-table-p) (org-in-src-block-p))
    (call-interactively #'org-return))
   ;; 空の項目 → 箇条書きを抜ける
   ((and (org-at-item-p)
         (save-excursion (forward-line 0) (looking-at-p my/org-empty-item-re)))
    (delete-region (line-beginning-position) (line-end-position)))
   ;; 箇条書きの中 → 次の項目を作る (nil が返ったら下の節に落ちる)
   ((and (org-in-item-p) (org-insert-item (org-at-item-checkbox-p))))
   (t (my/org-return-keep-indent))))

(with-eval-after-load 'org
  (define-key org-mode-map (kbd "RET") #'my/org-return-list-item))

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
  :bind (("C-c n r" . org-roam-node-find))
  :config
  (org-roam-db-autosync-mode))

;; Deft
;; For search roam files.
(leaf deft
  :after org-roam-mode
  :custom
  ((deft-extensions . '("txt" "tex" "org"))
   `(deft-directory . ,(expand-file-name "roam" org-directory)))
  :bind ("C-c n d" . deft))

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
  :after org
  :config
  (setq org-modern-list '((?* . "•")
                          (?+ . "•")
                          (?- . "•")))
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
  :after org
  :config
  ;; org ファイルを開いた時に om-dash をロードして
  ;; #+BEGIN: om-dash-* 動的ブロックを解釈できるようにする
  (add-hook 'org-mode-hook #'my/om-dash-load-for-org))

;; om-dash の動的ブロック更新を非同期化するために async を使用する。
;; 関数内で require すると `async-inject-variables' がマクロ展開時に
;; 未定義になるため、トップレベルでロードしておく。
;; パッケージが無い環境（古いビルド）でも init が失敗しないよう
;; エラーを抑制する。async が無い場合は非同期更新が無効になるだけ。
(require 'async nil t)

(defun my/om-dash-schedule-update (buf)
  "Schedule an asynchronous om-dash dynamic block update for BUF.
Defers the update so the buffer is displayed and flycheck's initial
org-lint run has settled before the refresh starts.  Falls back to
the synchronous update when async is not available."
  (require 'om-dash)
  (when (buffer-live-p buf)
    (if (fboundp 'async-start)
        (run-with-idle-timer 0.5 nil #'my/om-dash-async-update-dblocks buf)
      (run-with-idle-timer 0.5 nil #'my/om-dash-update-dblocks buf))))

(defun my/om-dash-update-dblocks (buf)
  "Update all om-dash dynamic blocks in buffer BUF.
flycheck is disabled for the duration of the update and re-enabled
afterwards, so stale org-lint markers from the pre-update text are
discarded."
  (when (buffer-live-p buf)
    (with-current-buffer buf
      (let ((fc-mode (bound-and-true-p flycheck-mode)))
        (when fc-mode (flycheck-mode -1))
        (unwind-protect
            (org-map-dblocks)
          (when fc-mode
            (flycheck-mode 1)
            (flycheck-buffer)))))))

(defvar my/om-dash-async-queue nil
  "Queue of pending om-dash dynamic block update jobs.
Each job is a plist with :buffer and :marker.")

(defvar my/om-dash-async-running-p nil
  "Non-nil when an async block update is currently running.")

(defvar my/om-dash-async-flycheck-buffer nil
  "Buffer whose flycheck mode should be re-enabled after all updates.")

(defun my/om-dash-async-update-dblocks (buf)
  "Update all om-dash dynamic blocks in BUF asynchronously.
Blocks are processed one at a time via `my/om-dash-async-queue' so
that concurrent edits to the buffer are avoided."
  (when (buffer-live-p buf)
    (with-current-buffer buf
      (let ((fc-mode (bound-and-true-p flycheck-mode)))
        (when fc-mode
          (flycheck-mode -1)
          (setq my/om-dash-async-flycheck-buffer buf)))
      (let ((blocks (org-element-map (org-element-parse-buffer) 'dynamic-block
                      (lambda (elem)
                        (when (string-prefix-p "om-dash-"
                                               (org-element-property :block-name elem))
                          elem)))))
        (when blocks
          ;; Drop stale jobs for this buffer so repeated switches don't queue
          ;; duplicate updates.
          (setq my/om-dash-async-queue
                (cl-remove-if (lambda (job)
                                (eq (plist-get job :buffer) buf))
                              my/om-dash-async-queue))
          (dolist (block blocks)
            (push (list :buffer buf
                        :marker (copy-marker (org-element-property :begin block)))
                  my/om-dash-async-queue))
          (setq my/om-dash-async-queue (nreverse my/om-dash-async-queue))
          (my/om-dash-async-process-queue))))))

(defun my/om-dash-async-process-queue ()
  "Start processing the next job in `my/om-dash-async-queue'."
  (while (and my/om-dash-async-queue (not my/om-dash-async-running-p))
    (let* ((job (pop my/om-dash-async-queue))
           (buf (plist-get job :buffer))
           (marker (plist-get job :marker)))
      (if (not (and (buffer-live-p buf) (marker-buffer marker)))
          (setq my/om-dash-async-running-p nil)
        (setq my/om-dash-async-running-p t)
        (my/om-dash-async-update-block buf marker)))))

(defun my/om-dash-async--dynamic-block-p (elem)
  "Return non-nil if ELEM is an om-dash dynamic block."
  (and (eq (org-element-type elem) 'dynamic-block)
       (string-prefix-p "om-dash-" (org-element-property :block-name elem))))

(defun my/om-dash-async-update-block (buf marker)
  "Update the om-dash dynamic block at MARKER in BUF asynchronously.
The block text is processed in a child Emacs process so that
synchronous shell commands used by om-dash do not block the UI."
  (with-current-buffer buf
    (save-excursion
      (goto-char marker)
      (let ((elem (org-element-at-point)))
        (if (not (my/om-dash-async--dynamic-block-p elem))
            (progn
              (setq my/om-dash-async-running-p nil)
              (my/om-dash-async-process-queue))
          (let* ((begin (org-element-property :begin elem))
                 (end (org-element-property :end elem))
                 (block-name (org-element-property :block-name elem))
                 (block-text (buffer-substring begin end))
		 (om-dash-vars (async-inject-variables "\\`om-dash-"))
		 (exec-path-var (async-inject-variables "\\`exec-path\\'"))
		 (load-path-var (async-inject-variables "\\`load-path\\'"))
		 (shell-file-name-var (async-inject-variables "\\`shell-file-name\\'"))
		 (shell-command-switch-var (async-inject-variables "\\`shell-command-switch\\'"))
		 (default-dir default-directory))
            (async-start
             `(lambda ()
                ,load-path-var
                (when (boundp 'native-comp-jit-compilation)
                  (setq native-comp-jit-compilation nil))
                (require 'org)
                (require 'om-dash)
                ,om-dash-vars
                ,exec-path-var
                ,shell-file-name-var
                ,shell-command-switch-var
                (let ((default-directory ,default-dir))
                  (with-temp-buffer
                    ;; Add a dummy heading before the block so that
                    ;; om-dash--choose-level can find a previous heading and
                    ;; does not loop forever in a child process buffer.
                    (insert "* om-dash async dummy\n\n")
                    (insert ,block-text)
                    (org-mode)
                    (org-map-dblocks)
                    ;; Remove the dummy heading before returning the result.
                    (goto-char (point-min))
                    (when (search-forward "* om-dash async dummy\n\n" nil t)
                      (delete-region (point-min) (point)))
                    (substring-no-properties (buffer-string)))))
             (lambda (result)
               (my/om-dash-async-replace-block buf marker block-name result)))))))))

(defun my/om-dash-async-replace-block (buf marker block-name result)
  "Replace the dynamic block at MARKER in BUF with RESULT.
RESULT must be a string produced by `org-map-dblocks' in a child
process.  If the buffer was modified while the update was running,
the replacement is skipped to avoid overwriting user edits."
  (unwind-protect
      (when (and (buffer-live-p buf) (stringp result))
        (with-current-buffer buf
          (unless (buffer-modified-p)
            (save-excursion
              (goto-char marker)
              (let ((elem (org-element-at-point)))
                (when (and (my/om-dash-async--dynamic-block-p elem)
                           (string-equal block-name
                                         (org-element-property :block-name elem)))
                  (let ((inhibit-read-only t))
                    (delete-region (org-element-property :begin elem)
                                   (org-element-property :end elem))
                    (insert result))))))))
    (when (null my/om-dash-async-queue)
      (when (and my/om-dash-async-flycheck-buffer
                 (buffer-live-p my/om-dash-async-flycheck-buffer))
        (with-current-buffer my/om-dash-async-flycheck-buffer
          (flycheck-mode 1)
          (flycheck-buffer))
        (setq my/om-dash-async-flycheck-buffer nil)))
    (setq my/om-dash-async-running-p nil)
    (my/om-dash-async-process-queue)))

(defun my/om-dash-load-for-org ()
  "Load om-dash when an org file is opened, so om-dash-* dynamic blocks work.
Schedules an om-dash dynamic block refresh for the buffer."
  (when (buffer-file-name)
    (my/om-dash-schedule-update (current-buffer))))

;; om-dash の動的ブロック (#+BEGIN: om-dash-github) を org-lint の
;; invalid-block checker が「不完全なブロック」と誤検出し、
;; flycheck 経由で "Wrong type argument: number-or-marker-p" エラーになる。
;; この checker を無効化して誤検出を防ぐ。
(require 'org-lint)
(org-lint-remove-checker 'invalid-block)

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
  (expand-file-name "project" (expand-file-name "~/.ghq/github.com/Comamoca/org"))
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

(defun my/project-notes-slug ()
  "Return the \"owner/repo\" slug for the current project notes file.
Derived from the notes file layout <author>/<repo>.org."
  (let ((dir (directory-file-name (file-name-directory buffer-file-name))))
    (format "%s/%s"
            (file-name-nondirectory dir)
            (file-name-base buffer-file-name))))

(defun my/project-dashboard-blocks (slug)
  "Return the initial om-dash-github dynamic blocks for SLUG (\"owner/repo\")."
  (format "#+BEGIN: om-dash-github :repo \"%s\" :type pullreq :open \"*\" :closed \"-1mo\"
   |-------+-----+---------------+---------------------------|
#+END:

#+BEGIN: om-dash-github :repo \"%s\" :type issue :open \"*\"
#+END:" slug slug))

(defun my/open-project-notes ()
  "Open the org file for the current projectile project.
Creates the file with default headings if it doesn't exist.
Sets `default-directory' to the projectile project root so that
subsequent operations (e.g. org-capture, compile) run in the
project context.  Refreshes om-dash dynamic blocks in the opened
file so dashboards are up to date on every project switch."
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
            (insert (format "#+title: %s\n\n%s\n\n* Tasks\n\n* Notes\n\n"
                            (file-name-base (buffer-file-name))
                            (my/project-dashboard-blocks
                             (my/project-notes-slug)))))
          ;; バッファ表示後に非同期で om-dash ブロックを更新する
          (when (fboundp 'my/om-dash-schedule-update)
            (my/om-dash-schedule-update (current-buffer))))
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

(leaf ghostel)

(leaf vterm
  :config
  (with-eval-after-load 'vterm
    (evil-define-key 'insert vterm-mode-map (kbd "C-l") 'vterm-clear)))

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

;; for textlint — flycheck-define-checker はマクロのため、
;; byte-compile 時には flycheck がロードされていないと正しく展開できない。
;; with-eval-after-load で実行時まで遅延させる。
(with-eval-after-load 'flycheck
  (flycheck-define-checker textlint
    "A linter for prose."
    :command ("textlint" "--format" "unix" source-inplace)
    :error-patterns
    ((warning line-start (file-name) ":" line ":" column ": "
              (id (one-or-more (not (any " "))))
              (message (one-or-more not-newline)
                       (zero-or-more "\n" (any " ") (one-or-more not-newline)))
              line-end))
    :modes (text-mode markdown-mode gfm-mode org-mode web-mode)))

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
  (amber-mode . lsp-deferred)
  :custom
  ((lsp-completion-provider . :none))   ;; :none で company 自動有効化を抑制（capf 経由で corfu が補完を表示）
  :config
  ;; Nix環境向けにlsp serverのパスを追加
  (setq lsp-elixir-server-command
	'("elixir-ls"))
  ;; gc-cons-threshold はグローバルGC管理(my/gc-*)に委譲
  (setq read-process-output-max (* 1024 1024))
  (setq lsp-idle-delay 1.0)
  (setq lsp-after-command-idle-delay 0.5)  ; post-command負荷低減

  (define-key evil-normal-state-map (kbd "K") 'lsp-ui-doc-glance)

  (push '(nix-mode . "nil") lsp-language-id-configuration)
  (push '(python-mode . "python") lsp-language-id-configuration)
  (push '(amber-mode . "amber") lsp-language-id-configuration)
  (with-eval-after-load 'lsp-mode
    (push 'semgrep-ls lsp-disabled-clients)
    (lsp-register-client
     (make-lsp-client :new-connection (lsp-stdio-connection "amber-lsp")
                      :major-modes '(amber-mode)
                      :server-id 'amber-lsp
                      :initialization-options
                      (lambda ()
                        `(:resourcesPath ,(expand-file-name "~/.cache/amber-lsp/resources")))))))

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

;; Auto Formatting — reformatter-define はマクロのため :require t 必須
(leaf reformatter
  :require t
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

;; Hydra — defhydra / pretty-hydra-define はマクロのため :require t 必須
(leaf hydra
  :require t
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
  (with-eval-after-load 'hydra-posframe
    (hydra-posframe-mode 1)))

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
  (dolist (f '("Cargo.toml" "gleam.toml" "flake.nix"))
    (add-to-list 'projectile-project-root-files-bottom-up f))
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
  :bind (("M-g" . projectile-persp-switch-project)
         (:projectile-mode-map
          ("C-c p p" . projectile-persp-switch-project))))

;; プロジェクト切替時のアクションをファイル選択ミニバッファから
;; そのプロジェクトの org ノート (C-c n p) の表示に変更する
;; 注意: projectile はこのアクションを引数なしで funcall する。
;; 呼び出し時には default-directory が新プロジェクトに設定済み。
(setq projectile-switch-project-action #'my/open-project-notes)

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

;; projectile でのプロジェクト切替後に treemacs を追従させる
;; treemacs-project-follow-mode は default-directory の変更に反応するが、
;; projectile-persp-switch-project 経由の切替では確実に発火しないため、
;; projectile の公式フックを使って強制的に再ルートする。
(add-hook 'projectile-after-switch-project-hook
          (defun my/treemacs-follow-project ()
            "After switching project via Projectile, re-root treemacs to the new project."
            (when (and (fboundp 'treemacs-add-and-display-current-project-exclusively)
                       (projectile-project-root))
              (treemacs-add-and-display-current-project-exclusively))))

(leaf treemacs-evil
  :after treemacs
  :config
  (with-eval-after-load 'treemacs-evil
    ;; Neotree 時代のキーバインドを再現
    (define-key evil-treemacs-state-map (kbd "q") #'treemacs-quit)
    (define-key evil-treemacs-state-map (kbd "g") #'treemacs-refresh)
    (define-key evil-treemacs-state-map (kbd "l") #'treemacs-RET-action)
    (define-key evil-treemacs-state-map (kbd "N") #'treemacs-create-file)
    (define-key evil-treemacs-state-map (kbd "K") #'treemacs-create-dir)
    (define-key evil-treemacs-state-map (kbd "D") #'treemacs-delete)
    (define-key evil-treemacs-state-map (kbd "M") #'treemacs-rename)
    (define-key evil-treemacs-state-map (kbd "H") #'treemacs-toggle-hidden-files)))

;; Treemacs x Perspective integration
;; 使うときは (treemacs-perspective-mode 1) を明示的に有効化
(leaf treemacs-perspective
  :after (treemacs perspective))

;; Translate
(leaf google-translate
  :custom
  (google-translate-translation-directions-alist . '(("en" . "ja")
                                                     ("ja" . "en"))))
;; wakatime: 起動時には不要（analytics 目的）なため idle timer で遅延起動
(leaf wakatime-mode
  :init
  (run-with-idle-timer 5 nil
		       (lambda ()
			 (require 'wakatime-mode)
			 (setq wakatime-cli-path (string-trim (shell-command-to-string "which wakatime-cli")))
			 (global-wakatime-mode 1))))

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
   (("<Tab>" . markdown-cycle))))

;; leaf の :hook がパッケージロード済み時に確実に効かないため直接登録する。
;; markdown-ts-mode は markdown-mode から派生していないため両方に登録する。
(defun my/blog-markdown-capf-setup ()
  "Register blog tag completion for markdown buffers."
  (setq-local completion-at-point-functions
              (cons #'my/blog-tag-capf
                    (cons #'cape-emoji completion-at-point-functions))))

(add-hook 'markdown-mode-hook #'my/blog-markdown-capf-setup)
(add-hook 'markdown-ts-mode-hook #'my/blog-markdown-capf-setup)

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
  :custom
  ;; --init-directory=/tmp/emacsd-{name} で起動するため user-emacs-directory が
  ;; /tmp/emacsd-{name} になり、デフォルトの tempel-path では
  ;; テンプレートが見つからない。絶対パスで明示指定する。
  ((tempel-path . "~/.emacs.d/templates"))
  :config 
  (defun tempel-setup-capf ()
    (setq-local completion-at-point-functions
		(cons #'tempel-complete
		      completion-at-point-functions)))

  (add-hook 'conf-mode-hook 'tempel-setup-capf)
  (add-hook 'prog-mode-hook 'tempel-setup-capf)
  (add-hook 'text-mode-hook 'tempel-setup-capf)

  ;; org-mode は独自に completion-at-point-functions を設定するため
  ;; org-mode-hook で確実に tempel を先頭に追加する
  (add-hook 'org-mode-hook #'tempel-setup-capf)

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
  :if (locate-library "folding-mode"))

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
;; デーモン時は GPG パスフレーズプロンプトが init をブロックするため
;; 遅延読み込み（get-secret 初回呼び出し時）。非デーモン時は即時読み込み。
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
(unless (daemonp)
  (my/load-secrets))

(leaf gptel
  :config
  (setq gptel-send-key (kbd "C-j"))
  ;; 初回読み込み時に既に API key が設定済みなら即座にbackendを構成
  (my/gptel-setup-opencode-backend)

  (with-eval-after-load 'gptel
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
     :category "web"))

  )

(leaf gptel-integrations
  :after gptel
  :init
  (require 'gptel-integrations))

;; AI codeing
(leaf aider
  :custom
  ((aider-args . '("--watch-files" "--model" "zai/glm-4.5"))))

(leaf aidermacs
  :custom
  ((aidermacs-default-model . "zai/glm-4.5")
   (aidermacs-watch-files . t))
  :config
  (setq aidermacs-watch-files t)
  (setq aidermacs-extra-args '("--yes-always" "--model" "zai/glm-4.5"))
  (setq aidermacs-backend 'vterm))

;; (aidermacs-default-model . "gemini/gemini-2.5-flash-preview-04-17")


(leaf mcp-hub
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
  :require ox-publish
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
  :after org)

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
  )

;; smudge OAuth 認証時に Firefox で認証画面を開く
(add-to-list 'load-path "~/.emacs.d/lisp")
(require 'smudge-oauth-browser)

(leaf ox-typst
  :after org-mode)

(leaf agent-shell
  :require t
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

(leaf claude-shell)

(leaf dirvish)

(leaf sparql-mode)

(leaf claudemacs
  :bind ((:evil-normal-state-map
          ("SPC c" . claudemacs-transient-menu))))

;; exec-path-from-shell: 外部シェル起動 (~0.3s) を伴うため、
;; 起動時ではなく最初のフレーム作成時（server-after-make-frame-hook）まで遅延。
;; exec-path-from-shell-initialize は一度だけ実行すればよい。
(leaf exec-path-from-shell
  :init
  (defun my/exec-path-from-shell-init-once ()
    "Initialize exec-path-from-shell on first frame, then remove self from hook."
    (require 'exec-path-from-shell)
    (exec-path-from-shell-initialize)
    (remove-hook 'server-after-make-frame-hook #'my/exec-path-from-shell-init-once))
  (add-hook 'server-after-make-frame-hook #'my/exec-path-from-shell-init-once))

(leaf emmet-mode
  :config
  (evil-define-key 'insert emmet-mode-keymap (kbd "C-l") 'emmet-expand-line)
  :hook
  (html-ts-mode . emmet-mode))

(leaf apheleia
  :require t
  :init
  (apheleia-global-mode +1)
  :config
  ;; treefmt は Apheleia に組み込み済み (treefmt --stdin <file>)。
  ;; treefmt-nix の wrapper (home.packages 経由) が PATH に乗っている前提。
  (setf (alist-get 'nix-ts-mode apheleia-mode-alist) '(treefmt)))

(leaf gerbil-mode
  :hook ((inferior-scheme-mode-hook . gambit-inferior-mode)))

(leaf tramps3)

(leaf consult-ghq)

(leaf minions
  :custom ((minions-mode-line-lighter . "[+]"))
  :config (minions-mode 1))

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

;; dashboard: server-after-make-frame-hook から dashboard-refresh-buffer を
;; 呼ぶため、事前にロードが必要
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

;; GUIフレーム生成時に dashboard を表示（TTY の場合は scratch バッファ）
(add-hook 'server-after-make-frame-hook #'my/after-make-frame-show-dashboard)

;; ================ my extentions ================

;; ================================================
;; Blog tag completion
;; YAML frontmatter の tags を Corfu で補完する。
;; 参照: ~/.ghq/github.com/Comamoca/blog/src/blog/*.md
;; ================================================

(require 'yaml)

(defvar my/blog-tags-dir
  (expand-file-name "~/.ghq/github.com/Comamoca/blog/src/blog/")
  "Directory containing blog markdown files.")

(defvar my/blog-tag-cache nil
  "Cached list of blog tags in frequency order.")

(defun my/blog-extract-frontmatter (str)
  "Extract the leading \"---\\n...\\n---\" block from STR.
Return nil when there is no frontmatter."
  (when (string-match-p "\\`---[ \t]*\n" str)
    (let ((end (string-match "\n---[ \t]*\n?" str 3)))
      (when end
        (substring str 4 end)))))

(defun my/blog-read-frontmatter (str)
  "Parse frontmatter string STR into a hash table.
Return nil on parse errors."
  (condition-case nil
      (yaml-parse-string str :object-type 'hash-table :object-key-type 'string)
    (error nil)))

(defun my/blog-tags-from-string (fm)
  "Extract the tags list from frontmatter string FM.
Uses `yaml-parse-string' so both `tags: [\"a\", \"b\"]' and the YAML list
form (`tags:' followed by `- item' lines) are handled.  Returns nil when
there are no tags."
  (when-let* ((table (my/blog-read-frontmatter fm))
              (tags (gethash "tags" table)))
    (cl-remove-if-not #'stringp (append tags nil))))

(defun my/blog-tags-from-file (file)
  "Return the list of tags in the frontmatter of FILE."
  (when-let* ((str (with-temp-buffer
                     (insert-file-contents file)
                     (buffer-string)))
              (fm (my/blog-extract-frontmatter str)))
    (my/blog-tags-from-string fm)))

(defvar my/blog-file-tags-cache (make-hash-table :test #'equal)
  "Per-file tag cache mapping blog post paths to their tag lists.")

(defun my/blog-rebuild-tag-cache ()
  "Rebuild `my/blog-tag-cache' from `my/blog-file-tags-cache'.
Pure aggregation over cached data: no file I/O, so it is cheap."
  (let ((counts (make-hash-table :test #'equal)))
    (maphash (lambda (_file tags)
               (dolist (tag tags)
                 (puthash tag (1+ (gethash tag counts 0)) counts)))
             my/blog-file-tags-cache)
    (setq my/blog-tag-cache
          (mapcar #'cdr
                  (sort (cl-loop for k being the hash-keys of counts
                                 using (hash-values v)
                                 collect (cons v k))
                        (lambda (a b) (> (car a) (car b))))))))

(defun my/blog-refresh-tags ()
  "Scan all blog posts and rebuild `my/blog-tag-cache' by frequency."
  (interactive)
  (clrhash my/blog-file-tags-cache)
  (dolist (file (directory-files-recursively my/blog-tags-dir "\\.md\\'"))
    (puthash file (my/blog-tags-from-file file) my/blog-file-tags-cache))
  (my/blog-rebuild-tag-cache))

(defun my/blog-update-tags-for-file (file)
  "Incrementally update the tag cache for the single blog post FILE."
  (puthash file (my/blog-tags-from-file file) my/blog-file-tags-cache)
  (my/blog-rebuild-tag-cache))

(defun my/blog-buffer-p ()
  "Return non-nil when the current buffer is a blog post."
  (let ((file (buffer-file-name)))
    (and file
         (string-prefix-p (expand-file-name my/blog-tags-dir)
                          (expand-file-name file)))))

(defvar-local my/blog-frontmatter-end-line-cache nil
  "Cached frontmatter end line, invalidated on buffer modification.")

(defun my/blog-frontmatter-end-line ()
  "Return the line number where the frontmatter ends, or nil.
Only the first 64 lines are inspected since frontmatter is always at
the top; the result is cached and invalidated on buffer change."
  (or my/blog-frontmatter-end-line-cache
      (setq my/blog-frontmatter-end-line-cache
            (save-excursion
              (goto-char (point-min))
              (when-let* ((str (buffer-substring
                                (point-min)
                                (min (point-max)
                                     (save-excursion
                                       (forward-line 64)
                                       (point))))))
                (let ((fm (my/blog-extract-frontmatter str)))
                  (when fm
                    (+ 1 (cl-count ?\n fm)))))))))

(defun my/blog-invalidate-frontmatter-cache (_beg _end _len)
  "Invalidate the cached frontmatter end line in blog buffers."
  (when (my/blog-buffer-p)
    (setq my/blog-frontmatter-end-line-cache nil)))

(add-hook 'after-change-functions #'my/blog-invalidate-frontmatter-cache)

(defun my/blog-in-frontmatter-p ()
  "Return non-nil when point is inside the frontmatter."
  (when-let ((end (my/blog-frontmatter-end-line)))
    (<= (line-number-at-pos) end)))

(defun my/blog-tag-bounds ()
  "Return (start . end) of the tag symbol at point in the frontmatter."
  (when (and (my/blog-buffer-p) (my/blog-in-frontmatter-p))
    (save-excursion
      (let ((end (point)))
        (skip-syntax-backward "-w")
        (when (> (point) (point-min))
          (cons (point) end))))))

(defun my/blog-tag-capf ()
  "Complete blog tags from `my/blog-tag-cache' inside the frontmatter."
  (when-let* ((cache my/blog-tag-cache)
              (bounds (my/blog-tag-bounds)))
    (list (car bounds) (cdr bounds) cache :exclusive 'no)))

(defun my/blog-maybe-refresh-tags ()
  "Update the tag cache after saving a blog post.
Only re-parses the saved file (a few milliseconds).  The previous
implementation re-scanned every post via an idle timer, which blocked
Emacs for seconds right after each save."
  (when (my/blog-buffer-p)
    (my/blog-update-tags-for-file (buffer-file-name))))

(add-hook 'after-save-hook #'my/blog-maybe-refresh-tags)

(defun my/blog-ensure-tag-cache ()
  "Build `my/blog-tag-cache' on first blog edit if it is still empty."
  (when (and (my/blog-buffer-p) (null my/blog-tag-cache))
    (run-with-idle-timer 0.5 nil #'my/blog-refresh-tags)))

(add-hook 'find-file-hook #'my/blog-ensure-tag-cache)

;; 起動時に一度だけ遅延構築する (キャッシュが空のままの main デーモン対策)
(run-with-idle-timer 2 nil #'my/blog-refresh-tags)

(defun my/set-pwd-to-project-root ()
  "Set `default-directory` to the root of the current project."
  (when-let ((project (project-current)))
    (setq default-directory (project-root project))))

(add-hook 'find-file-hook #'my/set-pwd-to-project-root)


(defun my/kaho-birthday-days ()
  (let* ((now (current-time))
         (decoded (decode-time now))
         (year (decoded-time-year decoded))
         (target (encode-time 0 0 0 29 7 year)))
    ;; まだ今年の7/29を過ぎていない場合は前年基準
    (if (time-less-p now target)
        (setq target (encode-time 0 0 0 29 7 (1- year))))
    (truncate (/ (float-time (time-subtract now target)) 86400))))

(defconst my/kaho-idol-url
  "https://shinycolors.idolmaster-official.jp/idol/hokagoclimaxgirls/kaho/")

(defun my/kaho-birthday-message ()
  (interactive)
  (insert (format "[小宮果穂](%s)さん、%d日目お誕生日おめでとうございます！"
                  my/kaho-idol-url
                  (my/kaho-birthday-days))))

(defun my/kaho-birthday-message-org ()
  (interactive)
  (insert (format "[[%s][小宮果穂]]さん、%d日目お誕生日おめでとうございます！"
                  my/kaho-idol-url
                  (my/kaho-birthday-days))))


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

;; gitmoji データのロードは init 中でなく、最初の git-commit-mode で遅延実行
(defun gitmoji-completion ()
  (unless (boundp 'gitmoji--codes)
    (setq gitmoji--codes (setup-gitmoji-data)))
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
                          (:eval smudge-controller-player-status)
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
  (find-file (if (file-exists-p user-init-file)
                 user-init-file
               (expand-file-name "init.el" "~/.emacs.d"))))

(defun toggle-truncate-lines ()
  "折り返し表示をトグル動作します."
  (interactive)
  (if truncate-lines
      (setq truncate-lines nil)
    (setq truncate-lines t))
  (recenter))

(leaf minimail
  :config
  (setq minimail-accounts
	'((gmail ;; This can be any symbol you like to identify the account
           :mail-address "comamoca.dev@gmail.com"
           :incoming-url "imaps://imap.gmail.com"))
	mail-user-agent 'minimail
	message-server-alist
	'()))

;; ================ My configuratons ================ 

(leaf server
  :require t
  :init
  (unless (daemonp)
    (unless (server-running-p)
      (server-start))))

(setq browse-url-browser-function 'browse-url-firefox)
;; Firefox on Wayland + Niri: --new-window が確実
(setq browse-url-firefox-arguments '("--new-window"))

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

;; Custom modeline — smudge (Spotify) は遅延ロードのため、初回ロード時に有効化
(mode-line-format-update)
(eval-after-load 'smudge
  '(smudge-controller-start-player-status-timer))

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
;; daemon 起動時 (systemd) に正しい値が入っていれば上書きしない
(setenv "WAYLAND_DISPLAY" (or (getenv "WAYLAND_DISPLAY") "wayland-1"))

(setq wl-copy-process nil)
(defun wl-copy (text)
  (setq wl-copy-process (make-process :name "wl-copy"
				      :buffer nil
				      :noquery t
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

;;; 画像クリップボード (Krita などへの画像貼り付け用)
;; interprogram-cut-function はテキストしか扱えないため、画像は
;; wl-copy で image/* MIME として直接コピーする。
;; Wayland クリップボード → XWayland (Krita 等) への画像受け渡しは
;; niri のクリップボード同期が MIME を透過するのでこの方式で動作する。
(defvar wl-copy-image-mime-alist
  '(("png"  . "image/png")
    ("jpg"  . "image/jpeg")
    ("jpeg" . "image/jpeg")
    ("gif"  . "image/gif")
    ("webp" . "image/webp")
    ("bmp"  . "image/bmp")
    ("tif"  . "image/tiff")
    ("tiff" . "image/tiff"))
  "画像拡張子と MIME タイプの対応表。")

(defun wl-copy-image (file)
  "FILE の画像を Wayland クリップボードへ image/* としてコピーする。
未対応形式は ffmpeg で PNG に変換してからコピーする。
wl-copy は stdin を読み切ると fork してクリップボードを保持し続ける。"
  (interactive "f画像ファイル: ")
  (unless (and (file-readable-p file) (file-regular-p file))
    (user-error "画像ファイルを読み込めません: %s" file))
  (let* ((ext (downcase (or (file-name-extension file) "")))
         (mime (cdr (assoc ext wl-copy-image-mime-alist)))
         (src file)
         (cleanup nil))
    (unless mime
      (setq src (make-temp-file "wl-copy-img-" nil ".png")
            cleanup t)
      (unless (zerop (call-process "ffmpeg" nil nil nil
                                   "-y" "-loglevel" "error"
                                   "-i" file "-frames:v" "1" src))
        (delete-file src)
        (user-error "ffmpeg での変換に失敗しました: %s" file))
      (setq mime "image/png"))
    ;; wl-copy は親プロセスが stdin を読み切って fork してから終了するため、
    ;; その後に一時ファイルを削除してよい
    (start-process "wl-copy-image" nil "sh" "-c"
                   (format "wl-copy -t %s < %s%s"
                           mime (shell-quote-argument src)
                           (if cleanup
                               (format " && rm -f %s"
                                       (shell-quote-argument src))
                             "")))
    (message "画像をクリップボードにコピーしました: %s" file)))

(defun wl-copy-image-from-dired ()
  "dired のカーソル位置 (またはマーク) の画像をクリップボードへコピーする。"
  (interactive)
  (wl-copy-image (dired-get-file-for-visit)))

(defun org-copy-image-at-point ()
  "ポイント位置の org リンクが指す画像をクリップボードへコピーする。"
  (interactive)
  (require 'org-element)
  (let ((path (org-element-property :path (org-element-context))))
    (setq path (and path (expand-file-name path)))
    (unless (and path (file-regular-p path))
      (user-error "ここには画像ファイルがありません"))
    (wl-copy-image path)))

(with-eval-after-load 'dired
  (define-key dired-mode-map (kbd "C-c C-w") #'wl-copy-image-from-dired))
(with-eval-after-load 'org
  (define-key org-mode-map (kbd "C-c C-i") #'org-copy-image-at-point))

;; フレーム透過を遅延適用（PGTKでは透過が背景色描画より先に効いて
;; 空っぽの透明窓が数秒表示されるのを防ぐため、default-frame-alist では
;; なく server-after-make-frame-functions でクライアント接続後に設定する）
;; また、visibility . nil でフレームを不可視にしてから表示することで、
;; 背景色が正しく適用される前にフレームが表示されるのを防ぐ（Emacs 30.2 PGTK の既知の問題）
;; early-init.el が --init-directory により読み込まれないため、
;; ここでフレーム設定を直接適用する。
(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars . nil) default-frame-alist)
(push '(background-color . "#1e1e2e") default-frame-alist)
(push '(foreground-color . "#cdd6f4") default-frame-alist)

(defun my/apply-alpha-background (&optional frame)
  "Apply alpha-background 85 to FRAME after client connects."
  (let ((f (or frame (selected-frame))))
    ;; Emacs 32 (PGTK) では背景色バグが修正済みのため、
    ;; 単純に alpha を設定するだけでよい。
    (set-frame-parameter f 'alpha-background 85)))

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
