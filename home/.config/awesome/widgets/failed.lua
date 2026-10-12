-- Failed systemd units, system and user: warning glyph + count, hidden when there is none.
-- Click: the list. An entry shows `systemctl status` in a terminal; "reset all" forgets the
-- failures (polkit asks the password for system units). Checked every minute.
local awful     = require("awful")
local gears     = require("gears")
local wibox     = require("wibox")
local beautiful = require("beautiful")

local CHECK = "systemctl --failed --no-legend --plain | awk '{ print \"--system\", $1 }';"
           .. "systemctl --user --failed --no-legend --plain | awk '{ print \"--user\", $1 }'"

local widget = wibox.widget.textbox()
local units, menu = {}, nil

local function check()
    awful.spawn.easy_async_with_shell(CHECK, function(out)
        units = {}
        for scope, unit in out:gmatch("(%-%-%a+) (%S+)") do table.insert(units, { scope, unit }) end
        widget.markup = #units > 0 and ('<span foreground="%s">\u{f071} %d</span>')
                                       :format(beautiful.bg_urgent, #units) or ""
    end)
end

widget:buttons(awful.button({}, 1, function()
    local items = {}
    for _, u in ipairs(units) do
        table.insert(items, { u[2] .. (u[1] == "--user" and " (user)" or ""), function()
            awful.spawn({ "alacritty", "--hold", "-e", "systemctl", u[1], "status", u[2] })
        end })
    end
    table.insert(items, { "reset all", function()
        awful.spawn.easy_async_with_shell("systemctl reset-failed; systemctl --user reset-failed", check)
    end })
    if menu then menu:hide() end
    menu = awful.menu { items = items, theme = { width = beautiful.xresources.apply_dpi(300) } }
    menu:show()
end))

gears.timer { timeout = 60, autostart = true, call_now = true, callback = check }

return widget
