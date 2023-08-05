
-- Fetches our Driver data.
function getDriverData() 
    local value = lib.callback.await("crazy-taxi:getDriverData")
    return value
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
