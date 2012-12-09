-- rc file for awesome 3.5

-- Awesome Library
local awful     = require("awful")
awful.rules     = require("awful.rules")
awful.autofocus = require("awful.autofocus")
local beautiful = require("beautiful")  -- Theme
local wibox     = require("wibox")      -- Widget and layouts
local menubar   = require("menubar")    -- menubar
local lfs       = require("lfs")        -- Lua filesystem
local gears     = require("gears")
local utils     = require("utils")

naughty = require("naughty")    -- Notifications

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title  = "Oops, there were errors during startup!",
                     text   = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset  = naughty.config.presets.critical,
                         title   = "Oops, an error happened!",
                         text    = err,
                         timeout = 10 })
        in_error = false
    end)
end
-- }}}

-- {{{ Default settings
-- locale
os.setlocale("zh_CN.utf-8")

-- Theming
beautiful.init(awful.util.getdir("config") .. "/themes/theme.lua")

-- Default toolkits
local tools = {
    terminal = "lilyterm"
  , editor   = "gvim"}

-- modkey
local modkey = "Mod4"

-- Layouts
local layouts = {
    awful.layout.suit.floating         -- 1
  , awful.layout.suit.tile             -- 2
  , awful.layout.suit.tile.left        -- 3
  , awful.layout.suit.tile.bottom      -- 4
  , awful.layout.suit.tile.top         -- 5
  , awful.layout.suit.fair             -- 6
  , awful.layout.suit.fair.horizontal  -- 7
  , awful.layout.suit.spiral           -- 8
  , awful.layout.suit.spiral.dwindle   -- 9
  , awful.layout.suit.max              -- 10
  , awful.layout.suit.max.fullscreen   -- 11
  , awful.layout.suit.magnifier        -- 12
}

-- set opaticy of notifications
naughty.config.presets.normal.opacity = 0.8
naughty.config.presets.low.opacity    = 0.8
-- }}}

-- {{{ Wallpapers
if beautiful.wallpaper then
    for s = 1, screen.count() do
        gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
end
-- }}}

-- {{{  Tags

local tags = {}

-- screen 1 has different set of tags
tags[1] = awful.tag(
    { "Main", "www", 3, 4, 5 }
  , 1
  , { layouts[1], layouts[1], layouts[2], layouts[2], layouts[2] })

for s = 2, screen.count() do
    tags[s] = awful.tag({1, 2, 3, 4, 5}, s, layouts[2])
end
--- }}}

-- {{{ Menu
local menu_main = awful.menu({
    items = {
        { "awesome", {
            { "Restart", awesome.restart }
          , { "Quit",    awesome.quit }}
        , beautiful.awesome_icon }
      , { "Terminal", tools.terminal }}
  , theme = { width = beautiful.menu_width, height = beautiful.menu_height }})

awful.menu.menu_keys = {
    up    = { "k", "Up" }
  , down  = { "j", "Down" }
  , exec  = { "l", "Return", "Right" }
  , enter = { "Right" }
  , back  = { "h", "Left" }
  , close = { "q", "Escape" }}

local widget_mainlauncher = awful.widget.launcher({
    image = beautiful.awesome_icon
  , menu  = menu_main})

menubar.utils.terminal = tools.terminal
-- }}}

