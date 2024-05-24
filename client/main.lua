local status = {}
local visible = false
local keyPromise = promise.new()

local action = {}
local actionPromise = promise.new()
local actionThread = false

local function draw3dText(params)
    local text = params.text
    local coords = params.coords
    local camCoords = GetGameplayCamCoord()
    local dist = #(coords - camCoords)
    local scale = params.scale or (200 / (GetGameplayCamFov() * dist)) ^ 0.5
    local font = params.font or Config.font
    local color = params.color or Config.color
    local line = params.line or 0

    if line ~= 0 then
        coords = vec3(coords.x, coords.y, coords.z + (0.2 * line))
    end

    SetTextScale(0.1, scale)
    --SetTextScale(0.0, 0.1)
    SetTextFont(font)
    SetTextDropshadow(0, 0, 0, 0, 55)
    SetTextDropShadow()
    SetTextColour(math.floor(color.r), math.floor(color.g), math.floor(color.b), math.floor(color.a))
    SetTextCentre(true)
    BeginTextCommandDisplayText('STRING')
    AddTextComponentSubstringPlayerName(text)
    SetDrawOrigin(coords.x, coords.y, coords.z, 0)
    EndTextCommandDisplayText(0.0, 0.0)

    if not params.disableDrawRect then
        local factor = #text / 370
        DrawRect(0.0, 0.0125, 0.017 + factor, 0.03, 0, 0, 0, 75)
    end
    ClearDrawOrigin()
end

local function drawStatuses()
    Citizen.Wait(0)
    while visible do
        local i = next(status, nil)
        while visible and i do
            if status[i] ~= nil and status[i].near == true then
                local coords = GetEntityCoords(GetPlayerPed(i))
                draw3dText({
                    text = status[i].text,
                    coords = vec3(coords.x, coords.y, coords.z + status[i].height),
                    disableDrawRect = true,
                })
            end
            i = next(status, i)
            if i == nil then
                i = next(status, nil)
                Citizen.Wait(0)
            end
        end
        Citizen.Wait(100)
    end
end

local function drawActions()
    Citizen.Await(actionPromise)
    local i = next(action, nil)
    while i do
        if action[i] ~= nil and action[i].near == true then
            local coords = GetEntityCoords(i)
            draw3dText({
                text = action[i].text,
                coords = vec3(coords.x, coords.y, coords.z + action[i].height),
                disableDrawRect = true,
            })
            draw3dText({
                text = action[i].attempt,
                coords = vec3(coords.x, coords.y, coords.z + action[i].height),
                disableDrawRect = true,
                line = -1,
                color = action[i].color,
            })
        end
        i = next(action, i)
        if i == nil then
            i = next(action, nil)
            Citizen.Wait(0)
        end
    end
end

local function setStatus(_player, _text, _height)
    if _text == "" then
        status[_player] = nil
        return
    end
    status[_player] = {
        text = _text,
        height = _height,
        near = false,
    }
end

local function setAction(_ped, _text, _attempt, _height)
    if _text == "" then
        action[_ped] = nil
        return
    end
    local result = 'Failure'
    local c = Config.failureColor
    if _attempt == 1 then
        result = 'Success'
        c = Config.successColor
    end
    local dist = #(GetEntityCoords(GetPlayerPed(PlayerId())) - GetEntityCoords(GetPlayerPed(_ped)))
    local nearVar = false
    if dist < Config.radius then
        nearVar = true
    end
    action[_ped] = {
        text = _text,
        height = _height,
        near = nearVar,
        timer = GetGameTimer() + Config.duration,
        attempt = result,
        color = c
    }
    actionPromise:resolve()
end

local function onStatus(_text, _source)
    local player = GetPlayerFromServerId(_source)
    if player ~= -1 then
        setStatus(player, "" .. _text .. "", 0)
    end
end

local function onAction(_text, _source, _attempt)
    local player = GetPlayerFromServerId(_source)
    if player ~= -1 then
        local ped = GetPlayerPed(player)
        setAction(ped, "" .. _text .. "", _attempt, 1)
        if actionThread == false then
            CreateThread(function()
                drawActions()
            end)
        end
    end
end

RegisterNetEvent('Mallow:status', onStatus)
RegisterNetEvent('Mallow:action', onAction)


AddEventHandler('onClientResourceStart', function(_resourceName)
    if _resourceName == 'mal_rpCmds' then
        Citizen.Wait(120000) -- wait 2 minutes before asking for data from server
        TriggerServerEvent("Mallow:sync", GetPlayerServerId(PlayerId())) -- request list of current statuses from server
    end
end)

CreateThread(function()
    while true do
        if next(status, nil) ~= nil then
            local clientCoords = GetEntityCoords(GetPlayerPed(PlayerId()))
            local i = next(status, nil)
            while i do
                local coords = GetEntityCoords(GetPlayerPed(i))
                local dist = #(clientCoords - coords)
                if dist < Config.radius then
                    status[i].near = true
                else
                    status[i].near = false
                end
                i = next(status, i)
            end
        end
        Citizen.Wait(1000)
    end
end)

CreateThread(function()
    while true do
        local clientCoords = GetEntityCoords(cache.ped)
        Citizen.Await(actionPromise)
        local i = next(action, nil)
        while i do
            if GetGameTimer() > action[i].timer then
                local j = next(action, i)
                action[i] = nil
                if j then
                    i = j
                else
                    break
                end
            end
            local coords = GetEntityCoords(i)
            local dist = #(clientCoords - coords)
            if dist < Config.radius then
                action[i].near = true
            else
                action[i].near = false
            end
            i = next(action, i)
        end
        Citizen.Wait(100)
    end
end)

do
    ---@type KeybindProps
    local keybind = {
        name = 'mal_rpCmds',
        defaultKey = GetConvar('ox_target:defaultHotkey', 'LMENU'),
        defaultMapper = 'keyboard',
        description = 'Toggle targeting',
    }

    function keybind:onPressed()
        visible = true
        CreateThread(function()
            drawStatuses()
        end)
        return
    end

    function keybind:onReleased()
        visible = false
        return
    end

    lib.addKeybind(keybind)
end
