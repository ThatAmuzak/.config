(defvar elpaca-installer-version 0.12)
(defvar elpaca-directory (expand-file-name "elpaca/" user-emacs-directory))
(defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
(defvar elpaca-sources-directory (expand-file-name "sources/" elpaca-directory))
(defvar elpaca-order '(elpaca :repo "https://github.com/progfolio/elpaca.git"
                              :ref nil :depth 1 :inherit ignore
                              :files (:defaults "elpaca-test.el" (:exclude "extensions"))
                              :build (:not elpaca-activate)))
(let* ((repo  (expand-file-name "elpaca/" elpaca-sources-directory))
       (build (expand-file-name "elpaca/" elpaca-builds-directory))
       (order (cdr elpaca-order))
       (default-directory repo))
  (add-to-list 'load-path (if (file-exists-p build) build repo))
  (unless (file-exists-p repo)
    (make-directory repo t)
    (when (<= emacs-major-version 28) (require 'subr-x))
    (condition-case-unless-debug err
        (if-let* ((buffer (pop-to-buffer-same-window "*elpaca-bootstrap*"))
                  ((zerop (apply #'call-process `("git" nil ,buffer t "clone"
                                                  ,@(when-let* ((depth (plist-get order :depth)))
                                                      (list (format "--depth=%d" depth) "--no-single-branch"))
                                                  ,(plist-get order :repo) ,repo))))
                  ((zerop (call-process "git" nil buffer t "checkout"
                                        (or (plist-get order :ref) "--"))))
                  (emacs (concat invocation-directory invocation-name))
                  ((zerop (call-process emacs nil buffer nil "-Q" "-L" "." "--batch"
                                        "--eval" "(byte-recompile-directory \".\" 0 'force)")))
                  ((require 'elpaca))
                  ((elpaca-generate-autoloads "elpaca" repo)))
            (progn (message "%s" (buffer-string)) (kill-buffer buffer))
          (error "%s" (with-current-buffer buffer (buffer-string))))
      ((error) (warn "%s" err) (delete-directory repo 'recursive))))
  (unless (require 'elpaca-autoloads nil t)
    (require 'elpaca)
    (elpaca-generate-autoloads "elpaca" repo)
    (let ((load-source-file-function nil)) (load "./elpaca-autoloads"))))
(add-hook 'after-init-hook #'elpaca-process-queues)
(elpaca `(,@elpaca-order))
;; Install use-package support
(elpaca elpaca-use-package
  ;; Enable use-package :ensure support for Elpaca.
  (elpaca-use-package-mode))

;; Expands to: (elpaca evil (use-package evil :demand t))
(use-package evil
  :ensure t
  :demand t
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-vsplit-window-right t)
  (setq evil-split-window-below t)
  (evil-mode)
  :config

  ;; QoL rebinds
  (define-key evil-normal-state-map "j" 'evil-next-visual-line)
  (define-key evil-normal-state-map "k" 'evil-previous-visual-line)
  (define-key evil-visual-state-map "j" 'evil-next-visual-line)
  (define-key evil-visual-state-map "k" 'evil-previous-visual-line)
  (define-key evil-visual-state-map (kbd "x") 'evil-delete)
  (define-key evil-normal-state-map (kbd "C-d") (lambda () (interactive) (evil-scroll-down nil) (recenter)))
  (define-key evil-normal-state-map (kbd "C-u") (lambda () (interactive) (evil-scroll-up nil) (recenter)))
  (define-key evil-normal-state-map "n" (lambda () (interactive) (evil-search-next) (recenter)))
  (define-key evil-normal-state-map "N" (lambda () (interactive) (evil-search-previous) (recenter)))
  (define-key evil-normal-state-map "G" (lambda () (interactive) (evil-goto-line) (recenter)))
  (define-key evil-normal-state-map (kbd "<up>") (lambda () (interactive) (evil-window-increase-height 2)))
  (define-key evil-normal-state-map (kbd "<down>") (lambda () (interactive) (evil-window-decrease-height 2)))
  (define-key evil-normal-state-map (kbd "<left>") (lambda () (interactive) (evil-window-decrease-width 2)))
  (define-key evil-normal-state-map (kbd "<right>") (lambda () (interactive) (evil-window-increase-width 2)))
  (define-key evil-visual-state-map "<" (lambda () (interactive) (evil-shift-left (region-beginning) (region-end)) (evil-visual-restore)))
  (define-key evil-visual-state-map ">" (lambda () (interactive) (evil-shift-right (region-beginning) (region-end)) (evil-visual-restore)))
  (define-key evil-visual-state-map "p" (lambda () (interactive) (evil-delete (region-beginning) (region-end) 'line ?_) (evil-paste-after nil)))
  (define-key evil-normal-state-map (kbd "C-k") 'evil-window-up)
  (define-key evil-normal-state-map (kbd "C-j") 'evil-window-down)
  (define-key evil-normal-state-map (kbd "C-h") 'evil-window-left)
  (define-key evil-normal-state-map (kbd "C-l") 'evil-window-right)
  (evil-define-key 'normal org-mode-map (kbd "RET") 'org-open-at-point))

(use-package evil-collection
  :ensure
  :demand t
  :after evil
  :config
  (setq evil-collection-mode-list '(dashboard dired ibuffer))
  (evil-collection-init))

;;Turns off elpaca-use-package-mode current declaration
;;Note this will cause evaluate the declaration immediately. It is not deferred.
;;Useful for configuring built-in emacs features.
(use-package emacs :ensure nil :config (setq ring-bell-function #'ignore))

(use-package general
  :ensure t
  :demand t
  :config
  (general-evil-setup)

  ;; 'SPC' as global leader key
  (general-create-definer amuzak/leader-keys
    :states '(normal insert visual emacs)
    :keymaps 'override
    :prefix "SPC"
    :global-prefix "C-SPC")

  ;; Buffer
  (amuzak/leader-keys
    "b" '(:ignore t :wk "Buffer")
    "b b" '(switch-to-buffer :wk "Switch buffer")
    "b i" '(ibuffer :wk "List active buffers")
    "b s" '(kill-this-buffer :wk "Kill this buffer")
    "b n" '(next-buffer :wk "Next buffer")
    "b p" '(previous-buffer :wk "Previous buffer")
    "b r" '(revert-buffer :wk "Reload buffer"))

  ;; Window
  (amuzak/leader-keys
    "v" '(evil-window-vsplit :wk "Split window vertically")
    "h" '(evil-window-split :wk "Split window horizontally")
    "se" '(balance-windows :wk "Make splits equal size")
    "xs" '(evil-window-delete :wk "Close current split"))

  ;; Evaluate
  (amuzak/leader-keys
    "e" '(:ignore t :wk "Evaluate")
    "e b" '(eval-buffer :wk "Evaluate elisp in buffer")
    "e d" '(eval-defun :wk "Evalute defun containing or after point")
    "e e" '(eval-expression :wk "Evalute an elisp expression")
    "e l" '(eval-last-sexp :wk "Evaluate elisp expression before point")
    "e r" '(eval-region :wk "Evaluate elisp in region"))

  ;; Emacs Utils
  (amuzak/leader-keys
    "d" '(:ignore t :wk "Help")
    "d f" '(describe-function :wk "Describe Function")
    "d v" '(describe-variable :wk "Describe Variable")
    "r r" '((lambda () (interactive) (load-file "~/.config/emacs/init.el")) :wk "Reload Emacs Config"))

  ;; Misc
  (amuzak/leader-keys
    "SPC" '(project-find-file :wk "Find file")
    "f r" '(counsel-recentf :wk "Find recent files")
    "c c" '((lambda () (interactive) (find-file "~/.config/emacs/config.org")) :wk "Edit Emacs Config")
    "a" (lambda () (interactive) (evil-goto-first-line) (evil-visual-line) (evil-goto-line))
    "d d" '(dashboard-open :wk "Open Dashboard")
    "l g" '(my/launch-lazygit :wk "Launch LazyGit")
    "ww" '((lambda () (interactive)
             (save-some-buffers t (lambda ()
  				    (and (buffer-modified-p)
  					 (not (string-match-p "\\*.*\\*" (buffer-name)))
  					 (not (eq major-mode 'comint-mode)))))
             (message "All files saved"))
  	   :wk "Save file(s)")
    "qq" '((lambda () (interactive)
             (save-some-buffers t (lambda ()
  				    (and (buffer-modified-p)
  					 (not (string-match-p "\\*.*\\*" (buffer-name)))
  					 (not (eq major-mode 'comint-mode)))))
             (message "All files saved, exiting...")
             (kill-emacs))
  	   :wk "Save all and quit"))

(general-define-key
 :states '(normal visual)
 "gcc" '(evilnc-comment-or-uncomment-lines :wk "Toggle comment")))

(electric-pair-mode 1)

(add-hook 'before-save-hook 'delete-trailing-whitespace)

(add-hook 'before-save-hook
          (lambda ()
            (save-excursion
              (goto-char (point-min))
              (while (re-search-forward "^\n+" nil t)
                (replace-match "\n")))))

(custom-set-faces
 '(region ((t (:background "#5f695f")))))

(set-language-environment "UTF-8")

(setq initial-buffer-choice "~/")

;; Map backspace to go up a directory in Dired
(with-eval-after-load 'dired
  (define-key dired-mode-map (kbd "<backspace>") 'dired-up-directory))

(setq gc-cons-threshold (* 100 1024 1024)) ; 100MB

(set-face-attribute 'default nil
		    :font "JetBrains Mono"
		    :height 110
		    :weight 'medium)
(set-face-attribute 'variable-pitch nil
		    :font "Ubuntu"
		    :height 120
		    :weight 'medium)
(set-face-attribute 'fixed-pitch nil
		    :font "JetBrains Mono"
		    :height 110
		    :weight 'medium)
(set-face-attribute 'font-lock-comment-face nil
		    :slant 'italic)
(set-face-attribute 'font-lock-keyword-face nil
		    :slant 'italic)
;; this will become useful once we move to the emacsclient
(add-to-list 'default-frame-alist '(font . "JetBrains Mono-11"))
(setq-default line-spacing 0.12)

(global-set-key (kbd "C-=") 'text-scale-increase)
(global-set-key (kbd "C--") 'text-scale-decrease)
(global-set-key (kbd "C-=") 'text-scale-increase)
(global-set-key (kbd "C--") 'text-scale-decrease)

(setq paragraph-start "\\([ \t]*$\\)\\|\\(^\\s-*$\\)")
(setq paragraph-separate "\\([ \t]*$\\)\\|\\(^\\s-*$\\)")

(use-package all-the-icons
  :ensure t
  :if (display-graphic-p))

(use-package nerd-icons
  :ensure t
  :config
  (setq nerd-icons-font-family "Symbols Nerd Font Mono"))

(use-package nerd-icons-dired
  :ensure t
  :hook (dired-mode . nerd-icons-dired-mode))

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(setq display-line-numbers-type 'relative)

(global-display-line-numbers-mode 1)
(global-visual-line-mode t)

(use-package darktooth-theme
  :ensure (:host github :repo "emacsfodder/emacs-theme-darktooth")
  :config
  (load-theme 'darktooth t))

(use-package evil-goggles
  :ensure t
  :after evil
  :config
  (evil-goggles-mode)
  (setq evil-goggles-duration 0.25))

(setq scroll-conservatively 101)
(setq scroll-margin 5)
(pixel-scroll-precision-mode 1)

(use-package holo-layer
  :ensure (:host github :repo "manateelazycat/holo-layer")
  :init
  (setq holo-layer-python-command "~/scoop/apps/python/current/python.exe")
  (setq holo-layer-python-file
        (expand-file-name "elpaca/sources/holo-layer/holo_layer.py"
                          user-emacs-directory))
  (setq holo-layer-enable-cursor-animation t)
  (setq holo-layer-enable-indent-rainbow t)
  :config
  (holo-layer-enable))

(use-package which-key
  :init
  (which-key-mode 1)
  :config
  (setq which-key-side-window-location 'bottom
	which-key-sort-order #'which-key-key-order-alpha
	which-key-sort-uppercase-first nil
	which-key-add-column-padding 1
	which-key-max-display-columns nil
	which-key-min-display-lines 6
	which-key-side-window-slot -10
	which-key-side-window-max-height 0.25
	which-key-idle-delay 0.8
	which-key-max-description-length 25
	which-key-allow-imprecise-window-fit t
	which-key-separator " -> "))

(use-package toc-org
  :ensure t
  :commands toc-org-enable
  :init (add-hook 'org-mode-hook 'toc-org-enable))

(add-hook 'org-mode-hook 'org-indent-mode)
(use-package org-superstar
  :ensure (:host github :repo "integral-dw/org-superstar-mode")
  :hook (org-mode . org-superstar-mode))

(electric-indent-mode -1)

(require 'org-tempo)

(add-hook 'org-mode-hook #'font-lock-fontify-buffer)

(add-to-list 'org-structure-template-alist '("se" . "src emacs-lisp"))
(add-to-list 'org-structure-template-alist '("sp" . "src python"))
(add-to-list 'org-structure-template-alist '("sr" . "src R"))
(add-to-list 'org-structure-template-alist '("sc" . "src clojure"))

(set-language-environment "UTF-8")
(use-package dashboard
  :ensure t
  :after nerd-icons
  :init
  (setq dashboard-center-content t)
  (setq dashboard-icon-type 'nerd-icons)
  (setq dashboard-display-icons-p t)
  (setq dashboard-set-heading-icons t)
  (setq dashboard-set-file-icons t)
  (setq dashboard-items '((recents . 5)
                          (agenda . 5)
                          (bookmarks . 5)
                          (projects . 5)))
  :config
  (add-hook 'elpaca-after-init-hook #'dashboard-insert-startupify-lists)
  (add-hook 'elpaca-after-init-hook #'dashboard-initialize)
  (dashboard-setup-startup-hook))
(with-eval-after-load 'dashboard
  (defun my/dashboard-replace-displayable (str)
    str)
  (advice-add 'dashboard-replace-displayable :override #'my/dashboard-replace-displayable))

(global-set-key (kbd "C-/") #'my/launch-shell)
(defun my/launch-shell ()
  "Launch WezTerm in the project root or current directory."
  (interactive)
  (let ((dir (or (project-root (project-current)) default-directory)))
    (call-process "wezterm" nil 0 nil
                  "start" "--cwd" (expand-file-name dir)
                  "pwsh" "-NoLogo")))
(global-set-key (kbd "C-/") #'my/launch-shell)

(defun my/launch-lazygit ()
  "Launch lazygit in WezTerm from the current buffer's directory."
  (interactive)
  (let ((dir (expand-file-name default-directory)))
    (start-process "wezterm-lazygit" nil
                   "wezterm" "start"
                   "--cwd" dir
                   "lazygit")))

;; Vertico - vertical completion UI
(use-package vertico
  :ensure t
  :init
  (vertico-mode))

;; Persist history across sessions (vertico sorts by recency)
(use-package savehist
  :init
  (savehist-mode))

;; Orderless - fuzzy/flex matching similar to telescope
(use-package orderless
  :ensure t
  :custom
  (completion-styles '(orderless flex basic))
  (completion-category-overrides '((file (styles orderless basic partial-completion)))))

;; Marginalia - annotations in the minibuffer (file size, docstrings, etc.)
(use-package marginalia
  :ensure t
  :init
  (marginalia-mode))

;; Nerd Icons for marginalia (requires nerd-icons and a patched font)
(use-package nerd-icons-completion
  :ensure t
  :after marginalia
  :config
  (nerd-icons-completion-mode)
  (add-hook 'marginalia-mode-hook #'nerd-icons-completion-marginalia-setup))

(use-package grease
  :ensure (:host github :repo "mwac-dev/grease.el")
  :commands (grease-open grease-toggle grease-here))

(use-package undo-fu
  :elpaca t)

(setq evil-undo-system 'undo-fu)

(with-eval-after-load 'evil
  (define-key evil-normal-state-map (kbd "C-r") 'evil-redo))

(use-package evil-surround
  :ensure t
  :config
  (global-evil-surround-mode 1))

(use-package evil-nerd-commenter
  :ensure (:host github :repo "redguardtoo/evil-nerd-commenter"))
