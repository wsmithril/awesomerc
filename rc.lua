-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")

-- Compiz Expose like
require("revelation")

-- freedesktop.org menu
require("freedesktop.utils")
require("freedesktop.menu")
lfs = require("lfs")

os.setlocale("zh_CN.utf-8")

-- {{{ usful functions 
function id(x)
    return x
end

function all(f, x, ...)
    if ... == nil then
        return f(x)
    else 
        return f(x) and all(f, ...)
    end
end

function any(f, x, ...)
    if ... == nil then
        return f(x)
    else 
        return f(x) or any(f, ...)
    end
end

function format_byte(byte)
    local unit = ""
    if byte > 1024 * 0.9 then byte = byte / 1024.0 unit = "k" end
    if byte > 1024 * 0.9 then byte = byte / 1024.0 unit = "M" end
    if byte > 1024 * 0.9 then byte = byte / 1024.0 unit = "G" end
    return string.format("% 3.1f%s", byte, unit)
end

function gradient(color, to_color, min, max, value)
    local function color2dec(c)
        return tonumber(c:sub(2,3),16), tonumber(c:sub(4,5),16), tonumber(c:sub(6,7),16)
    end

    local factor = 0
    if (value >= max ) then 
        factor = 1  
    elseif (value > min ) then 
        factor = (value - min) / (max - min)
    end 

    local red, green, blue = color2dec(color) 
    local to_red, to_green, to_blue = color2dec(to_color) 

    red   = red   + (factor * (to_red   - red))
    green = green + (factor * (to_green - green))
    blue  = blue  + (factor * (to_blue  - blue))

    -- dec2color
    return string.format("#%02x%02x%02x", red, green, blue)
end

-- }}}

 -- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.add_signal("debug::error", function (err)
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

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
beautiful.init(awful.util.getdir("config") .. "/themes/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "sakura"
editor = os.getenv("EDITOR") or "nano"
editor_cmd = "gvim"

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts = {
    awful.layout.suit.floating
  , awful.layout.suit.tile
  , awful.layout.suit.tile.left
  , awful.layout.suit.tile.bottom
  , awful.layout.suit.tile.top
--  ====  5  ===
  , awful.layout.suit.fair
  , awful.layout.suit.fair.horizontal
  , awful.layout.suit.spiral
  , awful.layout.suit.spiral.dwindle
  , awful.layout.suit.max
--  ====  10  ===
  , awful.layout.suit.max.fullscreen
  , awful.layout.suit.magnifier
}

-- set opaticy of notifications
naughty.config.presets.normal.opacity = 0.8
naughty.config.presets.low.opacity = 0.8
-- }}} 

-- {{{ Tags
-- Define a tag table which will hold all screen tags.
tags = {
    names  = { "Main",     "Broswer",   "Utils",    "GVim",     "dev",      6, 7, 8, 9 }
  , layout = { layouts[1], layouts[1], layouts[1], layouts[2], layouts[2]
             , layouts[2], layouts[1],  layouts[2], layouts[2] }
}

-- tags for Screen 1, others using default tag layout
tags[1] = awful.tag(tags.names, 1, tags.layout)

-- tags for other screen
for s = 2, screen.count() do
    tags[s] = awful.tag({0, 1, 2, 3, 4, 5, 6, 7, 8, 9}, s,
                        {layout[2], layout[2], layout[2], layout[2], layout[2], layout[2], layout[2], layout[2], layout[2], layout[2]})
end
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
freedesktop.utils.icon_theme = { 'elementary', 'gnome', 'default' }
freedesktop.utils.terminal = 'sakura'

freedesktop_menu = freedesktop.menu.new()

menu_awesome = {
    { "Edit Config", editor_cmd .. " " .. awesome.conffile }
  , { "Restart", awesome.restart }
  , { "Quit", awesome.quit }
}

menu_mainmenu = awful.menu( {
    items = {
        { "Awesome", menu_awesome, beautiful.awesome_icon }
      , { "Applications", freedesktop_menu }
      , { "Open Terminal", terminal }
    }
})

launcher_main = awful.widget.launcher({
    image = image(beautiful.awesome_icon)
  , menu  = menu_mainmenu
})
-- }}}

