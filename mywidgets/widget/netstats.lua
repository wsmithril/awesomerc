-- net status widgets

-- requires
local wibox   = require("wibox")
local utils   = require("mywidgets.utils")

-- module
local M = {}

local net_stat = function() 
    local proc_file = "/proc/net/dev"
    local ret = {}
    fd = io.open(proc_file)
    local line_no = 1
    local idx_recv_bytes = 0
    local idx_send_bytes = 0
    
    for l in fd:lines() do 
        local fields = utils.split_words(l)
        if line_no == 1 and not M.fields_prefix then
            -- order of recieve and transmit
            M.fields_prefix = {}
            for _, v in ipairs(fields) do
                if v == "Receive"  then table.insert(M.fields_prefix, 'rx_') end
                if v == "Transmit" then table.insert(M.fields_prefix, 'tx_') end
            end
        elseif line_no == 2 and not M.fields then
            -- get field index we need
            M.fields = {}
            local byte_rot = 1
            local pkt_rot  = 1
            for i, v in ipairs(fields) do
                if v == 'bytes' then
                    M.fields[M.fields_prefix[byte_rot] .. v] = i
                    byte_rot = byte_rot + 1
                elseif v == 'packets' then
                    M.fields[M.fields_prefix[pkt_rot] .. v] = i
                    pkt_rot = pkt_rot + 1
                end
            end
        elseif line_no > 2 then
            dev = fields[1]
            if utils.any(function(p) return string.match(dev, p) end, 'wlan%d+', 'p2p%s+', 'eth%d+', 'em%d+', 'lo') then
                ret[dev] = {
                    status     = utils.fstab('/sys/class/net/' .. dev)['operstate'],
                    rx_bytes   = tonumber(fields[M.fields["rx_bytes"]]   or 0),
                    tx_bytes   = tonumber(fields[M.fields["tx_bytes"]]   or 0),
                    rx_packets = tonumber(fields[M.fields["rx_packets"]] or 0),
                    tx_packets = tonumber(fields[M.fields["tx_packets"]] or 0)} 
            end
        end
        line_no = line_no + 1
    end
    fd:close()
    return ret
end

function M.new(arg)
    local ret = {}
    ret.widget = wibox.widget.textbox()
    ret.update = arg.update or 3
    local rx_max = (arg.rx_max or 360) * 1024
    local tx_max = (arg.tx_max or 100) * 1024
    ret.old_status = {}
    ret.updater = function(self)
        local text = ""
        local line, rx, tx, old_status
        local s = net_stat()
        for dev, new_status in pairs(s) do
            if not new_status.status:find('down', 1) then

                old_status = self.old_status[dev]
                rx_bytes = old_status and (new_status.rx_bytes - old_status.rx_bytes) / self.update or 0
                tx_bytes = old_status and (new_status.tx_bytes - old_status.tx_bytes) / self.update or 0
                
                -- make test for widget
                line = "✓" .. dev 
                        .. ' <span color="' .. utils.gradient("#e0e0e0", "#3030EC", 0, tx_max, tx_bytes) .. '">' .. utils.format_byte(tx_bytes, "sub") .. '</span>'
                        .. '⇅<span color="' .. utils.gradient("#e0e0e0", "#EC3030", 0, rx_max, rx_bytes) .. '">' .. utils.format_byte(rx_bytes, "sub") .. '</span>'
                if line then text = text .. (text == "" and "" or "|") .. line end
            end
        end
        self.old_status = s
        self.widget:set_markup(text)
    end
    return ret
end

return M
