local Json = require('lib.json')

local module = {}

function module.parsedTaggedJson(text, tag)
    --[[
    local spaceOrLines = "[ \n\r]*"
    local catchJsonArrayOrObject = "([%[{].+[%]}])"
    local pattern = tag .. spaceOrLines .. catchJsonArrayOrObject
    ]]
    local pattern = tag .. "[ \n\r]*([%[{].+[%]}])"
    return Json.parse(string.match(text, pattern))
end

return module