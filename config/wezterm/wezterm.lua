local wezterm = require 'wezterm';

return {
  color_scheme = "nord",
  use_ime = true, -- wezは日本人じゃないのでこれがないとIME動かない
  font_size = 12.5,
  font = wezterm.font("Cica"),
  window_background_opacity = 0.85,

  -- disable_default_key_bindings = true,

   -- keys = {
    -- Turn off the default CMD-m Hide action, allowing CMD-m to
    -- be potentially recognized and handled by the tab
  -- }
  keys = {
    {key="v", mods="CTRL", action="Paste"},
    -- {key="t", mods="CTRL", action="CurrentPaneDomain"}
  },

  -- Middle mouse button pastes the clipboard.
  -- Note that this is the default so you needn't copy this.
  mouse_bindings = {
    {
      event={Up={streak=1, button="Middle"}},
      mods="NONE",
      action="Paste",
    },
  }
}
