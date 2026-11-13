# Patio visual vocabulary

Status: **accepted; permanent atlas allocation recorded**

Patio keeps the shared structural, one-way, exit, and Treasure Egg behavior. Its
identity comes from narrow metal silhouettes, horizontal slats, rectangular
planters, climbing foliage, and sparse suspended lights. Shapes should remain
lighter and more open than Dining Room furniture.

## Traversable furniture

| Family | Footprint | Collision | Visual language |
|---|---:|---|---|
| Café table | 4×2 | One-way tabletop | Thin dark rim, pale slats, narrow paired legs |
| Patio chair | 2×2 | One-way seat | Open slatted back, narrow metal frame |
| Patio bench | 5×2 | One-way seat | Repeated horizontal slats over sparse supports |
| Planter box | 4×2 | One-way rim | Low masonry box with an irregular leafy crown |

Furniture remains optional traversal. Removing it cannot break a required
route. Planters may help a room read as outdoor space, but placement must leave
ports, seams, catch ledges, spawn, exit, eggs, and encounters clear.

## Rear cosmetics

| Family | Footprint | Placement | Visual language |
|---|---:|---|---|
| Trellis vine | 3×4 | Wall mounted | Sparse grid interrupted by a climbing organic line |
| String lights | Repeatable 1×2 modules | High wall or open span | Ceiling-anchored downward sag with widely spaced bulbs |
| Exit awning | 4×2 | Centered above shared exit | Alternating narrow stripes with a shallow scalloped edge |

Rear cosmetics are passable. Trellises and lights stay sparse enough that Chef,
mobs, eggs, hearts, and keys remain legible against them. The awning decorates
the shared exit without changing its footprint or interaction.

## Density

- Most rooms receive no large furniture family or one family.
- Planters cluster near room edges rather than filling central traversal space.
- String lights appear as one deliberate span, not scattered bulbs.
- Trellises are occasional accents and do not repeat in every room.
- The bottom-world fence and shrub horizon remains the dominant Patio motif.

## Permanent atlas allocation

| IDs | Owner | Count |
|---|---|---:|
| 43–46 | Café table | 4 |
| 47–52 | Patio chair, both orientations | 6 |
| 53–56 | Patio bench | 4 |
| 57–62 | Planter box | 6 |
| 63–70 | Exit awning | 8 |
| 71–80 | String lights | 10 |
| 81–86 | Shared open exit; unchanged | 6 |
| 87–98 | Trellis vine | 12 |
| 99–115 | Patio growth reserve | 17 |
| 116–127 | Shared title and Game Over font; unchanged | 12 |

`data/patio-furniture.json` and `data/patio-background.json` own the exact
component matrices. IDs must not move when the pixel art is implemented.
