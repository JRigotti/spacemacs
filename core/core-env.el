;;; core-env.el --- Spacemacs Core File
;;
;; Copyright (c) 2012-2018 Sylvain Benner & Contributors
;;
;; Author: Sylvain Benner <sylvain.benner@gmail.com>
;; URL: https://github.com/syl20bnr/spacemacs
;;
;; This file is not part of GNU Emacs.
;;
;;; License: GPLv3

(require 'core-dotspacemacs)
(require 'load-env-vars)

(defvar spacemacs-env-vars-file
  (concat (or dotspacemacs-directory user-home-directory) ".spacemacs.env")
  "Absolute path to the env file where environment variables are set.")

(defvar spacemacs-ignored-environment-variables
  '(
    "DBUS_SESSION_BUS_ADDRESS"
    "GPG_AGENT_INFO"
    "SSH_AGENT_PID"
    "SSH_AUTH_SOCK"
    )
  "Ignored environments variables. This env. vars are not import in the
`.spacemacs.env' file.")

(defvar spacemacs--spacemacs-env-loaded nil
  "non-nil if `spacemacs/load-spacemacs-env' has been called at least once.")

(defun spacemacs//init-spacemacs-env (&optional force)
  "Attempt to fetch the environment variables from the users shell.
This solution is far from perfect and we should not rely on this function
a lot. We use it only to initialize the env file when it does not exist
yet.
If FORCE is non-nil then force the initialization of the file, note that the
current contents of the file will be overwritten."
  (when (or force (not (file-exists-p spacemacs-env-vars-file)))
    (with-temp-file spacemacs-env-vars-file
      (let ((shell-command-switches (cond
                                     ((or(eq system-type 'darwin)
                                         (eq system-type 'gnu/linux))
                                      ;; execute env twice, once with a
                                      ;; non-interactive login shell and
                                      ;; once with an interactive shell
                                      ;; in order to capture all the init
                                      ;; files possible.
                                      '("-lc" "-ic"))
                                     ((eq system-type 'windows-nt) '("-c"))))
            (executable (cond ((or(eq system-type 'darwin)
                                  (eq system-type 'gnu/linux)) "env")
                              ((eq system-type 'windows-nt) "set"))))
        (insert
         (concat
          "# ---------------------------------------------------------------------------\n"
          "#                    Spacemacs environment variables\n"
          "# ---------------------------------------------------------------------------\n"
          "# This file has been generated by Spacemacs. It contains all found environment\n"
          "# variables defined in your default shell except the black listed variables\n"
          "# defined in `spacemacs-ignored-environment-variables'. Some variables may be\n"
          "# listed twice, the last one is effective except for the PATH variables.\n"
          "# All PATH values are added to the `exec-path' variable without duplicates.\n"
          "#\n"
          "# You can safely edit this file and tweak the values or remove the duplicates,\n"
          "# Spacemacs won't overwrite it unless you call the function\n"
          "# `spacemacs/force-init-spacemacs-env'.\n"
          "#\n"
          "# If you don't want to use this file and manage your environment variables\n"
          "# yourself then remove the call to `spacemacs/load-spacemacs-env' from your\n"
          "# `dotspacemacs/user-env' function in your dotfile and replace it with your\n"
          "# own initialization code. You can use `exec-path-from-shell' if you add it\n"
          "# to your additional packages or simply use `setenv' and\n"
          "# `(add-to-list 'exec-path ...)' which are built-in.\n"
          "#\n"
          "# It is recommended to get used to this file as it unambiguously and\n"
          "# explicitly set the values of your environment variables.\n"
          "# ---------------------------------------------------------------------------\n"
          "\n"
          "# Environment variables:\n"
          "# ----------------------\n"))
        (let ((env-point (point)))
          (dolist (shell-command-switch shell-command-switches)
            (insert (shell-command-to-string executable)))
          ;; sort the environment variables
          (sort-lines nil env-point (point-max))
          ;; remove adjacent duplicated lines
          (delete-duplicate-lines env-point (point-max) nil t)
          ;; remove ignored environment variables
          (dolist (v spacemacs-ignored-environment-variables)
            (flush-lines v env-point (point-max))))))
    (spacemacs-buffer/warning
     (concat "Spacemacs has imported your environment variables from "
             "your shell and saved them to `%s'.\n"
             "Open this file for more info (SPC f e e) or call "
             "`spacemacs/edit-env' function.")
     spacemacs-env-vars-file)))

(defun spacemacs/force-init-spacemacs-env ()
  "Forces a reinitialization of environment variables."
  (interactive)
  (spacemacs//init-spacemacs-env t))

(defun spacemacs/edit-env ()
  "Open the env file for edition."
  (interactive)
  (if (and spacemacs--spacemacs-env-loaded
           (file-exists-p spacemacs-env-vars-file))
      (progn
        (find-file spacemacs-env-vars-file)
        (when (fboundp 'dotenv-mode)
          (dotenv-mode)))
    ;; fallback to the dotspacemacs/user-env
    (dotspacemacs/go-to-user-env)))

(defun spacemacs/load-spacemacs-env (&optional force)
  "Load the environment variables from the `.spacemacs.env' file.
If FORCE is non-nil then force the loading of environment variables from env.
file."
  (interactive "P")
  (setq spacemacs--spacemacs-env-loaded t)
  (when (or force (display-graphic-p))
    (spacemacs//init-spacemacs-env force)
    (load-env-vars spacemacs-env-vars-file)))

(provide 'core-env)
