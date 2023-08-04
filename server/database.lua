--[[
    Functions that read + write from the database, to isolate this code from the rest.
]]
local oxmysql = exports.oxmysql -- For saving + loading data from the database
local ESX = exports['es_extended']:getSharedObject()

local tableID = 'crazy-taxi'

-- Query the database for a player's data. If not present, defaults will be generated.
function getOrCreateDriverData(src)
    local identifier = ESX.GetPlayerFromId(src).identifier
    if identifier ~= nil then
        -- Query the DB first.
        local result = oxmysql:single_async('SELECT * FROM `' .. tableID .. '` WHERE identifier = @identifier', { ['@identifier'] = identifier })
        if result ~= nil then
            -- If the player already has an entry in the DB, then return their data.
            return { totalFares = result.total_fares, level = result.level, highScore = result.high_score }
        else
            -- Insert the player into the table, and return default values.
            oxmysql:executeSync('INSERT INTO `' .. tableID .. '` (identifier) VALUES (@identifier)', { ['@identifier'] = identifier })
            return { totalFares = 0, level = 1, highScore = 0 }
        end
    end
end

-- Store a completed fare into the DB.
-- If the total fares exceeds the configurable level factoring equation, then the player will also gain a level 
function addCompletedFare(src, drivers)
    local identifier = ESX.GetPlayerFromId(src).identifier
    if identifier ~= nil then
        local fares = drivers[src].totalFares
        local level = drivers[src].level
        -- Compare the fares against the level factoring equation
        if (tonumber(fares) + 1) >= Config.LevelFactoring(level, fares) then
            -- Upgrade the player's level if appropriate.
            oxmysql:executeSync('UPDATE ' .. tableID .. ' SET `total_fares` = @fares, `level` = `level` + 1 WHERE `identifier` = @identifier', { ['@fares'] = fares + 1, ['@identifier'] = identifier })
            drivers[src].totalFares = fares + 1
            drivers[src].level = level + 1
        else
            -- Just increment the update.
            oxmysql:executeSync('UPDATE ' .. tableID .. ' SET `total_fares` = @fares WHERE `identifier` = @identifier', { ['@fares'] = fares + 1, ['@identifier'] = identifier })
            drivers[src].totalFares = fares + 1
        end
    end
end