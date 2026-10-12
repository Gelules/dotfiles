-- Now playing (MPRIS: Firefox, VLC, Spotify...): play/pause glyph + "artist - title" of the
-- most recently updated player, cut at MAX_WIDTH, hidden when nothing plays or pauses.
-- Click: play/pause, middle: previous, right: next; also the XF86Audio media keys.
-- Commands go to playerctld (playerctl package, started by D-Bus on first use): it keeps
-- track of the last player used, so they don't hit a forgotten paused tab instead. The
-- display doesn't go through it: it misses a player's first track (it asks too early).
local awful     = require("awful")
local gears     = require("gears")
local wibox     = require("wibox")
local beautiful = require("beautiful")

local MAX_WIDTH = beautiful.xresources.apply_dpi(250) -- longer titles end in "..." (tooltip: all)

local function ctl(cmd) return function() awful.spawn({ "playerctl", "-p", "playerctld", cmd }, false) end end

local label = wibox.widget.textbox() -- plain .text: titles may contain & and <
local widget = wibox.container.constraint(label, "max", MAX_WIDTH)
local tip = awful.tooltip { objects = { label } }
widget:buttons(gears.table.join(
    awful.button({}, 1, ctl("play-pause")),
    awful.button({}, 2, ctl("previous")),
    awful.button({}, 3, ctl("next"))))

local GLYPH = { Playing = "\u{f04b}", Paused = "\u{f04c}" }
local pid
local function follow()
    pid = awful.spawn.with_line_callback({ "playerctl", "--follow", "metadata",
                                           "--format", "{{status}}\t{{artist}}\t{{title}}" }, {
        stdout = function(line)
            local status, artist, title = line:match("^(%a*)\t(.-)\t(.*)$")
            local text = artist and artist ~= "" and artist .. " - " .. title or title or ""
            label.text = GLYPH[status] and GLYPH[status] .. " " .. text or ""
            tip.text = text
        end,
        exit = function()
            pid = nil
            gears.timer.start_new(5, follow) -- D-Bus restarted: follow again
        end,
    })
end
follow()
-- awesome.restart() re-runs rc.lua: don't leave the old follower behind
awesome.connect_signal("exit", function()
    if type(pid) == "number" then awesome.kill(pid, 15) end
end)

return {
    widget = widget,
    keys = gears.table.join(
        awful.key({}, "XF86AudioPlay", ctl("play-pause"), { description = "play/pause", group = "audio" }),
        awful.key({}, "XF86AudioPause", ctl("pause"), { description = "pause", group = "audio" }),
        awful.key({}, "XF86AudioStop", ctl("stop"), { description = "stop", group = "audio" }),
        awful.key({}, "XF86AudioNext", ctl("next"), { description = "next track", group = "audio" }),
        awful.key({}, "XF86AudioPrev", ctl("previous"), { description = "previous track", group = "audio" })),
}
