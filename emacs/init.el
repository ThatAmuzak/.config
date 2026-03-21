(setenv "PATH" (concat "C:\\msys64\\mingw64\\bin;" (getenv "PATH")))
(add-to-list 'exec-path "C:\\msys64\\mingw64\\bin")

(org-babel-load-file
 (expand-file-name
  "config.org"
 user-emacs-directory))
