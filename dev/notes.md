# dev notes
## require: relative path
  see https://forum.cockos.com/showthread.php?t=190342
  `package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."?.lua;".. package.path`
## Interactive Reascript (repl) one liners
 - `_, chunk = reaper.GetItemStateChunk(reaper.GetSelectedMediaItem(0, 0), '')`