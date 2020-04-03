local module = {}

module.DEBUG = 0
module.INFO = 1
module.WARN = 2

module.LEVEL = module.WARN

local function dump(o)
    if type(o) == "table" then
        local s = "{ "
        for k, v in pairs(o) do
            if type(k) ~= "number" then
                k = '"' .. k .. '"'
            end
            s = s .. "[" .. k .. "] = " .. dump(v) .. ","
        end
        return s .. "} "
    elseif type(o) == "string" then
        return "'" .. o .. "'"
    else
        return tostring(o)
    end
end

local function print(prepend, ...)
    reaper.ShowConsoleMsg(os.date() .. " " .. prepend .. " ")
    for _, v in ipairs {...} do
        reaper.ShowConsoleMsg(dump(v) .. "\n")
    end
end

function module.debug(...)
    if module.LEVEL > module.DEBUG then
        return
    end
    print("DEBUG", ...)
end

function module.info(...)
    if module.LEVEL > module.INFO then
        return
    end
    print("INFO", ...)
end

function module.warn(...)
    if module.LEVEL > module.WARN then
        return
    end
    print("WARN", ...)
end

return module
