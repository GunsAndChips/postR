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

-- Function to sort Tables by Keys from Lua documentation
function PairsByKeys(t, f)
    local a = {}
    for n in pairs(t) do table.insert(a, n) end
    table.sort(a, f)
    local i = 0                -- iterator variable
    local iter = function()    -- iterator function
        i = i + 1
        if a[i] == nil then
            return nil
        else
            return a[i], t[a[i]]
        end
    end
    return iter
end

Lookups = {
    facingX = {
        right = 1,
        left = -1
    }
}
