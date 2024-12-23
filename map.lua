Map = {}
Map.__index = Map

function Map:New(data,width,height)
    --if(data.getn() ~= width*height) then
    --    return -1
    --end

    local this ={
        tiles = data,
        width = width,
        height = height,
        cellSize = 16
    }
    setmetatable(this,self)

    this.screenWidth = this.width * this.cellSize
    this.screenHeight = this.height * this.cellSize

    this.offsetX = PIXEL_WIDTH / 2 - this.screenWidth / 2
    this.offsetY = PIXEL_HEIGHT / 2 - this.screenHeight / 2

    return this
end

function Map:Render()
    love.graphics.setColor(1, 1, 1)
    for row=0,self.height-1 do
        for col=0, self.width-1 do
            local tileX = col*self.cellSize + self.offsetX
            local tileY = row * self.cellSize + self.offsetY
            local tile = self:GetTile(col,row)

            if tile == 0 then
                love.graphics.rectangle("line",tileX,tileY,self.cellSize,self.cellSize)
            elseif tile == 1 then
                love.graphics.rectangle("fill",tileX,tileY,self.cellSize,self.cellSize)
            end
        end
    end
end

function Map:GetTile(x,y)
    if x < 0 or y < 0 or x > self.width - 1 or y > self.height - 1 then
        return -1
    end

    return self.tiles[y * self.width + x + 1]
end