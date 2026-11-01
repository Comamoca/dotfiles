function dty --description 'dt + yolo (DSH_PERMISSION_MODE=danger-full-access)'
    # dt.fish と同じだが、TUI 側の権限も yolo に揃える。
    # アタッチ先 (dsh web) は既に danger-full-access で動いているが、
    # この env はローカル起動へフォールバックしたときにも効く。
    env DSH_PERMISSION_MODE=danger-full-access dt $argv
end
