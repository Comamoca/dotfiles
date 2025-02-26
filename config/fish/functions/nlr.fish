function nlr
        nix run nixpkgs#$argv[1] -- $argv[2..]
end
