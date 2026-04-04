-- Cuts up a tilesheet into individual tiles/quads
function CreateQuads(tilesheet, tileWidth, tileHeight)
    local quads = {}

    local rows = math.floor(tilesheet:getHeight() / (tileHeight + 1))
    local columns = math.floor(tilesheet:getWidth() / (tileWidth + 1))

    for i = 0, rows - 1 do
        for j = 0, columns - 1 do
            local quad = love.graphics.newQuad(j * (tileWidth + 1), i * (tileHeight + 2), tileWidth, tileHeight, tilesheet:getDimensions())
            table.insert(quads, quad)
        end
    end

    return quads
end