-- Anomalies: CPU, RAM and temperature. Shows only what is above its LIMIT (a build on all
-- cores, a memory leak, a fan problem), hidden otherwise. Click: all three readings and htop.
-- Reads /proc and sysfs every 5 s: no process, no package.
local awful     = require("awful")
local gears     = require("gears")
local wibox     = require("wibox")
local beautiful = require("beautiful")

-- Calibration knobs. temp: coretemp's "Package id 0", where this Meteor Lake throttles at 110 °C
local LIMIT = { cpu = 90, ram = 90, temp = 90 } -- %, %, °C

local function read(path)
    local f = io.open(path)
    if not f then return nil end
    local s = f:read("a")
    f:close()
    return s
end

-- hwmonN numbers change between boots: find coretemp by name
local TEMP
for i = 0, 31 do
    local dir = "/sys/class/hwmon/hwmon" .. i .. "/"
    if (read(dir .. "name") or ""):match("^coretemp") then TEMP = dir .. "temp1_input" break end
end

local widget = wibox.widget.textbox()
local now = {}
local prev_total, prev_idle = 0, 0

local function update()
    local fields = {}
    for n in (read("/proc/stat") or ""):match("^cpu +([^\n]*)"):gmatch("%d+") do
        table.insert(fields, tonumber(n))
    end
    local total, idle = 0, fields[4] + fields[5] -- idle + iowait
    for i = 1, 8 do total = total + fields[i] end -- user .. steal (guest is already in user)
    if total > prev_total then
        now.cpu = math.floor(100 * (1 - (idle - prev_idle) / (total - prev_total)) + 0.5)
    end
    prev_total, prev_idle = total, idle

    local mem = read("/proc/meminfo") or ""
    local mtotal, avail = tonumber(mem:match("MemTotal: +(%d+)")), tonumber(mem:match("MemAvailable: +(%d+)"))
    now.ram = math.floor(100 * (1 - avail / mtotal) + 0.5)
    now.temp = TEMP and math.floor((tonumber(read(TEMP)) or 0) / 1000 + 0.5)

    local parts = {}
    if (now.cpu or 0) >= LIMIT.cpu then table.insert(parts, "CPU " .. now.cpu .. "%") end
    if now.ram >= LIMIT.ram then table.insert(parts, "RAM " .. now.ram .. "%") end
    if (now.temp or 0) >= LIMIT.temp then table.insert(parts, now.temp .. "°C") end
    widget.markup = #parts > 0 and ('<span foreground="%s">\u{f21e} %s</span>')
                                   :format(beautiful.bg_urgent, table.concat(parts, " ")) or ""
end

local menu
widget:buttons(awful.button({}, 1, function()
    local htop = function() awful.spawn({ "alacritty", "-e", "htop" }) end
    if menu then menu:hide() end
    menu = awful.menu { items = {
        { "CPU " .. (now.cpu or "?") .. " %", htop },
        { "RAM " .. now.ram .. " %", htop },
        { "Temperature " .. (now.temp or "?") .. " °C", htop },
        { "htop", htop },
    } }
    menu:show()
end))

gears.timer { timeout = 5, autostart = true, call_now = true, callback = update }

return widget
