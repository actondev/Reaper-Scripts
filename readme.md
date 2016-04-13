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
Usage of Reaper's `empty items` to create **Region items!**
![Alt text](http://i.imgur.com/swu4UMv.gif)
  + `Multi double click` (for double clicking item)
  + `Region Copy & Scan Paste`
  + `Region Item Select`
  + `Escape` (multi tool to clear time sel, track sel, item sel PLUS remove temp items created for region copying
  
> More than just using region items on folder tracks, you can use them on tracks
 + whose title begin with `*` : select across all tracks (`*SONG` track in demo gif)
 + whose title begin with `^` : select the children of this tracks parent
 + whose title begin with `>` : select folling n tracks (siblings) (eg >2 will make selection on the next 2 tracks)
>
> Tracks whose title begin with `-` will be ignored from the selections (useful when making selection from `*SONG` tracks,and you want to ignore a Temporary track)

### Coloring ###

  + `Random Color`
  + `Color Swatch` (customizable, based on an image swatch.png.. Just replace it :D)
Other
![Color Swatch](http://i.imgur.com/W0aPDZM.gif)

### FX Routing Matrix (MAD credits to eugen2777, also to DarkStar for his mod) ###

![FX Routing demo](http://i.imgur.com/JU5JZTe.gif)
See how all the fx are routed for the selected track/take (yeah Reaper has take FX :D)

> Uses your current theme colors only if the theme is extracted (does not work with .ReaperThemeZip files

Take FX functionality is a little limited compared to Track FX because of current API limitations (for now).

### Notes to self ###

#### Mouse modifiers ####

*(!! Essential, trust me :D)*
`Media item double click`: Multi double click

#### Keyboard mappings ####

`Esc` : Escape  
 `~`  : Folder track toggle Focus  
`Alt+S` : Select folder track (useful for multiple, else just use double click)  
`Alt+C` :_Region Copy & Scan Paste  
`C` : Random Color  
`Shift+C` : Color Swatch  
`Alt+F` : Fx Routing Matrix  
