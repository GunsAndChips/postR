Map = {}
Map.__index = Map

function Map:New(data,width,height)
    --if(data.getn() ~= width*height) then
    --    return -1
    --end

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

    this.offsetX = 0 --SCREEN_WIDTH / 2 - this.screenWidth / 2
    this.offsetY = 0 --SCREEN_HEIGHT / 2 - this.screenHeight / 2

    return this
end

function Map:Render()
    love.graphics.setColor(1, 1, 1)
    for row=1,self.heightInTiles do
        for col=1, self.widthInTiles do
            local staggerX = -self.screenCellStaggerX * row + self.screenCellStaggerX * self.heightInTiles --Stagger each row 4 pixels left for parallelogram tiling
            local tileX = (col-1) * self.screenCellWidth + self.offsetX + staggerX
            local tileY = (row-1) * self.screenCellHeight + self.offsetY
            local tile = self:GetTile(col,row)

            if tile > 0 then
                --tile:setFilter("nearest", "nearest")
                love.graphics.drawLayer(TileSprites, tile, tileX, tileY)
                --local min, mag = tileSprites[tile]:GetFilter()
            end

            --love.graphics.rectangle("line",tileX,tileY,self.screenCellSize,self.screenCellSize)
        end
    end
end

function Map:GetTile(x,y)
    if x < 1 or y < 1 or x > self.widthInTiles or y > self.heightInTiles then
        return -1
    end

    return self.tiles[(y - 1) * (self.widthInTiles) + x]
end