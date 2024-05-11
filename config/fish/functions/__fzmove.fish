function __fzmove
	if test (string length "(find . -maxdepth 2 -type d 2>/dev/null)") != 1
		cd (find . -maxdepth 2 -type d | fzf)
	end
end
