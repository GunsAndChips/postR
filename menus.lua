Menu = {}
Menu.__index = Menu

function Menu:New(id, title)
    if type(id) ~= "string" then
        error("Unable to create menu without id. Please provide a string value.")
    end
    title = title or "Menu Title"
    local this = {
        id = id,
        title = {
            textString = title,
            text = nil,
            x = nil,
            y = nil,
            width = nil,
            height = nil
        },
        items = {},
        loaded = false,
        minHeight = 120,
        minWidth = 96,
        backgroundColour = { 0.5, 0.5, 0.5 },
        textColour = { 1, 1, 1 },
        textColourHover = { 0.1, 0.3, 0.1 },
        textColourClick = { 0.1, 0.3, 0.1 },
        textColourDisabled = { 0.69, 0.69, 0.69 },
        textLineSpacing = 3,
        marginSize = 6
    }

    return this
end

-- Creates range text of the desired font for the two colours provided
-- Range text is a series of dots that are two colours, representing a scalar value
local function CreateRangeText(font, colour1, colour2)
    local rangeText = {}

    -- Set offsetY based on the font scale
    if font == Config.fonts.ui150 then
        rangeText.offsetY = -6
    elseif font == Config.fonts.ui200 then
        rangeText.offsetY = -11
    else
        rangeText.offsetY = 0
    end

    local ranges = {
        "",
        ".",
        "..",
        "...",
        "....",
        ".....",
        "......",
        ".......",
        "........"
    }
    ranges.count = #ranges

    for i = 1, ranges.count do
        local textTable = {
            colour1,
            ranges[i],
            colour2,
            ranges[ranges.count + 1 - i]
        }

        table.insert(rangeText, love.graphics.newText(font, textTable))
    end

    rangeText.width = rangeText[1]:getWidth()
    rangeText.height = rangeText[1]:getHeight()
    rangeText.length = #ranges - 1

    return rangeText
end

-- Fleshes out menu definitions
-- e.g. sets fonts and x/y positions for items, so we don't have to do it every time we render them
function Menu:Load()
    log.debug("Loading menu: " .. self.title.textString)

    -- Set Title
    local title = self.title
    title.text = love.graphics.newText(Config.fonts.ui, title.textString)
    title.width = title.text:getWidth()
    title.height = title.text:getHeight()
    -- Title X can't be set until the menu width is decided
    title.y = self.marginSize

    local maxItemLength = PIXEL_WIDTH - 4 * self.marginSize
    local largestItemWidth = title.width
    local itemsWithControls = {}

    for i = 1, #self.itemDefinitions do
        local itemDefinition = self.itemDefinitions[i]
        local item = MenuItem:New(self, itemDefinition, Config.fonts.ui, maxItemLength)
        item.x = self.marginSize
        item.y = (i - 1) * (item.height + self.textLineSpacing) + 2 * self.marginSize + title.height

        local itemAndControlWidth = item.width

        if item.type == "range" then
            local definition = {
                type = "control",
                parent = item,
                onClick = function() MenuItem.SetRange() end
            }
            item.control = MenuItem:New(self, definition, Config.fonts.ui150)

            table.insert(itemsWithControls, item)

            -- Add width of control so Menu is wide enough to fit both
            itemAndControlWidth = itemAndControlWidth + item.control.width + 1
        end

        largestItemWidth = math.max(largestItemWidth, itemAndControlWidth)
        table.insert(self.items, item)
    end

    -- Set menu width to fit all items on it, without going below the minWidth
    self.width = math.max(largestItemWidth + 2 * self.marginSize, self.minWidth)
    -- Set menu width to not go over max width, which is the screen size minus a margin on each size (rounded down to the nearest even number)
    self.width = math.min(self.width, PIXEL_WIDTH - 2 * self.marginSize)

    -- Set title x centred on the Menu
    title.x = math.floor(self.width / 2 - title.width / 2)

    -- Check for itemsWithControls to load
    if #itemsWithControls > 0 then
        for i = 1, #itemsWithControls do
            local item = itemsWithControls[i]
            if item.type == "range" then
                item.control.x = self.width - self.marginSize - item.control.width
                item.control.y = item.y + item.control.text.offsetY
            end
        end
    end

    -- TODO: make menu height dynamic to fit all items contained in that menu
    self.height = self.minHeight

    -- Set transform
    self.transform = love.math.newTransform()
    self.transform:translate(PIXEL_WIDTH / 2 - self.width / 2, PIXEL_HEIGHT / 2 - self.height / 2)

    self.loaded = true
end

