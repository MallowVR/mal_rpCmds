RegisterCommand("status", function(source, args)
    local message = table.concat(args, " "):gsub("%s+","")

    TriggerClientEvent("Mallow:status", -1, message, source)
end)