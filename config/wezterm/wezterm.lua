local wezterm = require 'wezterm';

return {
	-- window_background_image = "~/MyPictures/toutoi/95693475_p0_master1200.jpg",
	window_background_image = "/home/coma/MyPictures/toutoi/95693475_p0_master1200.jpg",
	window_background_image_hsb = {
		-- Darken the background image by reducing it to 1/3rd
		brightness = 0.15,

		-- You can adjust the hue by scaling its value.
		-- a multiplier of 1.0 leaves the value unchanged.
		-- hue = 1.0,

		-- You can adjust the saturation also.
		saturation = 1.0,
	},

	-- disable_default_key_bindings = true,
	color_scheme = "nord",
	use_ime = true,
	font_size = 12.5,
	font = wezterm.font("UDEVGothicLG-Regular"),
	Window_background_opacity = 0.85,

	hide_tab_bar_if_only_one_tab = true,
	adjust_window_size_when_changing_font_size = false,

	-- disable_default_key_bindings = true,

	-- keys = {
	-- Turn off the default CMD-m Hide action, allowing CMD-m to
	-- be potentially recognized and handled by the tab
	-- }
	keys = {
		{key="C", mods="SHIFT|CTRL", action="Copy"},
		{key="V", mods="SHIFT|CTRL", action="Paste"},

		{ key = "h", mods = "ALT|CTRL", action = wezterm.action({ MoveTabRelative = -1 }) },
		{ key = "l", mods = "ALT|CTRL", action = wezterm.action({ ActivateTabRelative = 1 }) },
		{ key = "y", mods = "ALT|CTRL", action = "ActivateCopyMode" },
		{ key = "p", mods = "ALT|CTRL", action = wezterm.action({ PasteFrom = "PrimarySelection" }) },

		{ key = "1", mods = "ALT", action = wezterm.action({ ActivateTab = 0 }) },
		{ key = "2", mods = "ALT", action = wezterm.action({ ActivateTab = 1 }) },
		{ key = "3", mods = "ALT", action = wezterm.action({ ActivateTab = 2 }) },
		{ key = "4", mods = "ALT", action = wezterm.action({ ActivateTab = 3 }) },
		{ key = "5", mods = "ALT", action = wezterm.action({ ActivateTab = 4 }) },
		{ key = "6", mods = "ALT", action = wezterm.action({ ActivateTab = 5 }) },
		{ key = "7", mods = "ALT", action = wezterm.action({ ActivateTab = 6 }) },
		{ key = "8", mods = "ALT", action = wezterm.action({ ActivateTab = 7 }) },
		{ key = "9", mods = "ALT", action = wezterm.action({ ActivateTab = 8 }) },

		{ key = "-", mods = "ALT", action = wezterm.action({ SplitVertical = { domain = "CurrentPaneDomain" } }) },
		{ key = "|", mods = "ALT", action = wezterm.action({ SplitHorizontal = { domain = "CurrentPaneDomain" } }) },

		{ key = "e", mods = "ALT", action = wezterm.action({ SpawnTab = "CurrentPaneDomain" }) },
		{ key = "q", mods = "ALT", action = wezterm.action({ CloseCurrentTab = { confirm = false } }) },
		{ key = "h", mods = "ALT|SHIFT", action = wezterm.action({ ActivateTabRelative = -1 }) },
		{ key = "l", mods = "ALT|SHIFT", action = wezterm.action({ ActivateTabRelative = 1 }) },


		{ key = "h", mods = "ALT", action = wezterm.action({ ActivatePaneDirection = "Left" }) },
		{ key = "l", mods = "ALT", action = wezterm.action({ ActivatePaneDirection = "Right" }) },
		{ key = "k", mods = "ALT", action = wezterm.action({ ActivatePaneDirection = "Up" }) },
		{ key = "j", mods = "ALT", action = wezterm.action({ ActivatePaneDirection = "Down" }) },

		{ key = "h", mods = "ALT|SHIFT|CTRL", action = wezterm.action({ AdjustPaneSize = { "Left", 1 } }) },
		{ key = "l", mods = "ALT|SHIFT|CTRL", action = wezterm.action({ AdjustPaneSize = { "Right", 1 } }) },
		{ key = "k", mods = "ALT|SHIFT|CTRL", action = wezterm.action({ AdjustPaneSize = { "Up", 1 } }) },
		{ key = "j", mods = "ALT|SHIFT|CTRL", action = wezterm.action({ AdjustPaneSize = { "Down", 1 } }) },

		{ key = " ", mods = "ALT", action = "QuickSelect" },

		{key="o", mods="ALT", action="ShowTabNavigator"},
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