-- {{{ My own widgets

local mywidgets = require("mywidgets")

local widget_netstats = mywidgets.new({ type = "netstats", update = 3, name = "net" })
local widget_cpuuse   = mywidgets.new({ type = "cpuusage", update = 3, name = "cpu", icon = awful.util.getdir("config") .. "/themes/cpu.png", not_decorate = true})
local widget_cputemp  = mywidgets.new({ type = "cputemp",  update = 3, name = "temperature", not_decorate = true })
local widget_weather  = mywidgets.new({ type = "weather",  name = "weather" })
local widget_volumn   = mywidgets.new({ type = "volumn",   name = "vol",     device = "Master" })
local widget_battery  = mywidgets.new({ type = "battery",  name = "battery", device = "BAT0" })

-- }}}

 -- {{{ wibox
widget_textclock = awful.widget.textclock("%Y-%m-%d %A %H:%M", 15) -- textclock
widget_systray   = wibox.widget.systray()   -- systray

-- {{{ buttons for tasklist
widget_tasklist = {}
widget_tasklist.buttons = awful.util.table.join(
    awful.button({ }, 1, function (c)
        if c == client.focus then
            c.minimized = true
        else
            c.minimized = false
            if not c:isvisible() then awful.tag.viewonly(c:tags()[1]) end
            client.focus = c
            c:raise()
        end
    end)
  , awful.button({ }, 3, function ()
        if instance then
            instance:hide()
            instance = nil
        else
            instance = awful.menu.clients(awful.menu.new({
                items = {}
              , theme = {width = 250}}))
        end
    end)
  , awful.button({ }, 4, function ()
        awful.client.focus.byidx(1)
        if client.focus then client.focus:raise() end
    end)
  , awful.button({ }, 5, function ()
        awful.client.focus.byidx(-1)
        if client.focus then client.focus:raise() end
    end))
-- }}}

-- {{{ buttions for taglist
widget_taglist = {}
widget_taglist.buttons = awful.util.table.join(
    awful.button({ }, 1, awful.tag.viewonly)
  , awful.button({ modkey }, 1, awful.client.movetotag)
  , awful.button({ }, 3, awful.tag.viewtoggle)
  , awful.button({ modkey }, 3, awful.client.toggletag)
  , awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end)
  , awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end))
--- }}}

wibox_main = {}
widget_promptbox = {}
widget_layoutbox = {}

for s = 1, screen.count() do
    -- prompt box
    widget_promptbox[s] = awful.widget.prompt()

    -- layout box
    widget_layoutbox[s] = awful.widget.layoutbox(s)
    widget_layoutbox[s]:buttons(awful.util.table.join(
        awful.button({ }, 1, function () awful.layout.inc(layouts,  1) end)
      , awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end)))

    -- taglist
    widget_taglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, widget_taglist.buttons)

    -- tasklist
    widget_tasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, widget_tasklist.buttons)

    -- THE wibox {{{
    wibox_main[s] = awful.wibox({position = "top", screen = s, height = 48 })

    local top_left   = wibox.layout.fixed.horizontal()
    local top_right  = wibox.layout.fixed.horizontal()
    local top_middle = wibox.layout.flex.horizontal()
    top_left:add(widget_mainlauncher)
    top_left:add(mywidgets.decorate(widget_textclock))
    top_left:add(widget_weather)
    top_left:add(widget_netstats)
    top_middle:add(widget_promptbox[s])
    top_right:add(widget_battery)
    top_right:add(widget_volumn)
    top_right:add(mywidgets.seperator.left)
    top_right:add(widget_cpuuse)
    top_right:add(widget_cputemp)
    top_right:add(mywidgets.seperator.right)

    local top = wibox.layout.align.horizontal()
    top:set_left(top_left)
    top:set_middle(top_middle)
    top:set_right(top_right)

    local bottom_left   = wibox.layout.fixed.horizontal()
    local bottom_middle = wibox.layout.flex.horizontal()
    local bottom_right  = wibox.layout.fixed.horizontal()
    bottom_left:add(widget_taglist[s])
    bottom_left:add(mywidgets.seperator.left)
    bottom_middle:add(widget_tasklist[s])
    bottom_right:add(mywidgets.seperator.right)
    if s == 1 then
        bottom_right:add(mywidgets.decorate(widget_systray))
    end
    bottom_right:add(widget_layoutbox[s])

    local bottom = wibox.layout.align.horizontal()
    bottom:set_left(bottom_left)
    bottom:set_middle(bottom_middle)
    bottom:set_right(bottom_right)

    local layout = wibox.layout.flex.vertical()
    layout:add(top)
    layout:add(bottom)

    wibox_main[s]:set_widget(layout)
    --  }}}
