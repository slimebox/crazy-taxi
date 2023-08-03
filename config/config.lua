Config = {}

Config.Offices = {
    ['mirrorpark'] = {
        name = 'Downtown Cab Co.',
        coords = vector3(908.3676, -155.0854, 74.1473),
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