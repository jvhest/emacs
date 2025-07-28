;;; config.el --- emacs configuration      -*- lexical-binding: t; -*-

;; Maintainer: Jan van Hest
;; Email: jan.vanhest@gmail.com

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;;; Commentary:

;; Config file for EMACS.

;;; Code:

(defvar my/compile-on-save nil
  "When non-nil, compile the file after saving it.")

(defvar my/compile-on-startup nil
  "When non-nil, compile EMACS LISP sources for the modules on startup.")

(use-package emacs
  :demand t
  :hook
  ;; Make shebang (#!) file executable when saved
  (after-save . executable-make-buffer-file-executable-if-script-p)

  :custom
  (large-file-warning-threshold 100000000)
  (global-auto-revert-non-file-buffers t)
  (kill-do-not-save-duplicates t)

  :config
  (setq-default
   help-window-select t                      ; Focus new help windows when opened
   max-lisp-eval-depth 2000
   byte-compile--use-old-handlers nil        ; Use the most recent byte code ops
   vc-follow-symlinks t                      ; Always follow symbolic links
   save-interprogram-paste-before-kill t     ; Save paste history when killing Emacs
   repeat-mode 1))

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;
;; CORE.ORG
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;
;;

(defvar var-dir (expand-file-name "var" user-emacs-directory))

(defvar lisp-source-dir (expand-file-name "site-lisp/" user-emacs-directory))
(add-to-list 'load-path lisp-source-dir t)

(let ((jh-info-dir (expand-file-name "docs/dir" user-emacs-directory)))
  (when (file-exists-p jh-info-dir)
    (require 'info)
    (info-initialize)
    (cl-pushnew (file-name-directory jh-info-dir) Info-directory-list)))

(defvar my/compile-on-save nil
  "When non-nil, compile the file after saving it.")

(defvar my/compile-on-startup nil
  "When non-nil, compile EMACS LISP sources for the modules on startup.")

(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name
        "straight/repos/straight.el/bootstrap.el"
        (or (bound-and-true-p straight-base-dir)
            user-emacs-directory)))
      (bootstrap-version 7))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

(use-package straight
  :custom
  (straight-use-package-by-default t))
;; :init
;; (setq use-package-expand-minimally t))

(use-package no-littering
  :demand t
  :config
  (setq custom-file (no-littering-expand-etc-file-name "custom.el"))
  (setq auto-save-file-name-transforms
        `((".*" ,(no-littering-expand-var-file-name "auto-save/") t)))
  (setq backup-directory-alist
        `((".*" . ,(no-littering-expand-var-file-name "backup/")))))

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;
;; UI.ORG
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;
;;

(defvar my/frame-transparency 90
  "Frame transparency.")

