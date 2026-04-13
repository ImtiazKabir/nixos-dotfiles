;;; Startup

(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(load custom-file 'noerror)

;;; PACKAGE LIST
(setq package-archives 
      '(("melpa" . "https://melpa.org/packages/")
        ("elpa" . "https://elpa.gnu.org/packages/")
        ("nongnu" . "https://elpa.nongnu.org/nongnu/")))

(setq-default tab-width 2)

;;; BOOTSTRAP USE-PACKAGE
(setq use-package-always-ensure t)
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(eval-when-compile (require 'use-package))

;;; ----------------------
;;; UI SETTINGS
;;; ----------------------
(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)
(global-display-line-numbers-mode)
(setq display-line-numbers-type 'relative)
(setq inhibit-startup-screen t)
(setq initial-scratch-message nil)
(electric-pair-mode 1)


;;; Set frame font (monospace for code)
(set-frame-font "JebrainsMono Nerd Font:weight=normal:size=16" t t)

(use-package gruber-darker-theme
  :config
  (load-theme 'gruber-darker t))

;;; ----------------------
;;; ANSI COLOR
;;; ----------------------
(use-package ansi-color
  :ensure nil ;; ansi-color is built into Emacs, no need to install
  :hook (compilation-filter . colorize-compilation-buffer)
  :config
  (defun colorize-compilation-buffer ()
    "Colorize the current compilation buffer using ANSI escape codes."
    (let ((inhibit-read-only t))
      (ansi-color-apply-on-region (point-min) (point-max)))))


;;; ----------------------
;;; EVIL (VIM) SETUP
;;; ----------------------
(use-package undo-fu)

(use-package evil
  :demand t
  :bind (("<escape>" . keyboard-escape-quit))
  :init
  (setq evil-want-keybinding nil)
  (setq evil-undo-system 'undo-fu)
  :config
  (evil-mode 1))

(use-package evil-collection
  :after evil
  :config
  (setq evil-want-integration t)
  (evil-collection-init))


;;; ----------------------
;;; MAGIT
;;; ----------------------
(use-package magit)


;;; ----------------------
;;; VERTICO
;;; ----------------------
(use-package vertico
  :config
  (vertico-mode 1))

;;; ----------------------
;;; COMPANY
;;; ----------------------
(use-package company
  :hook (prog-mode . company-mode)
  :config
  (setq company-minimum-prefix-length 1
        company-idle-delay 0.3
        company-selection-wrap-around t
        company-tooltip-align-annotations t))

;;; ----------------------
;;; FLYCHECK
;;; ----------------------
(use-package flycheck
  :ensure t
  :init (global-flycheck-mode))

;;; ----------------------
;;; WHICH-KEY
;;; ----------------------
(use-package which-key
  :ensure t
  :config
  (which-key-mode))

(require 'project)


;;; ----------------------
;;; END OF INIT
;;; ----------------------
