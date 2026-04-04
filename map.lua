Map = {}
Map.__index = Map

function Map:New(mapDefinition)
    Config.tile.height = mapDefinition.tileheight
    Config.tile.width = mapDefinition.tilewidth

    local this = {
        tiles = {
            mapDefinition.layers[1].data,
            mapDefinition.layers[2].data
        },
        widthInTiles = mapDefinition.width,
        heightInTiles = mapDefinition.height,
        tileHeight = Config.tile.height,
        tileWidth = Config.tile.width,
        tileStaggerX = mapDefinition.skewx
    }
    setmetatable(this, self)

    this.screenWidth = (this.widthInTiles) * this.tileWidth
    this.screenHeight = (this.heightInTiles) * this.tileHeight

    return this
end

function Map:Render()
    love.graphics.setColor(1, 1, 1)

    -- Apply map transform
    love.graphics.push()
    love.graphics.applyTransform(MapTransform)

    for row = 1, self.heightInTiles do
        for col = 1, self.widthInTiles do
            -- Stagger each row to the left for oblique tiling
            local staggerX = self.tileStaggerX * row + 1

            local tileX = (col - 1) * self.tileWidth + staggerX
            local tileY = (row - 1) * self.tileHeight

            for layer = 1, #self.tiles do
                local tile = self:GetTile(col, row, layer)
                local tileId, flipX, flipY, flipD = GetTileFlips(tile)

                if tile > 0 then
                    love.graphics.push()

                    -- With oblique tiling, we can only do 180 degree rotations (we either flip horiztonal AND vertical, or neither)
                    if flipX and flipY then
                        love.graphics.scale(-1,-1)
                        love.graphics.translate(- 2 * (tileX + 1) - self.tileWidth, -2 * tileY - self.tileHeight)
                    end

                    love.graphics.draw(TileSheet, TileQuads[tileId], tileX, tileY)
                    love.graphics.pop()
                end
            end
        end
    end
    love.graphics.pop()
end

function Map:GetTile(x, y, layer)
    layer = layer or 1
    -- Check if tile is out of bounds
    if self:CheckIfTileIsOutOfBounds(x, y) then
        return -1
    end

    return self.tiles[layer][(y - 1) * (self.widthInTiles) + x]
end

function Map:SetTile(x, y, layer, newTileId, clearUpperLayers)
    -- Check if tile is out of bounds
    if self:CheckIfTileIsOutOfBounds(x, y) then
        return
    end

    -- Set defaults for optional params
    layer = layer or 1
    clearUpperLayers = clearUpperLayers or true

    self.tiles[layer][(y - 1) * (self.widthInTiles) + x] = newTileId
    if clearUpperLayers and layer < #self.tiles then
        log.debug("Clearing upper layers above layer: " .. layer)
        for i = layer + 1, #self.tiles do
            self:SetTile(x, y, i, 0, false)
        end
    end
end

function Map:CheckIfTileIsOutOfBounds(x, y)
    if self.widthInTiles == nil or self.heightInTiles == nil then
        log.warning("Unable to check if tile is in bounds of map, as Map does not have widthInTiles or heightInTiles set.")
        return
    end
    if x < 1 or y < 1 or x > self.widthInTiles or y > self.heightInTiles then
        return true
    end
    return false
end

function Map:SetTileIfMatch(x, y, layer, newTileId, tileIdsToMatch)
    if #tileIdsToMatch < 1 then
        return
    end

    log.debug("Getting the value of the tile at coordinates: " .. x .. ", " .. y)
    local existingTileId = self:GetTile(x, y, layer)
    log.debug("Checking if the value (" .. existingTileId .. ") is in ", tileIdsToMatch)
    for i = 0, #tileIdsToMatch do
        if existingTileId == tileIdsToMatch[i] then
            self:SetTile(x, y, layer, newTileId)
            return
        end
    end
    log.debug("Tile's existing value was not in tileIdsToMatch, unable to set tile to " .. newTileId)
end

function GetTileFlips(tileGID)
    local isFlippedHorizontal, isFlippedVertical, isFlippedDiagonal = false, false, false

    if tileGID > 2 ^ 31 then
        tileGID = tileGID - 2 ^ 31
        isFlippedHorizontal = true
    end
    if tileGID > 2 ^ 30 then
        tileGID = tileGID - 2 ^ 30
        isFlippedVertical = true
    end
    if tileGID > 2 ^ 29 then
        tileGID = tileGID - 2 ^ 29
        isFlippedDiagonal = true
    end

    return tileGID, isFlippedHorizontal, isFlippedVertical, isFlippedDiagonal
end
