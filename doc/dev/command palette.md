# Command palette
https://github.com/ReaTeam/ReaScripts/blob/7df08ad58eb5aedc8d9431a87d28a1fc4b95fc8e/Development/Lokasenna_GUI%20v2/Library/Classes/Class%20-%20Textbox.lua#L247
``` lua
    -- Typeable chars
    elseif GUI.clamp(32, char, 254) == char then

        if self.sel_s then self:deleteselection() end

        self:insertchar(char)

    end
```