-- Power profile (power-profiles-daemon): leaf = power-saver, scales = balanced,
-- rocket = performance. Click: next profile. Hidden if the daemon is not running.
-- ponytail: polled every minute, so a `powerprofilesctl set` typed in a terminal shows up
-- to 1 min late; follow PropertiesChanged with gdbus monitor if that ever matters.
local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")

local ORDER = { "power-saver", "balanced", "performance" }
local GLYPH = { ["power-saver"] = "\u{f06c}", balanced = "\u{f24e}", performance = "\u{f135}" }

local widget = wibox.widget.textbox()
local tip = awful.tooltip { objects = { widget } }
local current

local function update()
    awful.spawn.easy_async({ "powerprofilesctl", "get" }, function(out)
        current = out:match("^[%w-]+")
        widget.text = GLYPH[current] or ""
        tip.text = current or "" -- nil would raise: daemon masked or down
    end)
end

widget:buttons(awful.button({}, 1, function()
    for i, p in ipairs(ORDER) do
        if p == current then
            -- performance only exists on some hardware (not in a VM): then go on to power-saver
            awful.spawn.easy_async_with_shell("powerprofilesctl set " .. ORDER[i % #ORDER + 1]
                                              .. " || powerprofilesctl set power-saver", update)
        end
    end
end))

gears.timer { timeout = 60, autostart = true, call_now = true, callback = update }

return widget
