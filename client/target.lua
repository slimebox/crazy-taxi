
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
                    if ESX.GetPlayerData().job.name == "crazy-taxi" then 
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

-- Remove the garage trigger
function removeGarageTarget(name)
    exports.ox_target:removeZone(State.GarageZoneIDs[name])
end
