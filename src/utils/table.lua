local module = {}
local Log = require('utils.log')

function module.merge(t1, t2)
    for k, v in pairs(t2) do
        t1[k] = v
    end
    return t1
end

function module.copy(orig)
    return module.merge({}, orig)
end

-- pass an ignoreKeys to avoid recursive arrays
function module.deepcopy(orig, ignoreKeys)
    ignoreKeys = ignoreKeys or {}
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            if ignoreKeys[orig_key] == nil then
                copy[module.deepcopy(orig_key, ignoreKeys)] = module.deepcopy(orig_value, ignoreKeys)
            end
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function module.deepmerge(t1, t2)
    for k,v in pairs(t2) do
        if type(v) == "table" then
            if type(t1[k] or false) == "table" then
                module.deepmerge(t1[k] or {}, t2[k] or {})
            else
                t1[k] = v
            end
        else
            t1[k] = v
        end
    end
    return t1
end

return module
