# ActonDev Scripts #
[Download latest version](https://github.com/actonDev/Reaper-Scripts/archive/master.zip)

Installation instructions:
[Download](https://github.com/actonDev/Reaper-Scripts/archive/master.zip) and unzip on folder named "ActonDev" on your "Scripts" folder. Please download whole zip and always have the full deps folder. You can ignore/delete 'ActonDev_xxxx.lua' files if you want, but no others.

**NOTICE** It'CaSe SeNsItIvE : **A**cton**D**ev

Example Structure
```
Directory <Reaper Resources>/Scripts/ActonDev
|   Actondev_Color Swatch.lua
|   ...
|   ActonDev_Region Copy & Scan Paste.lua
|   ActonDev_Region Item Select.lua
|   readme.md
|   ...
\---deps
        ...
        options-defaults.lua
        region.lua
        template.lua
        ...
```

You can make a copy of the `options-defaults.lua` and name it `options.lua`. This will overwrite some default options that have been set.

## Requirements ##
  + [REAPER](http://www.cockos.com/reaper/download.php) v5.18+
  + [SWS extensions](http://www.sws-extension.org/) v2.8.3 +

## List of Scripts ##

### Regions ###

![Alt text](http://i.imgur.com/swu4UMv.gif)
  + `Multi double click` (for double clicking item)
  + `Region Copy & Scan Paste`
  + `Region Item Select`
  + `Escape` (multi tool to clear time sel, track sel, item sel PLUS remove temp items created for region copying

### Coloring ###

  + `Random Color`
  + `Color Swatch` (customizable, based on an image swatch.png.. Just replace it :D)
Other
![Color Swatch](http://i.imgur.com/W0aPDZM.gif)

### FX Routing Matrix (MAD credits to eugen2777, also to DarkStar for his mod) ###

![FX Routing demo](http://i.imgur.com/JU5JZTe.gif)


### Notes to self ###

#### Mouse modifiers ####

*(!! Essential, trust me :D)*
`Media item double click`: Multi double click

#### Keyboard mappings ####

`Esc`: Escape  
`~`: Folder track toggle Focus  
`Alt+S`: Select folder track (useful for multiple, else just use double click)  
`Alt+C`: _Region Copy & Scan Paste  
`C`: Random Color  
`Shift+C`: Color Swatch  
`Alt+F`: Fx Routing Matrix  
