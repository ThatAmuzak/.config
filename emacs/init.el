(org-babel-load-file
 (expand-file-name
  "config.org"
 user-emacs-directory))
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(safe-local-variable-values
   '((citar-bibliography "references/refs.bib"
						 "references/additional_refs.bib"))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(org-code ((t (:background "#2e3440" :foreground "#d8dee9" :box nil))))
 '(org-verbatim ((t (:background "#2e3440" :foreground "#d8dee9" :box nil))))
 '(region ((t (:background "#5f695f")))))
