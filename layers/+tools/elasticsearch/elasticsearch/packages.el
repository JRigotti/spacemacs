;;; packages.el --- elasticsearch layer packages file for Spacemacs.
;;
;; Copyright (c) 2012-2018 Sylvain Benner & Contributors
;;
;; Author: Jean Rigotti
;; URL: https://github.com/syl20bnr/spacemacs
;;
;; This file is not part of GNU Emacs.
;;
;;; License: GPLv3

;;; Commentary:

;;; Code:

(defconst elasticsearch-packages
  '(
    es-mode
    yasnippet-snippets
    ))

(defun elasticsearch/init-es-mode ()
  "Initialize es mode"
  (use-package es-mode
    :mode ("\\.es\\'" . es-mode)))

(defun elasticsearch/init-yasnippet-snippets ())

;;; packages.el ends here
