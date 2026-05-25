;; -*- lexical-binding: t; -*-

;;; ----------------------
;;; UI
;;; ----------------------
(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)
(global-display-line-numbers-mode)
(setq display-line-numbers-type 'relative)
(setq inhibit-startup-screen t)
(setq initial-scratch-message nil)
(electric-pair-mode 1)
(setq-default tab-width 2)
(setq make-backup-files nil)

;;; Font
(set-frame-font "MartianMono Nerd Font:weight=normal:size=22" t t)

;;; Theme
(require 'gruber-darker-theme)
(load-theme 'gruber-darker t)

;;; ----------------------
;;; ANSI COLOR (built-in)
;;; ----------------------
(require 'ansi-color)
(defun colorize-compilation-buffer ()
  (let ((inhibit-read-only t))
    (ansi-color-apply-on-region (point-min) (point-max))))
(add-hook 'compilation-filter-hook #'colorize-compilation-buffer)

;;; ----------------------
;;; EVIL
;;; ----------------------
(setq evil-want-keybinding nil)
(setq evil-undo-system 'undo-fu)

(require 'undo-fu)
(require 'evil)
(evil-mode 1)
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

(require 'evil-collection)
(setq evil-want-integration t)
(evil-collection-init)

;;; ----------------------
;;; MAGIT
;;; ----------------------
(require 'magit)

;;; ----------------------
;;; VERTICO
;;; ----------------------
(require 'vertico)
(vertico-mode 1)

;;; ----------------------
;;; COMPANY
;;; ----------------------
(require 'company)
(setq company-minimum-prefix-length 1
      company-idle-delay 0.3
      company-selection-wrap-around t
      company-tooltip-align-annotations t)
(add-hook 'prog-mode-hook #'company-mode)

;;; ----------------------
;;; FLYCHECK
;;; ----------------------
(require 'flycheck)
(global-flycheck-mode)

;;; ----------------------
;;; WHICH-KEY
;;; ----------------------
(require 'which-key)
(which-key-mode)

;;; ----------------------
;;; ENVRC
;;; ----------------------
(require 'envrc)
(add-hook 'after-init-hook #'envrc-global-mode)
