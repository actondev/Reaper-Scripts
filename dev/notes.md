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