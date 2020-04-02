package.path = "./test/?.lua;" .. "./src/?.lua;" .. package.path

local lu = require("luaunit")
local Search = require("aod.search")
local Log = require("utils.log")
Log.isdebug = true
local entries = {
    {name = "split items"},
    {name = "copy"},
    {name = "paste"},
    {name = "copy items"},
    {name = "paste items"}
}

function testSearch()
    local res =
        Search.search(
        {
            entries = entries,
            limit = 2,
            query = "item",
            key = "name"
        }
    )
    lu.assertEquals(2, #res)
    lu.assertEquals("split items", res[1]["name"])
    lu.assertEquals("copy items", res[2]["name"])
end

function testSearchNoQuery()
    local res =
        Search.search(
        {
            entries = entries,
            limit = false,
            query = "",
            key = "name",
            emptyWhenNoQuery = false
        }
    )
    lu.assertEquals(5, #res)
    lu.assertEquals("split items", res[1]["name"])
    lu.assertEquals("copy", res[2]["name"])
    lu.assertEquals("paste items", res[5]["name"])

    local res2 =
        Search.search(
        {
            entries = entries,
            limit = false,
            query = "",
            key = "name",
            emptyWhenNoQuery = true
        }
    )
    lu.assertEquals(0, #res2)
end

os.exit(lu.LuaUnit.run())
