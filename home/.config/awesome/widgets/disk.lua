-- Root filesystem: disk glyph + use % once / is LIMIT % full, hidden below. Checked every
-- 5 min. Tooltip: free space. Click: ncdu on / (this filesystem only) in a terminal.
local awful     = require("awful")
local gears     = require("gears")
local wibox     = require("wibox")
local beautiful = require("beautiful")

local LIMIT = 90 -- %

local widget = wibox.widget.textbox()
local tip = awful.tooltip { objects = { widget } }

local function check()
    awful.spawn.easy_async({ "df", "-h", "--output=pcent,avail", "/" }, function(out)
        local pct, avail = out:match("(%d+)%%%s+(%S+)")
        pct = tonumber(pct)
        widget.markup = pct and pct >= LIMIT and ('<span foreground="%s">\u{f0a0} %d%%</span>')
                                                 :format(beautiful.bg_urgent, pct) or ""
        tip.text = (avail or "?") .. " free on /"
    end)
end

widget:buttons(awful.button({}, 1, function() awful.spawn({ "alacritty", "-e", "ncdu", "-x", "/" }) end))

gears.timer { timeout = 300, autostart = true, call_now = true, callback = check }

return widget
