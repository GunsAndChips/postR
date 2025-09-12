Map = {}
Map.__index = Map

function Map:New(mapDefinition)
    local this = {
        tiles = {mapDefinition.layers[1].data},
        widthInTiles = mapDefinition.width,
        heightInTiles = mapDefinition.height,
        tileHeight = mapDefinition.tileheight,
        tileWidth = 16,
        tileStaggerX = 3
    }
    setmetatable(this,self)

    this.screenWidth = (this.widthInTiles) * this.tileWidth
    this.screenHeight = (this.heightInTiles) * this.tileHeight

    this.offsetX = -this.screenWidth / 2
    this.offsetY = -this.screenHeight / 2

    return this
end

function Map:Render(cameraOffset)
    love.graphics.setColor(1, 1, 1)

    local pixelPerfectOffset = {}
    pixelPerfectOffset.x = 0
    pixelPerfectOffset.y = 0

    -- DONT LIKE THIS METHOD OF PIXEL PERFECTNESS, IT MAKES THE WHOLE BACKGROUND JITTERY. todo: TRY MAKING PLAYER JITTER AND BG SMOOTH
    if Config.movement.pixelPerfect then
        pixelPerfectOffset.x = math.floor(cameraOffset.x+0.5)-cameraOffset.x
        pixelPerfectOffset.y = math.floor(cameraOffset.y+0.5)-cameraOffset.y
    end

    for row=1,self.heightInTiles do
        for col=1, self.widthInTiles do
             --Stagger each row 'screenCellStaggerX' pixels right for parallelogram tiling
            local staggerX = -self.tileStaggerX * row + self.tileStaggerX * self.heightInTiles

            local tileX = (col-1) * self.tileWidth + self.offsetX + staggerX + cameraOffset.x + pixelPerfectOffset.x
            local tileY = (row-1) * self.tileHeight + self.offsetY + cameraOffset.y + pixelPerfectOffset.y
            local tile = self:GetTile(col,row)

            if tile >= 0 then
                love.graphics.drawLayer(TileSprites, tile, tileX, tileY)
            end
        end
    end
end

function Map:GetTile(x,y,layer)
    layer = layer or 1
    if x < 1 or y < 1 or x > self.widthInTiles or y > self.heightInTiles then
        return -1
    end

    return self.tiles[layer][(y - 1) * (self.widthInTiles) + x]
end