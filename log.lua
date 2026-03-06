require "settings"

log = {}

-- Input of ... is any number of input args (so non-strings can be passed in to be converted to strings, rather than having to be converted before being passed to log.debug)
function log.debug(...)
    if type(Config) == "table" and type(Config.debug) == "table" and type(Config.debug.logging) == "boolean" and Config.debug.logging == "false" then
        return
    end

    local text = ""

    -- select("#",...) is effectively #...
    for i = 1, select("#",...) do
        text = text .. tostring(select(i,...))
    end
    print("DEBUG: ", text)
end