end
-- }}} 

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () menu_main:toggle() end)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       )
  , awful.key({ modkey,           }, "Right",  awful.tag.viewnext       )
  , awful.key({ modkey,           }, "Escape", awful.tag.history.restore)
  , awful.key({ modkey,           }, "w", function() menu_main:show({keygrabber = true}) end)
  , awful.key({ modkey,           }, "j", function() awful.client.focus.bydirection("down")  if client.focus then client.focus:raise() end end)
  , awful.key({ modkey,           }, "k", function() awful.client.focus.bydirection("up")    if client.focus then client.focus:raise() end end)
  , awful.key({ modkey,           }, "h", function() awful.client.focus.bydirection("left")  if client.focus then client.focus:raise() end end)
  , awful.key({ modkey,           }, "l", function() awful.client.focus.bydirection("right") if client.focus then client.focus:raise() end end)
  , awful.key({ modkey, "Shift"   }, "h", function() awful.client.swap.bydirection("left")  end)
  , awful.key({ modkey, "Shift"   }, "j", function() awful.client.swap.bydirection("down")  end)
  , awful.key({ modkey, "Shift"   }, "k", function() awful.client.swap.bydirection("up")    end)
  , awful.key({ modkey, "Shift"   }, "l", function() awful.client.swap.bydirection("right") end)
  , awful.key({ modkey,           }, "u", awful.client.urgent.jumpto)
  , awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end)

    -- Standard program
  , awful.key({ modkey,           }, "Return", function () awful.util.spawn(tools.terminal) end)
  , awful.key({ modkey, "Control", "Mod1" }, "r", awesome.restart)
  , awful.key({ modkey, "Shift"   }, "q", awesome.quit)
  , awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end)
  , awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end)

    -- Prompt
  , awful.key({ modkey, "Shift" },   "r",     function () widget_promptbox[mouse.screen]:run() end)
  , awful.key({ modkey },            "r",     function () widget_promptbox[mouse.screen]:run() end)
  , awful.key({ modkey },            "x",
              function ()
                  awful.prompt.run(
                      { prompt = "Run Lua code: " },
                      widget_promptbox[mouse.screen].widget,
                      awful.util.eval, nil,
                      awful.util.getdir("cache") .. "/history_eval")
              end)
    -- start nautilus
  , awful.key({ modkey }, "e", function () awful.util.spawn("nautilus --no-desktop") end)
    -- media keys
  , awful.key({}, "XF86AudioMute",        function() utils.volumn.toogle("Master", widget_volumn) end)
  , awful.key({}, "XF86AudioLowerVolume", function() utils.volumn.down("Master", widget_volumn)   end)
  , awful.key({}, "XF86AudioRaiseVolume", function() utils.volumn.up("Master", widget_volumn)     end)
    -- lock screen
  , awful.key({ modkey }, "BackSpace", function () awful.util.spawn("slock") end)
    -- take screen shot
  , awful.key({}, "Print", function() 
        naughty.notify({
            preset  = naughty.config.presets.normal 
          , title   = "Scrot"
          , text    = "Taking screenshot in 5 sec"
          , timeout = 3})
        local filename = os.getenv("HOME") .. "/Pictures/awesome-screen-" .. os.date("%Y%m%d%H%M%S") .. ".png"
        awful.util.spawn("scrot -d 5 " .. filename)
    end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      awful.client.floating.toggle)
  , awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill() end)
  , awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end)
  , awful.key({ modkey,           }, "o",      awful.client.movetoscreen)
  , awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw() end)
  , awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop end)
  , awful.key({ modkey,           }, "n",      function (c) c.minimized = true end)
  , awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
  , awful.key({ modkey }, "Up", function (c)
      c.maximized_vertical = not c.maximized_vertical
    end)

)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(
        globalkeys
      , awful.key({ modkey }, "#" .. i + 9,
            function ()
                local screen = mouse.screen
                if tags[screen][i] then
                    awful.tag.viewonly(tags[screen][i])
                end
            end)
      , awful.key({ modkey, "Control" }, "#" .. i + 9,
          function ()
              local screen = mouse.screen
              if tags[screen][i] then
                  awful.tag.viewtoggle(tags[screen][i])
              end
          end)
      , awful.key({ modkey, "Shift" }, "#" .. i + 9,
          function ()
              if client.focus and tags[client.focus.screen][i] then
                  awful.client.movetotag(tags[client.focus.screen][i])
              end
          end)
      , awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
          function ()
              if client.focus and tags[client.focus.screen][i] then
                  awful.client.toggletag(tags[client.focus.screen][i])
              end
          end)
    )
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end)
  , awful.button({ modkey }, 1, awful.mouse.client.move)
  , awful.button({ modkey }, 3, awful.mouse.client.resize)
)

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { }, properties = {
        border_width = 0
      , border_color = beautiful.border_normal
      , focus        = true
      , floating     = false
      , keys         = clientkeys
      , size_hints_honor = false
      , buttons      = clientbuttons }
    , callback = function (c)
            if c.name then
                naughty.notify({ title = c.name .. " Started", presets = naughty.config.presets.normal, timeout = 2, icon = c.icon })
            end
        end}
    -- Floating dialog window
  , { rule = { type = "dialog" }, properties = {floating = true },
      callback = function (c)
          if c.urgent then
              awful.placement.centered(c)
              c.ontop  = c.urgent
              c.sticky = c.urgent
          end
      end}
    -- Firefox and Pidgin on tag[1][2], horizontal side by side
  , { rule = { class = "Firefox", role = "browse" },
      properties = { x = 0 , tag = tags[1][2] , maximized_vertical = true , width = 1280 } }
    -- pidgin
  , { rule       = { class = "Pidgin", role = "buddy_list" },
      properties = { minimized = true, maximized_vertical = true , tag = tags[1][2] , width = 1920 - 1280 , x = 1280 } }
  , { rule       = { class = "Pidgin", role = "conversation" },
      properties = { maximized_vertical = true , tag = tags[1][2] , width = 1920 - 1280 , x = 1280 },
      callback   = awful.client.setslave }
    -- Terminals
  , { rule = { class = "Sakura" }, properties = { opacity = 0.9, floating = true }}
  , { rule = { class = "LilyTerm" }, properties = { opacity = 0.9, floating = true }}
    -- Flash Full screen
  , { rule = { class = "Plugin-container" }, properties = {fullscreen = true } }
    -- Deadbeef
  , { rule = {class = "Deadbeef" }, properties = { maximized_vertical = true , x = 920 , width = 1000 }}
  , { rule = {class = "Transmission-gtk", role = "tr-main" }, properties = { maximized_vertical = true , x = 920 , width = 1000 }}
  , { rule = {class = "Guake" }, properties = { floating = true} }
}
-- }}}

