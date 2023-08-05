
-- Create all the options in the hire menu.
function gatherHireMenu()
    local options = {}

    -- First option: return a taxi.
    local i = #options + 1
    options[i] = {}
    options[i].title = "Return your hired cab" -- _U('menu_ctaxi_return_title')
    options[i].description = "You will receive your original deposit." -- _U('menu_ctaxi_return_desc')
    options[i].disabled = true
    options[i].onSelect = function()
        lib.callback.await('crazy-taxi:return')
        Wait(200)
        lib.hideContext(false)
        updateHireMenu("hire")
        lib.showContext('taxi-hire')
    end

    local playerLevel = getDriverData().level

    -- Iterate the Cabs config, add each as an item. 
    for k, v in pairs(Config.Cabs) do
        local i = #options + 1
        options[i] = {}
        options[i].title = v.label
        options[i].description = "Required: $" .. v.deposit .. " deposit, and level " .. v.reqLevel .. "."
        -- The button is not selectable unless you have unlocked it.
        -- This way, everyone gets a preview of the options.
        options[i].disabled = playerLevel < v.reqLevel
        options[i].onSelect = function()
            hireTaxi(v.hash, v.livery or nil, v.extra or nil)
            Wait(150)
            lib.hideContext(false)
        end
    end

    return options
end

-- When called at certain times, will either:
--  - Toggle the enabled state of the "Return Taxi" menu
--  - Enable taxis that were recently unlocked
function updateHireMenu(mode)
    local data = getDriverData()
    -- Iterate every option for hiring, and toggle them.
    for idx, option in ipairs(State.HireOptions) do
        -- For index 1 ("return a hired taxi"), we want it to be ENABLED if there is a hired taxi
        -- For every other index, we want it to be DISABLED if there is a hired taxi
        if idx == 1 then
            option.disabled = not data.Rental
        else 
            -- This would ordinarily make all options available, but we fall through to check ranks again.
            option.disabled = data.Rental
        end
    end

    -- This needs to only happen when we don't have a rental.
    if not data.Rental then
        local i = 1
        for k, v in pairs(Config.Cabs) do
            i = i + 1
            -- The button is not selectable unless you have unlocked it.
            -- This way, everyone gets a preview of the options.
            State.HireOptions[i].disabled = data.level < v.reqLevel    
        end
    end

    -- TODO: This is currently needed to make it update - but why? Unless ox_lib internally copies the options, we should be able to mutate the reference externally.
    lib.registerContext({
        id = 'taxi-hire',
        title = "Hire a Taxi",
        options = State.HireOptions
    })
end