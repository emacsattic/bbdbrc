;; -*- auto-recompile: t -*-
;;; bbdbrc.el---Completion through multiple sources--mailrc, bbdb etc.
;; Time-stamp: <2002-06-13 17:14:39 deego>
;; Copyright (C) Deepak Goel 2001
;; Emacs Lisp Archive entry
;; Filename: bbdbrc.el
;; Package: bbdbrc
;; Author: Deepak Goel <deego@glue.umd.edu>
;; Version: 0.3alpha
;; For latest version: 

(defvar bbdbrc-home-page  
  "http://www.glue.umd.edu/~deego/emacspub/lisp-mine/bbdbrc")
 

;; Requires: when-copiling... 'cl

;; This file is NOT (yet) part of GNU Emacs.
 
;; This is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.
 
;; This is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.
 

;; See also: message-x.el from THE Uberlisper, Kai.
;; that library implements a subset of bbdbrc.el.


;; Quick start:
(defvar bbdbrc-quick-start
  "Add to your .emacs:
\(require 'bbdbrc\)
\(add-hook 'message-mode-hook 'bbdbrc-minor-mode-enable\)"
)

(defun bbdbrc-quick-start ()
  "Provides electric help for function `bbdbrc-quick-start'."
  (interactive)
  (with-electric-help
   '(lambda () (insert bbdbrc-quick-start) nil) "*doc*"))

;;; Introduction:
;; Stuff that gets posted to gnu.emacs.sources
;; as introduction
(defvar bbdbrc-introduction
  "Greetings,

While composing messages: I wanted my SPC, TAB and , to complete not
just .mailrc entries but also those from bbdb when available.  This
file implements that through a minor mode----completing entries *both*
from .mailrc and .bbdb, and also 
NEW--- if can't find a completion from any of those, will, be default,
try to complete via a local user-name.  Thus, the order of completion
attempts is: mailrc, bbdb, user-name on local machine.  The last
option can be turned off by customizing bbdbrc-local-complete-p.


Should be platform-independent but tested only with gnus-version
\"Gnus v5.8.8\" on emacs-version 21.1 and 20.3 on a sun-sparc unix
box.  Comments, bug-reports, enhancements and patches are welcome.. 

Type M-x bbdbrc-quick-start, bbdbrc-new-features, bbdbrc-commentary
extra for more details. 

" )

(defun bbdbrc-introduction ()
  "Provides electric help for function `bbdbrc-introduction'."
  (interactive)
  (with-electric-help
   '(lambda () (insert bbdbrc-introduction) nil) "*doc*"))

;;; Commentary:
(defvar bbdbrc-commentary
  "Type M-x bbdbrc-introduction and M-x bbdbrc-quick-start first.

This file defines bbdbrc-minor-mode, which when active in outgoing
messages, will allow keys like SPC or , or TAB to complete entries
from either .mailrc \(if any\), or from bbdb.  Of course, the entries
are completed only when we are in relevant headers, and not the rest
of the message..  (if you ever want to expand field no matter where you
are, you always have M-TAB..)

If an alias is defined in .mailrc, it is completed.  If not, then bbdb
is searched.  If a unique completion is found, completed. \(In each of
the above cases, your , or TAB or SPC also then self-inserts.\) If
more than one bbdb-completion is found, your character \(think ,\)
does not insert itself, for obvious reasons, rather all completions
are displayed.  Next in the order of searching (optionally) comes the
local user-name on your machine.  Note that (as of now) the user-name
is not completed.  Only is you supplied a complete user-name, the name
is replaced by an appropriate `pretty-looking' email-address.  Finally,
If no completion is found, your character simply self-inserts.

Tested only with gnus \(is there any other mailer too that message.el
is used by?\) on emacs 20.3.1.

PS: If you are used to customizing bbdb-complete-name-allow-cycling,
note that you can customize its behavior for the case of bbdbrc- minor
mode separately from the case when the mode is not enabled.  In other
words, the bbdbrc- equivalent of that variable is called
bbdbrc-complete-name-allow-cycling.   

Note however, that not been tested for the case when
bbdbrc-complete-name-allow-cycling is non-nil.  This is because my
bbdb seems to always ignore bbdb-complete-name-allow-cycling and
assume that it is nil.

"
)

(defun bbdbrc-commentary ()
  "Provides electric help for function `bbdbrc-commentary'."
  (interactive)
  (with-electric-help
   '(lambda () (insert bbdbrc-commentary) nil) "*doc*"))

;;; History:

;;; New features:
(defvar bbdbrc-new-features
  "
[1]  Inspired from a thread in gnus.ding by Matthieu Moy  and Martin
Thornquist, adding a third completion-method----- this one completes
the user-name on the local machine you are on.  

[2] bbdbrc will now remark in the echo area on how it did the
completion. 

[3] some bugfixes.

"
)

(defun bbdbrc-new-features ()
  "Provides electric help for function `bbdbrc-new-features'."
  (interactive)
  (with-electric-help
   '(lambda () (insert bbdbrc-new-features) nil) "*doc*"))

(defvar bbdbrc-version "0.3alpha")

;;==========================================
;;; Code:
(eval-when-compile (require 'cl))

(defvar bbdbrc-local-complete-p t
  "Set this variable to non-nil for local completions.
When non-nil,bbdbrc will try local-completions if nothing neither
mailrc nor bbdbrc help..

 Inspired from a thread in gnus.ding by Matthieu Moy  and Martin
Thornquist ---note that this solution still does not mimic pine's
behavior.   Pine can complete based on only partial user-name whereas
this needs the full user-name. 

")

(easy-mmode-define-minor-mode
 bbdbrc-minor-mode
 "Toggle bbdbrc-mode---a mode to make bbdb and mailrc compatible.
With optional positive argument, turn it on, with negative argument, turn it
off.

Type M-x bbdbrc-introduction for more details.

"
 nil  " RC"
 ; want SPC, TAB and , to do it..
 (list 'keymap
       (cons 32 'bbdbrc-expand)
       (cons 44 'bbdbrc-expand)
       (cons 9 'bbdbrc-expand)))

;;;###autoload
(defun bbdbrc-minor-mode-enable ()
  (interactive)
  (bbdbrc-minor-mode 1))

;;;###autoload
(defun bbdbrc-minor-mode-disable ()
  (interactive)
  (bbdbrc-minor-mode -1))


(defvar bbdbrc-complete-name-allow-cycling nil
  "Can be any expression which evals at runtime to something.
The eval of this expression is (temporarily) assigned to 
bbdb-complete-name-allow-cycling, when doing bbdbrc-expand.
")

 

(defun bbdbrc-expand ()
 "Gets bound to certain keys like SPC and , and TAB..
When composing messages..  Tends to work properly only when bound to a
key, i think.

The *Completions* hack is ugly, but what can you do? there's no other
way to find out the results of M-x bbdb-complete.

Warning: If you have a previous buffer called *Completions*, this will
try to delete it.. and won't even ask you.. unless of course, it
belongs to a unsaved file..

Finally, returns the value nil if no completion detected, else tries
to return either the completed name or the string *Completions*---this
when bbdb-complete-name results in this buffer...

For programmer: Some day, the completion modules need to be
separated.  Each completion-module, if success, should result in a
self-insert too..  This is because we don't want > 1
self-inserts.. The latter can lead to more than one abbrev-expansions,
which may not be desirable.   The only exception is the case when
there's a *Completions* buffer, in which case, no self-insert should
occur. 

"
  (interactive)
  (let ((char-string 
	 (with-temp-buffer
	   (self-insert-command 1)
	   (buffer-substring (point-min) (point-max))))
	(expanded-word nil))
    (if (mail-abbrev-in-expansion-header-p)
	(progn
	  (let* ((this-word (thing-at-point 'word))

		 (this-pt (point))
		 (this-len (and this-word (length this-word)))
		 (prev-pt (and this-len
			       (- this-pt this-len)))
		 (completed-p nil)
		 )
	    
	    ;; begin mailrc-module
	    (self-insert-command 1)
	    (setq expanded-word (and this-word (abbrev-symbol
						this-word)))
	    (when (and this-word
		       expanded-word)
	      (message "BBDBRC: Completing from mailrc-file"))
	    (unless expanded-word (delete-backward-char 1))
	    ;; End of mailrc-module
	    
	    ;; begin bbdb-module
	    (when (and
		 this-word
		 (not expanded-word))
	      ;; Try bbdb
	      (progn
		(when
		    (bbdbrc-buffer-name-p "*Completions*")
		  (kill-buffer "*Completions*"))
		(let
		    ((bbdb-complete-name-allow-cycling
		      (eval bbdbrc-complete-name-allow-cycling)))
		  (bbdb-complete-name)
		  ;; if name complete, set expanded-word
		  (when
		      (bbdbrc-buffer-name-p
		       "*Completions*")
		    (setq expanded-word "*Completions*")
		    (message "BBDBRC: Completing through bbdb-*Completions*"))
		  (bbdbrc-withit
		   (buffer-substring prev-pt (point))
		   (when 
		       (and (not expanded-word) 
			    (not (string= it this-word)))
		     (message "BBDBRC: Completing through bbdb")
		     (insert char-string)
		     (setq expanded-word it))
		   ;; if completions, set expanded word...
		   ;; if name complete, please insert the character..

		    ;;self-insert iff expanded, and no completiobs..
		   ;(bbdbrc-withit
		   ; (bbdbrc-buffer-name-p
		   ;  "*Completions*")
		   ; (when (and (not it) expanded-word)
		    ;  (self-insert-command 1)))
		   ))))


	    ;; next, try local completion. 
	    (when
		(and bbdbrc-local-complete-p (not expanded-word))
	      (setq expanded-word 
		    (bbdbrc-local-complete)))
	    
	    )
	  ;; done local-completion

	  ;; if nothing worked, insert a self-insert
	  (when (not expanded-word)
	    (message "BBDBRC: No completions found")
	    (insert char-string)
	    ))
      
      ;; if not in header completion, then simply self-insert
	  (self-insert-command 1))
    expanded-word))




(defun bbdbrc-buffer-name-p (name)
  "Whether name is the name of a buffer.."
  (member-if
   (lambda (arg)
     (string= name 
	      (buffer-name arg)))
   (buffer-list)))


;;; 2002-03-14 T14:54:35-0500 (Thursday)    Deepak Goel
(defmacro bbdbrc-withit (expr &rest rest)
  "Caution: var-capture by its very nature.."
  `(let ((it ,expr))
     ,@rest))

;;; 2002-03-14 T15:21:03-0500 (Thursday)    Deepak Goel
;;;###autoload
(defun bbdbrc-local-complete ()
  "Will local complete, and also return the completion, if success"
  (interactive)
  (let*
      ((this-word (thing-at-point 'word))
       (this-pt (point))
       (len (and this-word (length this-word)))
       (prev-pt (and len this-pt (- this-pt len)))
       (host (getenv "HOST"))
       (fulln (and this-word (user-full-name this-word)))
       (fstring
	(and fulln host len
	     (concat fulln " <" this-word "@" host ">"))))
    (when fstring
      (delete-backward-char len)
      (message "BBDBRC: Completing local machine address..")
      (insert fstring)
      (self-insert-command 1))
    fstring))

(provide 'bbdbrc)

;;; bbdbrc.el ends here
