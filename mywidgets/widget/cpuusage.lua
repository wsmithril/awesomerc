-- CPU monitor
-- require
local lfs     = require("lfs")
local wibox   = require("wibox")
local utils   = require("mywidgets.utils")

-- module
local widget_pcpu = {}

-- CPU widget
local function cpu_usage()
    local fd = io.open("/proc/stat")
    local cpu_lines = { total = 0, idle = 0 }
    for l in fd:lines() do
        local idx = 0
        for num in string.gmatch(l, "[^%s]+") do
            idx = idx + 1
            if idx ~= 1 then cpu_lines.total = cpu_lines.total + tonumber(num) end
            if idx == 5 then cpu_lines.idle  = tonumber(num) end
        end
        break
    end
    fd:close()
    return cpu_lines
end

widget_pcpu.new = function (args)
    local ret  = {}
    ret.update = args.update or 3
    ret.widget = wibox.widget.textbox()
    ret.updater = function(self)
        local new_state = cpu_usage()
        local usage = 0.0
        if self.state then
            usage = usage + 1 - (new_state.idle - self.state.idle) / (new_state.total - self.state.total)
        end
        ret.widget:set_markup(string.format('<span color="%s">% 3d%%</span>',
                    utils.gradient("#50EC50", "#EC3030", 0, 1, usage), usage * 100))
        self.state = new_state
    end
    return ret
end

return widget_pcpu
-- }}}
