local module = {}

module.isdebug = false

function module.debug(...)
    if module.isdebug == false then
        return
    end
    reaper.ShowConsoleMsg(os.date() .. " DEBUG ")
    for _, v in ipairs {...} do
        reaper.ShowConsoleMsg(module.dump(v) .. "\n")
    end
end

function module.dump(o)
    if type(o) == "table" then
        local s = "{ "
        for k, v in pairs(o) do
            if type(k) ~= "number" then
                k = '"' .. k .. '"'
            end
            s = s .. "[" .. k .. "] = " .. module.dump(v) .. ","
        end
        return s .. "} "
    elseif type(o) == "string" then
        return "'" .. o .. "'"
    else
        return tostring(o)
    end
end

return module
