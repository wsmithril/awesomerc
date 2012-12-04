-- Volumn control widget

-- Namespace
local volumn = {}

 -- requires
local wibox  = require("wibox")
local volumn = require("utils.volumncontrol")
local awful  = require("awful")

volumn.new = function(args)
    local ret = {}
    ret.device = args.device or "Master"
    ret.widget = wibox.widget.textbox()
    ret.widget:buttons(awful.util.table.join(
        awful.button({ }, 4, function() volumn.up(ret.device, ret.widget)     end)
      , awful.button({ }, 5, function() volumn.down(ret.device, ret.widget)   end)
      , awful.button({ }, 1, function() volumn.toogle(ret.device, ret.widget) end)
    ))

    -- We don't have a updater here,
    -- so we need to set widget text when it created
    volumn.status(ret.device, ret.widget)
    return ret
end

return volumn
