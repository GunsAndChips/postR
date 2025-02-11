Map = {}
Map.__index = Map

function Map:New(data,width,height)
    if(#data ~= width*height) then
        error("OI BEN: Map size doesn't match height and width.")
    end

    local this = {
        tiles = data,
        widthInTiles = width,
        heightInTiles = height,
        screenCellHeight = 12,
        screenCellWidth = 16,
        screenCellStaggerX = 4
    }
    setmetatable(this,self)

    this.screenWidth = (this.widthInTiles) * this.screenCellWidth
    this.screenHeight = (this.heightInTiles) * this.screenCellHeight

    this.offsetX = PIXEL_WIDTH / 2 - this.screenWidth / 2
    this.offsetY = PIXEL_HEIGHT / 2 - this.screenHeight / 2

    return this
end

function Map:Render()
    love.graphics.setColor(1, 1, 1)
    for row=1,self.heightInTiles do
        for col=1, self.widthInTiles do
            local staggerX = -self.screenCellStaggerX * row + self.screenCellStaggerX * self.heightInTiles --Stagger each row 'screenCellStaggerX' pixels right for parallelogram tiling
            local tileX = (col-1) * self.screenCellWidth + self.offsetX + staggerX
            local tileY = (row-1) * self.screenCellHeight + self.offsetY
            local tile = self:GetTile(col,row)

            if tile > 0 then
                love.graphics.drawLayer(TileSprites, tile, tileX, tileY)
            end
        end
    end
end

function Map:GetTile(x,y)
    if x < 1 or y < 1 or x > self.widthInTiles or y > self.heightInTiles then
        return -1
    end

    return self.tiles[(y - 1) * (self.widthInTiles) + x]
end