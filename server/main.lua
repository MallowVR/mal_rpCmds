local statuses = {}

local function addToStatuses(_message, _source)
    statuses[_source] = _message
end

local function syncStatuses(_source)
    local ptr = next(statuses, nil)
    while ptr do
        TriggerClientEvent("Mallow:status", _source, statuses[ptr], ptr)
        ptr = next(statuses, ptr)
    end
end

CreateThread(function ()
    while true do
        local ptr = next(statuses, nil)
        while ptr do
            if not GetPlayerName(ptr) then
                statuses[ptr] = nil
                TriggerClientEvent("Mallow:status", -1, '', ptr)
            end
            ptr = next(statuses, ptr)
        end
        Wait(300000)
    end
end)






RegisterNetEvent('Mallow:sync', syncStatuses)

RegisterCommand(Config.statusCommand, function(source, args)
    local message = table.concat(args, " "):gsub("%s%s+","")
    TriggerClientEvent("Mallow:status", -1, message, source)
    addToStatuses(message, source)
end)

RegisterCommand(Config.actionCommand, function(source, args)
    local message = table.concat(args, " "):gsub("%s%s+","")
    local attempt = math.random(100)
    TriggerClientEvent("Mallow:action", -1, message, source, attempt)
end)

RegisterCommand(Config.meCommand, function(source, args)
    local message = table.concat(args, " "):gsub("%s%s+","")
    TriggerClientEvent("Mallow:me", -1, message, source)
end)

RegisterCommand(Config.doCommand, function(source, args)
    local message = table.concat(args, " "):gsub("%s%s+","")
    TriggerClientEvent("Mallow:me", -1, message, source)
end)

RegisterCommand(Config.rollCommand, function(source, args)
    if(args[1] ~= nil and args[2] ~= nil) then --Makes sure you do have both arguments in place.
        local dice = tonumber(args[1]) 
        local sides = tonumber(args[2]) --Converts chat string to number.
        if (sides > 0 and sides <= Config.maxSides) and (dice > 0 and dice <= Config.maxDice) then --Checks if sides and dices are bigger than 0 and smaller than the config values.
            local rolls = {}
            for i = 1, dice do
                rolls[i] = math.random(sides)
            end
            TriggerClientEvent("Mallow:roll", -1, rolls, sides, source)
        else
            TriggerClientEvent('chatMessage', source, 'SYSTEM', 'error', "Invalid amount. Max Dices: " .. Config.maxDice .. ", Max Sides: " .. Config.maxSides)
        end
    else
        TriggerClientEvent('chatMessage', source, 'SYSTEM', 'error', "Please fill out both arguments, example: /" .. Config.rollCommand .. " <dices> <sides>")
    end
end)