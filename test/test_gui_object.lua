package.path = "./test/?.lua;" .. "./src/?.lua;" .. package.path

local lu = require("luaunit")
local Log = require("aod.utils.log")
local Gui = require("aod.gui.v1.core")
Log.LEVEL = Log.DEBUG

function test_watch()
    local watchCounter = 0
    local obj = Gui.Object({foo = "bar"})
    obj:watch(
        "foo",
        function(el, oldValue, newValue)
            watchCounter = watchCounter + 1
        end
    )

    -- setting to same value won't do anything
    obj:set("foo", "bar")
    lu.assertEquals(watchCounter, 0)
    obj:set("foo", "bar2")
    lu.assertEquals(watchCounter, 1)
    -- again, not calling callback
    obj:set("foo", "bar2")
    lu.assertEquals(watchCounter, 1)

    -- however, can trigger callback if 3rd parameter 'force' is set to true
    obj:set("foo", "bar2", true)
    lu.assertEquals(watchCounter, 2)
end

function test_watch_mod()
    local watchCounter = 0
    local obj = Gui.Object({foo = "notbar", mod = {isFooBar = false, mirrorFoo = "waitforit"}})
    obj:watch_mod(
        "foo",
        function(el, oldValue, newValue)
            watchCounter = watchCounter + 1
            if newValue == "bar" then
                return {
                    [{"mod", "isFooBar"}] = true,
                    [{"mod", "mirrorFoo"}] = "bar"
                }
            end
            -- the "else return nil" can be skipped
        end
    )

    lu.assertEquals(obj.data.mod.isFooBar, false)
    lu.assertEquals(obj.data.mod.mirrorFoo, "waitforit")
    obj:set("foo", "bar")
    lu.assertEquals(obj.data.mod.isFooBar, true)
    lu.assertEquals(obj.data.mod.mirrorFoo, "bar")

    obj:set("foo", "bar..kinda")
    lu.assertEquals(obj.data.mod.isFooBar, false)
    lu.assertEquals(obj.data.mod.mirrorFoo, "waitforit")

    lu.assertEquals(watchCounter, 2)
end

function test_signals()
    local received = nil
    local obj = Gui.Object()

    obj:on("dada", function(el, data)
        received = data
    end)

    lu.assertEquals(received, nil)
    obj:emit("dada", "here's your dada")
    lu.assertEquals(received, "here's your dada")

    -- nothing should happen here
    obj:emit("invalid")
end

os.exit(lu.LuaUnit.run())
