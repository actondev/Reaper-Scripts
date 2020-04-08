local module = {}
local Table = require('utils.table')
local Log = require("utils.log")

module.OPTS = 
{
    entries = 'entries', -- an array of the searchable entries
    query = 'query', -- the query to search over the entries
    limit = 'limit', -- the limit for the results to return
    key = 'key', -- the key of the entries to perform the search to
    showAll = 'showAll'
}

function module.search(opts)
    local default = {
        entries = {},
        query = {},
        key = 'name',
        limit = 10, -- false or number
        showAll = true,
    }
    opts = Table.merge(default, opts)

    local results = {}
    if opts.query == "" and not opts.showAll  then
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