-- {{{ signal handlers
local add_titlebar = function(c)
    local titlebar = awful.titlebar(c, { size = 16, position = "top" })
    local layout = wibox.layout.fixed.horizontal()
    layout:add(awful.titlebar.widget.iconwidget(c))
    layout:add(awful.titlebar.widget.titlewidget(c))
    titlebar:set_widget(layout)
end

local hide_titlebar = function(c)
    if (c.maximized_vertical or c.maximized) then
        awful.titlebar(c, { size = 0, position = "top" })
    else
        awful.titlebar(c, { size = 16, position = "top" })
    end
end

client.connect_signal("manage", function (c, startup)
--[[
    if (awful.client.floating.get(c)
        or awful.layout.get(c.screen) == awful.layout.suit.floating)
       and not c.maximized_vertical then
        add_titlebar(c)
    end

    c:connect_signal("property::maximized_vertical",   hide_titlebar)
    c:connect_signal("property::maximized_horizontal", hide_titlebar)
]]

     if not startup and awful.client.floating.get(c) then
         awful.client.setslave(c)
         awful.placement.no_overlap(c)
         awful.placement.no_offscreen(c)
    end
end)
-- }}}

-- {{{ autostart
awful.util.spawn_with_shell(awful.util.getdir("config") .. "/autostart.sh start")
-- }}}

-- {{{ autostop
awesome.connect_signal("exit", function() awful.util.spawn_with_shell(awful.util.getdir("config") .. "/autostart.sh stop") end)
-- }}}
-- vim: foldmethod=marker ts=4
