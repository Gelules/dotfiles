-- Session: power menu, lock (also before suspend/lid close), caffeine, do-not-disturb.
-- Needs xss-lock (new) + i3lock (installed). Caffeine replaces the zsh "blackscreen".
local awful     = require("awful")
local wibox     = require("wibox")
local naughty   = require("naughty")
local beautiful = require("beautiful")

-- awful.spawn.once only tracks windows, not daemons: pgrep guard so restarts don't duplicate it.
-- i3lock -e: an empty Enter is not sent to PAM (no faillock strikes).
awful.spawn.with_shell("pgrep -u \"$USER\" -x xss-lock >/dev/null"
                       .. " || exec xss-lock --transfer-sleep-lock -- i3lock -n -e -c 000000")

-- false = no startup notification, else the cursor stays "busy" for windowless commands.
local function run(cmd) return function() awful.spawn(cmd, false) end end
local lock = run("loginctl lock-session") -- xss-lock answers logind's Lock signal

local menu = awful.menu { items = {
    { "lock",      lock },
    { "suspend",   run("systemctl suspend") },
    { "hibernate", run("systemctl hibernate") },
    { "log out",   function() awesome.quit() end },
    { "reboot",    run("systemctl reboot") },
    { "power off", run("systemctl poweroff") },
} }

local power = wibox.widget.textbox("\u{f011}")
power:buttons(awful.button({}, 1, function() menu:toggle() end))

-- A glyph in the "active" colour means "something is switched off", so it can't be forgotten.
local function paint(w, glyph, active)
    w.markup = active and ('<span foreground="' .. (beautiful.bg_urgent or "#ffffff") .. '">'
                           .. glyph .. "</span>") or glyph
end

-- Caffeine: no blanking, no DPMS, no idle lock. State read back from X at startup/restart.
local caffeine, awake = wibox.widget.textbox(), false
awful.spawn.easy_async({ "xset", "q" }, function(out)
    awake = out:find("DPMS is Disabled") ~= nil
    paint(caffeine, "\u{f0f4}", awake)
end)
caffeine:buttons(awful.button({}, 1, function()
    awake = not awake
    awful.spawn(awake and "xset s off -dpms" or "xset s default +dpms", false)
    paint(caffeine, "\u{f0f4}", awake)
end))

-- Do not disturb: naughty queues notifications while suspended, shows them on resume.
local dnd = wibox.widget.textbox("\u{f0f3}")
dnd:buttons(awful.button({}, 1, function()
    naughty.toggle()
    paint(dnd, naughty.is_suspended() and "\u{f1f6}" or "\u{f0f3}", naughty.is_suspended())
end))

return {
    power = power,
    menu = menu, -- also bound to Mod4+Shift+q in rc.lua (one power menu, not two)
    caffeine = caffeine,
    dnd = dnd,
    keys = awful.key({ "Mod4", "Shift" }, "Escape", lock, { description = "lock screen", group = "awesome" }),
}
