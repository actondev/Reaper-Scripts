local module = {}
-- local Log = require("aod.utils.log")



-- modifies t1 -> updates with t2's values
function module.merge(t1, t2)
    for k, v in pairs(t2) do
        t1[k] = v
    end
    return t1
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

local function getIn(tbl, keys)
    local k = table.remove(keys,1)
    if #keys == 0 then
        return tbl[k]
    else return
        getIn(tbl[k], keys)
    end
end

-- the has copied
function module.getIn(tbl, keys)
    local copiedKeys = module.copy(keys)
    return getIn(tbl, copiedKeys)
end

local function setIn(tbl, keys, value)
    local k = table.remove(keys,1)
    if #keys == 0 then
        tbl[k] = value
    else return
        setIn(tbl[k], keys, value)
    end
end

function module.updateIn(tbl, keys)
    local copiedKeys = module.copy(keys)
    return getIn(tbl, copiedKeys)
end

function module.setIn(tbl, keys, value)
    local copiedKeys = module.copy(keys)
    return setIn(tbl, copiedKeys, value)
end

function module.copy(orig)
    return module.merge({}, orig)
end

-- code from lua site
-- there was a bug: copies wasn't present in the arguments, thus creating a global variable copies
-- that caused subsequent calls to this function with the same table argument return the same table reference
function module.deepcopy(orig, copies)
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

function module.map(tbl, f)
    local t = {}
    for k, v in ipairs(tbl) do
        t[k] = f(v)
    end
    return t
end

function module.clear(tbl)
    for k in pairs(tbl) do
        tbl[k] = nil
    end
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
return module
