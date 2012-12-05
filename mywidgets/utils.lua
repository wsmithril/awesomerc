-- Mudule
local utils = {}

utils.id = function(x) return x end

function utils.all(f, x, ...)
    if ... then
        return f(x) and utils.all(f, ...)
    else
        return f(x)
    end
end

function utils.any(f, x, ...)
    if ... then
        return f(x) or utils.any(f, ...)
    else
        return f(x)
    end
end

function utils.format_byte(byte, tag, threshold)
    local t    = threshold or 0.8
    local ret  = ""
    local unit = ""
    if byte > 1024 * t then byte = byte / 1024.0 unit = "k" end
    if byte > 1024 * t then byte = byte / 1024.0 unit = "M" end
    if byte > 1024 * t then byte = byte / 1024.0 unit = "G" end
    ret = string.format("%3.2f", byte)
    if tag and tag ~= "" then
        ret = ret .. "<" .. tag .. ">" .. unit .. "</" .. tag .. ">"
    else
        ret = ret .. unit
    end
    return ret
end

-- gradient color bteween two #xxxxxx color
function utils.gradient(color1, color2, min, max, value)
    local function color_dec(c)
        return tonumber(c:sub(2, 3), 16), tonumber(c:sub(4, 5), 16), tonumber(c:sub(6, 7), 16)
    end

    local factor = 0
    if (value >= max) then
        factor = 1
    elseif (value <= min) then
        factor = 0
    else
        factor = (value - min) / (max - min)
    end

    local r1, g1, b1 = color_dec(color1)
    local r2, g2, b2 = color_dec(color2)

    r1 = r1 + (r2 - r1) * factor
    g1 = g1 + (g2 - g1) * factor
    b1 = b1 + (b2 - b1) * factor

    return string.format("#%02x%02x%02x", r1, b1, g1)
end

-- most of this is stolen from vicious library
function utils.fstab(dir)
    return setmetatable({ _path = dir}, {
        __index = function(table, index)
            local path = table._path .. "/" .. index
            local fd   = io.open(path)
            if fd then
                local str = fd:read("*all")
                fd:close()
                if str then return str else
                    return setmetatable({ _path = path}, getmetatable(table))
                end
            end
        end})
 end

return utils