(defvar my/display-line-numbers-enable
  '(prog-mode-hook conf-mode-hook) "Modes with line-numbers.")

(use-package emacs
  :hook
  (text-mode . variable-pitch-mode)

  :custom
  ;; better scrolling experience
  (scroll-margin 8)
  (fast-but-imprecise-scrolling t)  ;; Make scrolling less stuttered
  (scroll-conservatively 101)       ;; > 100
  (scroll-preserve-screen-position t)
  (auto-window-vscroll nil)

  :config
  ;; line-numbers
  (dolist (mode my/display-line-numbers-enable)
    (add-hook mode 'display-line-numbers-mode))
  (setq-default display-line-numbers-width 3    ;; Enough space for big files
                display-line-numbers-widen t)   ;; Enable dynamic sizing of line number width

  ;; general ui settings
  (global-prettify-symbols-mode t)   ;; Enables us to use ligatures in Emacs.

  ;; frame settings
  ;; activate transparency on startup
  (set-frame-parameter nil 'alpha
                       `(,my/frame-transparency
                         ,my/frame-transparency))
  (setq frame-title-format '("%b")
        frame-resize-pixelwise t
        frame-inhibit-implied-resize t)

  (setq ring-bell-function #'ignore
        visible-bell nil
        use-short-answers t        ;; Use "y" and "n" answers
        auto-window-vscroll nil)   ;; Make scrolling less stuttered

  (blink-cursor-mode -1)
  (tooltip-mode -1))

(set-face-attribute 'default nil
                    :family "JetBrainsMono Nerd Font"
                    :height 130
                    :weight 'semi-light)

(set-face-attribute 'fixed-pitch nil
                    :family "JetBrainsMono Nerd Font"
                    :height 130
                    :weight 'semi-light)

(set-face-attribute 'variable-pitch nil
                    :family "JetBrainsMono Nerd Font"
                    :height 135
                    :weight 'regular)

(set-face-attribute 'mode-line nil
                    :family "SpaceMono Nerd Font"
                    :height 130
                    :weight 'semi-light)

(use-package all-the-icons-dired)

(setq custom-safe-themes t)

(setq doom-theme nil)

(require-theme 'modus-themes)
(setq modus-themes-custom-auto-reload nil
      ;; modus-themes-to-toggle '(modus-vivendi-deuteranopia
      ;;                          modus-operandi-deuteranopia)
      modus-themes-to-toggle '(modus-vivendi-tinted
                               modus-operandi-tinted)
      modus-themes-mixed-fonts t
      modus-themes-variable-pitch-ui t
      modus-themes-italic-constructs t
      modus-themes-bold-constructs t
      modus-themes-completions
      '((matches . (extrabold intense))
              (selection . (extrabold intense))
              (popup . (extrabold intense)))
      modus-themes-prompts '(extrabold)
      modus-themes-headings
      '((agenda-structure . (fixed-pitch light 2.2))
              (agenda-date . (fixed-pitch regular 1.3))
              (t . (regular 1.15)))
      modus-themes-fringes 'subtle
      modus-themes-tabs-accented t
      modus-themes-paren-match '(bold intense)
      modus-themes-org-blocks 'tinted-background
      modus-themes-scale-headings t
      modus-themes-region '(bg-only))

(setq modus-themes-common-palette-overrides
      '((bg-mode-line-active bg-lavender)
              (bg-mode-line-inactive bg-dim)
              (border-mode-line-inactive bg-inactive)
              (fringe subtle)
              (bg-completion gray)
              (bg-paren-match bg-yellow-intense)))

(setq modus-themes-headings
      '((1 . (extrabold 1.35))
        (2 . (bold 1.28))
        (3 . (bold 1.22))
        (4 . (bold 1.17))
        (5 . (bold 1.14))
        (t . (semibold 1.1))))

(load-theme (car modus-themes-to-toggle) t)

(define-key global-map (kbd "<f5>") #'modus-themes-toggle)

(use-package doom-modeline
  ;; Start up the modeline after initialization is finished
  :hook (after-init . doom-modeline-mode)
  :custom
  (doom-modeline-height 30)
  (doom-modeline-bar-width 6)
  (doom-modeline-buffer-encoding t)
  (doom-modeline-lsp t)
  (doom-modeline-icon nil)
  (doom-modeline-minor-modes nil)
  (doom-modeline-buffer-file-name-style 'relative-to-project))

(use-package posframe)

(use-package hydra
  :hook (emacs-lisp-mode . hydra-add-imenu)
  :init
  (setq hydra-hint-display-type 'posframe)

  (with-eval-after-load 'posframe
    (defun hydra-set-posframe-show-params ()
      "Set hydra-posframe style."
      (setq hydra-posframe-show-params
            `( :left-fringe 8
               :right-fringe 8
               :internal-border-width 2
               :background-color ,(face-background 'tooltip nil t)
               :foreground-color ,(face-foreground 'tooltip nil t)
               :lines-truncate t
               :poshandler posframe-poshandler-frame-bottom-center)))
    (hydra-set-posframe-show-params)
    (add-hook 'after-load-theme-hook #'hydra-set-posframe-show-params t)))

(use-package pretty-hydra)

(use-package hide-mode-line
  :hook ((shell-mode . hide-mode-line-mode)))

(use-package hl-line
  :straight (:type built-in)
  :config
  (defvar global-hi-line-sticky-flag nil)
  (global-hl-line-mode -1))

(use-package hl-todo
  :init (global-hl-todo-mode))

(use-package paren
  :straight (:type built-in)
  :commands (show-paren-mode)
  :hook ((prog-mode . show-paren-mode)
         (org-src-mode . show-paren-mode))
  :config
  ;; (show-paren-mode 1)
  (setq show-paren-highlight-openparen t        ;; Always show the matching parenthesis.
        show-paren-delay 0
        show-paren-when-point-inside-paren t))  ;; Show parenthesis when inside a block.

(use-package helpful
  :bind
  (([remap describe-command] . helpful-command)
   ([remap describe-function] . helpful-callable)  ; help functions & macros
   ([remap describe-key] . helpful-key)
   ([remap describe-symbol] . helpful-symbol)
   ([remap describe-variable] . helpful-variable)
   ("C-h F" . helpful-function)                    ; help functions
   ("C-h K" . describe-keymap)
   :map helpful-mode-map
   ([remap revert-buffer] . helpful-update)))

(use-package which-key
  :hook (after-init . which-key-mode)
  :config
  (setq which-key-separator " → " )
  (setq which-key-unicode-correction 3)
  (setq which-key-prefix-prefix "... ")
  (setq which-key-max-display-columns 3)
  (setq which-key-idle-delay 1.0)
  (setq which-key-idle-secondary-delay 0.25)
  (setq which-key-add-column-padding 5)
  (setq which-key-max-description-length 40)
  (setq which-key-sort-order 'which-key-key-order-alpha))

(use-package project
  :straight (:type built-in)
  :demand t
  :custom ('project-list-file (no-littering-expand-var-file-name "projects")))

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;
;; EDITOR.ORG
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;
;;

(defvar my/fill-width 110
  "The default width at which to wrap text.")

(defvar my/tab-width 2
  "The default width for indentation, in spaces.")

(use-package emacs
  :hook
  (text-mode . auto-fill-mode)

  ;; :bind ("C-s" . save-buffer)

  :init
  ;; No backup files
  (setq make-backup-files nil
        backup-inhibited nil
        create-lockfiles nil)

  (setq-default
   indent-tabs-mode nil
   tab-width my/tab-width
   fill-column my/fill-width               ; Wrap lines after this point
   compilation-scroll-output 'first-error  ; Stop at first error in compilation
   word-wrap t
   require-final-newline t
   sentence-end-double-space nil
   save-interprogram-paste-before-kill t
   ;; Better support for files with long lines
   bidi-paragraph-direction 'left-to-right
   bidi-inhibit-bpa t)

  (set-default-coding-systems 'utf-8)
  (global-superword-mode 1)                ; e.g. this-is-a-symbol is one word
  (global-auto-revert-mode 1)              ; Revert buffers when file has changed
  (global-so-long-mode 1))                 ; Support for files with long lines

(use-package recentf
  :hook ((prog-mode text-mode) . recentf-mode)
  :custom (recentf-save-file
           (no-littering-expand-var-file-name "recentf"))
  :init
  (setq recentf-max-saved-items 1000 ;; Total amount of saved recent files
        recentf-auto-cleanup 'never) ;;  Never clean the history but append and remove the last
  (recentf-mode))

(use-package saveplace
  :init (save-place-mode))

(use-package savehist
  :init (savehist-mode 1)
  :custom (savehist-file
           (no-littering-expand-var-file-name "history"))
  :config
  (setq history-length 500)
  (setq history-delete-duplicates t)
  (setq savehist-save-minibuffer-history t)
  (setq savehist-additional-variables '(register-alist kill-ring)))

;; (setq electric-pair-pairs '((?\{ . ?\}) (?\( . ?\)) (?\[ . ?\]) (?\" . ?\")))
(electric-pair-mode -1)

(use-package evil-mc
  :bind
  (("C-S-c C-S-c" . evil-mc-make-cursor-in-visual-selection-beg)

  ("C->" . evil-mc-make-and-goto-next-match)
  ("C-<" . evil-mc-make-and-goto-prev-match)
  ("C-c C-<" . evil-mc-make-all-cursors)

  ("C-\"" . evil-mc-skip-and-goto-next-match)
  ("C-:" . evil-mc-undo-all-cursors))
  :config
  (global-evil-mc-mode 1))

(use-package aggressive-indent
  :defer 5
  :hook ((emacs-lisp-mode lisp-mode org-src-mode) . aggressive-indent-mode))

(use-package yasnippet
  :diminish yas-global-mode

  :commands (yas-global-mode)

  :hook ((prog-mode text-mode) . yas-global-mode)

  :config
  (setq yas-snippet-dirs (list (expand-file-name "snippets" user-emacs-directory)))
  (yas-global-mode))

(use-package yasnippet-snippets
  :after yasnippet)

(use-package emacs
  :straight (:type built-in)
  :preface
  (defun toggle-line-numbers ()
    "Toggle-line-numbers on/off."
    (cond ((fboundp 'display-line-numbers-mode)
           (display-line-numbers-mode (if display-line-numbers-mode -1 1)))
          ((fboundp 'global-linum-mode)
           (global-linum-mode (if global-linum-mode -1 1)))))

  (defun toggle-transparency ()
    "Toggle theme's transparency."
    (let ((frame-alpha (frame-parameter nil 'alpha)))
      (if (or (not frame-alpha)
              (= (cadr frame-alpha) 100))
          (set-frame-parameter nil 'alpha
                               `(,my/frame-transparency
                                 ,my/frame-transparency))
        (set-frame-parameter nil 'alpha '(100 100)))))

;  :general
;  (my-leader
;    "t h" '(toggles-hydra/body :wk "Toggle Hydra"))

  :config
  (pretty-hydra-define toggle-hydra
    (:title "Toggles" :color amaranth :quit-key ("q" "C-g"))
    ("Basic"
     (("n" (toggle-line-numbers) "line number")
      ("a" global-aggressive-indent-mode "aggressive indent" :toggle t)
      ("c" flyspell-mode "spell check" :toggle t)
      ("e" ef-themes-toggle "ef-themes")
      ("s" prettify-symbols-mode "pretty symbol" :toggle t)
      ("t" toggle-truncate-lines "truncate lines" :toggle t)
      ("T" (toggle-transparency) "transparency")
      ("v" variable-pitch-mode "variable pitch" :toggle t))
     "Highlight"
     (("l" global-hl-line-mode "line" :toggle t)
      ("p" show-paren-mode "paren" :toggle t)
      ("S" symbol-overlay-mode "symbol" :toggle t)
      ("w" (setq-default show-trailing-whitespace (not show-trailing-whitespace))
       "whitespace" :toggle show-trailing-whitespace)
      ("h" global-hl-todo-mode "hl-todo" :toggle t))
     "Program"
     (("f" flycheck "flycheck" :toggle t)
      ("O" hs-minor-mode "hideshow" :toggle t)
      ("u" subword-mode "subword" :toggle t)
      ("W" which-function-mode "which function" :toggle t)
      ("E" toggle-debug-on-error "debug on error" :toggle (default-value 'debug-on-error))
      ("Q" toggle-debug-on-quit "debug on quit" :toggle (default-value 'debug-on-quit))
      ("v" global-diff-hl-mode "gutter" :toggle t)
      ("V" diff-hl-flydiff-mode "live gutter" :toggle t)
      ("M" diff-hl-margin-mode "margin gutter" :toggle t)
      ("D" diff-hl-dired-mode "dired gutter" :toggle t)))))

(use-package emacs
  :straight (:type built-in)

  ;; :general
  ;; (my-leader
  ;;   "u s" '(scale-hydra/body :wk "Scale Text"))

  :config
  (pretty-hydra-define font-hydra
    (:title "Fonts" :color pink :quit-key ("q" "C-g"))
     ("Scale text"
      (("+" text-scale-increase "in")
      ("=" text-scale-increase "in")
      ("-" text-scale-decrease "out")
      ("0" (text-scale-increase 0) "reset")))))

(use-package emacs
  :straight (:type built-in)

  :config
  (pretty-hydra-define window-hydra
    (:title "Window" :color pink :quit-key ("q" "C-g"))
     ("Resize window"
      ((">" evil-window-increase-width "Increase width")
       ("<" evil-window-decrease-width "Decrease width")
       ("+" evil-window-increase-height "Increase height")
       ("-" evil-window-decrease-height "Decrease height")
       ("0" balance-windows "Balans windows")
       ("f" fit-window-to-buffer "Fit to buffer")))))

(use-package emacs
  :straight (:type built-in)

  :config
  (pretty-hydra-define org-table-hydra
    (:title "Org-table" :color pink :quit-key ("q" "C-g"))
     ("Table"
      (("a" org-table-align "align table")
       ("n" org-table-create "new table")
       ("x" org-table-create-or-convert-from-region "create from region"))
      "Tabel-insert"
      (("c" org-table-insert-column "insert column")
       ("r" org-table-insert-row "insert row")
       ("h" org-table-insert-hline "insert hline"))
      "Table-delete"
      (("C" org-table-delete-column "delete column")
       ("R" org-table-kill-row "delete row")))))

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;
;; WINDOWS.ORG
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;
;;

(setq switch-to-buffer-obey-display-actions t)

;; see doc buffer-math-p

(defun get-buffer-major-mode ()
  "Get major-mode name of current buffer."
  (buffer-local-value 'major-mode (current-buffer)))

;; display on right-side.
(add-to-list 'display-buffer-alist
             '((or (major-mode . Info-mode)
                   (major-mode . helpful-mode)
                   (major-mode . help-mode)
                   (major-mode . occur-mode))
               (display-buffer-in-side-window)
               (side . right)
               (slot . 0)
               (window-width . 0.45)
               (inhibit-same-window . t)
               (window-parameters
                (no-other-windows . t))))

;; display at top
(add-to-list 'display-buffer-alist
             '((or "\\*Flycheck.*")
               (display-buffer-in-side-window)
               (side . top)
               (slot . 0)
               (window-height . 0.20)
               (inhibit-same-window . t)
               (window-parameters
                (no-other-windows . t))))

;; display at bottom
(add-to-list 'display-buffer-alist
             ;; '((or (major-mode . dired-mode)
             '((or "\\*Messages.*"
                   "^\\(\\*e?shell\\|vterm\\).*"
                   "\\*\\(Backtrace\\|Warnings\\|Compile-Log\\)\\*"
                   "\\*\\(Output\\|Register Preview\\).*"
                   ".*\\*\\(Completions\\|Embark Live Occur\\).*"
                   "\\*Embark Occur.*")
               (display-buffer-in-side-window)
               (side . bottom)
               (slot . 0)
               (window-height . 0.30)
               (inhibit-same-window . t)
               (window-parameters
                (no-other-windows . t))))

(winner-mode 1)

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;
;; DIRED.ORG
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;
;;

(use-package dired
  :straight (:type built-in)
  :defer 5
  :commands (dired dired-jump)
  :bind (("C-x C-j" . dired-jump)
         :map dired-mode-map
         ("F" . (lambda ()
                  (interactive)
                  (mapc #'find-file (reverse (dired-get-marked-files))))))
  :custom (dired-listing-switches "-alh --group-directories-first")

  :hook ((dired-mode . dired-hide-details-mode)
         (dired-mode . dired-omit-mode)
         (dired-mode . auto-revert-mode)
         (dired-mode . hl-line-mode)
         (dired-mode . (lambda () (all-the-icons-dired-mode t))))

  :config
  (setq ls-lisp-dirs-first t)
  (setq dired-auto-revert-buffer #'dired-directory-changed-p)
  (setq dired-kill-when-opening-new-dired-buffer t)
  (setq dired-make-directory-clickable t) ; Emacs 29.1
  (setq delete-by-moving-to-trash t)
  (setq-default dired-dwim-target t))

(use-package dired-open
  :config
  (setq dired-open-extensions '(("gif" . "sxiv")
                                ("jpg" . "sxiv")
                                ("png" . "sxiv")
                                ("mkv" . "mpv")
                                ("mp4" . "mpv"))))

(use-package peep-dired
  :after dired
  :hook (evil-normalize-keymaps . peep-dired-hook)
  :config
    (evil-define-key 'normal dired-mode-map (kbd "h") 'dired-up-directory)
    (evil-define-key 'normal dired-mode-map (kbd "l") 'dired-open-file) ; use dired-find-file instead if not using dired-open package
    (evil-define-key 'normal peep-dired-mode-map (kbd "j") 'peep-dired-next-file)
    (evil-define-key 'normal peep-dired-mode-map (kbd "k") 'peep-dired-prev-file)
)

(use-package dired-x
:straight (:type built-in)
:after dired
:config
(setq ls-lisp-use-insert-directory-program nil)
(setq dired-clean-confirm-killing-deleted-buffers nil)
(require 'ls-lisp)
(setq directory-free-space-program nil)
(setq dired-x-hands-off-my-keys t)
(setq dired-omit-verbose nil
      dired-omit-files
      (concat dired-omit-files
              "\\|^.DS_Store\\'"
              "\\|^.project\\(?:ile\\)?\\'"
              "\\|^.\\(svn\\|git\\)\\'"
              "\\|^.ccls-cache\\'"
              "\\|\\(?:\\.js\\)?\\.meta\\'"
              "\\|\\.\\(?:elc\\|o\\|pyo\\|swp\\|class\\)\\'"))

(setq dired-guess-shell-alist-user  ;; those are the suggestions for ! and & in Dired
'(("\\.\\(?:docx\\|pdf\\|djvu\\|eps\\)\\'" "xdg-open")
  ("\\.\\(?:jpe?g\\|png\\|gif\\|xpm\\)\\'" "feh" "xdg-open")
  ("\\.\\(?:xcf\\)\\'" "xdg-open")
  ("\\.csv\\'" "xdg-open")
  ("\\.tex\\'" "xdg-open")
  ("\\.\\(?:mp[4]\\|m4a\\|ogg\\|webm\\|mkv\\)" "mpv" "xdg-open")
  ("\\.\\(?:mp4\\|avi\\|flv\\|rm\\|rmvb\\|ogv\\)\\(?:\\.part\\)?\\'" "xdg-open")
  ("\\.\\(?:mp3\\|flac\\)\\'" "mpv" "xdg-open")
  ("\\.html?\\'" "xdg-open")
  ("\\.md\\'" "xdg-open"))))

(use-package dired-subtree
  :bind ( :map dired-mode-map
          (("<tab>" . dired-subtree-toggle)
           ("<backtab>" . dired-subtree-remove))) ; S-TAB
  :config
  (setq dired-subtree-use-backgrounds nil))

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;
;; MINIBUFFER.ORG
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;
;;

(use-package vertico
  :demand t
  :custom
  (vertico-cycle t)
  :hook (rfn-eshadow-update-overlay . vertico-directory-tidy)
  :bind (:map vertico-map
              ("C-j" . vertico-next)
              ("C-k" . vertico-previous)
              ("M-h" . vertico-directory-up))
  :init
  (vertico-mode 1)
  (file-name-shadow-mode 1))

(use-package marginalia
  :after vertico
  :custom
  (marginalia-annotators '(marginalia-annotators-heavy
                           marginalia-annotators-light
                           nil))
  :init
  (marginalia-mode 1))

(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion))))
  (orderless-component-separator #'orderless-escapable-split-on-space))

(use-package consult
  :demand t
  :after vertico
  :bind (;; Rebind C-c bindings in `mode-specific-map'
         ("C-c M-x" . consult-mode-command)
         ("C-c h"   . consult-history)
         ("C-c k"   . consult-kmacro)
         ("C-c m"   . consult-man)
         ("C-c i"   . consult-info)
         ("C-c r"   . consult-ripgrep)
         ("C-c T"   . consult-theme)

         ("C-c c f" . describe-face)
         ("C-c c t" . consult-theme)

         ([remap Info-search]        . consult-info)
         ([remap isearch-forward]    . consult-line)
         ([remap recentf-open-files] . consult-recent-file)

         ;; Rebind C-x bindings in `ctl-x-map'
         ("C-x M-:" . consult-complex-command)     ;; orig. repeat-complex-command
         ("C-x b"   . consult-buffer)              ;; orig. switch-to-buffer
         ("C-x 4 b" . consult-buffer-other-window) ;; orig. switch-to-buffer-other-window
         ("C-x 5 b" . consult-buffer-other-frame)  ;; orig. switch-to-buffer-other-frame
         ("C-x r b" . consult-bookmark)            ;; orig. bookmark-jump
         ("C-x p b" . consult-project-buffer)      ;; orig. project-switch-to-buffer

         ;; Rebind Custom M-# bindings for fast register access
         ("M-#"     . consult-register-load)
         ("M-'"     . consult-register-store)      ;; orig. abbrev-prefix-mark (unrelated)
         ("C-M-#"   . consult-register)

         ;; Rebind Other custom bindings
         ("M-y"     . consult-yank-pop)            ;; orig. yank-pop

         ;; Rebind M-g bindings in `goto-map'
         ("M-g e"   . consult-compile-error)
         ("M-g f"   . consult-flymake)             ;; Alternative: consult-flycheck
         ("M-g g"   . consult-goto-line)           ;; orig. goto-line
         ("M-g M-g" . consult-goto-line)           ;; orig. goto-line
         ("M-g o"   . consult-outline)             ;; Alternative: consult-org-headingq
         ("M-g m"   . consult-mark)
         ("M-g k"   . consult-global-mark)
         ("M-g i"   . consult-imenu)
         ("M-g I"   . consult-imenu-multi)

         ;; M-s bindings in `search-map'
         ("M-s d"   . consult-find)
         ("M-s D"   . consult-locate)
         ("M-s g"   . consult-grep)
         ("M-s G"   . consult-git-grep)
         ("M-s r"   . consult-ripgrep)
         ("M-s l"   . consult-line)
         ("M-s L"   . consult-line-multi)
         ("M-s k"   . consult-keep-lines)
         ("M-s u"   . consult-focus-lines)
         ;; Isearch integration
         ("M-s e"   . consult-isearch-history)
         :map isearch-mode-map
         ("M-e"     . consult-isearch-history)       ;; orig. isearch-edit-string
         ("M-s e"   . consult-isearch-history)       ;; orig. isearch-edit-string
         ("M-s l"   . consult-line)                  ;; needed by consult-line to detect isearch
         ("M-s L"   . consult-line-multi)            ;; needed by consult-line to detect isearch

         ;; Minibuffer history
         :map minibuffer-local-map
         ("M-s" . consult-history)                   ;; orig. next-matching-history-element
         ("M-r" . consult-history)))                 ;; orig. previous-matching-history-element

;;  ("M-s M-a" . consult-org-agenda)

;; :config
;; (setq completion-in-region-function #'consult-completion-in-region))

(use-package consult-flycheck)
;; :bind (("M-g f" . consult-flycheck)))      ; find next flycheck error

(use-package consult-dir
  :bind (("C-x F" . consult-dir)      ; find file in directory
         :map vertico-map
         ("C-x F" . consult-dir)))

(use-package embark
  :bind (("C-." . embark-act)
         :map minibuffer-local-map
         ("C-c C-c" . embark-collect)
         ("C-c C-e" . embark-export))
  :custom
  (embark-indicators
   '(embark-highlight-indicator
     embark-isearch-highlight-indicator
     embark-minimal-indicator))

  :init
  ;; Optionally replace the key help with a completing-read interface
  (setq prefix-help-command #'embark-prefix-help-command)
  (setq embark-prompter 'embark-completing-read-prompter)

  :config
  (global-set-key [remap describe-bindings] #'embark-bindings))


(use-package embark-consult
  :demand t
  :after (:all embark consult)
  ;; if you want to have consult previews as you move around an
  ;; auto-updating embark collect buffer

  :hook
  (embark-collect-mode . consult-preview-at-point-mode))

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;
;; COMPLETION.ORG
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;
;;

(use-package corfu
  :demand t
  :custom
  (corfu-cycle t)                  ; Allows cycling through candidates
  (corfu-auto t)                   ; Enable auto completion
  (corfu-count 8)
  (corfu-min-width 25)
  (corfu-auto-prefix 2)
  (corfu-auto-delay 0.8)
  (corfu-echo-documentation 0.25) ; Echo docs for current completion option
  (corfu-popupinfo-delay '(0.5 . 0.2))
  (corfu-on-exact-match nil)       ; Don't auto expand tempel snippets

  :hook (corfu-popupinfo-mode)
  ;; Optionally use TAB for cycling, default is `corfu-complete'.

  :bind (:map corfu-map
              ("RET" . nil)
              ("SPC" . corfu-insert-separator)
              ("M-p" . corfu-doc-scroll-down)
              ("M-n" . corfu-doc-scroll-up)
              ("M-d" . corfu-doc-toggle))

  :init
  (global-corfu-mode)
  (corfu-history-mode)
  (corfu-popupinfo-mode)) ; Popup completion info

(use-package cape
  :defer 10
  :bind ("C-c f" . cape-file)

  :init
  ;; Add useful defaults completion sources from cape
  (cl-pushnew #'cape-dabbrev completion-at-point-functions)
  (cl-pushnew #'cape-file completion-at-point-functions)
  (cl-pushnew #'cape-elisp-block completion-at-point-functions)
  (cl-pushnew #'cape-keyword completion-at-point-functions)
  (cl-pushnew #'cape-abbrev completion-at-point-functions)

  ;; Silence then pcomplete capf, no errors or messages!
  (advice-add 'pcomplete-completions-at-point :around #'cape-wrap-silent)
  ;; Ensure that pcomplete does not write to the buffer
  ;; and behaves as a pure `completion-at-point-function'.
  (advice-add 'pcomplete-completions-at-point :around #'cape-wrap-purify)
  (advice-add 'eglot-completion-at-point :around #'cape-wrap-buster))

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;
;; KEYBINDINGS.ORG
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;
;;

(defvar my-leader-key "SPC"
  "The default leader key.")

(defvar my-leader-secondary-key "C-SPC"
  "The secondary leader key.")

(defvar my-major-leader-key ","
  "The default major mode leader key.")

(defvar my-major-leader-secondary-key "M-,"
  "The secondary major mode leader key")

(use-package evil
  :hook (after-init . evil-mode)
  :preface
  (defun my/save-and-kill-this-buffer ()
    (interactive)
    (save-buffer)
    (kill-current-buffer))
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-want-C-u-scroll t)
  (setq evil-want-C-i-jump nil)
  :config
  (define-key key-translation-map (kbd "ESC") (kbd "C-g"))
  (define-key evil-insert-state-map (kbd "C-g") 'evil-normal-state)
  (define-key evil-insert-state-map (kbd "C-h") 'evil-delete-backward-char-and-join)
  (setq evil-vsplit-window-right t)
  (setq evil-split-window-below t)
  (evil-set-initial-state 'messages-buffer-mode 'normal)
  (evil-set-initial-state 'dired-mode 'emacs)
  (evil-set-undo-system 'undo-redo)
  ;; Use visual line motions even outside of visual-line-mode buffers
  (evil-global-set-key 'motion "j" 'evil-next-visual-line)
  (evil-global-set-key 'motion "k" 'evil-previous-visual-line)
  (evil-ex-define-cmd "q" #'kill-current-buffer)
  (evil-ex-define-cmd "wq" #'my/save-and-kill-this-buffer)
  (define-key evil-normal-state-map (kbd "C-r") nil)
  (define-key evil-motion-state-map (kbd ";") nil)
  (define-key evil-motion-state-map (kbd ",") nil)
  (evil-mode 1))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

(use-package evil-lion
  :commands evil-lion-mode
  :config (evil-lion-mode))

(use-package evil-nerd-commenter
  :bind (("M-/" . evilnc-comment-or-uncomment-lines)
               ("C-M-/" . evilnc-copy-and-comment-lines)))

(use-package evil-surround
  :commands global-evil-surround-mode
  :init (global-evil-surround-mode 1))

(use-package general
  :after evil
  :config
  (progn
    (general-override-mode)
    (general-evil-setup)

    (general-create-definer my-leader
      :states '(normal insert emacs)
      :prefix my-leader-key
      :non-normal-prefix my-leader-secondary-key)

    (general-create-definer my-major-leader
      :states '(normal insert emacs)
      :prefix my-major-leader-key
      :non-normal-prefix my-major-leader-secondary-key)

  ;; "v" (cons "Version Control" 'vc-prefix-map)

(my-leader
  "SPC" '(consult-mode-command :wk "Consult M-x")
  "." '(find-file :wk "Find file")
  "a" '(:ignore t :wk "Applications")
  "b" '(:ignore t :wk "Buffers")
  "c" '(:ignore t :wk "Emacs config")
  "e" '(:ignore t :wk "Eshell/evaluate")
  "f" '(:ignore t :wk "Files")
  "g" '(:ignore t :wk "Goto")
  ;; "h" -> general-nmap SPC h : Help
  "K" '(helpful-at-point :wk "Helpful at Point")
  "m" '(:ignore t :wk "Org")
  ;; "n" -> general-nmap SPC n : Narrow
  ;; "r" -> general-nmap SPC r : Register
  "s" '(:ignore t :wk "Search")
  "S" '(:ignore t :wk "Spelling")
  "t" '(:ignore t :wk "Toggle")
  "u" '(:ignore t :wk "Utils")
  "v" '(:ignore t :wk "Version Control")
  "w" '(:ignore t :wk "Windows"))

(my-leader
  "a g" '(magit-status :wk "Magit"))

(my-leader
  "b b" '(consult-buffer :wk "Switch buffer")
  "b i" '(ibuffer :wk "Ibuffer")
  "b k" '(kill-current-buffer :wk "Kill this buffer")
  "b n" '(next-buffer :wk "Next buffer")
  "b p" '(previous-buffer :wk "Previous buffer")
  "b r" '(revert-buffer-quick :wk "Reload buffer")
  "b x" '(previous-buffer :wk "Open scratch buffer"))

(my-leader
  "c e" '((lambda () (interactive)
            (find-file "~/.config/emacs/emacs.org")) :wk "Edit emacs config")
  "c r" '((lambda () (interactive)
            (load-file "~/.config/emacs/init.el")) :wk "Reload emacs config")
  "c t" '(tangle-and-compile :wk "Tangle emacs and compile"))

(my-leader
  "e b" '(eval-buffer :wk "Evaluate elisp in buffer")
  "e d" '(eval-defun :wk "Evaluate defun containing or after point")
  "e e" '(eval-expression :wk "Evaluate and elisp expression")
  "e h" '(counsel-esh-history :which-key "Eshell history")
  "e l" '(eval-last-sexp :wk "Evaluate elisp expression before point")
  "e r" '(eval-region :wk "Evaluate elisp in region")
  "e s" '(eshell :which-key "Eshell"))

(my-leader
  "f f" '(consult-buffer :wk "Open file")
  "b i" '(ibuffer :wk "Ibuffer")
  "b k" '(kill-current-buffer :wk "Kill this buffer")
  "b n" '(next-buffer :wk "Next buffer")
  "b p" '(previous-buffer :wk "Previous buffer")
  "b r" '(revert-buffer-quick :wk "Reload buffer")
  "b x" '(previous-buffer :wk "Open scratch buffer"))

(my-leader
  "g e" '(consult-compile-error :wk "Compile errors [M-g e]")
  "g f" '(consult-flycheck :wk "Flycheck errors [M-g f]")
  "g g" '(consult-goto-line :wk "Goto linenumber [M-g l]")
  "g o" '(consult-outline :wk "Org headings [M-g o]")
  "g m" '(consult-mark :wk "Mark [M-g m]")
  "g k" '(consult-global-mark :wk "Global mark [M-g k]")
  "g i" '(consult-imenu :wk "Imenu [M-g i]")
  "g I" '(consult-imenu-multi :wk "Imenu multi [M-g I]"))

(general-nmap "SPC h" (general-simulate-key "C-h" :which-key "...Help"))

(my-leader
  "m d" '(org-demote-subtree :wk "Demote subtree")
  "m p" '(org-promote-subtree :wk "Promote subtree")
  "m a" '(org-agenda :wk "Org agenda")
  "m e" '(org-export-dispatch :wk "Org export dispatch")
  "m i" '(org-toggle-item :wk "Org toggle item")
  ;; "m t" '(org-todo :wk "Org todo")
  "m B" '(org-babel-tangle :wk "Org babel tangle")
  "m T" '(org-todo-list :wk "Org todo list")

  "m t" '(org-table-hydra/body :wk "Create org-table")

  "m d" '(:ignore t :wk "Date/deadline"))
  ;; "m d t" '(org-time-stamp :wk "Org time stamp"))

(general-nmap "SPC n" (general-simulate-key "C-x n" :which-key "...Narrow"))

(general-nmap "SPC r" (general-simulate-key "C-x r" :which-key "...Registers"))

(my-leader
  "s a" '(consult-org-agenda :wk "Agenda [M-s M-a]")
  "s g" '(consult-grep :wk "Grep [M-s g]")
  "s r" '(consult-ripgrep :wk "Ripgrep [M-s r]")
  "s f" '(consult-find :wk "Filenames [M-s d]")
  "s l" '(consult-line :wk "Isearch-buffer [M-s l]")
  "s L" '(consult-line-multi :wk "Isearch-buffer multi [M-s L]")
  "s d" '(consult-dir :wk "Directory [C-x F]")
  "s h" '(consult-history :wk "History [C-c h]")
  "s i" '(consult-isearch-history :wk "Isearch history [M-s e]"))

(my-leader
  "t e" '(eshell-toggle :wk "Toggle eshell")
  "t h" '(toggle-hydra/body :wk "Toggle Hydra")
  "t l" '(display-line-numbers-mode :wk "Toggle line numbers")
  "t t" '(visual-line-mode :wk "Toggle truncated lines")
  "t v" '(vterm-toggle :wk "Toggle vterm"))

(my-leader
  "u c" '(world-clock :wk "World clock")
  "u s" '(font-hydra/body :wk "Scale Text"))

(my-leader
  ;; Window splits
  "w c" '(evil-window-delete :wk "Close window")
  "w o" '(delete-other-windows :wk "Close other windows")
  "w n" '(evil-window-new :wk "New window")
  "w s" '(evil-window-split :wk "Horizontal split window")
  "w v" '(evil-window-vsplit :wk "Vertical split window")
  ;; Window resize
  "w >" '(window-hydra/body :wk "Resize window")
  ;; Window motions
  "w h" '(evil-window-left :wk "Window left")
  "w j" '(evil-window-down :wk "Window down")
  "w k" '(evil-window-up :wk "Window up")
  "w l" '(evil-window-right :wk "Window right")
  "w r" '(evil-window-rotate_downwards :wk "Window rotate Down")
  "w u" '(evil-window-rotate_upwards :wk "Window rotate Up")
  "w w" '(evil-window-next :wk "Next window"))))

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;
;; TOOLS.ORG
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;
;;

(use-package eglot
  :commands (eglot eglot-ensure)

  :preface
  ;; Setup eldoc the way I like it for emacs
  (defun my/setup-eldoc-for-eglot ()
    "Make sure Eldoc will show us all of the feedback at point."
    (setq-local eldoc-documentation-strategy
                #'eldoc-documentation-compose))

  :hook (eglot-managed-mode . my/setup-eldoc-for-eglot)

  :bind (:map eglot-diagnostics-map
              ("M-RET" . eglot-code-actions)))

(use-package consult-eglot
  :after eglot
  :bind ("M-s s" . consult-eglot-symbols))

(use-package flycheck-eglot
  :after (flycheck eglot)
  :custom (flycheck-eglot-exclusive nil)
  :config
  (global-flycheck-eglot-mode 1))

(use-package eldoc
  :straight (:type built-in)
  :diminish
  :hook (emacs-lisp-mode python-mode)
  :config
  (use-package eldoc-box
    :diminish (eldoc-box-hover-mode eldoc-box-hover-at-point-mode)
    :custom
    (eldoc-box-lighter nil)
    (eldoc-box-only-multi-line t)
    (eldoc-box-clear-with-C-g t)
    :custom-face
    (eldoc-box-border ((t (:inherit posframe-border :background unspecified))))
    (eldoc-box-body ((t (:inherit tooltip))))
    :hook (eglot-managed-mode . eldoc-box-hover-at-point-mode)
    :config
    ;; Prettify `eldoc-box' frame
    (setf (alist-get 'left-fringe eldoc-box-frame-parameters) 8
          (alist-get 'right-fringe eldoc-box-frame-parameters) 8)))

(use-package flycheck
  :diminish flycheck-mode
  :hook ((prog-mode . flycheck-mode)
         (markdown-mode . flycheck-mode)
         (org-mode . flycheck-mode))

  :custom-face
  (flycheck-error   ((t (:inherit error :underline t))))
  (flycheck-warning ((t (:inherit warning :underline t))))

  :bind
  (:map flycheck-mode-map
        ("M-g f" . consult-flycheck))

  :config
  (setq flycheck-check-syntax-automatically '(save mode-enabled))
  (setq flycheck-display-errors-delay 0.1)
  (setq-default flycheck-disabled-checkers '(python-pylint))
  (setq flycheck-flake8rc "~/.config/flake8")
  (setq flycheck-checker-error-threshold 1000)
  (setq flycheck-indication-mode nil))

(use-package sideline
  :hook ((flycheck-mode . sideline-mode))
  :init
  (setq sideline-backends-left-skip-current-line t   ; don't display on current line (left)
        sideline-backends-right-skip-current-line t  ; don't display on current line (right)
        sideline-order-left 'down                    ; or 'up
        sideline-order-right 'up                     ; or 'down
        sideline-format-left "%s   "                 ; format for left aligment
        sideline-format-right "   %s"                ; format for right aligment
        sideline-priority 100                        ; overlays' priority
        sideline-display-backend-name t              ; display the backend name
        sideline-backends-right '((sideline-flycheck . down))))

(use-package sideline-flycheck
  :hook (flycheck-mode . sideline-flycheck-setup))

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;
;; MAGIT.ORG
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;
;;

(use-package magit
  :commands magit-add-section-hook
  :bind ("C-x g" . magit-status))

;; Quickly move between hunks in your document.
(defhydra hydra-git (:color pink)
  "Git"
  ("k" diff-hl-previous-hunk "prev hunk")
  ("j" diff-hl-next-hunk "next hunk")
  ("q" nil "quit" :color blue))

(use-package diff-hl
  :commands (diff-hl-magit-post-refresh global-diff-hl-mode)
  :functions (diff-hl-flydiff-mode diff-hl-margin-mode)
  :defines diff-hl-margin-symbols-alist
  :hook (magit-post-refresh . diff-hl-magit-post-refresh)
  :init
  (setq diff-hl-margin-symbols-alist
        '((insert . "+") (delete . "-") (change . "~")
          (unknown . "?") (ignored . "i")))
  (global-diff-hl-mode)
  (diff-hl-margin-mode)
  (diff-hl-flydiff-mode))

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;
;; TREESITTER.ORG
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;
;;

(use-package treesit-auto
  :custom (treesit-auto-install 'prompt)
  :config
  (treesit-auto-add-to-auto-mode-alist 'all)
  (global-treesit-auto-mode))

(defun install-treesit-grammars ()
  "Installs a list of treesitter-grammars."
  (interactive)
  (setq treesit-language-source-alist
        '((bash "https://github.com/tree-sitter/tree-sitter-bash")
          (cmake "https://github.com/uyha/tree-sitter-cmake")
          (css "https://github.com/tree-sitter/tree-sitter-css")
          (elisp "https://github.com/Wilfred/tree-sitter-elisp")
          (go "https://github.com/tree-sitter/tree-sitter-go")
          (html "https://github.com/tree-sitter/tree-sitter-html")
          (javascript "https://github.com/tree-sitter/tree-sitter-javascript" "master" "src")
          (json "https://github.com/tree-sitter/tree-sitter-json")
          (make "https://github.com/alemuller/tree-sitter-make")
          (markdown "https://github.com/ikatyang/tree-sitter-markdown")
          (python "https://github.com/tree-sitter/tree-sitter-python")
          (toml "https://github.com/tree-sitter/tree-sitter-toml")
          (tsx "https://github.com/tree-sitter/tree-sitter-typescript" "master" "tsx/src")
          (typescript "https://github.com/tree-sitter/tree-sitter-typescript" "master" "typescript/src")
          (yaml "https://github.com/ikatyang/tree-sitter-yaml")))

  (mapc #'treesit-install-language-grammar (mapcar #'car treesit-language-source-alist)))

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;
;; DEBUGGER.ORG
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;
;;

(use-package dape
  :bind (("<f6>" . dape)
         ("M-<f6>" . dape-hydra/body))
  :custom (dape-buffer-window-arrangment 'right)
  :pretty-hydra
  ((:title "Debug" :color pink :quit-key ("q" "C-g"))
   ("Stepping"
    (("n" dape-next "next")
     ("s" dape-step-in "step in")
     ("o" dape-step-out "step out")
     ("c" dape-continue "continue")
     ("p" dape-pause "pause")
     ("k" dape-kill "kill")
     ("r" dape-restart "restart")
     ("D" dape-disconnect-quit "disconnect"))
    "Switch"
    (("m" dape-read-memory "memory")
     ("t" dape-select-thread "thread")
     ("w" dape-watch-dwim "watch")
     ("S" dape-select-stack "stack")
     ("i" dape-info "info")
     ("R" dape-repl "repl"))
    "Breakpoints"
    (("b" dape-breakpoint-toggle "toggle")
     ("l" dape-breakpoint-log "log")
     ("e" dape-breakpoint-expression "expression")
     ("B" dape-breakpoint-remove-all "clear"))
    "Debug"
    (("d" dape "dape")
     ("Q" dape-quit "quit" :exit t))))
  :config
  ;; Save buffers on startup, useful for interpreted languages
  (add-hook 'dape-on-start-hook
            (defun dape--save-on-start ()
              (save-some-buffers t t)))
  ;; Display hydra on startup
  (add-hook 'dape-on-start-hook #'dape-hydra/body))

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;
;; READERS.ORG
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;
;;

(use-package nov
  :defer 10
  :mode ("\\.epub\\'" . nov-mode)
  :hook (nov-mode . my-nov-setup)
  :preface
  (defun my-nov-setup ()
    "Setup `nov-mode' for better reading experience."
    ;; (visual-line-mode 1)
    (display-line-numbers-mode -1)
    (face-remap-add-relative 'variable-pitch :family "Times New Roman" :height 1.0)
    (setq-local line-spacing 0.2
                next-screen-context-lines 4
                shr-use-colors t)
    (require 'visual-fill-column nil t)
    (setq-local visual-fill-column-center-text t)
    (visual-fill-column-mode 1))

  :config
  (with-no-warnings
    ;; WORKAROUND: errors while opening `nov' files with Unicode characters
    ;; @see https://github.com/wasamasa/nov.el/issues/63
    (defun my-nov-content-unique-identifier (content)
      "Return the the unique identifier for CONTENT."
      (let* ((name (nov-content-unique-identifier-name content))
             (selector (format "package>metadata>identifier[id='%s']"
                               (regexp-quote name)))
             (id (car (esxml-node-children (esxml-query selector content)))))
        (and id (intern id))))
    (advice-add #'nov-content-unique-identifier :override #'my-nov-content-unique-identifier)))

(use-package pdf-view
  :disabled t
  :when (display-graphic-p)
  ;; :ensure pdf-tools
  :diminish (pdf-view-themed-minor-mode
             pdf-view-midnight-minor-mode
             pdf-view-printer-minor-mode)
  :defines pdf-annot-activate-created-annotations
  :hook ((pdf-tools-enabled . pdf-view-auto-slice-minor-mode)
         (pdf-tools-enabled . pdf-isearch-minor-mode))
  :mode ("\\.[pP][dD][fF]\\'" . pdf-view-mode)
  :magic ("%PDF" . pdf-view-mode)
  :bind (:map pdf-view-mode-map
              ("C-s" . isearch-forward))
  :init (setq pdf-view-use-scaling t
              pdf-view-use-imagemagick nil
              pdf-annot-activate-created-annotations t)
  :config
  ;; Activate the package
  (pdf-tools-install t nil t nil)

  ;; Recover last viewed position
  (use-package saveplace-pdf-view
    :when (ignore-errors (pdf-info-check-epdfinfo) t)
    :autoload (saveplace-pdf-view-find-file-advice saveplace-pdf-view-to-alist-advice)
    :init
    (advice-add 'save-place-find-file-hook :around #'saveplace-pdf-view-find-file-advice)
    (advice-add 'save-place-to-alist :around #'saveplace-pdf-view-to-alist-advice)))

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;
;; TERMINAL.ORG
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;
;;

(use-package vterm
  :hook (vterm-mode . (lambda ()
                        (setq-local global-hl-line-mode nil)
                        (setq-local line-spacing nil)))
  :preface
  (defun ian/new-vterm-instance ()
    (interactive)
    (vterm t))
  :config
  (setq vterm-disable-bold t)
  (setq vterm-timer-delay 0.01)
  (with-eval-after-load 'evil
    (evil-set-initial-state 'vterm-mode 'emacs))
  (define-key vterm-mode-map (kbd "C-l") #'(lambda ()
                                             (interactive)
                                             (vterm-clear)
                                             (vterm-clear-scrollback))))

(use-package vterm-toggle
  :after (projectile vterm evil)
  :bind ("C-`" . vterm-toggle)
  :config
  (setq vterm-toggle-fullscreen-p nil)
  (setq vterm-toggle-scope 'project)
  (add-to-list 'display-buffer-alist
               '((lambda(bufname _) (with-current-buffer bufname
                                 (or (equal major-mode 'vterm-mode)
                                     (string-prefix-p vterm-buffer-name bufname))))
                 (display-buffer-reuse-window display-buffer-at-bottom)
                 (direction . bottom)
                 (dedicated . t)
                 (reusable-frames . visible)
                 (window-height . 0.5))))

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;
;; LANGS.ORG
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;
;;

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ORG-MODE.ORG
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;
;;

(defvar my/org-dir-local "~/org-files"
  "Base directory for org related file.")

(defvar my/org-dir-sync "~/Dropbox/org"
  "Base directory for org related file that need sync to android app.")

(defvar my/agenda-projects (expand-file-name "projects.org" my/org-dir-local)
  "Inbox file project related tasks.")

(defvar my/agenda-notes (expand-file-name "notes.org" my/org-dir-local)
  "Notes file.")

(defvar my/agenda-archive (expand-file-name "archive.org" my/org-dir-local)
  "Archive file for DONE TODOs.")

(defvar my/agenda-index (expand-file-name "index.org" my/org-dir-sync)
  "Inbox file for todo's.")

(defvar my/agenda-inbox (expand-file-name "inbox.org" my/org-dir-sync)
  "Personal tasks, reminders and so on.")

(defvar my/capture-bookmarks (expand-file-name "bookmarks.org" my/org-dir-local)
  "Captured weblinks.")

(use-package org
  :straight (:type built-in)
  :commands org-mode
  :bind (:map org-mode-map
              (("<f8>" . org-toggle-narrow-to-subtree)))

  :custom
  ;; Return or left-click with mouse follows link
  (org-return-follows-link t)
  (org-mouse-1-follows-link t)
  ;; Display links as the description provided
  (org-descriptive-links t)
  ;; Hide markup markers
  (org-hide-emphasis-markers t)

  :hook
  (org-mode . org-appear-mode)
  (org-mode . (lambda () (hl-line-mode 1)))
  ;; (org-mode . visual-line-mode)
  ;; (org-mode . org-indent-mode)
  (org-mode . (lambda () (electric-indent-mode -1)))
  ;; (org-mode . variable-pitch-mode)
  (org-mode . org-bullets-mode)

  :config
  (setq org-src-fontify-natively t                ;; Always use syntax highlighting of code blocks
        org-src-tab-acts-natively t               ;; TAB in src blocks act same as lang’s major mode
        org-startup-with-inline-images t          ;; Always show images
        org-startup-indented t                    ;; Indent text according to the current header
        org-indent-mode-turns-on-hiding-stars t
        org-hide-emphasis-markers t               ;; Hides the symbols that makes text bold, italics
        org-src-window-setup 'current-window      ;; editing code snippet in current window
        org-fold-catch-invisible-edits 'smart          ;; Smart editing of hidden regions
        org-highlight-latex-and-related '(latex)  ;; Highlight LaTeX fragments, snippets etc
        org-pretty-entities t                     ;; Show entities as UTF8-characters when possible
        org-list-allow-alphabetical t             ;; Allow lists to be a) etc
        org-confirm-babel-evaluate nil            ;; Don't bug about executing code all the time
        org-ellipsis " 󰛒"
        org-edit-src-content-indentation 0
        org-babel-python-command "python3"        ;; Newer is always better
        org-auto-tangle-default nil               ;; activate auto-tangle with PROPERTY auto-tangle t
        org-todo-keywords
        '((sequence "TODO(t)" "NEXT(n)" "PROJ(p)" "|" "DONE(d)")))

  ;; Configure which languages we can use in Org Babel code blocks
  ;; NOTE: This slows down the startup of Org-mode a little bit
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((shell . t)
     (emacs-lisp . t)
     (python .t)
     (sql . t)))

  (use-package org-bullets)
  (use-package org-appear)

  (font-lock-add-keywords
   'org-mode
   '(("^ *\\([-]\\) "
      (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•"))))))

  ;; (add-to-list 'org-modules 'org-tempo t)
  (require 'org-tempo)
  (cl-pushnew '("sh" . "src sh") org-structure-template-alist)
  (cl-pushnew '("se" . "src elisp") org-structure-template-alist)
  (cl-pushnew '("sp" . "src python") org-structure-template-alist)
  (cl-pushnew '("sl" . "src lisp") org-structure-template-alist)
  (cl-pushnew '("sr" . "src racket") org-structure-template-alist))

(use-package org-auto-tangle
  :defer t
  :hook (org-mode . org-auto-tangle-mode)
  :config
  (setq org-auto-tangle-default t))

(use-package visual-fill-column
  :hook (org-mode . visual-fill-column-mode)
  :config
  (setq-default visual-fill-column-width my/fill-width)
  (setq visual-fill-column-center-text nil))

(use-package toc-org
  :commands toc-org-enable
  :hook ((markdown-mode . toc-org-mode)
         (org-mode . toc-org-enable)))

(use-package org-agenda
  :straight (:type built-in)
  :after org
  :preface
  (defun my/mark-done-and-archive()
    "Mark the state of an `org-mode' item as DONE and archive it."
    (interactive)
    (org-todo 'done)
    (org-archive-subtree))
  :init
  (add-to-list 'org-modules 'org-habit t)
  :config
  (setq org-agenda-files (list my/agenda-inbox
                               my/agenda-notes)

        org-refile-targets '((nil :maxlevel . 9)
                             (org-agenda-files :maxlevel . 9))

        org-agenda-skip-schedule-if-done t
        org-agenda-skip-deadline-if-done t
        org-agenda-skip-timestamp-if-done t
        org-log-done 'time
        org-enforce-todo-dependencies t
        org-enforce-todo-checkbox-dependencies t
        org-agenda-start-on-weekday 1 ;; Begin weeks today, not on the last Monday.
        org-agenda-prefix-format '((agenda . " %i %?-12t% s")
                                   (todo . " %i ")
                                   (tags . " %i ")
                                   (search . " %i "))
        org-habit-graph-column 60))

;; TODO: make keymap !
;; (my-leader 'org-mode-map
;;   "a" '(:ignore t :wk "Org-agenda")
;;   "a v" '(org-agenda-list :wk "view")
;;   "a o" '(org-agenda :wk "open")
;;   "a a" '(my/mark-done-and-archive :wk "archive")
;;   "a d" '(org-deadline :wk "deadline")
;;   "a s" '(org-schedule :wk "schedule"))

(use-package org-capture
  :straight (:type built-in)
  :after org
  :init
  (setq org-capture-templates
        '(("t" "Personal TODO" entry
           (file+headline my/agenda-inbox "Inbox")
           "** Todo %?\n  %t\n")
          ("n" "Personal note" entry
           (file+headline my/agenda-notes "Notes")
           "* %?\n  %u\n  %a")
          ("o" "Weblinks" entry
           (file+headline my/capture-bookmarks "Weblinks")
           "* %:annotation\n %?\n %u\n %i\n" :empty-lines-before 1))))

;; (setq counsel-projectile-org-capture-templates
;;       '(("pt" "[${name}] TODO" entry
;;          (file+headline my/agenda-projects "${name}")
;;          "* TODO %? %u\n")
;;         ("pl" "[${name}] TODO" entry
;;          (file+headline my/agenda-projects "${name}")
;;          "* TODO %? %u\n%a")
;;         ("pf" "[${name}] FIXME" entry
;;          (file+headline my/agenda-projects "${name}")
;;          "* FIXME %? %t\n")))))

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;
;; MARKDOWN.ORG
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;
;;

(use-package markdown-mode
  :hook (smartparens-mode)
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.md\\'" . markdown-mode)
         ("\\.markdown\\'" . markdown-mode))
  :init
  ;; Use pandoc to convert documents from markdown to HTML
  (setq markdown-command "pandoc --from=markdown --to=html --standalone --mathjax")
  (setq markdown-enable-wiki-links t)               ;; Syntax highlighting for wiki links
  (setq markdown-italic-underscore t)               ;; Use underscores for italic text
  (setq markdown-make-gfm-checkboxes-buttons t)     ;; Make checkboxes into buttons you can interact with
  (setq markdown-gfm-additional-languages '("sh"))  ;; Add `sh' as a language to convert
  (setq markdown-fontify-code-blocks-natively t))   ;; Highlight code using the languages major mode

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;
;; PYTHON.ORG
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;
;;

(use-package python-mode
  :hook ((python-mode . eglot-ensure)
         (python-mode . corfu-mode)
         (python-mode . eldoc-mode)
         (inferior-python-mode . hide-mode-line-mode))
  :config
  ;; Remove guess indent python message
  (setq python-indent-guess-indent-offset-verbose nil)
  ;; Use IPython when available or fall back to regular Python
  (cond
   ((executable-find "ipython")
    (progn
      (setq python-shell-buffer-name "IPython")
      (setq python-shell-interpreter "ipython")
      (setq python-shell-interpreter-args "-i --simple-prompt")))
   ((executable-find "python3")
    (setq python-shell-interpreter "python3"))
   ((executable-find "python2")
    (setq python-shell-interpreter "python2"))
   (t
    (setq python-shell-interpreter "python"))))

(use-package auto-virtualenv
  :hook ((python-mode . auto-virtualenv-set-virtualenv)
         (projectile-after-switch-project . auto-virtualenv-set-virtualenv))
  :init
  (use-package pyvenv
    :config
    (setq pyvenv-mode-line-indicator '(pyvenv-virtual-env-name ("[venv:" pyvenv-virtual-env-name "] ")))))

(use-package blacken
  :diminish blacken-mode
  :hook (python-mode . blacken-mode)
  :custom
  (blacken-allow-py36 t)
  (blacken-skip-string-normalization t)
  (blacken-only-if-project-is-blackened t)
  (blacken-line-length 88)
  (black-fast-unsafe t))

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;
;; LISP.ORG
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;
;;

(use-package racket-mode
  :config
  (cl-pushnew  "~/.local/racket/bin" exec-path)
  (setf racket-program "racket"))

(use-package lisp-mode
  :straight (:type built-in)
  :config
  (cl-pushnew  "/usr/bin" exec-path)
  (setq inferior-lisp-program "sbcl"))

(use-package slime
  :config
  (slime-setup '(slime-fancy slime-quicklisp slime-asdf slime-mrepl)))

(use-package elisp-slime-nav
  :after evil
  :hook (emacs-lisp-mode . my/lisp-hook)
  :preface
  (defun my/lisp-hook ()
    (elisp-slime-nav-mode)
    (eldoc-mode))
  :config
  (evil-define-key 'normal emacs-lisp-mode-map (kbd "K")
    'elisp-slime-nav-describe-elisp-thing-at-point))

;; (use-package scheme-mode
;;   :ensure nil
;;   :mode "\\.sld\\'")

(use-package geiser
  :config
  ;; (setq geiser-default-implementation 'gambit)
  ;; (setq geiser-active-implementations '(gambit guile))
  ;; (setq geiser-implementations-alist '(((regexp "\\.scm$") gambit)
  ;;                                      ((regexp "\\.sld") gambit)))
  ;; (setq geiser-repl-default-port 44555) ; For Gambit Scheme
  (setq geiser-default-implementation 'guile)
  (setq geiser-active-implementations '(guile))
  (setq geiser-implementations-alist '(((regexp "\\.scm$") guile))))

(use-package geiser-guile
  :after geiser)

;; (with-eval-after-load 'geiser-guile
;;   ;; (add-to-list 'geiser-guile-load-path "~/.dotfiles")
;;   (add-to-list 'geiser-guile-load-path "~/Projects/Code/guix"))

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;
;; HASKELL.ORG
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;
;;

(use-package haskell-mode
  :config
 (setq haskell-interactive-popup-errors nil))

(require 'compile-funcs)

(defvar my/compile-tasks `((,lisp-source-dir)
                           (,user-emacs-directory "early-init" "init" "config")))

;;;;; modules
(add-hook 'emacs-startup-hook ;; or kill-emacs-hook?
          (lambda ()
            (when my/compile-on-startup
              (my/compile-modules))))

;;;;; on save files
(add-hook 'after-save-hook
          (lambda ()
            (when (and my/compile-on-save
                       (string-equal major-mode "emacs-lisp-mode"))
              (my/compile-buffer))))

;;;;; on tangle
(defun tangle-and-compile ()
  "Tangle emacs.org and native compile "
  (interactive)
  (org-babel-tangle)
  (if (> (length my/compile-tasks) 0)
     (my/compile-modules)))

(provide 'config)
;;; config.el ends here
