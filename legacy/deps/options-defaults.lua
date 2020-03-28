--[[
-------------------------------------
DEFAULT OPTIONS: DO NOT EDIT FILE
might and SHOULD get overwritten when you update the scripts
-------------------------------------

Make a copy of this file (in the same folder) and name it to 'options.lua'
then edit that file as you plase


** quantizeThreshold **
Having some tolerance to the start/end of media items
Some times some glitches happen and items starts/ends just miliseconds off by the start/end
of the region edges (usually caused by splitting items in region item borders).
This thresholds automatically quantizes items, so no unnecessary splts are
to happen. (could result in almost zero length items).
Set to zero to skip this feature (note that you get informed if quantizing happend)


** keepStartingIn **
Set to true if you want to keep items that start inside the region edges
Set to nil or 0 to get prompt

** keepEndingIn **
Set to true if you want to keep items that start inside the region edges
ILL ADVISED TO SET TO TRUE, copying becomes fiddly

Note: if keepStartingIn is true and keepEnding in is false,
items that start outside the region area, but ending in will be splitted (no prompt)

Each script has its own set of settings
]]

RegionSelect = {
	quantizeThreshold = 0.001,
	keepStartingIn = nil,
	keepEndingIn = nil
}

RegionCopyScanPaste = {
	quantizeThreshold = 0.001,
	keepStartingIn = nil,
	keepEndingIn = false
}

CommonOptions = {
	alertOnQuantize = true
}