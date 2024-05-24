local statuses = {}

local function addToStatuses(_message, _source)
    statuses[_source] = _message
end

local function syncStatuses(_source)
    local ptr = next(statuses, nil)
    print('['.._source..']')
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

RegisterCommand("status", function(source, args)
    local message = table.concat(args, " "):gsub("%s%s+","")
    TriggerClientEvent("Mallow:status", -1, message, source)
    addToStatuses(message, source)
end)

RegisterCommand("action", function(source, args)
    local message = table.concat(args, " "):gsub("%s%s+","")
    local attempt = math.floor(math.random(100) / Config.weight)
    TriggerClientEvent("Mallow:action", -1, message, source, attempt)
end)