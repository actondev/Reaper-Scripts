local Common = require('utils.common')
local module = {}

function module.storeEditCursorPosition()
    Common.cmd('_XENAKIOS_DOSTORECURPOS')
end

function module.recallEditCursorPosition()
    Common.cmd('_XENAKIOS_DORECALLCURPOS')
end

return module