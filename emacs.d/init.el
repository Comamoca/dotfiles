(require 'package)

(add-to-list 'package-archives '("marmalade" . "http://marmalade-repo.org/packages/") t)
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/") t)
(add-to-list 'package-archives '("melpa-stable" . "http://stable.melpa.org/packages/") t)

(package-initialize)

;; eglot(LSP)
(use-package eglot
  :ensure t
  :hook
  (c++-mode . eglot-ensure)
  (sh-mode . eglot-ensure)
  (python-mode . eglot-ensure)
  (html-mode . eglot-ensure)
  (go-mode . eglot-ensure)  
  (cmake-mode . eglot-ensure)
  (bitbake-mode . eglot-ensure)
  :config
  (add-to-list 'eglot-server-programs '((bitbake-mode) "bitbake-language-server"))
  :bind (("M-t" . xref-find-definitions)
     ("M-r" . xref-find-references)
     ("C-t" . xref-go-back)))
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages '(company-box ivy lsp-ui company-go company leaf go-mode)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

(leaf iceberg-theme
  :ensure t
  :config
  (iceberg-theme-create-theme-file)
  (load-theme 'solarized-iceberg-dark t))

(use-package lsp-mode)
(use-package company)
(use-package company-go)
(use-package ivy)

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
