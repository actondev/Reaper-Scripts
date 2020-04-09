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

## traceback
``` lua
local crash = function(errObject)
   local byLine = "([^\r\n]*)\r?\n?"
   local trimPath = "[\\/]([^\\/]-:%d+:.+)$"
   local err = errObject and string.match(errObject, trimPath) or "Couldn't get error message."

   local trace = debug.traceback()
   local stack = {}
   for line in string.gmatch(trace, byLine) do
      local str = string.match(line, trimPath) or line
      stack[#stack + 1] = str
   end

   local name = ({reaper.get_action_context()})[2]:match("([^/\\_]+)$")

   local ret =
      reaper.ShowMessageBox(
      name .. " has crashed!\n\n" .. "Would you like to have a crash report printed " .. "to the Reaper console?",
      "Oops",
      4
   )

   if ret == 6 then
      reaper.ShowConsoleMsg(
         "Error: " ..
            err ..
               "\n\n" ..
                  "Stack traceback:\n\t" ..
                     table.concat(stack, "\n\t", 2) ..
                        "\n\n" ..
                           "Reaper:       \t" .. reaper.GetAppVersion() .. "\n" .. "Platform:     \t" .. reaper.GetOS()
      )
   end
end


local function Main()
   xpcall(
      function()
-- CODE HERE--
,
      crash
   )
end
```

## Running the tests
On windows
- install lua53 with chocolatey `install lua53`
- on the root folder of this git project run `lua53.exe test/test*.lua`

example `.vscode/tasks/json` for vscode development
``` json
{
    "tasks": [
        {
            "label": "lua tests",
            "type": "shell",
            "command" : "for f in test/test*.lua; do lua53.exe $f -v; done",
            "group": {
                "isDefault": true,
                "kind": "test"
            }
        }
    ]
}
```