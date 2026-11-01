function dtl --description 'dsh TUI を tui profile でローカル起動する (attach しない)'
    # dsh web に繋がず、tui profile を in-process で起動する。
    # 旧 `dt` の挙動。web の有無に関係なく単体で動かしたいとき用。
    command dsh tui $argv
end
