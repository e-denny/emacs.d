;;; .emacs  --- user-init-file   -*- lexical-binding: t -*-

;;; Commentary:

;;; Code:

;; (setq gnutls-algorithm-priority "NORMAL:-VERS-TLS1.3")

(require 'package)
(package-initialize)
(setq package-enable-at-startup t)

(setq package-archives
      '(("melpa" . "https://melpa.org/packages/")
        ("gnu" . "https://elpa.gnu.org/packages/")
        ("nongnu" . "http://elpa.gnu.org/nongnu/")))

(setq package-archive-priorities
      '(("melpa" . 5)
        ("gnu" . 0)))

(when (not (package-installed-p 'use-package))
  (package-refresh-contents)
  (package-install 'use-package)
  (eval-when-compile (require 'use-package)))

(setq use-package-verbose t)

(require 'use-package-ensure)
(setq use-package-always-ensure t)

(if (and (fboundp 'native-comp-available-p)
         (native-comp-available-p))
    (message "Native compilation is available")
  (message "Native complation is *not* available"))

(customize-set-variable 'use-package-compute-statistics t)

;; ----------------------------------------------------------------------
;; garbage-collection
;; ----------------------------------------------------------------------

(setq read-process-output-max (* 1024 1024)) ; 1MB
(defvar my-gc 100000000) ; 100MB

(setq gc-cons-threshold my-gc)

(add-hook 'after-init-hook
          `(lambda ()
             (setq gc-cons-threshold my-gc
                   gc-cons-percentage 0.1)
             (garbage-collect)) t)

;; Run GC every 60 seconds if emacs is idle.
(run-with-idle-timer 60.0 t #'garbage-collect)

(defun my-gc-minibuf ()
  "Prevent garbage collection."
  (setq gc-cons-threshold most-positive-fixnum))

(defun my-gc-restore ()
  "Restore garbage collection."
  (run-at-time 1 nil (lambda () (setq gc-cons-threshold my-gc))))

(add-hook 'minibuffer-setup-hook #'my-gc-minibuf)
(add-hook 'minibuffer-exit-hook #'my-gc-restore)

;; ----------------------------------------------------------------------

(setq custom-file "~/.emacs.d/custom.el")
(setq custom-safe-themes t)
(load custom-file)

(use-package diminish)

(diminish 'visual-line-mode "")
(diminish 'undo-tree-mode "")
(diminish 'auto-revert-mode "")
(diminish 'isearch-mode "?")
(diminish 'abbrev-mode "")

;; ----------------------------------------------------------------------
;; defaults
;; ----------------------------------------------------------------------

;; (require 'epa)
;;   (epa-file-enable)
;;   (setq epg-gpg-program "gpg")

;;   (load-if-exists "~/.emacs.d/secrets.el.gpg")
;;   (load-if-exists "~/.emacs.d/secrets.el")

(add-to-list 'initial-frame-alist '(fullscreen . fullheight))
(add-to-list 'default-frame-alist '(internal-border-width . 8))

(set-face-attribute 'default nil
                    :family "Source Code Pro Semibold" :height 110 :width 'expanded)
(set-face-attribute 'variable-pitch nil
                    :font "Open Sans" :height 115)

(use-package emacs
  :ensure nil
  :config
  (blink-cursor-mode -1)
  (scroll-bar-mode -1)
  (tool-bar-mode -1)
  (menu-bar-mode -1)
  (tooltip-mode -1)
  (setq initial-scratch-message "")
  (setq inhibit-startup-screen t)
  (setq ring-bell-function 'ignore)
  (setq sentence-end-double-space nil)

  ;;kill running processes without confirmation on Emacs exit
  (setq confirm-kill-processes nil)

  (set-fringe-mode '(8 . 0))

  (fset 'yes-or-no-p 'y-or-n-p)
  (show-paren-mode 1)
  (column-number-mode 1)

  (global-hl-line-mode +1)
  (set-language-environment 'utf-8)
  (prefer-coding-system 'utf-8)
  (set-terminal-coding-system 'utf-8)
  (setq buffer-file-coding-system 'utf-8
        coding-system-for-read 'utf-8
        coding-system-for-write 'utf-8)

  (setq history-length t
        history-delete-duplicates t)
  (global-visual-line-mode 1)
  (setq-default indent-tabs-mode nil
                c-basic-offset 4
                tab-width 4
                tab-always-indent 'complete)
  ;; don't load old bype code
  (setq load-prefer-newer t)
  ;; auto revert mode
  (global-auto-revert-mode 1)
  ;; If a popup does happen, don't resize windows to be equal-sized
  (setq even-window-sizes nil)

  ;; smooth scrolling
  (setq scroll-margin 3
        scroll-conservatively 100
        scroll-preserve-screen-position t
        scroll-conservatively scroll-margin
        scroll-step 1
        mouse-wheel-scroll-amount '(6 ((shift) . 1))
        mouse-wheel-progressive-speed nil
        scroll-error-top-bottom t
        next-error-recenter (quote (4)))

  (setq backup-directory-alist '(("." . "~/.emacs.d/backup"))
        backup-by-copying t
        version-control t
        delete-old-versions t
        kept-new-versions 20
        kept-old-versions 5)

  (add-hook 'prog-mode-hook
            (lambda ()
              (font-lock-add-keywords
               nil
               '(("\\<\\(FIXME\\|TODO\\|BUG\\):" 1 font-lock-warning-face t)))))

  :hook ((prog-mode . flymake-mode)
         (before-save . whitespace-cleanup)
         (text-mode . turn-on-visual-line-mode))
  :bind (("s-e b" . eval-buffer)
         ("s-e r" . eval-region)
         ("s-b k" . kill-buffer))
  )

(define-key minibuffer-local-map [escape] 'minibuffer-keyboard-quit)
(define-key minibuffer-local-ns-map [escape] 'minibuffer-keyboard-quit)
(define-key minibuffer-local-completion-map [escape] 'minibuffer-keyboard-quit)
(define-key minibuffer-local-must-match-map [escape] 'minibuffer-keyboard-quit)
(define-key minibuffer-local-isearch-map [escape] 'minibuffer-keyboard-quit)

(setq window-divider-default-right-width 12)
(setq window-divider-default-bottom-width 12)
(setq window-divider-default-places t)
(window-divider-mode 1)

(setq default-frame-alist
      (append (list '(internal-border-width . 12))))

;; ----------------------------------------------------------------------
;; edgar theme
;; ----------------------------------------------------------------------

(use-package edgar-theme
  :load-path "lisp/edgar-theme"
  :config
  (load-theme 'edgar t))

;; ----------------------------------------------------------------------
;; avy
;; ----------------------------------------------------------------------

(use-package avy
  :bind (("s-s w" . avy-goto-word-or-subword-1)
         ("s-s y" . avy-goto-symbol-1)
         ("s-s c" . avy-goto-char-2)
         ("s-j l" . avy-goto-line))
  :config
  (setq avy-background t))

;; ----------------------------------------------------------------------
;; kill ring
;; ----------------------------------------------------------------------

(use-package browse-kill-ring
  :config
  (setq browse-kill-ring-quit-action 'kill-and-delete-window))

(setq save-interprogram-paste-before-kill t)

;; ----------------------------------------------------------------------
;; psession
;; ----------------------------------------------------------------------

(use-package psession
  :config
  (psession-mode 1)
  (psession-savehist-mode 1)
  (psession-autosave-mode 1))

;; ----------------------------------------------------------------------
;; symex
;; ----------------------------------------------------------------------

;; (use-package symex
;;   :commands symex-mode
;;   :config
;;   (symex-initialize)
;;   (global-set-key (kbd "s-;") 'symex-mode-interface))


;; ----------------------------------------------------------------------
;; corfu / company
;; ----------------------------------------------------------------------

;; (use-package company
;;   :commands company-mode
;;   :bind (:map company-active-map
;;               ("<ESC>" . 'company-abort)
;;               ("C-n" . 'company-select-next)
;;               ("C-p" . 'company-select-previous))
;;   :hook ((emacs-lisp-mode . company-mode)
;;          (lisp-mode . company-mode)
;;          (sly-mrepl-mode . company-mode))
;;   :config
;;   ;; (add-hook 'after-init-hook 'global-company-mode)
;;   (global-company-mode)
;;   (setq company-selection-wrap-around t)
;;   (setq company-require-match 'never)
;;   ;; (company-tng-configure-default)
;;   (setq company-idle-delay 0)
;;   ;; (global-set-key (kbd "TAB") #'company-indent-or-complete-common)
;;   )

;; (use-package company-quickhelp
;;   :after company
;;   :config
;;   (define-key company-active-map (kbd "C-c h") #'company-quickhelp-manual-begin))

;; (use-package cape)

(use-package corfu
  :bind (:map corfu-map
              ("<escape>" . corfu-quit)
              ("<return>" . corfu-insert)
              ;;              ("M-d" . corfu-show-documentation)
              ("M-l" . corfu-show-location))
  :custom
  ;; Works with `indent-for-tab-command'. Make sure tab doesn't indent when you
  ;; want to perform completion
  (tab-always-indent 'complete)
  (completion-cycle-threshold nil)      ; Always show all candidates in popup menu
  (corfu-cycle t)
  (corfu-auto nil)
  (corfu-auto-prefix 2)
  (corfu-count 14)
  (corfu--goto)
  (corfu-quit-no-match t)
  (corfu-echo-documentation nil)
  (corfu-scroll-margin 5)
  (corfu-preselect-first t)
  (corfu-min-width 60)
  (corfu-max-width corfu-min-width)
  (corfu-separator ?\s)                 ; Necessary for use with orderless
  (corfu-quit-no-match 'separator)
  (corfu-preview-current 'insert)       ; Preview current candidate?
  (corfu-preselect-first t)             ; Preselect first candidate?
  :init
  (corfu-global-mode)
  :config
  (defun my/corfu-setup-lsp ()
    "Use orderless completion style with lsp-capf instead of the default lsp-passthrough."
    (setf (alist-get 'styles (alist-get 'lsp-capf completion-category-defaults))
          '(orderless)))
  :hook (lsp-completion-mode . my/corfu-setup-lsp))

(use-package kind-icon
  :after corfu
  :custom
  (kind-icon-use-icons t)
  (kind-icon-default-face 'corfu-default)
  (kind-icon-blend-background nil)
  (kind-icon-blend-frac 0.08)
  :config
  (add-to-list 'corfu-margin-formatters #'kind-icon-margin-formatter))

(use-package corfu-doc
  :load-path "lisp/corfu-doc"
  :after corfu
  :bind (:map corfu-map
              ([remap corfu-show-documentation] . corfu-doc-toggle)
              ("M-d" . corfu-doc-toggle)
              ("M-n" . corfu-doc-scroll-up)
              ("M-p" . corfu-doc-scroll-down))
  :custom
  (corfu-doc-delay 0.5)
  (corfu-doc-max-width 70)
  (corfu-doc-max-height 20)
  (corfu-echo-documentation nil)
  :hook (corfu-mode . corfu-doc-mode))


(use-package dabbrev
  ;; Swap M-/ and C-M-/
  :bind (("M-/" . dabbrev-completion)
         ("C-M-/" . dabbrev-expand)))

;; (use-package emacs
;;   :init
;;   (setq completion-cycle-threshold 3)
;;   (setq read-extended-command-predicate
;;         #'command-completion-default-include-p))

;; ----------------------------------------------------------------------
;; dired
;; ----------------------------------------------------------------------

(use-package dired
  :ensure nil
  :bind (("s-d d" . dired)
         ("s-d j" . dired-jump))
  :custom
  (dired-listing-switches "-laGh1v --group-directories-first")
  (dired-recursive-copies 'always)
  (dired-recursive-deletes 'always)
  (dired-kill-when-opening-new-dired-buffer t)
  ;; we want dired not not make always a new buffer if visiting a directory
  ;; but using only one dired buffer for all directories.
  :config
  (defadvice dired-advertised-find-file (around dired-subst-directory activate)
    "Replace current buffer if file is a directory."
    (interactive)
    (let ((orig (current-buffer))
          (filename (dired-get-filename)))
      ad-do-it
      (when (and (file-directory-p filename)
                 (not (eq (current-buffer) orig)))
        (kill-buffer orig))))
  ;; auto refresh dired when file changes
  :hook (dired-mode . auto-revert-mode))

(use-package dired-subtree
  :bind (:map dired-mode-map
              ("<tab>" . dired-subtree-toggle)))

(use-package dired-narrow
  ;; type 'g' to un-narrow
  :bind (:map dired-mode-map
              ("/" . dired-narrow)))

(use-package dired-sidebar
  :bind ("s-d s" . dired-sidebar-toggle-sidebar)
  :init
  (add-hook 'dired-sidebar-mode-hook
            (lambda ()
              (unless (file-remote-p default-directory)
                (auto-revert-mode))))
  :config
  (push 'toggle-window-split dired-sidebar-toggle-hidden-commands)
  (push 'rotate-windows dired-sidebar-toggle-hidden-commands)

  (setq dired-sidebar-subtree-line-prefix "  ")
  (setq dired-sidebar-use-term-integration t)
  (setq dired-sidebar-use-custom-font t))

;; colorful dired
(use-package diredfl
  :config
  (diredfl-global-mode 0))

(use-package dired-git-info
  :bind (:map dired-mode-map
              (")" . dired-git-info-mode)))

;; ----------------------------------------------------------------------
;; info
;; ----------------------------------------------------------------------

(use-package info-colors
  :hook (Info-selection . info-colors-fontify-node))

;; ----------------------------------------------------------------------
;; elisp
;; ----------------------------------------------------------------------

(defvar +emacs-lisp--face nil)

(defvar +emacs-lisp-enable-extra-fontification t
  "If non-nil, highlight special forms, and defined functions and variables.")

;; from doom emacs
(defun +emacs-lisp-highlight-vars-and-faces (end)
  "Match defined variables and functions to END.
Functions are differentiated into special forms, built-in functions and
library/userland functions"
  (catch 'matcher
    (while (re-search-forward "\\(?:\\sw\\|\\s_\\)+" end t)
      (let ((ppss (save-excursion (syntax-ppss))))
        (cond ((nth 3 ppss)  ; strings
               (search-forward "\"" end t))
              ((nth 4 ppss)  ; comments
               (forward-line +1))
              ((let ((symbol (intern-soft (match-string-no-properties 0))))
                 (and (cond ((null symbol) nil)
                            ((eq symbol t) nil)
                            ((keywordp symbol) nil)
                            ((special-variable-p symbol)
                             (setq +emacs-lisp--face 'font-lock-variable-name-face))
                            ((and (fboundp symbol)
                                  (eq (char-before (match-beginning 0)) ?\()
                                  (not (memq (char-before (1- (match-beginning 0)))
                                             (list ?\' ?\`))))
                             (let ((unaliased (indirect-function symbol)))
                               (unless (or (macrop unaliased)
                                           (special-form-p unaliased))
                                 (let (unadvised)
                                   (while (not (eq (setq unadvised (ad-get-orig-definition unaliased))
                                                   (setq unaliased (indirect-function unadvised)))))
                                   unaliased)
                                 (setq +emacs-lisp--face
                                       (if (subrp unaliased)
                                           'font-lock-constant-face
                                         'font-lock-function-name-face))))))
                      (throw 'matcher t)))))))
    nil))

;; We byte-compile to ensure they run as fast as possible:
(dolist (fn '(+emacs-lisp-highlight-vars-and-faces))
  (unless (byte-code-function-p (symbol-function fn))
    (with-no-warnings (byte-compile fn))))

(use-package highlight-quoted)

(use-package elisp-mode
  :ensure nil
  :custom
  (font-lock-maximum-decoration t)
  (debugger-stack-frame-as-list t)
  ;; Enhance elisp syntax highlighting, by highlighting defined symbols.
  :config
  (defun my-enhanced-elisp-fontification ()
    (font-lock-add-keywords
     'emacs-lisp-mode
     (append
      ;; highlight defined, special variables & functions
      (when +emacs-lisp-enable-extra-fontification
        `((+emacs-lisp-highlight-vars-and-faces . +emacs-lisp--face))))))
  (defun my/debugger-pp-frame ()
    (interactive)
    (let ((inhibit-read-only t)
          (frame (backtrace-frame (debugger-frame-number))))
      (set-buffer (pop-to-buffer "*BT: Frame*"))
      (destructuring-bind (special fn &rest args) frame
                          (erase-buffer)
                          (progn
                            (insert "(" (pp-to-string fn))
                            (dolist (arg args)
                              (insert "\n" (pp-to-string arg)))
                            (insert ")"))
                          (goto-char (point-min))
                          (indent-pp-sexp))))
  :hook ((emacs-lisp-mode . highlight-quoted-mode)
         (emacs-lisp-mode . my-enhanced-elisp-fontification)))


(use-package eldoc
  :diminish eldoc-mode
  :commands turn-on-eldoc-mode
  :defer t
  :init
  (setq eldoc-idle-delay 0.1)
  :hook ((emacs-lisp-mode . eldoc-mode)
         (lisp-interaction-mode . eldoc-mode)
         (lisp-mode . eldoc-mode)
         (ielm-mode . eldoc-mode)))

;; M-. navigate to symbol
;; M-, pop back to prevous marks
(use-package elisp-slime-nav
  :diminish
  :bind ("s-h v" . elisp-slime-nav-describe-elisp-thing-at-point)
  :hook ((emacs-lisp-mode ielm-mode lisp-interaction-mode) . elisp-slime-nav-mode))

(use-package macrostep
  :bind (("s-c m e" . macrostep-expand)
         ("s-c m n" . macrostep-next-macro)
         ("s-c m p" . macrostep-prev-macro)
         ("s-c m c" . macrostep-collapse)
         ("s-c m q" . macrostep-collapse-all)))

(use-package smartparens
  :diminish smartparens-mode
  :hook ((emacs-lisp-mode . smartparens-mode)
         (lisp-interaction-mode . smartparens-mode)
         (lisp-mode . smartparens-mode)
         (ielm-mode . smartparens-mode)
         (eval-expression-minibuffer-setup . smartparens-mode))
  ;; FIXME: this is not working
  :bind (:map smartparens-mode-map
              ("C-)" . sp-forward-slurp-sexp)
              ("C-(" . sp-backward-slurp-sexp)
              ("C-}" . sp-forward-barf-sexp)
              ("C-{" . sp-backward-barf-sexp)))

(use-package highlight-parentheses
  :diminish highlight-parentheses-mode
  :config
  (set-face-attribute 'hl-paren-face nil :weight 'ultra-bold)
  ;; (set-face-attribute 'hl-paren-face nil :background "gray92")
  (global-highlight-parentheses-mode)
  ;;make paren highlight update after stuff like paredit changes
  (add-to-list 'after-change-functions '(lambda (&rest x) (hl-paren-highlight))))

(use-package aggressive-indent
  :diminish aggressive-indent-mode
  :hook ((emacs-lisp-mode scheme-mode) . aggressive-indent-mode))

;; ----------------------------------------------------------------------
;; common-lisp
;; ----------------------------------------------------------------------

(defvar inferior-lisp-program "sbcl")
(defvar sly-contribs '(sly-fancy))

(use-package sly
  :init
  (sly-setup)
  :config
  (add-hook 'lisp-mode-hook #'sly-editing-mode)
  (add-hook 'sly-mode-hook
            (lambda ()
              (unless (sly-connected-p)
                (save-excursion (sly)))))
  (setq sly-kill-without-query-p t
        sly-net-coding-system 'utf-8-unix
        sly-complete-symbol-function 'sly-simple-completions))

(use-package sly-repl-ansi-color
  :defer t
  :init
  (add-to-list 'sly-contribs 'sly-repl-ansi-color))

;; ----------------------------------------------------------------------
;; eshell
;; ----------------------------------------------------------------------

(use-package eshell
  :init
  (add-hook 'eshell-mode-hook
            (lambda ()
              (eshell/alias "e" "find-file $1")
              (eshell/alias "ll" "ls -ltra --color=always")
              (eshell/alias "d" "dired $1")))
  (add-hook 'eshell-mode-hook
            (lambda()
              ;; programs that don't work well in eshell and should be run in visual mode
              (add-to-list 'eshell-visual-commands "ssh")
              (add-to-list 'eshell-visual-commands "tail")
              (add-to-list 'eshell-visual-commands "htop"))))

;; ----------------------------------------------------------------------
;; shrface
;; ----------------------------------------------------------------------

(use-package shrface
  :defer t
  :config
  (shrface-basic)
  (shrface-trial)
  (setq shrface-href-versatile t))

;; ----------------------------------------------------------------------
;; browser
;; ----------------------------------------------------------------------

(use-package eww
  :commands eww
  :init
  (add-hook 'eww-after-render-hook #'shrface-mode)
  :config
  (require 'shrface))

(setq my-browsers
      '(("Firefox" . browse-url-firefox)
        ("Chromium" . browse-url-chromium)
        ("EWW" . eww-browse-url)))

(setq browse-url-browser-function #'eww-browse-url)

;; (defun my-browse-url (&rest args)
;;   "Select the prefered browser from a helm menu before opening the URL."
;;   (interactive)
;;   (let ((browser (or (helm :sources (helm-build-sync-source "WWW browsers"
;;                                                             :candidates (mapcar 'car my-browsers))
;;                            :buffer "*my browsers*")
;;                      (signal 'quit nil))))
;;     (apply (cdr (assoc browser my-browsers)) args)))

;; (setq browse-url-browser-function #'my-browse-url)

;; ----------------------------------------------------------------------
;; hippie expand
;; ----------------------------------------------------------------------

(use-package hippie-exp
  :bind (("M-/" . hippie-expand))
  :config
  (setq hippie-expand-try-functions-list '(try-expand-dabbrev
                                           try-expand-dabbrev-all-buffers
                                           try-expand-dabbrev-from-kill
                                           try-complete-file-name-partially
                                           try-complete-file-name
                                           try-expand-all-abbrevs
                                           try-expand-list
                                           try-expand-line
                                           try-complete-lisp-symbol-partially
                                           try-complete-lisp-symbol)))

;; ----------------------------------------------------------------------
;; vertico
;; ----------------------------------------------------------------------

(use-package all-the-icons)

(use-package all-the-icons-completion
  :after (marginalia all-the-icons)
  :hook (marginalia-mode . all-the-icons-completion-marginalia-setup)
  :init
  (all-the-icons-completion-mode))

(use-package vertico
  :bind (:map vertico-map
              ("<tab>" . vertico-insert)                ; insert selected candidate
              ("<escape>" . minibuffer-keyboard-quit)   ; close minibuffer
              ;; cycle through candidate groups
              ("C-M-n" . vertico-next-group)
              ("C-M-p" . vertico-previous-group))
  :init
  (vertico-mode)
  ;; Show more candidates
  (setq vertico-count 20)
  ;; Grow and shrink the Vertico minibuffer
  (setq vertico-resize t)
  ;; (setq vertico-cycle t)
  (require 'vertico-buffer)
  (vertico-buffer-mode)
  (setq vertico-buffer-display-action `(display-buffer-in-direction
                                        (direction . down)
                                        (window-height . ,(+ 3 vertico-count)))))

(use-package orderless
  :init
  (setq completion-styles '(orderless))
  :config
  (setq orderless-component-separator "[ &]")
  (defun just-one-face (fn &rest args)
    (let ((orderless-match-faces [completions-common-part]))
      (apply fn args)))
  (advice-add 'company-capf--candidates :around #'just-one-face))

(use-package emacs
  :init
  ;; Add prompt indicator to `completing-read-multiple'.
  ;; Alternatively try `consult-completing-read-multiple'.
  (defun crm-indicator (args)
    (cons (concat "[CRM] " (car args)) (cdr args)))
  (advice-add #'completing-read-multiple :filter-args #'crm-indicator)

  (setq minibuffer-prompt-properties
        '(read-only t cursor-intangible t face minibuffer-prompt))
  (add-hook 'minibuffer-setup-hook #'cursor-intangible-mode)

  (setq read-extended-command-predicate
        #'command-completion-default-include-p)
  (setq enable-recursive-minibuffers t))

(use-package marginalia
  ;; Either bind `marginalia-cycle` globally or only in the minibuffer
  :bind (("M-A" . marginalia-cycle)
         :map minibuffer-local-map
         ("M-A" . marginalia-cycle))
  :init
  (marginalia-mode)
  :config
  (setq marginalia-margin-threshold 500)
  ;; (add-hook 'marginalia-mode-hook #'all-the-icons-completion-marginalia-setup)
  )

(use-package consult
  ;; Replace bindings. Lazily loaded due by `use-package'.
  :bind (
         ;; C-c bindings (mode-specific-map)
         ("s-b h" . consult-history)
         ;; ("C-c m" . consult-mode-command)
         ("s-m b" . consult-bookmark)
         ;; ("C-c k" . consult-kmacro)
         ;; ("C-x M-:" . consult-complex-command)     ;; orig. repeat-complex-command

         ;; buffer
         ("s-b b" . consult-buffer)                ;; orig. switch-to-buffer
         ("s-b o" . consult-buffer-other-window) ;; orig. switch-to-buffer-other-window
         ;; ("C-x 5 b" . consult-buffer-other-frame)  ;; orig. switch-to-buffer-other-frame

         ;; ;; Custom M-# bindings for fast register access
         ;; ("M-#" . consult-register-load)
         ;; ("M-'" . consult-register-store)          ;; orig. abbrev-prefix-mark (unrelated)
         ;; ("C-M-#" . consult-regi)
         ;; Other custom bindings
         ;; ("M-y" . consult-yank-pop)                ;; orig. yank-pop
         ("<help> a" . consult-apropos)            ;; orig. apropos-command

         ;; goto
         ("s-g e" . consult-compile-error)
         ("s-g f" . consult-flymake)               ;; Alternative: consult-flycheck
         ("s-g g" . consult-goto-line)             ;; orig. goto-line
         ("s-g s -g" . consult-goto-line)           ;; orig. goto-line
         ("s-g o" . consult-outline)               ;; Alternative: consult-org-heading
         ("s-g m" . consult-mark)
         ("s-g k" . consult-global-mark)
         ("s-g i" . consult-imenu)
         ("s-g I" . consult-imenu-multi)

         ;; search
         ("s-s f" . consult-find)
         ("s-s F" . consult-locate)
         ("s-s g" . consult-grep)
         ("s-s G" . consult-git-grep)
         ("s-s r" . consult-ripgrep)
         ("s-s l" . consult-line)
         ("s-s L" . consult-line-multi)
         ("s-s m" . consult-multi-occur)
         ("s-s k" . consult-keep-lines)
         ("s-s u" . consult-focus-lines)
         ("s-s e" . consult-isearch-history)
         :map isearch-mode-map
         ("s-s e" . consult-isearch-history)       ;; orig. isearch-edit-string
         ("s-s l" . consult-line)                  ;; needed by consult-line to detect isearch
         ("s-s L" . consult-line-multi))           ;; needed by consult-line to detect isearch

  ;; Enable automatic preview at point in the *Completions* buffer. This is
  ;; relevant when you use the default completion UI. You may want to also
  ;; enable `consult-preview-at-point-mode` in Embark Collect buffers.
  :hook (completion-list-mode . consult-preview-at-point-mode)

  :init
  ;; Optionally configure the register formatting. This improves the register
  ;; preview for `consult-register', `consult-register-load',
  ;; `consult-register-store' and the Emacs built-ins.
  (setq register-preview-delay 0
        register-preview-function #'consult-register-format)

  ;; Optionally tweak the register preview window.
  ;; This adds thin lines, sorting and hides the mode line of the window.
  (advice-add #'register-preview :override #'consult-register-window)

  ;; Optionally replace `completing-read-multiple' with an enhanced version.
  (advice-add #'completing-read-multiple :override #'consult-completing-read-multiple)

  ;; Use Consult to select xref locations with preview
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)

  :config
  ;; Optionally configure preview. The default value
  ;; is 'any, such that any key triggers the preview.
  ;; (setq consult-preview-key 'any)
  ;; (Setq consult-preview-key (kbd "M-."))
  ;; (s etq consult-preview-key (list (kbd "<S-down>") (kbd "<S-up>")))
  ;; For some commands and buffer sources it is useful to configure the
  ;; :preview-key on a per-command basis using the `consult-customize' macro.
  (consult-customize
   consult-theme
   :preview-key '(:debounce 0.2 any)
   consult-ripgrep consult-git-grep consult-grep
   consult-bookmark consult-recent-file
   consult--source-recent-file consult--source-project-recent-file consult--source-bookmark
   :preview-key (kbd "M-."))

  ;; Optionally configure the narrowing key.
  ;; Both < and C-+ work reasonably well.
  (setq consult-narrow-key "<") ;; (kbd "C-+")

  (setq consult-project-root-function
        (lambda ()
          (when-let (project (project-current))
            (car (project-roots project)))))
  )

;; ----------------------------------------------------------------------
;; embark
;; ----------------------------------------------------------------------

(use-package embark
  :bind(("C-." . embark-act)
        :map minibuffer-local-map
        ("C-M-e" . embark-act))
  :config
  (setq embark-action-indicator
        (lambda (map)
          (which-key--show-keymap "Embark" map nil nil 'no-paging)
          #'which-key--hide-popup-ignore-command)
        embark-become-indicator embark-action-indicator))

;; Consult users will also want the embark-consult package.
(use-package embark-consult
  :after (embark consult)
  :demand t ; only necessary if you have the hook below
  ;; if you want to have consult previews as you move around an
  ;; auto-updating embark collect buffer
  :hook
  (embark-collect-mode . consult-preview-at-point-mode))

;; ----------------------------------------------------------------------
;; hydra
;; ----------------------------------------------------------------------

(use-package hydra)

;; ----------------------------------------------------------------------
;; helpful
;; ----------------------------------------------------------------------

(use-package helpful
  :bind (([remap describe-command] . helpful-command)
         ([remap describe-key] . helpful-key)
         ("s-h h" . helpful-at-point)
         :map helpful-mode-map
         ("q" . delete-window)))

;; ----------------------------------------------------------------------
;; buffer placement
;; ----------------------------------------------------------------------

(setq display-buffer-alist
      `((,(rx bos (or "*Apropos*" "*Help*" "*helpful" "*info*" "*Summary*") (0+ not-newline))
         (display-buffer-reuse-mode-window display-buffer-below-selected)
         (window-height . 0.33)
         (mode apropos-mode help-mode helpful-mode Info-mode Man-mode))))

;; ----------------------------------------------------------------------
;; ccls
;; ----------------------------------------------------------------------

(use-package ccls
  :hook ((c-mode c++-mode objc-mode cuda-mode) .
         (lambda () (require 'ccls))))

;; ----------------------------------------------------------------------
;; lsp
;; ----------------------------------------------------------------------

(use-package lsp-mode
  :commands lsp-install-server
  :custom
  (lsp-completion-provider :none) ;; we use Corfu!
  :init
  (defun my/orderless-dispatch-flex-first (_pattern index _total)
    (and (eq index 0) 'orderless-flex))

  (defun my/lsp-mode-setup-completion ()
    (setf (alist-get 'styles (alist-get 'lsp-capf completion-category-defaults))
          '(orderless)))

  ;; ;; Optionally configure the first word as flex filtered.
  ;; (add-hook 'orderless-style-dispatchers #'my/orderless-dispatch-flex-first nil 'local)

  ;; ;; Optionally configure the cape-capf-buster.
  ;; (setq-local completion-at-point-functions (list (cape-capf-buster #'lsp-completion-at-point)))

  :config
  (setq lsp-auto-guess-root t
        lsp-file-watch-threshold 500
        lsp-auto-configure nil
        lsp-eldoc-render-all t
        lsp-enable-xref t
        lsp-enable-symbol-highlighting t
        lsp-semantic-tokens-enable t
        lsp-prefer-flymake t)
  :bind (("s-l c" . lsp-describe-session)
         ("s-l d" . lsp-find-declaration)
         ("s-l D" . xref-find-definitions)
         ("s-l R" . xref-find-references)
         ("s-l i" . lsp-find-implementation)
         ("s-l t" . lsp-find-type-definition)
         ("s-l ?" . display-local-help)
         ("s-l s" . lsp-signature-help)
         ("s-l r" . lsp-rename)
         ("s-l h" . lsp-describe-thing-at-point)
         ("s-l f" . lsp-format-buffer)
         ("s-l x" . lsp-execute-code-action)
         ("s-l R" . lsp-restart-workspace)
         ("s-l S" . lsp-shutdown-workspace))
  :hook (((c-mode c++-mode java-mode python-mode) . lsp)
         ;; (lsp-completion-mode . my/lsp-mode-setup-completion)
         ))

(use-package lsp-ui
  :after lsp-mode
  :bind (("s-l s-m" . lsp-ui-imenu)
         ("s-l s-d" . lsp-ui-peek-find-definitions)
         ("s-l s-r" . lsp-ui-peek-find-references)
         ("s-l s-i" . lsp-ui-peek-find-implementation))
  :config
  (setq lsp-ui-doc-enable nil)
  (setq lsp-ui-doc-delay 100)
  (setq lsp-ui-sideline-show-hover nil
        lsp-ui-peek-always-show t)
  (setq lsp-ui-doc-include-signature t)
  (lsp-ui-doc-mode -1)
  :hook (lsp-mode . lsp-ui-mode))

(use-package dap-mode
  :after lsp-mode
  :defer t
  :config
  (dap-mode t)
  (dap-ui-mode t))

;; ----------------------------------------------------------------------
;; magit
;; ----------------------------------------------------------------------

(use-package magit
  :bind (("s-m s" . magit-status)
         ("s-m d" . magit-diff)
         ("s-m c" . magit-commit)
         ("s-m p" . magit-push)))

(use-package git-gutter
  :diminish git-gutter-mode
  :init
  (progn
    (add-hook 'prog-mode-hook 'git-gutter-mode)
    (add-hook 'org-mode-hook 'git-gutter-mode))
  :bind (("s-m g n" . git-gutter:next-hunk)
         ("s-m g p" . git-gutter:previous-hunk)
         ("s-m g =" . git-gutter:popup-hunk)
         ("s-m g r" . git-gutter:revert-hunk))
  :custom
  (git-gutter:modified-sign ">")
  (git-gutter:added-sign "+")
  (git-gutter:deleted-sign "-")
  :custom-face
  (git-gutter:modified ((t (:background "#c0b18b" :foreground "#2f2f2f"))))
  (git-gutter:added    ((t (:background "#84edb9" :foreground "#2f2f2f"))))
  (git-gutter:deleted  ((t (:background "#d75f5f" :foreground "#2f2f2f")))))

;; ----------------------------------------------------------------------
;; org
;; ----------------------------------------------------------------------

;; (use-package olivetti
;;   :config
;;   (add-hook 'text-mode 'olivetti-mode))

(use-package org
  :mode ("\\.org\\'" . org-mode)
  :bind (("s-o l s" . org-store-link)
         ("s-o l i" . org-insert-link)
         ("s-o m" . org-mu4e-store-and-capture)
         ("s-o c" . org-capture)
         ("s-o a" . org-agenda)
         ("s-o b" . org-iswitchb)
         ("s-o r" . org-refile))
  :custom-face
  (org-document-title ((t (:foreground "#171717" :weight bold :height 1.5))))
  :config
  (progn
    (setq org-directory "/home/edgar/Notes")
    (setq org-agenda-files (directory-files-recursively (concat org-directory "/Agenda/") "\.org$"))
    (setq org-log-done 'time)
    (setq org-agenda-show-all-dates nil)
    (setq org-capture-templates
          `(("i" "Todo [inbox]" entry
             (file+headline ,(format "%s/%s" org-directory "Inbox.org") "Inbox")
             "* TODO %i%?")
            ("w" "Web site" entry
             (file "")
             "* %a :website:\n\n%U %?\n\n%:initial")
            ("M" "mu4e with kill" entry
             (file+headline ,(format "%s/%s" org-directory "Inbox.org") "Inbox")
             "* TODO %a %?\nSCHEDULED: %(org-insert-time-stamp (org-read-date nil t \"+0d\")) \n %c \n")
            ("m" "mu4e" entry
             (file+headline ,(format "%s/%s" org-directory "Inbox.org") "Inbox")
             "* TODO %a %?\nSCHEDULED: %(org-insert-time-stamp (org-read-date nil t \"+0d\"))\n")
            ("j" "Task Diary" entry
             (file+datetree ,(format "%s/%s" org-directory "/Agenda/Journal.org"))
             "* TODO %^{Description}  %^g \n %? \n Added: %U")
            ("T" "Tickler" entry
             (file+headline ,(format "%s/%s" org-directory "Tickler.org") "Tickler")
             "* %i%? \n %^t")))

    (setq org-return-follows-link t)

    ;;    (org-catch-invisible-edits 'show)

    (setq org-outline-path-complete-in-steps nil)
    (setq org-refile-allow-creating-parent-nodes 'confirm)
    (setq org-src-fontify-natively t
          org-edit-src-content-indentation 0
          org-src-tab-acts-natively t
          org-src-preserve-indentation t)
    (setq org-use-speed-commands t)

    (add-to-list 'org-modules 'org-habit t)

    ;; log TODO creation also
    (setq org-treat-insert-todo-heading-as-state-change t)
    ;; log into LOGBOOK drawer
    (setq org-log-into-drawer t)

    ;; show agenda from today rather than Monday
    (setq org-agenda-start-on-weekday nil)

    (setq org-startup-indented t
          org-startup-truncated nil
          org-ellipsis " …"
          org-return-follows-link t)
    (setq org-hide-emphasis-markers t)
    (setq org-hide-leading-stars t)
    (setq org-src-fontify-natively t)
    (setq org-refile-use-outline-path t
          org-reverse-note-order nil)
    (setq org-tags-column 70)
    (setq org-agenda-skip-scheduled-if-deadline-is-shown t)
    (setq org-agenda-skip-deadline-if-done t)
    (setq org-agenda-skip-scheduled-if-done t)
    (setq org-deadline-warning-days 7)
    (setq org-agenda-ndays 7)

    ;;don't show tasks that are scheduled or have deadlines in the
    ;;normal todo list
    (setq org-agenda-todo-ignore-deadlines 'all)
    (setq org-agenda-todo-ignore-scheduled 'all)
    ;;sort tasks in order of when they are due and then by priority
    (setq org-agenda-sorting-strategy
          '((agenda deadline-up priority-down)
            (todo priority-down category-keep)
            (tags priority-down category-keep)
            (search category-keep)))

    ;; refile
    (setq org-refile-targets '((nil :maxlevel . 4)
                               (org-agenda-files :maxlevel . 4)))
    (setq org-refile-use-outline-path 'file)
    (setq org-outline-path-complete-in-steps nil)
    (setq org-refile-allow-creating-parent-nodes 'confirm)

    (setq org-tags-column 0)
    (setq org-agenda-tags-column 0)

    (setq org-agenda-span 14)
    (setq org-todo-keywords '((sequence "TODO(t)" "IN-PROGRESS(p)" "NOTE(n)" "WAITING(w)" "|" "DONE(d)")))
    (add-hook 'org-mode-hook (lambda () (setq fill-column 100)))
    (add-hook 'org-mode-hook 'turn-on-auto-fill)
    (add-hook 'org-mode-hook 'org-indent-mode)

    (setq org-clock-persist t)
    (org-clock-persistence-insinuate)
    (setq org-outline-path-complete-in-steps 't)
    (setq org-time-clocksum-format '(:hours "%d" :require-hours t :minutes ":%02d" :require-minutes t))

    (org-babel-do-load-languages 'org-babel-load-languages
                                 '((emacs-lisp . t)
                                   (python . t)))

    (org-link-set-parameters
     "search-view" :follow 'my-search-view-link)

    (defun my-search-view-link (txt)
      "Display a list of TODOs that match txt"
      (setq current-prefix-arg 1)
      (org-search-view (null current-prefix-arg) txt))

    (defun my/hash-word-to-search-view ()
      "Create search-view link if word starts with a hash."
      (when (eq major-mode 'org-mode)
        (with-current-buffer (current-buffer)
          (save-excursion
            (goto-char (point-min))
            (while (re-search-forward "\\\( \\\)\\\(#\\\)\\\(\\\w+\\\|\\\w+\\\s_\\\w+\\\)\\\( \\\|$\\\)" nil t)
              (let ((txt (match-string 3)))
                (replace-match (concat " [[search-view:" txt "][#" txt "]] "))))))))

    (add-hook 'before-save-hook 'my/hash-word-to-search-view)

    (defun my/org-setup ()
      ;; (olivetti-mode 1)
      (set-fringe-style 0)
      ;; (setq olivetti-body-width 100)
      )

    (defun my/org-agenda-setup ()
      ;; (olivetti-mode 1)
      (setq org-agenda-files (directory-files-recursively (concat org-directory "/Agenda/") "\.org$"))
      ;; (setq olivetti-body-width 100)
      )

    (setq org-todo-keyword-faces
          '(("TODO" . (foreground "black" :background "brown2" :weight bold
                                  :overline "white"
                                  :box (:line-width (6 . 0) :style flat-button)))
            ("IN-PROGRESS" . (foreground "black" :background "SeaGreen" :weight bold
                                         :overline "white"
                                         :box (:line-width (6 . 1) :style flat-button)))
            ("NOTE" . (foreground "black" :background "tan4" :weight bold
                                  :overline "white"
                                  :box (:line-width (6 . 1) :color ,orange-1 :style flat-button)))
            ("WAITING" . (foreground "black" :background "orange3" :weight bold
                                     :overline "white"
                                     :box (:line-width (6 . 1) :style flat-button)))
            ("DONE" . (foreground "black" :background "DimGrey" :weight bold
                                  :overline "white"
                                  :box (:line-width (6 . 1) :style flat-button)))))
    (setq org-priority-faces '((?A . (:background "DimGrey" :weight bold))
                               (?B . (:background "DimGrey" :weight bold))
                               (?C . (:background "DimGrey" :weight bold))))

    (add-hook 'org-mode-hook 'my/org-setup)
    (add-hook 'org-agenda-mode-hook 'my/org-agenda-setup)
    ))

;; (use-package org-bullets
;;   ;;  :commands org-bullets-mode
;;   :config
;;   (add-hook 'org-mode-hook
;;             (lambda ()
;;               (org-bullets-mode 1)))
;;   (setq org-bullets-bullet-list '("●" "○" "■" "□")))

(use-package org-ql
  :after org
  :commands (org-ql-search org-ql-view org-ql-view-sidebar org-ql-sparse-tree org-ql-block))

(use-package org-super-agenda
  :after org
  :config (org-super-agenda-mode))

(setq org-agenda-custom-commands
      '(("c" "Super Agenda" agenda
         (org-super-agenda-mode)
         ((org-super-agenda-groups
           '(
             (:name "Habits"
                    :habit t)
             (:name "Today"
                    :time-grid t
                    :scheduled today)
             (:name "Due Today"
                    :deadline today)
             (:name "Important"
                    :priority "A")
             (:name "Overdue"
                    :deadline past)
             (:name "Due soon"
                    :deadline future)
             (:name "Waiting"
                    :todo "WAITING")
             )))
         (org-agenda nil "a"))
        ("n" "Agenda"
         ((agenda ""
                  ((org-agenda-overriding-header "Scheduled")))
          (todo "TODO"
                ((org-agenda-overriding-header "Unscheduled")
                 (org-agenda-skip-function
                  (quote
                   (org-agenda-skip-entry-if
                    (quote scheduled)))))))
         nil nil)))

(use-package org-sidebar
  :after org
  :commands (org-sidebar-tree-toggle org-sidebar-toggle org-sidebar-ql)
  :custom (org-sidebar-tree-side 'left))

(setq package-check-signature nil)

(use-package org-ref
  :defer t
  :after org
  :init
  (setq reftex-default-bibliography '("~/Documents/Economics/Economics.bib"))
  (setq org-ref-default-bibliography '("~/Documents/Economics/Economics.bib"))
  (setq org-ref-pdf-directory '("~/Documents/Economics/files/"))

  (setq bibtex-completion-bibliography "~/Documents/Economics/Economics.bib"
        bibtex-completion-library-path "~/Documents/Economics/files/"
        ;; bibtex-completion-notes-path "~/Dropbox/bibliography/bibtex-notes"
        ))

;; (use-package org-roam
;;   :diminish org-roam-mode
;;   :after org
;;   :hook
;;   (org-mode . org-roam-mode)
;;   :custom
;;   (org-roam-directory (concat org-directory "/Roam"))
;;   :bind (:map org-roam-mode-map
;;               (("C-c n l" . org-roam)
;;                ("C-c n f" . org-roam-find-file)
;;                ("C-c n g" . org-roam-graph))
;;               :map org-mode-map

;;               (("C-c n i" . org-roam-insert))
;;               (("C-c n I" . org-roam-insert-immediate)))
;;   :config
;;   (setq org-roam-buffer-width 0.4)
;;   (setq org-roam-link-title-format "{{%s}}")
;;   (setq org-roam-templates
;;         '(("default" (:file org-roam--file-name-timestamp-title
;;                             :content "#+TITLE: ${title} \n")))))

;; download web pages to org
(use-package org-web-tools
  :bind (("s-o w" . org-web-tools-insert-web-page-as-entry)
         ("s-o u" . org-web-tools-insert-link-for-url)))

;; drag and drop images to org
(use-package org-download
  :bind ("s-o i" . org-download-image)
  :config
  (setq-default org-download-image-dir "~/Notes/Roam/images")
  :hook (dired-mode . org-download-enable))

(use-package org-journal
  :config
  (setq org-journal-dir "~/Notes/Agenda/"))

;; ----------------------------------------------------------------------
;; pdf-tools
;; ----------------------------------------------------------------------

(use-package pdf-tools
  :defer t
  :config
  (pdf-tools-install)
  (setq-default pdf-view-display-size 'fit-width)
  (define-key pdf-view-mode-map (kbd "C-s") 'isearch-forward)
  :custom
  (pdf-annot-activate-created-annotations t "automatically annotate highlights"))

(setq TeX-view-program-selection '((output-pdf "PDF Tools"))
      TeX-view-program-list '(("PDF Tools" TeX-pdf-tools-sync-view))
      TeX-source-correlate-start-server t)

(add-hook 'TeX-after-compilation-finished-functions
          #'TeX-revert-document-buffer)

;; ----------------------------------------------------------------------
;; latex
;; ----------------------------------------------------------------------

(defvar previewable-environments
  "List of environments that should be previewed."
  '("tabular" "tabular*" "tikzpicture" "..."))

(defadvice preview-region (around preview-at-point-no-long-pauses activate)
  "Preview all latex snippets when no snippet at point."
  (message "preview-region")
  (if (or (not (eq this-command 'preview-at-point))
          (TeX-active-mark)
          (texmathp)
          (member (LaTeX-current-environment) previewable-environments))
      ad-do-it
    (preview-section)
    )
  )

;; ----------------------------------------------------------------------
;; mu4e
;; ----------------------------------------------------------------------

;; (add-to-list 'load-path "/usr/share/emacs/site-lisp/mu4e")

;; (use-package smtpmail
;;   :init
;;   (setq message-send-mail-function 'smtpmail-send-it
;;         smtpmail-starttls-credentials
;;         '(("smtp.gmail.com" 587 nil nil))
;;         smtpmail-default-smtp-server "smtp.gmail.com"
;;         smtpmail-smtp-server "smtp.gmail.com"
;;         smtpmail-smtp-service 587
;;         smtpmail-debug-info t))

;; (use-package mu4e
;;   :config
;;   (progn
;;     (require 'shr)
;;     (require 'org-mu4e)
;;     (setq mu4e-maildir (expand-file-name "~/Maildir")
;;           mu4e-attachment-dir "~/Downloads"
;;           mu4e-compose-signature-auto-include nil

;;           mu4e-trash-folder "/home/[Gmail]/Trash"
;;           mu4e-refile-folder "/home/[Gmail]/Archive"
;;           mu4e-sent-folder "/home/[Gmail]/SentMail"

;;           mu4e-get-mail-command "mbsync -c ~/.mbsyncrc gmail"
;;           ;; mu4e-html2text-command "w3m -T text/html" ;; use default

;;           user-mail-address "edgar1denny@gmail.com"

;;           mu4e-maildir-shortcuts
;;           '(("/inbox" . ?i)
;;             ("/Drafts" . ?D)
;;             ("/SentMail" . ?s))

;;           mu4e-view-show-images t
;;           mu4e-update-interval 300
;;           mu4e-headers-visible-lines 30
;;           mu4e-headers-auto-update t
;;           mu4e-view-show-addresses t
;;           mu4e-view-show-images t
;;           mu4e-view-prefer-html t
;;           mu4e-headers-skip-duplicates t
;;           mu4e-compose-signature-auto-include nil
;;           mu4e-sent-messages-behavior 'delete)

;;     (setq mu4e-completing-read-function 'completing-read)

;;     ;; Don't ask to quit
;;     (setq mu4e-confirm-quit nil)

;;     (when (fboundp 'imagemagick-register-types)
;;       (imagemagick-register-types))

;;     (setq mu4e-headers-fields
;;           `((:date .  25)
;;             (:flags .  6)
;;             (:from-or-to . 22)
;;             (:subject . 35)
;;             (:size . 7))
;;           mu4e-headers-from-or-to-prefix nil)

;;     ;; view in Firefox with 'aV'
;;     (add-to-list 'mu4e-view-actions
;;                  '("ViewInBrowser" . mu4e-action-view-in-browser) t)

;;     (add-hook 'mu4e-view-mode-hook #'visual-line-mode)
;;     (add-hook 'mu4e-compose-mode-hook
;;               (lambda ()
;;                 (set-fill-column 76)
;;                 (flyspell-mode)))))

;; ----------------------------------------------------------------------
;; multiple cursors
;; ----------------------------------------------------------------------

(use-package multiple-cursors
  :bind (("s-c e" . mc/edit-lines)
         ("s-c a" . mc/mark-all-like-this)
         ("s-c n" . mc/mark-next-like-this)
         ("s-c p" . mc/mark-previous-like-this)
         ("s-c N" . mc/unmark-next-like-this)
         ("s-c P" . mc/unmark-previous-like-this)
         ("s-c s" . mc/skip-to-next-like-this)
         ("s-c S" . mc/skip-to-previous-like-this)
         ("s-c h" . mc-hide-unmatched-lines-mode)))

;; ----------------------------------------------------------------------
;; recentf
;; ----------------------------------------------------------------------

(use-package recentf
  :custom
  (recentf-max-saved-items 50)
  (recentf-max-menu-items 50)
  (recentf-exclude '("^/var/folders\\.*"
                     "COMMIT_EDITMSG\\'"
                     "/\\.git/.*\\'"
                     ".*-autoloads\\.el\\'"
                     "[/\\]\\.elpa/"))
  :config
  (recentf-mode 1))

;; ----------------------------------------------------------------------
;; savehist
;; ----------------------------------------------------------------------

(use-package savehist
  :init
  (progn
    (setq savehist-file "~/.emacs.d/savehist")
    (setq savehist-save-minibuffer-history 1)
    (setq savehist-additional-variables
          '(kill-ring
            search-ring
            regexp-search-ring))
    (savehist-mode 1)))

;; ----------------------------------------------------------------------
;; flyspell
;; ----------------------------------------------------------------------

(use-package flyspell
  :commands (flyspell-auto-correct-previous-word flyspell-correct-word-generic)
  :init
  (setq flyspell-use-meta-tab nil)
  :custom
  (flyspell-abbrev-p t)
  (flyspell-use-global-abbrev-table-p t)
  (flyspell-issue-message-flag nil)
  (flyspell-issue-welcome-flag nil)
  :config
  ;; Use mouse
  (define-key flyspell-mouse-map [down-mouse-3] #'flyspell-correct-word)
  (define-key flyspell-mouse-map [mouse-3] #'undefined))

(add-hook 'flyspell-mode-hook 'flyspell-buffer) ; show misspelled

;; ----------------------------------------------------------------------
;; theme
;; ----------------------------------------------------------------------

(use-package rainbow-mode
  :config
  (rainbow-mode 1))

;; (use-package modus-themes
;;   :init
;;   (setq modus-themes-bold-constructs t)
;;   (setq modus-themes-slanted-constructs t)
;;   (setq modus-themes-subtle-line-numbers t)
;;   (setq modus-themes-lang-checkers 'straight-underline)
;;   (setq modus-themes-fringes nil)
;;   (setq modus-themes-completions 'moderate)
;;   (setq modus-themes-org-blocks 'gray-background)
;;   (setq modus-themes-mode-line '(1 accented borderless))
;;   (setq modus-themes-prompts 'subtle)
;;   (setq modus-themes-syntax 'alt-syntax-yellow-comments)
;;   (modus-themes-load-themes)
;;   :config
;;   (setq modus-themes-vivendi-color-overrides
;;         '((bg-main . "gray10")
;;           (bg-hl-line . "gray20")
;;           (bg-hl-alt . "gray20")
;;           ))
;;   (modus-themes-load-vivendi))

;; ----------------------------------------------------------------------
;; treemacs
;; ----------------------------------------------------------------------

(use-package treemacs
  :commands (treemacs-follow-mode
             treemacs-filewatch-mode
             treemacs-fringe-indicator-mode
             treemacs-git-mode)
  :bind ("s-d t" . treemacs)
  :config
  (setq treemacs-collapse-dirs (if treemacs-python-executable 3 0)
        treemacs-sorting 'alphabetic-case-insensitive-desc
        treemacs-follow-after-init t
        treemacs-is-never-other-window t
        treemacs-silent-filewatch t
        treemacs-silent-refresh t
        treemacs-width 40)
  (treemacs-follow-mode t)
  (treemacs-filewatch-mode t))

(use-package treemacs-magit
  :after treemacs magit)

;; ----------------------------------------------------------------------
;; vterm
;; ----------------------------------------------------------------------

(use-package vterm
  ;; prevent hl-line in vterm
  :hook (vterm-mode . (lambda () (setq-local global-hl-line-mode nil))))

;; ----------------------------------------------------------------------
;; which key
;; ----------------------------------------------------------------------

(use-package which-key
  :diminish which-key-mode
  ;; :custom
  ;; (which-key-setup-side-window-bottom)
  :config
  (setq which-key-max-display-columns nil
        which-key-min-display-lines 5
        which-key-sort-order #'which-key-prefix-then-key-order
        which-key-popup-type 'side-window
        which-key-add-column-padding 1)
  (which-key-mode +1))

(use-package free-keys
  :bind ("C-~" . free-keys))

;; ----------------------------------------------------------------------
;; window management
;; ----------------------------------------------------------------------

(use-package winum
  :init
  (setq-default winum-keymap nil)
  :config
  (winum-mode))

(use-package ace-window)

(use-package windmove
  :bind (("C-s-l" . windmove-right)
         ("C-s-k" . windmove-up)
         ("C-s-j" . windmove-down)
         ("C-s-h" . windmove-left))
  :config
  (windmove-default-keybindings))

;; (use-package dimmer
;;   :config
;;   (setq dimmer-fraction 0.15)
;;   (setq dimmer-adjustment-mode :both)
;;   (dimmer-mode 1))


;; move a buffer to another window in a specified direction
(use-package buffer-move
  :bind (("M-s-k" . buf-move-up)
         ("M-s-j" . buf-move-down)
         ("M-s-h" . buf-move-left)
         ("M-s-l" . buf-move-right)))

;; undo a change to a window configuration
(use-package winner
  :bind (("s-w u" .  winner-undo)
         ("s-w r" .  winner-redo))
  :init
  (winner-mode 1))

;; ----------------------------------------------------------------------
;; snippets
;; ----------------------------------------------------------------------

(use-package yasnippet
  :defer
  :diminish yas-minor-mode
  :config
  (add-to-list 'yas-snippet-dirs "~/.emacs.d/yasnippet-snippets")
  (add-to-list 'yas-snippet-dirs "~/.emacs.d/snippets")
  (yas-global-mode))

(use-package yasnippet-snippets
  :defer
  )

;; ----------------------------------------------------------------------
;; my commands
;; ----------------------------------------------------------------------

(use-package emacs
  :ensure nil
  :config
  (defun my/load-only-theme ()
    "Disable all themes and then load a single theme interactively."
    (interactive)
    (while custom-enabled-themes
      (disable-theme (car custom-enabled-themes)))
    (call-interactively 'load-theme))

  (defun my/shell-command (command)
    "Execute shell COMMAND from the minibuffer."
    (interactive (list (read-shell-command "$ ")))
    (start-process-shell-command command nil command))

  (defun my/insert-new-line ()
    (interactive)
    (move-end-of-line nil)
    (newline-and-indent))

  (defun my/insert-new-line-yank ()
    (interactive)
    (move-end-of-line nil)
    (newline)
    (yank))

  (defun my/next-begin-sexp ()
    (interactive)
    (forward-char 1)
    (search-forward "(" nil t)
    (backward-char 1))

  (defun my/prev-begin-sexp ()
    (interactive)
    (search-backward "(" nil t))

  (defun my/copy-line ()
    (interactive)
    (let ((beg (line-beginning-position))
          (end (line-end-position)))
      (copy-region-as-kill beg end)))

  (defun my/mark-sexp ()
    (interactive)
    (when (and mark-active (looking-at-p "(.*"))
      (backward-up-list))
    (unless (looking-at-p "(.*")
      (my/prev-begin-sexp))
    (mark-sexp))

  (defun my/kill-sexp ()
    (interactive)
    (unless (looking-at-p "(.*")
      (my/prev-begin-sexp))
    (kill-sexp))

  (defun my/backward-symbol ()
    (interactive)
    (forward-symbol -1))

  (defun my/get-positions-of-line-or-region ()
    (let (beg end)
      (if (and mark-active (> (point) (mark)))
          (exchange-point-and-mark))
      (setq beg (line-beginning-position))
      (if mark-active
          (exchange-point-and-mark))
      (setq end (line-end-position))
      (cons beg end)))

  (defun my/html-to-org ()
    (interactive)
    (require 'org-web-tools)
    (let* ((html (gui-get-selection 'CLIPBOARD))
           (txt (org-web-tools--html-to-org-with-pandoc html)))
      (org-paste-subtree (1+ (org-outline-level))
                         (with-temp-buffer
                           (org-mode)
                           (insert txt)
                           (insert "hello")))))
  :bind (("s-, c" . my/shell-command)
         ("s-, o" . my/insert-new-line)
         ("s-, p" . my/insert-new-line-yank)
         ("s-, l" . my/next-begin-sexp)
         ("s-, h" . my/prev-begin-sexp)
         ("s-, y" . my/copy-line)
         ("s-, m" . my/mark-sexp)
         ("s-, k" . my/kill-sexp)))

;; ----------------------------------------------------------------------
;; hydras
;; ----------------------------------------------------------------------

(with-eval-after-load 'hydra
  (defhydra hydra-spelling (:color blue)
    "
  ^Spelling^        ^Errors^            ^Checker^
  ^────────^────────^──────^────────────^───────^───────
  [_q_] quit        [_<_] previous      [_c_] correction
  ^^                [_>_] next          [_d_] dictionary
  ^^                [_f_] check         [_m_] mode
  "
    ("q" nil)
    ("<" flyspell-correct-previous :color pink)
    (">" flyspell-correct-next :color pink)
    ("c" ispell)
    ("d" ispell-change-dictionary)
    ("f" flyspell-buffer :color pink)
    ("m" flyspell-mode))

  (defhydra hydra-info (:hint nil)
    "
    Info-mode:
    [_j_] forward    [_l_] last      [_u_] up          [_f_] follow reference  [_T_] TOC
    [_k_] backward   [_r_] return    [_m_] menu        [_i_] index             [_d_] directory
    [_n_] nex        [_H_] history   [_g_] goto        [_,_] next index item   [_c_] copy node name
    [_p_] prev       [_<_] top       [_b_] beginning   [_I_] virtual index     [_C_] clone buffer
    [_s_] search     [_>_] final     [_e_] end         ^^                      [_a_] apropos

    [_1_] .. [_9_] Pick first .. ninth item in the node's menu.
  "

    ("j"   Info-forward-node)
    ("k"   Info-backward-node)
    ("n"   Info-next)
    ("p"   Info-prev)
    ("s"   Info-search)
    ("S"   Info-search-case-sensitively)

    ("l"   Info-history-back)
    ("r"   Info-history-forward)
    ("H"   Info-history)
    ("t"   Info-top-node)
    ("<"   Info-top-node)
    (">"   Info-final-node)

    ("u"   Info-up)
    ("^"   Info-up)
    ("m"   Info-menu)
    ("g"   Info-goto-node)
    ("b"   beginning-of-buffer)
    ("e"   end-of-buffer)

    ("f"   Info-follow-reference)
    ("i"   Info-index)
    (","   Info-index-next)
    ("I"   Info-virtual-index)

    ("T"   Info-toc)
    ("d"   Info-directory)
    ("c"   Info-copy-current-node-name)
    ("C"   clone-buffer)
    ("a"   info-apropos)

    ("1"   Info-nth-menu-item)
    ("2"   Info-nth-menu-item)
    ("3"   Info-nth-menu-item)
    ("4"   Info-nth-menu-item)
    ("5"   Info-nth-menu-item)
    ("6"   Info-nth-menu-item)
    ("7"   Info-nth-menu-item)
    ("8"   Info-nth-menu-item)
    ("9"   Info-nth-menu-item)

    ("?"   Info-summary "Info summary")
    ("h"   Info-help "Info help")
    ("q"   Info-exit "Info exit")
    ("." nil "cancel" :color blue))

  (define-key Info-mode-map "." 'hydra-info/body)

  (defhydra hydra-next-error
    (global-map "C-x")
    "
  Compilation errors:
  _j_: next error        _h_: first error    _q_uit
  _k_: previous error    _l_: last error
  "
    ("`" next-error     nil)
    ("j" next-error     nil :bind nil)
    ("k" previous-error nil :bind nil)
    ("h" first-error    nil :bind nil)
    ("l" (condition-case err
             (while t
               (next-error))
           (user-error nil))
     nil :bind nil)
    ("q" nil            nil :color blue))
  )

;; ----------------------------------------------------------------------
;; bookmark
;; ----------------------------------------------------------------------

(use-package bookmark
  :bind (("s-m s" . bookmark-set)
         ("s-m d" . bookmark-delete)))

;; ----------------------------------------------------------------------
;; window
;; ----------------------------------------------------------------------

(use-package window
  :ensure nil
  :bind (("s-w v" . split-window)
         ("s-w b" . split-window-below)
         ("s-w +" . enlarge-window)
         ("s-w ." . enlarge-window-horizontally)
         ("s-w ," . shrink-window-horizontally)
         ("s-w =" . balance-windows)
         ("s-w d" . delete-window)
         ("s-w z" . delete-other-windows)
         ("s-w o" . other-window)
         ("s-b p" . previous-buffer)
         ("s-b n" . next-buffer)))

(use-package ace-window
  :bind ("s-w w" . ace-window))

(use-package ibuffer
  :bind ("s-b i" . ibuffer))

;; ----------------------------------------------------------------------
;; files
;; ----------------------------------------------------------------------

(use-package files
  :ensure nil
  :bind (("s-f s" . save-buffer)
         ("s-f f" . find-file)
         ("s-f w" . write-file)))

;; ----------------------------------------------------------------------
;; lisp
;; ----------------------------------------------------------------------

(use-package lisp
  :ensure nil
  :bind (("s-e f" . mark-defun)
         ("s-e s" . mark-sexp)))

(use-package ielm
  :bind ("s-e i" . ielm))

(use-package elisp-mode
  :ensure nil
  :bind (("s-e e" . eval-last-sexp)
         ("s-e n" . eval-defun)))

(use-package edebug
  :bind ("s-e d" .  edebug-defun))

;; ----------------------------------------------------------------------
;; project
;; ----------------------------------------------------------------------

(use-package project
  :bind (("s-p s" . project-switch-project)
         ("s-p b" . project-swtch-to-buffer)
         ("s-p d" . project-dired)
         ("s-p c" . project-compile)
         ("s-p e" . project-eshell)
         ("s-p k" . project-kill-buffers)
         ("s-p f" . project-find-file)))

;; ----------------------------------------------------------------------
;; flymake
;; ----------------------------------------------------------------------

(use-package flymake
  :bind (("s-k c" . display-local-help)
         ("s-k e" . flymake-show-buffer-diagnostics)
         ("s-k m" . flymake-menu)
         ("s-k n" . flymake-goto-next-error)
         ("s-k p" . flymake-goto-previous-error)))

(put 'downcase-region 'disabled nil)
(put 'dired-find-alternate-file 'disabled nil)

(provide 'init)
;;; init.el ends here
