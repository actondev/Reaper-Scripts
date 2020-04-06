package.path = "./test/?.lua;" .. "./src/?.lua;" .. package.path

local lu = require("luaunit")
local Log = require("aod.utils.log")
local Table = require("aod.utils.table")
Log.LEVEL = Log.DEBUG

function test_getIn()
    local t = {
        text = "blah",
        fg = {
            r = 1,
            g = 0,
            b = 0
        },
        bg = {
            r = 0,
            g = 1,
            b = 0
        }
    }

    lu.assertEquals(Table.getIn(t, {"text"}), "blah")
    lu.assertEquals(Table.getIn(t, {"fg", "r"}), 1)
    lu.assertEquals(Table.getIn(t, {"fg", "g"}), 0)
    lu.assertEquals(Table.getIn(t, {"bg", "g"}), 1)
    local path = {"bg", "g"}
    lu.assertEquals(Table.getIn(t, path), 1)
    -- assert that the passed keys is immutable
    lu.assertEquals(#path, 2)
    lu.assertEquals(path[1], "bg")
end

function test_setIn()
    local t = {
        text = "blah",
        fg = {
            r = 1,
            g = 0,
            b = 0
        },
        bg = {
            r = 0,
            g = 1,
            b = 0
        }
    }
    lu.assertEquals(Table.getIn(t, {"text"}), "blah")
    Table.setIn(t, {"text"}, "blah2")
    lu.assertEquals(Table.getIn(t, {"text"}), "blah2")

    local path = {"fg", "r"}
    Table.setIn(t, path, 1.1)
    Log.debug(t)
    lu.assertEquals(Table.getIn(t, path), 1.1)
    lu.assertEquals(Table.getIn(t, {"fg", "r"}), 1.1)


end

os.exit(lu.LuaUnit.run())
