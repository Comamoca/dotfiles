#!/usr/bin/env fish

set -l script_name "verify-opencode-failover"
set -l env_var_name "OPENCODE_FAILOVER_ENV_FILE"

function fail
    echo "FAIL: $argv[1]"
    exit 1
end

function ok
    echo "OK: $argv[1]"
end

echo "== opencode-failover verification =="

if not set -q $env_var_name
    fail "$env_var_name is not set (try a new shell)"
end

set -l env_file_path $$env_var_name

if test -z "$env_file_path"
    fail "$env_var_name is empty"
end

ok "$env_var_name = $env_file_path"

if not test -e "$env_file_path"
    fail "$env_file_path does not exist"
end

if test -L "$env_file_path"
    set -l real_path (readlink -f "$env_file_path" 2>/dev/null)
    ok "$env_file_path exists (symlink -> $real_path)"
else
    ok "$env_file_path exists (regular file)"
end

set -l content (cat "$env_file_path" 2>/dev/null)
if test -z "$content"
    fail "$env_file_path is empty"
end

if not string match -q '*OPENCODE_FAILOVER_KEYS*' "$content"
    fail "OPENCODE_FAILOVER_KEYS not found in $env_file_path"
end

ok "OPENCODE_FAILOVER_KEYS found in file"

set -l providers opencode opencode-go opencode_go
set -l missing 0

for provider in $providers
    if string match -q "*\"$provider\"*" "$content"
        ok "provider '$provider' found"
    else
        echo "WARN: provider '$provider' not found"
        set missing (math $missing + 1)
    end
end

echo ""
echo "Current directory: $(pwd)"
echo "Keys file: $env_file_path"

if test $missing -eq 0
    echo ""
    echo "== ALL CHECKS PASSED =="
    echo "opencode-failover is configured correctly for this directory."
    exit 0
else
    echo ""
    fail "$missing provider(s) missing"
end
