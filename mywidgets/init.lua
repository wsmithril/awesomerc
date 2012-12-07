-- my widgets
local capi = { timer = timer }

-- requires
local wibox = require("wibox")

-- Module
local mywidgets = {}

-- widget_list
local widgets = {}
mywidgets.widget_list = widgets

mywidgets.update = function()
    local ts = os.time()
    for name, w in pairs(widgets) do
        if w.update and w.updater and ts % w.update == 0 then
            w:updater()
        end
    end
end

local widget_update_timer = capi.timer({ timeout = 1 })
widget_update_timer:connect_signal("timeout", mywidgets.update)
widget_update_timer:start()

-- [ and ] shape seperators
local seperator = {}
seperator.left = wibox.widget.base.make_widget()
seperator.left.fit  = function(self, w, h) return (w < 8 and w or 8), h end
seperator.left.draw = function(self, wibox, cr, w, h)
    cr:move_to(7, 6)
    cr:line_to(3, 6)
    cr:line_to(3, h - 4)
    cr:line_to(7, h - 4)
    cr:set_line_width(0.5)
    cr:stroke()
end

seperator.right = wibox.widget.base.make_widget()
seperator.right.fit  = function(self, w, h) return (w < 8 and w or 8), h end
seperator.right.draw = function(self, wibox, cr, w, h)
    cr:move_to(0, 6)
    cr:line_to(4, 6)
    cr:line_to(4, h - 4)
    cr:line_to(0, h - 4)
    cr:set_line_width(0.5)
    cr:stroke()
end

mywidgets.seperator = seperator

mywidgets.decorate = function(widget, args)
    local in_arg = args or {}

    local dec  = not in_arg.not_decorate
    local icon = in_arg.icon

    if not dec and not icon then return widget end

    local d = wibox.layout.fixed.horizontal()
    if dec then d:add(seperator.left) end
    if icon then
        local i = wibox.widget.imagebox()
        i:set_image(args.icon)
        i:set_resize(false)
        d:add(i)
    end
    d:add(widget)
    if dec then d:add(seperator.right) end
    
    -- pass all set_.+ function in widget to d
    for name, func in pairs(widget) do
        if name:match("set_.*") then 
            d[name] = function(self, ...) return func(widget, ...) end
        end
    end
    return d
end

mywidgets.new = function(arg)
    local _type   = arg.type or "text"
    local update  = arg.update
    local name    = arg.name or "widget_" .. tostring(#widgets)
    local factory = require("mywidgets.widget." .. _type)

    local w = factory.new(arg)
    if w.widget == nil then return nil end
    w.update = w.update or arg.update
    if w.updater then w:updater() end
    widgets[name] = w
    return mywidgets.decorate(w.widget, arg)
end

return mywidgets
