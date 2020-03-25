local helper = require('ActonDev.utils.helper')
local navigation = {}

function navigation.storeEditCursorPosition()
    helper.reaperCMD('_XENAKIOS_DOSTORECURPOS')
end

function navigation.recallEditCursorPosition()
    helper.reaperCMD('_XENAKIOS_DORECALLCURPOS')
end

return navigation