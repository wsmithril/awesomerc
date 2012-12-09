-- Volumn control
local control = {}

local function run_and_wait(cmd)
    local fd  = io.popen(cmd)
    local str = fd:read("*all")
    fd:close()
    return str
end

function control.control(action, sID)
    local l_sID = sID or "Master"
    local vol_pattern = "%[(1?%d?%d)%%%]"
    if action == "status" then
        local str = run_and_wait("amixer sget " .. l_sID)
        if (string.match(str, "%[(of?f?n?)%]") == "off") then
            return "off"
        else
            return tonumber(string.match(str, vol_pattern))
        end
    elseif action == "volumn" or action == "volume" then
        return string.match(run_and_wait("amixer sget " .. l_sID), "%[(1?%d?%d)%%%]")
    elseif action == "mute" then
        run_and_wait("amixer sset " .. l_sID .. " mute")
        return "off"
    elseif action == "unmute" then
        return tonumber(string.match(run_and_wait("amixer sset " .. l_sID .. " unmute"), vol_pattern))
    elseif action == "up" then
        return tonumber(string.match(run_and_wait("amixer sset " .. l_sID .. " 10%+ on"), vol_pattern))
    elseif action == "down" then
        return tonumber(string.match(run_and_wait("amixer sset " .. l_sID .. " 10%- on"), vol_pattern))
    elseif action == "toogle" then
        local status = control.control("status", l_sID)
        return control.control(status ~= "off" and "mute" or "unmute", l_sID)
    end
end

actions = {"up", "down", "status", "mute", "unmute", "toogle", "volumn", "unmule"}
for i, a in ipairs(actions) do
    control[a] = function(sID, widget)
        local status = control.control(a, sID)
        -- update the corresponding widget if there is one
        if widget then
            local text = ""
            if (status == "off" or status == 0) then
                text = '<span color="red">🔇Mute</span>'
            else
                text = string.format("🔉% 3d%%", status or 0)
            end
            widget:set_markup(text)
        end
        return status
    end
end

return control
