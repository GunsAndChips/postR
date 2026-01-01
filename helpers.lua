function Clone(_table, allTablesSeen, _depth)
    allTablesSeen = allTablesSeen or {}
    local _depth = _depth or 0
    print("Running Clone function, depth: " .. _depth)

    local copy = {}
    for key, value in pairs(_table) do
        if type(value) == "table" then
            print("Found table property: " .. tostring(key))
            if #allTablesSeen > 0 then
                for i = 1, #allTablesSeen do
                    if _table == allTablesSeen[i] then
                        error("unable to clone table '" .. tostring(_table) .. "', due to circular reference.")
                    end
                end
            end

            table.insert(allTablesSeen, _table)
            copy[key] = Clone(value, allTablesSeen, _depth + 1)
            table.remove(allTablesSeen)
        else
            copy[key] = value
        end
    end
    print("Exiting clone function...")
    return copy
end

Lookups = {
    facingX = {
        right = 1,
        left = -1
    }
}
