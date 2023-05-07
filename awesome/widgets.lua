-- Standard awesome library
local awful = require("awful")

-- Widget and layout library
local wibox = require("wibox")

---wibox2
--
-- Memory
-- Initialize widget
memwidget = wibox.widget.textbox()
-- Register widget

-- Initialize widget
memwidget2 = wibox.widget.progressbar()
-- Progressbar properties
memwidget2:set_width(50)
memwidget2:set_vertical(true)
memwidget2:set_background_color("#494B4F")
memwidget2:set_border_color(nil)
memwidget2:set_color({ type = "linear", from = { 0, 0 }, to = { 10,0 }, stops = { {0, "#AECF96"}, {0.5, "#88A175"},
                    {1, "#FF5656"}}})
-- Register widget

-- Initialize widget
cpuwidget = awful.widget.graph()
-- Graph properties
cpuwidget:set_width(50)
cpuwidget:set_background_color("#494B4F")
cpuwidget:set_color({ type = "linear", from = { 0, 0 }, to = { 10,0 }, stops = { {0, "#FF5656"}, {0.5, "#88A175"},
                {1, "#AECF96" }}})
-- Register widget

-- Initialize widget
cpuwidget2 = wibox.widget.textbox()
-- Register widget

-- wifi widget
wifiwidget = wibox.widget.textbox()

-- Possible network devices
eths = { 'enp0s31f6', 'wlp4s0' }
netwidget = wibox.widget.textbox()

-- Initialize widget battery
batwidget = wibox.widget.textbox()