function Menu:Draw()
    if not self.loaded then
        Menu.Load(self)
    end

    love.graphics.push()
    love.graphics.applyTransform(self.transform)

    -- background
    love.graphics.setColor(self.backgroundColour)
    love.graphics.rectangle("fill", 0, 0, self.width, self.height)

    -- title
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(self.title.text, self.title.x, self.title.y)

    -- items
    for i = 1, #self.items do
        local item = self.items[i]
        local x = item.x
        local displayText = item.text

        if Hovering.item == item then
            x = item.x + item.hoverOffsetX

            if Hovering.clicking == 1 and item.textClick ~= nil then
                displayText = item.textClick
            elseif item.textHover ~= nil then
                displayText = item.textHover
            end
        end

        -- Draw menu item
        love.graphics.draw(displayText, x, item.y)

        if item.type == "range" then
            local controlText = nil

            if Hovering.item == item.control then
                controlText = item.control.textHover[Hovering.rangePosition + 1]
            else
                print(item, item.value)
                controlText = item.control.text[item.value + 1]
            end

            love.graphics.draw(controlText, self.width - self.marginSize - controlText:getWidth(), item.control.y)
        end
    end

    love.graphics.pop()
end

function Menu:GetItem(x, y)
    if not self.loaded then
        return nil, nil
    end
    local menuX, menuY = self.transform:inverseTransformPoint(x, y)
    if menuX < 0 or menuX > self.width or menuY < 0 or menuY > self.height then
        return nil, nil
    end

    for i = 1, #self.items do
        local item = self.items[i]
        if menuY > item.y and menuY < item.y + item.height then
            if menuX > item.x and menuX < item.x + item.width then
                return item
            elseif item.control ~= nil and menuX > item.control.x and menuX < item.control.x + item.control.width and menuY > item.control.y and menuY < item.control.y + item.control.height then
                local rangePosition = nil
                if item.type == "range" then
                    local rangeDotCount = item.control.text.length
                    rangePosition = math.floor((menuX - item.control.x) / item.control.width * rangeDotCount) + 1
                    if rangePosition < 1 or rangePosition > rangeDotCount + 1 then
                        error("rangePosition: '" ..
                            rangePosition .. "' is not valid. Must not be less than 1 or more than " .. rangeDotCount)
                    end
                end
                return item.control, rangePosition
            end
        end
    end
    return nil, nil
end

function ShowHoverText()
    if #Game.visibleMenus < 1 then
        return
    end

    local pixelX, pixelY = love.mouse.getPosition()
    local menu = Game.visibleMenus[#Game.visibleMenus]
    Hovering.item, Hovering.rangePosition = Menu.GetItem(menu, pixelX, pixelY)
    Hovering.clicking = GetClickingIfHovering()
end

function GetClickingIfHovering()
    if Hovering.item == nil then
        return false
    elseif love.mouse.isDown(1) then
        return 1
    else
        return false
    end
end

function Menu.Back()
    SaveSettings()

    -- Remove the top menu
    table.remove(Game.visibleMenus)
end

MenuItem = {}
MenuItem.__index = MenuItem

function MenuItem:New(menu, itemDefinition, font, maxLength, textAlignment)
    maxLength = maxLength or PIXEL_WIDTH
    textAlignment = textAlignment or "left"

    local this = {
        type = itemDefinition.type,
        x = menu.marginSize,
        y = nil,
        width = nil,
        height = nil,
        onClick = itemDefinition.onClick,
        value = itemDefinition.value,
        parent = itemDefinition.parent,
        menu = menu,
        hoverOffsetX = 0
    }
    setmetatable(this, self)

    if this.type == "button" then
        this.hoverOffsetX = 2
    end

    if this.type == "control" and itemDefinition.parent.type == "range" then
        this.text = CreateRangeText(font, menu.textColour, menu.textColourDisabled)
        this.textHover = CreateRangeText(font, menu.textColourHover, menu.textColourDisabled)
        this.onClick = function() this:SetRange(Hovering.rangePosition) end
    else
        this.text = love.graphics.newText(font)
        this.text:setf({ menu.textColour, itemDefinition.textString }, maxLength, textAlignment)

        if menu.textColourHover == menu.textColour then
            this.textHover = this.text
        elseif menu.textColourHover ~= nil then
            this.textHover = love.graphics.newText(font)
            this.textHover:setf({ menu.textColourHover, itemDefinition.textString }, maxLength, textAlignment)
        end

        if this.onClick ~= nil and menu.textColourClick ~= nil then
            -- Set click text
            if menu.textColourClick == menu.textColour then
                this.textClick = this.text
            elseif menu.textColourClick == menu.textColourHover then
                this.textClick = this.textHover
            else
                this.textClick = love.graphics.newText(font)
                this.textClick:setf({ menu.textColourClick, itemDefinition.textString }, maxLength, textAlignment)
            end
        end
    end

    if type(this.text) == "table" then
        -- Set width and height from first Text in table
        this.height = this.text[1]:getHeight()
        this.width = this.text[1]:getWidth()
    else
        -- Set width and height from Text
        this.height = this.text:getHeight()
        this.width = this.text:getWidth()
    end

    return this
end

function MenuItem.SetRange()
    Hovering.item.parent.value = Hovering.rangePosition
end
