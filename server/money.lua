

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
        if leftover < 0 then
            xPlayer.setAccountMoney("money", 1)
            xPlayer.setAccountMoney("bank", abs(leftover))
        else
            xPlayer.setAccountMoney("money", leftover)
        end
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