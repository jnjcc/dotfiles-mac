;;;;;; brew install emacs --with-cocoa

;;;;; 0) Key Mappings {{{
;;;; 1) Custom Key Mappings {{{
;;; <M-]> {{{
(global-set-key "\M-]" 'comint-dynamic-complete-filename)
;;; }}}
;;; <M-x find-file-at-point> {{{
;;; }}}
;;;; }}}

;;;; 2) Variables {{{
(defvar *use-home* (concat (expand-file-name "~") "/"))
(defvar *dot-emacs-path* (concat *use-home* ".emacs.d/"))
(defvar *plugin-path* (concat *dot-emacs-path* "plugins/"))

;;; R & ESS path
(defvar *ess-path* (concat *dot-emacs-path* "ess/lisp"))
(defvar *r-bin* "/path/to/R")
(defvar *r-start-args* "--quiet --no-restore-history --no-save ")

;;; Common Lisp path
(defvar *cl-path* (concat *dot-emacs-path* "common-lisp/"))
;; brew install sbcl
(defvar *sbcl* "/path/to/sbcl")
(defvar *slime-path* (concat *cl-path* "slime/"))
;; NOTICE: jnjcc@github:dotfiles/dotemacs.d/common-lisp/docs/
(setq common-lisp-hyperspec-root (concat *cl-path* "docs/HyperSpec/"))

;;; Maxima path
(defvar *maxima-path* "/usr/local/share/maxima/5.37.2/emacs/")

;;; Org path
;; org-reveal needs `org-export-get-reference'
;;   http://orgmode.org/org-9.1.tar.gz
(defvar *org-latest* (concat *plugin-path* "org-9.1/lisp/"))
(defvar *htmlize-path* (concat *dot-emacs-path* "htmlize/"))
;;   https://github.com/hakimel/reveal.js/
(defvar *reveal-js-path* (concat "file://" *htmlize-path* "reveal.js/"))
;; getwd() / setwd()
(defvar *latex-bin* "/Library/TeX/texbin/xelatex")
;;; <C-c a L>: timeline for current buffer
(defvar *org-path* "/path/to/org/")
;;; <M-x calendar> `d': diary for current day
(defvar *diary-file* (concat *org-path* "diary.org"))
;;; Register org file
(defvar *register-file* (concat *org-path* "daily.org"))
(set-register ?d '(file . *register-file*))
(defvar *org-agenda-files*
  (list (concat *org-path* "agenda.org")))
;;;; }}}
;;;;; END Key Mappings }}}

