-- Namespace
widget_cpu = {}

-- requires
local wibox = require("wibox")
local utils = require("mywidgets.utils")

-- CPU temperature widget
widget_cpu.new = function(args)
    local ret = {}
    ret.widget = wibox.widget.textbox()
    ret.update = args.update or 3
    ret.updater = function(self)
        local fd = io.open("/sys/class/thermal/thermal_zone0/temp")
        local t  = tonumber(fd:read("*a")) / 1000
        fd:close()
        self.widget:set_markup(string.format('<span color="%s">% 3d</span>°C',
            utils.gradient("#2020EC", "#EC2020", 50, 95, t), t))
    end
    return ret
end

return widget_cpu
