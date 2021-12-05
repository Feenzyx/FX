-- WITWAS
ESX = nil
local PlayerData = {}
Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(10)
    end

    while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end
	PlayerData = ESX.GetPlayerData()

end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
  PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	PlayerData.job = job
end)

function IsJobTrue()
    if PlayerData.job ~= nil then
        local job = PlayerData.job.name
        if (job == 'rvb') or (job == 'whitelotus') or (job == 'amstelangels') or (job == 'yamaguchi') or (job == 'vision') then
            return true
        else    
            return false
        end
    else
        return false
    end
end

local AnimInfo = {InAnimation = false, Dict = nil, Name = nil, Time = nil}
local drugsSell = false
local Run = false
local isRunCanceld = false
local smelten = false
local counter = 0
local counterToBeDeliverd = 0
local sellPoint = 0
local nextLocation = false
local blip = 0

local firstLocation = true
local locationDistance = 200

RegisterNetEvent('as_witwas:return')
AddEventHandler('as_witwas:return', function()
    RemoveBlip(blip)
    counter = counter + 1
    if counterToBeDeliverd > 0 then
        nextLocation = true
    else
        nextLocation = false
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(3)
        local ped = PlayerPedId()
        local pedCoords = GetEntityCoords(ped, true)
        local doWait = true
        if not smelten then
            for k,v in pairs(Config.StartLocations) do
                local distance = #(pedCoords-v.Coords)
                if distance < 5.0 then
                    if v.Gangjob == nil or IsJobTrue() then
                        doWait = false
                        local text = v.Text
                        if distance < 1.0 then
                            text = '[~b~E~s~] '..text
                        end
                        DrawText3Ds(v.Coords, text)
                        if not IsPedInAnyVehicle(ped, true) and IsControlJustReleased(0, 38) and distance < 1.0 then
                            if not Run then
                                ESX.TriggerServerCallback('as_jobcounter:GetJobAmount', function(CopsConnected)
                                    if v.Type == 'smeltery' then
                                        smelten = true
                                        ESX.TriggerServerCallback('as_witwas:hasEnough', function(amount)
                                            if amount >= 50 then
                                                smelten = true
                                                startsmeltery()
                                            else
                                                ESX.ShowNotification('~y~Je hebt 50 juwelen nodig om een goudstaaf te smelten.')
                                                smelten = false
                                            end
                                        end, 'jewels')
                                    elseif v.Type == 'jewerly' then
                                        if CopsConnected >= Config.CopsNeeded then
                                            TriggerServerEvent('as_witwas:juweleninkoop')
                                        else
                                            ESX.ShowNotification('~r~Er is niet genoeg politie aanwezig. ('..CopsConnected..'/3)')
                                        end
                                    elseif v.Type == 'start' then
                                        if CopsConnected >= Config.CopsNeeded then
                                            ESX.TriggerServerCallback('as_witwas:hasEnough', function(amount)
                                                if amount >= Config.GoldToStart then
                                                    StartRun()
                                                else
                                                    ESX.ShowNotification('~y~Je hebt minimaal 2 goudstaven nodig om een run te starten.')
                                                end
                                            end, 'goldbar')
                                        else
                                            ESX.ShowNotification('~r~Er is niet genoeg politie aanwezig. ('..CopsConnected..'/3)')
                                        end
                                    end
                                end, 'police')
                                Citizen.Wait(1000)
                            else
                                ESX.ShowNotification('~r~Beëindig eerst je verkoop run.')
                            end
                        end
                    end
                end
            end
        end
        if doWait then
            Citizen.Wait(500)
        end
    end
end)

Citizen.CreateThread(function()
	while true do
        Citizen.Wait(5)
        if AnimInfo.InAnimation then
            local ped = PlayerPedId()
            if not IsEntityPlayingAnim(ped, AnimInfo.Dict, AnimInfo.Name, 3) then
				TaskPlayAnim(ped, AnimInfo.Dict, AnimInfo.Name, 2.0, 2.0, (AnimInfo.Time/1000), 1, 0, false, false, false)
            end
        else
            Citizen.Wait(100)
        end
    end
end)

function startsmeltery()
    local ped = PlayerPedId()
    SetEntityHeading(ped, Config.SmeltHeading)
    FreezeEntityPosition(ped, true)
    loadAnimDict(Config.AnimDictSmelt)
    TaskPlayAnim(ped, Config.AnimDictSmelt, Config.AnimSmelt, 2.0, 2.0, (Config.SmeltTime/1000.0), 1, 0, false, false, false)
    AnimInfo.InAnimation,AnimInfo.Dict,AnimInfo.Name,AnimInfo.Time = true,Config.AnimDictSmelt,Config.AnimSmelt,Config.SmeltTime
    exports['progressBars']:startUI(Config.SmeltTime, "Omsmelten")
    Citizen.Wait(Config.SmeltTime)
    Citizen.Wait(100)
    FreezeEntityPosition(ped, false)
    ClearPedTasks(ped)
    AnimInfo.InAnimation = false
    TriggerServerEvent('as_witwas:givegold')
    smelten = false
end

function StartRun()
    Run = true
    isRunCanceld = false
    counterToBeDeliverd = Config.DeliveryAmount
    ESX.ShowNotification("Goud verkoop run gestart, ~n~gebruik /endgoudrun om deze te annuleren.")
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(5)
            if isRunCanceld == true then
                break
            end
            if drugsSell == false and counter ~= Config.DeliveryAmount then
                MissionStart()
                drugsSell = true
            elseif counter == Config.DeliveryAmount then
                Reset()
            elseif drugsSell == true and counter >= 0 then
                SellGold()
            end
        end
    end)
