function fzf_prev_open
  set filename (find . -type f | fzf --preview 'bat  --color=always --style=header,grid {}')
  nvim (realpath $filename)
end
