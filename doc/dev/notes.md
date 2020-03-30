# dev notes
## require: relative path
  see https://forum.cockos.com/showthread.php?t=190342
  `package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."?.lua;".. package.path`

  my previous solution
  `package.path = reaper.GetResourcePath().. package.config:sub(1,1) .. '?.lua;' .. package.path`

## Interactive Reascript (repl) one liners
 - `_, chunk = reaper.GetItemStateChunk(reaper.GetSelectedMediaItem(0, 0), '')`

## Reversing media item
  Ended up using the reaper action, but this what I got so far
  ``` lua
    local take = reaper.GetActiveTake(item)
    local _retval, section, start, length, fade, reverse = reaper.BR_GetMediaSourceProperties( take )
    reaper.BR_SetMediaSourceProperties( take, section, start, length, fade, not reverse )
    local itemLength = module.getInfo(item, module.PARAM.LENGTH)
    reaper.SetMediaItemTakeInfo_Value(take, module.TAKE_PARAM.START_OFFSET, itemLength)
  ```
## Reascript bugs?
  Apparently there are bugs concering splitting:
  I should always check if my selected item count is 0 or greater. If 0 DO NOT SPLIT

## Colorizing
  Old piece of code that was to get deleted
  ``` lua
    -- if colorizing a track, rtconfig "tcp.trackidx.color ?trackcolor_valid" does not work,
    -- 		gotta redraw/update the TCP (Track Control Panel)
    function TcpRedraw()
      -- credits: found in a X-Raym script, crediting HeDa in turn.. thanks both! :D
      reaper.PreventUIRefresh(1)
      local track=reaper.GetTrack(0,0)
      local trackparam=reaper.GetMediaTrackInfo_Value(track, "I_FOLDERCOMPACT")	
      if trackparam==0 then
        reaper.SetMediaTrackInfo_Value(track, "I_FOLDERCOMPACT", 1)
      else
        reaper.SetMediaTrackInfo_Value(track, "I_FOLDERCOMPACT", 0)
      end
      reaper.SetMediaTrackInfo_Value(track, "I_FOLDERCOMPACT", trackparam)
      reaper.PreventUIRefresh(-1)
    end
  ```



## TODOs
 - [x] moving everything to src/ ?
 - [x] create an action to insert region item
   creates a midi item with a pan envelope going from hard left to hard right
   it helps visualizing "subregion" items
 - [x] region item: add midi text events: count 16th notes (or x.. user input)]
 - [x] region item: can copy a subregion and update a whole region
 - [ ] insert region item: should disable the 'loop source' option
 - [ ] recheck the midi item arrangement
   - item copy bug? if so, post at reaper forum
 - [ ] item arrangement 2 midi
 - [x] merge to dev
 - [x] fix color swatch..?
 - [ ] add reapack functionality
 - [x] remove reaper undo/preventUiRefresh etc from utils/region_item.lua