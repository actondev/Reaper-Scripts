package.path = './test/?.lua;' .. package.path

lu = require('luaunit')
midi = require('legacy.deps.midi_helper')

midiStructure01 = {
    item = {tstart = 2.0, tend = 5.0},
    frequencies = {
        -- note: it couldbe that a note/f tstart is even less than the item tstart
        -- that happens when the midi item has a start offset
        {f = 120, tstart = 2.0, tend = 3.0},
        {f = 130, tstart = 3.0, tend = 4.0},
        {f = 130, tstart = 4.0, tend = 5.0},
        {f = 135, tstart = 3.5, tend = 4.0},
        {f = 199, tstart = 0.0, tend = 10.0}, -- for example tstart should be converted to 2 and end to 5
        {f = 200, tstart = 6.0, tend = 10.0}, -- should be filtered out, outside of the item
        {f = 201, tstart = 0.0, tend = 1.0}-- should be filtered out, outside of the item
    }
}

function testRelativeTimings()
    local actual = midi.midiStructureToRelativeTimings(midiStructure01, 3.5)
    local expected = {
        frequencies = {
            {f = 120, tend = -0.5, tstart = -1.5},
            {f = 130, tend = 0.5, tstart = -0.5},
            {f = 130, tend = 1.5, tstart = 0.5},
            {f = 135, tend = 0.5, tstart = 0},
            {f = 199, tend = 1.5, tstart = -1.5}-- note: it got "cropped" in the midi borders
        },
        item = {tend = 1.5, tstart = -1.5}
    }
    lu.assertEquals(actual, expected)
end

function testOrderingForCurrentPlaying()
    local midiStructure = {
        frequencies = {
            {f = 2, tstart = 1.0, tend = 1.5}, -- future
            {f = 3.5, tstart = 0.0, tend = 2.0}, -- current, should be higher priority?
            {f = 3, tstart = -1.0, tend = 2.0}, -- current
            {f = 1, tstart = -1.0, tend = -3.0}, -- past
        }
    }
    
    local expected = {
        {f = 1, tstart = -1.0, tend = -3.0}, -- past
        {f = 2, tstart = 1.0, tend = 1.5}, -- future
        {f = 3.5, tstart = 0.0, tend = 2.0}, -- current, should be higher priority? (TODO)
        {f = 3, tstart = -1.0, tend = 2.0}, -- current
    }
    midi.orderForCurrentPlayingPriority(midiStructure)
    -- print(midiStructure01)
    lu.assertEquals(midiStructure.frequencies, expected)
end

function testReorder2()
    local midiStructure = {["frequencies"] = {
        [1] = {["f"] = 2, ["tstart"] = -2.105263157909, ["tend"] = -0.099186769015821, },
        [2] = {["f"] = 1, ["tstart"] = -1.8752284356863, ["tend"] = -0.92470760235093, },
        [3] = {["f"] = 4, ["tstart"] = 0.39473684209635, ["tend"] = 2.1716465643224, },
        [4] = {["f"] = 3, ["tstart"] = 2.9008132309906, ["tend"] = 4.0674798976598, }, }, }
    midi.orderForCurrentPlayingPriority(midiStructure)
    local expected = {
        {f = 1, tend = -0.92470760235093, tstart = -1.8752284356863},
        {f = 2, tend = -0.099186769015821, tstart = -2.105263157909},
        {f = 3, tend = 4.0674798976598, tstart = 2.9008132309906},
        {f = 4, tend = 2.1716465643224, tstart = 0.39473684209635}
    }
    lu.assertEquals(midiStructure.frequencies, expected)

end

function testNormalizedKey()
    lu.assertEquals(midi.getNormalizedKey(130, midiStructure01), 130 / 2)
    lu.assertEquals(midi.getNormalizedKey(60, midiStructure01), 120)
    lu.assertEquals(midi.getNormalizedKey(30, midiStructure01), 120)
end

function testNormalizedKeys()
    -- 120 minF, 201 maxF
    lu.assertEquals(midi.getNormalizedKeys(130, midiStructure01), {low = 130 / 2, high = 130*2})
    lu.assertEquals(midi.getNormalizedKeys(60, midiStructure01), {low=120, high=240})
end

os.exit(lu.LuaUnit.run())
