;;; compile-funcs.el --- Emacs configuration      -*- lexical-binding: t; -*-

;; Maintainer: Jan van Hest
;; Email: jan.vanhest@gmail.com

;;; Commentary:

;; Modules for init.el.

;;; Code:


(defun my/compile-file (f)
  "Compiles (native or byte-code) the file F.

F could be a single file or a list of files.

If F is a directory or contains a directory, the content of that
directory will be compiled, but not it's subdirectories."
  (setq f (flatten-list (list f)))
  (message "Compiling file(s): %s" f)
  (if (featurep 'native-compile)
      (native-compile-async f)
    (dolist (source f)
      (when (file-exists-p source)
        (if (file-directory-p source)
            (byte-recompile-directory source 0)
          (byte-recompile-file source nil 0))))))

;; A function to compile the buffer's file
(defun my/compile-buffer (&optional b)
  "Compiles (native or byte-code) the file of buffer B."
  (when (and b ;; Let's be sure it is not nil
             (not (bufferp b)))
    (cl-return nil))
  (let ((file (buffer-file-name b)))
    (when file
      (my/compile-file file))))

;; A function to compile a specific directory
(defun my/compile-directory (d)
  "Compiles (native or byte-ocde) the files within directory D.

D could be a single directory or a list of directories."
  (setq d (flatten-list (list d)))
  (message "Compiling directory/ies: %s" d)
  (if (featurep 'native-compile)
      (native-compile-async d t)
    (dolist (source d)
      (byte-recompile-directory source 0))))

(defun my/compile-modules ()
  "Compile the modules within the task list."
  (dolist (task my/compile-tasks)
    (message "==== module-path: %s ====" (car task))
    (if (= (length task) 1)  ;; compile whole dir
        (my/compile-directory (car task))
      (dolist (module (cdr task))  ;; compile specific modules in dir
        (let ((module-src (expand-file-name (format "%s.el" module) (car task))))
          (when (file-exists-p module-src)
            (my/compile-file module-src)))))))

(provide 'compile-funcs)
