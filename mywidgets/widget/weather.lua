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
        local str = run_and_wait("python " .. awful.util.getdir("config") .. "/weather.py " .. self.city)
        if resp ~= "None" then
            self.widget:set_text("Outdoor:" .. (str:match("Temperature: (-?%d+)%D*")) ..  "°C")
            self.tooltip:set_text(str)
        else
            self.widget:set_text("Weather: N/A")
            self.tooltip:set_text("Fail to get weather")
        end
    end
    return ret
end

return weather
