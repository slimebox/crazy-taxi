-- For checking the player's job.
ESX = exports['es_extended']:getSharedObject()

State = {
    GarageZoneIDs = {},      -- Cached IDs of garage triggers. Indexed by the name of the Offices table in config.lua. ID represents the Box Zone created at the doorCoords.
    HiredTaxi = nil         -- The car that the user has hired. Only one at a time.
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
                    if ESX.PlayerData.job.name == "crazy-taxi" then -- and state.onJob 
                        return true -- Players can only interact with this, if they have the Taxi job and are on duty.
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
    options[i].disabled = not (State.HiredTaxi and State.HiredTaxi.entity or false)
    options[i].onSelect = function()
        TriggerServerEvent('crazy-taxi:return')
        Wait(200)
        lib.hideContext(false)
        lib.showContext('taxi-hire')
    end

    -- Iterate the Cabs config, add each as an item. 
    for k, v in pairs(Config.Cabs) do
        local i = #options + 1
        options[i] = {}
        options[i].title = v.label
        options[i].description = "Required: $" .. v.deposit .. " deposit."
        -- The button is not selectable unless you have unlocked it.
        -- This way, everyone gets a preview of the options.
        -- TODO: Implement serverside progression.
        -- options[i].disabled = ServerState.Progression[ID].level > v.requiredLevel
        options[i].onSelect = function()
            hireTaxi(v.hash, v.livery or nil, v.extra or nil)
            Wait(150)
            lib.hideContext(false)
        end
    end

    return options
end

-- Request the server spawn our taxi for us.
-- The server will do the necessary checks, to prevent sneaky cheats.
function hireTaxi(model, livery, extras)
    print("Hiring a " .. tostring(model))
end

-- Run all client setup tasks
CreateThread(function() 

    -- Set up menus
    hireOptions = gatherHireMenu()

    lib.registerContext({
        id = 'taxi-hire',
        title = "Hire a Taxi", -- _U('menu_ctaxi_hire_title'),
        options = hireOptions
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
            createGarageTarget(k, v)
        end

        function point:onExit()
            removeGarageTarget(k)
        end
    end
end)