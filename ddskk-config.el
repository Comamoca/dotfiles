(setq skk-use-azik t)
(setq skk-sticky-key ";")

(setq skk-jisyo (cons "~/.skk-jisyo" 'utf-8))

(setq skk-large-jisyo "~/.skk-dict/SKK-JISYO.L")
(setq skk-extra-jisyo-file-list
     (list '("~/.skk-dict/SKK-JISYO.im@sparql.all.utf8" 'utf-8)))

(add-hook 'skk-azik-load-hook
	  (lambda ()
	    (setq skk-rom-kana-rule-list
		  (skk-del-alist ";" skk-rom-kana-rule-list))

	    (setq skk-rom-kana-rule-list
		  (append skk-rom-kana-rule-list
			  '((";" nil skk-sticky-set-henkan-point))))
	    ))


;; (setq skk-rom-kana-rule-list
;;       (skk-del-alist "'" skk-rom-kana-rule-list))


;; (setq skk-show-candidates-always-pop-to-buffer t)
;; (setq skk-henkan-show-candidates-rows 5)
;; (setq skk-comp-mode t)

;; (setq skk-use-azik t)
;; (setq skk-sticky-key ";")

;; (setq skk-rom-kana-rule-list
;;       (assoc-delete-all ";" skk-rom-kana-rule-list))

;; (add-to-list 'skk-rom-kana-rule-list '(";" nil skk-start-henkan))

;; (defun my/skk-azik-hook (
;;   (setq skk-rom-kana-rule-list
;; 	(assoc-delete-all ";" skk-rom-kana-rule-list))

;;   (add-to-list 'skk-rom-kana-rule-list '(";" nil skk-start-henkan)))