;;;;; I) Basic Configuration {{{
;;;; 1) Reading {{{
(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)
(blink-cursor-mode -1)
(column-number-mode t)
(line-number-mode t)
(show-paren-mode t)

(fset 'yes-or-no-p 'y-or-n-p)
(setq inhibit-startup-message t)

;;; Mode line: we want `buffer-name` + `default-directory`...
(setq-default mode-line-buffer-identification
              '("%b:" default-directory))
(require 'uniquify)
(setq uniquify-buffer-name-style 'post-forward)

;;; Controlling the Display
(setq scroll-preserve-screen-position t)
;; Automatic Scrolling
;;   by default, automatic scrolling centers point vertically in the window,
;;   which is weird to me
(setq scroll-step 1)

;;; Using Multiple Buffers
;; Fast minibuffer selection
; (icomplete-mode)
;; `completion-ignored-extensions`
;;;; END Reading }}}

;;;; 2) Searching {{{
;;; Searching and Replacement
; (setq search-whitespace-regexp nil)
;; Searching and Case
(setq-default case-fold-search nil)
;;;; END Searching }}}

;;;; 3) Editing {{{
;; Normally, we do not keep backup files
(setq make-backup-files nil)
;; M-x delete-trailing-whitespace
;;; FIXME: no-use after `whitespace-style`
(defun toggle-trailing-whitespace ()
  (set-face-background 'trailing-whitespace "red")
  (setq show-trailing-whitespace t))

;; do not `kill-region` if the mark is inactive
(setq mark-even-if-inactive nil)
;; highlight text selection
(transient-mark-mode t)
(delete-selection-mode t)

;;; Encoding {{{
; (setq default-buffer-file-coding-system 'utf-8)
(modify-coding-system-alist 'file "\\.txt\\'" 'chinese-gbk)
;;; }}}
;;;; END Editing }}}

;;;; 4) Window System {{{
(when window-system
  (set-face-attribute 'default nil :height 130)
  (set-fringe-mode '(1 . 1))
  (set-background-color "dark slate gray")
  (set-foreground-color "grey")
  ;; (global-set-key (kbd "<mouse-3>") 'mouse-popup-menubar-stuff)
  (global-set-key (kbd "M-RET") 'toggle-frame-fullscreen)
  (toggle-frame-maximized)
  (let ((path-from-shell
         (shell-command-to-string "$SHELL -l -i -c 'echo $PATH'")))
    (setenv "PATH" path-from-shell)
    (setq exec-path (split-string path-from-shell path-separator))))
;;;; END Window System }}}
;;;;; END Basic Configuration }}}

;;;;; II) Programming {{{
;; turn on syntax highlighting
(global-font-lock-mode t)

;;; Useless Whitespace
; (setq-default indicate-empty-lines t)
;; for <M-x whitespace-mode>
(setq whitespace-style '(face trailing tabs tab-mark newline newline-mark))

;;;; Indentation
;;; Convenience Features for Indentation
;;;   if line already indented, tries to complete text at point
(setq tab-always-indent 'complete)
(setq-default indent-tabs-mode nil)

;;;; Programming Languages {{{
;; make all comint prompt read only
(setq comint-prompt-read-only t)

(setq load-path (append (list *ess-path* *slime-path*) load-path))
(setq auto-mode-alist
      (append '(
                ("\\.R$" . R-mode)
                ("\\.lisp$" . lisp-mode)
                ("\\.lsp$" . lisp-mode)
                ("\\.asd$" . lisp-mode)
                ("\\.org$" . org-mode)
                ("\\.ma[cx]$" . maxima-mode))
              auto-mode-alist))
(defun highlight-todos ()
  (font-lock-add-keywords
   nil
   '(("\\<\\(FIXME\\|TODO\\|NOTICE\\)" 1
      font-lock-warning-face t))))
(add-hook 'prog-mode-hook
          (lambda ()
            (toggle-trailing-whitespace)
            (highlight-todos)))

;;; Emacs Lisp {{{
(add-hook 'emacs-lisp-mode-hook
          'eldoc-mode)
;;; }}}

;;; R {{{
;;;   ESS version 13.09-1, same as dotfiles-windows
(require 'ess-site)
(setq inferior-R-args *r-start-args*)
(setq inferior-R-program-name *r-bin*)
(setq ess-history-directory *use-home*)
(setq ess-ask-for-ess-directory nil)
(ess-toggle-underscore nil)
(add-hook 'R-mode-hook
          (lambda ()
            (require 'ess-eldoc)
            (setq ess-local-process-name "R")
            (setq ansi-color-for-comint-mode 'filter)
            (setq comint-scroll-to-bottom-on-input t)
            (setq comint-scroll-to-bottom-on-output t)
            (setq comint-move-point-for-ouput t)

            (autoload 'R-mode "ess-site.el" "ESS" t)
            (setq ess-tab-complete-in-script t)
            (setq ess-eval-visibly-p nil)
            (toggle-trailing-whitespace)
            (require 'ess-eldoc)))
;;; }}}

;;; Common Lisp {{{
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
(slime-setup-for-lisp)
(add-hook 'lisp-mode-hook
          (lambda ()
            (set (make-local-variable 'lisp-indent-function)
                 'common-lisp-indent-function)
            (define-key lisp-mode-map (kbd "TAB") 'lisp-indent-or-complete)
            (define-key lisp-mode-map "\C-r" 'forward-char)
            ; (setq browse-url-browser-function 'browse-url-generic
            ;       browse-url-generic-program "google-chrome")
            ))
;;; }}}

;;; Maxima {{{
;;;   NOTICE: only turn on maxima under window-system
;;;
;;;   Install maxima:
;;;     1) brew tap homebrew/science && brew update
;;;        brew install homebrew/science/maxima
;;;        brew uninstall gnuplot
;;;        ## for plot2d() & draw2d()
;;;        brew install gnuplot --with-qt --with-x11
;;;     2) http://maxima.sourceforge.net/
;;;
;;;   https://sites.google.com/site/imaximaimath/
(defun maxima-gui-init ()
  (setq exec-path
        (append
         (list
          ;; BasicTex: <http://pages.uoregon.edu/koch/>
          "/usr/texbin"
          ;; Ghostscript: <http://pages.uoregon.edu/koch/>>
          "/usr/local/bin")
         exec-path))
  ;; NOTICE: `rmaxima` with SBCL
  (setq imaxima-maxima-program "maxima")
  (add-hook 'inferior-maxima-mode-hook
            (lambda ()
              (local-set-key (kbd "TAB") 'inferior-maxima-complete)))
  (setq load-path (append (list *maxima-path*) load-path))
  (autoload 'maxima-mode "maxima" "Maxima mode" t)
  (autoload 'imaxima "imaxima" "Frontend for maxima with Image support" t)
  (autoload 'maxima "maxima" "Maxima interaction" t)
  (autoload 'imath-mode "imath" "Imath mode for math formula input" t)

  (setq imaxima-use-maxima-mode-flag t)
  (setq maxima-use-dynamic-complete t)
  ;; <M-x imaxima>
  (setq imaxima-gs-program "gs"))
;;; }}}

;;; Org Mode {{{
(setq load-path (append (list *org-latest*) load-path))
(setq latex-run-command *latex-bin*)
(with-eval-after-load "calendar"
  (setq diary-file *diary-file*)
  (calendar-set-date-style 'iso))
(defun org-mode-init ()
  ;; do not search hidden text
  ;;   <M-x show-all> / <S-TAB>
  (set (make-local-variable 'search-invisible) nil)
  (set (make-local-variable 'case-fold-search) t))
(with-eval-after-load "org"
  (setq org-directory *org-path*)
  (setq org-agenda-files *org-agenda-files*)
  (setq org-startup-indented t)
  (setq org-hide-emphasis-markers t)
  ;;; Key mappings
  (global-set-key "\C-cl" 'org-store-link)
  (global-set-key "\C-ca" 'org-agenda)
  (global-set-key "\C-cc" 'org-capture)
  (global-set-key "\C-cb" 'org-iswitchb)
  ;;; <C-a> moves to fancy place
  (setq org-special-ctrl-a/e t)
  (setq org-startup-folded t)
  ;;; <M-RET> do not split line on headline & item
  (setq org-M-RET-may-split-line '((table . t)))
  ;;; Progress logging
  (setq org-log-done 'time)
  ;;; Misc: src font
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((emacs-lisp . t) (python . t) (R . t)))
  (setq org-src-fontify-natively t)
  (setq org-src-tab-acts-natively t)
  ;;;; Embedded LaTeX
  ;;; Special symbols: `org-entities`
  (setq org-pretty-entities t)
  (setq org-use-sub-superscripts '{})
  (if window-system
      (set-face-attribute 'org-code nil :inherit 'shadow :background "dim gray")
    (set-face-attribute 'org-hide nil :foreground "black")))
(add-hook 'org-mode-hook
          (lambda ()
            (setq truncate-lines nil)
            (org-mode-init)
            ;;; #+Time-stamp: <>
            (add-hook 'before-save-hook
                      (lambda ()
                        (setq time-stamp-format "%:y-%02m-%02d %02H:%02M:%02S")
                        (time-stamp))
                      nil 'local)
            ;;; turn on flyspell-mode when editing org files, local to org-mode
            ;; (add-hook 'read-only-mode-hook
            ;;           (lambda ()
            ;;             (if buffer-read-only
            ;;                 (flyspell-mode 0)
            ;;               (flyspell-mode t)))
            ;;           nil 'local)
            (toggle-read-only)))
;;; }}}

;;; Python {{{
;; (require 'package)
;; (add-to-list 'package-archives
;;              '("elpy" . "https://jorgenschaefer.github.io/packages/"))
;; <M-x package-install RET elpy RET>
(setq python-shell-interpreter "ipython")
(defun ipython-elpy-init ()
  (package-initialize)
  (elpy-enable)
  ;; conda install ipython=4.2.0
  (elpy-use-ipython)
  ;; IPython 5.0:
  ;;   The new terminal interface is not compatible with
  ;;   Emacs 'inferior-shell' feature
  ;;   This ruins tab-completion, though
  ;; (setq python-shell-interpreter-args "--simple-prompt")
  (run-python (python-shell-parse-command)))
(add-hook 'python-mode-hook
          'ipython-elpy-init)
;;; }}}

;;; Window System {{{
;;;   only turn on maxima under window-system
(when window-system
  (maxima-gui-init))
;;; }}}
;;;; END Programming Languages }}}
;;;;; END Programming }}}

;;;;; III) Plugins {{{
(setq load-path (append (list *plugin-path*) load-path))
;;;; 1) linum {{{
; (add-hook 'linum-before-numbering-hook
;           (lambda ()
;             (setq linum-format "%d ")))
; (global-linum-mode 1)
;;;; }}}

;;;; 2) taglist {{{
;; <M-x visit-tags-table>; <M-x taglist>
;;   cedet & ecb does this better, but their size really freaks me out
(require 'taglist)
;;;; }}}

;;;; 3) sr-speedbar {{{
;;; NOTICE: sr-speedbar does not work under Emacs 25.3.1
;; (require 'sr-speedbar)
;; (setq sr-speedbar-right-side nil)
;; (setq sr-speedbar-skip-other-window-p t)
;; (setq sr-speedbar-auto-refresh t)
;; (setq sr-speedbar-max-width 30)
;; (setq speedbar-show-unknown-files t)
;; (setq speedbar-tag-hierarchy-method '(speedbar-prefix-group-tag-hierarchy))
;; (setq speedbar-sort-tags t)
;;;; }}}

;;;; 4) org-reveal {{{
(require 'ox-reveal)
(setq org-reveal-root *reveal-js-path*)
;;;; }}}
;;;;; END Plugins }}}

;;;;; IV) Miscellaneous {{{

;;;;; END Miscellaneous }}}

;;;;; V) Custom {{{
;;; Org-modes <M-x customize-face>
;;;;; END Custom
