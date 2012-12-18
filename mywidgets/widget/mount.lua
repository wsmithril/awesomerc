-- Mounted devices
-- Namespace
local M = {}
setmetatable(M, {__mode = "k"})

-- requires
local menu   = require("awful.menu")
local udisks = require("utils.udisks")
local awful  = require("awful")
local textbox = require("wibox.widget.textbox")

local icons = {
    eject   = awful.util.getdir("config") .. "/themes/icons/eject.png"
  , no      = awful.util.getdir("config") .. "/themes/icons/no.png"
  , hdd     = awful.util.getdir("config") .. "/themes/icons/hdd.png"
  , usb     = awful.util.getdir("config") .. "/themes/icons/usb.png"
  , optical = awful.util.getdir("config") .. "/themes/icons/optical.png"
  , sdcard  = awful.util.getdir("config") .. "/themes/icons/sdcard.png"
}

-- Creating a menu Entry
local make_entry = function(info)
    local device      = info["device-file"]
    local ret         = { device }
    local device_type = udisks.get_device_type(info)
    local sub_menu    = {}
    
    -- insert mount-point if there is one
    if info["mount paths"] then
        table.insert(sub_menu, { info["mount paths"], nil, icons[device_type] })
    else
        table.insert(sub_menu, { "Not mounted", nil, icons.no })
    end

    -- label if there is one
    if info["label"] then
        table.insert(sub_menu, {info["label"]})
    end

    -- add Actions to sub_menu
    if device_type == "hdd" then
        -- device not removable
        table.insert(sub_menu, { "DO NOT TOUCH", nil, icons.no })
    else
        if info["is mounted"] == "1" then
            table.insert(sub_menu, { "Unmount", "udisks --unmount " .. device, icons.eject })
        else
            table.insert(sub_menu, {"Mount", "udisks --mount " .. device, nil})
        end
    end

    ret[2] = sub_menu
    ret[3] = icons[device_type]
    return ret
end

local function get_icon(info)
    return icons[udisks.get_device_type(info)]
end

-- creat the whole menu
local make_menu = function(devices)
    local ret = {}
    local device_tree = {}
    for _, v in pairs(devices) do
        local info = udisks.get_device_info(v)
        local device_file = info["device-file"]
        local root_device = device_file:match("^(/dev/[sh]d%a+)%d*$") or device_file:match("^(/dev/mmcblk%d+)p?%d*$")
        if not device_tree[root_device] then 
            device_tree[root_device] = { root_device, {}, get_icon(info) }
        end
        
        if device_file ~= root_device and info["type"] ~= "swap" then
            table.insert(device_tree[root_device][2], make_entry(info))
        end
    end
    
    for k, v in pairs(device_tree) do table.insert(ret, v) end

    table.sort(ret, function(x, y) 
        if not x or not y then return false end
        return x[1] < y[1] 
    end)

    ret.theme = { width = 150 }
    return menu(ret)
end


M.new = function(args)
    local ret  = {}
    ret.widget = textbox("⏏")
    ret.widget:buttons(awful.util.table.join(
        awful.button({ }, 3, function() ret.menu:toggle() end)
      , awful.button({ }, 1, function() ret.menu:toggle() end)))
    ret.updater = function(self)
        self.menu = make_menu(udisks.list_devices())
    end
    return ret
end

return M
