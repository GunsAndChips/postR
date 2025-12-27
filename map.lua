Map = {}
Map.__index = Map

function Map:New(mapDefinition)
    Config.tile.height = mapDefinition.tileheight
    Config.tile.width = mapDefinition.tilewidth - (Config.tile.staggerX - 1)

    local this = {
        tiles = {mapDefinition.layers[1].data},
        widthInTiles = mapDefinition.width,
        heightInTiles = mapDefinition.height,
        tileHeight = Config.tile.height,
        tileWidth = Config.tile.width,
        tileStaggerX = Config.tile.staggerX
    }
    setmetatable(this,self)

    this.screenWidth = (this.widthInTiles) * this.tileWidth
    this.screenHeight = (this.heightInTiles) * this.tileHeight

    this.offsetX = 0-- -this.screenWidth / 2
    this.offsetY = 0-- -this.screenHeight / 2

    return this
end

function Map:Render()
    love.graphics.setColor(1, 1, 1)
    
    for row=1,self.heightInTiles do
        for col=1, self.widthInTiles do
            --Stagger each row to the left? for parallelogram tiling
            local staggerX = -self.tileStaggerX * row+1

            local tileX = (col-1) * self.tileWidth + self.offsetX + staggerX
            local tileY = (row-1) * self.tileHeight + self.offsetY
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