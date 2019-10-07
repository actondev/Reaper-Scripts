package.path = './test/?.lua;' .. package.path

lu = require('luaunit')
midi = require('deps.midi_helper')

midiStructure01 = {
    item = {tstart = 2.0, tend = 5.0},
    frequencies = {
        {f = 120, tstart = 2.0, tend = 3.0},
        {f = 130, tstart = 3.0, tend = 4.0},
        {f = 135, tstart = 3.5, tend = 4.0}
    }
}

function testMidiHelper()
    local actual = midi.relevantFrequenciesFromMidiStructure(midiStructure01,3.5)
    local expected = {
        frequencies={{f=130, tend=0.5, tstart=-0.5}, {f=135, tend=0.5, tstart=0}},
        item={tend=1.5, tstart=-1.5}
    }
    lu.assertEquals(actual, expected)
end

os.exit(lu.LuaUnit.run())
