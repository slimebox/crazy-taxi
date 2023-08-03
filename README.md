## Crazy Taxi

A feature-packed Taxi job for FiveM.

Dependencies: 
 - ESX
 - ox_target


## Overview

Crazy Taxi is fully configurable, and extensible with plugins to add new "fare types", destinations, and scoring methods. Every time something mentioned is configurable, it will be surrounded by square brackets ( `[]` ).


The taxi game loop is such:

* Find / obtain / [steal] / otherwise get in possession of a Taxi cab
* "clock in"; register with the Dispatch system
* Wait for, [or manually select], a fare. These may be players, or peds on the street.
* Find the location of the fare, either by [following the GPS blip], or searching on the map for them.
* Drive up to them, to let them into your car
* Find the destination, drive them to it.
* Stop in the highlighted zone to let the fare out, and receive payment for it.

### [Crazy Mode]

Occasionally, when a fare enters the vehicle, they will have special instructions. These are "fare types" being triggered, and by default, there are five of them:

- *Slow and Steady*  
  The passenger wants to be taken to their destination as legally as possible - you must stay under the speed limit, you must stay in the "forward" lane, and you must not make illegal turning maneuvers. 
  [This is the default mode.]
- *Offroading*  
  The passenger wants to get dirty - take them offroad! The longer you stay offroad, the more money they give you. [Certain stunts will add to the fare.]
- *Airtime*  
  The passenger is a thrillseeker - try to find routes that take them over the crest of hills at speed, to get air time. The longer you're in the air, the more money they give you.
- *Crazy Taxi*  
  The namesake of the plugin - the passenger wants you to get them to their destination as fast as possible. The clock starts ticking, and you must floor it. [Extra points for near misses, illegal turns, and high speed.] [The handling of the car is greatly increased when this mode triggers, to allow you to make more dangerous maneuvers and stay in control of the car.] [The car's health is also greatly increased, to make slamming into things not such a detriment.]
- *Follow that driver!*  
  Sometimes, the passenger may have less than legitimate intentions, so will ask you to do something shady. Sometimes, this involves driving them to the slums of Los Santos, waiting a few minutes, then driving them to the middle of nowhere. Sometimes, it involves finding, then following a car in the city. You get extra money for being discreet.


## Getting a car

Obtaining a taxi can be done legitimately, or illegitimately:

### Legitimately

When the player has the Taxi job, they can go to Downtown Cab Co, target the [garage door], and select a Taxi Rental. There are [four] taxis they can take - the Vapid, the Caravan, the Prius, and the GT63. 

When taking a taxi, the player is [charged $1500]. This can be [returned at any point, despawning the car.], though the car must be within the Downtown Cab Co parking lot. 

To "activate" the taxi to be able to receive fares, the player must press [n].

### Illegitimately

A player seeking to imitate a taxi driver has two options. They must be wearing a Cab Co t-shirt to pass at a glance, and they must have "training" with a taxi (that is, they must have at least [level 2] with the Taxi job, and be off-duty.)

They can:

- Steal a cab that was rented by a legitimate cabby. Their experience means [they can hotwire the car without tools]. They can then use the taxi to complete fares, if the taxi was "activated". Otherwise, the taxi is "dead" and can either be returned, or destroyed, or whatever else the car is wanted for.

- Steal a cab from the Downtown Cab Co itself. No legitimate taxi drivers may be present nearby the building, and no taxis will be available for rent for [10 minutes] following the theft. These taxis will not be able to be activated, unless by an on-duty cabby.

## Selecting a fare

Selection of fares can happen three ways.

- First, players may use the `/taxi` command [or the taxi phone app] in-game to request a taxi to their position. If there are players in-game with the taxi job, it will go to them, and they can respond to the job where it is their responsibility. If the player used the app, the taxi will receive a GPS ping with their location. If they used the command, the taxi will receive only the text information given - so the fare must have the required information or it will be rejected.
- Second, players may [select their fare from a list] that is sent by NPCs. These show you the NPC's location as [street names] or [ZIP codes] if your server supports them, as well as an expected fare for getting them to their destination. Their actual destination will be revealed when they get in the taxi.
- Third, players may pick up passengers on the street. Occasionally, peds that the taxi drives past (with lights on) will whistle loudly, and wave. These want to be picked up. They will state their destination when inside.

In any case, when the fare reaches the destination, they will automatically be billed the total amount. Some may choose to add tips - such as those with a different fare type - and some may choose to wait to pay the fee, though invoices tend to have a penalty for late payment.

## Time Limits

Optionally, you may enable time limits for fares. This enforces approximately twice the estimated time for a trip, accounting for speed limits and traffic lights, to ensure that a short trip (Pillbox Hill to Vespucci Boulevard) doesn't end up going way off course (to Paleto Bay) to artifically increase the fare counter.

## Points of Interest

Certain times may be configurable as hotspots for fares. Places like the Pier late at night, the Airport at mid-day, and the train station at morning may on some days have far more fares than average, to provide some incentive for taxi drivers to work together to work through fares, and guarantee work for themselves.

## High Scores

When playing Crazy Taxi mode, you accrue "points" for each daring move you perform. Each point accrued in a certain fare increases the odds of a nearby pedestrian wanting a fare, which allows you to "chain" fares. Every point adds 5 seconds to a timer, but when the timer expires, the current fare being dropped off ends Crazy Taxi mode, and your score is saved. 

You may view, and compare your high scores with other taxi drivers from a bulletin board inside the Downtown Cab Co.