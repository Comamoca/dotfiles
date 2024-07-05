(require 'package)

(add-to-list 'package-archives '("marmalade" . "http://marmalade-repo.org/packages/") t)
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/") t)
(add-to-list 'package-archives '("melpa-stable" . "http://stable.melpa.org/packages/") t)

(package-initialize)

;; Load and setup packages
(use-package lsp-mode)
(use-package ivy)
(use-package paredit)
(use-package highlight-indent-guides)

(use-package company-go)
(use-package company
  :init
  (global-company-mode)
  (setq company-idle-delay 0.3)
  (setq company-minimum-prefix-length 1)
  (setq company-transformers '(company-sort-by-occurrence))
  :bind
  (:map company-active-map
	("C-n". company-select-next)
	("C-p". company-select-previous)
	("M-<". company-select-first)
	("M->". company-select-last)))

;; Language modes
(use-package go-mode
      :hook
      (go-mode . eglot-ensure))

(use-package c++-mode
      :hook
      (c++-mode . eglot-ensure))

(use-package sh-mode
      :hook
      (sh-mode . eglot-ensure))

(use-package html-mode
      :hook
      (html-mode . eglot-ensure))

(use-package cmake-mode
      :hook
      (cmake-mode . eglot-ensure))

(use-package bitbake-mode
      :hook
      (bitbake-mode . eglot-ensure))

;; eglot(LSP)
(use-package eglot
  :ensure t
  :config
  (add-to-list 'eglot-server-programs
        '((go-mode) "gopls"))
        ;; '((mode-name) "program-name")
   
  :bind (("M-t" . xref-find-definitions)
         ("M-r" . xref-find-references)
         ("C-t" . xref-go-back)))
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(highlight-indent-guides paredit company-box ivy lsp-ui company-go company leaf go-mode)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 

(leaf iceberg-theme
  :ensure t
  :config
  (iceberg-theme-create-theme-file)
  (load-theme 'solarized-iceberg-dark t))

(defun lsp-mode-init ()
  (lsp)
  (global-set-key (kbd "M-*") 'xref-pop-marker-stack)
  (global-set-key (kbd "M-.") 'xref-find-definitions)
  (global-set-key (kbd "M-/") 'xref-find-references))

;; lsp-ui config
(setq lsp-ui-doc-enable t)
(setq lsp-ui-doc-header t)
(setq lsp-ui-doc-include-signature t)
(setq lsp-ui-doc-max-width 150)
(setq lsp-ui-doc-max-height 30)
(setq lsp-ui-peek-enable t)
(add-hook 'lsp-mode-hook 'lsp-ui-mode)


(global-set-key (kbd "C-c <left>")  'windmove-left)
(global-set-key (kbd "C-c <down>")  'windmove-down)
(global-set-key (kbd "C-c <up>")    'windmove-up)
(global-set-key (kbd "C-c <right>") 'windmove-right)

(electric-pair-mode 1)
