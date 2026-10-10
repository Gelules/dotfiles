-- "Stencil": awesome 4.3 theme. Black and greys, white as the only accent, to extend
-- wallpaper-black.png (a pure grayscale image) instead of fighting it.
-- Target: ~/.config/awesome/theme.lua, next to the wallpaper (no /home path).
local theme_assets = require("beautiful.theme_assets")
local dpi = require("beautiful.xresources").apply_dpi -- follows Xft.dpi (~/.Xresources)
local gfs = require("gears.filesystem")
local gshape = require("gears.shape")

local p = {
    void    = "#000000", -- wallpaper, letterbox, lock screen, text on white
    ink     = "#0c0c0c", -- terminal background, hotkeys popup
    surface = "#141414", -- wibar, menus, notifications, tooltips
    raised  = "#1f1f1f", -- focused task / titlebar
    line    = "#2e2e2e", -- inactive borders, popup borders, slider track
    mute    = "#6e6e6e", -- empty tags, secondary text, urgent tag
    ash     = "#a8a8a8", -- normal text
    text    = "#d4d4d4", -- body text
    paper   = "#ffffff", -- the only accent: focus, selection, handle, alerts
}

local theme = { palette = p } -- custom key: beautiful.palette.* in widgets

theme.font       = "Comic Code 10" -- Pango falls back to sans if the font is missing
theme.wallpaper  = gfs.get_configuration_dir() .. "wallpaper-black.png"
theme.icon_theme = "Papirus-Dark"  -- menubar/app icons; unset = Adwaita

theme.bg_normal   = p.surface
theme.bg_focus    = p.raised
theme.bg_urgent   = p.paper -- widgets use bg_urgent as the alert text colour
theme.bg_minimize = p.surface -- minimized tasks: dimmed text, no black hole
theme.bg_systray  = p.surface -- must equal the wibar bg
theme.fg_normal   = p.ash
theme.fg_focus    = p.paper
theme.fg_urgent   = p.void -- text on bg_urgent (urgent tasks, critical notifications)
theme.fg_minimize = p.mute

-- Clients. Gaps only show in tiled layouts, not in floating.
theme.useless_gap           = dpi(5)
theme.border_width          = 2 -- px: dpi(2) would round to 3 at 120 dpi
theme.border_normal         = p.line
theme.border_focus          = p.paper
theme.border_marked         = p.ash
theme.maximized_hide_border = true

-- Wibar. 4.3 has no wibar margins (awesome-git only): a transparent X border
-- as wide as the gap makes it float, and the shape rounds the visible part
-- with radius (shape radius - border), see wibox:_apply_shape() in 4.3.
theme.wibar_height         = dpi(24)
theme.wibar_bg             = p.surface
theme.wibar_fg             = p.ash
theme.wibar_border_width   = theme.useless_gap
theme.wibar_border_color   = "#00000000"
theme.wibar_shape          = function(cr, w, h)
    gshape.rounded_rect(cr, w, h, theme.useless_gap + dpi(6))
end
theme.systray_icon_spacing = dpi(6)

-- Taglist: white = where you are, grey = look here (urgent), dim text = empty.
theme.taglist_bg_focus    = p.paper
theme.taglist_fg_focus    = p.void
theme.taglist_bg_urgent   = p.mute
theme.taglist_fg_urgent   = p.paper
theme.taglist_fg_occupied = p.text
theme.taglist_fg_empty    = p.mute
theme.taglist_spacing     = dpi(2)

theme.tasklist_bg_focus        = p.raised
theme.tasklist_fg_focus        = p.paper
theme.tasklist_disable_icon    = true -- no coloured app icons in a grey bar
theme.tasklist_plain_task_name = true -- drop the [F]/[M] state prefixes

-- Titlebars (floating-rule clients and dialogs only, see rc.lua). The stock buttons
-- are already #b3b3b3 (normal) / #e6e6e6 (focus): grey fits, no recolour.
theme.titlebar_bg_normal = p.surface
theme.titlebar_bg_focus  = p.raised
theme.titlebar_fg_normal = p.mute
theme.titlebar_fg_focus  = p.paper
local tb = gfs.get_themes_dir() .. "default/titlebar/"
for _, s in ipairs({ "normal", "focus" }) do
    for _, b in ipairs({ "close", "minimize" }) do
        theme["titlebar_" .. b .. "_button_" .. s] = tb .. b .. "_" .. s .. ".png"
    end
    for _, b in ipairs({ "ontop", "sticky", "floating", "maximized" }) do
        for _, a in ipairs({ "active", "inactive" }) do
            theme["titlebar_" .. b .. "_button_" .. s .. "_" .. a] =
                tb .. b .. "_" .. s .. "_" .. a .. ".png"
        end
    end
end

-- Layout icons: stock white ones, recoloured to the text grey.
for _, l in ipairs({ "fairh", "fairv", "floating", "magnifier", "max", "fullscreen",
                     "tilebottom", "tileleft", "tile", "tiletop", "spiral", "dwindle",
                     "cornernw", "cornerne", "cornersw", "cornerse" }) do
    theme["layout_" .. l] = gfs.get_themes_dir() .. "default/layouts/" .. l .. "w.png"
end
theme_assets.recolor_layout(theme, p.ash)

-- Popups. picom rounds and shadows them, so no awesome shapes here
-- (awesome shapes are 1-bit, picom's corners are anti-aliased).
theme.menu_height       = dpi(24)
theme.menu_width        = dpi(180)
theme.menu_border_width = dpi(1)
theme.menu_border_color = p.line
theme.menu_bg_focus     = p.paper
theme.menu_fg_focus     = p.void
theme.awesome_icon      = theme_assets.awesome_icon(theme.menu_height, p.paper, p.void)

theme.tooltip_bg           = p.surface
theme.tooltip_fg           = p.text
theme.tooltip_border_width = dpi(1)
theme.tooltip_border_color = p.line

-- naughty 4.3 only reads notification_border_width / _margin if
-- naughty.config.defaults.* are pointed at them (see rc.lua).
theme.notification_bg           = p.surface
theme.notification_fg           = p.text
theme.notification_border_width = dpi(1)
theme.notification_border_color = p.line
theme.notification_margin       = dpi(12)
theme.notification_max_width    = dpi(420)
theme.notification_icon_size    = dpi(48) -- some apps send huge icons

-- Group label colours of this popup come from xrdb color1..15 (~/.Xresources).
theme.hotkeys_bg               = p.ink
theme.hotkeys_fg               = p.text
theme.hotkeys_border_width     = dpi(1)
theme.hotkeys_border_color     = p.line
theme.hotkeys_modifiers_fg     = p.mute
theme.hotkeys_label_bg         = p.paper
theme.hotkeys_label_fg         = p.void -- group labels use xrdb colors up to white: black text
theme.hotkeys_font             = "Comic Code Bold 10"
theme.hotkeys_description_font = "Comic Code 9"
theme.hotkeys_group_margin     = dpi(12)

-- For the volume popup slider. 4.3 sliders have one bar colour (no "filled"
-- part: slider_bar_active_color is awesome-git only).
theme.slider_bar_color    = p.line
theme.slider_bar_height   = dpi(4)
theme.slider_bar_shape    = gshape.rounded_bar
theme.slider_handle_color = p.paper
theme.slider_handle_width = dpi(14)
theme.slider_handle_shape = gshape.circle

return theme
