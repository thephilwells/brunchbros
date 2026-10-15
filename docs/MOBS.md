`FREQUENCY` is a relative selection weight among mobs eligible for the current
biome. It does not determine the total number of enemies in a level. A weight
of 8 is the common baseline: WEINER should appear with roughly the regularity
of Spelunky's SNAKE. These initial weights are tuning values, not guarantees.

# WEINER
BIOMES: [ PATIO_1, PATIO_2, DINING_ROOM_1, KITCHEN_1, FREEZER ]
FREQUENCY: 8 (COMMON)
DAMAGE: .5 heart
DIES TO: 1 hit
DESCRIPTION: A hot dog, half chef's height when arched. It inches along like an inchworm, only ever moving forward without malice but with inevitability. When it comes to a wall, it turns and crawls up the wall. When it comes to a ceiling, it turns and crawls across the ceiling. It is a meat tube, a sausage inchworm. Cute and hot to the touch.

# BURGER
BIOMES: [ PATIO_2, DINING_ROOM_2, KITCHEN_1, KITCHEN_2, FREEZER ]
FREQUENCY: 4 (UNCOMMON)
DAMAGE: .5 heart
DIES TO: 2 hits
DESCRIPTION: A hamburger, half chef's height. It propels itself by jumping, like the blobs in the game Terraria. It sits still where it is for a few seconds, then winds up and leaps in chef's direction. If possible it lands on one-way platforms, having no way to get back down through them unless its next leap propels it over the side. 

# PANCAKE
BIOMES: [ DINING_ROOM_1, DINING_ROOM_2, FREEZER ]
FREQUENCY: 3 (UNCOMMON)
DAMAGE: .5 heart
DIES TO: 2 hits
DESCRIPTION: A floppy pancake, spinning in the air at a constant height from the floor, like a UFO. It flies toward the chef, but is slower than Chef's running speed. Its altitude is higher than room-to-room openings, so it can be escaped by just leaving a room. When it finds itself in a fixed goal location, either above chef or abutted aginst a wall, it osciallates a little back and forth, giving the illusion that if it were to hover in one spot it would be doomed. 

# FRIED_EGG
BIOMES: [ DINING_ROOM_1, DINING_ROOM_2, KITCHEN_2, FREEZER ]
FREQUENCY: 2 (UNCOMMON)
DAMAGE: .5 heart
DIES TO: 3 hits
DESCRIPTION: A walking fried egg, capable of walking at Chef's speed and jumping just like Chef. It moves toward Chef whenever Chef is on the same room-level that it is. It attacks by just walking into Chef, oscillating on the ground around stopping points, if possible, similar to how PANCAKE seems restless when it gets where it's going.

# DISCO_FRY
BIOMES: [ KITCHEN_1, KITCHEN_2 ]
FREQUENCY: 1 (RARE)
DAMAGE: 1 heart
DIES TO: 3 hits
DESCRIPTION: A crinkle-cut french fry flying back and forth thru the air at pancake height. The difference is it just flies back and forth in whatever room its in, bumping from wall to wall. It drops one-pixel drops of gravy that do .5 hearts of damage. Attacking the gravy does nothing, only the fry itself can be damaged by Chef.

# ICE_CUBE
BIOMES: [ FREEZER ]
FREQUENCY: 5 (COMMON)
DAMAGE: .5 heart
DIES TO: 5 hits
DESCRIPTION: An ice skating ice cube. It can't jump. It skates back and forth on the floor, attempting to collide with Chef. It moves faster than Chef can run.

# BOSS_MAN
BIOMES: [ FREEZER ]
FREQUENCY: 0 (BOSS_ONLY)
DAMAGE: 1 heart
DIES TO: 8 hits
DESCRIPTION: <TBD>
