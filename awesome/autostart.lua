-- Standard awesome library
local spawn = require("awful.spawn")

-- Startup programs
-- Programs starting before spawn_with_shell
--
-- Network applet
spawn.with_shell("sleep 3; nm-applet")

-- Power management
spawn.with_shell("sleep 3; xfce4-power-manager")

-- Volume icon
spawn.with_shell("sleep 3; volumeicon")

-- Start Conky
spawn.with_shell("conky -c /home/jules/.config/awesome/conky/conky_simple/conkyrc")
