require "settings"

log = {}

function log.debug(string)
    if type(Config) == "table" and type(Config.debug) == "table" and type(Config.debug.logging) == "boolean" and Config.debug.logging == "false" then
        return
    else
        print("DEBUG: " .. tostring(string))
    end
end