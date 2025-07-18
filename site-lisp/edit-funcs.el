;;; edit-funcs.el --- Utility functions for emacs config -*- lexical-binding: t -*-

;;; Commentary:

;; Functions used for copying, (re)moving text.

;;; Code:

(defmacro crux-with-region-or-line (func)
  "When called with no active region, call FUNC on current line."
  `(defadvice ,func (before with-region-or-line activate compile)
     (interactive
      (if mark-active
          (list (region-beginning) (region-end))
        (list (line-beginning-position) (line-beginning-position 2))))))

(defun alternate-buffer (&optional window)
  "Return the last buffer WINDOW has displayed other than the current one.
This is equivalent to Vim's alternate buffer.
[from evil-commands.el]"
  ;; If the last buffer visited has been killed, then `window-prev-buffers'
  ;; returns a list with `window-buffer' at the head.
  (let* ((prev-buffers (window-prev-buffers))
         (head (car prev-buffers)))
    (if (eq (car head) (window-buffer window))
        (cadr prev-buffers)
      head)))

(defun switch-to-windows-last-buffer ()
  "Switch to the last open buffer of the current window.
[from evil-commands.el]"
  (interactive)
  (let ((previous-place (alternate-buffer)))
    (when previous-place
      (switch-to-buffer (car previous-place)))))

(defun mark-whole-line ()
  "Select whole line."
  (beginning-of-line)
  (set-mark-command nil)
  (end-of-line))

(defun kill-ring-save-whole-line-or-region ()
  "Save active region or current line to `kill-ring'."
  (interactive)
  (if (region-active-p)
      (call-interactively #'kill-ring-save)
    (save-mark-and-excursion
      (mark-whole-line)
      (kill-ring-save (region-beginning) (region-end))
      (pop-mark)
      )))

(defun kill-whole-line-or-region ()
  "Delete active region or current line to `kill-ring'."
  (interactive)
  (if (region-active-p)
      (call-interactively #'kill-region)
    (save-mark-and-excursion
      (mark-whole-line)
      (kill-region (region-beginning) (region-end))
      (delete-char 1)
      (pop-mark)
      )))

(defun open-line-below ()
  "Create empty line below point."
  (interactive)
  (move-end-of-line 1)
  (newline)
  (indent-for-tab-command))

(defun open-line-above ()
  "Create empty line above point."
  (interactive)
  ;; (previous-line)
  (forward-line -1)
  (move-end-of-line 1)
  (newline)
  (indent-for-tab-command))

(defun select-line (n)
  "Start new selection of N lines.
Select up- or downwards"
  (interactive "p")
  (let ((jump (if (null n) 1 n)))
    (if (< jump 0)
        (move-end-of-line 1)
      (move-beginning-of-line 1))
    (set-mark-command nil)
    (forward-line jump)
    (setq deactivate-mark nil)))

(defun yank-below ()
  "Yank below current line."
  (interactive)
  (move-end-of-line 1)
  (newline)
  (yank))

(defun yank-above ()
  "Yank above current line."
  (interactive)
  (forward-line -1)
  (move-end-of-line 1)
  (newline)
  (yank))

(defmacro save-column (&rest body)
  "Save column position.
and restore cursor position after BODY."
  `(let ((column (current-column)))
     (unwind-protect
         (progn ,@body)
       (move-to-column column))))
(put 'save-column 'lisp-indent-function 0)

(defun get-positions-of-line-or-region (include-newline)
  "Return positions (beg . end) of the current line or region.
Region is extended to full lines [from: crux]"
  (let (beg end)
    (if (and mark-active (> (point) (mark)))
        (exchange-point-and-mark))
    ;; point on FIRST line of region (or line)
    (setq beg (line-beginning-position))
    (if mark-active
        (exchange-point-and-mark))
    ;; point on LAST line of region (or line)
    (cond
     ((> (point) (line-beginning-position))
      (setq end (line-end-position)))  ;; extend selection to eol
     ((= (point) beg)  ;; point at beginning of single line
      (setq end (line-end-position)))
     (t
      (setq end (- (point) 1))))
    (cons beg (if (null include-newline) end  (+ end 1)))))

(defun move-region-or-line (n)
  "Move current region N lines."
  (pcase-let* ((`(,beg . ,end) (get-positions-of-line-or-region t))
               (region (delete-and-extract-region beg end)))
    (forward-line n)
    (set-mark (point))
    (insert region)
    (exchange-point-and-mark)
    (setq deactivate-mark nil)))

(defun move-region-or-line-up (n)
  "Move current region N lines up."
  (interactive "p")
  (move-region-or-line (if (null n) -1 (- n))))

(defun move-region-or-line-down (n)
  "Move current region N lines down."
  (interactive "p")
  (move-region-or-line (if (null n) 1 n)))


(defun duplicate-region-or-line (arg)
  "Duplicates the current line or region ARG times.
If there's no region, the current line will be duplicated.  However, if
there's a region, all lines that region covers will be duplicated.
[from: crux]."
  (interactive "p")
  (pcase-let* ((origin (point))
               (`(,beg . ,end) (get-positions-of-line-or-region nil))
               (region (buffer-substring-no-properties beg end)))
    (dotimes (_i arg)
      (goto-char end)
      (newline)
      (insert region)
      (setq end (point)))
    (goto-char (+ origin (length region)))))

(defun top-join-line ()
  "Join the current line with the line beneath it."
  (interactive)
  (delete-indentation 1))

(defun extend-region-by-word ()
  "Extend active region word by word."
  (interactive)
  (if (region-active-p)
      (forward-word)
    (progn
      (set-mark-command nil)
      (forward-word)
      )))

(defun toggle-case-at-point ()
  "Toggle case of char at point and move 1 position."
  (interactive)
  (let ((cf (char-after)) cn)
    (cond
     ((and (>= cf 65) (<= cf 90))    ;; upper-case
      (setq cn (downcase cf))
      (delete-char 1)
      (insert cn))
     ((and (>= cf 97) (<= cf 122))  ;; lower-case
      (setq cn (upcase cf))
      (delete-char 1)
      (insert cn)))))

(defun my/add-keys-to-prefix-keymap (keymap key-list)
  "Add new keys to a prefix KEYMAP.
KEY-LIST is a list of lists that contain the
key-parameters: (key command description)
`description' is optional.
`command' can also be an other"
  (dolist (key key-list)
    (cond
     ((or (< (length key) 2) (> (length key) 3))
      (message "invalid count of key-parameters"))
     ((= (length key) 3)
      (if (keymapp (car (cdr key)))
          (keymap-set keymap (kbd (car key)) (cons (car (cdr (cdr key))) (car (cdr key))))
        (define-key keymap (kbd (car key)) (cons (car (cdr (cdr key))) (car (cdr key))))))
     (t
      (if (keymapp (car (cdr key)))
          (keymap-set keymap (kbd (car key)) (car (cdr key)))
        (define-key keymap (kbd (car key)) (car (cdr key))))))))

(provide 'edit-funcs)
;;; edit-funcs.el ends here
