function ShallowClone(table)
    local copy = {}
    for key, value in pairs(table) do
        copy[key] = value
    end
    return copy
end

-- Calculate player targeting coordinates
Lookups = {
    facingX = {
        right = 1,
        left = -1
    }
}
