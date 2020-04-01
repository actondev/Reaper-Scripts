local module = {}
local Log = require("utils.log")

-- modifies t1 -> updates with t2's values
function module.merge(t1, t2)
    for k, v in pairs(t2) do
        t1[k] = v
    end
    return t1
end

function module.copy(orig)
    return module.merge({}, orig)
end

function module.map(tbl, f)
    local t = {}
    for k, v in ipairs(tbl) do
        t[k] = f(v)
    end
    return t
end

function module.deepCopyIgnoringKeys(orig, ignoreKeys)
    ignoreKeys = ignoreKeys or {}
    local orig_type = type(orig)
    local copy
    if orig_type == "table" then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            if ignoreKeys[orig_key] == nil then
                copy[module.deepCopyIgnoringKeys(orig_key, ignoreKeys)] =
                    module.deepCopyIgnoringKeys(orig_value, ignoreKeys)
            end
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function module.deepcopy(orig)
    copies = copies or {}
    local orig_type = type(orig)
    local copy
    if orig_type == "table" then
        if copies[orig] then
            copy = copies[orig]
        else
            copy = {}
            copies[orig] = copy
            for orig_key, orig_value in next, orig, nil do
                copy[module.deepcopy(orig_key, copies)] = module.deepcopy(orig_value, copies)
            end
            setmetatable(copy, module.deepcopy(getmetatable(orig), copies))
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function module.deepmerge(t1, t2)
    for k, v in pairs(t2) do
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
