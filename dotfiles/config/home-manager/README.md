```
 _   _                        __  __                                   
| | | | ___  _ __ ___   ___  |  \/  | __ _ _ __   __ _  __ _  ___ _ __ 
| |_| |/ _ \| '_ ` _ \ / _ \ | |\/| |/ _` | '_ \ / _` |/ _` |/ _ \ '__|
|  _  | (_) | | | | | |  __/ | |  | | (_| | | | | (_| | (_| |  __/ |   
|_| |_|\___/|_| |_| |_|\___| |_|  |_|\__,_|_| |_|\__,_|\__, |\___|_|   
                                                       |___/           
```

This is my home manager settings.

## Apply settings

```sh
home-manager switch

# if you not installed home-manager, please run below.
# The next time you run it, you will be able to run it with `home-manager`.
nix run home-manager/master -- switch
```

## Update

```sh
nix flake update
home-manager switch
```
