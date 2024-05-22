local status = {}

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
        while true do--Targetting == false do
            print('loop')
            for _, player in ipairs(GetActivePlayers()) do
                local serverid = GetPlayerServerId(player)
                local ped = GetPlayerPed(player)
                local coords = GetEntityCoords(ped)
                if status[ped] ~= nil then --and status[ped].near == true then
                    qbx.drawText3d({
                        text = status[ped].text,
                        coords = vec3(coords.x, coords.y, coords.z + status[ped].height),
                        disableDrawRect = true,
                        --color = vec4(1,255,158,255),
                    })
                end
            end
            Citizen.Wait(0)
        end
        Citizen.Wait(500)
    end
end)