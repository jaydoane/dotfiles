;;; .emacs --- Initialization file for Emacs -*- lexical-binding: t; -*-
;; -*- mode: emacs-lisp -*-

;;; Commentary:
;;
;; This file contains initialization configurations for my own custom
;; Emacs installation.

;;; Code:

(require 'package)

;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(package-initialize)

;; Install use-package if not already installed
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(require 'use-package)

;; Enable defer and ensure by default for use-package
;; Keep auto-save/backup files separate from source code:  https://github.com/scalameta/metals/issues/1027
(setq use-package-always-defer t
      use-package-always-ensure t
      backup-directory-alist `((".*" . ,temporary-file-directory))
      auto-save-file-name-transforms `((".*" ,temporary-file-directory t)))

;; Enable scala-mode for highlighting, indentation and motion commands
(use-package scala-mode
  :interpreter ("scala" . scala-mode))

;; Enable sbt mode for executing sbt commands
(use-package sbt-mode
  :commands sbt-start sbt-command
  :config
  ;; WORKAROUND: https://github.com/ensime/emacs-sbt-mode/issues/31
  ;; allows using SPACE when in the minibuffer
  (substitute-key-definition
   'minibuffer-complete-word
   'self-insert-command
   minibuffer-local-completion-map)
   ;; sbt-supershell kills sbt-mode:  https://github.com/hvesalai/emacs-sbt-mode/issues/152
   (setq sbt:program-options '("-Dsbt.supershell=false")))

;; Enable nice rendering of diagnostics like compile errors.
(use-package flycheck
  :init (global-flycheck-mode))


;; Define a utility function which either installs a package (if it is
;; missing) or requires it (if it already installed).
(defun package-require (pkg &optional require-name)
  "Install PKG only if it's not already installed.
If REQUIRE-NAME is set, require it if already installed."
  (when (not (package-installed-p pkg))
    (package-install pkg))
  (if require-name
      (require require-name)
    (require pkg)))

(setq user-full-name "Jay Doane")
(setq user-mail-address "jay.s.doane@gmail.com")


(defun maybe-add-to-load-path (path)
  "Add PATH to `load-path` if it exists."
  (if (file-accessible-directory-p path)
      (add-to-list 'load-path path)))

;; https://github.com/purcell/exec-path-from-shell
(when (memq window-system '(mac ns x))
  (exec-path-from-shell-initialize))

(add-to-list 'exec-path "/opt/homebrew/bin")
(add-to-list 'exec-path "/Users/jay/bin")
(add-to-list 'exec-path "/Users/jay/repos/ziose/bin")

(load-theme 'deeper-blue t)

(global-hl-line-mode t)
(set-face-background 'hl-line "#333")

(global-set-key (kbd "C-c C-SPC") 'comment-region)
(global-set-key (kbd "C-c C-u") 'uncomment-region)

;; (defun buffer-menu-custom-font-lock  ()
;;   (let ((font-lock-unfontify-region-function
;;          (lambda (start end)
;;            (remove-text-properties start end '(font-lock-face nil)))))
;;     (font-lock-unfontify-buffer)
;;     (set (make-local-variable 'font-lock-defaults)
;;          '(buffer-menu-buffer-font-lock-keywords t))
;;     (font-lock-fontify-buffer)))

;; (add-hook 'buffer-menu-mode-hook 'buffer-menu-custom-font-lock)
;; (add-hook 'electric-buffer-menu-mode-hook 'buffer-menu-custom-font-lock)

;; http://stackoverflow.com/questions/3145332/emacs-help-me-understand-file-buffer-management/3145824#3145824
(define-key ctl-x-map "\^b" 'ibuffer)

(global-set-key (kbd "C-x g") 'magit-status)

;; fullscreen
;(global-set-key (kbd "M-0") 'ns-toggle-fullscreen)

;; window splitting shortcuts
;(global-set-key (kbd "M-2") 'split-window-horizontally) ; was digit-argument
;(global-set-key (kbd "M-1") 'delete-other-windows) ; was digit-argument
;(global-set-key (kbd "M-s") 'other-window) ; was center-line

;; Set up the keyboard so the delete key on both the regular keyboard
;; and the keypad delete the character under the cursor and to the right
;; under X, instead of the default, backspace behavior.
(global-set-key [delete] 'backward-delete-char)
(global-set-key [kp-delete] 'backward-delete-char)

(setq column-number-mode t)

;(add-hook 'text-mode-hook 'turn-on-visual-line-mode)

(setq require-final-newline 'ask) ;(setq require-final-newline nil)

;; stop at the end of the file, not just add lines
(setq next-line-add-newlines nil)

;(setq inhibit-startup-message t)
(setq make-backup-files nil)
(setq visible-bell t)
(setq initial-scratch-message nil)

(put 'font-lock-mode 'disabled nil)
(define-key esc-map "g" 'goto-line)

;(smart-frame-positioning-mode nil)
;;; Resize Emacs frame on startup, and place at top-left of screen.
;;; Height for MacBook Pro 15" screen
(setq initial-frame-alist `((left . 0) (top . 0) (width . 205) (height . 54)))

;(desktop-load-default)
;(desktop-read)
(if (fboundp 'desktop-save-mode) (desktop-save-mode 1))

;; dired

(add-hook 'dired-mode-hook 'dired-hide-details-mode)
(add-hook 'dired-mode-hook 'treemacs-icons-dired-mode)

; suppress ls does not support --dired; see ‘dired-use-ls-dired’ for more details.
(setq-default ls-lisp-use-insert-directory-program nil)

(setq insert-directory-program "gls")

(require 'dired-x)
(setq dired-recursive-deletes t)
(setq dired-ls-F-marks-symlinks nil)
(setq dired-dwim-target t)
(put 'dired-find-alternate-file 'disabled nil)
;(setq dired-listing-switches "-ahlF")
(setq dired-listing-switches "-ahl")
;; The below fails to correctly dired-sort-toggle-or-edit when using `gls`
;; (if (executable-find "gls") ; from brew install coreutils
;;     (progn
;;       (setq insert-directory-program "gls")
;;       (setq dired-listing-switches "-lFaGh1v"))
;;   (setq dired-listing-switches "-ahlF"))

;; (use-package dirvish
;;   :ensure t
;;   :init
;;   ;; Let Dirvish take over Dired globally
;;   (dirvish-override-dired-mode))

(use-package dired-subtree
  :ensure t
  :after dired
  :bind (:map dired-mode-map
              ("i" . dired-subtree-insert)
              (";" . dired-subtree-remove)
              ("M-o" . dired-find-file-other-window)
              ("M-<up>" . dired-subtree-up)
              ("M-<down>" . dired-subtree-down)
              ("<tab>" . dired-subtree-toggle)
              ("<backtab>" . dired-subtree-cycle))) ; S-TAB

;(require 'mise)
;(add-hook 'after-init-hook #'global-mise-mode)

(add-to-list 'load-path "~/repos/asdf.el")
(require 'asdf "~/repos/asdf.el/asdf.el")
(asdf-enable) ;; This ensures Emacs has the correct paths to asdf shims and bin

(use-package direnv
 :config
 (direnv-mode))

;; json
(defun beautify-json (start end)
  "Format JSON in region from START to END using python json.tool."
  (interactive "*r")
  (shell-command-on-region start end "python -mjson.tool" (current-buffer) t))

;; (add-to-list 'auto-mode-alist '("\\.erb\\'" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\.log\\'" . auto-revert-tail-mode))
;(add-to-list 'auto-mode-alist '("\\.log\\'" . log-view-mode))
;; (add-to-list 'auto-mode-alist '("\\.sc\\'" . scala-mode))

(setq-default indent-tabs-mode nil)
;(setq default-tab-width 4)

(add-hook 'c++-mode-hook (lambda () (setq-default c-basic-offset 4)))
(add-hook 'js-mode-hook (lambda () (setq-default js-indent-level 2)))
(add-hook 'javascript-mode-hook (lambda () (setq-default js-indent-level 2)))
(put 'downcase-region 'disabled nil)
(put 'upcase-region 'disabled nil)

(if (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(scroll-bar-mode -1)

(mouse-wheel-mode t)
(setq mouse-wheel-scroll-amount '(1 ((shift) . 1))) ; one line at a time
(setq mouse-wheel-progressive-speed nil) ; don't accelerate scrolling
(setq scroll-step 1) ;; keyboard scroll one line at a time

(setq select-enable-clipboard t)

(require 'uniquify)
(setq uniquify-buffer-name-style 'forward)


;; python
(require 'python)

(setq-default python-indent 4)

;; activate minor whitespace mode when in python mode
(add-hook 'python-mode-hook 'whitespace-mode)

;; smart word boundaries
(add-hook 'python-mode-hook (lambda () (subword-mode 1)))

;; bind RET to py-newline-and-indent
(add-hook 'python-mode-hook
          (lambda () (define-key python-mode-map "\C-m" 'newline-and-indent)))


(defun make-project (cmd)
  "Traveling up the path, find a Makefile and run CMD."
  (interactive (list (read-string "make command: " "make -k")))
  (let ((make-dir (locate-dominating-file default-directory "Makefile")))
    (when make-dir
      (with-temp-buffer
        (cd make-dir)
        (compile cmd)))))

;; (defun reverse-string (s)
;;   "Return reverse of S."
;;   (coerce (reverse (loop for c across s collect c)) 'string))

;; (defun file-dir (file-name)
;;   "Return FILE-NAME's directory, eg, (file-dir (buffer-file-name))."
;;   (reverse-string (substring (reverse-string file-name)
;;                              (+ 1 (string-match "/" (reverse-string file-name))))))
(defun file-dir (file-name)
  "Return FILE-NAME's directory, eg, (file-dir (buffer-file-name))."
  (reverse (substring (reverse file-name)
                             (+ 1 (string-match "/" (reverse file-name))))))

(defun my-dired-find-file-other-window ()
  "Open file under point in other window."
  (interactive)
  (find-file-other-window
   (concat
    (dired-current-directory)
    (thing-at-point 'filename 'no-properties))))

;; (defun python-insert-sysmodules ()
;;   "Insert directory of current buffer's file into sys.modules in *Python* sys.path"
;;   (interactive)
;;   (python-send-string (format "import sys; sys.path.insert(0, '%s'); print(sys.path[0])"
;;                               (file-dir(buffer-file-name)))))

;; (define-key esc-map "s" 'python-insert-sysmodules)
;; (define-key python-mode-map (kbd "<f5>") 'python-switch-to-python)
;; (define-key python-mode-map (kbd "C-c p") 'python-switch-to-python)

;; (defadvice python-send-buffer (before advice-send-dunder-file activate)
;;   "Set the __file__ variable prior to sending current python buffer"
;;   (python-send-string (format "__file__ = '%s'" buffer-file-name)))


;; multi-mode-mode, for html/css/javascript
;; (if (file-accessible-directory-p "~/.emacs.d/pkg/mmm-mode")
;;     (add-to-list 'load-path "~/.emacs.d/pkg/mmm-mode"))
;; (when (file-readable-p "~/.emacs.d/pkg/mmm-mako.el")
;;   (load "~/.emacs.d/pkg/mmm-mako.el")
;;   (add-to-list 'auto-mode-alist '("\\.mako\\'" . html-mode))
;;   (mmm-add-mode-ext-class 'html-mode "\\.mako\\'" 'mako))

(setq word-wrap-by-category t)
;; Add the | (= line-breakable) category to the - char.
(modify-category-entry ?- ?| (standard-category-table))

;; org
;; (add-to-list 'auto-mode-alist '("\\.org$" . org-mode))
(define-key global-map "\C-cl" 'org-store-link)
(define-key global-map "\C-ca" 'org-agenda)
(setq-default org-log-done t)
(setq-default org-startup-indented t)
;(add-hook 'org-mode-hook '(lambda () (flyspell-mode 1)))
(add-hook 'org-mode-hook
          (lambda ()
            (local-set-key (kbd "C-c C-1") 'org-time-stamp-inactive)
            (local-set-key "\C-\M-c" 'org-table-copy-down)
            (local-unset-key (kbd "C-c C-b"))))

(require 'org-superstar)
(add-hook 'org-mode-hook (lambda () (org-superstar-mode 1)))

(add-hook 'text-mode-hook 'turn-on-visual-line-mode)
(add-hook 'text-mode-hook (lambda () (flyspell-mode 1)))


(defun my-save-word ()
  "Save current word to `~/.ispell_english` dictionary."
  (interactive)
  (let ((current-location (point))
         (word (flyspell-get-word)))
    (when (consp word)
      (flyspell-do-correct 'save nil (car word) current-location (cadr word) (caddr word) current-location))))


(defun copy-char-above-deepseek ()
  "Copy the character above point into the buffer."
  (interactive)
  (let* ((current-point (point))
         (current-line-number (line-number-at-pos)))
    (if (= current-line-number 1)
        (message "Cannot move up from first line.")
        (progn
          (previous-line) ;; Move to previous line
          (let* ((col (current-column))
                 (pos-in-prev-line (point)))
            (move-to-column col)
            (let ((char-to-copy (if (= pos-in-prev-line (line-end-position))
                                      nil
                                    (char-after))))
              (goto-char current-point)
              (if char-to-copy
                  (insert-char char-to-copy)
                (message "End of line reached; no character to copy."))))))))

;; http://justinhj.github.io/2008/05/01/copying-characters-from-line-above-in.html
(defun copy-char-above()
 "Copy the character above point into the buffer."
 (interactive)
 (let (c)
   (save-excursion
     (previous-line)
     ;; (forward-line -1)
     (setq c (char-after)))
   (delete-char 1)
   (insert (char-to-string c))
   (backward-char)
   (next-line)
   ;; (forward-line)
))
(global-set-key [f6] 'copy-char-above)

;; markdown -- http://jblevins.org/projects/markdown-mode/
(autoload 'markdown-mode "markdown-mode.el"
   "Major mode for editing Markdown files" t)
(add-to-list 'auto-mode-alist '("\\.md$" . markdown-mode))

;; elixir
(add-hook 'elixir-mode-hook
          (lambda ()
            (setq-local whitespace-line-column 90)))

(let ((emacs-dir "~/repos/otp/lib/tools/emacs/"))
  (when (file-accessible-directory-p emacs-dir)
    (add-to-list 'load-path emacs-dir)
    (require 'erlang-start)
    (setq-default erlang-indent-level 4)
    (setq-default erlang-indent-guard 4)
    (setq-default erlang-argument-indent 4)
    (add-to-list 'auto-mode-alist '("\\.app\\'" . erlang-mode))
    (add-to-list 'auto-mode-alist '("\\.app.src\\'" . erlang-mode))))


(use-package eglot
  :ensure t
  :defer t
  :hook ((go-mode . eglot-ensure)
         (js-mode . eglot-ensure)
         (python-mode . eglot-ensure))
  :config
  (add-to-list 'eglot-server-programs
               `(python-mode
                 . ,(eglot-alternatives '("jedi-language-server"
                                          "pylsp")))))
;; (use-package python-black
;;   :ensure t
;;   :demand t
;;   :after python
;;   :hook ((python-mode . python-black-on-save-mode)))


;; LSP
;; Performance tweaks for LSP
(setq gc-cons-threshold 100000000)
(setq read-process-output-max (* 1024 1024))
(setq-default lsp-idle-delay 0.500)

;(setq lsp-keymap-prefix "C-l")
(package-require 'lsp-mode)
;(add-hook 'erlang-mode-hook #'lsp)

(use-package lsp-mode
  :hook ((c-mode          ; clangd
          c++-mode        ; clangd
          c-or-c++-mode   ; clangd
          erlang-mode
          java-mode       ; eclipse-jdtls
          web-mode        ; ts-ls/HTML/CSS
          haskell-mode    ; haskell-language-server
          scala-mode      ; metals
          ) . lsp-deferred)
  (lsp-mode . lsp-lens-mode)
  :commands lsp
  :config
  ;; ;; Enable LSP automatically for Erlang files
  ;; (add-hook 'erlang-mode-hook #'lsp)
  ;; ;; ELP, added as priority 0 (> -1) so takes priority over the built-in one
  ;; (lsp-register-client
  ;;  (make-lsp-client :new-connection (lsp-stdio-connection '("elp" "server"))
  ;;                   :major-modes '(erlang-mode)
  ;;                   :priority 0
  ;;                   :server-id 'erlang-language-platform))

  ;; Uncomment following section if you would like to tune lsp-mode performance according to
  ;; https://emacs-lsp.github.io/lsp-mode/page/performance/
  ;; (setq gc-cons-threshold 100000000) ;; 100mb
  ;; (setq read-process-output-max (* 1024 1024)) ;; 1mb
  ;; (setq lsp-idle-delay 0.500)
  ;; (setq lsp-log-io nil)
  ;; (setq lsp-completion-provider :capf)
  (setq lsp-prefer-flymake nil)
  ;; Makes LSP shutdown the metals server when all buffers in the project are closed.
  ;; https://emacs-lsp.github.io/lsp-mode/page/settings/mode/#lsp-keep-workspace-alive
  (setq lsp-keep-workspace-alive nil)

  (add-to-list 'lsp-file-watch-ignored-directories "[\////]ebin\\'")
  (add-to-list 'lsp-file-watch-ignored-directories "[\////]\\.eunit\\'")
  (add-to-list 'lsp-file-watch-ignored-directories "[\////]\\.rebar\\'")
  (add-to-list 'lsp-file-watch-ignored-directories "[\////]\\.git\\'")
  (add-to-list 'lsp-file-watch-ignored-directories "[\////]dev\\'")
  (add-to-list 'lsp-file-watch-ignored-directories "[\////]__pycache__\\'")
  (add-to-list 'lsp-file-watch-ignored-directories "[\////]_build\\'")
  (add-to-list 'lsp-file-watch-ignored-directories "[\////]venv\\'")
  (add-to-list 'lsp-file-watch-ignored-directories "[\////]tmp\\'")
  (add-to-list 'lsp-file-watch-ignored-directories "[\////]shards\\'")
  (setq lsp-file-watch-threshold 2000)
  ;; (setq lsp-auto-guess-root t)
  (setq lsp-log-io nil)
  ;; (setq lsp-restart 'auto-restart)
  (setq lsp-enable-symbol-highlighting nil)
  (setq lsp-enable-on-type-formatting nil)
  ;; (setq lsp-signature-auto-activate nil)
  ;; (setq lsp-signature-render-documentation nil)
  ;; (setq lsp-eldoc-hook nil)
  ;; (setq lsp-modeline-code-actions-enable nil)
  ;; (setq lsp-modeline-diagnostics-enable nil)
  ;; (setq lsp-headerline-breadcrumb-enable nil)
  (setq lsp-semantic-tokens-enable nil)
  (setq lsp-enable-folding nil)
  ;; (setq lsp-enable-imenu nil)
  (setq lsp-headerline-breadcrumb-enable nil)
  (setq lsp-enable-snippet nil)
  (setq lsp-lens-enable nil)

  (setq read-process-output-max (* 1024 1024)) ;; 1MB
  (setq lsp-idle-delay 0.5))

;; Add metals backend for lsp-mode
(use-package lsp-metals)

;; Enable nice rendering of documentation on hover
;;   Warning: on some systems this package can reduce your emacs
;;   responsiveness significally.  (See: https://emacs-
;;   lsp.github.io/lsp-mode/page/performance/) In that case you have
;;   to not only disable this but also remove from the packages since
;;   lsp-mode can activate it automatically.
(use-package lsp-ui)

;; lsp-mode supports snippets, but in order for them to work you need
;; to use yasnippet If you don't want to use snippets set lsp-enable-
;; snippet to nil in your lsp-mode settings to avoid odd behavior with
;; snippets and indentation
(use-package yasnippet
  :config
  (yas-global-mode 1))

;; Use company-capf as a completion provider.
;;
;; To Company-lsp users:
;;   Company-lsp is no longer maintained and has been removed from MELPA.
;;   Please migrate to company-capf.
(use-package company
  :hook (scala-mode . company-mode)
  :config
  (setq lsp-completion-provider :capf))

;; Posframe is a pop-up tool that must be manually installed for dap-mode
(use-package posframe)

;; Use the Debug Adapter Protocol for running tests and debugging
(use-package dap-mode
  :hook
  (lsp-mode . dap-mode)
  (lsp-mode . dap-ui-mode))

;; (use-package lsp-pyright
;;   :hook (python-mode . (lambda () (require 'lsp-pyright)))
;;   :init (when (executable-find "python3")
;;           (setq lsp-pyright-python-executable-cmd "python3")))

;; Debugging with LSP
(require 'dap-mode)
(require 'dap-erlang)

(add-to-list 'display-buffer-alist
             `(,(rx bos "*Flycheck errors*" eos)
              (display-buffer-reuse-window
               display-buffer-in-side-window)
              (side            . bottom)
              (reusable-frames . visible)
              (window-height   . 0.25)))


(let ((dir "~/repos/nitrogen/support/nitrogen-mode"))
  (when (file-accessible-directory-p dir)
    (add-to-list 'load-path dir)
    (require 'nitrogen-mode)
    ;; (add-to-list 'auto-mode-alist '("\\.config\\'" . nitrogen-mode))
    ;; (add-to-list 'auto-mode-alist '("\\.erl\\'" . nitrogen-mode))
    ;; (add-to-list 'auto-mode-alist '("\\.hrl\\'" . nitrogen-mode))
    ))


;; http://stackoverflow.com/questions/730751/hiding-m-in-emacs
(defun hide-dos-eol ()
  "Do not show ^M in files containing mixed UNIX and DOS line endings."
  (interactive)
  (setq buffer-display-table (make-display-table))
  (aset buffer-display-table ?\^M []))
(add-hook 'log-view-mode-hook 'hide-dos-eol)
(add-hook 'log-view-mode-hook
          (lambda ()
            (setq-local whitespace-line-column 800)))

(add-to-list 'auto-mode-alist '("\\.[0-9]+\\'" . log-view-mode))


;; multi-term
(autoload 'multi-term "multi-term" nil t)
(autoload 'multi-term-next "multi-term" nil t)
(setq-default multi-term-program "/bin/bash")
(global-set-key (kbd "C-c C-n") 'multi-term-next)
(global-set-key (kbd "C-c N") 'multi-term) ;; create a new one
(global-set-key (kbd "C-c C-j") 'term-line-mode)

(require 'completion)
(dynamic-completion-mode)
(global-set-key (kbd "M-\\") 'complete)

(fset 'dup-line
   (lambda (&optional arg) "Keyboard macro." (interactive "p") (kmacro-exec-ring-item (quote ([67108896 14 134217847 25 16] 0 "%d")) arg)))


;; Automatically make scripts executable
(add-hook 'after-save-hook
  'executable-make-buffer-file-executable-if-script-p)


;; whitespace handling
(require 'whitespace)
;(global-whitespace-mode t)

;; display only tails of lines longer than specified columns, tabs and
;; trailing whitespaces
;; (setq whitespace-line-column 80
;;       whitespace-style '(face tabs trailing tab-mark lines-tail))
;(setq whitespace-line-column nil)
(setq whitespace-style '(face tabs trailing tab-mark lines-tail))

;; save whitespace-mode variables
(add-to-list 'desktop-globals-to-save 'whitespace-line-column)
(add-to-list 'desktop-globals-to-save 'whitespace-style)


;; email sending - still doesn't work
;; http://ejd.posterous.com/send-email-through-gmail-with-gnu-emacs
(require 'smtpmail)
;;(require 'starttls)
(setq send-mail-function 'smtpmail-send-it
      message-send-mail-function 'smtpmail-send-it
      smtpmail-starttls-credentials '(("smtp.gmail.com" 587 nil nil))
      smtpmail-auth-credentials (expand-file-name "~/.authinfo")
      smtpmail-default-smtp-server "smtp.gmail.com"
      smtpmail-smtp-server "smtp.gmail.com"
      smtpmail-smtp-service 587
      user-mail-address "jay.s.doane@gmail.com"
      smtpmail-debug-info t)

;; abc-mode
(add-to-list 'auto-mode-alist '("\\.abc\\'"  . abc-mode))
;(add-to-list 'auto-mode-alist '("\\.abp\\'"  . abc-mode))
(autoload 'abc-mode "abc-mode" "abc music files" t)
;(add-to-list 'auto-insert-alist '(abc-mode . abc-skeleton))

;; http://stackoverflow.com/questions/683425/globally-override-key-binding-in-emacs/5340797#5340797
(global-set-key (kbd "C-x k") 'kill-current-buffer)
(global-set-key (kbd "C-c C-b") 'bury-buffer)
(global-set-key (kbd "C-c C-f") 'find-grep)
(global-set-key (kbd "C-c b") 'bury-buffer)
(global-set-key (kbd "C-c f") 'find-grep)

(setq vc-follow-symlinks nil)

(setq term-buffer-maximum-size 8192)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-names-vector
   ["#2d3743" "#ff4242" "#74af68" "#dbdb95" "#34cae2" "#008b8b" "#00ede1"
    "#e1e1e0"])
 '(case-fold-search t)
 '(column-number-mode t)
 '(current-language-environment "English")
 '(custom-safe-themes
   '("6c4c97a17fc7b6c8127df77252b2d694b74e917bab167e7d3b53c769a6abb6d6"
     "7898de5b2effa442cdab89f117d50aae9c345c9840aa1672adcdb5fc21bc9521"
     "950a9a6ca940ea1db61f7d220b01cddb77aec348d3c2524349a8683317d1dbb6"
     "585d10b2b3d7dfcefc7494c56b25f5e1b319d978ddae744be6023613c999fc34"
     "fc5fcb6f1f1c1bc01305694c59a1a861b008c534cae8d0e48e4d5e81ad718bc6"
     "36a309985a0f9ed1a0c3a69625802f87dee940767c9e200b89cdebdb737e5b29"
     "1056c413dd792adddc4dec20e8c9cf1907e164ae"
     "0470e5a761de61fe26ed4b3c00893370a795c8ab"
     "7a44c5ce5065d2843b0bf308e556185355a1cc28" default))
 '(delete-selection-mode t)
 '(fci-rule-color "#383838")
 '(global-font-lock-mode t nil (font-lock))
 '(menu-bar-mode t)
 '(org-export-backends '(ascii html icalendar latex md))
 '(package-archives
   '(("gnu" . "https://elpa.gnu.org/packages/")
     ("melpa-stable" . "https://melpa.org/packages/")))
 '(package-selected-packages
   '(abc-mode ansible browse-kill-ring company consult-eglot consult-lsp
              corfu dired-filter dired-git dired-preview dired-subtree
              diredfl direnv dirvish dockerfile-mode ellama embark
              embark-consult exec-path-from-shell flycheck groovy-mode
              helm ini-mode jinja2-mode json-mode keycast logview
              lsp-metals lsp-pyright lsp-ui lua-mode magit marginalia
              mise mmm-mode mood-line mustache-mode orderless
              org-superstar paredit rg sbt-mode tree-sitter
              treemacs-all-the-icons treemacs-icons-dired treesit-auto
              vertico vterm yaml-mode yasnippet))
 '(safe-local-variable-values
   '((git-commit-major-mode . git-commit-elisp-text-mode)
     (eval setq default-directory
           (locate-dominating-file buffer-file-name ".dir-locals.el"))
     (st-rulers . [70]) (indent-tabs-mode . 1) (allout-layout . t)))
 '(show-paren-mode t nil (paren))
 '(tramp-completion-use-auth-sources nil)
 '(tramp-password-prompt-regexp
   "^.*\\(Pass\\(?:phrase\\|word\\)\\|Verification code\\|pass\\(?:phrase\\|word\\)\\).*:\0? *")
 '(tramp-use-connection-share nil)
 '(tramp-use-ssh-controlmaster-options nil t)
 '(tramp-verbose 3)
 '(vc-ignore-dir-regexp
   "\\`\\(?:[\\/][\\/][^\\/]+[\\/]\\|/\\(?:net\\|afs\\|\\.\\.\\.\\)/\\)\\'\\|^/\\(\\(?:\\([a-zA-Z0-9-]+\\):\\(?:\\([^/|: \11]+\\)@\\)?\\(\\(?:[a-zA-Z0-9_.%-]+\\|\\[\\(?:\\(?:[a-zA-Z0-9]*:\\)+[a-zA-Z0-9.]+\\)?]\\)\\(?:#[0-9]+\\)?\\)?|\\)+\\)?\\([a-zA-Z0-9-]+\\):\\(?:\\([^/|: \11]+\\)@\\)?\\(\\(?:[a-zA-Z0-9_.%-]+\\|\\[\\(?:\\(?:[a-zA-Z0-9]*:\\)+[a-zA-Z0-9.]+\\)?]\\)\\(?:#[0-9]+\\)?\\)?:\\([^\12\15]*\\'\\)\\|^/\\(\\(?:\\([a-zA-Z0-9-]+\\):\\(?:\\([^/|: \11]+\\)@\\)?\\(\\(?:[a-zA-Z0-9_.%-]+\\|\\[\\(?:\\(?:[a-zA-Z0-9]*:\\)+[a-zA-Z0-9.]+\\)?]\\)\\(?:#[0-9]+\\)?\\)?|\\)+\\)?\\([a-zA-Z0-9-]+\\):\\(?:\\([^/|: \11]+\\)@\\)?\\(\\(?:[a-zA-Z0-9_.%-]+\\|\\[\\(?:\\(?:[a-zA-Z0-9]*:\\)+[a-zA-Z0-9.]+\\)?]\\)\\(?:#[0-9]+\\)?\\)?:\\([^\12\15]*\\'\\)\\|^/\\(\\(?:\\([a-zA-Z0-9-]+\\):\\(?:\\([^/|: \11]+\\)@\\)?\\(\\(?:[a-zA-Z0-9_.%-]+\\|\\[\\(?:\\(?:[a-zA-Z0-9]*:\\)+[a-zA-Z0-9.]+\\)?]\\)\\(?:#[0-9]+\\)?\\)?|\\)+\\)?\\([a-zA-Z0-9-]+\\):\\(?:\\([^/|: \11]+\\)@\\)?\\(\\(?:[a-zA-Z0-9_.%-]+\\|\\[\\(?:\\(?:[a-zA-Z0-9]*:\\)+[a-zA-Z0-9.]+\\)?]\\)\\(?:#[0-9]+\\)?\\)?:\\([^\12\15]*\\'\\)")
 '(warning-minimum-level :error))

(save-place-mode 1)

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
(set-face-attribute 'default nil :height 160)

;; (setq mac-option-modifier 'meta)
;; (setq mac-command-modifier 'hyper)
(unless (boundp 'ns-right-alternate-modifier)
  (load-file "~/.emacs.d/mac-switch-meta.el")
  (mac-switch-meta))

(defun revert-buffer-without-confirmation()
  "Revert buffer without asking for confirmation."
  (interactive "")
  (revert-buffer t t t))

(global-set-key (kbd "C-c C-v") 'revert-buffer-without-confirmation)

(global-set-key (kbd "C-c m") 'make-project)
(global-set-key (kbd "C-c C-h") 'helm-mini)

(defun bury-compile-buffer-if-successful (buffer string)
  "Bury a compilation BUFFER if STRING contents has no errors or warnings."
  (if (and
       (string-match "compilation" (buffer-name buffer))
       (string-match "finished" string)
       (not
        (with-current-buffer buffer
          (search-forward "warning" nil t))))
          ;; (search-forward "abnormal" nil t))))
      (run-with-timer 4 nil
                      (lambda (buf)
                        (bury-buffer buf)
                        (switch-to-prev-buffer (get-buffer-window buf) 'kill))
                      buffer)))
(add-hook 'compilation-finish-functions 'bury-compile-buffer-if-successful)


(add-to-list 'auto-mode-alist '("\\.j2\\'" . jinja2-mode))

(add-hook 'yaml-mode-hook
        (lambda ()
            (define-key yaml-mode-map "\C-m" 'newline-and-indent)))


(defun reload-dir-locals-for-current-buffer ()
  "Reload dir locals for the current buffer."
  (interactive)
  (let ((enable-local-variables :all))
    (hack-dir-local-variables-non-file-buffer)))

(global-set-key (kbd "C-c d") 'reload-dir-locals-for-current-buffer)

(when (require 'browse-kill-ring nil 'noerror)
  (browse-kill-ring-default-keybindings))
(require 'browse-kill-ring)


(defun eshell-here ()
  "Open a new eshell in the directory associated with the
current buffer's file.  The eshell is renamed to match that
directory to make multiple eshell windows easier."
  (interactive)
  (let* ((parent (if (buffer-file-name)
                     (file-name-directory (buffer-file-name))
                   default-directory))
         (height (/ (window-total-height) 3))
         (name   (car (last (split-string parent "/" t)))))
    (split-window-vertically (- height))
    (other-window 1)
    (eshell "new")
    (rename-buffer (concat "*eshell: " name "*"))

    (insert (concat "ls"))
    (eshell-send-input)))

(global-set-key (kbd "C-!") 'eshell-here)

(defun eshell/x ()
  "Exit eshell and delete window."
  (interactive)
  (insert "exit")
  (eshell-send-input)
  (delete-window))

(defalias 'yes-or-no-p 'y-or-n-p)

;;; https://glyph.twistedmatrix.com/2015/11/editor-malware.html
;; (let ((trustfile
;;        (replace-regexp-in-string
;;         "\\\\" "/"
;;         (replace-regexp-in-string
;;          "\n" ""
;;          (shell-command-to-string
;;           "/Users/jay/.pyenv/versions/certifi/bin/python -m certifi")))))
;;   (setq tls-program
;;         (list
;;          (format "gnutls-cli%s --x509cafile %s -p %%p %%h"
;;                  (if (eq window-system 'w32) ".exe" "") trustfile))))


;; https://www.emacswiki.org/emacs/CopyFromAbove
(autoload 'copy-from-above-command "misc"
  "Copy characters from previous nonblank line, starting just above point.
  \(fn &optional arg)"
  'interactive)

;; prefix with M-1 for single character
(global-set-key (kbd "C-c c") 'copy-from-above-command)

(require 'vterm)

(defun file-notify-rm-all-watches ()
  "Remove all existing file notification watches from Emacs."
  (interactive)
  (maphash
   (lambda (key _value)
     (file-notify-rm-watch key))
   file-notify-descriptors))

(require 'browse-kill-ring)
(browse-kill-ring-default-keybindings)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; TRAMP ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; This sets up Tramp (Transparent Remote Access, Multiple Protocol). The
;; syntax looks like:
;;
;;   emacs /ssh:work1.sl-dal-12.cloudant.com:./couchdb/stampede_ddocs.py
;;   emacs /scp:logs.sl-usc-02.cloudant.net:/srv/rsyslog/dbcore/bigblue/2021/11/30/notice
;;   emacs "/ssh:db4.bigblue.cloudant.com|sudo:dbcore@db4.bigblue.cloudant.com:/opt/dbcore/etc/local.ini"
;;
;; The second example uses `scp` as the protocol. That could be faster for
;; reading larger files such as logs. The last example demonstrates using sudo
;; transparently (be careful using it!).
;;
;; Tramp mode works automatically with:
;;   * Bookmarks - Save and load remote file bookmarks (C-x r m, C-x r l, etc)
;;   * Speedbar - Starts in the remote folder automatically.
;;   * EShell - Just like speedbar, opens on the remote node transparently
;;
;; Tested with cloudant-ssh version 0.3.3, the built-in Emacs 27.2 Tramp and
;; with Tramp version 2.5.1.5 from Package.el.

;; Skip the VC bits for the remote files
(customize-set-variable 'vc-ignore-dir-regexp
                        (format "%s\\|%s"
                                vc-ignore-dir-regexp
                                tramp-file-name-regexp))

;; Can set up to 10 to debug. Up to 6 is usually enough
(customize-set-variable 'tramp-verbose 3)

;; This technically works but is kinda slow. Easier to just use the itail
;; package or view-mode with manual s-f (revert) commands
;;(customize-set-variable 'auto-revert-remote-files t)

;; We use our own control socket so we disable it here
(customize-set-variable 'tramp-use-ssh-controlmaster-options nil)

;; These both have to be set for the verification code bits to work. This
;; setting should be set too '(auth-source-save-behavior nil). The main idea
;; here is to treat the verification code prompt as a password prompt. The
;; password prompts were left in there as examples.
;; (customize-set-variable 'tramp-completion-use-auth-sources nil)
;; (customize-set-variable 'tramp-password-prompt-regexp
;;                         (concat
;;                          "^.*"
;;                          (regexp-opt
;;                           '("passphrase" "Passphrase"
;;                             "password" "Password"
;;                             "Verification code")
;;                           t)
;;                          ".*:\0? *"))

(customize-set-variable 'tramp-default-method "ssh")
(customize-set-variable 'tramp-default-user "jdoane")
;(customize-set-variable 'vc-ignore-dir-regexp (format "%s\\|%s" vc-ignore-dir-regexp tramp-file-name-regexp))
(customize-set-variable 'auto-revert-remote-files nil)
(customize-set-variable 'tramp-use-ssh-controlmaster-options nil)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END TRAMP SETUP ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Tramp usage examples
; /-:files-master.c:./
; /-:db1.relengtest001.cloudant.com|sudo:db1.relengtest001.cloudant.com:/etc/sv/clouseau/control/
; /-:db1.relengtest001.c|sudo:db1.relengtest001.c:/etc/sv/clouseau/
; /-:db1.perftest003.c|sudo:db1.perftest003.c:/var/log/

(setenv "BASTION_AUTO_LOGIN_IBMCLOUD" "1")

(use-package treesit-auto
  :config
  (treesit-auto-add-to-auto-mode-alist 'all)
  (global-treesit-auto-mode))

;; The `vertico' package applies a vertical layout to the minibuffer.
;; It also pops up the minibuffer eagerly so we can see the available
;; options without further interactions.  This package is very fast
;; and "just works", though it also is highly customisable in case we
;; need to modify its behaviour.
;;
;; Further reading: https://protesilaos.com/emacs/dotemacs#h:cff33514-d3ac-4c16-a889-ea39d7346dc5
(use-package vertico
  :ensure t
  :config
  (setq vertico-cycle t)
  (setq vertico-resize nil)
  (vertico-mode 1))
(vertico-mode 1)

;; The `marginalia' package provides helpful annotations next to
;; completion candidates in the minibuffer.  The information on
;; display depends on the type of content.  If it is about files, it
;; shows file permissions and the last modified date.  If it is a
;; buffer, it shows the buffer's size, major mode, and the like.
;;
;; Further reading: https://protesilaos.com/emacs/dotemacs#h:bd3f7a1d-a53d-4d3e-860e-25c5b35d8e7e
(use-package marginalia
  :ensure t
  :config
  (marginalia-mode 1))
(marginalia-mode 1)

;; The `orderless' package lets the minibuffer use an out-of-order
;; pattern matching algorithm.  It matches space-separated words or
;; regular expressions in any order.  In its simplest form, something
;; like "ins pac" matches `package-menu-mark-install' as well as
;; `package-install'.  This is a powerful tool because we no longer
;; need to remember exactly how something is named.
;;
;; Note that Emacs has lots of "completion styles" (pattern matching
;; algorithms), but let us keep things simple.
;;
;; Further reading: https://protesilaos.com/emacs/dotemacs#h:7cc77fd0-8f98-4fc0-80be-48a758fcb6e2
(use-package orderless
  :ensure t
  :config
  (setq completion-styles '(orderless basic)))

;; The `consult' package provides lots of commands that are enhanced
;; variants of basic, built-in functionality.  One of the headline
;; features of `consult' is its preview facility, where it shows in
;; another Emacs window the context of what is currently matched in
;; the minibuffer.  Here I define key bindings for some commands you
;; may find useful.  The mnemonic for their prefix is "alternative
;; search" (as opposed to the basic C-s or C-r keys).
;;
;; Further reading: https://protesilaos.com/emacs/dotemacs#h:22e97b4c-d88d-4deb-9ab3-f80631f9ff1d
(use-package consult
  :ensure t
  ;; :bind
  ;; ("C-c s f" . consult-find)
  ;; )
  :bind (;; A recursive grep
         ("M-s M-g" . consult-grep)
         ;; Search for files names recursively
         ("M-s M-f" . consult-find)
         ;; Search through the outline (headings) of the file
         ("M-s M-o" . consult-outline)
         ;; Search the current buffer
         ("M-s M-l" . consult-line)
         ;; Switch to another buffer, or bookmarked file, or recently
         ;; opened file.
         ("M-s M-b" . consult-buffer)))

;; The `embark' package lets you target the thing or context at point
;; and select an action to perform on it.  Use the `embark-act'
;; command while over something to find relevant commands.
;;
;; When inside the minibuffer, `embark' can collect/export the
;; contents to a fully fledged Emacs buffer.  The `embark-collect'
;; command retains the original behaviour of the minibuffer, meaning
;; that if you navigate over the candidate at hit RET, it will do what
;; the minibuffer would have done.  In contrast, the `embark-export'
;; command reads the metadata to figure out what category this is and
;; places them in a buffer whose major mode is specialised for that
;; type of content.  For example, when we are completing against
;; files, the export will take us to a `dired-mode' buffer; when we
;; preview the results of a grep, the export will put us in a
;; `grep-mode' buffer.
;;
;; Further reading: https://protesilaos.com/emacs/dotemacs#h:61863da4-8739-42ae-a30f-6e9d686e1995
(use-package embark
  :ensure t
  :bind (("C-." . embark-act)
         :map minibuffer-local-map
         ("C-c C-c" . embark-collect)
         ("C-c C-e" . embark-export)))

;; The `embark-consult' package is glue code to tie together `embark'
;; and `consult'.
(use-package embark-consult
  :ensure t)

;; The `wgrep' packages lets us edit the results of a grep search
;; while inside a `grep-mode' buffer.  All we need is to toggle the
;; editable mode, make the changes, and then type C-c C-c to confirm
;; or C-c C-k to abort.
;;
;; Further reading: https://protesilaos.com/emacs/dotemacs#h:9a3581df-ab18-4266-815e-2edd7f7e4852
(use-package wgrep
  :ensure t
  :bind ( :map grep-mode-map
          ("e" . wgrep-change-to-wgrep-mode)
          ("C-x C-q" . wgrep-change-to-wgrep-mode)
          ("C-c C-c" . wgrep-finish-edit)))

;; The built-in `savehist-mode' saves minibuffer histories.  Vertico
;; can then use that information to put recently selected options at
;; the top.
;;
;; Further reading: https://protesilaos.com/emacs/dotemacs#h:25765797-27a5-431e-8aa4-cc890a6a913a
(savehist-mode 1)

;; The built-in `recentf-mode' keeps track of recently visited files.
;; You can then access those through the `consult-buffer' interface or
;; with `recentf-open'/`recentf-open-files'.
;;
;; I do not use this facility, because the files I care about are
;; either in projects or are bookmarked.
(recentf-mode 1)

(use-package corfu
  ;; Optional customizations
  ;; :custom
  ;; (corfu-cycle t)                ;; Enable cycling for `corfu-next/previous'
  ;; (corfu-quit-at-boundary nil)   ;; Never quit at completion boundary
  ;; (corfu-quit-no-match nil)      ;; Never quit, even if there is no match
  ;; (corfu-preview-current nil)    ;; Disable current candidate preview
  ;; (corfu-preselect 'prompt)      ;; Preselect the prompt
  ;; (corfu-on-exact-match nil)     ;; Configure handling of exact matches

  ;; Enable Corfu only for certain modes. See also `global-corfu-modes'.
  ;; :hook ((prog-mode . corfu-mode)
  ;;        (shell-mode . corfu-mode)
  ;;        (eshell-mode . corfu-mode))

  ;; Recommended: Enable Corfu globally.  This is recommended since Dabbrev can
  ;; be used globally (M-/).  See also the customization variable
  ;; `global-corfu-modes' to exclude certain modes.
  :init
  (global-corfu-mode))

;; A few more useful configurations...
(use-package emacs
  :custom
  ;; TAB cycle if there are only few candidates
  ;; (completion-cycle-threshold 3)

  ;; Enable indentation+completion using the TAB key.
  ;; `completion-at-point' is often bound to M-TAB.
  (tab-always-indent 'complete)

  ;; Emacs 30 and newer: Disable Ispell completion function.
  ;; Try `cape-dict' as an alternative.
  (text-mode-ispell-word-completion nil)

  ;; Hide commands in M-x which do not apply to the current mode.  Corfu
  ;; commands are hidden, since they are not used via M-x. This setting is
  ;; useful beyond Corfu.
  (read-extended-command-predicate #'command-completion-default-include-p))

(put 'narrow-to-region 'disabled nil)

;; (use-package keycast
;;   :config
;;   (keycast-mode-line-mode 1))

;; When you first call `find-file' (C-x C-f by default), you do not
;; need to clear the existing file path before adding the new one.
;; Just start typing the whole path and Emacs will "shadow" the
;; current one.  For example, you are at ~/Documents/notes/file.txt
;; and you want to go to ~/.emacs.d/init.el: type the latter directly
;; and Emacs will take you there.
(file-name-shadow-mode 1)

;; This works with `file-name-shadow-mode' enabled.  When you are in
;; a sub-directory and use, say, `find-file' to go to your home '~/'
;; or root '/' directory, Vertico will clear the old path to keep
;; only your current input.
(add-hook 'rfn-eshadow-update-overlay-hook #'vertico-directory-tidy)

;;; .emacs ends here
