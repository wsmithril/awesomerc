-- Alternative icon sets and widget icons:
--  * http://awesome.naquadah.org/wiki/Nice_Icons

config_dir = ".config/awesome/themes/"

-- {{{ Main
theme = {}
theme.wallpaper_cmd = { "awsetbg" .. config_dir .. "zenburn-background.png" }
-- }}}

-- {{{ Styles
theme.font      = "Yahei Mono 10"

-- {{{ Colors
theme.fg_normal = "#DCDCCC"
theme.fg_focus  = "#F0DFAF"
theme.fg_urgent = "#CC9393"
theme.bg_normal = "#3F3F3F"
theme.bg_focus  = "#1E2320"
theme.bg_urgent = "#3F3F3F"
-- }}}

-- {{{ Borders
theme.border_width  = "2"
theme.border_normal = "#3F3F3F"
theme.border_focus  = "#6F6F6F"
theme.border_marked = "#CC9393"
-- }}}

-- {{{ Titlebars
theme.titlebar_bg_focus  = "#3F3F3F"
theme.titlebar_bg_normal = "#3F3F3F"
-- }}}

-- There are other variable sets
-- overriding the default one when
-- defined, the sets are:
-- [taglist|tasklist]_[bg|fg]_[focus|urgent]
-- titlebar_[normal|focus]
-- tooltip_[font|opacity|fg_color|bg_color|border_width|border_color]
-- Example:
--theme.taglist_bg_focus = "#CC9393"
-- }}}

-- {{{ Widgets
-- You can add as many variables as
-- you wish and access them by using
-- beautiful.variable in your rc.lua
--theme.fg_widget        = "#AECF96"
--theme.fg_center_widget = "#88A175"
--theme.fg_end_widget    = "#FF5656"
--theme.bg_widget        = "#494B4F"
--theme.border_widget    = "#3F3F3F"
-- }}}

-- {{{ Mouse finder
theme.mouse_finder_color = "#CC9393"
-- mouse_finder_[timeout|animate_timeout|radius|factor]
-- }}}

-- {{{ Menu
-- Variables set for theming the menu:
-- menu_[bg|fg]_[normal|focus]
-- menu_[border_color|border_width]
theme.menu_height = "15"
theme.menu_width  = "100"
-- }}}

-- {{{ Icons
-- {{{ Taglist
theme.taglist_squares_sel   = config_dir .. "taglist/squarefz.png"
theme.taglist_squares_unsel = config_dir .. "taglist/squarez.png"
--theme.taglist_squares_resize = "false"
-- }}}

-- {{{ Misc
theme.awesome_icon           = config_dir .. "awesome-icon.png"
theme.menu_submenu_icon      = "/usr/share/awesome/themes/default/submenu.png"
theme.tasklist_floating_icon = "/usr/share/awesome/themes/default/tasklist/floatingw.png"
-- }}}

-- {{{ Layout
theme.layout_tile       = config_dir .. "layouts/tile.png"
theme.layout_tileleft   = config_dir .. "layouts/tileleft.png"
theme.layout_tilebottom = config_dir .. "layouts/tilebottom.png"
theme.layout_tiletop    = config_dir .. "layouts/tiletop.png"
theme.layout_fairv      = config_dir .. "layouts/fairv.png"
theme.layout_fairh      = config_dir .. "layouts/fairh.png"
theme.layout_spiral     = config_dir .. "layouts/spiral.png"
theme.layout_dwindle    = config_dir .. "layouts/dwindle.png"
theme.layout_max        = config_dir .. "layouts/max.png"
theme.layout_fullscreen = config_dir .. "layouts/fullscreen.png"
theme.layout_magnifier  = config_dir .. "layouts/magnifier.png"
theme.layout_floating   = config_dir .. "layouts/floating.png"
-- }}}

-- {{{ Titlebar
theme.titlebar_close_button_focus  = config_dir .. "titlebar/close_focus.png"
theme.titlebar_close_button_normal = config_dir .. "titlebar/close_normal.png"

theme.titlebar_ontop_button_focus_active  = config_dir .. "titlebar/ontop_focus_active.png"
theme.titlebar_ontop_button_normal_active = config_dir .. "titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_inactive  = config_dir .. "titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_inactive = config_dir .. "titlebar/ontop_normal_inactive.png"

theme.titlebar_sticky_button_focus_active  = config_dir .. "titlebar/sticky_focus_active.png"
theme.titlebar_sticky_button_normal_active = config_dir .. "titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_inactive  = config_dir .. "titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_inactive = config_dir .. "titlebar/sticky_normal_inactive.png"

theme.titlebar_floating_button_focus_active  = config_dir .. "titlebar/floating_focus_active.png"
theme.titlebar_floating_button_normal_active = config_dir .. "titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_inactive  = config_dir .. "titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_inactive = config_dir .. "titlebar/floating_normal_inactive.png"

theme.titlebar_maximized_button_focus_active  = config_dir .. "titlebar/maximized_focus_active.png"
theme.titlebar_maximized_button_normal_active = config_dir .. "titlebar/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_inactive  = config_dir .. "titlebar/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_inactive = config_dir .. "titlebar/maximized_normal_inactive.png"
-- }}}
-- }}}

return theme
