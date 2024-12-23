Map = {}
Map.__index = Map

function Map:New(data,width,height)
    --if(data.getn() ~= width*height) then
    --    return -1
    --end

    local this ={
        tiles = data,
        pixelWidth = width,
        pixelHeight = height,
        screenWidth = width * SCALE_FACTOR,
        screenHeight = height * SCALE_FACTOR,
        screenCellSize = 16 * SCALE_FACTOR
    }
    setmetatable(this,self)

    this.screenWidth = this.screenWidth * this.screenCellSize
    this.screenHeight = this.screenHeight * this.screenCellSize

    this.offsetX = SCREEN_WIDTH / 2 - this.screenWidth / 2
    this.offsetY = SCREEN_HEIGHT / 2 - this.screenHeight / 2

    return this
end

function Map:Render()
    love.graphics.setColor(1, 1, 1)
    for row=0,self.pixelHeight-1 do
        for col=0, self.pixelWidth-1 do
            local tileX = col*self.screenCellSize + self.offsetX
            local tileY = row * self.screenCellSize + self.offsetY
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
    if x < 0 or y < 0 or x > self.pixelWidth-1 or y > self.pixelHeight-1 then
        return -1
    end

    return self.tiles[y * self.pixelWidth + x + 1]
end