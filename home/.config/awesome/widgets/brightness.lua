-- Backlight: click the sun for a slider, scroll on it for +/-5 %, XF86MonBrightness keys.
-- Writes through logind's SetBrightness (busctl ships with systemd): no brightnessctl,
-- no udev rule, no video group. Reads the level from sysfs (no process).
local awful     = require("awful")
local gears     = require("gears")
local wibox     = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local DEV = "intel_backlight" -- ls /sys/class/backlight
local SYS = "/sys/class/backlight/" .. DEV .. "/"

local function read(file)
    local f = io.open(SYS .. file)
    if not f then return nil end
    local n = tonumber(f:read("l"))
    f:close()
    return n
end

local max = read("max_brightness")
if not max then return { widget = wibox.widget.textbox(), keys = {} } end -- other machine: don't break rc.lua

local function percent() return math.floor((read("brightness") or 0) * 100 / max + 0.5) end

local label = wibox.widget.textbox()
label.forced_width = dpi(48) -- fixed, so the slider doesn't shift while dragging
local slider = wibox.widget {
    widget = wibox.widget.slider, forced_width = dpi(160), forced_height = dpi(20),
    bar_height = beautiful.slider_bar_height or dpi(4), -- 4.3 default = full widget height
}

local syncing = false -- true while we move the slider ourselves
local function refresh()
    local pct = percent()
    label.text = pct .. "%"
    if mousegrabber.isrunning() then return end -- never move the handle under a drag
    syncing = true
    slider.value = pct
    syncing = false
end

-- One busctl in flight; the latest requested level wins (async spawns can finish out of order).
local busy, want, inflight
local function set(pct)
    want = math.floor(math.max(1, math.min(100, pct))) -- floor at 1 %: 0 turns some panels fully off
    if busy then return end
    busy, inflight, want = true, want, nil
    awful.spawn.easy_async({ "busctl", "call", "org.freedesktop.login1", "/org/freedesktop/login1/session/auto",
                             "org.freedesktop.login1.Session", "SetBrightness", "ssu", "backlight", DEV,
                             tostring(math.floor(inflight * max / 100)) }, function()
        busy, inflight = false, nil
        if want then set(want) else refresh() end
    end)
end
local function step(delta) set((want or inflight or percent()) + delta) end

slider:connect_signal("property::value", function()
    if syncing then return end
    label.text = math.max(1, slider.value) .. "%"
    set(slider.value)
end)

local scroll = gears.table.join(awful.button({}, 4, function() step(5) end),
                                awful.button({}, 5, function() step(-5) end))
local row = wibox.widget {
    wibox.widget.textbox("\u{f185}"), label, slider,
    spacing = dpi(8), layout = wibox.layout.fixed.horizontal,
}
row:buttons(scroll)
local popup = awful.popup {
    widget = { row, margins = dpi(10), widget = wibox.container.margin },
    visible = false, ontop = true, preferred_positions = "bottom",
    border_width = dpi(1), border_color = beautiful.border_normal,
}

local widget = wibox.widget.textbox("\u{f185}")
widget:buttons(gears.table.join(
    -- geo = the widget geometry from awful.button (4.3's move_next_to(nil) keeps the last position)
    awful.button({}, 1, function(geo)
        if popup.visible then popup.visible = false else refresh(); popup:move_next_to(geo) end
    end),
    scroll))

return {
    widget = widget,
    keys = gears.table.join(
        awful.key({}, "XF86MonBrightnessUp", function() step(5) end, { description = "brightness +5%", group = "screen" }),
        awful.key({}, "XF86MonBrightnessDown", function() step(-5) end, { description = "brightness -5%", group = "screen" })),
}
