
local ESX = exports['es_extended']:getSharedObject()
local AppFares = {}     -- Stores the current "virtual" NPC fares.
local InWorldFares = {} -- Stores the current "passive" NPC fares.
local PlayerFares = {}  -- Stores the current "real" player fares - players waiting for a taxi in-game.
local Drivers = {}      -- Stores information about the current drivers. Stores name, xp, level, current fare, current rental, Crazy Mode data.

-- Show an alert on the client's screen using ox_lib
function alert(target, data)
    TriggerClientEvent('ox_lib:notify', target, data)
end