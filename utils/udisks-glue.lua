-- Intergate with udisks-glue
-- Nmaespaces
local m = {}

-- requires
local naughty = require("naughty")

m.mount_notify = function(device, mount_point, device_type, action)
    naughty.notify({
        title   = string.upper(tostring(device_type)) .. ":"
      , text    = tostring(action) .. " " .. tostring(device) .. " on " .. tostring(mount_point)
      , preset  = naughty.config.presets.normal
      , timeout = 10 })
end

if globals then globals.mount_notify = m.mount_notify end

return m