-- {{{ Widget
-- widget update timer
update_interval = 2
timer_widget_update = timer({ timeout = update_interval })
timer_widget_update_long = timer({ timeout = 30 })

-- {{{ text clock
widget_textclock = awful.widget.textclock()
-- }}}

-- {{{ seperator
widget_seperator = widget({ type = "textbox" })
widget_seperator.text = "|"
--- }}}

--  Network usage widget {{{
function net_status()
    -- return table of network status
    local base_dir = "/sys/class/net"
    local ret = {}
    for dev in lfs.dir(base_dir) do
        if any(function (p) return string.match(dev, p) end, "wlan%d+", "p2p%d+", "eth%d+", "em%d+") then
            local fd, status, rx, tx
            fd = io.open(base_dir .. '/' .. dev .. '/operstate')
            status = fd:read("*l")
            fd:close()
            if status == "up" then
                fd = io.open(base_dir .. '/' .. dev .. '/statistics/rx_bytes')
                rx = fd:read("*l")
                fd:close()
                fd = io.open(base_dir .. '/' .. dev .. '/statistics/tx_bytes')
                tx = fd:read("*l")
                fd:close()
            else
                rx = 0
                tx = 0
            end
            ret[dev] = { status = status, rx = tonumber(rx), tx = tonumber(tx) }
        end
    end
    return ret
end

function update_net_widget_helper(w)
    local old_status
    return function () 
        local text = "" 
        local line, rx, tx
        local rx_max = 360 * 1024
        local tx_max = 100 * 1024
        local s = net_status()
        if old_status == nil then old_status = s end
        for k, v in pairs(s) do
            if v.status == "up" then
                rx = old_status[k] and (v.rx - old_status[k].rx) / update_interval or 0
                tx = old_status[k] and (v.tx - old_status[k].tx) / update_interval or 0
                line = "✓" .. k .. '<span color="' .. gradient("#93A093", "#30EC30", 0, tx_max, tx) .. '">' .. format_byte(tx) .. 'B/s</span> '
                                .. '⇅<span color="' .. gradient("#A09090", "#EC3030", 0, rx_max, rx) .. '">' .. format_byte(rx) .. 'B/s</span>' 
            else
                line = nil
                -- line = k .. '<span color="#D0D0D0">-</span>'
            end
            if line then text = text .. (text == "" and "" or "|") .. line end
        end
        old_status = s
        w.widget.text = " " .. text .. " "
        w.status = s
    end
end

widget_net = {}
widget_net.widget = widget({ type = "textbox" })
update_net_widget = update_net_widget_helper(widget_net)
timer_widget_update:add_signal("timeout", update_net_widget)
 -- }}}

-- {{{ volume control widget
function ran_and_wait(cmd)
    local fd = io.popen(cmd)
    fd:read("*all")
    fd:close()
end

volume_sID = "Master"
function volume_control(action)
    if action == "status" then
        local fd = io.popen("amixer sget " .. volume_sID)
        local status = fd:read("*all")
        fd:close()
        status = string.match(status, "%[(on?f?f?)%]")
        return status
    elseif action == "volume" then
        local fd = io.popen("amixer sget " .. volume_sID)
        local status = fd:read("*all")
        fd:close()
        status = string.match(status, "%[(%d?%d?%d)%%%]")
        return tonumber(status)
    elseif action == "mute" then
        ran_and_wait("amixer -q sset " .. volume_sID .. " mute")
    elseif action == "unmute" then
        ran_and_wait("amixer -q sset " .. volume_sID .. " unmute")
    elseif action == "up" then
        ran_and_wait("amixer -q sset " .. volume_sID .. " 10%+ unmute")
    elseif action == "down" then
        ran_and_wait("amixer -q sset " .. volume_sID .. " 10%- unmute")
    elseif action == "toggle" then
        ran_and_wait("amixer -q sset " .. volume_sID .. " " 
            .. (volume_control("status") == "on" and "mute" or "unmute"))
    end
end

widget_volume = {}
widget_volume.widget = widget({ type = "textbox", name = "widget_volume" })
widget_volume.widget:buttons(awful.util.table.join(
    awful.button({ }, 4, function () volume_control("up")     update_volume_widget(widget_volume) end)
  , awful.button({ }, 1, function () volume_control("toggle") update_volume_widget(widget_volume) end)
  , awful.button({ }, 5, function () volume_control("down")   update_volume_widget(widget_volume) end)
))

function update_volume_widget(w)
    w.status = volume_control("status")
    w.vol    = volume_control("volume")
    if w.status == "on" and (w.vol > 0) then
        w.widget.text = string.format("♫% 3d", w.vol) .. "%"
    else
        w.widget.text = '<span color="red">♫Mute</span>'
    end
end

update_volume_widget(widget_volume)
--- }}}

-- {{{ CPU usage and temp
-- CPU widget
widget_cpu = widget({ type = "textbox" })
function cpu_usage()
    local fd = io.open("/proc/stat")
    local cpu_lines = { total = 0, idle = 0 }
    for l in fd:lines() do
        local idx = 0
        for num in string.gmatch(l, "[^%s]+") do
            idx = idx + 1
            if idx ~= 1 then cpu_lines.total = cpu_lines.total + tonumber(num) end
            if idx == 5 then cpu_lines.idle  = tonumber(num) end
        end
        break
    end
    fd:close()
    return cpu_lines
end

function cpu_widget_update_helper()
    local old_state
    return function (w)
        local new_state = cpu_usage()
        local usage = 0.0
        if old_state ~= nil then 
            usage = usage + 1 - (new_state.idle - old_state.idle) * 1.0 / (new_state.total - old_state.total)
        end
        w.text = string.format(" ☢% 3d%%", usage * 100)
        old_state = new_state
    end
end
cpu_widget_update = cpu_widget_update_helper()
timer_widget_update:add_signal("timeout", function () cpu_widget_update(widget_cpu) end)

-- CPU temperature widget
widget_cputemp = widget({ type = "textbox" })

function cputemp_update()
    local fd = io.open("/sys/class/thermal/temp")
    local temp = (fd:read("*a"))
end

timer_widget_update:add_signal("timeout", 
    function ()
        local fd = io.open("/sys/class/thermal/thermal_zone0/temp")
        local temp = tonumber(fd:read("*a")) / 1000
        fd:close()
        widget_cputemp.text = "<span color=\"" .. gradient("#20E020", "#E02020", 50, 95, temp) .. "\">"
                           .. string.format("% 3d", temp) .. "</span>°C"
    end)
-- }}}

-- {{{ systray
widget_systray = widget({ type = "systray", height = 32})
-- }}}

-- {{{ taglist buttons
widget_taglist = {}
widget_taglist.buttons = awful.util.table.join(
    awful.button({ }, 1, awful.tag.viewonly)
  , awful.button({ modkey }, 1, awful.client.movetotag)
  , awful.button({ }, 3, awful.tag.viewtoggle)
  , awful.button({ modkey }, 3, awful.client.toggletag)
  , awful.button({ }, 5, awful.tag.viewnext)
  , awful.button({ }, 4, awful.tag.viewprev)
)
-- }}}

-- {{{ tasklist buttons
widget_tasklist = {}
widget_tasklist.buttons = awful.util.table.join(
    awful.button({ }, 1,
        function (c)
            if c == client.focus then
                c.minimized = true
            else
                if not c:isvisible() then
                    awful.tag.viewonly(c:tags()[1])
                end
                -- This will also un-minimize
                -- the client, if needed
                client.focus = c
                c:raise()
            end
        end)
  , awful.button({ }, 3,
        function ()
            if instance then
                instance:hide()
                instance = nil
            else
                instance = awful.menu.clients({ width=250 })
            end
        end)
  , awful.button({ }, 5,
        function () awful.client.focus.byidx(1) if client.focus then client.focus:raise() end end)
  , awful.button({ }, 4, 
        function () awful.client.focus.byidx(-1) if client.focus then client.focus:raise() end end))

-- }}}

-- {{{ SSID widget

-- }}}

wibox_main = {}
wibox_status = {}
widget_prompt = {}
widget_layout = {}

for s = 1, screen.count() do
    -- {{{ prompt
    widget_prompt[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
    -- }}}

    -- {{{ layout box
    widget_layout[s] = awful.widget.layoutbox(s)
    widget_layout[s]:buttons(awful.util.table.join(
        awful.button({ }, 1, function () awful.layout.inc(layouts,  1) end)
      , awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end)
      , awful.button({ }, 5, function () awful.layout.inc(layouts,  1) end)
      , awful.button({ }, 4, function () awful.layout.inc(layouts, -1) end)))
    -- }}}

    -- {{{ taglist
    widget_taglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, widget_taglist.buttons)
    -- }}}
    
    -- {{{ tasklist
    widget_tasklist[s] = awful.widget.tasklist(
        function(c) return awful.widget.tasklist.label.currenttags(c, s) end,
        widget_tasklist.buttons)
    -- }}}

    -- wiboxes {{{
    wibox_main[s]   = awful.wibox({ position = "top", screen = s, height = 48})
    wibox_main[s].widgets = {
        {   {   launcher_main
              , widget_textclock
              , widget_net.widget
              , layout = awful.widget.layout.horizontal.leftright }
          , widget_cputemp
          , widget_cpu
          , widget_volume.widget
          , widget_prompt[s]
          , layout = awful.widget.layout.horizontal.rightleft } 
      , {   {   widget_taglist[s]
              , widget_seperator
              , layout = awful.widget.layout.horizontal.leftright }
          , widget_layout[s]
          , widget_seperator
          , s == 1 and widget_systray or nil
          , widget_seperator
          , widget_tasklist[s]
          , layout = awful.widget.layout.horizontal.rightleft }
        , layout = awful.widget.layout.vertical.flex }

    -- }}}
end

timer_widget_update:start()
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () menu_mainmenu:toggle() end)
    -- , awful.button({ }, 4, awful.tag.viewnext)
    -- , awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       )
  , awful.key({ modkey,           }, "Right",  awful.tag.viewnext       )
  , awful.key({ modkey,           }, "Escape", awful.tag.history.restore)
  , awful.key({ modkey,           }, "j", function () awful.client.focus.byidx( 1) if client.focus then client.focus:raise() end end)
  , awful.key({ modkey,           }, "k", function () awful.client.focus.byidx(-1) if client.focus then client.focus:raise() end end)
  , awful.key({ modkey,           }, "w", function () menu_mainmenu:show({keygrabber=true}) end)

    -- Layout manipulation
  , awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end)
  , awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end)
  , awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end)
  , awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end)
  , awful.key({ modkey,           }, "u", awful.client.urgent.jumpto)
  , awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end)

    -- Standard program
  , awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end)
  , awful.key({ modkey, "Control", "Mod1" }, "r", awesome.restart)
  , awful.key({ modkey, "Shift"   }, "q", awesome.quit)

  , awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end)
  , awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end)
  , awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end)
  , awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end)
  , awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end)
  , awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end)
  , awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end)
  , awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end)

    -- Prompt
  , awful.key({ modkey, "Shift" },   "r",     function () widget_prompt[mouse.screen]:run() end)
  , awful.key({ modkey },            "r",     function () widget_prompt[mouse.screen]:run() end)
  , awful.key({ modkey },            "x",
              function ()
                  awful.prompt.run(
                      { prompt = "Run Lua code: " },
                      widget_prompt[mouse.screen].widget,
                      awful.util.eval, nil,
                      awful.util.getdir("cache") .. "/history_eval")
              end)
    -- compiz expose like
  , awful.key({ modkey }, "b", revelation)

    -- start nautilus
  , awful.key({ modkey }, "e", function () awful.util.spawn("nautilus --no-desktop") end)
    -- media keys
  , awful.key({}, "XF86AudioMute",        function () volume_control("toggle") update_volume_widget(widget_volume) end)
  , awful.key({}, "XF86AudioLowerVolume", function () volume_control("down")   update_volume_widget(widget_volume) end)
  , awful.key({}, "XF86AudioRaiseVolume", function () volume_control("up")     update_volume_widget(widget_volume) end)
    -- lock screen
  , awful.key({ modkey }, "BackSpace", function () awful.util.spawn("slock") end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      awful.client.floating.toggle)
  , awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill() end)
  , awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle)
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
  , awful.key({ modkey }, "Up", function (c) c.maximized_vertical = not c.maximized_vertical end)

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
  , { rule = { type = "dialog" }, properties = { ontop = true, floating = true }}
    -- Firefox and Pidgin on tag[1][2], horizenily side by side 
  , { rule = { class = "Firefox", role = "browse" },
      properties = { x = 0 , tag = tags[1][2] , maximized_vertical = true , width = 1280 } }
    -- pidgin
  , { rule       = { class = "Pidgin", role = "buddy_list" },
      properties = { minimized = true, maximized_vertical = true , tag = tags[1][2] , width = 1920 - 1280 , x = 1280 } }
  , { rule       = { class = "Pidgin", role = "conversation" },
      properties = { maximized_vertical = true , tag = tags[1][2] , width = 1920 - 1280 , x = 1280 },
      callback   = awful.client.setslave }
    -- sakura terminal
  , { rule = { class = "Sakura" }, properties = { opacity = 0.8 }}
    -- Flash Full screen
  , { rule = { class = "Plugin-container"}, properties = {fullscreen = true } }
    -- Deadbeef
  , { rule = {class = "Deadbeef" },
      properties = { maximized_vertical = true , x = 920 , width = 1000 }}
  , { rule = { class = "Guake" }, properties = { floating = true} }
}
-- }}}

-- {{{ autostart
awful.util.spawn_with_shell(awful.util.getdir("config") .. "/autostart.sh start")
awful.util.spawn("xsetroot -cursor_name  Adwaita")
-- }}} 

-- {{{ autostop
awesome.add_signal("exit", function() awful.util.spawn_with_shell(awful.util.getdir("config") .. "/autostart.sh stop") end)
-- }}} 

-- vim: set foldmethod=marker:
