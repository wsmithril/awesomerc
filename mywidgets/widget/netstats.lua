-- net stats widgets

-- requires
local lfs     = require("lfs")
local wibox   = require("wibox")
local utils   = require("mywidgets.utils")

-- module
local widget_netstat = {}

--  Network usage widget {{{
function net_status()
    -- return table of network status
    local base_dir = "/sys/class/net"
    local ret = {}
    for dev in lfs.dir(base_dir) do
        if utils.any(function (p) return string.match(dev, p) end, "wlan%d+", "p2p%d+", "eth%d+", "em%d+", "lo") then
            local fd, status, rx, tx
            fd = io.open(base_dir .. '/' .. dev .. '/operstate')
            status = fd:read("*l")
            fd:close()
            if status == "up" then
                fd = io.open(base_dir .. '/' .. dev .. '/statistics/rx_bytes')
                rx = fd:read("*l")
                fd:close()
                fd = io.open(base_dir .. '/' .. dev .. '/statistics/tx_bytes')
                tx = fd:read("*l")
                fd:close()
            else
                rx = 0
                tx = 0
            end
            ret[dev] = { status = status, rx = tonumber(rx), tx = tonumber(tx) }
        end
    end
    return ret
end

function widget_netstat.new(arg)
    local ret = {}
    ret.widget = wibox.widget.textbox()
    ret.update = arg.update or 3
    ret.rx_max = (arg.rx_max or 360) * 1024
    ret.tx_max = (arg.tx_max or 100) * 1024
    ret.updater = function(self)
        local text = ""
        local line, rx, tx
        local s = net_status()
        if self.stats == nil then self.stats = s end
        for k, v in pairs(s) do
            if v.status == "up" then
                rx = self.stats[k] and (v.rx - self.stats[k].rx) / self.update or 0
                tx = self.stats[k] and (v.tx - self.stats[k].tx) / self.update or 0
                line = "✓" .. k .. ' <span color="' .. utils.gradient("#e0e0e0", "#3030EC", 0, ret.tx_max, tx) .. '">' .. utils.format_byte(tx, "sub") .. '</span>'
                                .. '⇅<span color="' .. utils.gradient("#e0e0e0", "#EC3030", 0, ret.rx_max, rx) .. '">' .. utils.format_byte(rx, "sub") .. '</span>'
            else
                line = nil
            end
            if line then text = text .. (text == "" and "" or "|") .. line end
        end
        self.stats = s
        self.widget:set_markup(text)
    end
    return ret
end

return widget_netstat
