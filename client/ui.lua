
-- Create all the options in the hire menu.
function gatherHireMenu()
    local options = {}

    -- First option: return a taxi.
    local i = #options + 1
    options[i] = {}
    options[i].title = "Return your hired cab" -- _U('menu_ctaxi_return_title')
    options[i].description = "You will receive your original deposit." -- _U('menu_ctaxi_return_desc')
    options[i].disabled = true
    options[i].onSelect = function()
        lib.callback.await('crazy-taxi:return')
        Wait(200)
        lib.hideContext(false)
        updateHireMenu("hire")
        lib.showContext('taxi-hire')
    end

    local driverData = getDriverData()
    print("d data ", driverData)

    local playerLevel = getDriverData().level

    -- Iterate the Cabs config, add each as an item. 
    for k, v in pairs(Config.Cabs) do
        local i = #options + 1
        options[i] = {}
        options[i].title = v.label
        options[i].description = "Required: $" .. v.deposit .. " deposit, and level " .. v.reqLevel .. "."
        -- The button is not selectable unless you have unlocked it.
        -- This way, everyone gets a preview of the options.
        options[i].disabled = playerLevel < v.reqLevel
        options[i].onSelect = function()
            hireTaxi(v.hash, v.livery or nil, v.extra or nil)
            Wait(150)
            lib.hideContext(false)
        end
    end

    return options
end

-- When called at certain times, will either:
--  - Toggle the enabled state of the "Return Taxi" menu
--  - Enable taxis that were recently unlocked
function updateHireMenu(mode)
    local data = getDriverData()
    -- Iterate every option for hiring, and toggle them.
    for idx, option in ipairs(State.HireOptions) do
        -- For index 1 ("return a hired taxi"), we want it to be ENABLED if there is a hired taxi
        -- For every other index, we want it to be DISABLED if there is a hired taxi
        if idx == 1 then
            option.disabled = not data.Rental
        else 
            -- This would ordinarily make all options available, but we fall through to check ranks again.
            option.disabled = data.Rental
        end
    end

    -- This needs to only happen when we don't have a rental.
    if not data.Rental then
        local i = 1
        for k, v in pairs(Config.Cabs) do
            i = i + 1
            -- The button is not selectable unless you have unlocked it.
            -- This way, everyone gets a preview of the options.
            State.HireOptions[i].disabled = data.level < v.reqLevel    
        end
    end

    -- TODO: This is currently needed to make it update - but why? Unless ox_lib internally copies the options, we should be able to mutate the reference externally.
    lib.registerContext({
        id = 'taxi-hire',
        title = "Hire a Taxi",
        options = State.HireOptions
    })
end

-- The in-taxi UI is based on GTA 5 Scaleform, so as to not express issues with cursor locking.
function initializeTaxiScaleform() 
    if not State.HiredTaxi then return end

    -- Load the scaleform itself
    State.Scaleform = RequestScaleformMovie("TAXI_DISPLAY") -- Base game! Handy.
    while not HasScaleformMovieLoaded(State.Scaleform) do
        Wait(5)
    end

    -- Load the model to place into the taxi, so it's visible in first person.
    local hash = joaat("prop_taxi_meter_2")
    RequestModel(hash)
    while not HasModelLoaded(hash) do
        Wait(5)
    end

    State.TaxiCounterObject = CreateObjectNoOffset(hash, GetEntityCoords(State.HiredTaxi.entity), true, true, false)
    AttachEntityToEntity(State.TaxiCounterObject, State.HiredTaxi.entity, GetEntityBoneIndexByName(State.HiredTaxi.entity, "Chassis"), vector3(-0.05, 0.78, 0.39), vector3(-6.0, 0.0, -10.0), false, false, false, false, 2, true, 0)
    -- TODO: Render the price on the entity!

    -- Set the data in the UI
    BeginScaleformMovieMethod(State.Scaleform, "SET_TAXI_PRICE")
    ScaleformMovieMethodAddParamInt(0)
    EndScaleformMovieMethod()
end

-- Delete the UI for the taxi overlay.
function removeTaxiScaleform()
    DeleteObject(State.TaxiCounterObject)
    SetModelAsNoLongerNeeded(joaat("prop_taxi_meter_2"))
    SetScaleformMovieAsNoLongerNeeded(State.Scaleform)
end

-- Change the destination in the taxi overlay.
function setDestination(dest)
    BeginScaleformMovieMethod(State.Scaleform, "ADD_TAXI_DESTINATION")
    
    -- Add Sprite
    ScaleformMovieMethodAddParamInt(0)
    ScaleformMovieMethodAddParamInt(dest.sprite)
    ScaleformMovieMethodAddParamInt(dest.color.r)
    ScaleformMovieMethodAddParamInt(dest.color.g)
    ScaleformMovieMethodAddParamInt(dest.color.b)

    -- Add taxi name
    BeginTextCommandScaleformString("STRING")
    AddTextComponentSubstringPlayerName(dest.playerName)
    EndTextCommandScaleformString()

    -- Add destination zone
    BeginTextCommandScaleformString("STRING")
    AddTextComponentSubstringPlayerName(dest.zone)
    EndTextCommandScaleformString()

    -- Add destination name
    BeginTextCommandScaleformString("STRING")
    AddTextComponentSubstringPlayerName(dest.street)
    EndTextCommandScaleformString()

    EndScaleformMovieMethod()

    BeginScaleformMovieMethod(State.Scaleform, "SHOW_TAXI_DESTINATION")
    EndScaleformMovieMethod()

    BeginScaleformMovieMethod(State.Scaleform, "HIGHLIGHT_DESTINATION")
    ScaleformMovieMethodAddParamInt(0)
    EndScaleformMovieMethod()
end

