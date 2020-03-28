# dev notes
## require: relative path
  see https://forum.cockos.com/showthread.php?t=190342
  `package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."?.lua;".. package.path`
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

## TODOs
 - [ ] moving everything to src/ ?
 - [x] create an action to insert region item
   creates a midi item with a pan envelope going from hard left to hard right
   it helps visualizing "subregion" items
 - [ ] region item: add midi text events: count 16th notes (or x.. user input)]
 - [ ] recheck the midi item arrangement
   - item copy bug? if so, post at reaper forum
 - [ ] item arrangement 2 midi
 - [ ] merge to dev
 - [ ] fix color swatch..?
 - [ ] add reapack functionality