end

function MissionStart()
    if firstLocation then
        local num = math.random(1,#Config.SellLocations)
        sellPoint = Config.SellLocations[num]
        firstLocation = false
        blip = CreateMissionBlip(sellPoint.Location)
        sellPoint.isUsed = true
        SetBlipRoute(blip, true)
        ESX.ShowNotification("Ga naar de ~y~locatie~s~ op de map.")
    else
        local pedCoords = GetEntityCoords(PlayerPedId())
        for k in pairs(Config.SellLocations) do
            sellPoint = Config.SellLocations[k]
            local distance = #(pedCoords-sellPoint.Location)
            if distance <= locationDistance and sellPoint.isUsed == false then
                blip = CreateMissionBlip(sellPoint.Location)
                sellPoint.isUsed = true
                SetBlipRoute(blip, true)
                ESX.ShowNotification("Ga naar de ~y~locatie~s~ op de map.")
                locationDistance = 200
                break
            elseif k == #Config.SellLocations then
                locationDistance = locationDistance + 200
                MissionStart()
            end
        end
    end
end

function SellGold()
    local ped = PlayerPedId()
    local pedCoords = GetEntityCoords(ped)
    local Distance = #(pedCoords-sellPoint.Location)
    if Distance < 15.0 then
        local text = 'Goudverkoop'
        if Distance < 1.0 then
            text = '[~b~E~s~] '..text
        end
        DrawText3Ds(sellPoint.Location, text)
        if Distance < 1.0 then
            if IsControlJustPressed(0, 38) and not IsPedInAnyVehicle(ped, false) then
                AnimInfo.InAnimation,AnimInfo.Dict,AnimInfo.Name,AnimInfo.Time = true,Config.AnimDict,Config.Anim,Config.KnockTime
                SetEntityHeading(ped, sellPoint.heading)
                FreezeEntityPosition(ped, true)
                loadAnimDict(Config.AnimDict)
                TaskPlayAnim(ped, Config.AnimDict, Config.Anim, 2.0, 2.0, (Config.KnockTime/1000.0), 1, 0, false, false, false)
                exports['progressBars']:startUI(Config.KnockTime, "Aankloppen")
                Citizen.Wait(Config.KnockTime)
                TriggerServerEvent('as_witwas:goudverkoop')
                Citizen.Wait(100)
                FreezeEntityPosition(ped, false)
                ClearPedTasks(ped)
                AnimInfo.InAnimation = false
            end
        end
    end
    if nextLocation and counter ~= Config.DeliveryAmount then
        Animation()
        nextLocation = false
        ESX.ShowNotification('~h~Nog ' ..(Config.DeliveryAmount - counter).. ' levering(en) te gaan.')
        MissionStart(location)
    elseif counter == Config.DeliveryAmount and Run == true then
        Animation()
    end
end

function Animation()
    local ped = PlayerPedId()
    AnimInfo.InAnimation,AnimInfo.Dict,AnimInfo.Name,AnimInfo.Time = true,Config.AnimDictGive,Config.AnimGive,Config.GiveTime
    SetEntityHeading(ped, sellPoint.heading)
    FreezeEntityPosition(ped, true)
    loadAnimDict(Config.AnimDictGive)
    TaskPlayAnim(ped, Config.AnimDictGive, Config.AnimGive, 2.0, 2.0, (Config.GiveTime/1000.0), 1, 0, false, false, false)
    local carryProp = CreateObject(GetHashKey(Config.DrugProp), GetEntityCoords(ped), 1, 1, 1)
    AttachEntityToEntity(carryProp, ped, GetPedBoneIndex(ped,  28422), 0.075, 0.021, -0.055, 25.0, 0.0, 0.0, 1, 1, 0, 1, 0, 1)
    exports['progressBars']:startUI(Config.GiveTime, "Verkopen")
    Citizen.Wait(Config.GiveTime)
    DeleteEntity(carryProp)
    FreezeEntityPosition(ped, false)
    ClearPedTasks(ped)
    AnimInfo.InAnimation = false
end

function loadAnimDict(dict)  
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Citizen.Wait(5)
    end
end

function Reset()
    ESX.ShowNotification("Run beëindigd.")
    Run = false
    drugsSell = false
    isRunCanceld = true
    nextLocation = false
    sellPoint = 0
    counter = 0
    firstLocation = true
    locationDistance = 200
    RemoveBlip(blip)
    for k in pairs(Config.SellLocations) do
        if Config.SellLocations[k].isUsed == true then
            Config.SellLocations[k].isUsed = false
        end
    end
end

function CreateMissionBlip(location)
	local blip = AddBlipForCoord(location)
	SetBlipSprite(blip, 618)
	SetBlipColour(blip, 5)
	AddTextEntry('MYBLIP', "Goud levering")
	BeginTextCommandSetBlipName('MYBLIP')
	AddTextComponentSubstringPlayerName(name)
	EndTextCommandSetBlipName(blip)
	SetBlipScale(blip, 0.9)
	SetBlipAsShortRange(blip, true)
	return blip
end

function DrawText3Ds(coords, text)
    local x,y,z = table.unpack(coords)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 370
	DrawRect(_x,_y+0.0125, 0.015+factor, 0.03, 41, 11, 41, 68)
end

RegisterCommand("endgoudrun", function()
    if Run == true then
        if not AnimInfo.InAnimation then
            Reset()
        else
            ESX.ShowNotification("Wacht totdat je klaar bent.")
        end
    end
end, false)