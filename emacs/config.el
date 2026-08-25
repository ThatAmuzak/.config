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

(use-package evil
    :ensure t
    :init
    (setq evil-want-integration t)
    (setq evil-want-keybinding nil)
    (setq evil-vsplit-window-right t)
    (setq evil-split-window-below t)
    (setq evil-kill-on-visual-paste nil)
    (evil-mode)
    :config
    (evil-select-search-module 'evil-search-module 'evil-search)

    ;; QoL rebinds
    (define-key evil-normal-state-map "j" 'evil-next-visual-line)
    (define-key evil-normal-state-map "k" 'evil-previous-visual-line)
    (define-key evil-visual-state-map "j" 'evil-next-visual-line)
    (define-key evil-visual-state-map "k" 'evil-previous-visual-line)
    (define-key evil-visual-state-map (kbd "x") 'evil-delete)
    (define-key evil-normal-state-map (kbd "C-d") (lambda () (interactive) (evil-scroll-down nil) (beacon-blink)))
    (define-key evil-normal-state-map (kbd "C-u") (lambda () (interactive) (evil-scroll-up nil) (beacon-blink)))
    (define-key evil-normal-state-map "n" (lambda () (interactive) (evil-ex-search-next) (recenter)))
    (define-key evil-normal-state-map "N" (lambda () (interactive) (evil-ex-search-previous) (recenter)))

    (defun amuzak/evil-x-no-yank ()
      (interactive)
      (let ((evil-this-register ?_))
        (call-interactively #'evil-delete-char)))
    (define-key evil-normal-state-map "x" #'amuzak/evil-x-no-yank)
    (defun amuzak/escape ()
      (interactive)
      (if (fboundp 'lsp-ui-doc-hide)   ; lsp-ui-doc usable => safe to call in
          (amuzak/lsp-ui-escape)       ; LSP buffers AND the doc child frame
        (evil-ex-nohighlight)))

    (defun amuzak/lsp-doc-cycle-safe ()
      (interactive)
      (if (and (fboundp 'lsp-ui-doc-hide)
               (fboundp 'amuzak/lsp-ui-doc-cycle))
          (amuzak/lsp-ui-doc-cycle)
        (user-error "lsp-ui isn't active; open an LSP buffer first")))

    (defun amuzak/lsp-doc-diag-cycle-safe ()
      (interactive)
      (if (and (fboundp 'lsp-ui-doc-hide)
               (fboundp 'amuzak/lsp-ui-doc-diagnostics-cycle))
          (amuzak/lsp-ui-doc-diagnostics-cycle)
        (user-error "lsp-ui isn't active; open an LSP buffer first")))

    (define-key evil-normal-state-map (kbd "<escape>") #'amuzak/escape)
    (define-key evil-normal-state-map "G" (lambda () (interactive) (evil-goto-line) (recenter)))
    (define-key evil-normal-state-map (kbd "<up>") (lambda () (interactive) (evil-window-increase-height 2)))
    (define-key evil-normal-state-map (kbd "<down>") (lambda () (interactive) (evil-window-decrease-height 2)))
    (define-key evil-normal-state-map (kbd "<left>") (lambda () (interactive) (evil-window-decrease-width 2)))
    (define-key evil-normal-state-map (kbd "<right>") (lambda () (interactive) (evil-window-increase-width 2)))
    (define-key evil-visual-state-map "<" 'evil-shift-left)
    (define-key evil-visual-state-map ">" 'evil-shift-right)

    (defun amuzak/evil-shift-keep-visual-line (orig beg end &optional count preserve-empty)
      (if (and (evil-visual-state-p)
               (eq evil-visual-selection 'line))
          (let ((m evil-visual-mark)
                (p evil-visual-point))
            (prog1 (funcall orig beg end count preserve-empty)
              (evil-visual-make-selection m p 'line)))
        (funcall orig beg end count preserve-empty)))
    (advice-add 'evil-shift-right :around #'amuzak/evil-shift-keep-visual-line)

    ;; window management
    (define-key evil-normal-state-map (kbd "C-k") 'evil-window-up)
    (define-key evil-normal-state-map (kbd "C-j") 'evil-window-down)
    (define-key evil-normal-state-map (kbd "C-h") 'evil-window-left)
    (define-key evil-normal-state-map (kbd "C-l") 'evil-window-right)
    (evil-set-undo-system 'undo-redo)
    ;; LSP Stuff
    (define-key evil-normal-state-map (kbd "K") #'amuzak/lsp-doc-cycle-safe)
    (define-key evil-normal-state-map (kbd "E") #'amuzak/lsp-doc-diag-cycle-safe)

    ;; DWIM in org on enter in normal mode
    (evil-define-key 'normal org-mode-map (kbd "RET") 'org-open-at-point))

  (use-package evil-collection
    :ensure
    :after evil
    :config
    (setq evil-collection-mode-list '(dashboard dired ibuffer))
    (evil-collection-init))

  (with-eval-after-load 'evil-maps
    (define-key evil-motion-state-map (kbd "RET") nil)
    (define-key evil-motion-state-map (kbd "TAB") nil))

  (use-package emacs :ensure nil :config (setq ring-bell-function #'ignore))
(with-eval-after-load 'evil
  (advice-add 'forward-evil-paragraph :around
    (lambda (orig &rest args)
      (let ((paragraph-start (default-value 'paragraph-start))
            (paragraph-separate (default-value 'paragraph-separate)))
        (apply orig args)))))

(use-package general
  :ensure t
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
    "x x" '(flycheck-projectile-list-errors :wk "Open Project Wide Issues")
    "g d" '(lsp-find-definition :wk "Go to Definitions")
    "g r" '(lsp-find-references :wk "Find References")
    "r n" '(lsp-rename :wk "Rename Symbol")
    "r w" '(lsp-restart-workspace :wk "Restart LSP")
    "k k" '(lsp-disconnect :wk "Stop LSP")
    "f m" '(apheleia-format-buffer :wk "Format Buffer"))

  ;; Rust / Cargo
  (amuzak/leader-keys
    "c c" '(:ignore t :wk "Cargo")
    "c c b" '(rustic-cargo-build :wk "Cargo Build")
    "c c r" '(rustic-cargo-run :wk "Cargo Run")
    "c c t" '(rustic-cargo-test :wk "Cargo Test")
    "c c k" '(rustic-cargo-check :wk "Cargo Check")
    "c c l" '(rustic-cargo-clippy :wk "Cargo Clippy")
    "c c f" '(rustic-cargo-fmt :wk "Cargo Fmt")
    "c c p" '(rustic-popup :wk "Cargo Popup Menu")
    "c c u" '(rustic-cargo-upgrade :wk "Cargo Upgrade Deps")
    "c c a" '(rustic-cargo-add :wk "Cargo Add Dependency")
    "c c m" '(rustic-cargo-rm :wk "Cargo Remove Dependency")
    "c c n" '(rustic-cargo-run-bin :wk "Cargo Run --bin (from file)")
    "c c d" '(dap-debug :wk "Debug (DAP)")
    "c c D" '(dap-hydra :wk "Debug Hydra Menu"))

  ;; Latex
  (defun clean-latex-project-aux-files ()
    (interactive)
    (let* ((root (if (fboundp 'project-root)
                     (let ((proj (project-current nil)))
                       (if proj (project-root proj) default-directory))
                   default-directory))
           (exts '("aux" "bbl" "bcf" "blg" "brf" "fdb_latexmk" "fls" "idx" "ilg" "ind" "lof" "log" "lot" "nav" "out" "run.xml" "snm" "synctex.gz" "toc"))
           (regex (concat "\\.\\(" (mapconcat #'identity exts "\\|") "\\)$"))
           (files (directory-files-recursively root regex)))
      (mapc #'delete-file files)
      (message "Cleaned %d auxiliary files." (length files))))

  (amuzak/leader-keys
    "l l l" '(TeX-command-run-all :wk "Compile Latex Project")
    "l l v" '(TeX-view :wk "View in PDF")
    "l l k" '(TeX-kill-job :wk "Stop Latex Compilation")
    "l l c" '(clean-latex-project-aux-files :wk "Full Clean Latex Project"))

  ;; LLM
  (amuzak/leader-keys
    "g g s" '(gptel-send :wk "Send LLM Query")
    "g g m" '(gptel-menu :wk "Open LLM Menu")
    "g g g" '(gptel :wk "Open LLM Buffer")
    "g g a" '(gptel-add-file :wk "Add File for LLM context")
    "g g t" '(gptel-agent :wk "Invoke LLM Tool Call")
    "g g r" '(gptel-rewrite :wk "Rewrite with LLM"))

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

  ;; Multiple Cursors
  (amuzak/leader-keys
    "m" '(:ignore t :wk "Multiple Cursors")
    "m a" '(evil-mc-make-all-cursors :wk "Cursor at all matches of word")
    "m m" '(evil-mc-make-and-goto-next-match :wk "Make cursor + Go to next match")
    "m M" '(evil-mc-make-and-goto-prev-match :wk "Make cursor + Go to prev match")
    "m s" '(evil-mc-skip-and-goto-next-match :wk "Skip Current + Go to next match")
    "m S" '(evil-mc-skip-and-goto-prev-match :wk "Skip Current + Go to next match")
    "m c" '(evil-mc-make-cursor-here :wk "Create cursor at current point")
    "m u" '(evil-mc-undo-last-added-cursor :wk "Undo last cursor created")
    "m q" '(evil-mc-undo-all-cursors :wk "Clear all cursors"))

  ;; Literate Programming Support
  (amuzak/leader-keys
    "j" '(:ignore t :wk "Jupyter/Notebook")
    "j p" '(my/babel-insert-python  :wk "Insert Python cell")
    "j r" '(my/babel-insert-r       :wk "Insert R cell")
    "j l" '(my/babel-insert-lisp    :wk "Insert emacs-lisp cell")
    "j s" '(my/babel-insert-sh      :wk "Insert shell cell")
    "j e" '(org-ctrl-c-ctrl-c       :wk "Execute block")
    "j a" '(my/babel-execute-buffer :wk "Run all blocks (till error)")
    "j f" '(my/babel-execute-from-point :wk "Run blocks from here")
    "j n" '(org-next-block          :wk "Next code block")
    "j N" '(org-previous-block      :wk "Previous code block")
    "j x" '(my/babel-toggle-output-and-src :wk "Toggle output/src")
    "j i" '(org-toggle-inline-images :wk "Toggle inline images")
    "j o" '(org-babel-jupyter-scratch-buffer :wk "Session scratch/REPL")
    "j d" '(org-edit-special        :wk "Edit src natively"))

  ;; Misc
    (defun amuzak/save-all-buffers ()
      (interactive)
      (save-some-buffers
       t
       (lambda ()
         (and (buffer-modified-p)
              (not (eq major-mode 'comint-mode))
              (not (derived-mode-p 'grease-mode))
              (not (string-match-p "\\*.*\\*" (buffer-name))))))

      (dolist (buf (buffer-list))
        (with-current-buffer buf
          (when (and (derived-mode-p 'grease-mode)
                     (buffer-modified-p))
            (grease-save))))

      (message "All files saved"))

  (amuzak/leader-keys
    "SPC" '(projectile-find-file :wk "Find file")
    "s g" '(consult-grep :wk "Search in Project")
    "p p" '(projectile-switch-project :wk "Switch Projects")
    "p a" '(projectile-add-known-project :wk "Add Project")
    "a" (lambda () (interactive) (evil-goto-first-line) (evil-visual-line) (evil-goto-line))
    "d d" '(dashboard-open :wk "Open Dashboard")
    "i p" '(org-download-screenshot :wk "Paste image from Clipboard")
    "l g" '(my/launch-lazygit :wk "Launch LazyGit")
    "f f" '(flash-jump :wk "Flash to Target")
    "c p" (lambda () (interactive) (let ((vertico-posframe-mode nil)) (call-interactively #'consult-yank-from-kill-ring)) :wk "Clipboard")
    "w w" '(amuzak/save-all-buffers :wk "Save file(s)")
    "q q" '((lambda () (interactive)
              (amuzak/save-all-buffers)
              (message "All files saved, exiting...")
              (kill-emacs))
            :wk "Save all and quit"))

  (general-define-key
   :states '(normal visual)
   "gcc" '(evilnc-comment-or-uncomment-lines :wk "Toggle comment")))

(electric-pair-mode 1)

;; Ignore angular brackets since that helps with code blocks
(setq electric-pair-inhibit-predicate
      (lambda (char)
        (if (char-equal char ?<)
            t
          (electric-pair-default-inhibit char))))

(add-hook 'before-save-hook 'delete-trailing-whitespace)

(defvar-local toggle-emptyline-removal nil
  "Variable to track the state of whitespace cleaning.")

(defun my-delete-excess-blank-lines ()
  "Search for and replace multiple consecutive newlines with a single newline."
  (save-excursion
    (goto-char (point-min))
    (while (re-search-forward "\n\n\n+" nil t)
      (replace-match "\n\n"))))

(define-minor-mode toggle-emptyline-removal
  "Toggle automatic cleaning of excessive blank lines on save."
  :lighter " CleanWS"
  (if toggle-emptyline-removal
      (add-hook 'before-save-hook #'my-delete-excess-blank-lines nil t)
    (remove-hook 'before-save-hook #'my-delete-excess-blank-lines t)))

(define-globalized-minor-mode global-emptyline-removal
  toggle-emptyline-removal toggle-emptyline-removal)

(global-emptyline-removal 1)

(global-auto-revert-mode 1)
(setq auto-revert-interval 0.5)
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

(setq org-confirm-babel-evaluate nil)

(setq backup-directory-alist '((".*" . "~/.config/emacs/backup")))

(setq gc-cons-threshold (* 100 1024 1024)) ; 100MB

(global-set-key [escape] 'keyboard-escape-quit)

(setq backup-directory-alist '((".*" . "~/.config/emacs/backups/")))

(setq-default tab-width 4)

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

(setq paragraph-start "\\([ \t]*$\\)\\|\\(^\\s-*$\\)")
(setq paragraph-separate "\\([ \t]*$\\)\\|\\(^\\s-*$\\)")

(use-package nerd-icons
  :ensure t
  :config
  (setq nerd-icons-font-family "Symbols Nerd Font Mono"))

(use-package nerd-icons-dired
  :ensure t
  :hook (dired-mode . nerd-icons-dired-mode))

(set-fontset-font t 'emoji "Segoe UI Emoji" nil 'prepend)
(set-fontset-font t 'symbol "Segoe UI Symbol" nil 'prepend)

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(setq display-line-numbers-type 'relative)

(global-display-line-numbers-mode 1)
(global-visual-line-mode t)

(use-package doom-themes
  :ensure t
  :custom
  (doom-themes-enable-bold t)   ; if nil, bold is universally disabled
  (doom-themes-enable-italic t) ; if nil, italics is universally disabled
  :config
  (load-theme 'doom-bluloco-dark t)
  (doom-themes-visual-bell-config)
  (doom-themes-org-config)
  (set-face-foreground 'vertical-border "grey80"))

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
   (rustic-mode . outline-indent-minor-mode)
   (rust-ts-mode . outline-indent-minor-mode)
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

(add-hook 'org-mode-hook #'font-lock-fontify-buffer)

(setq org-startup-folded t)

(setq org-hide-emphasis-markers t)
(use-package org-appear
  :ensure t
  :commands (org-appear-mode)
  :hook     (org-mode . org-appear-mode)
  :config
  (setq org-hide-emphasis-markers t)  ; Must be activated for org-appear to work
  (setq org-appear-autoemphasis   t   ; Show bold, italics, verbatim, etc.
              org-appear-autolinks      t   ; Show links
              org-appear-autosubmarkers t))

(setq org-hide-emphasis-markers t)
(custom-set-faces
 '(org-code ((t (:background "#2e3440" :foreground "#d8dee9" :box nil))))
 '(org-verbatim ((t (:background "#2e3440" :foreground "#d8dee9" :box nil)))))

(require 'org-tempo)

(add-to-list 'org-structure-template-alist '("se" . "src emacs-lisp"))
(add-to-list 'org-structure-template-alist '("sp" . "src python"))
(add-to-list 'org-structure-template-alist '("sr" . "src r"))
(add-to-list 'org-structure-template-alist '("sru" . "src rust"))
(add-to-list 'org-structure-template-alist '("ss" . "srp sh"))
(add-to-list 'org-structure-template-alist '("sc" . "src clojure"))

(add-hook 'org-mode-hook 'org-indent-mode)
(use-package org-bullets
  :ensure t)
(add-hook 'org-mode-hook (lambda () (org-bullets-mode 1)))

(setq org-log-done t
        org-auto-align-tags t
        org-tags-column -80
        org-fold-catch-invisible-edits 'show-and-error
        org-special-ctrl-a/e t
        org-insert-heading-respect-content t)

  ;; Indentation consistency: kill the phantom 2-space offsets and make
  ;; org's per-level indent match tab-width (4), same as evil-shift-width.
  (setq org-edit-src-content-indentation 0)
  (setq org-indent-indentation-per-level tab-width)
  (setq-default evil-shift-width tab-width)

  ;; Vim-style dumb indentation in org
  (add-hook 'org-mode-hook (lambda () (electric-indent-local-mode -1)))

  (defun amuzak/org-insert-inherited-indent ()
    "Insert the leading whitespace of the nearest previous non-blank line."
    (let ((indent (save-excursion
                    (beginning-of-line)
                    (and (re-search-backward "^[ \\t]*\\([^ \\t\\n]\\)" nil t)
                         (buffer-substring-no-properties
                          (line-beginning-position) (match-beginning 1))))))
      (when indent (insert indent))))

  (defun amuzak/org-newline-inherit-indent ()
    "Newline that copies the previous line's indent; never re-indents anything."
    (interactive)
    (newline)
    (amuzak/org-insert-inherited-indent))

  (defun amuzak/org-open-below ()
    "Evil `o' that inherits the previous line's indent."
    (interactive)
    (evil-insert-newline-below)
    (amuzak/org-insert-inherited-indent))

  (defun amuzak/org-open-above ()
    "Evil `O' that inherits the current line's indent."
    (interactive)
    (evil-insert-newline-above)
    (amuzak/org-insert-inherited-indent))

  (defun amuzak/org-insert-tab ()
    "In src blocks: advance to the next tab-width stop. Elsewhere: org-cycle."
    (interactive)
    (if (org-in-src-block-p)
        (insert (make-string (- tab-width (% (current-column) tab-width)) ?\s))
      (org-cycle)))

  (defun amuzak/org-insert-backtab ()
    "In src blocks: eat whitespace back toward the previous tab-width stop.
Stops at real text. Elsewhere: org-shifttab."
    (interactive)
    (if (org-in-src-block-p)
        (let* ((col (current-column))
               (rem (% col tab-width))
               (target (max 0 (- col (if (zerop rem) tab-width rem)))))
          (while (and (> (current-column) target)
                      (memq (char-before) '(?\s ?\t)))
            (delete-char -1)))
      (org-shifttab)))

  (with-eval-after-load 'org
    (with-eval-after-load 'evil
      (evil-define-key 'insert org-mode-map (kbd "RET") #'amuzak/org-newline-inherit-indent)
      (evil-define-key 'insert org-mode-map (kbd "TAB") #'amuzak/org-insert-tab)
      (evil-define-key 'insert org-mode-map (kbd "<backtab>") #'amuzak/org-insert-backtab)
      (evil-define-key 'normal org-mode-map "o" #'amuzak/org-open-below)
      (evil-define-key 'normal org-mode-map "O" #'amuzak/org-open-above)))

(plist-put org-format-latex-options :scale 1.35)
(use-package org-fragtog
  :ensure t
  :hook (org-mode-hook . org-fragtog-mode))

(use-package svg-tag-mode
  :ensure t
  :config
  (defconst date-re "[0-9]\\{4\\}-[0-9]\\{2\\}-[0-9]\\{2\\}")
  (defconst time-re "[0-9]\\{2\\}:[0-9]\\{2\\}")
  (defconst day-re "[A-Za-z]\\{3\\}")
  (defconst day-time-re (format "\\(%s\\)? ?\\(%s\\)?" day-re time-re))

  (defun svg-progress-percent (value)
    (svg-image (svg-lib-concat
                (svg-lib-progress-bar (/ (string-to-number value) 100.0)
                                      nil :margin 1 :stroke 2 :radius 3 :padding 2 :width 11)
                (svg-lib-tag (concat value "%")
                             nil :stroke 0 :margin 1)) :ascent 'center))

  (defun svg-progress-count (value)
    (let* ((seq (mapcar #'string-to-number (split-string value "/")))
           (count (float (car seq)))
           (total (float (cadr seq))))
      (svg-image (svg-lib-concat
                  (svg-lib-progress-bar (/ count total) nil
                                        :margin 1 :stroke 2 :radius 3 :padding 2 :width 11)
                  (svg-lib-tag value nil
                               :stroke 0 :margin 1)) :ascent 'center)))
  (setq svg-tag-tags
        `(
          ;; Task priority
          ("\\[#[A-Z]\\]" . ( (lambda (tag)
                                (svg-tag-make tag :face 'org-priority
                                              :beg 2 :end -1 :margin 0))))

          ;; Progress
          ("\\(\\[[0-9]\\{1,3\\}%\\]\\)" . ((lambda (tag)
                                              (svg-progress-percent (substring tag 1 -2)))))
          ("\\(\\[[0-9]+/[0-9]+\\]\\)" . ((lambda (tag)
                                            (svg-progress-count (substring tag 1 -1)))))

          ;; Citation of the form [cite:@Knuth:1984]
          ("\\(\\[cite:@[A-Za-z]+:\\)" . ((lambda (tag)
                                            (svg-tag-make tag
                                                          :inverse t
                                                          :beg 7 :end -1
                                                          :crop-right t))))
          ("\\[cite:@[A-Za-z]+:\\([0-9]+\\]\\)" . ((lambda (tag)
                                                     (svg-tag-make tag
                                                                   :end -1
                                                                   :crop-left t))))

          ;; Active date (with or without day name, with or without time)
          (,(format "\\(<%s>\\)" date-re) .
           ((lambda (tag)
              (svg-tag-make tag :beg 1 :end -1 :margin 1))))
          (,(format "\\(<%s \\)%s>" date-re day-time-re) .
           ((lambda (tag)
              (svg-tag-make tag :beg 1 :inverse nil :crop-right t :margin 1))))
          (,(format "<%s \\(%s>\\)" date-re day-time-re) .
           ((lambda (tag)
              (svg-tag-make tag :end -1 :inverse t :crop-left t :margin 1))))

          ;; Inactive date  (with or without day name, with or without time)
          (,(format "\\(\\[%s\\]\\)" date-re) .
           ((lambda (tag)
              (svg-tag-make tag :beg 1 :end -1 :margin 1 :face 'org-date))))
          (,(format "\\(\\[%s \\)%s\\]" date-re day-time-re) .
           ((lambda (tag)
              (svg-tag-make tag :beg 1 :inverse nil
                            :crop-right t :margin 1 :face 'org-date))))
          (,(format "\\[%s \\(%s\\]\\)" date-re day-time-re) .
           ((lambda (tag)
              (svg-tag-make tag :end -1 :inverse t
                            :crop-left t :margin 1 :face 'org-date)))))))

(add-hook 'org-mode-hook 'svg-tag-mode)

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

(use-package org-superstar
  :ensure t
  :config
  (setq org-superstar-leading-bullet " ")
  (setq org-superstar-special-todo-items t) ;; Makes TODO header bullets into boxes
  (setq org-superstar-todo-bullet-alist '(("TODO" . 9744)
                                          ("DONE" . 9744)
                                          ("IN-PROGRESS" . 9744)
                                          ("CANCELLED" . 9744))))

(defun my/prettify-symbols-setup ()
  (push '("[ ]" . "") prettify-symbols-alist)
  (push '("[X]" . "") prettify-symbols-alist)
  (push '("[-]" . "" ) prettify-symbols-alist)

  (push '("#+BEGIN_SRC" . ?≫) prettify-symbols-alist)
  (push '("#+END_SRC" . ?≫) prettify-symbols-alist)
  (push '("#+begin_src" . ?≫) prettify-symbols-alist)
  (push '("#+end_src" . ?≫) prettify-symbols-alist)

  (push '("#+BEGIN_QUOTE" . ?❝) prettify-symbols-alist)
  (push '("#+END_QUOTE" . ?❞) prettify-symbols-alist)

  (push '(":PROPERTIES:" . "") prettify-symbols-alist)

  (push '(":projects:" . "") prettify-symbols-alist)
  (push '(":work:"     . "") prettify-symbols-alist)
  (push '(":inbox:"    . "") prettify-symbols-alist)
  (push '(":task:"     . "") prettify-symbols-alist)
  (push '(":thesis:"   . "") prettify-symbols-alist)
  (push '(":uio:"      . "") prettify-symbols-alist)
  (push '(":emacs:"    . "") prettify-symbols-alist)
  (push '(":learn:"    . "") prettify-symbols-alist)
  (push '(":code:"     . "") prettify-symbols-alist)

  (prettify-symbols-mode))

(add-hook 'org-mode-hook        #'my/prettify-symbols-setup)
(add-hook 'org-agenda-mode-hook #'my/prettify-symbols-setup)

(use-package org-download
  :ensure (:host github :repo "abo-abo/org-download")
  :after org
  :custom
  (org-download-method 'directory)
  (org-download-image-dir "./images")
  ;; this is specifically a windows only solution
  (org-download-screenshot-method
   "powershell -command \"(Get-Clipboard -Format Image).Save('%s')\"")
  (org-download-annotate-function (lambda (_link) ""))
  :config
  (add-hook 'dired-mode-hook 'org-download-enable))

(setq org-startup-with-inline-images t)

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
           :if-new (file+head "Projects/${slug}.org" "#+title: ${title}\n#+STARTUP: showeverything\n")
           :unnarrowed t)

          ("a" "artifact"
           plain "%?"
           :if-new (file+head "Artifacts/${slug}.org" "#+title: ${title}\n#+STARTUP: showeverything\n")
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
  (setq dashboard-item-names
        '(("Agenda for the coming week:" . "Agenda")
          ("Agenda for today:" . "Agenda")))
  (setq dashboard-footer-icon "")
  (setq dashboard-footer-messages '("Simplicity is the Ultimate Sophistication. Think Simple."))
  (setq dashboard-filter-agenda-entry 'dashboard-no-filter-agenda)
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
(with-eval-after-load 'dashboard
  (defface my/dashboard-agenda-date
    '((t :background "#3d2b5e" :foreground "#e0c0ff" :inherit default))
    "Face for relative date in dashboard agenda.")

  (defun my/dashboard-agenda--formatted-time ()
    "Return a relative date string for the current agenda entry."
    (let* ((ts (or (org-entry-get (point) "SCHEDULED")
                   (org-entry-get (point) "DEADLINE")))
           (time   (and ts (org-time-string-to-time ts)))
           (now    (decode-time (current-time)))
           (today  (encode-time 0 0 0 (nth 3 now) (nth 4 now) (nth 5 now)))
           (target (and time
                        (let ((d (decode-time time)))
                          (encode-time 0 0 0 (nth 3 d) (nth 4 d) (nth 5 d)))))
           (diff   (and target
                        (round (/ (float-time (time-subtract target today))
                                  86400))))
           (label  (if (not diff) ""
                     (cond
                      ((= diff  0)  "today")
                      ((= diff  1)  "tomorrow")
                      ((= diff -1)  "yesterday")
                      ((> diff  0)  (format "in %d days" diff))
                      (t            (format "%d days ago" (abs diff)))))))
      (propertize label 'face 'my/dashboard-agenda-date)))

  (advice-add 'dashboard-agenda--formatted-time
              :override #'my/dashboard-agenda--formatted-time))

(use-package ghostel
  :ensure t)
(setopt ghostel-keymap-exceptions
        '("C-c" "C-x" "C-u" "C-h" "M-x" "M-:" "C-\\" "C-/"))

(use-package evil-ghostel
  :ensure t
  :after (ghostel evil)
  :hook (ghostel-mode . evil-ghostel-mode))

(setq ghostel-shell "C:/Program Files/PowerShell/7/pwsh.exe")

(defun amuzak/toggle-ghostel ()
  (interactive)
  (require 'ghostel)
  (let ((win (seq-some
              (lambda (buf)
                (when (with-current-buffer buf (derived-mode-p 'ghostel-mode))
                  (get-buffer-window buf t)))
              (buffer-list))))
    (if win
        (delete-window win)
      (select-window (split-window-right))
      (ghostel))))

(defun amuzak/ghostel-new ()
  (interactive)
  (require 'ghostel)
  (ghostel t))

(global-set-key (kbd "C-/")   #'amuzak/toggle-ghostel)

(defun my/launch-wezterm ()
  "Launch WezTerm in the project root or current directory."
  (interactive)
  (let ((dir (or (project-root (project-current)) default-directory)))
    (call-process "wezterm" nil 0 nil
                  "start" "--cwd" (expand-file-name dir)
                  "pwsh" "-NoLogo")))

(defun my/launch-lazygit ()
  "Launch lazygit in WezTerm from the current buffer's directory."
  (interactive)
  (let ((dir (expand-file-name default-directory)))
    (start-process "wezterm-lazygit" nil
                   "wezterm" "start"
                   "--cwd" dir
                   "lazygit")))

(use-package projectile
  :ensure t
  :init
  (projectile-mode +1))

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
  ;; (completion-category-overrides '((file (styles orderless basic partial-completion))))
  (completion-category-overrides '((file (styles orderless))))
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

;; Consult for more functionality and yank ring
(use-package consult
  :ensure t)

(use-package treesit-auto
  :ensure t
  :config
  (setq treesit-auto-install 'prompt)
  (global-treesit-auto-mode))
(setq treesit-font-lock-level 4)

(setq treesit-language-source-alist
      '((python . ("https://github.com/tree-sitter/tree-sitter-python" "v0.23.6"))
        (javascript . ("https://github.com/tree-sitter/tree-sitter-javascript" "v0.23.1" "src"))
        (typescript . ("https://github.com/tree-sitter/tree-sitter-typescript" "v0.23.2" "typescript/src"))
        (tsx . ("https://github.com/tree-sitter/tree-sitter-typescript" "v0.23.2" "tsx/src"))
        (bash . ("https://github.com/tree-sitter/tree-sitter-bash" "v0.23.3"))
        (c-sharp . ("https://github.com/tree-sitter/tree-sitter-c-sharp" "v0.23.1"))
        (elisp . ("https://github.com/Wilfred/tree-sitter-elisp" "main"))
        (java . ("https://github.com/tree-sitter/tree-sitter-java" "v0.23.5"))
        (lua . ("https://github.com/tree-sitter-grammars/tree-sitter-lua" "v0.2.0"))
        (css . ("https://github.com/tree-sitter/tree-sitter-css" "v0.23.2"))
        (html . ("https://github.com/tree-sitter/tree-sitter-html" "v0.23.2"))
        (go . ("https://github.com/tree-sitter/tree-sitter-go" "v0.23.4"))
        (rust . ("https://github.com/tree-sitter/tree-sitter-rust" "v0.23.2"))
        (c . ("https://github.com/tree-sitter/tree-sitter-c" "v0.23.5"))
        (cpp . ("https://github.com/tree-sitter/tree-sitter-cpp" "v0.23.4"))
        (yaml . ("https://github.com/tree-sitter-grammars/tree-sitter-yaml" "v0.7.2"))
        (toml . ("https://github.com/tree-sitter-grammars/tree-sitter-toml" "v0.7.0"))
        (json . ("https://github.com/tree-sitter/tree-sitter-json" "v0.24.8"))))

(use-package treesit-fold
  :ensure t
  :hook (prog-mode . treesit-fold-mode))

(use-package yasnippet
  :ensure t
  :config
  (setq yas-snippet-dirs
        (append '("~/.config/emacs/snippets")
                yas-snippet-dirs))
  (setq yas-indent-line 'fixed)
  (yas-global-mode 1)
  (yas-reload-all))

(use-package lsp-mode
  :ensure t
  :hook ((python-ts-mode . lsp-deferred)
         (rustic-mode . lsp-deferred)
         (rust-ts-mode . lsp-deferred)
         (js-ts-mode . lsp-deferred)
         (typescript-ts-mode . lsp-deferred)
         (c-ts-mode . lsp-deferred)
         (c++-ts-mode . lsp-deferred)
         (LaTeX-mode . lsp-deferred)
         (csharp-ts-mode . lsp-deferred))
  :custom
  (lsp-completion-provider :company)
  (lsp-diagnostics-provider :auto)
  (lsp-eldoc-enable-hover nil)
  (lsp-signature-auto-activate nil)
  (lsp-signature-render-documentation nil)
  (lsp-headerline-breadcrumb-enable t)
  (lsp-idle-delay 0.1)
  (lsp-enable-snippet t)
  (lsp-enable-file-watchers nil)
  (lsp-tex-server 'texlab)
  :commands (lsp lsp-deferred))
  (setq lsp-tex-server 'texlab)

(use-package lsp-ui
  :ensure t
  :hook (lsp-mode . lsp-ui-mode)
  :custom
  (lsp-ui-doc-enable t)
  (lsp-ui-doc-position 'at-point)
  (lsp-ui-sideline-enable nil)
  (lsp-ui-sideline-show-diagnostics nil)
  (lsp-ui-sideline-show-hover nil)
  (lsp-ui-peek-enable t))
  (defvar-local amuzak/lsp-doc-shown-point nil)
  (defvar-local amuzak/lsp-diag-shown-point nil)

  (defun amuzak/lsp-ui-doc-framep ()
    (or (string-prefix-p lsp-ui-doc--buffer-prefix (buffer-name))
        (let* ((f (selected-frame))
               (parent (and (frame-live-p f) (frame-parent f))))
          (and parent
               (eq f (frame-parameter parent 'lsp-ui-doc-frame))))))

  (defun amuzak/lsp-ui-doc--clear ()
    (setq amuzak/lsp-doc-shown-point nil
          amuzak/lsp-diag-shown-point nil))

  (defun amuzak/lsp-ui-doc--exit-focus ()
    (when-let ((pv (buffer-local-value 'lsp-ui-doc--parent-vars (current-buffer)))
               (src (plist-get pv :buffer)))
      (with-current-buffer src
        (amuzak/lsp-ui-doc--clear)))
    (lsp-ui-doc-hide))

  (defun amuzak/lsp-ui-doc-cycle ()
    (interactive)
    (cond
     ;; Focused inside the doc frame -> return to code, remove entirely.
     ((amuzak/lsp-ui-doc-framep) (amuzak/lsp-ui-doc--exit-focus))
     ;; Doc pinned here and cursor still on it -> move into the doc frame.
     ((and amuzak/lsp-doc-shown-point
           (equal (point) amuzak/lsp-doc-shown-point)
           (lsp-ui-doc--visible-p))
      (lsp-ui-doc-focus-frame))
     ;; Otherwise -> pin the hover doc at point.
     (t
      (lsp-ui-doc-show)
      (amuzak/lsp-ui-doc--clear)
      (setq amuzak/lsp-doc-shown-point (point)))))

  (defun amuzak/lsp-ui-doc-diagnostics-string ()
    "Return a formatted string of the flycheck diagnostics on the current line."
    (when (and (bound-and-true-p flycheck-mode)
               (fboundp 'flycheck-overlay-errors-in))
      (let ((errs (flycheck-overlay-errors-in (line-beginning-position)
                                              (1+ (line-end-position)))))
        (when errs
          (mapconcat
           (lambda (e)
             (format "[%s] %s"
                     (flycheck-error-level e)
                     (flycheck-error-format-message-and-id e)))
           errs "\n")))))

  (defun amuzak/lsp-ui-doc-diagnostics-cycle ()
    (interactive)
    (cond
     ;; Focused inside the doc frame -> return to code, remove entirely.
     ((amuzak/lsp-ui-doc-framep) (amuzak/lsp-ui-doc--exit-focus))
     ;; Popup pinned here and cursor still on it -> move into the frame.
     ((and amuzak/lsp-diag-shown-point
           (equal (point) amuzak/lsp-diag-shown-point)
           (lsp-ui-doc--visible-p))
      (lsp-ui-doc-focus-frame))
     ;; Otherwise -> pin the diagnostics at point (or clear if none).
     (t
      (let ((str (amuzak/lsp-ui-doc-diagnostics-string)))
        (if str
            (progn
              (lsp-ui-doc--display "Diagnostics" str)
              (amuzak/lsp-ui-doc--clear)
              (setq amuzak/lsp-diag-shown-point (point)))
          (amuzak/lsp-ui-doc--clear)
          (lsp-ui-doc-hide))))))

  (defun amuzak/lsp-ui-escape ()
    (interactive)
    (cond
     ;; Focused inside the popup frame -> return to code and remove popup.
     ((amuzak/lsp-ui-doc-framep) (amuzak/lsp-ui-doc--exit-focus))
     ;; Some popup (pinned doc/diag, or the plain hover doc) is visible -> close it.
     ((lsp-ui-doc--visible-p)
      (amuzak/lsp-ui-doc--clear)
      (lsp-ui-doc-hide))
     ;; Nothing open -> default escape action.
     (t (evil-ex-nohighlight))))

  (defun amuzak/lsp-ui-doc-maybe-hide ()
    "Hide the pinned lsp-ui-doc if the cursor moved off its anchor."
    (when (or (and amuzak/lsp-doc-shown-point
                   (not (equal (point) amuzak/lsp-doc-shown-point)))
              (and amuzak/lsp-diag-shown-point
                   (not (equal (point) amuzak/lsp-diag-shown-point))))
      (amuzak/lsp-ui-doc--clear)
      (lsp-ui-doc-hide)))

  ;; Auto-hide the pinned popup as soon as the cursor moves.
  (add-hook 'post-command-hook #'amuzak/lsp-ui-doc-maybe-hide)

  (with-eval-after-load 'lsp-ui-doc
    ;; K / E also work while focused inside the doc frame, and make sure
    ;; evil is in normal state there so the binding actually fires.
    (define-key lsp-ui-doc-frame-mode-map (kbd "K") #'amuzak/lsp-ui-doc-cycle)
    (define-key lsp-ui-doc-frame-mode-map (kbd "E") #'amuzak/lsp-ui-doc-diagnostics-cycle)
    (with-eval-after-load 'evil
      (advice-add 'lsp-ui-doc-focus-frame :after
                  (lambda (&rest _)
                    (when (bound-and-true-p evil-mode)
                      (evil-normal-state))))))

(use-package company
  :ensure t
  :hook (lsp-mode . company-mode)
  :custom
  (company-minimum-prefix-length 1)
  (company-idle-delay 0.02)
  (company-selection-wrap-around t))

(add-hook 'lsp-completion-mode-hook
          (lambda ()
            (setq-local company-backends
                        (cl-substitute '(company-yasnippet :with company-capf :separate)
                                       'company-capf company-backends))))

(use-package flycheck
  :ensure t
  :hook (text-mode org-mode lsp-mode prog-mode)
  :custom
  (flycheck-display-errors-function nil))
(with-eval-after-load 'flycheck
  (set-face-attribute 'flycheck-error nil
                      :underline '(:color "#e06c75" :style wave))
  (set-face-attribute 'flycheck-warning nil
                      :underline '(:color "#e5c07b" :style wave))
  (set-face-attribute 'flycheck-info nil
                      :underline '(:color "#61afef" :style wave)))

(use-package flycheck-projectile
  :ensure t
  :after (flycheck projectile))

(use-package apheleia
  :ensure t
  :defer t
  :hook ((text-mode lsp-mode prog-mode) . apheleia-mode)
  :config
  (setf (alist-get 'python-ts-mode apheleia-mode-alist) '(ruff))
  (setf (alist-get 'csharp-ts-mode apheleia-mode-alist) '(csharpier))
  (setf (alist-get 'rustic-mode apheleia-mode-alist) '(rustfmt))
  (setf (alist-get 'rust-ts-mode apheleia-mode-alist) '(rustfmt)))

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
  :hook ((org-src-mode) . lsp-bridge-mode)
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
  :custom
  (lsp-pyright-langserver-command "basedpyright")
  :hook ((python-mode . (lambda () (require 'lsp-pyright) (lsp-deferred)))
         (python-ts-mode . (lambda () (require 'lsp-pyright) (lsp-deferred)))))

(use-package unity
  :ensure (:host github :repo "elizagamedev/unity.el")
  :commands (unity-mode))

(use-package rustic
  :ensure t
  :after lsp-mode
  :custom
  (rustic-lsp-server 'rust-analyzer)
  (rustic-analyzer-command '("rust-analyzer"))
  (rustic-format-on-save t)
  (rustic-cargo-auto-add-missing-dependencies t)
  (rustic-compile-command "cargo build")
  (rustic-compile-backtrace 0)
  :config
  ;; Enable rust-analyzer inline type hints
  (setq lsp-rust-analyzer-display-chaining-hints t)
  (setq lsp-rust-analyzer-display-parameter-hints t)
  (setq lsp-rust-analyzer-display-reborrow-hints t)
  (setq lsp-rust-analyzer-server-display-inlay-hints t)
  (setq lsp-rust-analyzer-cargo-all-features t)
  (setq lsp-rust-analyzer-cargo-load-out-dirs-from-check t)
  (setq lsp-rust-analyzer-proc-macro-enable t))

(defun rustic-cargo-run-bin (bin-name)
  (interactive
   (let* ((file (buffer-file-name))
          (bin (when file
                 (save-match-data
                   (cond
                    ;; src/bin/foo.rs or src/bin/foo/ (just the bin name)
                    ((string-match "src/bin/\\([^/]+?\\)\\(\\.rs\\|/main\\.rs\\)?$" file)
                     (match-string 1 file))
                    ;; src/main.rs → use package name via cargo metadata
                    ((string-match "src/main\\.rs$" file)
                     nil)
                    (t nil))))))
     (list (read-from-minibuffer "Cargo run --bin: "
                                  (or bin "")
                                  nil nil 'rustic-run-history))))
  (let ((rustic-run-arguments (format "--bin %s" bin-name)))
    (rustic-cargo-run-command rustic-run-arguments)))

(use-package dap-mode
  :ensure t
  :after lsp-mode
  :custom
  (dap-auto-configure-features '(sessions locals controls tooltip))
  :config
  (dap-auto-configure-mode))

(with-eval-after-load 'dap-mode
  (require 'dap-gdb-lldb)
  (dap-gdb-lldb-setup))

;; Automatically load debug adapter when Rust LSP activates
(with-eval-after-load 'lsp-rust
  (require 'dap-gdb-lldb))

(use-package jupyter
  :ensure (:host github :repo "emacs-jupyter/jupyter")
  :config
  (require 'jupyter-R)

  (org-babel-do-load-languages
   'org-babel-load-languages
   '((emacs-lisp . t)
     (shell . t)
     (python . t)
     (jupyter . t)))

  (setq org-babel-default-header-args:jupyter-python
        '((:session . "py") (:kernel . "python")))
  (setq org-babel-default-header-args:jupyter-R
        '((:session . "r") (:kernel . "ir")
          (:display . "plain")))

  (org-babel-jupyter-override-src-block "python")
  (org-babel-jupyter-override-src-block "R"))

(defun my/babel-insert (lang &optional session)
  (let* ((sess (if session (format " :session %s" session) ""))
         (header (format "#+begin_src %s%s\n" lang sess)))
    (unless (bolp) (newline))
    (insert header)
    (let ((pt (point)))
      (insert "#+end_src")
      (goto-char pt))))

(defun my/babel-insert-python () (interactive) (my/babel-insert "python" "py"))
(defun my/babel-insert-r      () (interactive) (my/babel-insert "R" "r"))
(defun my/babel-insert-lisp   () (interactive) (my/babel-insert "emacs-lisp" nil))
(defun my/babel-insert-sh     () (interactive) (my/babel-insert "sh" nil))

(defvar my/babel-src-regexp "^#\\+begin_src\\|^#\\+BEGIN_SRC"
  "Regexp matching a #+begin_src line (either case).")

(defun my/babel-toggle-output-and-src ()
  (interactive)
  (if (org-in-src-block-p)
      (let ((pos (org-babel-where-is-src-block-result)))
        (if pos
            (goto-char pos)
          (message "This block has no results yet")))
    (org-previous-block 1 my/babel-src-regexp)))

(defun my/babel-src-positions (beg end)
  (let (positions)
    (save-excursion
      (goto-char beg)
      (while (re-search-forward my/babel-src-regexp end t)
        (push (match-beginning 0) positions)))
    (nreverse positions)))

(defun my/babel-execute-region (beg end)
  (let ((blocks (my/babel-src-positions beg end))
        (count 0))
    (condition-case err
        (progn
          (dolist (pos blocks)
            (save-excursion
              (goto-char pos)
              (org-babel-execute-src-block))
            (setq count (1+ count)))
          (message "Ran %d blocks" count))
      (error
       (message "Stopped after %d blocks: %s" count (error-message-string err))))))

(defun my/babel-execute-buffer ()
  (interactive)
  (my/babel-execute-region (point-min) (point-max)))

(defun my/babel-execute-from-point ()
  (interactive)
  (let ((beg (save-excursion
               (goto-char (point))
               (if (re-search-backward my/babel-src-regexp nil t)
                   (match-beginning 0)
                 (point)))))
    (my/babel-execute-region beg (point-max))))

(with-eval-after-load 'general
    (setq org-src-tab-acts-natively t
          org-src-fontify-natively t)
    (add-hook 'org-babel-after-execute-hook #'org-redisplay-inline-images)
    (setq org-image-actual-width '(800)))
(setq flycheck-disabled-checkers '(org-lint))

(use-package tex
  :ensure auctex
  :config
  (setq TeX-command-default "LaTeXMk")
  (setq TeX-save-query nil)
  (setq TeX-show-compilation nil)
  (setq TeX-parse-self t)
  (setq-default TeX-master nil)
  (add-to-list 'TeX-view-program-list
                   '("Sioyek"  "sioyek.exe --reuse-window --forward-search-file \"%b\" --forward-search-line %n --inverse-search \"emacsclient --no-wait +%2:%3 %1\" \"%o\""))

  (add-to-list 'TeX-view-program-selection '(output-pdf "Sioyek"))
  (setq TeX-source-correlate-mode t)
  (setq TeX-source-correlate-start-server t)
  (setq TeX-source-correlate-method 'synctex)

  (add-hook 'LaTeX-mode-hook
            (lambda ()
              (add-hook 'after-save-hook
                        (lambda () (TeX-command "LaTeXMk" 'TeX-master-file -1))
                        nil t))))
(server-start)

(use-package evil-tex
  :ensure t
  :after tex evil
  :hook (LaTeX-mode . evil-tex-mode))

;; citar
(use-package citar
  :ensure t
  :init
  (put 'citar-bibliography 'safe-local-variable #'listp)
  :hook
  (LaTeX-mode . (lambda ()
                  (add-hook 'completion-at-point-functions 'citar-capf -100 t))))

(elpaca compat)
(elpaca-wait)

(use-package transient :ensure t)
(elpaca-wait)

(use-package gptel-openrouter
  :ensure (:host github :repo "bharadswami/gptel-openrouter")
  :after gptel)

(use-package gptel
  :ensure t
  :config
  ;; API key is read from ~/.authinfo (machine openrouter.ai).
  (setq gptel-backend
        (gptel-openrouter-make-backend "OpenRouter"
          :key (lambda ()
                 (auth-source-pick-first-password
                  :host "openrouter.ai"
                  :user "apikey"))
          :stream t))

  (gptel-openrouter-auto-refresh-mode 1)

  (setq gptel-model 'openrouter/auto
        gptel-use-curl t
        gptel-default-mode #'org-mode
        gptel-org-branching-context t
        gptel-expert-commands t
        gptel-highlight-methods '(face))
  (setf (alist-get 'org-mode gptel-prompt-prefix-alist) "@user\n"
        (alist-get 'org-mode gptel-response-prefix-alist) "@assistant\n")
  (custom-set-faces
   '(gptel-response-highlight ((t (:background "#112233" :extend t))))))
(add-hook 'gptel-mode-hook (lambda () (gptel-highlight-mode +1)))

(defvar my/gptel-save-dir
  (expand-file-name "~/emacs/backups/gptel_conversations/")
  "Directory for auto-saved gptel buffers.")

(defun my/gptel-auto-save ()
  "Save the current gptel buffer to `my/gptel-save-dir'."
  (when gptel-mode
    (if (buffer-file-name)
        (save-buffer)
      (unless (file-directory-p my/gptel-save-dir)
        (make-directory my/gptel-save-dir t))
      (let* ((ext (if (eq major-mode 'org-mode) "org" "md"))
             (slug (replace-regexp-in-string
                    "[^a-zA-Z0-9_-]" "-"
                    (downcase (buffer-name))))
             (timestamp (format-time-string "%Y%m%dT%H%M%S"))
             (filename (expand-file-name
                        (format "%s-%s.%s" timestamp slug ext)
                        my/gptel-save-dir)))
        (remove-hook 'before-save-hook #'gptel--save-state t)
        (write-file filename)
        (add-hook 'before-save-hook #'gptel--save-state nil t)))))

(add-hook 'gptel-post-response-functions
          (lambda (_ _) (my/gptel-auto-save)))

(add-hook 'gptel-mode-hook (lambda () (gptel-highlight-mode +1)))

(use-package gptel-agent
  :ensure (:host github :repo "karthink/gptel-agent")
  :after gptel
  :config
  (gptel-agent-update))

(use-package beacon
  :ensure t
  :config
  (beacon-mode 1))

(use-package grease
  :elpaca (:host github :repo "mwac-dev/grease.el")
  :commands (grease-open grease-toggle grease-here)
  :init
  (setq grease-skip-confirm-for-simple-edits t
        grease-directory-face-foreground "#f8c759"
        grease-show-hidden t
        grease-preview-writable nil)
  :hook (grease-mode . (lambda ()
                          (olivetti-mode 1))))

(use-package undo-fu
  :elpaca t)

(setq evil-undo-system 'undo-fu)

(with-eval-after-load 'evil
  (define-key evil-normal-state-map (kbd "C-r") 'evil-redo))

(use-package evil-surround
  :ensure t
  :init
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

(use-package good-scroll
  :ensure t
  :config
  (good-scroll-mode 1))

;; Required for search match counts in the modeline
(use-package anzu
  :ensure t
  :config (global-anzu-mode +1))

;; evil integration
(use-package evil-anzu
  :ensure t
  :after (evil anzu))

(use-package telephone-line
  :ensure t
  :init
  (telephone-line-mode 1)
  :config

  (setq telephone-line-height 24)
  (setq telephone-line-evil-use-short-tag nil))

(use-package symbol-overlay
  :ensure t
  :init
  (setq symbol-overlay-idle-time 0.2)
  :config
  (set-face-background 'symbol-overlay-default-face "#694b35")
  :hook ((text-mode lsp-mode prog-mode) . symbol-overlay-mode))

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

(use-package ripgrep
  :ensure (:host github :repo "https://github.com/nlamirault/ripgrep.el"))

(use-package flash
  :ensure t
  :commands (flash-jump flash-jump-continue flash-treesitter)
  :custom
  (flash-multi-window t)
  :init
  (with-eval-after-load 'evil
    (require 'flash-evil)
    (flash-evil-setup t))
  :config
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
  (setq-default git-gutter:start-revision "HEAD")
  (global-git-gutter-mode +1))

(defun amuzak/git-gutter-refresh ()
  "Refresh git-gutter for the current buffer if enabled."
  (when (bound-and-true-p git-gutter-mode)
    (git-gutter)))

(add-hook 'focus-in-hook #'amuzak/git-gutter-refresh)

(add-function :before window-buffer-change-functions
              #'amuzak/git-gutter-refresh)

(use-package git-gutter-fringe
  :ensure t
  :after git-gutter
  :config
  (setq-default fringes-outside-margins t)
  (fringe-mode '(15 . 15)))

(use-package helpful
  :ensure t)

(use-package evil-mc
  :ensure (:host github :repo "gabesoft/evil-mc")
  :after evil
  :config
  (global-evil-mc-mode 1)
  (setq evil-mc-key-map nil))

(use-package pi-coding-agent
  :ensure t
  :init (defalias 'pi 'pi-coding-agent))

(add-to-list 'exec-path "C:/bin/")
