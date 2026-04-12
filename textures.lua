-- Cuts up a tilesheet into individual tiles/quads
function CreateQuads(tilesheet, tileWidth, tileHeight, pad, includeextrapadding)
    if tileWidth == nil or tileWidth <= 0 then
        error("Cannot create quads - tileWidth must be > 1")
    elseif tileHeight == nil or tileHeight <= 0 then
        error("Cannot create quads - tileHeight must be > 1")
    end

    pad = pad or 0
    includeextrapadding = includeextrapadding or false

    local extra = 0
    if includeextrapadding then
        extra = 1
    end
    local quads = {}

    local totalRows = math.floor((tilesheet:getHeight() - pad) / (tileHeight + pad))
    local totalColumns = math.floor((tilesheet:getWidth() - pad) / (tileWidth + pad))

    for i = 0, totalRows - 1 do
        for j = 0, totalColumns - 1 do
            local quad = love.graphics.newQuad(pad + j * (tileWidth + 2 * pad), pad + i * (tileHeight + 2 * pad), tileWidth + extra, tileHeight + extra, tilesheet:getDimensions())
            table.insert(quads, quad)
        end
    end

    return quads
end
