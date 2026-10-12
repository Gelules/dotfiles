-- Screen layouts on F7 (XF86Display): saved autorandr profiles, the ~/.screenlayout/*.sh
-- scripts, autorandr's built-in layouts, "save as..." and arandr. Saved profiles also come
-- back by themselves: autorandr's udev rule on hotplug, rc.lua's autostart at login.
local awful   = require("awful")
local naughty = require("naughty")

-- Built-in ("virtual") profiles: autorandr --load works for them too, see autorandr --help
local VIRTUAL = { "horizontal", "horizontal-reverse", "vertical", "vertical-reverse",
                  "clone-largest", "common" }

local function run(cmd) return function() awful.spawn(cmd, false) end end

local function save()
    awful.prompt.run {
        prompt       = "Save screens as: ",
        textbox      = awful.screen.focused().mypromptbox.widget,
        exe_callback = function(name)
            if name == "" or name:find("/") then return end
            awful.spawn.easy_async({ "autorandr", "--save", name, "--force" }, function(_, err, _, code)
                naughty.notify { title = "autorandr", text = code == 0 and "Saved as " .. name or err }
            end)
        end,
    }
end

local layouts = {}
for _, v in ipairs(VIRTUAL) do table.insert(layouts, { v, run({ "autorandr", "--load", v }) }) end

local menu
local function show()
    -- Rebuilt on each press: profiles and scripts may have changed since
    awful.spawn.easy_async_with_shell(
        "autorandr --list | sed 's/^/p /'; for f in ~/.screenlayout/*.sh; do [ -x \"$f\" ] && echo \"s $f\"; done",
        function(out)
            local items = {}
            for kind, value in out:gmatch("([ps]) ([^\n]+)") do
                table.insert(items, kind == "p" and { value, run({ "autorandr", "--load", value }) }
                                                 or { value:match("[^/]+$"), run({ value }) })
            end
            table.insert(items, { "autorandr layouts", layouts })
            table.insert(items, { "save as...", save })
            table.insert(items, { "arandr...", run("arandr") })
            if menu then menu:hide() end
            menu = awful.menu { items = items }
            menu:show()
        end)
end

return {
    show = show,
    keys = awful.key({}, "XF86Display", show, { description = "screen layouts", group = "screen" }),
}
