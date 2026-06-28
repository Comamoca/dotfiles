function opensrc-switch --description "Change directory to a selected opensrc repo"
    set -l repo_json (opensrc list --json 2>/dev/null)
    if test -z "$repo_json"
        echo "opensrc: no repos found or command failed" >&2
        return 1
    end

    set -l selected (echo $repo_json | jq -r '.repos[] | [.name] | @tsv' | fzf --prompt="opensrc> " --header="Select a repo to cd into" | cut -f1)

    if test -z "$selected"
        return 0
    end

    set -l target (opensrc path $selected 2>/dev/null)
    if test -z "$target"
        echo "opensrc: failed to resolve path for $selected" >&2
        return 1
    end

    if not test -d "$target"
        echo "opensrc: directory not found: $target" >&2
        return 1
    end

    cd $target
end
