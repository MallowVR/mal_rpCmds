local status = {}
local visible = false
local statusPromise = promise.new()

local action = {}
local actionPromise = promise.new()
local actionThread = false

ReplaceHudColourWithRgba(232, Config.successColor.r, Config.successColor.g, Config.successColor.b, Config.successColor.a) -- replaces HUD_COLOUR_PLACEHOLDER_09
ReplaceHudColourWithRgba(233, Config.failureColor.r, Config.failureColor.g, Config.failureColor.b, Config.failureColor.a) -- replaces HUD_COLOUR_PLACEHOLDER_10

local function draw3dText(params)
    local text = params.text
    local coords = params.coords
    local camCoords = GetGameplayCamCoord()
    local dist = #(coords - camCoords)
    local scale = params.scale or (200 / (GetGameplayCamFov() * dist) * 0.7)
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
    AddTextComponentString(text)
    SetDrawOrigin(coords.x, coords.y, coords.z, 0)
    EndTextCommandDisplayText(0.0, 0.0)

    if not params.disableDrawRect then
        local factor = #text / 370
        DrawRect(0.0, 0.0125, 0.017 + factor, 0.03, 0, 0, 0, 75)
    end
    ClearDrawOrigin()
end

function DiceRollAnimation()
    RequestAnimDict("anim@mp_player_intcelebrationmale@wank") --Request animation dict.

    while (not HasAnimDictLoaded("anim@mp_player_intcelebrationmale@wank")) do --Waits till it has been loaded.
        Citizen.Wait(0)
    end
    local globalPlayerPedId = GetPlayerPed(PlayerId())
    TaskPlayAnim(globalPlayerPedId, "anim@mp_player_intcelebrationmale@wank" ,"wank" ,8.0, -8.0, -1, 49, 0, false, false, false ) --Plays the animation.
    Citizen.Wait(2400)
    ClearPedTasks(globalPlayerPedId)
end

local function drawStatuses()
    Citizen.Await(statusPromise)
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
            local coords = GetEntityCoords(GetPlayerPed(i))
            draw3dText({
                text = action[i].text,
                coords = vec3(coords.x, coords.y, coords.z + action[i].height),
                disableDrawRect = true,
            })
        end
        i = next(action, i)
        if i == nil then
            i = next(action, nil)
            Citizen.Wait(0)
        end
    end
    actionThread = false
    actionPromise = promise.new()
end

local function setStatus(_player, _text, _height)
    if _text == "" then
        status[_player] = nil
        TriggerEvent('chatMessage', 'SYSTEM', 'error', 'Clearing status')
        return
    end
    status[_player] = {
        text = _text,
        height = _height,
        near = false,
    }
    statusPromise:resolve()
end

local function setAction(_player, _text, _height)
    if _text == "" then
        action[_player] = nil
        return
    end
    local dist = #(GetEntityCoords(GetPlayerPed(PlayerId())) - GetEntityCoords(GetPlayerPed(_player)))
    local nearVar = false
    if dist < Config.radius then
        nearVar = true
    end
    action[_player] = {
        text = _text,
        height = _height,
        near = nearVar,
        timer = GetGameTimer() + Config.duration,
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
    local string = _text
    if Config.crits and _attempt <= Config.critRange then
        string = string..' [~HC_233~Critical Failure~s~]'
    elseif Config.crits and _attempt > (100 - Config.critRange) then
        string = string..' [~HC_232~Critical Success~s~]'
    elseif _attempt > Config.weight then
        string = string..' [~HC_232~Success~s~]'
    else
        string = string..' [~HC_233~Failure~s~]'
    end
    if player ~= -1 then
        setAction(player, "" .. string .. "", 1)
        if actionThread == false then
            CreateThread(function()
                drawActions()
            end)
            actionThread = true
        end
    end
end

local function onMe(_text, _source)
    local player = GetPlayerFromServerId(_source)
    if player ~= -1 then
        setAction(player, "" .. _text .. "", 1)
        if actionThread == false then
            CreateThread(function()
                drawActions()
            end)
            actionThread = true
        end
    end
end

local function onRoll(_rolls, _sides, _source)
    local player = GetPlayerFromServerId(_source)
    if player ~= -1 then
        if GetPlayerServerId(PlayerId()) == _source then --Checks if you you ahve the same source id
            DiceRollAnimation()
        end
        local i = next(_rolls, nil)
        local total = 0
        local message = ''
        while i do
            total += _rolls[i]
            message = message.._rolls[i]..' | '
            i = next(_rolls, i)
        end
        message = message..'Sides: '.._sides..' (Total: '..total..')'
        setAction(player, "" .. message .. "", 1)
        if actionThread == false then
            CreateThread(function()
                drawActions()
            end)
            actionThread = true
        end
    end
end

RegisterNetEvent('Mallow:status', onStatus)
RegisterNetEvent('Mallow:action', onAction)
RegisterNetEvent('Mallow:me', onMe)
RegisterNetEvent('Mallow:roll', onRoll)


AddEventHandler('onClientResourceStart', function(_resourceName)
    if _resourceName == 'mal_rpCmds' then
        Citizen.Wait(120000) -- wait 2 minutes before asking for data from server
        TriggerServerEvent("Mallow:sync", GetPlayerServerId(PlayerId())) -- request list of current statuses from server
    end
end)

CreateThread(function()
    while true do
        Citizen.Await(statusPromise)
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
        else
            statusPromise = promise.new()
        end
        Citizen.Wait(1000)
    end
end)

CreateThread(function()
    while true do
        Citizen.Await(actionPromise)
        local clientCoords = GetEntityCoords(GetPlayerPed(PlayerId()))
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
            local coords = GetEntityCoords(GetPlayerPed(i))
            local dist = #(clientCoords - coords)
            if dist < Config.radius then
                action[i].near = true
            else
                action[i].near = false
            end
            i = next(action, i)
        end
        Citizen.Wait(250) -- quarter second delay before it calculates nearness again
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
