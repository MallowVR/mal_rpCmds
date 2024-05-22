local status = {}
local lastscale = 0
local visible = false
local keyPromise = promise.new()


local function draw3dText(params)
    local text = params.text
    local coords = params.coords
    local camCoords = GetGameplayCamCoord()
    local dist = #(coords - camCoords)
    local scale = params.scale or (200 / (GetGameplayCamFov() * dist)) ^ 0.5
    if scale ~= lastscale then
        --print('scale: '..scale)
        lastscale = scale
    end
    local font = params.font or 4--10?
    local color = params.color or Config.color

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

local function displayStatus(_ped, _text, _height)
    if _text:sub(1,2) == "  " then
        status[_ped] = nil
        return
    end
    status[_ped] = {
        text = _text,
        height = _height,
        near = false,
    }
end

local function onStatus(_text, _source)
    local player = GetPlayerFromServerId(_source)
    if player ~= -1 then
        local ped = GetPlayerPed(player)
        --print('' .. _source .. ' ' .. player .. ' ' .. ped)
        displayStatus(ped, " " .. _text .. " ", 0)
    end
end


RegisterNetEvent('Mallow:status', onStatus)

CreateThread(function()
    Citizen.Wait(0)
    while true do
        --print(''..Targetting)
        while visible == true do
            for _, player in ipairs(GetActivePlayers()) do
                local serverid = GetPlayerServerId(player)
                local ped = GetPlayerPed(player)
                local coords = GetEntityCoords(ped)
                if status[ped] ~= nil then --and status[ped].near == true then
                    draw3dText({
                        text = status[ped].text,
                        coords = vec3(coords.x, coords.y, coords.z + status[ped].height),
                        disableDrawRect = true,
                        --color = vec4(1,255,158,255),
                    })
                end
            end
            Citizen.Wait(0)
        end
        keyPromise = promise.new()
        Citizen.Await(keyPromise)
        
    end
end)

do
    ---@type KeybindProps
    local keybind = {
        name = 'mal_rpCmds',
        defaultKey = GetConvar('ox_target:defaultHotkey', 'LMENU'),
        defaultMapper = 'keyboard',
        description = 'toggle_targeting',
    }

    function keybind:onPressed()
        visible = true
        keyPromise:resolve()
        return
    end

    function keybind:onReleased()
        visible = false
        return
    end

    lib.addKeybind(keybind)
end
