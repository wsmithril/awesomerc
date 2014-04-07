-- CPU monitor
-- require
local wibox   = require("wibox")
local utils   = require("mywidgets.utils")

-- module
local M = {}

-- CPU widget
local function cpu_usage()
    local fd = io.open("/proc/stat")
    ret = {}
    for l in fd:lines() do
        local cpu_id = l:match("^cpu(%d+)")
        if cpu_id then
            local idx = 0
            local idle = 0
            local total = 0
            for num in string.gmatch(l, "[^%s]+") do
                idx = idx + 1
                if idx ~= 1 then total = total + tonumber(num) end
                if idx == 5 then idle  = tonumber(num) end
            end
            ret[tonumber(cpu_id) + 1] = {idle = idle, total = total, id = cpu_id}
        end
    end
    fd:close()
    return ret
end

M.new = function (args)
    local ret  = {}

    ret.update     = args.update or 3
    ret.widget     = wibox.widget.textbox()
    ret.old_status = {}
    ret.updater = function(self)
        local status = cpu_usage()
        local lines = {}
        local old_status, usage
        for id, new_status in ipairs(status) do
            old_status = self.old_status[id]
            usage = old_status and 1 - (new_status.idle - old_status.idle) / (new_status.total - old_status.total) or 0
            table.insert(lines, string.format(' %d:<span color="%s">% 3d%%</span>', new_status.id, utils.gradient("#50EC50", "#EC3030", 0, 1, usage), usage * 100))
        end
        ret.widget:set_markup(table.concat(lines))
        self.old_status = status
    end
    return ret
end

return M
-- }}}
