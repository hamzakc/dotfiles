;;; init-maps.el -- Provide global key maps

;;; Commentary:
;;; Provide global maps that aren't specific to any mode or package.

;;; Code:
(define-key global-map (kbd "C-x C-q") 'kill-emacs)
(define-key global-map (kbd "C-c u")   'insert-char) ;; "u" for Unicode, get it?
(define-key global-map (kbd "C-c s")   (lambda () (interactive) (ansi-term "zsh")))
(define-key global-map (kbd "s-e")     'eval-buffer)
(define-key global-map (kbd "C-}")     'air-cycle-theme)
(define-key global-map (kbd "s-r")     (tiny-menu-run-item "reverts"))
(define-key global-map (kbd "C-c C-l") (tiny-menu-run-item "org-links"))

(evil-define-key 'insert global-map (kbd "C-v") 'yank)

(provide 'init-maps)
;;; init-maps.el ends here
