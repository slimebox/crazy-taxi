
local ESX = exports['es_extended']:getSharedObject()
local AppFares = {}     -- Stores the current "virtual" NPC fares.
local InWorldFares = {} -- Stores the current "passive" NPC fares.
local PlayerFares = {}  -- Stores the current "real" player fares - players waiting for a taxi in-game.
local Drivers = {}      -- Stores information about the current drivers. Stores name, xp, level, current fare, current rental, Crazy Mode data.

-- Show an alert on the client's screen using ox_lib
function alert(target, data)
    TriggerClientEvent('ox_lib:notify', target, data)
end

-- Check whether the given player has enough money to pay for something.
-- If their total bank+cash is < amount, they are rejected.
local function playerHasEnough(source, amount)
    local total = 0
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then 
        total = total + xPlayer.getAccount("bank").money
        if not Config.UseOxInventoryCash then -- TODO: Reasses whether this is needed - ESX guarantees we can use getAccount("money") to inspect ox_inventory cash.
            total = total + xPlayer.getAccount("money").money
        else
            local oxInvMoney = exports.ox_inventory:Search(source, "count", "money")
            total = total + (oxInvMoney and oxInvMoney or 0) -- Make sure we never try to add nil
        end
    end

    return total >= amount
end

-- Charges the player for the given amount of money.
-- It is expected that you already called playerHasEnough before this - because no checks are performed.
-- If their cash < amount but bank+cash is >= amount, their cash is taken first, and their bank account pays the rest.
local function chargePlayer(source, amount, includeBank)
    local leftover = 0
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then 
        leftover = xPlayer.getAccount("money").money - amount
        print("Charging player " .. xPlayer.getName() .. " amount " .. amount .. ", has " .. xPlayer.getAccount("money").money .. " cash, leaves " .. ((leftover < 0) and (tostring(abs(leftover)) .. " to charge to bank") or (tostring(leftover) .. " in cash")))
    end
end

-- Check for entities in the vicinity of a set of coordinates.
-- entities: A list of entities to check. Usually the result of GetGamePool('CVehicle').
-- coords: The point at the center of the range to check
-- range: The radius (in RAGE units) around the coords to check for the presence of an entity
local function isAreaClear(entities, coords, range)
    for idx, entity in pairs(entities) do
        if #(coords - entity.coords) <= range then
            return false
        end
    end
    return true
end

-- Called from the client, when a taxi is selected for hire.
lib.callback.register('crazy-taxi:hire', function(source, model, livery, extras, zone)
    -- First, we should run some checks. Is the player actually a taxi driver?
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer.job.name == 'crazy-taxi' then
        alert(source, {
            icon = "ban", position = "top", duration = 2000, title = "Crazy Taxi", description = "You are not on duty, so you cannot hire a taxi."
        })
        return
    end

    -- Second, does the player already have a hired cab?
    if Drivers[source] and Drivers[source].rental then
        alert(source, {
            icon = "ban", position = "top", duration = 2000, title = "Crazy Taxi", description = "You already have a cab rented. Return it first!"
        })
        return
    end

    -- Third, is the player eligible for spawning this cab?
    local eligible = false
    local carCost = 0 -- Saved for later!
    for k,v in pairs(Config.Cabs) do -- Search through the active cabs to find the one called for
        if v.hash == model and (Drivers[source] and Drivers[source].level or 1) >= v.reqLevel then -- Check whether the driver meets the required level
            eligible = true -- Set the flag if so
            carCost = v.deposit
        end
    end
    if not eligible then -- Once we've searched the whole list, we can check whether we turned up valid.
        alert(source, {
            icon = "ban", position = "top", duration = 2000, title = "Crazy Taxi", description = "You have not unlocked this vehicle yet. How are you even trying to spawn this?"
        })
        return
    end

    -- Fourth, do we have to charge for the taxi? If so, does the player have enough money?
    if Config.RequireHirePayment then
        if not playerHasEnough(source, carCost) then -- Will check both cash and bank.
            alert(source, {
                icon = "ban", position = "top", duration = 2000, title = "Crazy Taxi", description = "You do not have enough money to hire this taxi."
            })
            return
        end
    end

    -- Now we're ready to start preparing to spawn. 
    local possibleSpawns = Config.Offices[zone].rentalSpawns
    local vehicles = lib.callback.await('crazy-taxi:getNearbyVehicles', source, 50)

    for i = 1, #possibleSpawns do -- Iterate every space that a car can be placed in, to find the first available spot.
        -- The only reliable source of information about this stuff is on the client, so we need to ask them: is there space here?
        if isAreaClear(vehicles, vector3(possibleSpawns[i].x, possibleSpawns[i].y, possibleSpawns[i].z), 3.0) then
            chargePlayer(source, 5000)
            return
        end

        -- Make sure we handle the case where there are no spots left
        if i == #possibleSpawns then 
            alert(source, {
                icon = "ban", position = "top", duration = 2000, title = "Crazy Taxi", description = "There are no available slots to spawn a taxi, please wait for one to move."
            })
        end
    end
    return
end
)