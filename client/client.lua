-- For checking the player's job.
ESX = exports['es_extended']:getSharedObject()

State = {
    PlayerZone = nil,       -- The name of the zone that the player is in, as determined by the key to the nearest Office target.
    GarageZoneIDs = {},     -- Cached IDs of garage triggers. Indexed by the name of the Offices table in config.lua. ID represents the Box Zone created at the doorCoords.
    HiredTaxi = nil,         -- The car that the user has hired. Only one at a time.
    HireOptions = {}        -- The state of the context menu used at each cab co office.
}

-- Set up the Garage Door target.
-- Provides an option to rent a taxi cab.
function createGarageTarget(name, data)
    State.GarageZoneIDs[name] = exports.ox_target:addBoxZone({
        coords = data.doorCoords,
        size = vector3(5, 5, 5),
        drawSprite = true,
        options = {
            {
                label = 'Rent Taxi Cab',
                icon = "fa-solid fa-car",
                canInteract = function()
                    if ESX.GetPlayerData().job.name == "crazy-taxi" then -- and state.onJob 
                        return true -- Players can only interact with this if they have the Taxi job.
                    end
                end,
                onSelect = function()
                    lib.hideContext(false) -- Close current menu
                    lib.showContext('taxi-hire') -- Open the new menu
                end
            } -- TODO: Options for clocking in, stealing cars when not having the job, etc.
        }
    })
end

-- Fetches our Driver data.
function getDriverData() 
    local value = lib.callback.await("crazy-taxi:getDriverData")
    return value
end

-- Remove the garage trigger
function removeGarageTarget(name)
    exports.ox_target:removeZone(State.GarageZoneIDs[name])
end

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

-- Request the server spawn our taxi for us.
-- The server will do the necessary checks, to prevent sneaky cheats.
function hireTaxi(model, livery, extras)
    lib.callback.await('crazy-taxi:hire', -1, model, livery, extras, State.PlayerZone) -- Cooldown enforced on the server, by checking that the player already has a rental.
    updateHireMenu("hire")
end

-- Send the server a list of vehicles nearby us.
-- Used for checking whether there's a car in a spot the server wants to use.
lib.callback.register('crazy-taxi:getNearbyVehicles', function(radius)
    local nearbyVehicles = lib.getNearbyVehicles(GetEntityCoords(cache.ped), radius, true)
    return nearbyVehicles
end)

-- Run all client setup tasks
CreateThread(function() 

    -- Set up menus
    State.HireOptions = gatherHireMenu()

    lib.registerContext({
        id = 'taxi-hire',
        title = "Hire a Taxi",
        options = State.HireOptions
    })

    -- Set up office hotspots.
    for k, v in pairs(Config.Offices) do
        -- Map blip
        local blip = AddBlipForCoord(v.coords.x, v.coords.y, v.coords.z)
        SetBlipSprite(blip, v.blip.sprite)
        SetBlipScale(blip, v.blip.scale)
        SetBlipColour(blip, v.blip.colour)
        SetBlipAsShortRange(blip, true)

        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName(tostring(v.name))
        EndTextCommandSetBlipName(blip)

        -- The zone makes sure we don't load stuff unnecessarily.
        local point = lib.points.new(v.coords, 40, { zone = k })

        function point:onEnter()
            State.PlayerZone = k -- The key of the current Office (area zone) is saved to the local State to be sent later
            createGarageTarget(k, v)
        end

        function point:onExit()
            removeGarageTarget(k)
            State.PlayerZone = nil
        end
    end
end)