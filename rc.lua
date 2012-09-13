-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")
-- Widget Library
vicious = require("vicious")

-- Compiz Expose like
require("revelation")

os.setlocale("zh_CN.utf-8")

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
-- beautiful.init("/usr/share/awesome/themes/default/theme.lua")
beautiful.init(awful.util.getdir("config") .. "/themes/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "terminator"
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
-- }}}

-- {{{ Tags
-- Define a tag table which will hold all screen tags.
tags = {
    names  = { "Main",     "Broswer",   "Utils",    "GVim",     "dev",      6, 7, 8, 9 }
  , layout = { layouts[1], layouts[2], layouts[2], layouts[2], layouts[6]
             , layouts[1], layouts[1],  layouts[1], layouts[1] }
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
menu_awesome = {
    { "Edit Config", editor_cmd .. " " .. awesome.conffile }
  , { "Restart", awesome.restart }
  , { "Quit", awesome.quit }
}

menu_mainmenu = awful.menu( {
    items = {
        { "Awesome", menu_awesome, beautiful.awesome_icon }
      , { "Open Terminal", terminal }
    }
})

launcher_main = awful.widget.launcher({
    image = image(beautiful.awesome_icon)
  , menu  = menu_mainmenu
})
-- }}}

-- {{{ Wibox
-- Create a textclock widget
widget_textclock = awful.widget.textclock({ align = "right" })

-- seperator
widget_seperator = widget({ type = "textbox" })
widget_seperator.text = "|"

--  Network usage widget {{{
-- Initialize widget
netwidget = widget({ type = "textbox" })
-- Register widget
vicious.register(netwidget, vicious.widgets.net, '<span color="#CC9393">${wlan0 down_kb}</span> <span color="#7F9F7F">${wlan0 up_kb}</span>', 3)

-- }}}

--- {{{ volume control widget
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

widget_volume = widget({ type = "textbox", name = "widget_volume", align = "right"})
widget_volume.width = 48
widget_volume:buttons(awful.util.table.join(
    awful.button({ }, 4, function () volume_control("up")     update_volume_widget(widget_volume) end)
  , awful.button({ }, 1, function () volume_control("toggle") update_volume_widget(widget_volume) end)
  , awful.button({ }, 5, function () volume_control("down")   update_volume_widget(widget_volume) end)
))

function update_volume_widget(w)
    local status = volume_control("status")
    local vol    = volume_control("volume")
    if status == "on" and (vol > 0) then
        w.text = string.format("% 3d", vol) .. "%"
    else
        w.text = '<span color="red">---M</span>'
    end
end

volume_control_clock = timer({ timeout = 3 })
volume_control_clock:add_signal("timeout", function () update_volume_widget(widget_volume) end)
volume_control_clock:start()

update_volume_widget(widget_volume)

--- }}}

-- Create a systray
widget_systray = widget({ type = "systray" })

-- Create a wibox for each screen and add it
wibox_main = {}
widget_prompt = {}
widget_layout = {}
widget_taglist = {}
widget_taglist.buttons = awful.util.table.join(
    awful.button({ }, 1, awful.tag.viewonly)
  , awful.button({ modkey }, 1, awful.client.movetotag)
  , awful.button({ }, 3, awful.tag.viewtoggle)
  , awful.button({ modkey }, 3, awful.client.toggletag)
  , awful.button({ }, 5, awful.tag.viewnext)
  , awful.button({ }, 4, awful.tag.viewprev)
)

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

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    widget_prompt[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })

    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    widget_layout[s] = awful.widget.layoutbox(s)
    widget_layout[s]:buttons(awful.util.table.join(
        awful.button({ }, 1, function () awful.layout.inc(layouts,  1) end)
      , awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end)
      , awful.button({ }, 5, function () awful.layout.inc(layouts,  1) end)
      , awful.button({ }, 4, function () awful.layout.inc(layouts, -1) end)))

    -- Create a widget_taglist widget
    widget_taglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, widget_taglist.buttons)

    -- Create a tasklist widget
    widget_tasklist[s] = awful.widget.tasklist(
        function(c) return awful.widget.tasklist.label.currenttags(c, s) end,
        widget_tasklist.buttons)

    -- Create the wibox
    wibox_main[s] = awful.wibox({ position = "top", screen = s, height = 32})
    -- Add widgets to the wibox - order matters
    wibox_main[s].widgets = {
        {   launcher_main
          , widget_taglist[s]
          , widget_prompt[s]
          , layout = awful.widget.layout.horizontal.leftright
        }
      , widget_layout[s]
      , netwidget
      , widget_textclock
      , widget_seperator
      , s == 1 and widget_systray or nil
      , widget_volume
      , widget_seperator
      , widget_tasklist[s]
      , layout = awful.widget.layout.horizontal.rightleft
    }
end
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
  , awful.key({ modkey, "Control" }, "r", awesome.restart)
  , awful.key({ modkey, "Shift"   }, "q", awesome.quit)

  , awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end)
  , awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end)
  , awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end)
  , awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end)
  , awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end)
  , awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end)
  , awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end)
  , awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end)

--  , awful.key({ modkey, "Control" }, "n", awful.client.restore)

    -- Prompt
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
  , awful.key({ modkey }, "n", function () awful.util.spawn("nautilus --no-desktop") end)
    -- media keys
  , awful.key({}, "XF86AudioMute",        function () volume_control("toggle") update_volume_widget(widget_volume) end)
  , awful.key({}, "XF86AudioLowerVolume", function () volume_control("down")   update_volume_widget(widget_volume) end)
  , awful.key({}, "XF86AudioRaiseVolume", function () volume_control("up")     update_volume_widget(widget_volume) end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end)
  , awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end)
  , awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     )
  , awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end)
  , awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        )
  , awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end)
  , awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end)
  , awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end)
  , awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
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
        border_width = beautiful.border_width
      , border_color = beautiful.border_normal
      , focus        = true
      , keys         = clientkeys
      , size_hints_honor = false
      , buttons      = clientbuttons } 
    , callback = function (c) 
            naughty.notify({ title = c.name .. " Started", presets = naughty.config.presets.normal, timeout = 2, icon = c.icon })
        end}

    -- Fire and Pidgin on tag[1][2], horizenily side by side 
  , { rule = { class = "Firefox", role = "browse" },
      properties = { 
            floating = true
          , x = 0
          , tag = tags[1][2] 
          , maximized_vertical = true
          , width = 1280 } }
    -- pidgin
  , { rule       = { class = "Pidgin", role = "buddy_list" },
      properties = { 
          floating = true
        , maximized_vertical = true
        , tag = tags[1][2]
        , width = 1920 - 1280
        , x = 1280 } }
  , { rule       = { class = "Pidgin", role = "conversation" },
      properties = { 
          floating = true
        , maximized_vertical = true
        , tag = tags[1][2]
        , width = 1920 - 1280
        , x = 1280 },
      callback   = awful.client.setslave }
    -- Flash Full screen
  , { rule = { class = "Exe"}, properties = {floating = true } }
}
-- }}}

-- {{{ autostart
awful.util.spawn_with_shell(awful.util.getdir("config") .. "/autostart.sh")
-- }}}

-- vim: set foldmethod=marker:
