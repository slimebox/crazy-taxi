Config = {}

-- Whether a taxi driver must pay money upfront to hire a vehicle.
Config.RequireHirePayment = true

-- When checking for the cash a player has, check their ox_inventory for the "cash" item, rather than their "money" ESX account.
Config.UseOxInventoryCash = false

-- When determining how a player levels up, this is checked against the player using the formula:
-- if (player.totalFares + 1) >= LevelFactoring then levelUp() end
-- This allows you to change the formula used to calculate when a player levels up - by default, every level is 15x harder / longer than the last, but any equation involving the level and the fare total is valid.
Config.LevelFactoring = function(level, totalFares) 
    return level * (10 * 1.5)
 end

--[[
    A table of locations where taxi drivers can clock in and start their job.
    
    The table index is the "zone" name, used internally.
    The table content is an anonymous table of the schema:

    name: English text (used for the map blip title)
    coords: Coordinates of the map blip, in RAGE units
    doorCoords: Coordinates of the trigger, which allows players to rent a cab. Should be a large garage door.
    blip: A table of schema:
        sprite: RAGE blip sprite for use in the map.
        scale: Size of the map blip.
        colour: Colour of the map blip.
    rentalSpawns: an array of vector4, which are the positions and orientations that cabs can spawn in this office.
]]
Config.Offices = {
    ['mirrorpark'] = {
        name = 'Downtown Cab Co.',
        coords = vector3(895.95, -179.67, 74.69),
        doorCoords = vector3(894.91, -179.35, 74.69),
        blip = {
            sprite = 198,
            scale = 0.8,
            colour = 5
        },
        rentalSpawns = {
            vector4(899.08, -180.64, 73.22, 237.635),
            vector4(897.12, -183.51, 73.16, 237.635),
            vector4(908.81, -183.44, 73.56, 58.57),
            vector4(906.95, -186.48, 73.42, 58.57),
            vector4(905.15, -189.09, 73.23, 58.57)
        }
    }
}

--[[
    A list of tables which specifies the cabs that taxi drivers can rent.
    The tables are of the schema:

    hash: The vehicle spawn code (https://docs.fivem.net/docs/game-references/vehicle-models/)
    label: The text that shows up in the menu for this vehicle
    deposit: The amount of money required to initially hire this vehicle
    reqLevel: The minimum level that the driver must be to have the option to hire this vehicle
    livery: The special livery for the vehicle, when appropriate
    extra: Extra features to add to the vehicle, such as the taxi light bar.
]]
Config.Cabs = {
        {
            hash = `taxi`,
            label = "Vapid Taxi",
            deposit = 250,
            reqLevel = 1,
        },
        {
            hash = `caravantaxi`,
            label = 'Caravan Taxi',
            deposit = 500,
            reqLevel = 2,
        },
        {
            hash = `priustaxi`,
            label = 'Prius Taxi',
            deposit = 750,
            reqLevel = 3,
        },
        {
            hash = `rmodgt63`,
            label = 'GT63 AMG Brabus Taxi',
            deposit = 5000,
            reqLevel = 4,
            livery = 0,
            extra = 1,
        },
}