-- Battery: level glyph + %, bolt while charging, red + sticky warning at LOW %.
-- Reads sysfs every 30 s (no extra package). Tooltip: time left / to full.
-- Glyphs = FontAwesome 4.7 code points: rendered today by awesome-terminal-fonts
-- (fontconfig fallback), same code points in any Nerd Font.
-- ponytail: 30 s poll, so plugging the charger shows up to 30 s late;
-- switch to lgi UPowerGlib device "notify" signals if that ever matters.
local awful     = require("awful")
local gears     = require("gears")
local wibox     = require("wibox")
local naughty   = require("naughty")
local beautiful = require("beautiful")

local BAT = "/sys/class/power_supply/BAT0/"
local LOW = 15 -- %. upowerd still does its CriticalPowerAction at 2 % (/etc/UPower/UPower.conf)
local LEVELS = { "\u{f244}", "\u{f243}", "\u{f242}", "\u{f241}", "\u{f240}" } -- empty .. full

local function read(file)
    local f = io.open(BAT .. file)
    if not f then return nil end
    local s = f:read("l")
    f:close()
    return s
end

local widget = wibox.widget.textbox()
local warned = false

local function update()
    local cap, status = tonumber(read("capacity")), read("status")
    if not cap then widget.text = "" return end -- no BAT0 (other machine): hide, don't break rc.lua
    local text = LEVELS[math.min(cap // 20 + 1, 5)] .. (status == "Charging" and "\u{f0e7}" or "")
                 .. " " .. cap .. "%"
    local low = status == "Discharging" and cap <= LOW
    widget.markup = low and ('<span foreground="' .. (beautiful.bg_urgent or "#ffffff") .. '">'
                             .. text .. "</span>") or text
    if low and not warned then
        naughty.notify { preset = naughty.config.presets.critical,
                         title = "Battery low", text = cap .. "% left, plug the charger" }
    end
    warned = low
end

awful.tooltip {
    objects = { widget },
    timer_function = function()
        local status = read("status") or "Unknown"
        local e, p = tonumber(read("energy_now")), tonumber(read("power_now"))
        if not (e and p and p > 0) then return status end -- Full / Not charging / idle
        local full = tonumber(read("energy_full")) or e
        local min = math.floor((status == "Charging" and (full - e) or e) / p * 60)
        return string.format("%s, %d:%02d %s", status, min // 60, min % 60,
                             status == "Charging" and "to full" or "left")
    end,
}

gears.timer { timeout = 30, autostart = true, call_now = true, callback = update }

return widget
