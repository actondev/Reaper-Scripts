local module = {}

module.CHAR = {
	EXIT = -1,
    ESCAPE		= 27,

    SPACE		= 32,
    BACKSPACE	= 8,
    TAB			= 9,
    HOME		= 1752132965,
    END			= 6647396,
    INSERT		= 6909555,
    DELETE		= 6579564,
    PGUP		= 1885828464,
    PGDN		= 1885824110,
    RETURN		= 13,
    UP			= 30064,
    DOWN		= 1685026670,
    LEFT		= 1818584692,
    RIGHT		= 1919379572,

    F1			= 26161,
    F2			= 26162,
    F3			= 26163,
    F4			= 26164,
    F5			= 26165,
    F6			= 26166,
    F7			= 26167,
    F8			= 26168,
    F9			= 26169,
    F10			= 6697264,
    F11			= 6697265,
    F12			= 6697266
}

function module.isPrintable(code)
    return code >=32 and code <=254
end

return module