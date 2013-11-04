-- Intergate with udisks
-- Namepaces
local m = {}

-- requires
-- local naughty = require("naughty")

m.mount_notify = function(device, mount_point, device_type, action)
    naughty.notify({
        title   = string.upper(tostring(device_type)) .. ":"
      , text    = tostring(action) .. " " .. tostring(device) .. " on " .. tostring(mount_point)
      , preset  = naughty.config.presets.normal
      , timeout = 10 })
    -- we need to update the mount widget
    globals.update_now["mount"] = true
end

if globals then globals.mount_notify = m.mount_notify end

m.get_device_info = function(device)
    local ret = {}
    local fd = io.popen('udisks --show-info ' .. device)
    for line in fd:lines() do
        local k, v = line:match('%s*([^:]*):%s*(.*)$')
        if k and v and v ~= "" then ret[k] = v end
    end
    fd:close()
    return ret
end

m.list_devices = function()
    local ret = {}
    local fd  = io.popen("udisks --dump")
    for line in fd:lines() do
        local device_file = line:match('%s*device%-file:%s*(.*)$')
        if device_file then table.insert(ret, device_file) end
    end
    fd:close()
    return ret
end

m.get_device_type = function(info)
    if string.match(info["native-path"], "/[^/]*ata%d+/") then
        return "hdd"
    elseif string.match(info["native-path"], "/usb%d+/") then
        return "usb"
    elseif string.match(info["device-file"], "mmcblk") then
        return "sdcard"
    elseif string.match(info["device-file"], "loop") then
        return "loop"
    end
    return "usb"
end

return m
