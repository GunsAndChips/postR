function PlayerMove()
    if not love.keyboard.isDown(_Key.up, _Key.down, _Key.left, _Key.right) then
        return
    end

    local speed = {}
    speed.x = 0
    speed.y = 0
    speed.magnitude = Config.movement.moveSpeed

    -- Set direction for x/y movement
    if love.keyboard.isDown(_Key.right) then
        speed.x = speed.x + 1
    end
    if love.keyboard.isDown(_Key.left) then
        speed.x = speed.x - 1
    end
    if love.keyboard.isDown(_Key.down) then
        speed.y = speed.y + 1
    end
    if love.keyboard.isDown(_Key.up) then
        speed.y = speed.y - 1
    end

    -- Return if no movement
    if speed.y == 0 and speed.x == 0 then
        return
    elseif speed.x > 0 then
        Player.facing = "right"
    elseif speed.x < 0 then
        Player.facing = "left"
    end

    -- Movespeed modifiers
    -- Sprint
    if love.keyboard.isDown(_Key.sprint) then
        speed.magnitude = Config.movement.moveSpeed * Config.movement.sprintMultiplier
    end
    -- Make diagonal movespeed same as straightline
    if math.abs(speed.y) + math.abs(speed.x) == 2 then
        speed.magnitude = speed.magnitude / math.sqrt(2)
    end

    local dx = speed.magnitude * speed.x * -1 -- invert because we're moving the map, not the player
    local dy = speed.magnitude * speed.y * -1 -- invert because we're moving the map, not the player

    if Settings.movement.useRotatedY then
        dx = dx + ((speed.magnitude * speed.y) / 3)
    end

    MapTransform:translate(dx, dy)

    local tiles = {}
    tiles.dy = dy / Config.tile.height
    tiles.dx = dx / Config.tile.width + tiles.dy * (Config.tile.staggerX / Config.tile.width)
    MapTilesTransform:translate(tiles.dx, tiles.dy)

    UpdatePlayerTargetingCoords()
end

function UpdatePlayerTargetingCoords()
    Player.targeting.x = Player.x + Lookups.facingX[Player.facing] * (Player.width / 2 + Player.reachLength)
    Player.targeting.y = Player.y + Player.reachHeight

    local tileX, tileY = MapTilesTransform:inverseTransformPoint(Player.targeting.x, Player.targeting.y)

    Player.targeting.tile = {
        x = math.floor(tileX),
        y = math.floor(tileY)
    }
end

function PlayerInteract()
    -- hi
end