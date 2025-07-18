(require 'seq)
(require 'org)
(require 'ob-tangle)
(require 'ox-org)

(let ((config-file (expand-file-name "./modules/config.org"))
      (export-file (expand-file-name "./exports.org")))
  (progn
    (format-message "Exporting %s to %s..." config-file export-file)
    (with-current-buffer (find-file-noselect config-file)
      (org-export-to-file 'org export-file))
    (with-current-buffer (find-file-noselect export-file)
      (org-babel-tangle))))
