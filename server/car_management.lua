
-- Called from the client, when a taxi is selected for hire.
lib.callback.register('crazy-taxi:hire', function(source, model, livery, extras, zone)
    -- First, we should run some checks. Is the player actually a taxi driver?
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local ID = xPlayer.identifier
    if not xPlayer.job.name == 'crazy-taxi' then
        print("Aborting - no job")
        alert(source, {
            icon = "ban", position = "top", duration = 2000, title = "Crazy Taxi", description = "You are not on duty, so you cannot hire a taxi."
        })
        return
    end

    -- Second, does the player already have a hired cab?
    if Drivers[ID] and Drivers[ID].Rental then
        print("Aborting - already rented")
        alert(source, {
            icon = "ban", position = "top", duration = 2000, title = "Crazy Taxi", description = "You already have a cab rented. Return it first!"
        })
        return
    end

    -- Third, is the player eligible for spawning this cab?
    local eligible = false
    local carCost = 0 -- Saved for later!
    for k,v in pairs(Config.Cabs) do -- Search through the active cabs to find the one called for
        if v.hash == model and (Drivers[ID] and Drivers[ID].level or 1) >= v.reqLevel then -- Check whether the driver meets the required level
            eligible = true -- Set the flag if so
            carCost = v.deposit
        end
    end
    if not eligible then -- Once we've searched the whole list, we can check whether we turned up valid.
        print("Aborting - not unlocked")
        alert(source, {
            icon = "ban", position = "top", duration = 2000, title = "Crazy Taxi", description = "You have not unlocked this vehicle yet. How are you even trying to spawn this?"
        })
        return
    end

    -- Fourth, do we have to charge for the taxi? If so, does the player have enough money?
    if Config.RequireHirePayment then
        if not playerHasEnough(source, carCost) then -- Will check both cash and bank.
            print("Aborting - no money")
            alert(source, {
                icon = "ban", position = "top", duration = 2000, title = "Crazy Taxi", description = "You do not have enough money to hire this taxi."
            })
            return
        end
    end

    -- Now we're ready to start preparing to spawn. 
    local possibleSpawns = Config.Offices[zone].rentalSpawns

    -- The only reliable source of information about this stuff is on the client, so we need to ask them: where are the nearby vehicles?
    local vehicles = lib.callback.await('crazy-taxi:getNearbyVehicles', source, 50)

    for i = 1, #possibleSpawns do -- Iterate every space that a car can be placed in, to find the first available spot.
        if isAreaClear(vehicles, vector3(possibleSpawns[i].x, possibleSpawns[i].y, possibleSpawns[i].z), 3.0) then
            if Config.RequireHirePayment then chargePlayer(source, carCost) end
            
            -- Car Spawning
            -- TODO: This is significantly different from the CFX docs "best practices". How do they differ?
            -- ESX.OneSync.SpawnVehicle!

            if type(model) == "string" then model = GetHashKey(model) end
            local entity = CreateVehicleServerSetter(model, 'automobile', possibleSpawns[i].x, possibleSpawns[i].y, possibleSpawns[i].z, possibleSpawns[i].w)
            while not DoesEntityExist(entity) do Wait(1) end
            local plate = GetVehicleNumberPlateText(entity)
            while plate == nil or plate == '' do
                Wait(1)
                plate = GetVehicleNumberPlateText(entity)
            end
            if Config.GiveHiredTaxiKeys then
                lib.callback.await('crazy-taxi:giveKey', source, plate, NetworkGetNetworkIdFromEntity(entity), livery, extra)
            end
            Drivers[ID] = getOrCreateDriverData(source)
            Drivers[ID].Rental = { entity = entity, cost = carCost or nil, plate = plate}
            return
        end

        -- Make sure we handle the case where there are no spots left
        if i == #possibleSpawns then 
            print("Aborting - no room")
            alert(source, {
                icon = "ban", position = "top", duration = 2000, title = "Crazy Taxi", description = "There are no available slots to spawn a taxi, please wait for one to move."
            })
        end
    end
    return
end)

-- Called from the client when it wants to return a taxi.
lib.callback.register('crazy-taxi:return', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    local ident = xPlayer.identifier

    -- Double check that this player has actually rented a taxi..
    if not Drivers[ident] then return end

    local rental = Drivers[ident].Rental
    if not rental then return end

    -- Double check their taxi wasn't destroyed..
    local taxiEntity = rental.entity
    if DoesEntityExist(taxiEntity) then
        DeleteEntity(taxiEntity)
    end

    -- If they paid for it, they get full cost back.
    -- TODO: Configurable! Disable this, also allow payment based on car damage?
    -- TODO: Should we allow the player to have the car repaired while in the cab yard?
    if rental.cost then
        xPlayer.addAccountMoney("money", rental.cost)
    end

    -- Nil out the rental for this driver
    Drivers[ident].Rental = nil
end)

-- Called from the client when it wants to get its' own data.
lib.callback.register('crazy-taxi:getDriverData', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    local ident = xPlayer.identifier
    
    -- If we don't have it, then make something! Save them as a new taxi driver.
    if not Drivers[ident] then
        if xPlayer.job.name == 'crazy-taxi' then -- Check they're actually a taxi driver first.
            Drivers[ident] = getOrCreateDriverData(source)
        end
    end

    return Drivers[ident]
end)