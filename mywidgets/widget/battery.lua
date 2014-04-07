-- Battery widget
-- Namespace
local battery = {}

-- requires
local wibox = require("wibox")
local utils = require("mywidgets.utils")

local battery_state = {
    ["Full\n"]        = "⚡",
    ["Unknown\n"]     = "⌁",
    ["Charged\n"]     = "↯",
    ["Charging\n"]    = "+",
    ["Discharging\n"] = "-"
}

local battery_path = "/sys/class/power_supply"

-- get Power state
local power_stat = function(dev)
    local bat = utils.fstab(battery_path .. "/" .. dev)
    
    -- Battery not exisits
    if not bat or bat.present ~= "1\n" then return nil end

    local ret = {}
    ret.status   = bat.status or "Unknown\n"
    ret.drain    = tonumber(bat.current_now or bat.power_now)
    ret.full     = tonumber(bat.energy_full or bat.charge_full)
    ret.now      = tonumber(bat.energy_now  or bat.charge_now)
    ret.precent  = tonumber(bat.capacity or "0")
    return ret
end

local m2hm = function(t)
    local h = math.floor(t)
    local m = math.floor((t - h) * 60)
    return h, m
end

battery.new = function(args)
    local ret = {}
    local dev   = args.dec or "BAT0"
    ret.update  = args.update or 5
    ret.widget  = wibox.widget.textbox()
    ret.updater = function(self)
        local stats = power_stat(dev)
        local text = ""
        if stats then
            text = string.format("% 2d%%", stats.precent)
            if stats.status ~= "Charged\n" and stats.status ~= "Full\n" and stats.drain ~= 0 then
                text = text .. " " .. battery_state[stats.status]
                if stats.status == "Charging\n" then
                    text = text .. string.format("%02d:%02d", m2hm((stats.full - stats.now) / stats.drain))
                else
                    text = text .. string.format("%02d:%02d", m2hm((stats.now) / stats.drain))
                end
            else
                text = battery_state[stats.status] .. text
            end
        else
            text = "on AC"
        end
        self.widget:set_markup(text)
    end
    return ret
end

return battery
