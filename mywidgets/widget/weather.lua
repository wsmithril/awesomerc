-- Weather widget
-- Namespaces
local weather = {}

-- requires
local awful = require("awful")
local wibox = require("wibox")
local utils = require("mywidgets.utils")

local function run_and_wait(cmd)
    local fd  = io.popen(cmd)
    local str = fd:read("*all")
    fd:close()
    return str
end

weather.new = function(args)
    local ret = {}
    ret.update  = args.update or 30 * 60
    ret.city    = args.city or "2151330"
    ret.widget  = wibox.widget.textbox()
    ret.tooltip = awful.tooltip({ objects = { ret.widget }})
    ret.updater = function(self)
        local str = awful.util.spawn("python " .. awful.util.getdir("config") .. "/weather.py " .. self.city)
        self.widget:set_text("Outdoor:...")
        self.tooltip:set_text("Getting Weather information")
    end
    globals.widget_weather  = ret.widget
    globals.tooltip_weather = ret.tooltip
    return ret
end

return weather
