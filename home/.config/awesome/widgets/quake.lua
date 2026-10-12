-- Drop-down terminal on Mod4+² (keycode 49, left of 1): an alacritty over the top HEIGHT of
-- the focused screen, on every tag, out of the tasklist. Hiding it keeps its shell running.
local awful = require("awful")

local CLASS  = "quake" -- alacritty --class: WM_CLASS, matched by the rule below
local HEIGHT = 0.4     -- of the screen's work area

local spawning = false -- a 2nd press before the window maps must not start a 2nd terminal
-- Kept on the window: awesome.restart() would show a hidden terminal again
awesome.register_xproperty("quake_hidden", "boolean")

local function place(c)
    local wa = c.screen.workarea
    c:geometry { x = wa.x, y = wa.y, width = wa.width - 2 * c.border_width,
                 height = math.floor(wa.height * HEIGHT) }
end

local function toggle()
    for _, c in ipairs(client.get()) do
        if c.class == CLASS then
            local s = awful.screen.focused()
            if c.hidden or client.focus ~= c or c.screen ~= s then -- shown elsewhere: bring it here
                c.hidden = false
                c.screen = s -- not move_to_screen: it would warp the pointer
                place(c)
                c:emit_signal("request::activate", "quake", { raise = true })
            else
                c.hidden = true
            end
            c:set_xproperty("quake_hidden", c.hidden)
            return
        end
    end
    if not spawning then
        -- A pid, not an error. Cleared by the rule below, or here if alacritty dies before its window shows
        spawning = type(awful.spawn.with_line_callback({ "alacritty", "--class", CLASS },
                                                       { exit = function() spawning = false end })) == "number"
    end
end

return {
    rule = { rule = { class = "^" .. CLASS .. "$" }, -- rules match patterns: else "vkquake" too
             properties = { floating = true, ontop = true, sticky = true, skip_taskbar = true,
                            size_hints_honor = false, placement = place },
             callback = function(c)
                 spawning = false
                 c.hidden = c:get_xproperty("quake_hidden") == true
             end },
    keys = awful.key({ "Mod4" }, "#49", toggle, { description = "drop-down terminal (the ² key)", group = "launcher" }),
}
