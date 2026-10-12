-- Night light: gammastep warms the screen from sunset to sunrise (~/.config/gammastep/config.ini).
-- Click: on/off (dimmed moon = off). "Off" lasts until you log out: it is kept in a property
-- of the root window, which survives Mod4+Ctrl+r but not a new X session.
local awful     = require("awful")
local wibox     = require("wibox")
local beautiful = require("beautiful")

awesome.register_xproperty("nightlight_off", "boolean")

local widget = wibox.widget.textbox()

local function set(on)
    awesome.set_xproperty("nightlight_off", not on)
    -- gammastep puts the normal colours back when it is stopped
    awful.spawn.with_shell(on and "pgrep -u \"$USER\" -x gammastep >/dev/null || exec gammastep"
                               or "pkill -u \"$USER\" -x gammastep")
    widget.markup = on and "\u{f186}"
                       or ('<span foreground="%s">\u{f186}</span>'):format(beautiful.palette.mute)
end

set(not awesome.get_xproperty("nightlight_off"))
widget:buttons(awful.button({}, 1, function() set(awesome.get_xproperty("nightlight_off")) end))

return widget
