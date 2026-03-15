require "settings"

log = {}

-- Input of ... is any number of input args (so non-strings can be passed in to be converted to strings here, instead of having to do that before calling a log function)
local function printToConsole(prefix, ...)
    if type(Config) == "table" and type(Config.debug) == "table" and type(Config.debug.logging) == "boolean" and Config.debug.logging == "false" then
        return
    end

    local text = ""

    -- select("#",...) is effectively #...
    for i = 1, select("#",...) do
        text = text .. tostring(select(i,...))
    end
    print("[" .. prefix .. "] ", text)
end

function log.debug(...)
    printToConsole("DEBUG", ...)
end

function log.warning(...)
    printToConsole(" ----- WARNING ----- ", ...)
end
