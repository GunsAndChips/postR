Menu = {}
Menu.__index = Menu

function Menu:Initialise(id, title)
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
        itemDefinitions = {},
        loaded = false,
        minHeight = 120,
        minWidth = 96,
        backgroundColour = { 0.55, 0.55, 0.55 },
        textColour = { 0.925, 0.925, 0.925 },
        textColourHover = { 0.1, 0.3, 0.1 },
        textColourClick = { 0.1, 0.3, 0.1 },
        textColourDisabled = { 0.69, 0.69, 0.69 },
        textLineSpacing = 3,
        marginSize = 6
    }

    return this
end

local function CreateControlText(type, font, colour1, colour2)
    if type == "boolean" then
        local booleanControlText = {}
        booleanControlText[false] = love.graphics.newText(font)
        booleanControlText[false]:setf({ colour1, "[", colour2, "x", colour1, "]" }, 30, "left")
        booleanControlText[true] = love.graphics.newText(font)
        booleanControlText[true]:setf({ colour1, "[x]" }, 30, "left")

        return booleanControlText
    elseif type == "range" then
        -- Create range text of the desired font for the two colours provided
        -- Range text is a series of dots that are two colours, representing a scalar value
        local rangeText = {}

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
    else
        error("Invalid type '" .. type .. "' provided to function CreateControlText")
    end
end

-- Fleshes out menu definitions
-- e.g. sets fonts and x/y positions for items, so we don't have to do it every time we render them
function Menu:Load()
    log.debug("Loading menu: ", self.title.textString)

    -- Set Title
    local title = self.title
    title.text = love.graphics.newText(Config.fonts.ui, "")
    title.text:setf({ self.textColour, title.textString }, PIXEL_WIDTH, "left")
    title.width = title.text:getWidth()
    title.height = title.text:getHeight()
    -- Title X can't be set until the menu width is decided
    title.y = self.marginSize

    local maxItemLength = PIXEL_WIDTH - 4 * self.marginSize
    local largestItemWidth = title.width
    local itemsWithControls = {}

    for i = 1, #self.itemDefinitions do
        local itemDefinition = self.itemDefinitions[i]
        local item = MenuItem:Load(self, itemDefinition, Config.fonts.ui, maxItemLength)
        item.x = self.marginSize
        item.y = (i - 1) * (item.height + self.textLineSpacing) + 2 * self.marginSize + title.height

        local itemAndControlWidth = item.width

        if item.type == "range" or item.type == "boolean" then
            table.insert(itemsWithControls, item)
            local paddingX = 0

            if item.type == "range" then
                item.onClick = function() item.value = 0 end
                paddingX = 1
            elseif item.type == "boolean" then
                item.onClick = item.control.onClick
                paddingX = 13
            end

            -- Add width of control so Menu is wide enough to fit both
            itemAndControlWidth = item.width + item.control.width + paddingX
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
            item.control.x = self.width - self.marginSize - item.control.width
            item.control.y = item.y + (item.control.offsetY or 0)
        end
    end

    -- TODO: make menu height dynamic to fit all items contained in that menu
    self.height = self.minHeight

    -- Set transform
    self.transform = love.math.newTransform()
    self.transform:translate(PIXEL_WIDTH / 2 - self.width / 2, PIXEL_HEIGHT / 2 - self.height / 2)

    self.loaded = true
end

local function MultiplyColour(colour, multiplier)
    return {
        colour[1] * multiplier,
        colour[2] * multiplier,
        colour[3] * multiplier
    }
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

    -- drop shadow
    love.graphics.setLineWidth(1)

    love.graphics.setColor(MultiplyColour(self.backgroundColour, 0.75))
    love.graphics.line(self.width + 0.5, 1, self.width + 0.5, self.height)
    love.graphics.line(1, self.height + 0.5, self.width + 1, self.height + 0.5)

    -- bevelled edge (bottom)
    love.graphics.setLineWidth(2)
    love.graphics.setColor(MultiplyColour(self.backgroundColour, 1.08))
    love.graphics.line(0, self.height - 1, self.width, self.height - 1)

    -- bevelled edge (right)
    love.graphics.setLineWidth(1)
    love.graphics.setColor(MultiplyColour(self.backgroundColour, 1.16))
    love.graphics.line(self.width - 0.5, 0, self.width - 0.5, self.height - 1)
    love.graphics.line(self.width - 1.5, 0, self.width - 1.5, self.height - 2)


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
        elseif Hovering.item == item.control then
            if item.type == "range" or item.type == "boolean" then
                if Hovering.clicking == 1 and item.textClick ~= nil then
                    displayText = item.textClick
                elseif item.textHover ~= nil then
                    displayText = item.textHover
                end
            end
        end

        -- Draw menu item
        love.graphics.draw(displayText, x, item.y)

        if item.type == "range" then
            local controlText = nil

            if Hovering.item == item.control then
                controlText = item.control.textHover[Hovering.rangePosition + 1]
            else
                controlText = item.control.text[item.value + 1]
            end

            love.graphics.draw(controlText, self.width - self.marginSize - controlText:getWidth(), item.control.y)
        elseif item.type == "boolean" then
            local controlText = nil
            if Hovering.item == item.control or Hovering.item == item then
                controlText = item.control.textHover[item.value]
            else
                controlText = item.control.text[item.value]
            end
            love.graphics.draw(controlText, self.width - self.marginSize - controlText:getWidth(), item.control.y)
        end
    end

    love.graphics.pop()
