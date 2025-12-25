function ShallowClone(table)
    local copy = {}
    for key, value in pairs(table) do
        copy[key] = value
    end
    return copy
end