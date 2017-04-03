# buffer-protect

Protect Emacs buffers from being killed inadvertently. 

This package provides a configurable list of buffer names that should
never be killed. 

# Usage

The `*Messages*` and `*scratch*` buffers are protected by
default. Customize `buffer-protect-buffers` to change the list of
protected buffer names.

The list of protected buffers can also be updated interactively:

 - Use `buffer-protect-add-buffer` to add the current buffer's name to
   the list.
 
 - Use `buffer-protect-kill-buffer` to force kill the current buffer
   and remove its name from the list.

# Ibuffer integration

This package advises certain `ibuffer` commands to be aware of
protected buffers: attempts to kill a protected buffer via ibuffer
will be silently ignored.

You can safely mark for deletion a set of buffers that includes a
protected buffer. Upon hitting `x` to kill the marked buffers, the
mark will be cleared on any protected buffers and they will be
preserved without causing an ibuffer error.


