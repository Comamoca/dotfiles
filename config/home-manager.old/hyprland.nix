{ pkgs }:
let
  kitty = "nixGLIntel kitty";
in
{
  monitor = [ ",preferred,auto,auto" ];

  env = [
    "XCURSOR_SIZE,32"
    "GDK_SCALE,2"
    # "HYPRCURSOR_THEME,MyCursor"
    "HYPRCURSOR_SIZE,25"
    "XCURSOR_SIZE,24"
    "QT_QPA_PLATFORMTHEME,qt5ct"
  ];

  # "$terminal" = "\"${pkgs.kitty}/bin/kitty\"";
  # "$terminal" = "kitty";
  "$terminal" = kitty;

  "$browser" = "firefox";
  "$fileManager" = "thunar";
  # "$menu" = "${pkgs.rofi} -show drun";
  "$menu" = "rofi -show drun";
  input = {
    kb_layout = "jp";
    #  kb_variant = "";
    #  kb_model = "";
    #  kb_options = "";
    #  kb_rules = "";

    follow_mouse = "0";
    mouse_refocus = false;

    touchpad = {
      natural_scroll = true;
    };

    sensitivity = 0; # -1.0 to 1.0, 0 means no modification.
  };

  xwayland = {
    force_zero_scaling = true;
  };

  general = {
    gaps_in = 5;
    gaps_out = 20;
    border_size = 2;
    "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
    "col.inactive_border" = "rgba(595959aa)";
    layout = "dwindle";
    allow_tearing = false;
  };

  decoration = {
    rounding = 10;

    blur = {
      enabled = true;
      size = 3;
      passes = 1;
    };
    drop_shadow = "yes";
    shadow_range = 4;
    shadow_render_power = 3;
    "col.shadow" = "rgba(1a1a1aee)";
  };

  animations = {
    enabled = "yes";
    bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";

    animation = [
      "windows, 1, 7, myBezier"
      "windowsOut, 1, 7, default, popin 80%"
      "border, 1, 10, default"
      "borderangle, 1, 8, default"
      "fade, 1, 7, default"
      "workspaces, 1, 6, default"
    ];
  };

  # Hyprland Plugins
  plugin = {
    hyprfocus = {
      enabled = "yes";
      animate_floating = "yes";
      animate_workspacechange = "yes";
      focus_animation = "shrink";
      # # Beziers for focus animations
      # bezier = bezIn, 0.5,0.0,1.0,0.5
      # bezier = bezOut, 0.0,0.5,0.5,1.0
      # bezier = overshot, 0.05, 0.9, 0.1, 1.05
      # bezier = smoothOut, 0.36, 0, 0.66, -0.56
      # bezier = smoothIn, 0.25, 1, 0.5, 1
      # bezier = realsmooth, 0.28,0.29,.69,1.08

      # Flash settings
      # flash {
      #     flash_opacity = 0.95
      #     in_bezier = realsmooth
      #     in_speed = 0.5
      #     out_bezier = realsmooth
      #     out_speed = 3
      # }

      # Shrink settings
      shrink = {
        shrink_percentage = 0.95;
        in_bezier = "realsmooth";
        in_speed = 1;
        out_bezier = "realsmooth";
        out_speed = 2;
      };
    };
  };

  dwindle = {
    pseudotile = "yes";
    preserve_split = "yes";
  };

  # master {
  #     # See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
  #     new_is_master = true
  # }

  gestures = {
    workspace_swipe = "off";
  };

  misc = {
    force_default_wallpaper = -1;
  };

  # Example per-device config
  # See https://wiki.hyprland.org/Configuring/Keywords/#per-device-input-configs for more
  device = {
    name = "epic-mouse-v1";
    sensitivity = -0.5;
  };

  # Example windowrule v1
  # windowrule = float, ^(kitty)$
  # Example windowrule v2
  # windowrulev2 = float,class:^(kitty)$,title:^(kitty)$
  # See https://wiki.hyprland.org/Configuring/Window-Rules/ for more

  windowrule = [
    "float,^(Floaterm)$"
    "size 25% 30%,^(Floaterm)$"
    "move 60% 60%,^(Floaterm)$"
  ];

  windowrulev2 = [
    "float,class:^(firefox),title:^(ピクチャーインピクチャー)"
    "pin,class:^(firefox),title:^(ピクチャーインピクチャー)"
    "suppressevent maximize, class:.*"
  ];

  # See https://wiki.hyprland.org/Configuring/Keywords/ for more
  # $mainMod = SUPER
  "$mainMod" = "Alt";

  bind = [
    # Example binds, see https://wiki.hyprland.org/Configuring/Binds/ for more
    "$mainMod, Return, exec, $terminal"
    "$mainMod, q, killactive,"
    # bind = $mainMod, m, exit, 
    "$mainMod, e, exec, $fileManager"
    "$mainMod, f, togglefloating,"
    "$mainMod, f, pin,"
    "$mainMod, space, exec, $menu"
    # bind = $mainMod, P, pseudo, # dwindle
    "$mainMod, J, togglesplit," # dwindle
    "$mainMod, b, exec, $browser"

    # Move focus with mainMod + arrow keys
    "$mainMod, h, movefocus, l"
    "$mainMod, l, movefocus, r"
    "$mainMod, k, movefocus, u"
    "$mainMod, j, movefocus, d"

    # bind = $mainMod, g, movefocus, d

    # Switch workspaces with mainMod + [0-9]
    "$mainMod, 1, workspace, 1"
    "$mainMod, 2, workspace, 2"
    "$mainMod, 3, workspace, 3"
    "$mainMod, 4, workspace, 4"
    "$mainMod, 5, workspace, 5"
    "$mainMod, 6, workspace, 6"
    "$mainMod, 7, workspace, 7"
    "$mainMod, 8, workspace, 8"
    "$mainMod, 9, workspace, 9"
    "$mainMod, 0, workspace, 10"

    # Move active window to a workspace with mainMod + SHIFT + [0-9]
    "$mainMod SHIFT, 1, focusworkspaceoncurrentmonitor, 1"
    "$mainMod SHIFT, 2, focusworkspaceoncurrentmonitor, 2"
    "$mainMod SHIFT, 3, focusworkspaceoncurrentmonitor, 3"
    "$mainMod SHIFT, 4, focusworkspaceoncurrentmonitor, 4"
    "$mainMod SHIFT, 5, focusworkspaceoncurrentmonitor, 5"
    "$mainMod SHIFT, 6, focusworkspaceoncurrentmonitor, 6"
    "$mainMod SHIFT, 7, focusworkspaceoncurrentmonitor, 7"
    "$mainMod SHIFT, 8, focusworkspaceoncurrentmonitor, 8"
    "$mainMod SHIFT, 9, focusworkspaceoncurrentmonitor, 9"
    "$mainMod SHIFT, 0, focusworkspaceoncurrentmonitor, 10"

    # Example special workspace (scratchpad)
    "$mainMod, w, togglespecialworkspace, magic"
    "$mainMod SHIFT, w, movetoworkspace, special:magic"

    "$mainMod, p, workspace, +1, focuswindow"
    "$mainMod, n, workspace, -1, focuswindow"

    "$mainMod SHIFT, p, movetoworkspace, +1"
    "$mainMod SHIFT, n, movetoworkspace, -1"

    "$mainMod SHIFT, l, movewindow, r"
    "$mainMod SHIFT, h, movewindow, l"

    # Change window size
    "$mainMod ctrl, l, resizeactive, 100 100"
    "$mainMod ctrl, h, resizeactive, -100 100"

    # Screenshot
    "$mainMod SHIFT, s, exec, slurp | grim -g - - | wl-copy"
    # Take screenshot active window
    # ",Print, exec, hyprctl -j activewindow | jq -r '\"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])\"' | grim -g - - | wl-copy"
    # ",Print, exec, grim -o (hyprctl monitors -j | jq -r '.[] | select(.focused) | .name') - | wl-copy" 
    # Take screenshot active monitor
    # "$mainMod, s, exec, hyprctl -j activeworkspace | jq -r '(.monitor)' | xargs -i grim -o {} -- - | wl-copy"
    ",Print, exec, hyprctl -j activeworkspace | jq -r '(.monitor)' | xargs -i grim -o {} -- - | wl-copy"

    # Screen lock
    "Super SHIFT, l, exec, hyprlock"

    # bind = Print, exec, slurp | grim -g - - | wl-cop

    # Vim as as IME
    "$mainMod, code:34, exec, ime.sh float"
  ];

  bindm = [
    # Move/resize windows with mainMod + LMB/RMB and dragging
    "$mainMod, mouse:272, movewindow"
    "$mainMod, mouse:273, resizewindow"
  ];

  exec-once = [
    "waybar"
    "fcitx5"
    "conky"
    "swaync"
    "playerctld daemon"
    "swaybg -i ~/Pictures/wallpaper/wallpaper-1.jpg"
  ];
}
