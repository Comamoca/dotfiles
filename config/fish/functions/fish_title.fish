function fish_title
    # Show the current folder name in the terminal title.
    # Fish automatically emits OSC 0 / OSC 2 sequences from this function.
    #
    # ghq管理下では "owner/repo" を表示してfork元と区別できるようにする
    set -l ghq_root (ghq root 2>/dev/null)
    if test -n "$ghq_root"
        set -l rel (string replace -r "^$ghq_root/" "" (pwd))
        set -l parts (string split "/" "$rel")
        if test (count $parts) -ge 3
            # parts: [host, owner, repo, ...] → "owner/repo"
            echo "$parts[2]/$parts[3]"
            return
        end
    end
    basename (pwd)
end
