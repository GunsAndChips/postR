require "log"

function Clone(_table, allTablesSeen, depth)
    allTablesSeen = allTablesSeen or {}
    depth = depth or 0
    log.debug("Entering Clone function, depth: " .. depth)

    local copy = {}
    for key, value in pairs(_table) do
        if type(value) == "table" then
            log.debug("Found table property: " .. tostring(key))
            if #allTablesSeen > 0 then
                for i = 1, #allTablesSeen do
                    if _table == allTablesSeen[i] then
                        error("unable to clone table '" .. tostring(_table) .. "', due to circular reference.")
                    end
                end
            end

            table.insert(allTablesSeen, _table)
            copy[key] = Clone(value, allTablesSeen, depth + 1)
            table.remove(allTablesSeen)
        else
            copy[key] = value
        end
    end
    log.debug("Exiting Clone function...")
    return copy
end

function RoundToEven(number, roundUp)
    roundUp = roundUp or false

    if number % 2 == 0 then
        return number
    elseif roundUp then
        return number + 1
    else
        return number - 1
    end
end

Lookups = {
    facingX = {
        right = 1,
        left = -1
    }
}
