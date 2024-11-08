;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

(setq doom-theme 'doom-one)

(setq display-line-numbers-type 'relative)

(setq org-directory "~/org/")

;; don't prompt before exiting
(setq confirm-kill-emacs nil)
;; don't prompt the first time we start vterm
(setq vterm-always-compile-module t)
;; default path has the wrong permissions
;; (setq server-socket-dir (concat "~/.emacs.d/" (getenv "ZELLIJ_SESSION_NAME") "/"))
;; shortcut to start deer
(evil-global-set-key 'normal "-" 'dired-jump)
;; When done with this frame, type SPC q f`?
(setq server-client-instructions nil)
;; No prompt
(map! :leader
      :desc "Delete frame" "q f" #'delete-frame)

;; No prompt when quitting ediff
;; https://emacs.stackexchange.com/questions/9322/how-can-i-quit-ediff-immediately-without-having-to-type-y
(defun disable-y-or-n-p (orig-fun &rest args)
  (cl-letf (((symbol-function 'y-or-n-p) (lambda (prompt) t)))
    (apply orig-fun args)))
(advice-add 'ediff-quit :around #'disable-y-or-n-p)

(after! keycast
  (define-minor-mode keycast-mode
    "Show current command and its key binding in the mode line."
    :global t
    (if keycast-mode
        (add-hook 'pre-command-hook 'keycast--update t)
      (remove-hook 'pre-command-hook 'keycast--update))))
(add-to-list 'global-mode-string '("" keycast-mode-line))
(require 'keycast)

;; Fix fish problems with emacs
(setq shell-file-name (executable-find "bash"))
(setq-default vterm-shell (executable-find "fish"))
(setq-default explicit-shell-file-name (executable-find "fish"))

;; Cider
(setq cider-save-file-on-load t)
(setq cider-ns-refresh-show-log-buffer t)
(setq cider-ns-save-files-on-refresh t)

;; https://micro.rousette.org.uk/2021/01/03/a-useful-binding.html
(map!
 (:map 'override
  :v "v" #'er/expand-region
  :v "V" #'er/contract-region))

;; swap M-x with evil-ex. We M-x more often than :%s
(map! :nv ":" #'execute-extended-command)
(map! :leader :nv ":" #'evil-ex)

;; no prompt for .dir-locals.el
(setq safe-local-variable-values
      '((cider-preferred-build-tool . clojure-cli)
        (cider-clojure-cli-aliases . ":dev:cider")
        (cider-default-cljs-repl . shadow)
        (cider-shadow-default-options . ":app")
        (cider-ns-refresh-before-fn . "user/stop!")
        (cider-ns-refresh-after-fn . "user/start!")
        (gac-automatically-push-p t)
        (gac-silent-message-p nil)))

;; no prompt for lsp
(setq lsp-auto-guess-root t)

;; discover projects
(setq projectile-project-search-path '(("~/workspaces" . 1) ("~/code/personal" . 1)))
(setq projectile-auto-discover t)
;; create test files if needed
(setq projectile-create-missing-test-files t)

;; loead direnv mode at startup
(use-package! direnv
  :demand t
  :config (direnv-mode))

;; dired
(map! :map dired-mode-map
      :n "h" #'dired-up-directory
      :n "l" #'dired-find-file)

;; smartparens and so on
(use-package! smartparens
  :config
  (require 'smartparens-config))
(add-hook 'prog-mode-hook #'smartparens-strict-mode)
(add-hook 'prog-mode-hook #'evil-cleverparens-mode)
(setq evil-move-beyond-eol t)

;; open terminal on the right
(defun open-term-on-right ()
  (interactive)
  (+evil/window-vsplit-and-follow)
  (+vterm/here nil))

(map! :map global-map
      :ni "C-x C-t" #'open-term-on-right)

;; make easier to find vterm in list buffers
(setq vterm-buffer-name-string "vterm %s")

;; completion with corfu
(after! corfu
  (setq corfu-preview-current nil)
  (setq corfu-quit-at-boundary nil)
  (setq corfu-preselect 'valid)
  (custom-set-faces!
    '(corfu-current :background "#000000")))

;; use avy on s
(setq avy-all-windows t)
(map! :map evil-snipe-local-mode-map :nv "s" #'evil-avy-goto-char-timer)

;; same bindings in vterm
(after! vterm
  (map! :map vterm-mode-map :i "C-w d" #'evil-window-delete)
  (map! :map vterm-mode-map :i "C-w C-o" #'delete-other-windows)
  (map! :map vterm-mode-map :i "C-w v" #'+evil/window-vsplit-and-follow)
  (map! :map vterm-mode-map :i "C-w h" #'evil-window-left)
  (map! :map vterm-mode-map :i "C-w j" #'evil-window-down)
  (map! :map vterm-mode-map :i "C-w k" #'evil-window-up)
  (map! :map vterm-mode-map :i "C-w l" #'evil-window-right))

;; better "SPC c j"
(after! consult-lsp
  (map! :leader
      ;;; <leader> c --- code
        (:prefix-map ("c" . "code")
                     (:when (and (modulep! :tools lsp) (not (modulep! :tools lsp +eglot)))
                       (:when (modulep! :completion vertico)
                         :desc "Jump to symbol in current file workspace" "j"   #'consult-lsp-file-symbols
                         :desc "Jump to symbol in current workspace"      "J"   #'consult-lsp-symbols)))))

;; swap evil-cp-next-opening with evil-cp-previous-opening
(define-key (current-global-map) [remap evil-cp-next-opening] 'evil-cp-previous-opening)
(define-key (current-global-map) [remap evil-cp-previous-opening] 'evil-cp-next-opening)

;; override evil-cleverparens
(defvar evil-cp-additional-movement-keys
  '(("L"   . evil-cp-forward-sexp)
    ("H"   . evil-cp-backward-sexp)
    ("M-H" . evil-cp-beginning-of-defun)
    ("M-h" . (lambda () (interactive) (evil-cp-beginning-of-defun -1)))
    ("M-l" . evil-cp-end-of-defun)
    ("M-L" . (lambda () (interactive) (evil-cp-end-of-defun -1)))
    ("["   . evil-cp-previous-opening)
    ("]"   . evil-cp-next-closing)
    ("{"   . evil-cp-next-opening)
    ("}"   . evil-cp-previous-closing)
    ("("   . evil-cp-backward-up-sexp)
    (")"   . evil-cp-up-sexp)))

;; swap gj with j
(define-key evil-motion-state-map (kbd "j") 'evil-next-visual-line)
(define-key evil-motion-state-map (kbd "k") 'evil-previous-visual-line)
(define-key evil-motion-state-map (kbd "gj") 'evil-next-line)
(define-key evil-motion-state-map (kbd "gk") 'evil-previous-line)
