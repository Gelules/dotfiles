-- Pending updates: repo (checkupdates, pacman-contrib) + AUR (paru -Qua), plus a
-- "reboot needed" glyph once the running kernel's modules were removed by an upgrade.
-- Hidden when there is nothing to do. Left click: upgrade in a terminal (re-checks
-- when it is closed). Middle click: check now. Replaces the zsh auto-upgrade at login.
local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")

local CHECK = "checkupdates; paru -Qua"
-- Automatic checks skip metered links (NM Metered: 1 = yes, 3 = guessed yes, e.g. a
-- phone hotspot): checkupdates downloads the sync DBs (~9 MB for extra.db).
local AUTO = "busctl get-property org.freedesktop.NetworkManager /org/freedesktop/NetworkManager"
          .. " org.freedesktop.NetworkManager Metered | grep -qx 'u [13]' && echo metered || { "
          .. CHECK .. "; }"

local f = io.open("/proc/sys/kernel/osrelease")
local KERNEL = f:read("l")
f:close()

local widget = wibox.widget.textbox()
local tip = awful.tooltip { objects = { widget } }

local function render(pending)
    local n = select(2, pending:gsub(" %-> ", "")) -- lines look like "pkg 1.0-1 -> 1.1-1"
    local reboot = not gears.filesystem.dir_readable("/usr/lib/modules/" .. KERNEL)
    widget.text = (n > 0 and "\u{f019} " .. n or "") .. (reboot and " \u{f021}" or "")
    tip.text = (reboot and "Kernel " .. KERNEL .. " was upgraded: reboot\n" or "") .. pending
end

local function check(auto)
    awful.spawn.easy_async_with_shell(auto and AUTO or CHECK, function(out)
        if out:find("^metered") then return end -- keep the last result
        render((out:gsub("\n$", "")))
    end)
end

widget:buttons(gears.table.join(
    awful.button({}, 1, function()
        awful.spawn.easy_async({ "alacritty", "--hold", "-e", "paru" }, function() check(false) end)
    end),
    awful.button({}, 2, function() check(false) end)))

-- First check once the network is up, then every 3 h.
gears.timer { timeout = 60, autostart = true, single_shot = true, callback = function() check(true) end }
gears.timer { timeout = 3 * 3600, autostart = true, callback = function() check(true) end }

return widget
