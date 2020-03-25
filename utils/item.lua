local item = {}

function item.chunk(item)
    local retval, itemChunk =  reaper.GetItemStateChunk(item, '')
    return itemChunk
end

function item.position(item)
    return reaper.GetMediaItemInfo_Value( item, "D_POSITION")
end

return item;