-- For checking the player's job.
ESX = exports['es_extended']:getSharedObject()

State = {
    PlayerZone = nil,       -- The name of the zone that the player is in, as determined by the key to the nearest Office target.
    GarageZoneIDs = {},     -- Cached IDs of garage triggers. Indexed by the name of the Offices table in config.lua. ID represents the Box Zone created at the doorCoords.
    HiredTaxi = nil,        -- The car that the user has hired. Only one at a time.
    HireOptions = {}        -- The state of the context menu used at each cab co office.
}


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