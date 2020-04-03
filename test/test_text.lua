package.path = "./test/?.lua;" .. "./src/?.lua;" .. package.path

local lu = require("luaunit")
local Text = require('aod.gui.v1.text')
local Log = require('aod.utils.log')
local Chars = require("aod.gui.v1.chars")
local function char(str)
    return string.byte(str, 1)
end

function testSimpleInput()
    local text = Text("")
    text:handle(char("h"))
    text:handle(char("i"))

    lu.assertEquals(text:getText(), "hi")
end

function testBackspace()

    local text = Text("")
    text:handle(char("h"))
    text:handle(char("i"))
    lu.assertEquals(text:getTextWithCursor(), "hi|")
    -- Log.LEVEL = Log.DEBUG
    text:handle(Chars.CHAR.BACKSPACE)
    lu.assertEquals(text:getText(), "h")
end

function testBeginning()
    local text = Text("")
    text:handle(char("a"))
    text:handle(char("b"))
    text:handle(char("c"))
    text:handle(Chars.CHAR.LEFT)
    lu.assertEquals(text:getTextWithCursor(), "ab|c")
    text:handle(Chars.CHAR.LEFT)
    -- lu.assertEquals(text:getTextWithCursor(), "a|bc")
    text:handle(Chars.CHAR.LEFT)
    lu.assertEquals(text:getTextWithCursor(), "|abc")
    lu.assertEquals(0,text:getCursor())
    -- should not keep going backwards
    text:handle(Chars.CHAR.LEFT)
    lu.assertEquals(text:getTextWithCursor(), "|abc")
    lu.assertEquals(0,text:getCursor())

    -- and backspace should have no effect
    text:handle(Chars.CHAR.BACKSPACE)
    lu.assertEquals(text:getTextWithCursor(), "|abc")
    lu.assertEquals(0,text:getCursor())
    -- but going right and backspace yeah
    text:handle(Chars.CHAR.RIGHT)
    text:handle(Chars.CHAR.BACKSPACE)
    lu.assertEquals(text:getTextWithCursor(), "|bc")
    lu.assertEquals(0,text:getCursor())

    Log.LEVEL = Log.DEBUG
    text:handle(Chars.CHAR.DELETE)
    lu.assertEquals(text:getTextWithCursor(), "|c")
end

function testMultiple()
    local text = Text("")
    lu.assertEquals(0,text:getCursor())
    text:handle(char("a"))
    text:handle(char("b"))
    text:handle(char("c"))
    text:handle(char("d"))
    lu.assertEquals(text:getText(), "abcd")
    lu.assertEquals(4,text:getCursor())
    lu.assertEquals(text:getTextWithCursor(), "abcd|")

    text:handle(Chars.CHAR.LEFT)
    lu.assertEquals(3,text:getCursor())
    lu.assertEquals(text:getTextWithCursor(), "abc|d")

    text:handle(Chars.CHAR.BACKSPACE)
    lu.assertEquals(text:getTextWithCursor(), "ab|d")
    lu.assertEquals(text:getText(), "abd")
    text:handle(char("c"))
    lu.assertEquals(text:getTextWithCursor(), "abc|d")
    lu.assertEquals(text:getText(), "abcd")
    text:handle(Chars.CHAR.RIGHT)
    text:handle(char("e"))
    lu.assertEquals(text:getTextWithCursor(), "abcde|")
    lu.assertEquals(text:getText(), "abcde")
    text:handle(Chars.CHAR.RIGHT)
    text:handle(char("f"))
    lu.assertEquals(text:getText(), "abcdef")
    lu.assertEquals(text:getTextWithCursor(), "abcdef|")
    lu.assertEquals(6,text:getCursor())
    text:handle(Chars.CHAR.LEFT)
    text:handle(Chars.CHAR.LEFT)
    lu.assertEquals(4,text:getCursor())
    lu.assertEquals(text:getTextWithCursor(), "abcd|ef")
end

os.exit(lu.LuaUnit.run())