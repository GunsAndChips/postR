function Clone(table)
    local copy = {}
    for key, value in pairs(table) do
        if type(value) == "table" then
            copy[key] = Clone(value)
        else
            copy[key] = value
        end
    end
    return copy
end

Lookups = {
    facingX = {
        right = 1,
        left = -1
    }
}
