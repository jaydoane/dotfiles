;; -*- mode: emacs-lisp -*-

;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(package-initialize)

;; Define a utility function which either installs a package (if it is
;; missing) or requires it (if it already installed).
(defun package-require (pkg &optional require-name)
  "Install a package only if it's not already installed."
  (when (not (package-installed-p pkg))
    (package-install pkg))
  (if require-name
      (require require-name)
    (require pkg)))

(setq user-full-name "Jay Doane")
(setq user-mail-address "jay.s.doane@gmail.com")


(defun maybe-add-to-load-path (path)
  "Add path to load-path if it exists"
  (if (file-accessible-directory-p path)
      (add-to-list 'load-path path)))

;; https://github.com/purcell/exec-path-from-shell
(when (memq window-system '(mac ns x))
  (exec-path-from-shell-initialize))

;; maybe not necessary with above?
;;(add-to-list 'exec-path "/usr/local/bin")

;; theming -- http://batsov.com/articles/2012/02/19/color-theming-in-emacs-reloaded/
;(add-to-list 'custom-theme-load-path "~/.emacs.d/themes/emacs-color-theme-solarized")
;(add-to-list 'custom-theme-load-path "~/.emacs.d/themes/zenburn-emacs")
;(load-theme 'solarized-dark t)
(load-theme 'deeper-blue t)

(global-hl-line-mode t)
(set-face-background 'hl-line "#333")
;(set-face-background 'hl-line "#ddd")

(global-set-key (kbd "C-c C-SPC") 'comment-region)
;(global-set-key (kbd "C-c C-c") 'comment-region)
(global-set-key (kbd "C-c C-u") 'uncomment-region)

;; some nice colors for the menu buffer
(setq buffer-menu-buffer-font-lock-keywords
      '(("^....[*]Man .*Man.*"   . font-lock-variable-name-face) ; Man page
        (".*Dired.*"             . font-lock-function-name-face) ; Dired
        ("^....[*]shell.*"       . font-lock-comment-face)       ; shell buff
        (".*[*]scratch[*].*"     . font-lock-preprocessor-face)  ; scratch buffer
        ("^....[*].*"            . font-lock-string-face)        ; "*" named buffers
        ("^..[*].*"              . font-lock-constant-face)      ; Modified
        ("^.[%].*"               . font-lock-keyword-face)))     ; Read only

(defun buffer-menu-custom-font-lock  ()
  (let ((font-lock-unfontify-region-function
         (lambda (start end)
           (remove-text-properties start end '(font-lock-face nil)))))
    (font-lock-unfontify-buffer)
    (set (make-local-variable 'font-lock-defaults)
         '(buffer-menu-buffer-font-lock-keywords t))
    (font-lock-fontify-buffer)))

(add-hook 'buffer-menu-mode-hook 'buffer-menu-custom-font-lock)
(add-hook 'electric-buffer-menu-mode-hook 'buffer-menu-custom-font-lock)

;;(define-key ctl-x-map "\^b" 'electric-buffer-list)
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

(setq require-final-newline nil)

;; stop at the end of the file, not just add lines
(setq next-line-add-newlines nil)

;(setq inhibit-startup-message t)
(setq make-backup-files nil)
;(setq require-final-newline 'ask)
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
; suppress ls does not support --dired; see ‘dired-use-ls-dired’ for more details.
(setq ls-lisp-use-insert-directory-program nil)

(require 'dired-x)
(setq dired-recursive-deletes t)
(setq dired-ls-F-marks-symlinks nil)
(setq dired-dwim-target t)
(put 'dired-find-alternate-file 'disabled nil)
(setq dired-listing-switches "-ahlF")
;; The below fails to correctly dired-sort-toggle-or-edit when using `gls`
;; (if (executable-find "gls") ; from brew install coreutils
;;     (progn
;;       (setq insert-directory-program "gls")
;;       (setq dired-listing-switches "-lFaGh1v"))
;;   (setq dired-listing-switches "-ahlF"))

(require 'use-package)
(use-package dired-subtree
  :ensure t
  :after dired
  :bind (:map dired-mode-map
              ("i" . dired-subtree-insert)
              (";" . dired-subtree-remove)
              ("M-<up>" . dired-subtree-up)
              ("M-<down>" . dired-subtree-down)
              ("<tab>" . dired-subtree-toggle)
              ("<backtab>" . dired-subtree-cycle))) ; S-TAB

;; json
(defun beautify-json (start end)
  "Format JSON in region using python json.tool"
  (interactive "*r")
  (shell-command-on-region start end "python -mjson.tool" (current-buffer) t))

;; nxml
;; (fset 'html-mode 'nxml-mode)
;; (setq auto-mode-alist
;;       (cons '("\\.\\(xml\\|xsl\\|rng\\|xhtml\\|sbml\\)\\'" . nxml-mode)
;; 	    auto-mode-alist))

(add-to-list 'auto-mode-alist '("\\.js\\'" . javascript-mode))
(add-to-list 'auto-mode-alist '("\\.json\\'" . javascript-mode))
(add-to-list 'auto-mode-alist '("\\.tac\\'" . python-mode))
(add-to-list 'auto-mode-alist '("\\.xml\\'" . nxml-mode))
(add-to-list 'auto-mode-alist '("\\.rss\\'" . nxml-mode))
(add-to-list 'auto-mode-alist '("\\.log\\'" . auto-revert-tail-mode))
(add-to-list 'auto-mode-alist '("\\Dockerfile\\'" . dockerfile-mode))

;(setq default-major-mode 'text-mode)
(setq-default indent-tabs-mode nil)
;(setq default-tab-width 4)

(add-hook 'org-mode-hook
          '(lambda () (auto-fill-mode 1)))

(add-hook 'c++-mode-hook '(lambda () (setq c-basic-offset 4)))
(add-hook 'js-mode-hook '(lambda () (setq js-indent-level 2)))
(add-hook 'javascript-mode-hook '(lambda () (setq js-indent-level 2)))
(put 'downcase-region 'disabled nil)
(put 'upcase-region 'disabled nil)

(if (fboundp 'tool-bar-mode) (tool-bar-mode -1))
;(if (fboundp 'scroll-bar-mode) (scroll-bar-mode 1))
(scroll-bar-mode -1)

(mouse-wheel-mode t)
(setq mouse-wheel-scroll-amount '(1 ((shift) . 1))) ; one line at a time
(setq mouse-wheel-progressive-speed nil) ; don't accelerate scrolling
(setq scroll-step 1) ;; keyboard scroll one line at a time

(setq x-select-enable-clipboard t)

;; (eval-after-load "sql"
;;   '(load-library "sql-indent"))

(require 'uniquify)
(setq uniquify-buffer-name-style 'forward)


;; python
(require 'python)
(setq python-indent 4)

;; activate minor whitespace mode when in python mode
(add-hook 'python-mode-hook 'whitespace-mode)

;; smart word boundaries
(add-hook 'python-mode-hook '(lambda () (subword-mode 1)))

;; bind RET to py-newline-and-indent
(add-hook 'python-mode-hook
          '(lambda () (define-key python-mode-map "\C-m" 'newline-and-indent)))

;(defun buffer-file-dir ()
;  "Return the directory of the current buffer's file"
;  (substring (buffer-file-name) 0 (string-match (buffer-name) (buffer-file-name))))
;  (substring (buffer-file-name) 0 (string-match "/" (buffer-file-name) 1))))
;(string-match "/" (reverse-string (buffer-file-dir)))

(defun reverse-string (s)
  (coerce (reverse (loop for b across s
                         collect b))
          'string))

(defun file-dir (file-name)
  "Return the file's directory, eg, (file-dir (buffer-file-name))"
  (reverse-string (substring (reverse-string file-name)
                             (+ 1 (string-match "/" (reverse-string file-name))))))

(defun python-insert-sysmodules ()
  "Insert directory of current buffer's file into sys.modules in *Python* sys.path"
  (interactive)
  (python-send-string (format "import sys; sys.path.insert(0, '%s'); print(sys.path[0])"
                              (file-dir(buffer-file-name)))))

(define-key esc-map "s" 'python-insert-sysmodules)
;(define-key python-mode-map (kbd "<M-s>") 'python-insert-sysmodules)
(define-key python-mode-map (kbd "<f5>") 'python-switch-to-python)
(define-key python-mode-map (kbd "C-c p") 'python-switch-to-python)

(defadvice python-send-buffer (before advice-send-dunder-file activate)
  "Set the __file__ variable prior to sending current python buffer"
  (python-send-string (format "__file__ = '%s'" buffer-file-name)))


;; haskell
;; (let ((file "~/emacs/haskell-mode-2.1/haskell-site-file.el"))
;;   (when (file-readable-p file)
;;     (load file)
;;     (add-hook 'haskell-mode-hook 'turn-on-haskell-doc-mode)
;;     (add-hook 'haskell-mode-hook 'turn-on-haskell-indent)))

;; javascript
(add-hook 'javascript-mode-hook 'js-mode)
;(autoload 'js-mode "js-mode" nil t)

;; multi-mode-mode, for html/css/javascript
;; (if (file-accessible-directory-p "~/.emacs.d/pkg/mmm-mode")
;;     (add-to-list 'load-path "~/.emacs.d/pkg/mmm-mode"))
(when (file-readable-p "~/.emacs.d/pkg/mmm-mako.el")
  (load "~/.emacs.d/pkg/mmm-mako.el")
  (add-to-list 'auto-mode-alist '("\\.mako\\'" . html-mode))
  (mmm-add-mode-ext-class 'html-mode "\\.mako\\'" 'mako))

(add-to-list 'auto-mode-alist '("\\.txt$" . text-mode))

;; org
(add-to-list 'auto-mode-alist '("\\.org$" . org-mode))
(define-key global-map "\C-cl" 'org-store-link)
(define-key global-map "\C-ca" 'org-agenda)
(setq org-log-done t)
(setq org-startup-indented t)
(add-hook 'org-mode-hook
          (lambda ()
            (local-set-key "\C-\M-c" 'org-table-copy-down)
            (local-unset-key (kbd "C-c C-b"))))


;; markdown -- http://jblevins.org/projects/markdown-mode/
(autoload 'markdown-mode "markdown-mode.el"
   "Major mode for editing Markdown files" t)
(add-to-list 'auto-mode-alist '("\\.md$" . markdown-mode))

;; elixir
(add-hook 'elixir-mode-hook
          (lambda ()
            (setq-local whitespace-line-column 90)))

;; erlang
;; (let ((emacs-dir
;;        (car
;;         (file-expand-wildcards "/usr/local/lib/erlang/lib/tools-*/emacs"))))
(let ((emacs-dir "~/prev/proj/otp/lib/tools/emacs/"))
  (when (file-accessible-directory-p emacs-dir)
    (add-to-list 'load-path emacs-dir)
    (require 'erlang-start)
    (setq erlang-indent-level 4)
    (setq erlang-indent-guard 4)
    (setq erlang-argument-indent 4)
    (add-to-list 'auto-mode-alist '("\\.app\\'" . erlang-mode))
    (add-to-list 'auto-mode-alist '("\\.app.src\\'" . erlang-mode))))


;; ;; distel
;; ;; http://bc.tech.coop/blog/070528.html
;; ;; http://fresh.homeunix.net/~luke/distel/distel-user-3.3.pdf
;; (let ((dir "~/proj/distel/elisp"))
;;   (when (file-accessible-directory-p dir)
;;     (unless (member dir load-path)
;;       (add-to-list 'load-path dir))
;;     (require 'distel)
;;     (distel-setup)
;;     (add-hook
;;      'erlang-mode-hook
;;      (lambda ()
;;        ;; when starting an Erlang shell in Emacs, default in the node name
;;        (setq inferior-erlang-machine-options
;;              '("-name" "distel@127.0.0.1"
;;                "-pa" "/Users/jay/proj/ibm/db/src/*/ebin"
;;                "-boot" "start_sasl"
;;                "-s" "app start ibrowse"))
;;        (setq-local whitespace-line-column 80)
;;        ;; add Erlang functions to an imenu menu
;;        (imenu-add-to-menubar "imenu")))
;;     ;; A number of the erlang-extended-mode key bindings are useful in the shell too
;;     (defconst distel-shell-keys
;;       '(("\C-\M-i"   erl-complete)
;;         ("\M-?"      erl-complete)
;;         ("\M-."      erl-find-source-under-point)
;;         ("\M-,"      erl-find-source-unwind)
;;         ("\M-*"      erl-find-source-unwind)
;;         )
;;       "Additional keys to bind when in Erlang shell.")
;;     (add-hook 'erlang-shell-mode-hook
;;               (lambda ()
;;                 ;; add some Distel bindings to the Erlang shell
;;                 (dolist (spec distel-shell-keys)
;;                   (define-key erlang-shell-mode-map (car spec) (cadr spec)))))))

;; LSP
;; Performance tweaks for LSP
(setq gc-cons-threshold 100000000)
(setq read-process-output-max (* 1024 1024))
(setq lsp-idle-delay 0.500)

;(setq lsp-keymap-prefix "C-l")
(package-require 'lsp-mode)
(add-hook 'erlang-mode-hook #'lsp)
;doesn't work: (add-hook 'nitrogen-mode-hook #'lsp)

(use-package lsp-mode
  :hook ((c-mode          ; clangd
          c++-mode        ; clangd
          c-or-c++-mode   ; clangd
          java-mode       ; eclipse-jdtls
          js-mode         ; ts-ls (tsserver wrapper)
          js-jsx-mode     ; ts-ls (tsserver wrapper)
          typescript-mode ; ts-ls (tsserver wrapper)
          python-mode     ; pyright
          web-mode        ; ts-ls/HTML/CSS
          haskell-mode    ; haskell-language-server
          ) . lsp-deferred)
  :commands lsp
  :config
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
  (setq lsp-enable-snippet nil)
  (setq read-process-output-max (* 1024 1024)) ;; 1MB
  (setq lsp-idle-delay 0.5))

(use-package lsp-pyright
  :hook (python-mode . (lambda () (require 'lsp-pyright)))
  :init (when (executable-find "python3")
          (setq lsp-pyright-python-executable-cmd "python3")))

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
(setq multi-term-program "/bin/bash")
;; only needed if you use autopair
;; (add-hook 'term-mode-hook
;;   #'(lambda () (setq autopair-dont-activate t)))
(global-set-key (kbd "C-c C-n") 'multi-term-next)
(global-set-key (kbd "C-c N") 'multi-term) ;; create a new one
(global-set-key (kbd "C-c C-j") 'term-line-mode)

;(require 'ido)
;(ido-mode t)
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
(global-set-key (kbd "C-x k") 'kill-this-buffer)
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
   ["#2d3743" "#ff4242" "#74af68" "#dbdb95" "#34cae2" "#008b8b" "#00ede1" "#e1e1e0"])
 '(case-fold-search t)
 '(column-number-mode t)
 '(current-language-environment "English")
 '(custom-enabled-themes '(vscode-dark-plus))
 '(custom-safe-themes
   '("6c4c97a17fc7b6c8127df77252b2d694b74e917bab167e7d3b53c769a6abb6d6" "7898de5b2effa442cdab89f117d50aae9c345c9840aa1672adcdb5fc21bc9521" "950a9a6ca940ea1db61f7d220b01cddb77aec348d3c2524349a8683317d1dbb6" "585d10b2b3d7dfcefc7494c56b25f5e1b319d978ddae744be6023613c999fc34" "fc5fcb6f1f1c1bc01305694c59a1a861b008c534cae8d0e48e4d5e81ad718bc6" "36a309985a0f9ed1a0c3a69625802f87dee940767c9e200b89cdebdb737e5b29" "1056c413dd792adddc4dec20e8c9cf1907e164ae" "0470e5a761de61fe26ed4b3c00893370a795c8ab" "7a44c5ce5065d2843b0bf308e556185355a1cc28" default))
 '(delete-selection-mode t)
 '(fci-rule-color "#383838")
 '(global-font-lock-mode t nil (font-lock))
 '(menu-bar-mode t)
 '(org-export-backends '(ascii html icalendar latex md))
 '(package-archives
   '(("gnu" . "https://elpa.gnu.org/packages/")
     ("melpa-stable" . "https://melpa.org/packages/")))
 '(package-selected-packages
   '(use-package dired-filter dired-git dired-subtree lsp-pyright dap-mode magit helm-lsp flycheck flycheck-dialyzer tree-sitter-langs tree-sitter vterm vscode-dark-plus-theme ## groovy-mode mood-line powerline doom-modeline persp-projectile perspective yasnippet alchemist ag yaml-mode mustache-mode markdown-mode helm-projectile exec-path-from-shell dockerfile-mode browse-kill-ring ansible abc-mode))
 '(safe-local-variable-values
   '((git-commit-major-mode . git-commit-elisp-text-mode)
     (eval setq default-directory
           (locate-dominating-file buffer-file-name ".dir-locals.el"))
     (st-rulers .
                [70])
     (indent-tabs-mode . 1)
     (allout-layout . t)))
 '(show-paren-mode t nil (paren))
 '(tramp-completion-use-auth-sources nil)
 '(tramp-password-prompt-regexp
   "^.*\\(Pass\\(?:phrase\\|word\\)\\|Verification code\\|pass\\(?:phrase\\|word\\)\\).*: ? *")
 '(tramp-use-ssh-controlmaster-options nil)
 '(tramp-verbose 3)
 '(vc-ignore-dir-regexp
   "\\`\\(?:[\\/][\\/][^\\/]+[\\/]\\|/\\(?:net\\|afs\\|\\.\\.\\.\\)/\\)\\'\\|^/\\(\\(?:\\([a-zA-Z0-9-]+\\):\\(?:\\([^/|: 	]+\\)@\\)?\\(\\(?:[a-zA-Z0-9_.%-]+\\|\\[\\(?:\\(?:[a-zA-Z0-9]*:\\)+[a-zA-Z0-9.]+\\)?]\\)\\(?:#[0-9]+\\)?\\)?|\\)+\\)?\\([a-zA-Z0-9-]+\\):\\(?:\\([^/|: 	]+\\)@\\)?\\(\\(?:[a-zA-Z0-9_.%-]+\\|\\[\\(?:\\(?:[a-zA-Z0-9]*:\\)+[a-zA-Z0-9.]+\\)?]\\)\\(?:#[0-9]+\\)?\\)?:\\([^
]*\\'\\)\\|^/\\(\\(?:\\([a-zA-Z0-9-]+\\):\\(?:\\([^/|: 	]+\\)@\\)?\\(\\(?:[a-zA-Z0-9_.%-]+\\|\\[\\(?:\\(?:[a-zA-Z0-9]*:\\)+[a-zA-Z0-9.]+\\)?]\\)\\(?:#[0-9]+\\)?\\)?|\\)+\\)?\\([a-zA-Z0-9-]+\\):\\(?:\\([^/|: 	]+\\)@\\)?\\(\\(?:[a-zA-Z0-9_.%-]+\\|\\[\\(?:\\(?:[a-zA-Z0-9]*:\\)+[a-zA-Z0-9.]+\\)?]\\)\\(?:#[0-9]+\\)?\\)?:\\([^
]*\\'\\)\\|^/\\(\\(?:\\([a-zA-Z0-9-]+\\):\\(?:\\([^/|: 	]+\\)@\\)?\\(\\(?:[a-zA-Z0-9_.%-]+\\|\\[\\(?:\\(?:[a-zA-Z0-9]*:\\)+[a-zA-Z0-9.]+\\)?]\\)\\(?:#[0-9]+\\)?\\)?|\\)+\\)?\\([a-zA-Z0-9-]+\\):\\(?:\\([^/|: 	]+\\)@\\)?\\(\\(?:[a-zA-Z0-9_.%-]+\\|\\[\\(?:\\(?:[a-zA-Z0-9]*:\\)+[a-zA-Z0-9.]+\\)?]\\)\\(?:#[0-9]+\\)?\\)?:\\([^
]*\\'\\)")
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
  "revert buffer without asking for confirmation"
  (interactive "")
  (revert-buffer t t t))

(global-set-key (kbd "C-c C-v") 'revert-buffer-without-confirmation)

;;(global-set-key (kbd "C-x C-l") 'compile)
(global-set-key (kbd "C-c C-c") 'compile)
(global-set-key (kbd "C-c m") 'compile)
(global-set-key (kbd "C-c C-h") 'helm-mini)

(defun bury-compile-buffer-if-successful (buffer string)
  "Bury a compilation buffer if succeeded without warnings "
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


(require 'org-superstar)
(add-hook 'org-mode-hook (lambda () (org-superstar-mode 1)))
;; superseded by superstar
;; (require 'org-bullets)
;; (add-hook 'org-mode-hook (lambda () (org-bullets-mode 1)))


(add-to-list 'auto-mode-alist '("\\.j2\\'" . jinja2-mode))
(maybe-add-to-load-path "~/.emacs.d/jinja2-mode")

(add-hook 'yaml-mode-hook
        (lambda ()
            (define-key yaml-mode-map "\C-m" 'newline-and-indent)))

;; projectile
;; (projectile-global-mode)
;; (setq projectile-completion-system 'helm)
;; (helm-projectile-on)

(defun reload-dir-locals-for-current-buffer ()
  "reload dir locals for the current buffer"
  (interactive)
  (let ((enable-local-variables :all))
    (hack-dir-local-variables-non-file-buffer)))

(global-set-key (kbd "C-c d") 'reload-dir-locals-for-current-buffer)

(when (require 'browse-kill-ring nil 'noerror)
  (browse-kill-ring-default-keybindings))
;; (require 'browse-kill-ring)
;; (browse-kill-ring-default-keybindings)


(defun eshell-here ()
  "Opens up a new shell in the directory associated with the
current buffer's file. The eshell is renamed to match that
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
  (insert "exit")
  (eshell-send-input)
  (delete-window))

(defalias 'yes-or-no-p 'y-or-n-p)

;;; https://glyph.twistedmatrix.com/2015/11/editor-malware.html
(let ((trustfile
       (replace-regexp-in-string
        "\\\\" "/"
        (replace-regexp-in-string
         "\n" ""
         (shell-command-to-string
          "/Users/jay/.pyenv/versions/certifi/bin/python -m certifi")))))
  (setq tls-program
        (list
         (format "gnutls-cli%s --x509cafile %s -p %%p %%h"
                 (if (eq window-system 'w32) ".exe" "") trustfile))))


;; https://www.emacswiki.org/emacs/CopyFromAbove
(autoload 'copy-from-above-command "misc"
  "Copy characters from previous nonblank line, starting just above point.
  \(fn &optional arg)"
  'interactive)

;; prefix with M-1 for single character
(global-set-key (kbd "C-c c") 'copy-from-above-command)

(require 'vterm)


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
(customize-set-variable 'tramp-completion-use-auth-sources nil)
(customize-set-variable 'tramp-password-prompt-regexp
                        (concat
                         "^.*"
                         (regexp-opt
                          '("passphrase" "Passphrase"
                            "password" "Password"
                            "Verification code")
                          t)
                         ".*:\0? *"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END TRAMP SETUP ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
