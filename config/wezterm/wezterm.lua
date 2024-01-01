local wezterm = require("wezterm")
local act = wezterm.action
local home = "/home/coma/"

local config = {
  colors = {
    tab_bar = {
      background = "#1b1f2f",

      active_tab = {
        bg_color = "#44716a",
        fg_color = "#c6c8d1",
        intensity = "Normal",
        underline = "None",
        italic = false,
        strikethrough = false,
      },
    },
  },

  ssh_domains = {
    {
      name = "area149",
      remote_address = "160.251.139.143",
      username = "root",
    },
  },
  audible_bell = "Disabled",
  wsl_domains = {
    {
      name = "WSL:Manjaro",
      distribution = "Manjaro",
      default_cwd = "/home/coma/",
    },
  },

  -- window_background_opacity = 0.85,
  window_background_image_hsb = {
    -- Darken the background image by reducing it to 1/3rd
    brightness = 0.04,
    -- You can adjust the hue by scaling its value.
    -- a multiplier of 1.0 leaves the value unchanged.
    -- hue = 1.0,

    -- You can adjust the saturation also.
    saturation = 1.0,
  },

  -- disable_default_key_bindings = true,
  color_scheme = "Afterglow",
  use_ime = true,
-- <<<<<<< HEAD
  font_size = 16,
-- =======
  font = wezterm.font("UDEV Gothic NFLG"),
  -- font = wezterm.font("UDEV Gothic NF Regular"),
  -- font = wezterm.font("/home/coma/Downloads/"),

  hide_tab_bar_if_only_one_tab = true,
  adjust_window_size_when_changing_font_size = false,

  -- disable_default_key_bindings = true,

  -- keys = {
  -- Turn off the default CMD-m Hide action, allowing CMD-m to
  -- be potentially recognized and handled by the tab
  -- }

  leader = { key = "q", mods = "CTRL", timeout_milliseconds = 1000 },
  keys = {
    -- {key="C", mods="SHIFT|CTRL", action="Copy"},
    -- {key="V", mods="SHIFT|CTRL", action="Paste"},

    { key = "y", mods = "ALT|CTRL", action = "ActivateCopyMode" },

    -- { key = "p", mods = "ALT|CTRL", action = wezterm.action({ PasteFrom = "PrimarySelection" }) },

    { key = "1", mods = "ALT", action = wezterm.action({ ActivateTab = 0 }) },
    { key = "2", mods = "ALT", action = wezterm.action({ ActivateTab = 1 }) },
    { key = "3", mods = "ALT", action = wezterm.action({ ActivateTab = 2 }) },
    { key = "4", mods = "ALT", action = wezterm.action({ ActivateTab = 3 }) },
    { key = "5", mods = "ALT", action = wezterm.action({ ActivateTab = 4 }) },
    { key = "6", mods = "ALT", action = wezterm.action({ ActivateTab = 5 }) },
    { key = "7", mods = "ALT", action = wezterm.action({ ActivateTab = 6 }) },
    { key = "8", mods = "ALT", action = wezterm.action({ ActivateTab = 7 }) },
    { key = "9", mods = "ALT", action = wezterm.action({ ActivateTab = 8 }) },
    {
      key = "-",
      mods = "ALT",
      action = wezterm.action({
        SplitVertical = { domain = "CurrentPaneDomain" },
      }),
    },
    {
      key = "|",
      mods = "ALT|SHIFT",
      action = wezterm.action({
        SplitHorizontal = { domain = "CurrentPaneDomain" },
      }),
    },
    { key = "t", mods = "LEADER", action = wezterm.action({ SpawnTab = "CurrentPaneDomain" }) },
    { key = "q", mods = "LEADER", action = wezterm.action({ CloseCurrentTab = { confirm = false } }) },
    -- { key = "e", mods = "ALT", action = wezterm.action({ SpawnTab = "CurrentPaneDomain" }) },
    -- { key = "q", mods = "ALT", action = wezterm.action({ CloseCurrentTab = { confirm = false } }) },
    { key = "j", mods = "ALT", action = wezterm.action({ ActivateTabRelative = -1 }) },
    { key = "k", mods = "ALT", action = wezterm.action({ ActivateTabRelative = 1 }) },
    { key = "h", mods = "ALT", action = wezterm.action({ ActivatePaneDirection = "Left" }) },
    { key = "l", mods = "ALT", action = wezterm.action({ ActivatePaneDirection = "Right" }) },
    { key = "h", mods = "LEADER", action = wezterm.action({ AdjustPaneSize = { "Left", 1 } }) },
    { key = "l", mods = "LEADER", action = wezterm.action({ AdjustPaneSize = { "Right", 1 } }) },
    { key = "k", mods = "LEADER", action = wezterm.action({ AdjustPaneSize = { "Up", 1 } }) },
    { key = "j", mods = "LEADER", action = wezterm.action({ AdjustPaneSize = { "Down", 1 } }) },
    -- { key = " ", mods = "ALT", action = "QuickSelect" },
    { key = "o", mods = "ALT", action = act.ShowTabNavigator },
}}

if wezterm.target_triple == "x86_64-pc-windows-msvc" then
  config.default_prog = { "wsl.exe", "--distribution", "Manjaro", "--exec", "/bin/fish", "-l" }
  config.window_background_image = "C:/Users/Coma/wallpapelar/sarah-sheedy-co1YPSazn70-unsplash.jpg"
else
  config.default_prog = { "fish" }
  config.window_background_image = home .. "Pictures/wallpapelar/benjamin-hersh-_69DlG4rMm4-unsplash.jpg"
end

return config
