;;;; 1) Variables
(defvar *use-home* (concat (expand-file-name "~") "/"))
(defvar *plugin-path* (concat *use-home* ".emacs.d/plugins/"))

;;; R & ESS path
(defvar *ess-path* (concat *use-home* ".emacs.d/ess/lisp"))
(defvar *r-bin* "/path/to/R")
(defvar *r-start-args* "--quiet --no-restore-history --no-save ")

;;; Common Lisp path
(defvar *cl-path* (concat *use-home* ".emacs.d/common-lisp/"))
;; brew install sbcl
(defvar *sbcl* "/path/to/sbcl")
(defvar *slime-path* (concat *cl-path* "slime/"))
;; NOTICE: jnjcc@github:dotfiles/dotemacs.d/common-lisp/docs/
(setq common-lisp-hyperspec-root (concat *cl-path* "docs/HyperSpec/"))

;;; getwd() / setwd()
(defvar *rwork-path* "/path/to/R/workspace/")
(defvar *lisp-work* "/path/to/lispwd/")
(defvar *org-path* "/path/to/orgnotes/")
(setq default-directory *use-home*)

;;;; 2) Emacs default setup
;; Normally, we do not keep backup files
(setq make-backup-files nil)
(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)
(fset 'yes-or-no-p 'y-or-n-p)
(setq-default indent-tabs-mode nil)
(setq inhibit-startup-message t)
(column-number-mode t)
(line-number-mode t)
(show-paren-mode t)
(delete-selection-mode t)
;; highlight text selection
(transient-mark-mode t)
;; turn on syntax highlighting
(global-font-lock-mode t)
;; Mode line: we want `buffer-name` + `default-directory`...
(setq-default mode-line-buffer-identification
              '("%b:" default-directory))
(require 'uniquify)
(setq uniquify-buffer-name-style 'post-forward)

;;; Editing
;; M-x delete-trailing-whitespace
(defun toggle-trailing-whitespace ()
  (setq show-trailing-whitespace t)
  (set-face-background 'trailing-whitespace "red"))
(setq default-buffer-file-coding-system 'utf-8)

;;;; 3) Emacs plugins
;; linum
; (global-linum-mode 1)

(setq load-path (append (list *plugin-path*) load-path))

;; M-x visit-tags-table; M-x taglist
;; cedet & ecb does this better, but their size really freaks me out
(require 'taglist)

(require 'sr-speedbar)
(setq sr-speedbar-right-side nil)
(setq sr-speedbar-skip-other-window-p t)
(setq sr-speedbar-auto-refresh t)
(setq sr-speedbar-max-width 30)
(setq speedbar-show-unknown-files t)
(setq speedbar-tag-hierarchy-method '(speedbar-prefix-group-tag-hierarchy))
(setq speedbar-sort-tags t)

;;;; 4) R, ESS, Common Lisp, Org-mode
;;; NOTICE: report terminal type as `xterm` instead of 'ansi'
;;;   otherwise, emacs behaves weirdly
(setq load-path (append (list *ess-path* *slime-path*) load-path))
(setq inferior-R-args *r-start-args*)
(setq inferior-R-program-name *r-bin*)
(require 'ess-site)
(setq auto-mode-alist
      (append '(
                ("\\.R$" . R-mode)
                ("\\.lisp$" . lisp-mode)
                ("\\.lsp$" . lisp-mode)
                ("\\.asd$" . lisp-mode)
                ("\\.org$" . org-mode))
              auto-mode-alist))

;;; The R part
;;;   ESS version 13.09-1, same as dotfiles-windows
(add-hook 'R-mode-hook
          (lambda ()
            (setq default-directory *rwork-path*)
            (setq ess-ask-for-ess-directory nil)

            (setq ess-local-process-name "R")
            (setq ansi-color-for-comint-mode 'filter)
            (setq comint-scroll-to-bottom-on-input t)
            (setq comint-scroll-to-bottom-on-output t)
            (setq comint-move-point-for-ouput t)

            (autoload 'R-mode "ess-site.el" "ESS" t)
            (setq ess-tab-complete-in-script t)
            (setq ess-eval-visibly-p nil)
            (setq comint-prompt-read-only t)
            (ess-toggle-underscore nil)
            (toggle-trailing-whitespace)
            (require 'ess-eldoc)))

;;; The Common Lisp part
;;;   SLIME version 2.15
(require 'slime)
(defun slime-setup-for-lisp ()
  (setq inferior-lisp-program *sbcl*)
  (setq slime-lisp-implementations
        `((sbcl (,*sbcl*) :coding-system utf-8-unix)
          ; (clisp (,*clisp*) :coding-system utf-8-unix)
          ))
  (slime-setup '(slime-fancy))
  (add-hook 'slime-mode-hook
            (lambda ()
              (unless (slime-connected-p)
                (save-excursion (slime))))))
(defun lisp-indent-or-complete (&optional arg)
  (interactive "p")
  (if (or (looking-back "^\\s-*") (bolp))
      (call-interactively 'lisp-indent-line)
    (call-interactively 'slime-indent-and-complete-symbol)))
(add-hook 'lisp-mode-hook
          (lambda ()
            (setq default-directory *lisp-work*)
            (slime-setup-for-lisp)
            (set (make-local-variable 'lisp-indent-function)
                 'common-lisp-indent-function)
            (define-key lisp-mode-map (kbd "TAB") 'lisp-indent-or-complete)
            (define-key lisp-mode-map "\C-r" 'forward-char)
            ; (setq browse-url-browser-function 'browse-url-generic
            ;       browse-url-generic-program "google-chrome")
            ))

;;; The Org-mode part: use org-mode under GUI Emacs
;;;   NOTICE: unfortunately, org-mode doesn't work properly in console emacs
(defun org-mode-gui-init ()
  (setq default-directory *org-path*)
  (set-face-attribute 'default nil :height 130)
  (set-fringe-mode '(0 . 1))
  (set-background-color "dark slate gray")
  (set-foreground-color "grey"))
  (setq org-startup-indented t)
  (add-hook 'org-mode-hook
            (lambda ()
              (setq system-time-locale "C")
              (setq truncate-lines nil)
              (setq org-log-done t)
              (global-set-key "\C-cl" 'org-store-link)
              (global-set-key "\C-ca" 'org-agenda)
              (setq org-agenda-files
                    (list (concat *org-path* "work.org")
                          (concat *org-path* "home.org")))))
(if window-system
  (progn
    (org-mode-gui-init)
    (global-set-key (kbd "M-RET") 'toggle-frame-fullscreen)
    (toggle-frame-maximized)))
