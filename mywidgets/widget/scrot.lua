-- Screen shot widget using scout
-- Namespace
local scrot = {}

-- requires
local awful    = require("awful")
local textbox  = require("wibox.widget.textbox")
local naughty  = require("naughty")

scrot.take = function(args_in)
    local args  = args_in or {}
    local delay = args.delay or 0
    local area  = args.area  or false
    local cmd_line = "scrot -q 100" 
            .. (delay == 0 and ""    or (" -d " .. tostring(delay)))
            .. (area       and " -s" or "")
            .. " " .. os.getenv("HOME") .. "/Pictures/awesome-screen-" .. os.date("%Y%m%d%H%M%S") .. ".png"
    
    print(cmd_line)
    awful.util.spawn(cmd_line)
end

-- Menu used when Right-click on the icon
scrot.pop_menu = awful.menu({
    items = { 
        { "Now",         function() scrot.take({ delay = 0 }) end }
      , { "5 sec",       function() scrot.take({ delay = 5 }) end }}
  , theme = {width = 200}})

scrot.new = function(args)
    local ret = {}
    ret.widget = textbox()
    ret.widget:set_text("⬚")
    ret.widget:buttons(awful.util.table.join(
        awful.button({ }, 1, function() scrot.take() end)
      , awful.button({ }, 3, function() scrot.pop_menu:show() end)))
    return ret
end

return scrot
