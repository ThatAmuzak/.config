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

;; (setq use-package-always-ensure t)

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
  (evil-select-search-module 'evil-search-module 'evil-search)

  ;; QoL rebinds
  (define-key evil-normal-state-map "j" 'evil-next-visual-line)
  (define-key evil-normal-state-map "k" 'evil-previous-visual-line)
  (define-key evil-visual-state-map "j" 'evil-next-visual-line)
  (define-key evil-visual-state-map "k" 'evil-previous-visual-line)
  (define-key evil-visual-state-map (kbd "x") 'evil-delete)
  (define-key evil-normal-state-map (kbd "C-d") (lambda () (interactive) (evil-scroll-down nil)))
  (define-key evil-normal-state-map (kbd "C-u") (lambda () (interactive) (evil-scroll-up nil)))
  (define-key evil-normal-state-map "n" (lambda () (interactive) (evil-ex-search-next) (recenter)))
  (define-key evil-normal-state-map "N" (lambda () (interactive) (evil-ex-search-previous) (recenter)))
  (define-key evil-normal-state-map (kbd "<escape>") #'evil-ex-nohighlight)
  (define-key evil-normal-state-map "G" (lambda () (interactive) (evil-goto-line) (recenter)))
  (define-key evil-normal-state-map (kbd "<up>") (lambda () (interactive) (evil-window-increase-height 2)))
  (define-key evil-normal-state-map (kbd "<down>") (lambda () (interactive) (evil-window-decrease-height 2)))
  (define-key evil-normal-state-map (kbd "<left>") (lambda () (interactive) (evil-window-decrease-width 2)))
  (define-key evil-normal-state-map (kbd "<right>") (lambda () (interactive) (evil-window-increase-width 2)))
  (define-key evil-visual-state-map "<" 'evil-shift-left-line)
  (define-key evil-visual-state-map ">" 'evil-shift-right-line)
  (define-key evil-visual-state-map "p" (lambda () (interactive) (evil-delete (region-beginning) (region-end) 'line ?_) (evil-paste-after nil)))

  ;; window management
  (define-key evil-normal-state-map (kbd "C-k") 'evil-window-up)
  (define-key evil-normal-state-map (kbd "C-j") 'evil-window-down)
  (define-key evil-normal-state-map (kbd "C-h") 'evil-window-left)
  (define-key evil-normal-state-map (kbd "C-l") 'evil-window-right)

  ;; LSP Stuff
  (define-key evil-normal-state-map (kbd "K") (lambda () (interactive) (lsp-ui-doc-glance)))
  (define-key evil-normal-state-map (kbd "E") (lambda () (interactive) (when (bound-and-true-p flycheck-mode) (flycheck-display-error-at-point))))
  (define-key evil-insert-state-map (kbd "C-k") (lambda () (interactive) (eldoc-box-help-at-point)))

  ;; DWIM in org on enter in normal mode
  (evil-define-key 'normal org-mode-map (kbd "RET") 'org-open-at-point))

(use-package evil-collection
  :ensure
  :demand t
  :after evil
  :config
  (setq evil-collection-mode-list '(dashboard dired ibuffer))
  (evil-collection-init))

(with-eval-after-load 'evil-maps
  (define-key evil-motion-state-map (kbd "RET") nil)
  (define-key evil-motion-state-map (kbd "TAB") nil))

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

  ;; Emacs Utils
  (amuzak/leader-keys
    "r r" '(revert-buffer-quick :wk "Refresh Buffer"))

  ;; Org Roam
  (amuzak/leader-keys
    "n"  '(:ignore t :wk "Org-Roam")
    "n l" '(org-roam-buffer-toggle :wk "Toggle Org Roam Buffer")
    "n f" '(org-roam-node-find :wk "Find Org Node")
    "n g" '(org-roam-graph :wk "Open Org Roam Graph")
    "n i" '(org-roam-node-insert :wk "Link to a Node")
    "n c" '(org-roam-capture :wk "Org Roam Capture")
    "n j" '(org-roam-dailies-capture-today :wk "Org Roam Daily Capture Today"))

  ;; LSP
  (amuzak/leader-keys
    "c a" '(lsp-execute-code-action :wk "Code Actions")
    "x x" '(flycheck-list-errors :wk "Open Quick Fix List")
    "g d" '(lsp-find-definition :wk "Go to Definitions")
    "g r" '(lsp-find-references :wk "Find References")
    "r n" '(lsp-rename :wk "Find References")
    )

  (amuzak/leader-keys
    "e" '(grease-toggle :wk "Open Grease Here"))

  ;; Task Management
  (amuzak/leader-keys
    "t" '(:ignore t :wk "Task")
    "t t" '(org-todo :wk "Cycle Org Todo")
    "t g" '(org-set-tags-command :wk "Set tags")
    "t p" '(org-priority :wk "Set Priority")
    "t d" '(org-deadline :wk "Set Deadline")
    "t c" '(org-toggle-checkbox :wk "Toggle Checkbox")
    "t a" '(org-agenda :wk "Org Agenda"))

  ;; Misc
  (amuzak/leader-keys
    "SPC" '(projectile-find-file :wk "Find file")
    "s g" '(projectile-ripgrep :wk "Search in file")
    "p p" '(projectile-switch-project :wk "Switch Projects")
    "p a" '(projectile-add-known-project :wk "Add Project")
    "a" (lambda () (interactive) (evil-goto-first-line) (evil-visual-line) (evil-goto-line))
    "d d" '(dashboard-open :wk "Open Dashboard")
    "l g" '(my/launch-lazygit :wk "Launch LazyGit")
    "f f" '(flash-jump :wk "Flash to Target")
    "c b" (lambda () (interactive) (let ((vertico-posframe-mode nil)) (call-interactively #'consult-yank-from-kill-ring)))
    "w w" '((lambda () (interactive)
              (save-some-buffers t (lambda ()
                                     (and (buffer-modified-p)
                                          (not (string-match-p "\\*.*\\*" (buffer-name)))
                                          (not (eq major-mode 'comint-mode)))))
              (message "All files saved"))
            :wk "Save file(s)")
    "q q" '((lambda () (interactive)
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

(global-auto-revert-mode 1)
(setq global-auto-revert-non-file-buffers t)
(setq auto-revert-verbose nil)

(custom-set-faces
 '(region ((t (:background "#5f695f")))))

(set-language-environment "UTF-8")

(setq initial-buffer-choice "~/")

;; Map backspace to go up a directory in Dired
(with-eval-after-load 'dired
  (define-key dired-mode-map (kbd "<backspace>") 'dired-up-directory))

(defun open-messages-buffer ()
  "Open the *Messages* buffer in a vertical split."
  (interactive)
  (let ((buf (get-buffer "*Messages*")))
    (if buf
        (select-window (split-window-right))
      (setq buf (get-buffer-create "*Messages*")))
    (switch-to-buffer buf)))

(setq use-short-answers t)

(setq backup-directory-alist '((".*" . "~/.config/emacs/backup")))

(setq gc-cons-threshold (* 100 1024 1024)) ; 100MB

(global-set-key [escape] 'keyboard-escape-quit)

(setq backup-directory-alist '((".*" . "~/.config/emacs/backups/")))

(setq default-frame-alist '((undecorated . t)))
(add-to-list 'default-frame-alist '(drag-internal-border . 1))
(add-to-list 'default-frame-alist '(internal-border-width . 5))

;; Setting the default font
(set-face-attribute 'default nil
                    :font "JetBrainsMono NFM"
                    :height 110
                    :weight 'medium)
;; Setting font for variable pitch
(set-face-attribute 'variable-pitch nil
                    :family (or (car (seq-filter
                                      (lambda (f) (member f (font-family-list)))
                                      '("Ubuntu" "DejaVu Sans" "Arial")))
                                "Sans")
                    :height 140)
;;Setting font for fixed pitch
(set-face-attribute 'fixed-pitch nil
                    :font "JetBrainsMono NFM"
                    :height 110
                    :weight 'medium)

;; Makes commented text and keywords  italics
(set-face-attribute 'font-lock-comment-face nil
                    :slant 'italic)
(set-face-attribute 'font-lock-keyword-face nil
                    :slant 'italic)

(add-to-list 'default-frame-alist '(font . "JetBrainsMono NFM-11"))
(setq-default line-spacing 0.12)

(global-set-key (kbd "C-=") 'text-scale-increase)
(global-set-key (kbd "C--") 'text-scale-decrease)
(global-set-key (kbd "C-=") 'text-scale-increase)
(global-set-key (kbd "C--") 'text-scale-decrease)

(setq paragraph-start "\\([ \t]*$\\)\\|\\(^\\s-*$\\)")
(setq paragraph-separate "\\([ \t]*$\\)\\|\\(^\\s-*$\\)")

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

;; (use-package darktooth-theme
;;   :ensure (:host github :repo "emacsfodder/emacs-theme-darktooth")
;;   :config
;;   (load-theme 'darktooth t))

(use-package doom-themes
  :ensure t
  :custom
  (doom-themes-enable-bold t)   ; if nil, bold is universally disabled
  (doom-themes-enable-italic t) ; if nil, italics is universally disabled
  :config
  (load-theme 'doom-bluloco-dark t)
  ;; Enable flashing mode-line on errors
  (doom-themes-visual-bell-config)
  ;; Corrects (and improves) org-mode's native fontification.
  (doom-themes-org-config))

(use-package evil-goggles
  :ensure t
  :after evil
  :init
  (setq evil-goggles-enable-delete nil)
  (setq evil-goggles-enable-change nil)
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
  :config
  (holo-layer-enable))

(use-package indent-bars
  :ensure t
  :custom
  (indent-bars-no-descend-lists 'skip)
  (indent-bars-treesit-support t)
  (indent-bars-treesit-ignore-blank-lines-types '("module"))
  ;; Add other languages as needed; check the wiki
  (indent-bars-treesit-scope '((python function_definition class_definition for_statement
				       if_statement with_statement while_statement)))
  :hook ((prog-mode) . indent-bars-mode))

(use-package outline-indent
  :ensure t
  :commands outline-indent-minor-mode
  :hook
  ((python-mode . outline-indent-minor-mode)
   (python-ts-mode . outline-indent-minor-mode)
   (emacs-lisp-mode . outline-indent-minor-mode)))

(use-package kirigami
  :ensure t
  :config ;; Configure Kirigami to replace the default Evil-mode folding key bindings
  (with-eval-after-load 'evil
    (define-key evil-normal-state-map "zo" 'kirigami-open-fold)
    (define-key evil-normal-state-map "zO" 'kirigami-open-fold-rec)
    (define-key evil-normal-state-map "zc" 'kirigami-close-fold)
    (define-key evil-normal-state-map "za" 'kirigami-toggle-fold)
    (define-key evil-normal-state-map "zr" 'kirigami-open-folds)
    (define-key evil-normal-state-map "zm" 'kirigami-close-folds)))

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
	which-key-side-window-max-height 0.2
	which-key-idle-delay 0.8
	which-key-max-description-length 50
	which-key-allow-imprecise-window-fit nil
	which-key-separator "  "))

(use-package toc-org
  :ensure t
  :commands toc-org-enable
  :init (add-hook 'org-mode-hook 'toc-org-enable))

(electric-indent-mode -1)

(add-hook 'org-mode-hook #'font-lock-fontify-buffer)

(setq org-startup-folded t)

(require 'org-tempo)

(add-to-list 'org-structure-template-alist '("se" . "src emacs-lisp"))
(add-to-list 'org-structure-template-alist '("sp" . "src python"))
(add-to-list 'org-structure-template-alist '("sr" . "src R"))
(add-to-list 'org-structure-template-alist '("sc" . "src clojure"))

(add-hook 'org-mode-hook 'org-indent-mode)
(use-package org-bullets
  :ensure t)
(add-hook 'org-mode-hook (lambda () (org-bullets-mode 1)))

(use-package org-modern
  :ensure t
  :hook (org-mode . org-modern-mode)
  :config
  (modify-all-frames-parameters
   '((right-divider-width . 0)
     (internal-border-width . 0)))
  (dolist (face '(window-divider
                  window-divider-first-pixel
                  window-divider-last-pixel))
    (face-spec-reset-face face)
    (set-face-foreground face (face-attribute 'default :background)))
  (set-face-background 'org-block (color-darken-name (face-attribute 'default :background) 30))
  (setq org-modern-hide-stars " ")
  (setq org-modern-fold-stars
	'(("" . "")
          ("" . "")
          ("" . "")
          ("󰮺" . "󰮷")
          ("" . "")))
  (setq ;;org-modern-star '("◉" "○" "✸" "✿")
   org-auto-align-tags t
   org-tags-column 0
   org-fold-catch-invisible-edits 'show-and-error
   org-special-ctrl-a/e t
   org-insert-heading-respect-content t
   ;; Don't style the following
   org-modern-tag nil
   org-modern-priority nil
   org-modern-todo nil
   org-modern-table nil
   org-ellipsis " "
   org-modern-block-fringe nil
   org-modern-priority
   '((?A . "󱗗")  ;; High
     (?B . "󰜥")  ;; Medium
     (?C . "󰒲")))) ;; Low

(use-package org-modern-indent
  :ensure (:host github :repo "jdtsmith/org-modern-indent")
  :config ; add late to hook
  (org-modern-indent-mode 1)
  (add-hook 'org-mode-hook #'org-modern-indent-mode t))

(use-package olivetti
  :ensure t
  :diminish olivetti-mode
  :bind (("<left-margin> <mouse-1>" . ignore)
         ("<right-margin> <mouse-1>" . ignore)
         ("C-c {" . olivetti-shrink)
         ("C-c }" . olivetti-expand)
         ("C-c |" . olivetti-set-width))
  :custom
  (olivetti-body-width 0.65)          ; 70% of window width
  (olivetti-minimum-body-width 80)   ; Minimum width in characters
  (olivetti-recall-visual-line-mode-entry-state t)
  :hook
  ((markdown-mode . olivetti-mode)
   (org-mode . olivetti-mode)
   (prog-mode . olivetti-mode)))

(defun my/olivetti-only-when-single-window ()
  "Enable Olivetti mode only when there is a single window."
  (if (= (count-windows) 1)
      (olivetti-mode 1)
    (olivetti-mode -1)))

;; (add-hook 'window-configuration-change-hook
;;           #'my/olivetti-only-when-single-window)

(use-package org-superstar
  :ensure t
  :config
  (setq org-superstar-leading-bullet " ")
  (setq org-superstar-special-todo-items t) ;; Makes TODO header bullets into boxes
  (setq org-superstar-todo-bullet-alist '(("TODO" . 9744)
                                          ("DONE" . 9744)
                                          ("IN-PROGRESS" . 9744)
                                          ("CANCELLED" . 9744))))

(defun my-org-checkbox-symbols ()
  (setq-local prettify-symbols-alist
              '(("[ ]" . "☐")
                ("[X]" . "󰸞")
                ("[-]" . "󰜥")))
  (prettify-symbols-mode 1))
(add-hook 'org-mode-hook #'my-org-checkbox-symbols)

(use-package org-roam
  :ensure t
  :custom
  (org-roam-directory (file-truename "~/Notes/Brain/"))
  :config
  (setq org-roam-dailies-directory "Journal/")
  (setq org-roam-dailies-capture-templates
  	'(("d" "daily" plain "%?"
  	   :target (file+head+olp "%<%Y-%m>.org"
  				  "#+title: %<%Y-%m>\n"
  				  ("%<%d>" "%<%H:%M>"))
  	   :unnarrowed t)))

  (setq org-roam-capture-templates
        '(

          ("d" "default"
           plain "%?"
           :if-new (file+head "${slug}.org" "#+title: ${title}\n")
           :unnarrowed t)

          ("t" "topics" entry
           "* ${title} :topic:\n:PROPERTIES:\n:ID: %(org-id-new)\n:END:\n%?"
           :target (file+head "topics.org" "#+title: Topics\n")
           :unnarrowed t)

          ("p" "project"
           plain "%?"
           :if-new (file+head "Projects/${slug}.org" "#+title: ${title}\n#STARTUP: showeverything\n")
           :unnarrowed t)

          ))
  (setq org-roam-node-display-template (concat "${title:*} " (propertize "${tags:10}" 'face 'org-tag)))
  (org-roam-db-autosync-mode)
  (require 'org-roam-protocol))

(setq org-agenda-files '("~/Notes/Brain/Projects/"))

(setq org-todo-keywords
      '((sequence "TODO(t)" "IN-PROGRESS(i)" "|" "DONE(d)" "CANCELLED(c)")))
(setq org-todo-keyword-faces
      '(("TODO"      . (:foreground "white" :background "#FF5964"     :weight bold))
        ("IN-PROGRESS"   . (:foreground "black" :background "#FFF4AD"           :weight bold))
        ("DONE"      . (:foreground "white" :background "#33b58e"    :weight bold))
        ("CANCELLED" . (:foreground "white" :background "DimGray"        :weight bold))
	))

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
  (setq dashboard-startup-banner "~/.config/emacs/EmacsDashboard.gif")
  (setq dashboard-projects-backend 'projectile)
  (setq dashboard-banner-logo-title "Welcome Back, Boss")
  (setq dashboard-set-init-info nil)
  (setq dashboard-footer-icon "")
  (setq dashboard-footer-messages '("Simplicity is the Ultimate Sophistication. Think Simple."))
  (setq dashboard-items '((recents . 5)
                          (agenda . 5)
                          (projects . 5)))
  (setq dashboard-agenda-sort-strategy '(time-up))
  :config
  ;; (add-hook 'elpaca-after-init-hook #'dashboard-insert-startupify-lists)
  ;; (add-hook 'elpaca-after-init-hook #'dashboard-initialize)
  (dashboard-setup-startup-hook))
(with-eval-after-load 'dashboard
  (defun my/dashboard-replace-displayable (str)
    str)
  (advice-add 'dashboard-replace-displayable :override #'my/dashboard-replace-displayable)
  (advice-add 'dashboard-insert-init-info :override #'ignore))

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
  :ensure nil
  :init
  (savehist-mode)
  (add-to-list 'savehist-additional-variables 'kill-ring))

;; Orderless - fuzzy/flex matching similar to telescope
(use-package orderless
  :ensure t
  :custom
  (completion-styles '(orderless flex basic))
  (completion-category-overrides '((file (styles orderless basic partial-completion))))
  (completion-ignore-case t))

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

;; Center of screen vertico
(use-package vertico-posframe
  :ensure t
  :init
  (vertico-posframe-mode 1))

;; Darken background when using posframe
;; Also works amazingly well when searching
;; And when alt tabbed out of emacs
(use-package dimmer
  :ensure t
  :init
  (dimmer-configure-posframe)
  (dimmer-configure-which-key)
  (dimmer-configure-org)
  (dimmer-configure-company-box)
  (dimmer-mode t)
  :config
  (setq dimmer-fraction 0.40))

;; Consult for more functionality and yank ring
(use-package consult
  :ensure t)

(use-package treesit-auto
  :ensure t
  :custom
  (treesit-auto-install 't)
  :config
  (setq treesit-auto-langs '(python csharp java lua clojure javascript typescript tsx c cpp bash css go rust yaml))
  (treesit-auto-add-to-auto-mode-alist 'all)
  (global-treesit-auto-mode))

(setq treesit-font-lock-level 4)

(setq treesit-language-source-alist
      '((python "https://github.com/tree-sitter/tree-sitter-python" "v0.20.4")
        (javascript "https://github.com/tree-sitter/tree-sitter-javascript" "v0.20.4" "src")
        (typescript "https://github.com/tree-sitter/tree-sitter-typescript" "v0.20.3" "typescript/src")
        (tsx "https://github.com/tree-sitter/tree-sitter-typescript" "v0.20.3" "tsx/src")
        (csharp "https://github.com/tree-sitter/tree-sitter-c-sharp" "v0.20.0")
        (elisp "https://github.com/Wilfred/tree-sitter-elisp" "1.5.0")
        (java "https://github.com/tree-sitter/tree-sitter-java" "v0.20.0")
        (lua "https://github.com/tree-sitter-grammars/tree-sitter-lua" "v0.3.0")
        (css "https://github.com/tree-sitter/tree-sitter-css" "v0.21.1")
        (go "https://github.com/tree-sitter/tree-sitter-go" "v0.21.0")
        (rust "https://github.com/tree-sitter/tree-sitter-rust" "v0.20.2")
        (bash "https://github.com/tree-sitter/tree-sitter-bash" "v0.20.2")
        (c "https://github.com/tree-sitter/tree-sitter-c" "v0.20.6")
        (cpp "https://github.com/tree-sitter/tree-sitter-cpp" "v0.20.5")
        (yaml "https://github.com/ikatyang/tree-sitter-yaml" "v0.5.0")
        (toml "https://github.com/tree-sitter/tree-sitter-toml" "v0.5.1")))

(use-package yasnippet
  :ensure t
  :config
  (yas-global-mode 1))

(use-package yasnippet-snippets
  :ensure (:host github :repo "AndreaCrotti/yasnippet-snippets")
  :after yasnippet)

(use-package lsp-mode
  :ensure t
  :commands (lsp lsp-deferred)
  :hook ((prog-mode . lsp-deferred)) ;; keeping it prog mode enables it to activate for any language
  :init
  ;; performance
  (setq gc-cons-threshold (* 100 1024 1024)
        read-process-output-max (* 1 1024 1024))
  :config

  (setq lsp-enable-symbol-highlighting t
        lsp-enable-on-type-formatting nil   ;; no auto format
        lsp-idle-delay 0.3
        lsp-headerline-breadcrumb-enable t)

  ;; diagnostics
  (setq lsp-diagnostics-provider :flycheck)

  ;; completion
  (setq lsp-completion-provider :capf))

(use-package lsp-ui
  :ensure t
  :after lsp-mode
  :hook (lsp-mode . lsp-ui-mode)
  :config
  (setq lsp-ui-doc-enable t
      lsp-signature-auto-activate nil
      lsp-signature-render-documentation nil
      lsp-enable-symbol-highlighting nil
      lsp-ui-doc-position 'at-point   ;; key setting
      lsp-ui-doc-show-with-cursor nil
      lsp-ui-doc-show-with-mouse nil
      lsp-eldoc-enable-hover t
      lsp-ui-sideline-enable nil
      lsp-headerline-breadcrumb-enable nil
      lsp-signature-auto-activate nil))

(use-package eldoc-box
  :ensure t
  ;; :hook (eldoc-mode . eldoc-box-hover-at-point-mode)
  :config (setq eldoc-box-max-pixel-width 800
              eldoc-box-max-pixel-height 600
              eldoc-box-clear-with-C-g t))

(use-package company
  :ensure t
  :hook (after-init . global-company-mode)
  :config
  (setq company-minimum-prefix-length 1
        company-idle-delay 0.0
        company-tooltip-align-annotations t))

(use-package company-box
  :ensure t
  :hook (company-mode . company-box-mode))

(use-package flycheck
  :ensure t
  :hook (lsp-mode . flycheck-mode))

(use-package flycheck-posframe
  :ensure t
  :hook (flycheck-mode . flycheck-posframe-mode)
  :config
  (setq flycheck-posframe-border-width 1))

(use-package apheleia
  :ensure t
  :config
  (apheleia-global-mode +1)

  ;; formatter definitions
  (setf (alist-get 'ruff apheleia-formatters)
        '("ruff" "format" "--stdin-filename" filepath "-"))

  (setf (alist-get 'python-mode apheleia-mode-alist)
        'ruff))

(use-package markdown-mode
  :ensure t
  :mode ("README\\.md\\'" . gfm-mode)
  :init (setq markdown-command "multimarkdown")
  :bind (:map markdown-mode-map
              ("C-c C-e" . markdown-do)))

(use-package lsp-bridge
  :ensure '(lsp-bridge :type git
                       :host github :repo "manateelazycat/lsp-bridge"
                       :files (:defaults "*.el" "*.py" "acm" "core" "langserver" "multiserver" "resources")
                       :build (:not compile))
  :hook ((org-src-mode LaTeX-mode) . lsp-bridge-mode)
  :config (setq lsp-bridge-python-command "python")
  :init (setq lsp-bridge-enable-diagnostics nil
              acm-enable-search-file-words t
              acm-backend-search-sdcv-words-dictionary nil
              lsp-bridge-enable-signature-help t
              lsp-bridge-enable-hover-diagnostic t
              lsp-bridge-enable-auto-format-code nil
              lsp-bridge-enable-completion-in-minibuffer nil
              lsp-bridge-enable-log t
              lsp-bridge-enable-org-babel t
              lsp-bridge-use-popup t
              lsp-bridge-deferred-tick-time 0.01))

(use-package lsp-pyright
  :ensure t
  :hook (python-mode . (lambda ()
                         (require 'lsp-pyright)
                         (lsp-deferred))))

(use-package rust-mode
  :hook (rust-mode . lsp-deferred))

(use-package grease
  :ensure (:host github :repo "mwac-dev/grease.el")
  :commands (grease-open grease-toggle grease-here)
  :hook (grease-mode . (lambda ()
                         (define-key grease-mode-map (kbd "<backspace>") #'grease-up-directory))))

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

(use-package scroll-on-jump
  :after evil
  :ensure t
  :config
  (setq scroll-on-jump-duration 0.3
        scroll-on-jump-smooth t
        scroll-on-jump-curve 'smooth-out
        scroll-on-jump-curve-power 4.0)

  (with-eval-after-load 'evil
    (scroll-on-jump-advice-add evil-undo)
    (scroll-on-jump-advice-add evil-redo)
    (scroll-on-jump-advice-add evil-jump-item)
    (scroll-on-jump-advice-add evil-jump-forward)
    (scroll-on-jump-advice-add evil-jump-backward)
    (scroll-on-jump-advice-add evil-ex-search-next)
    (scroll-on-jump-advice-add evil-ex-search-previous)
    (scroll-on-jump-advice-add evil-forward-paragraph)
    (scroll-on-jump-advice-add evil-backward-paragraph)
    (scroll-on-jump-advice-add evil-goto-mark)

    (scroll-on-jump-with-scroll-advice-add evil-goto-line)
    (scroll-on-jump-with-scroll-advice-add evil-scroll-down)
    (scroll-on-jump-with-scroll-advice-add evil-scroll-up)
    (scroll-on-jump-with-scroll-advice-add evil-scroll-line-to-center)
    (scroll-on-jump-with-scroll-advice-add evil-scroll-line-to-top)
    (scroll-on-jump-with-scroll-advice-add evil-scroll-line-to-bottom)))

(use-package shrink-path
  :ensure (:host gitlab :repo "bennya/shrink-path.el"))

;; Required for search match counts in the modeline
(use-package anzu
  :ensure t
  :config (global-anzu-mode +1))

;; evil integration
(use-package evil-anzu
  :ensure t
  :after (evil anzu))

(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1)
  :config

  ;; ── Evil state tags (no "state" suffix) ────────────────────────────
  (setq doom-modeline-modal t
        doom-modeline-modal-icon nil  ; text only, no icon
	doom-modeline-keystroke t
        evil-normal-state-tag   " NORMAL "
        evil-insert-state-tag   " INSERT "
        evil-visual-state-tag   " VISUAL "
        evil-replace-state-tag  " REPLACE "
        evil-operator-state-tag " OPERATOR "
        evil-motion-state-tag   " MOTION "
        evil-emacs-state-tag    " EMACS ")

  ;; ── State face colors ───────────────────────────────────────────────
  (set-face-attribute 'doom-modeline-evil-normal-state   nil :foreground "#1e1e2e" :background "#cba6f7" :weight 'bold)
  (set-face-attribute 'doom-modeline-evil-insert-state   nil :foreground "#1e1e2e" :background "#a6e3a1" :weight 'bold)
  (set-face-attribute 'doom-modeline-evil-visual-state   nil :foreground "#1e1e2e" :background "#fab387" :weight 'bold)
  (set-face-attribute 'doom-modeline-evil-replace-state  nil :foreground "#1e1e2e" :background "#f38ba8" :weight 'bold)
  (set-face-attribute 'doom-modeline-evil-operator-state nil :foreground "#1e1e2e" :background "#f9e2af" :weight 'bold)
  (set-face-attribute 'doom-modeline-evil-motion-state   nil :foreground "#1e1e2e" :background "#89b4fa" :weight 'bold)
  (set-face-attribute 'doom-modeline-evil-emacs-state    nil :foreground "#1e1e2e" :background "#a6adc8" :weight 'bold)

  (setq doom-modeline-position-column-line-format '("%l:%c"))

  (doom-modeline-set-modeline 'my-modeline t))

(use-package symbol-overlay
  :ensure t
  :config
  (setq symbol-overlay-idle-time 0.2)
  (set-face-background 'symbol-overlay-default-face "#694b35")
  (define-globalized-minor-mode global-symbol-overlay-mode
    symbol-overlay-mode symbol-overlay-mode)
  (global-symbol-overlay-mode 1))

(defun my/prettify-symbols-setup ()

  ;; Drawers
  (push '(":PROPERTIES:" . "") prettify-symbols-alist)
  (push '(":ROAM_ALIASES:" . "") prettify-symbols-alist)
  (push '(":ID:" . " ") prettify-symbols-alist)
  (push '(":DATE:" . "") prettify-symbols-alist)
  (push '(":DATE_PUBLISHED:" . "") prettify-symbols-alist)
  (push '(":AUTHOR:" . "") prettify-symbols-alist)
  (push '(":ROAM_REFS:" . " ") prettify-symbols-alist)
  (push '(":PRIORITY:" . "") prettify-symbols-alist)
  (push '(":END:" . "") prettify-symbols-alist)
  (push '(":RESULTS:" . "") prettify-symbols-alist)
  ;; Tags
  (push '(":projects:" . "  Projects") prettify-symbols-alist)
  (push '(":work:"     . "  Work") prettify-symbols-alist)
  (push '(":inbox:"    . "  Inbox") prettify-symbols-alist)
  (push '(":task:"     . "  Task") prettify-symbols-alist)
  (push '(":thesis:"   . "  Thesis") prettify-symbols-alist)
  (push '(":learn:"    . "  Learn") prettify-symbols-alist)
  (push '(":code:"     . "  Code") prettify-symbols-alist)

  (set-face-attribute 'org-drawer nil :height 1.3)
  (set-face-attribute 'org-special-keyword nil :height 1.3)
  (prettify-symbols-mode))

(add-hook 'org-mode-hook        #'my/prettify-symbols-setup)
(add-hook 'org-agenda-mode-hook #'my/prettify-symbols-setup)

(use-package projectile
  :ensure t
  :init
  (projectile-mode +1))

(use-package ripgrep
  :ensure (:host github :repo "https://github.com/nlamirault/ripgrep.el"))

(use-package flash
  :ensure t
  :commands (flash-jump flash-jump-continue
			flash-treesitter)
  ;; :bind ("s-j" . flash-jump)
  :custom
  (flash-multi-window t)
  :init
  ;; Evil integration (simple setup)
  (with-eval-after-load 'evil
    (require 'flash-evil)
    (flash-evil-setup t))  ; t = also set up f/t/F/T char motions
  :config
  ;; Search integration (labels during C-s, /, ?)
  (require 'flash-isearch)
  (setq flash-rainbow-shade 6)
  (setq flash-rainbow t)
  (setq flash-highlight-matches t)
  (setq flash-label-position 'overlay)
  (setq projectile-enable-caching 'persistent)
  (flash-isearch-mode 1))

(use-package git-gutter
  :ensure t
  :config
  (setq git-gutter:added-sign "+")
  (setq git-gutter:deleted-sign "-")
  (setq git-gutter:modified-sign "~")

  (set-face-foreground 'git-gutter:added "green")
  (set-face-foreground 'git-gutter:deleted "red")
  (set-face-foreground 'git-gutter:modified "yellow")
  (global-git-gutter-mode +1))

(use-package git-gutter-fringe
  :ensure t
  :after git-gutter
  :config
  (setq-default fringes-outside-margins t)
  (fringe-mode '(15 . 15)))

(use-package helpful
  :ensure t)
