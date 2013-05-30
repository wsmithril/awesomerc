-- switch between builtin and external USB keyboard

-- Namespace
local w = {}

local wibox = require("wibox")
local awful = require("awful")

local function run_and_wait(cmd)
    local fd  = io.popen(cmd)
    local str = fd:read("*all")
    fd:close()
    return str
end

local sym = "⌨  "

local list_all_kb = function()
    local device_list = {}
    local i = 1
    local fd = io.popen("xinput")
    for l in fd:lines() do
        line = string.gsub(l, '"', "")
        if string.match(line, "keyboard") and
           not string.match(line, "[Vv]irtual") then
            -- this is an actual keyboard
            local d = {}
            d.id, d.name = string.match(line, "(%a.+)%s*id=(%d+)")
            device_list[i] = d
        end
    end
    fd:close()
    return device_list
end

local enable_device = function(id)
    awful.util.spawn("xinput enable ".. id)
end

local disable_device = function(id)
    awful.util.spawn("xinput disable ".. id)
end

w.new = function(args)
    local ret = {}
    ret.dev_list = list_all_kb()
    ret.current_enable = #ret.dev_list

    -- cycle enable keyboard
    local cycle = function()
        local tooltip_text = ""
        local widget_text  = ""

        local enable_this = (ret.current_enable + 1) % (#ret.dev_list + 1)
        if enable_this == 0 then 
            for _, dev in ipairs(ret.dev_list) do enable_device(dev.id) end
            widget_text = "ALL"
        else  
            if ret.current_enable == 0 then
                for _, dev in ipairs(ret.dev_list) do disable_device(dev.id) end
            else
                disable_device(ret.dev_list[current_enable].id)
            end
            enable_device(ret.dev_list[enable_this].id)
            widget_text = ret.dev_list[enable_this].id .. " " .. ret.dev_list[enable_this].name
        end
        
        -- tooltip text
        for i, dev in ipairs(ret.dev_list) do
            local enable = ""
            if enable_this == 0 or enable_this == id then
                enable = "* "
            else 
                enable = "  "
            end

            if tooltip_text == "" then
                tooltip_text = enable .. dev.id .. " " .. dev.name
            else
                tooltip_text = tooltip .. "\n" ..
                               enable .. dev.id .. " " .. dev.name
            end
        end
        
        ret.widget:set_text(sym .. widget_text)
        ret.tooltip:set_text(tooltip_text)
        ret.current_enable = enable_this
    end

    ret.widget  = wibox.widget.textbox()
    ret.tooltip = awful.tooltip({objects = {ret.widget}})
    ret.widget:buttons(awful.util.table.join(awful.button({ }, 1, cycle)))
    cycle()
    return ret
end

return w