end

function Menu:GetItem(x, y)
    if not self.loaded then
        return
    end
    local menuX, menuY = self.transform:inverseTransformPoint(x, y)
    if menuX < 0 or menuX > self.width or menuY < 0 or menuY > self.height then
        return
    end

    for i = 1, #self.items do
        local item = self.items[i]
        if menuY > item.y and menuY < item.y + item.height then
            if menuX > item.x and menuX < item.x + item.width then
                return item
            elseif item.control == nil then
                return
            elseif menuX > item.control.x and menuX < item.control.x + item.control.width and menuY > item.control.y and menuY < item.control.y + item.control.height then
                if item.type ~= "range" then
                    return item.control
                else
                    local rangeDotCount = item.control.text.length
                    local rangePosition = math.floor((menuX - item.control.x) / item.control.width * rangeDotCount) + 1
                    if rangePosition < 1 or rangePosition > rangeDotCount + 1 then
                        error("rangePosition: " .. rangePosition .. " is invalid. It must be between 1 & " .. rangeDotCount)
                    end
                    return item.control, rangePosition
                end
            end
        end
    end
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

function MenuItem:Load(menu, itemDefinition, font, maxLength, textAlignment)
    maxLength = maxLength or PIXEL_WIDTH
    textAlignment = textAlignment or "left"

    if itemDefinition.id == nil then
        error("id is missing from itemDefinition " .. (itemDefinition.textString or ""))
    end

    local this = {
        id = menu.id .. "." .. itemDefinition.id,
        type = itemDefinition.type,
        x = menu.marginSize,
        y = nil,
        width = nil,
        height = nil,
        onClick = itemDefinition.onClick,
        value = itemDefinition.value,
        menu = menu,
        hoverOffsetX = 0
    }
    setmetatable(this, self)

    if this.type == "button" then
        this.hoverOffsetX = 2
    elseif this.type == "range" then
        this.control = {}
        local controlFont = Config.fonts.ui150
        this.control.text = CreateControlText("range", controlFont, menu.textColour, menu.textColourDisabled)
        this.control.textHover = CreateControlText("range", controlFont, menu.textColourHover, menu.textColourDisabled)

        -- Set offsetY based on the font scale
        if controlFont == Config.fonts.ui150 then
            this.control.offsetY = -6
        elseif controlFont == Config.fonts.ui200 then
            this.control.offsetY = -11
        else
            this.control.offsetY = 0
        end

        this.control.onClick = function() this.value = Hovering.rangePosition end
        this.control.width, this.control.height = GetTextDimensions(this.control.text[1])
    elseif this.type == "boolean" then
        this.control = {}
        this.control.text = CreateControlText("boolean", font, menu.textColour, menu.backgroundColour)

        this.control.offsetY = -2
        this.control.width, this.control.height = GetTextDimensions(this.control.text[false])

        if menu.textColourHover == menu.textColour then
            this.control.textHover = this.control.text
        elseif menu.textColourHover ~= nil then
            this.control.textHover = CreateControlText("boolean", font, menu.textColourHover, menu.backgroundColour)
        end
        this.control.onClick = function() this:ToggleBooleanValue() end
    end

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

    this.width, this.height = GetTextDimensions(this.text)

    return this
end

function MenuItem:ToggleBooleanValue()
    log.debug("toggling setting ", self.id)

    self.value = not (self.value)
    if self.id == "video.fullscreen" then
        love.window.setFullscreen(self.value)
    elseif self.id == "game.useRotatedY" then
        Settings.movement.useRotatedY = self.value
    end
end

function GetTextDimensions(text)
    local t = nil
    if text == nil then
        log.warning('Unable to get dimensions for text that is nil')
        return 0, 0
    elseif type(text) == "table" then
        t = text[1]
    else
        t = text
    end

    return t:getWidth(), t:getHeight()
end
