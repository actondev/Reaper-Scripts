local module = {}
local Table = require('utils.table')
local Log = require("utils.log")


reaper = {}
function reaper.ShowConsoleMsg(text)
    print(text)
end

module.OPTS = 
{
    entries = 'entries', -- an array of the searchable entries
    query = 'query', -- the query to search over the entries
    limit = 'limit', -- the limit for the results to return
    key = 'key', -- the key of the entries to perform the search to
    emptyWhenNoQuery = 'emptyWhenNoQuery'
}

function module.search(opts)
    local default = {
        entries = {},
        query = {},
        key = 'name',
        limit = 10, -- false or number
        emptyWhenNoQuery = true, -- TODO
    }
    opts = Table.merge(default, opts)

    local results = {}
    if opts.emptyWhenNoQuery and opts.query == "" then
        return {}
    end

    for i, entry in ipairs(opts.entries) do
        entryLowerCase = string.lower(entry[opts.key])
        local match = true
        -- all words in the query string must match the action name
        for token in string.gmatch(opts.query, "[^%s]+") do
            local findI, findJ = string.find(entryLowerCase, token:lower(), 1, true)
            if findI == nil then
                match = false
                break
            end
        end

        -- if i == 2 then
        --     return results
        -- end

        if match then
            results[#results + 1] = entry
        end
        if opts.limit and #results == opts.limit then
            break
        end
    end

    -- Log.debug("result count " .. tostring(#results))
    return results
end

return module