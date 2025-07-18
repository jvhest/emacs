;;; early-init.el --- start setup emacs      -*- lexical-binding: t -*-

;; Maintainer: Jan van Hest
;; Email: jan.vanhest@gmail.com

;;; Commentary:

;; First fase of EMACS startup.


;;; Code:

;; Prefer loading newest compiled .el file
(customize-set-variable 'load-prefer-newer noninteractive)

;; disable package.el
(setq package-enable-at-startup nil)

;; Temporarily increase the garbage collection threshold.
(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.5)

;; Same idea as above for the `file-name-handler-alist' and the
;; `vc-handled-backends' with regard to startup speed optimisation.
;; Temporary save the default value
(defvar my/file-name-handler-alist file-name-handler-alist)
(defvar my/vc-handled-backends vc-handled-backends)

;; save handlers
(setq file-name-handler-alist nil
      vc-handled-backends nil)

;; restore handlers and garbage collection and
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (* 1000 1000 8)
                  gc-cons-percentage 0.1
                  file-name-handler-alist my/file-name-handler-alist
                  vc-handled-backends my/vc-handled-backends)))

;; profile emacs startup
(add-hook 'emacs-startup-hook
          (lambda ()
            (message "Emacs loaded in %s."
                     (emacs-init-time))))

(when (featurep 'native-compile)
  ;; Silence compiler warnings as they can be pretty disruptive
  (setq native-comp-async-report-warnings-errors nil)

  ;; Make native compilation happens asynchronously
  (setq native-comp-jit-compilation t)

  ;; Set the right directory to store the native compilation cache
  ;; NOTE the method for setting the eln-cache directory depends on the emacs version
  (when (fboundp 'startup-redirect-eln-cache)
    (if (version< emacs-version "29")
        (add-to-list 'native-comp-eln-load-path
                     (convert-standard-filename (expand-file-name "var/eln-cache/" user-emacs-directory)))
      (startup-redirect-eln-cache
       (convert-standard-filename (expand-file-name "var/eln-cache/" user-emacs-directory)))))

  (add-to-list 'native-comp-eln-load-path (expand-file-name "eln-cache/" user-emacs-directory)))

;; Cleanup startup screen
(setq inhibit-splash-screen t)
(setq inhibit-startup-screen t)
(setq inhibit-startup-message t)
(setq initial-scratch-message "")

(push '(tool-bar-lines . 0) default-frame-alist)
(push '(menu-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars) default-frame-alist)
(push '(mouse-color . "white") default-frame-alist)
(push '(fullscreen . maximized) default-frame-alist)
(setq use-dialog-box nil)
(setq use-file-dialog nil)

;;; Prevent flashes on startup
(setq mode-line-format nil)
(set-face-attribute 'default nil :background "#000000" :foreground "#ffffff")
(set-face-attribute 'mode-line nil :background "#000000" :foreground "#ffffff" :box 'unspecified)

;; Don't start with *scratch* buffer if started with file(s) on command-line
(setq initial-buffer-choice nil)
(customize-set-variable 'initial-major-mode 'emacs-lisp-mode)  ;; for fast loading

(provide 'early-init)
;;; early-init.el ends here
