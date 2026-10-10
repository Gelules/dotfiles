-- PipeWire volume widget for awesome 4.3: wibar icon + popup with output/mic sliders.
-- Needs wpctl (wireplumber) and pactl (libpulse, pulled in by pipewire-pulse).
-- Glyphs are Font Awesome 4 code points, like the other widgets/*.lua: drawn today by
-- awesome-terminal-fonts, and by ttf-nerd-fonts-symbols (same code points).
-- Slider looks come from theme.lua (beautiful.slider_*).
-- Usage: local volume = require("widgets.volume")  -- after beautiful.init()
local M = {}

-- "Volume: 0.40 [MUTED]" -> 40, true ; nil when wpctl printed nothing useful
function M._parse(out)
    local v = out and out:match("^Volume:%s*(%d+%.?%d*)")
    if not v then return nil end
    return math.floor(tonumber(v) * 100 + 0.5), out:find("[MUTED]", 1, true) ~= nil
end

if not awesome then return M end -- plain Lua (tests): parser only

local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local sink = { id = "@DEFAULT_AUDIO_SINK@", pct = 0, muted = false }
local source = { id = "@DEFAULT_AUDIO_SOURCE@", pct = 0, muted = false, mic = true }

local function icon(d) -- FA4: microphone(-slash), volume-off / -down / -up
    if d.mic then return d.muted and "\u{f131}" or "\u{f130}" end
    return d.muted and "\u{f026}" or d.pct < 50 and "\u{f027}" or "\u{f028}"
end
local function alert(s) return ('<span foreground="%s">%s</span>'):format(beautiful.bg_urgent or "#ffffff", s) end
local function text(d) local t = icon(d) .. " " .. d.pct .. "%" return d.muted and alert(t) or t end

M.widget = wibox.widget.textbox()

local function render()
    sink.label.markup, source.label.markup = text(sink), text(source)
    -- wibar: output volume, plus a red mic-off glyph while the mic is muted
    M.widget.markup = " " .. text(sink) .. (source.muted and " " .. alert(icon(source)) or "") .. " "
end

local syncing = false -- true while we move a slider ourselves
local timer -- debounce: bursts of events -> one refresh
local function refresh()
    -- A slider drag holds the mousegrabber: keep the timer ticking, refresh after the drag.
    -- (mouse.is_left_mouse_button_pressed is always nil in 4.3)
    if mousegrabber.isrunning() then return end
    timer:stop()
    for _, d in ipairs({ sink, source }) do
        awful.spawn.easy_async({ "wpctl", "get-volume", d.id }, function(out)
            local pct, muted = M._parse(out)
            if not pct or d.busy or d.want then return end -- no data, or our own set in flight
            d.pct, d.muted = pct, muted
            syncing = true
            d.slider.value = math.min(pct, 100)
            syncing = false
            render()
        end)
    end
end
timer = gears.timer { timeout = 0.1, callback = refresh }
local function sync() timer:again() end

local function run(...) awful.spawn.easy_async({ "wpctl", ... }, sync) end

function M.change(delta)
    run("set-volume", "-l", "1.0", sink.id, math.abs(delta) .. "%" .. (delta < 0 and "-" or "+"))
end
function M.toggle_mute() run("set-mute", sink.id, "toggle") end
function M.toggle_mic_mute() run("set-mute", source.id, "toggle") end

-- One wpctl in flight per device; the latest slider value wins (async spawns can finish out of order).
local function push(d)
    if d.busy or not d.want then return end
    local cmd = { "wpctl", "set-volume", d.id, d.want .. "%" }
    d.busy, d.want = true, nil
    awful.spawn.easy_async(cmd, function()
        d.busy = false
        if d.want then push(d) else sync() end
    end)
end

local function row(d, mute)
    d.label = wibox.widget.textbox()
    d.label.forced_width = dpi(72) -- fixed, so the slider doesn't shift while dragging
    d.label:buttons(awful.button({}, 1, mute))
    d.slider = wibox.widget {
        widget = wibox.widget.slider, forced_width = dpi(160), forced_height = dpi(20),
        bar_height = beautiful.slider_bar_height or dpi(4), -- 4.3 default = full widget height
    }
    d.slider:connect_signal("property::value", function(s)
        if syncing then return end
        d.pct, d.want = s.value, s.value
        render()
        push(d)
    end)
    return { d.label, d.slider, spacing = dpi(8), layout = wibox.layout.fixed.horizontal }
end

local mixer = wibox.widget.textbox("\u{f1de} Mixer (apps, devices)")
local popup = awful.popup {
    widget = {
        {
            row(sink, M.toggle_mute), row(source, M.toggle_mic_mute), mixer,
            spacing = dpi(8), layout = wibox.layout.fixed.vertical,
        },
        margins = dpi(10), widget = wibox.container.margin,
    },
    visible = false, ontop = true, preferred_positions = "bottom",
    border_width = dpi(1), border_color = beautiful.border_normal,
}
mixer:buttons(awful.button({}, 1, function()
    popup.visible = false
    awful.spawn("pavucontrol")
end))

M.widget:buttons(gears.table.join(
    -- geo = the widget geometry from awful.button. 4.3's move_next_to(nil) does NOT follow
    -- the mouse (it keeps the last position), so this toggle is not exported for keys.
    awful.button({}, 1, function(geo)
        if popup.visible then popup.visible = false else popup:move_next_to(geo) end
    end),
    awful.button({}, 2, M.toggle_mute),
    awful.button({}, 3, function() awful.spawn("pavucontrol") end),
    awful.button({}, 4, function() M.change(5) end),
    awful.button({}, 5, function() M.change(-5) end)))
render()

-- Follow changes made elsewhere (keys, pavucontrol, bluetooth sink switch...).
-- Filter matters: every wpctl call emits 'client' events, refreshing on them would loop.
local sub_pid
local function subscribe()
    -- LC_ALL=C: pactl's event lines are gettext-translated
    sub_pid = awful.spawn.with_line_callback({ "env", "LC_ALL=C", "pactl", "subscribe" }, {
        stdout = function(line)
            local what = line:match(" on (%a+) #")
            if what == "sink" or what == "source" or what == "server" then sync() end
        end,
        exit = function()
            sub_pid = nil
            gears.timer.start_new(5, subscribe) -- pipewire-pulse restarted or not up yet
        end,
    })
    sync()
end
subscribe()
-- awesome.restart() re-runs rc.lua: don't leave the old subscriber behind
awesome.connect_signal("exit", function()
    if type(sub_pid) == "number" then awesome.kill(sub_pid, 15) end -- SIGTERM
end)

return M
