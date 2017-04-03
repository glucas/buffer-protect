;;; buffer-protect.el --- Protect buffers from being killed inadvertently.  -*- lexical-binding: t; -*-

;; Copyright (C) 2015 Greg Lucas

;; Author:  <greg@glucas.net>
;; Keywords: convenience

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Prevent certain buffers from being killed.

;; By default the *Messages* and *scratch* buffers are protected.  Use
;; `buffer-protect-add-buffer' to interactively add buffers to the
;; protected list; or customize `buffer-protect-buffers' directly.

;; This package integrates with `ibuffer': protected buffers are
;; unmarked before a kill operation.

;;; Code:

(defgroup buffer-protect nil
  "Protect buffers from being killed."
  :group 'convenience)

(defcustom buffer-protect-buffers '("*scratch*" "*Messages*")
  "List of buffer names to protect."
  :type '(repeat string)
  :group 'buffer-protect)

(defun buffer-protect-protected-p (buffer)
  "Return non-nil if BUFFER is protected."
  (member buffer buffer-protect-buffers))

(defun buffer-protect-add-buffer (&optional buffer)
  "Protect BUFFER from being accidentally killed."
  (interactive "bProtect buffer:")
  (unless buffer (setq buffer (buffer-name (current-buffer))))
  (add-to-list 'buffer-protect-buffers buffer)
  (message "Added buffer '%s' to protected list." buffer))

(defun buffer-protect-kill-buffer (&optional buffer)
  "Kill BUFFER and remove it from the protected list."
  (interactive "bKill buffer:")
  (unless buffer (setq buffer (buffer-name (current-buffer))))
  (setq buffer-protect-buffers (delete buffer buffer-protect-buffers))
  (kill-buffer (get-buffer buffer)))

(defun buffer-protect-kill-buffer-query-function ()
  "Bury a protected buffer and don't allow it to be killed."
  (let ((buf (buffer-name)))
    (if (buffer-protect-protected-p buf)
        (with-current-buffer buf
          (progn (bury-buffer) nil))
      t)))

(add-hook 'kill-buffer-query-functions #'buffer-protect-kill-buffer-query-function)

;;; Ibuffer integration

(eval-when-compile
  (require 'ibuffer)
  (require 'ibuf-ext))

(defun buffer-protect-ibuffer-unmark-protected (&optional list)
  "Unmark all protected buffers.
When called non-interactively, unmark protected buffers in LIST."
  (interactive)
  (require 'ibuf-ext)
  (ibuffer-mark-on-buffer
   (lambda (buf)
     (let ((name (buffer-name buf)))
       (when (buffer-protect-protected-p name)
         (if list
             (when (member name list)
               (setq list (delete name list))
               t)
           t))))
   ?\s)
  list)

(defun buffer-protect-unmark-protected-with-mark (mark)
  "Unmark all protected buffers currently marked with MARK.
Returns the remaining list of marked buffers."
  (let ((marked (ibuffer-buffer-names-with-mark mark)))
    (if marked
        (buffer-protect-ibuffer-unmark-protected marked)
      marked)))

(with-eval-after-load "ibuffer"
  (advice-add 'ibuffer-do-kill-on-deletion-marks :before-while
              (lambda () (buffer-protect-unmark-protected-with-mark ibuffer-deletion-char))
              '((name . "buffer-protect-unmark")))
  (advice-add 'ibuffer-do-delete :before-while
              (lambda () (buffer-protect-unmark-protected-with-mark ibuffer-marked-char))
              '((name . "buffer-protect-unmark"))))

(provide 'buffer-protect)
;;; buffer-protect.el ends here
