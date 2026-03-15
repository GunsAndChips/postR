require "helpers"

function PlayerMove(dt)
    if not love.keyboard.isDown(_Key.up, _Key.down, _Key.left, _Key.right) then
        return
    end

    local speed = {}
    speed.x = 0
    speed.y = 0
    speed.magnitude = Player.movement.baseSpeed

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
        speed.magnitude = Player.movement.baseSpeed * Player.movement.sprintMultiplier
    end
    -- Make diagonal movespeed same as straightline
    if math.abs(speed.y) + math.abs(speed.x) == 2 then
        speed.magnitude = speed.magnitude / math.sqrt(2)
    end
    -- Delta time
    speed.magnitude = speed.magnitude * dt * 144

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
    Player.targeting.x = Player.x + Lookups.facingX[Player.facing] * (Player.width / 2 + Player.targeting.distance)
    -- Set height to target at, to the player's coords + half their height to get to their feet, minus the height
    Player.targeting.y = Player.y + Player.height / 2 - Player.targeting.height

    local tileX, tileY = MapTilesTransform:inverseTransformPoint(Player.targeting.x, Player.targeting.y)

    Player.targeting.tile = {
        x = math.floor(tileX),
        y = math.floor(tileY)
    }
end

function Player.Interact(button, dt)
    local actionTypes = Config.entity.actions
    local a = Player.interaction

    -- If there is no action currently in cooldown, and key was pressed
    if a.action == nil then
        if button == nil then
            log.warning("Player.Interact was called when there is no current action, and no button was pressed. This should not happen.")
            return
        elseif button == 1 then
            a.action = actionTypes.till
        else
            log.warning("Player.Interact was called with a button/key press that has not been implemented.")
            return
        end

        a.cooldown = a.action.baseCooldown
        return
    elseif a.cooldown == nil or a.cooldown <= 0 then
        log.warning("Player.Interact was called with an ongoing action, but the cooldown for it was nil or <= 0. This is an invalid state.")
        a.action = nil
        return
    elseif a.cooldown > dt then
        a.cooldown = a.cooldown - dt
        return
    elseif a.cooldown <= dt then
        a.cooldown = 0
        a.action = nil
        return
    end
end
