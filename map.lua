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
        screenCellSize = PIXEL_CELL_SIZE * SCALE_FACTOR
    }
    setmetatable(this,self)

    this.screenWidth = (this.widthInTiles) * this.screenCellSize
    this.screenHeight = (this.heightInTiles) * this.screenCellSize

    this.offsetX = SCREEN_WIDTH / 2 - this.screenWidth / 2
    this.offsetY = SCREEN_HEIGHT / 2 - this.screenHeight / 2

    return this
end

function Map:Render()
    love.graphics.setColor(1, 1, 1)
    love.graphics.newFont(40)
    for row=1,self.heightInTiles do
        for col=1, self.widthInTiles do
            local tileX = (col-1)*self.screenCellSize + self.offsetX
            local tileY = (row-1) * self.screenCellSize + self.offsetY
            local tile = self:GetTile(col,row)

            if tile == 0 then
                love.graphics.rectangle("line",tileX,tileY,self.screenCellSize,self.screenCellSize)
            elseif tile == 1 then
                love.graphics.rectangle("fill",tileX,tileY,self.screenCellSize,self.screenCellSize)
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