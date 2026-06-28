#! /usr/bin/env nix-shell
#! nix-shell -i bash -p bash

clip_file="/tmp/clip"

frame_opts=()
if [ "${1:-}" = "float" ]; then
	frame_opts=(-F '((name . "Floaterm"))')
fi

emacsclient -c "${frame_opts[@]}" \
  --eval "(progn
            (find-file \"$clip_file\")
            (erase-buffer)
            (add-hook 'delete-frame-functions
                      (lambda (frame)
                        (when (get-file-buffer \"$clip_file\")
                          (with-current-buffer (get-file-buffer \"$clip_file\")
                            (goto-char (point-max))
                            (when (eq (char-before) ?\\n)
                              (delete-char -1))
                            (save-buffer)))) nil t))"

if [[ -e "$clip_file" ]]; then
	wl-copy < "$clip_file"
	rm -f "$clip_file"
fi
