DEF PORT_WEST EQU $01
DEF PORT_EAST EQU $02
DEF PORT_NORTH EQU $04
DEF PORT_SOUTH EQU $08
DEF TRAVERSAL_LEDGE_CATCH EQU 1
IF DEF(FURNITURE_PARITY_TEST)
INCLUDE "build/seeded_level.inc"
ENDC

SECTION "Level Generation State", WRAM0
SelectedSeed: dw
GenerationRandomState: dw
GenerationShift: dw
GeneratedPlayerX: dw
GeneratedPlayerY: db
GeneratedExitX: db
GeneratedExitY: db
RouteColumns: ds 5
CriticalRouteLength: db
CriticalRoute: ds 16
RoomPorts: ds 16
RoomWidePorts: ds 16
RoomTraversalClasses: ds 16
MatchingParent: ds 16
MatchingOrder: ds 16
MatchingFreeScore: ds 16
MatchingParentScore: ds 16
MatchingChild: ds 16
ConnectedRoomCount: db
ConnectedRooms: ds 16
ConnectedMask: dw
FrontierCount: db
FrontierFrom: ds 32
FrontierTo: ds 32
GenerationRoom: db
GenerationCurrentRoom: db
GenerationColumn: db
GenerationRow: db
GenerationIndex: db
GenerationTarget: db
GenerationTargetRoom: db
BackgroundCandidateCounts: ds 5
BackgroundEligibleCount: db
BackgroundCandidateCount: db
BackgroundComponent: db
BackgroundAnchorRoom: db
BackgroundPlacementRoom: db
BackgroundLocalX: db
BackgroundTopY: db
BackgroundWidth: db
BackgroundHeight: db
BackgroundModulo: db
BackgroundSavedRandomState: dw
BackgroundRoomPorts: db
BackgroundRoomWidePorts: db
FurnitureCandidateCounts: ds 4
FurnitureEligibleCount: db
FurnitureCandidateCount: db
FurnitureComponent: db
FurnitureLocalX: db
FurnitureTopY: db
FurnitureWidth: db
FurnitureHeight: db
FurnitureModulo: db
FurnitureSavedRandomState: dw
FurnitureWorldX: db
FurnitureWorldY: db
FurnitureLeftDistance: db
FurnitureRightDistance: db
WallpaperBlockedTiles: ds 160
FurnitureOccupiedTiles: ds 160
WallpaperCandidateCount: db
WallpaperTargetCount: db
WallpaperSelectionIndex: db
WallpaperTargetOrdinal: db
WallpaperCandidateOrdinal: db
WallpaperLocalX: db
WallpaperLocalY: db
WallpaperWidth: db
WallpaperHeight: db
WallpaperPlacementRoom: db
WallpaperRoomX: db
WallpaperRoomY: db
MobCandidateCounts: ds 16
MobOccupiedTiles: ds 160
MobCandidateCount: db
MobLocalX: db
MobLocalY: db
MobType: db
MobCandidateDirection: db
MobReservationRow: db
MobCandidateOrdinal: db
MobTargetOrdinal: db
MobTargetCount: db
MobSelectedCount: db
MobBestRoom: db
MobBestFound: db
MobBestScore: dw
MobMixResult: dw
MobSavedRandomState: dw
TreasureRoomDistances: ds 16
TreasureRoomUsed: ds 16
TreasureBestDistance: db
TreasureBestUsed: db
TreasureContentsPresent: db
TreasureRelaxPass: db

SECTION "Level Generation", ROM0
GenerateLevel:
IF DEF(FURNITURE_PARITY_TEST)
	ld a, GENERATED_LEVEL_KIND
	ld [CurrentLevelKind], a
	ld a, LOW(GENERATED_LEVEL_SEED)
	ld [SelectedSeed], a
	ld b, a
	ld a, HIGH(GENERATED_LEVEL_SEED)
	ld [SelectedSeed + 1], a
	or a, b
	jr nz, .paritySeedReady
	ld a, $e1
	ld [GenerationRandomState], a
	ld a, $ac
	ld [GenerationRandomState + 1], a
	jr .parityStateReady
.paritySeedReady
	ld a, [SelectedSeed]
	ld [GenerationRandomState], a
	ld a, [SelectedSeed + 1]
	ld [GenerationRandomState + 1], a
.parityStateReady
ENDC
	call GenerateRouteColumns
	call BuildCriticalRoute
	call ConnectRemainingRooms
	call SelectRoomVariants
	call AssembleRoomTemplates
	call ApplyRoomVariants
	call ApplyProtectedEndpoints
	call ConvertSemanticMap
	call PlaceExitDoor
	call ClearWallpaperBlockedTiles
	call ClearFurnitureOccupiedTiles
	call PlaceDiningRoomBackground
	call PlaceDiningRoomFurniture
	call PlaceDiningRoomWallpaper
	call PlaceDiningRoomMobs
	call PlaceDiningRoomTreasure
IF DEF(FURNITURE_PARITY_TEST)
	call VerifyFurnitureParity
	call VerifyMobParity
	call VerifyTreasureParity
ENDC
	ret

GenerateRouteColumns:
	ld hl, RouteColumns
	ld b, 5
.loop
	push bc
	push hl
	call NextGenerationRandom
	pop hl
	pop bc
	ld a, [GenerationRandomState]
	and a, 3
	ld [hl+], a
	dec b
	jr nz, .loop
	ret

NextGenerationRandom:
	ld b, 7
	call XorGenerationLeft
	ld b, 9
	call XorGenerationRight
	ld b, 8
	jp XorGenerationLeft

XorGenerationLeft:
	ld a, [GenerationRandomState]
	ld [GenerationShift], a
	ld a, [GenerationRandomState + 1]
	ld [GenerationShift + 1], a
	ld hl, GenerationShift
.shift
	sla [hl]
	inc hl
	rl [hl]
	dec hl
	dec b
	jr nz, .shift
	ld a, [GenerationShift]
	ld hl, GenerationRandomState
	xor a, [hl]
	ld [hl+], a
	ld a, [GenerationShift + 1]
	xor a, [hl]
	ld [hl], a
	ret

XorGenerationRight:
	ld a, [GenerationRandomState]
	ld [GenerationShift], a
	ld a, [GenerationRandomState + 1]
	ld [GenerationShift + 1], a
	ld hl, GenerationShift + 1
.shift
	srl [hl]
	dec hl
	rr [hl]
	inc hl
	dec b
	jr nz, .shift
	ld a, [GenerationShift]
	ld hl, GenerationRandomState
	xor a, [hl]
	ld [hl+], a
	ld a, [GenerationShift + 1]
	xor a, [hl]
	ld [hl], a
	ret

BuildCriticalRoute:
	ld hl, RoomPorts
	ld b, 16
	xor a
.clearPorts
	ld [hl+], a
	dec b
	jr nz, .clearPorts
	ld hl, CriticalRoute
	ld b, 16
	ld a, $ff
.clearRoute
	ld [hl+], a
	dec b
	jr nz, .clearRoute

	ld a, [RouteColumns]
	ld [GenerationColumn], a
	ld [GenerationCurrentRoom], a
	ld [CriticalRoute], a
	ld a, 1
	ld [CriticalRouteLength], a
	xor a
	ld [GenerationRow], a

.rowLoop
	ld a, [GenerationRow]
	cp a, 3
	jr z, .bottomRun
	inc a
	ld e, a
	ld d, 0
	ld hl, RouteColumns
	add hl, de
	ld a, [hl]
	ld [GenerationTarget], a
	call AppendHorizontalRun
	ld a, [GenerationCurrentRoom]
	add a, 4
	call AppendCriticalRoom
	ld a, [GenerationRow]
	inc a
	ld [GenerationRow], a
	jr .rowLoop

.bottomRun
	ld a, [RouteColumns + 4]
	ld [GenerationTarget], a
	jp AppendHorizontalRun

AppendHorizontalRun:
.loop
	ld a, [GenerationColumn]
	ld b, a
	ld a, [GenerationTarget]
	cp a, b
	ret z
	jr c, .left
	ld a, b
	inc a
	ld [GenerationColumn], a
	ld a, [GenerationCurrentRoom]
	inc a
	call AppendCriticalRoom
	jr .loop
.left
	ld a, b
	dec a
	ld [GenerationColumn], a
	ld a, [GenerationCurrentRoom]
	dec a
	call AppendCriticalRoom
	jr .loop

AppendCriticalRoom:
	ld [GenerationTargetRoom], a
	ld a, [GenerationCurrentRoom]
	ld e, a
	inc a
	ld d, a
	ld a, [GenerationTargetRoom]
	cp a, d
	jr z, .east
	ld a, e
	dec a
	ld d, a
	ld a, [GenerationTargetRoom]
	cp a, d
	jr z, .west
	ld a, e
	add a, 4
	ld d, a
	ld a, [GenerationTargetRoom]
	cp a, d
	jr z, .south
	ret
.east
	ld a, e
	ld b, PORT_EAST
	call OrRoomPort
	ld a, [GenerationTargetRoom]
	ld b, PORT_WEST
	call OrRoomPort
	jr .append
.west
	ld a, e
	ld b, PORT_WEST
	call OrRoomPort
	ld a, [GenerationTargetRoom]
	ld b, PORT_EAST
	call OrRoomPort
	jr .append
.south
	ld a, e
	ld b, PORT_SOUTH
	call OrRoomPort
	ld a, [GenerationTargetRoom]
	ld b, PORT_NORTH
	call OrRoomPort
.append
	ld a, [GenerationTargetRoom]
	ld [GenerationCurrentRoom], a
	ld a, [CriticalRouteLength]
	ld e, a
	ld d, 0
	ld hl, CriticalRoute
	add hl, de
	ld a, [GenerationCurrentRoom]
	ld [hl], a
	ld a, [CriticalRouteLength]
	inc a
	ld [CriticalRouteLength], a
	ret

OrRoomPort:
	ld e, a
	ld d, 0
	ld hl, RoomPorts
	add hl, de
	ld a, [hl]
	or a, b
	ld [hl], a
	ret

ConnectRemainingRooms:
	xor a
	ld [ConnectedMask], a
	ld [ConnectedMask + 1], a
	ld [ConnectedRoomCount], a
	ld [GenerationIndex], a
.copyRoute
	ld a, [GenerationIndex]
	ld b, a
	ld a, [CriticalRouteLength]
	cp a, b
	jr z, .grow
	ld a, b
	ld e, a
	ld d, 0
	ld hl, CriticalRoute
	add hl, de
	ld a, [hl]
	push af
	call AppendConnectedRoom
	pop af
	call MarkRoomConnected
	ld a, [GenerationIndex]
	inc a
	ld [GenerationIndex], a
	jr .copyRoute

.grow
	ld a, [ConnectedRoomCount]
	cp a, 16
	ret z
	call BuildFrontier
	call NextGenerationRandom
	ld a, [FrontierCount]
	ld c, a
	call GenerationRandomModulo
	ld e, a
	ld d, 0
	ld hl, FrontierFrom
	add hl, de
	ld b, [hl]
	ld hl, FrontierTo
	add hl, de
	ld c, [hl]
	push bc
	call AddRoomConnection
	pop bc
	ld a, c
	push af
	call AppendConnectedRoom
	pop af
	call MarkRoomConnected
	jr .grow

BuildFrontier:
	xor a
	ld [FrontierCount], a
	ld [GenerationIndex], a
.roomLoop
	ld a, [GenerationIndex]
	ld b, a
	ld a, [ConnectedRoomCount]
	cp a, b
	ret z
	ld a, b
	ld e, a
	ld d, 0
	ld hl, ConnectedRooms
	add hl, de
	ld a, [hl]
	ld [GenerationRoom], a
	and a, 3
	jr z, .skipWest
	ld a, [GenerationRoom]
	dec a
	call AddFrontierIfUnconnected
.skipWest
	ld a, [GenerationRoom]
	and a, 3
	cp a, 3
	jr z, .skipEast
	ld a, [GenerationRoom]
	inc a
	call AddFrontierIfUnconnected
.skipEast
	ld a, [GenerationRoom]
	cp a, 4
	jr c, .skipNorth
	sub a, 4
	call AddFrontierIfUnconnected
.skipNorth
	ld a, [GenerationRoom]
	cp a, 12
	jr nc, .skipSouth
	add a, 4
	call AddFrontierIfUnconnected
.skipSouth
	ld a, [GenerationIndex]
	inc a
	ld [GenerationIndex], a
	jr .roomLoop

AddFrontierIfUnconnected:
	ld c, a
	call IsRoomConnected
	ret c
	ld a, c
	ld d, a
	ld a, [FrontierCount]
	ld e, a
	ld a, d
	push af
	ld d, 0
	ld hl, FrontierFrom
	add hl, de
	ld a, [GenerationRoom]
	ld [hl], a
	ld hl, FrontierTo
	add hl, de
	pop af
	ld [hl], a
	ld a, [FrontierCount]
	inc a
	ld [FrontierCount], a
	ret

AppendConnectedRoom:
	ld d, a
	ld a, [ConnectedRoomCount]
	ld e, a
	ld a, d
	ld d, 0
	ld hl, ConnectedRooms
	add hl, de
	ld [hl], a
	ld a, [ConnectedRoomCount]
	inc a
	ld [ConnectedRoomCount], a
	ret

MarkRoomConnected:
	cp a, 8
	jr nc, .high
	ld e, a
	ld d, 0
	ld hl, BitMasks
	add hl, de
	ld a, [ConnectedMask]
	or a, [hl]
	ld [ConnectedMask], a
	ret
.high
	sub a, 8
	ld e, a
	ld d, 0
	ld hl, BitMasks
	add hl, de
	ld a, [ConnectedMask + 1]
	or a, [hl]
	ld [ConnectedMask + 1], a
	ret

IsRoomConnected:
	cp a, 8
	jr nc, .high
	ld e, a
	ld d, 0
	ld hl, BitMasks
	add hl, de
	ld a, [ConnectedMask]
	and a, [hl]
	jr z, .clear
	scf
	ret
.high
	sub a, 8
	ld e, a
	ld d, 0
	ld hl, BitMasks
	add hl, de
	ld a, [ConnectedMask + 1]
	and a, [hl]
	jr z, .clear
	scf
	ret
.clear
	and a
	ret

AddRoomConnection:
	ld a, b
	inc a
	cp a, c
	jr z, .east
	ld a, b
	dec a
	cp a, c
	jr z, .west
	ld a, b
	add a, 4
	cp a, c
	jr z, .south
	ld a, b
	ld b, PORT_NORTH
	call OrRoomPort
	ld a, c
	ld b, PORT_SOUTH
	jp OrRoomPort
.east
	ld a, b
	push bc
	ld b, PORT_EAST
	call OrRoomPort
	pop bc
	ld a, c
	ld b, PORT_WEST
	jp OrRoomPort
.west
	ld a, b
	push bc
	ld b, PORT_WEST
	call OrRoomPort
	pop bc
	ld a, c
	ld b, PORT_EAST
	jp OrRoomPort
.south
	ld a, b
	push bc
	ld b, PORT_SOUTH
	call OrRoomPort
	pop bc
	ld a, c
	ld b, PORT_NORTH
	jp OrRoomPort

GenerationRandomModulo:
	ld a, [GenerationRandomState]
	ld e, a
	ld a, [GenerationRandomState + 1]
	ld d, a
	xor a
	ld b, 16
.loop
	sla e
	rl d
	rla
	cp a, c
	jr c, .next
	sub a, c
.next
	dec b
	jr nz, .loop
	ret

SelectRoomVariants:
	ld hl, RoomWidePorts
	ld b, 32
	xor a
.clear
	ld [hl+], a
	dec b
	jr nz, .clear
	call SelectDominoMatching

	xor a
	ld [FrontierCount], a
	ld a, 2
	ld [GenerationIndex], a
.candidateLoop
	ld a, [GenerationIndex]
	add a, 2
	ld b, a
	ld a, [CriticalRouteLength]
	cp a, b
	jr c, .chooseCandidate
	jr z, .chooseCandidate
	ld a, [GenerationIndex]
	ld e, a
	ld d, 0
	ld hl, CriticalRoute
	add hl, de
	ld a, [hl]
	ld [GenerationRoom], a
	dec hl
	ld a, [hl]
	add a, 4
	ld b, a
	ld a, [GenerationRoom]
	cp a, b
	jr nz, .nextCandidate
	inc hl
	inc hl
	ld a, [hl]
	ld [GenerationTargetRoom], a
	ld b, a
	ld a, [GenerationRoom]
	inc a
	cp a, b
	jr z, .eastExit
	ld a, [GenerationRoom]
	dec a
	cp a, b
	jr nz, .nextCandidate
	ld b, PORT_WEST
	jr .checkWideExit
.eastExit
	ld b, PORT_EAST
.checkWideExit
	ld a, [GenerationRoom]
	ld e, a
	ld d, 0
	ld hl, RoomPorts
	add hl, de
	bit 3, [hl]
	jr nz, .nextCandidate
	ld hl, RoomWidePorts
	add hl, de
	ld a, [hl]
	and a, b
	jr z, .nextCandidate
	ld a, [GenerationRoom]
	ld d, a
	ld a, [FrontierCount]
	ld e, a
	ld a, d
	ld d, 0
	ld hl, FrontierTo
	add hl, de
	ld [hl], a
	ld a, [FrontierCount]
	inc a
	ld [FrontierCount], a
.nextCandidate
	ld a, [GenerationIndex]
	inc a
	ld [GenerationIndex], a
	jr .candidateLoop

.chooseCandidate
	ld a, [FrontierCount]
	and a
	ret z
	ld c, a
	call GenerationRandomModulo
	ld e, a
	ld d, 0
	ld hl, FrontierTo
	add hl, de
	ld a, [hl]
	ld e, a
	ld d, 0
	ld hl, RoomTraversalClasses
	add hl, de
	ld [hl], TRAVERSAL_LEDGE_CATCH
	ret

SelectDominoMatching:
	ld hl, MatchingParent
	ld b, 16
	ld a, $ff
.clearParents
	ld [hl+], a
	dec b
	jr nz, .clearParents
	ld a, $fe
	ld [MatchingParent], a
	xor a
	ld [MatchingOrder], a
	ld [GenerationIndex], a
	inc a
	ld [FrontierCount], a

.buildOrder
	ld a, [GenerationIndex]
	ld b, a
	ld a, [FrontierCount]
	cp a, b
	jr z, .scoreRooms
	ld a, b
	ld e, a
	ld d, 0
	ld hl, MatchingOrder
	add hl, de
	ld a, [hl]
	ld [GenerationRoom], a
	ld e, a
	ld d, 0
	ld hl, RoomPorts
	add hl, de
	ld a, [hl]
	ld b, a
	bit 0, b
	jr z, .orderEast
	ld a, [GenerationRoom]
	dec a
	call AppendMatchingChild
.orderEast
	bit 1, b
	jr z, .orderNorth
	ld a, [GenerationRoom]
	inc a
	call AppendMatchingChild
.orderNorth
	bit 2, b
	jr z, .orderSouth
	ld a, [GenerationRoom]
	sub a, 4
	call AppendMatchingChild
.orderSouth
	bit 3, b
	jr z, .orderNext
	ld a, [GenerationRoom]
	add a, 4
	call AppendMatchingChild
.orderNext
	ld a, [GenerationIndex]
	inc a
	ld [GenerationIndex], a
	jr .buildOrder

.scoreRooms
	ld a, [FrontierCount]
	ld [GenerationIndex], a
.scoreRoom
	ld a, [GenerationIndex]
	and a
	jp z, .reconstruct
	dec a
	ld [GenerationIndex], a
	ld e, a
	ld d, 0
	ld hl, MatchingOrder
	add hl, de
	ld a, [hl]
	ld [GenerationRoom], a
	xor a
	ld [GenerationTarget], a
	ld [GenerationTargetRoom], a
.sumChildren
	ld a, [GenerationTargetRoom]
	cp a, 16
	jr z, .storeBase
	ld e, a
	ld d, 0
	ld hl, MatchingParent
	add hl, de
	ld a, [GenerationRoom]
	cp a, [hl]
	jr nz, .sumNext
	ld hl, MatchingFreeScore
	add hl, de
	ld a, [GenerationTarget]
	add a, [hl]
	ld [GenerationTarget], a
.sumNext
	ld a, [GenerationTargetRoom]
	inc a
	ld [GenerationTargetRoom], a
	jr .sumChildren

.storeBase
	ld a, [GenerationRoom]
	ld e, a
	ld d, 0
	ld hl, MatchingParentScore
	add hl, de
	ld a, [GenerationTarget]
	ld [hl], a
	ld hl, MatchingFreeScore
	add hl, de
	ld [hl], a
	ld hl, MatchingChild
	add hl, de
	ld [hl], $ff
	xor a
	ld [GenerationTargetRoom], a
.testChildren
	ld a, [GenerationTargetRoom]
	cp a, 16
	jr z, .scoreRoom
	ld e, a
	ld d, 0
	ld hl, MatchingParent
	add hl, de
	ld a, [GenerationRoom]
	cp a, [hl]
	jr nz, .testNext
	call IsMatchingEdgeEligible
	jr nc, .testNext
	ld a, [GenerationTargetRoom]
	ld e, a
	ld d, 0
	ld hl, MatchingFreeScore
	add hl, de
	ld a, [GenerationTarget]
	sub a, [hl]
	ld b, a
	ld hl, MatchingParentScore
	add hl, de
	ld a, b
	add a, [hl]
	add a, 17
	ld b, a
	push bc
	ld a, [GenerationRoom]
	call RoomInternalBonus
	pop bc
	add a, b
	ld b, a
	push bc
	ld a, [GenerationTargetRoom]
	call RoomInternalBonus
	pop bc
	add a, b
	ld b, a
	ld a, [GenerationRoom]
	ld e, a
	ld d, 0
	ld hl, MatchingFreeScore
	add hl, de
	ld a, [hl]
	cp a, b
	jr nc, .testNext
	ld [hl], b
	ld hl, MatchingChild
	add hl, de
	ld a, [GenerationTargetRoom]
	ld [hl], a
.testNext
	ld a, [GenerationTargetRoom]
	inc a
	ld [GenerationTargetRoom], a
	jr .testChildren

.reconstruct
	ld hl, MatchingParentScore
	ld b, 16
	xor a
.clearMatched
	ld [hl+], a
	dec b
	jr nz, .clearMatched
	ld [GenerationIndex], a
.reconstructRoom
	ld a, [GenerationIndex]
	ld b, a
	ld a, [FrontierCount]
	cp a, b
	ret z
	ld a, b
	ld e, a
	ld d, 0
	ld hl, MatchingOrder
	add hl, de
	ld a, [hl]
	ld [GenerationRoom], a
	ld e, a
	ld d, 0
	ld hl, MatchingParentScore
	add hl, de
	ld a, [hl]
	and a
	jr nz, .reconstructNext
	ld a, [GenerationRoom]
	ld e, a
	ld d, 0
	ld hl, MatchingChild
	add hl, de
	ld a, [hl]
	cp a, $ff
	jr z, .reconstructNext
	ld c, a
	ld a, [GenerationRoom]
	ld b, a
	push bc
	call SetWideConnection
	pop bc
	ld e, c
	ld d, 0
	ld hl, MatchingParentScore
	add hl, de
	ld [hl], 1
.reconstructNext
	ld a, [GenerationIndex]
	inc a
	ld [GenerationIndex], a
	jr .reconstructRoom

AppendMatchingChild:
	ld [GenerationTargetRoom], a
	ld e, a
	ld d, 0
	ld hl, MatchingParent
	add hl, de
	ld a, [hl]
	cp a, $ff
	ret nz
	ld a, [GenerationRoom]
	ld [hl], a
	ld a, [FrontierCount]
	ld e, a
	ld d, 0
	ld hl, MatchingOrder
	add hl, de
	ld a, [GenerationTargetRoom]
	ld [hl], a
	ld a, [FrontierCount]
	inc a
	ld [FrontierCount], a
	ret

IsMatchingEdgeEligible:
	ld a, [GenerationRoom]
	ld b, a
	ld a, [GenerationTargetRoom]
	sub a, b
	cp a, 1
	jr z, .eligible
	cp a, $ff
	jr z, .eligible
	ld a, [GenerationRoom]
	ld b, a
	ld a, [GenerationTargetRoom]
	cp a, b
	jr nc, .upperReady
	ld b, a
.upperReady
	ld a, [CriticalRoute]
	cp a, b
	jr z, .ineligible
	ld a, b
	ld e, a
	ld d, 0
	ld hl, RoomPorts
	add hl, de
	ld a, [hl]
	and a, PORT_WEST | PORT_EAST
	jr nz, .ineligible
.eligible
	scf
	ret
.ineligible
	and a
	ret

RoomInternalBonus:
	ld e, a
	ld d, 0
	ld hl, RoomPorts
	add hl, de
	ld a, [hl]
	ld b, a
	dec a
	and a, b
	ret z
	ld a, 1
	ret

SetWideConnection:
	ld a, b
	inc a
	cp a, c
	jr z, .east
	ld a, b
	dec a
	cp a, c
	jr z, .west
	ld a, b
	add a, 4
	cp a, c
	jr z, .south
	ld a, b
	ld b, PORT_NORTH
	call OrWidePort
	ld a, c
	ld b, PORT_SOUTH
	jp OrWidePort
.east
	ld a, b
	push bc
	ld b, PORT_EAST
	call OrWidePort
	pop bc
	ld a, c
	ld b, PORT_WEST
	jp OrWidePort
.west
	ld a, b
	push bc
	ld b, PORT_WEST
	call OrWidePort
	pop bc
	ld a, c
	ld b, PORT_EAST
	jp OrWidePort
.south
	ld a, b
	push bc
	ld b, PORT_SOUTH
	call OrWidePort
	pop bc
	ld a, c
	ld b, PORT_NORTH
	jp OrWidePort

OrWidePort:
	ld e, a
	ld d, 0
	ld hl, RoomWidePorts
	add hl, de
	ld a, [hl]
	or a, b
	ld [hl], a
	ret

AssembleRoomTemplates:
	xor a
	ld [GenerationRoom], a
.roomLoop
	ld a, [GenerationRoom]
	cp a, 16
	ret z
	call GetRoomDestination
	push hl
	ld a, [GenerationRoom]
	ld e, a
	ld d, 0
	ld hl, RoomPorts
	add hl, de
	ld a, [hl]
	call GetRoomTemplate
	ld d, h
	ld e, l
	pop hl
	ld b, 8
.rowLoop
	ld c, 10
.cellLoop
	ld a, [de]
	ld [hl+], a
	inc de
	dec c
	jr nz, .cellLoop
	ld a, l
	add a, 30
	ld l, a
	jr nc, .rowReady
	inc h
.rowReady
	dec b
	jr nz, .rowLoop
	ld a, [GenerationRoom]
	inc a
	ld [GenerationRoom], a
	jr .roomLoop

GetRoomDestination:
	add a, a
	ld e, a
	ld d, 0
	ld hl, RoomDestinationPointers
	add hl, de
	ld e, [hl]
	inc hl
	ld d, [hl]
	ld h, d
	ld l, e
	ret

GetRoomTemplate:
	dec a
	add a, a
	ld e, a
	ld d, 0
	ld hl, RoomTemplatePointers
	add hl, de
	ld e, [hl]
	inc hl
	ld d, [hl]
	ld h, d
	ld l, e
	ret

ApplyRoomVariants:
	xor a
	ld [GenerationRoom], a
.roomLoop
	ld a, [GenerationRoom]
	cp a, 16
	ret z
	ld e, a
	ld d, 0
	ld hl, RoomTraversalClasses
	add hl, de
	ld a, [hl]
	and a
	call nz, ApplyLedgeCatchRoom
	ld a, [GenerationRoom]
	ld e, a
	ld d, 0
	ld hl, RoomWidePorts
	add hl, de
	ld a, [hl]
	bit 0, a
	call nz, ClearWideWest
	ld a, [GenerationRoom]
	ld e, a
	ld d, 0
	ld hl, RoomWidePorts
	add hl, de
	ld a, [hl]
	bit 1, a
	call nz, ClearWideEast
	ld a, [GenerationRoom]
	ld e, a
	ld d, 0
	ld hl, RoomWidePorts
	add hl, de
	ld a, [hl]
	bit 2, a
	call nz, ClearWideNorth
	ld a, [GenerationRoom]
	ld e, a
	ld d, 0
	ld hl, RoomWidePorts
	add hl, de
	ld a, [hl]
	bit 3, a
	call nz, ClearWideSouth
	ld a, [GenerationRoom]
	inc a
	ld [GenerationRoom], a
	jr .roomLoop

ApplyLedgeCatchRoom:
	ld a, [GenerationRoom]
	call GetRoomDestination
	ld de, 41
	add hl, de
	ld b, 6
.clearRow
	ld c, 8
	xor a
.clearCell
	ld [hl+], a
	dec c
	jr nz, .clearCell
	ld a, l
	add a, 32
	ld l, a
	jr nc, .clearReady
	inc h
.clearReady
	dec b
	jr nz, .clearRow
	ld a, [GenerationRoom]
	call GetRoomDestination
	ld de, 44
	add hl, de
	ld a, 2
	ld [hl+], a
	ld [hl+], a
	ld [hl], a
	ld a, [GenerationRoom]
	ld e, a
	ld d, 0
	ld hl, RoomWidePorts
	add hl, de
	ld b, [hl]
	ld a, [GenerationRoom]
	call GetRoomDestination
	ld de, 121
	bit 0, b
	jr z, .ledgeOffsetReady
	ld de, 126
.ledgeOffsetReady
	add hl, de
	ld a, 1
	ld [hl+], a
	ld [hl+], a
	ld [hl], a
	ret

ClearWideWest:
	ld a, [GenerationRoom]
	call GetRoomDestination
	ld de, 40
	add hl, de
	jr ClearWideVerticalBoundary

ClearWideEast:
	ld a, [GenerationRoom]
	call GetRoomDestination
	ld de, 49
	add hl, de
	jr ClearWideVerticalBoundary

ClearWideNorth:
	ld a, [GenerationRoom]
	call GetRoomDestination
	inc hl
	jr ClearWideHorizontalBoundary

ClearWideSouth:
	ld a, [GenerationRoom]
	call GetRoomDestination
	ld de, 281
	add hl, de

ClearWideHorizontalBoundary:
	ld b, 8
	xor a
.loop
	ld [hl+], a
	dec b
	jr nz, .loop
	ret

ClearWideVerticalBoundary:
	ld b, 6
	xor a
.loop
	ld [hl], a
	ld de, 40
	add hl, de
	dec b
	jr nz, .loop
	ret

ApplyProtectedEndpoints:
	ld a, [CriticalRoute]
	ld [GenerationRoom], a
	call GetRoomDestination
	ld de, 41
	add hl, de
	ld b, 6
.spawnClearRow
	ld c, 3
	xor a
.spawnClearCell
	ld [hl+], a
	dec c
	jr nz, .spawnClearCell
	ld a, l
	add a, 37
	ld l, a
	jr nc, .spawnClearReady
	inc h
.spawnClearReady
	dec b
	jr nz, .spawnClearRow
	ld a, [GenerationRoom]
	call GetRoomDestination
	ld de, 281
	add hl, de
	ld a, 1
	ld [hl+], a
	ld [hl+], a
	ld [hl], a
	call SetGeneratedPlayerPosition

	ld a, [CriticalRouteLength]
	dec a
	ld e, a
	ld d, 0
	ld hl, CriticalRoute
	add hl, de
	ld a, [hl]
	ld [GenerationRoom], a
	call GetRoomDestination
	ld de, 41
	add hl, de
	ld b, 6
.exitClearRow
	ld c, 4
	xor a
.exitClearCell
	ld [hl+], a
	dec c
	jr nz, .exitClearCell
	ld a, l
	add a, 36
	ld l, a
	jr nc, .exitClearReady
	inc h
.exitClearReady
	dec b
	jr nz, .exitClearRow
	ld a, [GenerationRoom]
	call GetRoomDestination
	ld de, 281
	add hl, de
	ld a, 1
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl], a
	ld a, [GenerationRoom]
	ld e, a
	ld d, 0
	ld hl, RoomPorts
	add hl, de
	bit 2, [hl]
	jr z, .exitReady
	ld a, [GenerationRoom]
	call GetRoomDestination
	ld de, 165
	add hl, de
	ld a, 2
	ld [hl+], a
	ld [hl+], a
	ld [hl], a
.exitReady
	jp SetGeneratedExitPosition

SetGeneratedPlayerPosition:
	ld a, [GenerationRoom]
	and a, 3
	ld b, a
	ld hl, 20
	ld de, 80
.xLoop
	ld a, b
	and a
	jr z, .xReady
	add hl, de
	dec b
	jr .xLoop
.xReady
	ld a, l
	ld [GeneratedPlayerX], a
	ld a, h
	ld [GeneratedPlayerX + 1], a
	ld a, [GenerationRoom]
	srl a
	srl a
	ld b, a
	ld a, 56
.yLoop
	ld c, a
	ld a, b
	and a
	ld a, c
	jr z, .yReady
	add a, 64
	dec b
	jr .yLoop
.yReady
	ld [GeneratedPlayerY], a
	ret

SetGeneratedExitPosition:
	ld a, [GenerationRoom]
	and a, 3
	ld b, a
	xor a
.xLoop
	ld c, a
	ld a, b
	and a
	ld a, c
	jr z, .xReady
	add a, 10
	dec b
	jr .xLoop
.xReady
	inc a
	ld [GeneratedExitX], a
	ld a, [GenerationRoom]
	srl a
	srl a
	add a, a
	add a, a
	add a, a
	add a, 4
	ld [GeneratedExitY], a
	ret

ConvertSemanticMap:
	xor a
	ld [GenerationRow], a
	ld [GenerationColumn], a
	ld hl, LevelMap
.cellLoop
	ld a, [hl]
	and a
	jr z, .empty
	cp a, 2
	jr z, .oneWay
	ld b, 0
	ld a, [GenerationRow]
	and a
	jr z, .skipUp
	push hl
	ld de, -40
	add hl, de
	call SemanticSolidAtHL
	pop hl
	jr nc, .skipUp
	set 0, b
.skipUp
	ld a, [GenerationColumn]
	cp a, 39
	jr z, .skipRight
	push hl
	inc hl
	call SemanticSolidAtHL
	pop hl
	jr nc, .skipRight
	set 1, b
.skipRight
	ld a, [GenerationRow]
	cp a, 31
	jr z, .skipDown
	push hl
	ld de, 40
	add hl, de
	call SemanticSolidAtHL
	pop hl
	jr nc, .skipDown
	set 2, b
.skipDown
	ld a, [GenerationColumn]
	and a
	jr z, .solidReady
	push hl
	dec hl
	call SemanticSolidAtHL
	pop hl
	jr nc, .solidReady
	set 3, b
.solidReady
	ld a, b
	inc a
	or a, $80
	ld [hl], a
	jr .next
.empty
	ld [hl], 17
	jr .next
.oneWay
	ld [hl], 50
.next
	inc hl
	ld a, [GenerationColumn]
	inc a
	cp a, 40
	jr c, .storeColumn
	xor a
	ld [GenerationColumn], a
	ld a, [GenerationRow]
	inc a
	ld [GenerationRow], a
	cp a, 32
	jr c, .cellLoop
	jr .clearMarkers
.storeColumn
	ld [GenerationColumn], a
	jr .cellLoop

.clearMarkers
	ld hl, LevelMap
	ld b, 5
.clearOuter
	ld c, 0
.clearInner
	res 7, [hl]
	inc hl
	dec c
	jr nz, .clearInner
	dec b
	jr nz, .clearOuter
	ret

SemanticSolidAtHL:
	ld a, [hl]
	cp a, 1
	jr z, .solid
	bit 7, a
	jr nz, .solid
	and a
	ret
.solid
	scf
	ret

PlaceExitDoor:
	ld a, [GeneratedExitX]
	ld b, a
	ld a, [GeneratedExitY]
	ld c, a
	call GetMapTilePointer
	ld a, 25
	ld b, 3
.rowLoop
	ld [hl+], a
	inc a
	ld [hl], a
	inc a
	ld de, 39
	add hl, de
	dec b
	jr nz, .rowLoop
	ret

PlaceDiningRoomBackground:
	xor a
	ld [GenerationRoom], a
.roomLoop
	ld a, [GenerationRoom]
	cp a, 16
	ret z
	call IsBackgroundChamberAnchor
	jp nc, .nextRoom
	ld a, [GenerationRoom]
	ld [BackgroundAnchorRoom], a
	xor a
	ld [BackgroundEligibleCount], a
	ld [BackgroundComponent], a
.countComponents
	call LoadBackgroundDimensions
	call CountBackgroundCandidates
	push af
	ld b, a
	ld a, [BackgroundComponent]
	ld e, a
	ld d, 0
	ld hl, BackgroundCandidateCounts
	add hl, de
	ld [hl], b
	pop af
	and a
	jr z, .nextComponent
	ld hl, BackgroundEligibleCount
	inc [hl]
.nextComponent
	ld a, [BackgroundComponent]
	inc a
	ld [BackgroundComponent], a
	cp a, 5
	jr c, .countComponents
	ld a, [BackgroundEligibleCount]
	and a
	jp z, .nextRoom
	call BackgroundGroupRandomModulo
	ld [GenerationTarget], a
	xor a
	ld [BackgroundComponent], a
.findComponent
	ld e, a
	ld d, 0
	ld hl, BackgroundCandidateCounts
	add hl, de
	ld a, [hl]
	and a
	jr z, .skipComponent
	ld a, [GenerationTarget]
	and a
	jr z, .componentReady
	dec a
	ld [GenerationTarget], a
.skipComponent
	ld a, [BackgroundComponent]
	inc a
	ld [BackgroundComponent], a
	jr .findComponent
.componentReady
	ld a, [BackgroundComponent]
	ld e, a
	ld d, 0
	ld hl, BackgroundCandidateCounts
	add hl, de
	ld a, [hl]
	call BackgroundPositionRandomModulo
	ld [GenerationTarget], a
	call LoadBackgroundDimensions
	ld a, [BackgroundComponent]
	cp a, 3
	jr z, .placeSconces
	call FindBackgroundPosition
	call PlaceBackgroundComponent
	jr .nextRoom
.placeSconces
	call SetFirstSconcePosition
	call PlaceBackgroundComponent
	call SetSecondSconcePosition
	call PlaceBackgroundComponent
.nextRoom
	ld hl, GenerationRoom
	inc [hl]
	jp .roomLoop

IsBackgroundChamberAnchor:
	ld e, a
	ld d, 0
	ld hl, RoomWidePorts
	add hl, de
	ld a, [hl]
	and a, PORT_WEST | PORT_NORTH
	ret nz
	scf
	ret

LoadBackgroundDimensions:
	ld a, [BackgroundComponent]
	ld e, a
	ld d, 0
	ld hl, DiningBackgroundWidths
	add hl, de
	ld a, [hl]
	ld [BackgroundWidth], a
	ld hl, DiningBackgroundHeights
	add hl, de
	ld a, [hl]
	ld [BackgroundHeight], a
	ld hl, DiningBackgroundTopRows
	add hl, de
	ld a, [hl]
	ld [BackgroundTopY], a
	ret

CountBackgroundCandidates:
	ld a, [BackgroundComponent]
	cp a, 3
	jr nz, .ordinary
	call IsSconcePairAvailable
	ld a, 0
	ret nc
	inc a
	ret
.ordinary
	xor a
	ld [BackgroundCandidateCount], a
	call SetFirstBackgroundMountingRoom
.roomLoop
	ld a, 1
	ld [BackgroundLocalX], a
.positionLoop
	call IsBackgroundCandidate
	jr nc, .nextPosition
	ld hl, BackgroundCandidateCount
	inc [hl]
.nextPosition
	ld a, [BackgroundLocalX]
	inc a
	ld [BackgroundLocalX], a
	ld b, a
	ld a, 10
	ld c, a
	ld a, [BackgroundWidth]
	ld e, a
	ld a, c
	sub a, e
	cp a, b
	jr nz, .positionLoop
	call AdvanceBackgroundMountingRoom
	jr c, .roomLoop
	ld a, [BackgroundCandidateCount]
	ret

SetFirstBackgroundMountingRoom:
	ld a, [BackgroundAnchorRoom]
	ld [BackgroundPlacementRoom], a
	ld e, a
	ld d, 0
	ld hl, RoomWidePorts
	add hl, de
	bit 3, [hl]
	ret z
	ld a, [BackgroundPlacementRoom]
	add a, 4
	ld [BackgroundPlacementRoom], a
	ret

AdvanceBackgroundMountingRoom:
	ld a, [BackgroundAnchorRoom]
	ld e, a
	ld d, 0
	ld hl, RoomWidePorts
	add hl, de
	bit 1, [hl]
	jr z, .done
	ld a, [BackgroundPlacementRoom]
	ld b, a
	ld a, [BackgroundAnchorRoom]
	cp a, b
	jr nz, .done
	inc a
	ld [BackgroundPlacementRoom], a
	scf
	ret
.done
	and a
	ret

IsSconcePairAvailable:
	call SetFirstSconcePosition
	call IsBackgroundCandidate
	ret nc
	call SetSecondSconcePosition
	jp IsBackgroundCandidate

SetFirstSconcePosition:
	ld a, [BackgroundAnchorRoom]
	ld [BackgroundPlacementRoom], a
	ld e, a
	ld d, 0
	ld hl, RoomWidePorts
	add hl, de
	bit 1, [hl]
	jr nz, .horizontal
	bit 3, [hl]
	jr z, .single
	ld a, [BackgroundPlacementRoom]
	add a, 4
	ld [BackgroundPlacementRoom], a
.single
	ld a, 3
	ld [BackgroundLocalX], a
	ret
.horizontal
	ld a, 6
	ld [BackgroundLocalX], a
	ret

SetSecondSconcePosition:
	ld a, [BackgroundAnchorRoom]
	ld [BackgroundPlacementRoom], a
	ld e, a
	ld d, 0
	ld hl, RoomWidePorts
	add hl, de
	bit 1, [hl]
	jr z, .singleOrVertical
	ld a, [BackgroundPlacementRoom]
	inc a
	ld [BackgroundPlacementRoom], a
	ld a, 3
	ld [BackgroundLocalX], a
	ret
.singleOrVertical
	bit 3, [hl]
	jr z, .single
	ld a, [BackgroundPlacementRoom]
	add a, 4
	ld [BackgroundPlacementRoom], a
.single
	ld a, 6
	ld [BackgroundLocalX], a
	ret

FindBackgroundPosition:
	call SetFirstBackgroundMountingRoom
.roomLoop
	ld a, 1
	ld [BackgroundLocalX], a
.positionLoop
	call IsBackgroundCandidate
	jr nc, .nextPosition
	ld a, [GenerationTarget]
	and a
	ret z
	dec a
	ld [GenerationTarget], a
.nextPosition
	ld a, [BackgroundLocalX]
	inc a
	ld [BackgroundLocalX], a
	ld b, a
	ld a, 10
	ld c, a
	ld a, [BackgroundWidth]
	ld e, a
	ld a, c
	sub a, e
	cp a, b
	jr nz, .positionLoop
	call AdvanceBackgroundMountingRoom
	jr c, .roomLoop
	ret

IsBackgroundCandidate:
	call IsBackgroundFootprintReserved
	jr c, .invalid
	call GetBackgroundTopPointer
	ld a, 40
	ld e, a
	ld a, [BackgroundWidth]
	ld c, a
	ld a, e
	sub a, c
	ld e, a
	ld d, 0
	ld a, [BackgroundHeight]
	ld b, a
.rowLoop
	ld a, [BackgroundWidth]
	ld c, a
.cellLoop
	ld a, [hl+]
	cp a, 17
	jr nz, .invalid
	dec c
	jr nz, .cellLoop
	add hl, de
	dec b
	jr nz, .rowLoop
	scf
	ret
.invalid
	and a
	ret

IsBackgroundFootprintReserved:
	; All current mounting bands intersect both standard port approach bands.
	ld a, [BackgroundPlacementRoom]
	ld e, a
	ld d, 0
	ld hl, RoomTraversalClasses
	add hl, de
	ld a, [hl]
	and a
	jp nz, .reserved
	ld a, [BackgroundPlacementRoom]
	ld b, a
	ld a, [CriticalRoute]
	cp a, b
	jr nz, .exit
	ld a, [BackgroundLocalX]
	cp a, 5
	jr c, .reserved
.exit
	ld a, [CriticalRouteLength]
	dec a
	ld e, a
	ld d, 0
	ld hl, CriticalRoute
	add hl, de
	ld a, [hl]
	cp a, b
	jr nz, .ports
	ld a, [BackgroundLocalX]
	cp a, 6
	jr c, .reserved
.ports
	ld e, b
	ld d, 0
	ld hl, RoomPorts
	add hl, de
	ld a, [hl]
	ld [BackgroundRoomPorts], a
	ld hl, RoomWidePorts
	add hl, de
	ld a, [hl]
	ld [BackgroundRoomWidePorts], a
	ld a, [BackgroundRoomPorts]
	bit 0, a
	jr z, .east
	ld a, [BackgroundLocalX]
	cp a, 3
	jr c, .reserved
.east
	ld a, [BackgroundRoomPorts]
	bit 1, a
	jr z, .north
	ld a, [BackgroundLocalX]
	ld b, a
	ld a, [BackgroundWidth]
	add a, b
	cp a, 8
	jr nc, .reserved
.north
	ld a, [BackgroundRoomPorts]
	bit 2, a
	jr z, .south
	ld a, [BackgroundRoomWidePorts]
	bit 2, a
	jr nz, .reserved
	call BackgroundOverlapsCentralPort
	jr c, .reserved
.south
	ld a, [BackgroundRoomPorts]
	bit 3, a
	jr z, .clear
	ld a, [BackgroundRoomWidePorts]
	bit 3, a
	jr nz, .reserved
	call BackgroundOverlapsCentralPort
	jr c, .reserved
.clear
	and a
	ret
.reserved
	scf
	ret

BackgroundOverlapsCentralPort:
	ld a, [BackgroundLocalX]
	cp a, 8
	jr nc, .clear
	ld b, a
	ld a, [BackgroundWidth]
	add a, b
	cp a, 4
	jr c, .clear
	scf
	ret
.clear
	and a
	ret

GetBackgroundTopPointer:
	ld a, [BackgroundPlacementRoom]
	call GetRoomDestination
	ld a, [BackgroundTopY]
	ld b, a
	ld de, 40
.rowLoop
	ld a, b
	and a
	jr z, .rowsReady
	add hl, de
	dec b
	jr .rowLoop
.rowsReady
	ld a, [BackgroundLocalX]
	ld e, a
	ld d, 0
	add hl, de
	ret

PlaceBackgroundComponent:
	call MarkBackgroundWallpaperFootprint
	call GetBackgroundTopPointer
	push hl
	ld hl, DiningBackgroundTilePointers
	ld a, [BackgroundComponent]
	add a, a
	ld e, a
	ld d, 0
	add hl, de
	ld e, [hl]
	inc hl
	ld d, [hl]
	pop hl
	ld a, 40
	ld c, a
	ld a, [BackgroundWidth]
	ld b, a
	ld a, c
	sub a, b
	ld c, a
	ld a, [BackgroundHeight]
	ld b, a
.rowLoop
	push bc
	ld a, [BackgroundWidth]
	ld c, a
.cellLoop
	ld a, [de]
	ld [hl+], a
	inc de
	dec c
	jr nz, .cellLoop
	pop bc
	ld a, l
	add a, c
	ld l, a
	jr nc, .rowReady
	inc h
.rowReady
	dec b
	jr nz, .rowLoop
	ret

BackgroundGroupRandomModulo:
	ld de, $b529
	jr BackgroundSelectionModulo

BackgroundPositionRandomModulo:
	ld de, $68e3

BackgroundSelectionModulo:
	ld [BackgroundModulo], a
	ld a, [GenerationRandomState]
	ld [BackgroundSavedRandomState], a
	ld a, [GenerationRandomState + 1]
	ld [BackgroundSavedRandomState + 1], a
	ld a, [SelectedSeed]
	ld b, a
	ld a, [SelectedSeed + 1]
	ld c, a
	ld a, b
	or a, c
	jr nz, .seedReady
	ld b, $e1
	ld c, $ac
.seedReady
	push de
	ld a, [BackgroundAnchorRoom]
	add a, a
	ld e, a
	ld d, 0
	ld hl, FurnitureRoomMix
	add hl, de
	pop de
	ld a, [hl+]
	xor a, b
	xor a, e
	ld [GenerationRandomState], a
	ld a, [hl]
	xor a, c
	xor a, d
	ld [GenerationRandomState + 1], a
	call NextGenerationRandom
	ld a, [BackgroundModulo]
	ld c, a
	call GenerationRandomModulo
	push af
	ld a, [BackgroundSavedRandomState]
	ld [GenerationRandomState], a
	ld a, [BackgroundSavedRandomState + 1]
	ld [GenerationRandomState + 1], a
	pop af
	ret

PlaceDiningRoomFurniture:
	xor a
	ld [GenerationRoom], a
.roomLoop
	ld a, [GenerationRoom]
	cp a, 16
	ret z
	call IsFurnitureRoomEligible
	jp nc, .nextRoom
	xor a
	ld [FurnitureEligibleCount], a
	ld [FurnitureComponent], a
.countComponents
	call LoadFurnitureDimensions
	call CountFurnitureCandidates
	push af
	ld b, a
	ld a, [FurnitureComponent]
	ld e, a
	ld d, 0
	ld hl, FurnitureCandidateCounts
	add hl, de
	ld [hl], b
	pop af
	and a
	jr z, .nextComponent
	ld hl, FurnitureEligibleCount
	inc [hl]
.nextComponent
	ld a, [FurnitureComponent]
	inc a
	ld [FurnitureComponent], a
	cp a, 4
	jr c, .countComponents
	ld a, [FurnitureEligibleCount]
	and a
	jp z, .nextRoom
	call FurnitureGroupRandomModulo
	ld [GenerationTarget], a
	xor a
	ld [FurnitureComponent], a
.findComponent
	ld e, a
	ld d, 0
	ld hl, FurnitureCandidateCounts
	add hl, de
	ld a, [hl]
	and a
	jr z, .skipComponent
	ld a, [GenerationTarget]
	and a
	jr z, .componentReady
	dec a
	ld [GenerationTarget], a
.skipComponent
	ld a, [FurnitureComponent]
	inc a
	ld [FurnitureComponent], a
	jr .findComponent
.componentReady
	ld a, [FurnitureComponent]
	ld e, a
	ld d, 0
	ld hl, FurnitureCandidateCounts
	add hl, de
	ld a, [hl]
	call FurniturePositionRandomModulo
	ld [GenerationTarget], a
	call LoadFurnitureDimensions
	xor a
	ld [FurnitureLocalX], a
.findPosition
	call IsFurnitureCandidate
	jr nc, .advancePosition
	ld a, [GenerationTarget]
	and a
	jr z, .place
	dec a
	ld [GenerationTarget], a
.advancePosition
	ld hl, FurnitureLocalX
	inc [hl]
	jr .findPosition
.place
	call PlaceFurnitureComponent
.nextRoom
	ld hl, GenerationRoom
	inc [hl]
	jp .roomLoop

IsFurnitureRoomEligible:
	ld b, a
	ld hl, CriticalRoute
	ld a, [CriticalRouteLength]
	ld c, a
.criticalLoop
	ld a, [hl+]
	cp a, b
	jr z, .ineligible
	dec c
	jr nz, .criticalLoop
	ld e, b
	ld d, 0
	ld hl, RoomTraversalClasses
	add hl, de
	ld a, [hl]
	and a
	jr nz, .ineligible
	scf
	ret
.ineligible
	and a
	ret

LoadFurnitureDimensions:
	ld a, [FurnitureComponent]
	ld e, a
	ld d, 0
	ld hl, DiningFurnitureWidths
	add hl, de
	ld a, [hl]
	ld [FurnitureWidth], a
	ld hl, DiningFurnitureHeights
	add hl, de
	ld a, [hl]
	ld [FurnitureHeight], a
	ld b, a
	ld a, 7
	sub a, b
	ld [FurnitureTopY], a
	ret

CountFurnitureCandidates:
	xor a
	ld [FurnitureCandidateCount], a
	ld [FurnitureLocalX], a
.loop
	call IsFurnitureCandidate
	jr nc, .next
	ld hl, FurnitureCandidateCount
	inc [hl]
.next
	ld a, [FurnitureWidth]
	ld b, a
	ld a, 10
	sub a, b
	ld b, a
	ld a, [FurnitureLocalX]
	cp a, b
	jr z, .done
	inc a
	ld [FurnitureLocalX], a
	jr .loop
.done
	ld a, [FurnitureCandidateCount]
	ret

IsFurnitureCandidate:
	call IsFurnitureFootprintReserved
	jr c, .invalid
	call GetFurnitureTopPointer
	ld a, 40
	ld e, a
	ld a, [FurnitureWidth]
	ld c, a
	ld a, e
	sub a, c
	ld e, a
	ld d, 0
	ld a, [FurnitureHeight]
	ld b, a
.emptyRow
	ld a, [FurnitureWidth]
	ld c, a
.emptyCell
	ld a, [hl+]
	cp a, 17
	jr nz, .invalid
	dec c
	jr nz, .emptyCell
	add hl, de
	dec b
	jr nz, .emptyRow
	ld a, [GenerationRoom]
	call GetRoomDestination
	ld de, 280
	add hl, de
	ld a, [FurnitureLocalX]
	ld e, a
	ld d, 0
	add hl, de
	ld a, [FurnitureWidth]
	ld b, a
.supportCell
	ld a, [hl+]
	cp a, 1
	jr c, .invalid
	cp a, 17
	jr nc, .invalid
	dec b
	jr nz, .supportCell
	scf
	ret
.invalid
	and a
	ret

IsFurnitureFootprintReserved:
	ld a, [GenerationRoom]
	ld e, a
	ld d, 0
	ld hl, RoomPorts
	add hl, de
	ld b, [hl]
	bit 0, b
	jr z, .east
	ld a, [FurnitureLocalX]
	cp a, 3
	jr c, .reserved
.east
	bit 1, b
	jr z, .south
	ld a, [FurnitureLocalX]
	ld c, a
	ld a, [FurnitureWidth]
	add a, c
	dec a
	cp a, 7
	jr nc, .reserved
.south
	bit 3, b
	jr z, .clear
	ld hl, RoomWidePorts
	add hl, de
	bit 3, [hl]
	jr nz, .reserved
	ld a, [FurnitureLocalX]
	ld c, a
	ld a, [FurnitureWidth]
	add a, c
	dec a
	cp a, 3
	jr c, .clear
	ld a, [FurnitureLocalX]
	cp a, 8
	jr nc, .clear
.reserved
	scf
	ret
.clear
	and a
	ret

GetFurnitureTopPointer:
	ld a, [GenerationRoom]
	call GetRoomDestination
	ld a, [FurnitureTopY]
	ld b, a
	ld de, 40
.rowLoop
	ld a, b
	and a
	jr z, .rowsReady
	add hl, de
	dec b
	jr .rowLoop
.rowsReady
	ld a, [FurnitureLocalX]
	ld e, a
	ld d, 0
	add hl, de
	ret

PlaceFurnitureComponent:
	call MarkFurnitureOccupiedFootprint
	call MarkFurnitureWallpaperFootprint
	call GetFurnitureTopPointer
	push hl
	ld a, [FurnitureComponent]
	cp a, 1
	jr nz, .baseTiles
	call IsChairBackLeft
	jr nc, .baseTiles
	ld hl, DiningFurnitureAlternateTilePointers
	jr .tilePointer
.baseTiles
	ld hl, DiningFurnitureTilePointers
.tilePointer
	ld a, [FurnitureComponent]
	add a, a
	ld e, a
	ld d, 0
	add hl, de
	ld e, [hl]
	inc hl
	ld d, [hl]
	pop hl
	ld a, 40
	ld c, a
	ld a, [FurnitureWidth]
	ld b, a
	ld a, c
	sub a, b
	ld c, a
	ld a, [FurnitureHeight]
	ld b, a
.rowLoop
	push bc
	ld a, [FurnitureWidth]
	ld c, a
.cellLoop
	ld a, [de]
	ld [hl+], a
	inc de
	dec c
	jr nz, .cellLoop
	pop bc
	ld a, l
	add a, c
	ld l, a
	jr nc, .rowReady
	inc h
.rowReady
	dec b
	jr nz, .rowLoop
	ret

IsChairBackLeft:
	ld a, [GenerationRoom]
	and a, 3
	ld b, a
	add a, a
	ld c, a
	ld a, b
	add a, a
	add a, a
	add a, a
	add a, c
	ld b, a
	ld a, [FurnitureLocalX]
	add a, b
	ld [FurnitureWorldX], a
	ld a, [GenerationRoom]
	srl a
	srl a
	add a, a
	add a, a
	add a, a
	ld b, a
	ld a, [FurnitureTopY]
	add a, b
	ld b, a
	ld a, [FurnitureHeight]
	dec a
	add a, b
	ld [FurnitureWorldY], a
	ld a, [FurnitureWorldX]
	ld b, a
	ld a, [FurnitureWorldY]
	ld c, a
	call GetMapTilePointer
	xor a
	ld [FurnitureLeftDistance], a
	ld a, [FurnitureWorldX]
	ld c, a
.scanLeft
	ld a, c
	and a
	jr z, .scanRightReady
	dec hl
	dec c
	ld a, [hl]
	cp a, 1
	jr c, .leftEmpty
	cp a, 17
	jr c, .scanRightReady
.leftEmpty
	ld a, [FurnitureLeftDistance]
	inc a
	ld [FurnitureLeftDistance], a
	jr .scanLeft
.scanRightReady
	xor a
	ld [FurnitureRightDistance], a
	ld a, [FurnitureWorldX]
	ld b, a
	ld a, [FurnitureWidth]
	add a, b
	ld b, a
	cp a, 40
	jr nc, .compare
	ld a, [FurnitureWorldY]
	ld c, a
	call GetMapTilePointer
	ld a, b
	ld c, a
.scanRight
	ld a, [hl+]
	cp a, 1
	jr c, .rightEmpty
	cp a, 17
	jr c, .compare
.rightEmpty
	ld a, [FurnitureRightDistance]
	inc a
	ld [FurnitureRightDistance], a
	inc c
	ld a, c
	cp a, 40
	jr c, .scanRight
.compare
	ld a, [FurnitureRightDistance]
	ld b, a
	ld a, [FurnitureLeftDistance]
	cp a, b
	jr c, .backLeft
	jr z, .backLeft
	and a
	ret
.backLeft
	scf
	ret

FurnitureGroupRandomModulo:
	ld de, $41c6
	jr FurnitureSelectionModulo

FurniturePositionRandomModulo:
	ld de, $7f4a

FurnitureSelectionModulo:
	ld [FurnitureModulo], a
	ld a, [GenerationRandomState]
	ld [FurnitureSavedRandomState], a
	ld a, [GenerationRandomState + 1]
	ld [FurnitureSavedRandomState + 1], a
	ld a, [SelectedSeed]
	ld b, a
	ld a, [SelectedSeed + 1]
	ld c, a
	ld a, b
	or a, c
	jr nz, .seedReady
	ld b, $e1
	ld c, $ac
.seedReady
	push de
	ld a, [GenerationRoom]
	add a, a
	ld e, a
	ld d, 0
	ld hl, FurnitureRoomMix
	add hl, de
	pop de
	ld a, [hl+]
	xor a, b
	xor a, e
	ld [GenerationRandomState], a
	ld a, [hl]
	xor a, c
	xor a, d
	ld [GenerationRandomState + 1], a
	call NextGenerationRandom
	ld a, [FurnitureModulo]
	ld c, a
	call GenerationRandomModulo
	push af
	ld a, [FurnitureSavedRandomState]
	ld [GenerationRandomState], a
	ld a, [FurnitureSavedRandomState + 1]
	ld [GenerationRandomState + 1], a
	pop af
	ret

ClearWallpaperBlockedTiles:
	ld hl, WallpaperBlockedTiles
	ld b, 160
	xor a
.loop
	ld [hl+], a
	dec b
	jr nz, .loop
	ret

ClearFurnitureOccupiedTiles:
	ld hl, FurnitureOccupiedTiles
	ld b, 160
	xor a
.loop
	ld [hl+], a
	dec b
	jr nz, .loop
	ret

MarkFurnitureOccupiedFootprint:
	call GetFurnitureTopPointer
	ld a, [FurnitureHeight]
	ld b, a
.rowLoop
	push bc
	ld a, [FurnitureWidth]
	ld c, a
.cellLoop
	push bc
	push hl
	call MarkFurnitureCellOccupied
	pop hl
	pop bc
	inc hl
	dec c
	jr nz, .cellLoop
	ld a, 40
	ld c, a
	ld a, [FurnitureWidth]
	ld b, a
	ld a, c
	sub a, b
	ld e, a
	ld d, 0
	add hl, de
	pop bc
	dec b
	jr nz, .rowLoop
	ret

MarkFurnitureCellOccupied:
	ld de, LevelMap
	ld a, l
	sub a, e
	ld l, a
	ld a, h
	sbc a, d
	ld h, a
	ld a, l
	and a, 7
	ld e, a
	ld d, 0
	srl h
	rr l
	srl h
	rr l
	srl h
	rr l
	ld bc, FurnitureOccupiedTiles
	add hl, bc
	push hl
	ld hl, BitMasks
	add hl, de
	ld a, [hl]
	pop hl
	or a, [hl]
	ld [hl], a
	ret

MarkBackgroundWallpaperFootprint:
	call GetBackgroundTopPointer
	ld a, [BackgroundWidth]
	ld [WallpaperWidth], a
	ld a, [BackgroundHeight]
	ld [WallpaperHeight], a
	jp MarkWallpaperFootprint

MarkFurnitureWallpaperFootprint:
	call GetFurnitureTopPointer
	ld a, [FurnitureWidth]
	ld [WallpaperWidth], a
	ld a, [FurnitureHeight]
	ld [WallpaperHeight], a

MarkWallpaperFootprint:
	ld a, [WallpaperHeight]
	ld b, a
.rowLoop
	push bc
	ld a, [WallpaperWidth]
	ld c, a
.cellLoop
	push bc
	push hl
	call MarkWallpaperCellBlocked
	pop hl
	pop bc
	inc hl
	dec c
	jr nz, .cellLoop
	ld a, 40
	ld c, a
	ld a, [WallpaperWidth]
	ld b, a
	ld a, c
	sub a, b
	ld e, a
	ld d, 0
	add hl, de
	pop bc
	dec b
	jr nz, .rowLoop
	ret

MarkWallpaperCellBlocked:
	ld de, LevelMap
	ld a, l
	sub a, e
	ld l, a
	ld a, h
	sbc a, d
	ld h, a
	ld a, l
	and a, 7
	ld e, a
	ld d, 0
	srl h
	rr l
	srl h
	rr l
	srl h
	rr l
	ld bc, WallpaperBlockedTiles
	add hl, bc
	push hl
	ld hl, BitMasks
	add hl, de
	ld a, [hl]
	pop hl
	or a, [hl]
	ld [hl], a
	ret

PlaceDiningRoomWallpaper:
	xor a
	ld [GenerationRoom], a
.chamberLoop
	ld a, [GenerationRoom]
	cp a, 16
	ret z
	call IsBackgroundChamberAnchor
	jp nc, .nextRoom
	ld a, [GenerationRoom]
	ld [BackgroundAnchorRoom], a
	call LoadWallpaperChamberDimensions
	call CountWallpaperCandidates
	and a
	jp z, .nextRoom
	ld [WallpaperCandidateCount], a
	ld b, a
	ld a, [WallpaperTargetCount]
	cp a, b
	jr c, .targetReady
	ld a, b
	ld [WallpaperTargetCount], a
.targetReady
	ld a, b
	call WallpaperSelectionRandomModulo
	ld [GenerationTarget], a
	xor a
	ld [WallpaperSelectionIndex], a
.selectionLoop
	call SetWallpaperTargetOrdinal
	call FindWallpaperCandidate
	ld a, DINING_WALLPAPER_MOTIF_TILE
	ld [hl], a
	ld hl, WallpaperSelectionIndex
	inc [hl]
	ld a, [WallpaperTargetCount]
	ld b, a
	ld a, [WallpaperSelectionIndex]
	cp a, b
	jr c, .selectionLoop
.nextRoom
	ld hl, GenerationRoom
	inc [hl]
	jp .chamberLoop

LoadWallpaperChamberDimensions:
	ld a, 10
	ld [WallpaperWidth], a
	ld a, 8
	ld [WallpaperHeight], a
	ld a, 1
	ld [WallpaperTargetCount], a
	ld a, [BackgroundAnchorRoom]
	ld e, a
	ld d, 0
	ld hl, RoomWidePorts
	add hl, de
	bit 1, [hl]
	jr z, .vertical
	ld a, 20
	ld [WallpaperWidth], a
	jr .domino
.vertical
	bit 3, [hl]
	ret z
	ld a, 16
	ld [WallpaperHeight], a
.domino
	ld a, 2
	ld [WallpaperTargetCount], a
	ret

CountWallpaperCandidates:
	xor a
	ld [WallpaperCandidateCount], a
	call ResetWallpaperCandidatePosition
.loop
	call IsWallpaperCandidate
	jr nc, .advance
	ld hl, WallpaperCandidateCount
	inc [hl]
.advance
	call AdvanceWallpaperCandidatePosition
	jr c, .loop
	ld a, [WallpaperCandidateCount]
	ret

ResetWallpaperCandidatePosition:
	ld a, DINING_WALLPAPER_X_OFFSET
	ld [WallpaperLocalX], a
	ld a, DINING_WALLPAPER_Y_OFFSET
	ld [WallpaperLocalY], a
	ret

AdvanceWallpaperCandidatePosition:
	ld a, [WallpaperLocalX]
	add a, DINING_WALLPAPER_X_STRIDE
	ld [WallpaperLocalX], a
	ld b, a
	ld a, [WallpaperWidth]
	dec a
	cp a, b
	jr c, .nextRow
	jr z, .nextRow
	scf
	ret
.nextRow
	ld a, DINING_WALLPAPER_X_OFFSET
	ld [WallpaperLocalX], a
	ld a, [WallpaperLocalY]
	add a, DINING_WALLPAPER_Y_STRIDE
	ld [WallpaperLocalY], a
	ld b, a
	ld a, [WallpaperHeight]
	dec a
	cp a, b
	jr c, .done
	jr z, .done
	scf
	ret
.done
	and a
	ret

SetWallpaperTargetOrdinal:
	ld a, [GenerationTarget]
	ld b, a
	ld a, [WallpaperSelectionIndex]
	and a
	jr z, .wrap
	ld a, [WallpaperCandidateCount]
	srl a
	add a, b
	ld b, a
.wrap
	ld a, [WallpaperCandidateCount]
	cp a, b
	jr c, .subtract
	jr z, .subtract
	ld a, b
	ld [WallpaperTargetOrdinal], a
	ret
.subtract
	ld a, b
	ld c, a
	ld a, [WallpaperCandidateCount]
	ld b, a
	ld a, c
	sub a, b
	ld [WallpaperTargetOrdinal], a
	ret

FindWallpaperCandidate:
	xor a
	ld [WallpaperCandidateOrdinal], a
	call ResetWallpaperCandidatePosition
.loop
	call IsWallpaperCandidate
	jr nc, .advance
	ld a, [WallpaperCandidateOrdinal]
	ld b, a
	ld a, [WallpaperTargetOrdinal]
	cp a, b
	jp z, GetWallpaperCandidatePointer
	ld hl, WallpaperCandidateOrdinal
	inc [hl]
.advance
	call AdvanceWallpaperCandidatePosition
	jr .loop

IsWallpaperCandidate:
	call SetWallpaperRoomPosition
	call IsWallpaperPointReserved
	jr c, .invalid
	call GetWallpaperCandidatePointer
	ld a, [hl]
	cp a, DINING_WALLPAPER_BACKGROUND_TILE
	jr z, .tileReady
	cp a, DINING_WALLPAPER_MOTIF_TILE
	jr nz, .invalid
.tileReady
	call IsWallpaperCellBlocked
	jr nc, .invalid
	scf
	ret
.invalid
	and a
	ret

SetWallpaperRoomPosition:
	ld a, [BackgroundAnchorRoom]
	ld [WallpaperPlacementRoom], a
	ld a, [WallpaperLocalX]
	ld [WallpaperRoomX], a
	cp a, 10
	jr c, .vertical
	sub a, 10
	ld [WallpaperRoomX], a
	ld hl, WallpaperPlacementRoom
	inc [hl]
.vertical
	ld a, [WallpaperLocalY]
	ld [WallpaperRoomY], a
	cp a, 8
	ret c
	sub a, 8
	ld [WallpaperRoomY], a
	ld hl, WallpaperPlacementRoom
	ld a, [hl]
	add a, 4
	ld [hl], a
	ret

IsWallpaperPointReserved:
	ld a, [WallpaperPlacementRoom]
	ld e, a
	ld d, 0
	ld hl, RoomTraversalClasses
	add hl, de
	ld a, [hl]
	and a
	jp nz, .reserved
	ld a, [WallpaperPlacementRoom]
	ld b, a
	ld a, [CriticalRoute]
	cp a, b
	jr nz, .exit
	ld a, [WallpaperRoomX]
	cp a, 5
	jp c, .reserved
.exit
	ld a, [CriticalRouteLength]
	dec a
	ld e, a
	ld d, 0
	ld hl, CriticalRoute
	add hl, de
	ld a, [hl]
	cp a, b
	jr nz, .ports
	ld a, [WallpaperRoomX]
	cp a, 6
	jr c, .reserved
.ports
	ld e, b
	ld d, 0
	ld hl, RoomPorts
	add hl, de
	ld b, [hl]
	ld hl, RoomWidePorts
	add hl, de
	ld c, [hl]
	bit 0, b
	jr z, .east
	ld a, [WallpaperRoomX]
	cp a, 3
	jr nc, .east
	bit 0, c
	jr nz, .reserved
	ld a, [WallpaperRoomY]
	cp a, 3
	jr nc, .reserved
.east
	bit 1, b
	jr z, .north
	ld a, [WallpaperRoomX]
	cp a, 7
	jr c, .north
	bit 1, c
	jr nz, .reserved
	ld a, [WallpaperRoomY]
	cp a, 3
	jr nc, .reserved
.north
	bit 2, b
	jr z, .south
	ld a, [WallpaperRoomY]
	cp a, 4
	jr nc, .south
	bit 2, c
	jr nz, .reserved
	ld a, [WallpaperRoomX]
	cp a, 3
	jr c, .south
	cp a, 8
	jr c, .reserved
.south
	bit 3, b
	jr z, .clear
	ld a, [WallpaperRoomY]
	cp a, 4
	jr c, .clear
	bit 3, c
	jr nz, .reserved
	ld a, [WallpaperRoomX]
	cp a, 3
	jr c, .clear
	cp a, 8
	jr c, .reserved
.clear
	and a
	ret
.reserved
	scf
	ret

GetWallpaperCandidatePointer:
	ld a, [BackgroundAnchorRoom]
	call GetRoomDestination
	ld a, [WallpaperLocalY]
	ld b, a
	ld de, 40
.rowLoop
	ld a, b
	and a
	jr z, .rowsReady
	add hl, de
	dec b
	jr .rowLoop
.rowsReady
	ld a, [WallpaperLocalX]
	ld e, a
	ld d, 0
	add hl, de
	ret

IsWallpaperCellBlocked:
	ld de, LevelMap
	ld a, l
	sub a, e
	ld l, a
	ld a, h
	sbc a, d
	ld h, a
	ld a, l
	and a, 7
	ld e, a
	ld d, 0
	srl h
	rr l
	srl h
	rr l
	srl h
	rr l
	ld bc, WallpaperBlockedTiles
	add hl, bc
	ld a, [hl]
	ld hl, BitMasks
	add hl, de
	and a, [hl]
	jr nz, .blocked
	scf
	ret
.blocked
	and a
	ret

WallpaperSelectionRandomModulo:
	ld de, DINING_WALLPAPER_SELECTION_SALT
	jp BackgroundSelectionModulo

SECTION "Dining Room Mob Generation", ROMX
PlaceDiningRoomMobs:
	ld hl, MobOccupiedTiles
	ld b, 160
	xor a
.clearOccupied
	ld [hl+], a
	dec b
	jr nz, .clearOccupied
	ld a, [CurrentLevelKind]
	add a, a
	ld e, a
	ld d, 0
	ld hl, DiningRoomMobRosterPointers
	add hl, de
	ld a, [hl+]
	ld b, [hl]
	ld l, a
	ld h, b
.roster
	ld a, [hl+]
	cp a, $ff
	ret z
	ld [MobType], a
	ld a, [hl+]
	push hl
	call PlaceMobType
	pop hl
	jr .roster

PlaceMobType:
	ld [MobTargetCount], a
	xor a
	ld [MobSelectedCount], a
.select
	ld a, [MobSelectedCount]
	ld b, a
	ld a, [MobTargetCount]
	cp a, b
	ret z
	xor a
	ld [GenerationRoom], a
.countRooms
	call IsMobRoomEligible
	jr nc, .storeEmpty
	call CountMobCandidates
	jr .storeCount
.storeEmpty
	xor a
.storeCount
	ld b, a
	ld a, [GenerationRoom]
	ld e, a
	ld d, 0
	ld hl, MobCandidateCounts
	add hl, de
	ld [hl], b
	ld a, [GenerationRoom]
	inc a
	ld [GenerationRoom], a
	cp a, 16
	jr c, .countRooms
	call FindBestMobRoom
	ld a, [MobBestFound]
	and a
	ret z
	ld a, [MobBestRoom]
	ld [GenerationRoom], a
	ld e, a
	ld d, 0
	ld hl, MobCandidateCounts
	add hl, de
	ld a, [hl]
	ld c, a
	ld a, [GenerationRoom]
	call LoadMobPositionSalt
	call MobSelectionMix
	ld a, [MobBestRoom]
	ld e, a
	ld d, 0
	ld hl, MobCandidateCounts
	add hl, de
	ld a, [hl]
	ld c, a
	call MobResultModulo
	ld [MobTargetOrdinal], a
	call FindMobCandidate
	call MarkMobCandidateOccupied
	ld a, [MobType]
	and a
	jr z, .createPancake
	cp a, 1
	jr z, .createBurger
	cp a, 2
	jr z, .createFriedEgg
	call CreateSelectedWeiner
	jr .created
.createFriedEgg
	call CreateSelectedFriedEgg
	jr .created
.createPancake
	call CreateSelectedPancake
	jr .created
.createBurger
	call CreateSelectedBurger
.created
	ld hl, MobSelectedCount
	inc [hl]
	jp .select

FindBestMobRoom:
	xor a
	ld [MobBestFound], a
	ld [GenerationRoom], a
.roomLoop
	ld a, [GenerationRoom]
	ld e, a
	ld d, 0
	ld hl, MobCandidateCounts
	add hl, de
	ld a, [hl]
	and a
	jr z, .nextRoom
	ld a, [GenerationRoom]
	call LoadMobSelectionSalt
	call MobSelectionMix
	ld a, [MobBestFound]
	and a
	jr z, .choose
	ld a, [MobMixResult + 1]
	ld b, a
	ld a, [MobBestScore + 1]
	cp a, b
	jr c, .nextRoom
	jr nz, .choose
	ld a, [MobMixResult]
	ld b, a
	ld a, [MobBestScore]
	cp a, b
	jr c, .nextRoom
	jr z, .nextRoom
.choose
	ld a, [MobMixResult]
	ld [MobBestScore], a
	ld a, [MobMixResult + 1]
	ld [MobBestScore + 1], a
	ld a, [GenerationRoom]
	ld [MobBestRoom], a
	ld a, 1
	ld [MobBestFound], a
.nextRoom
	ld a, [GenerationRoom]
	inc a
	ld [GenerationRoom], a
	cp a, 16
	jr c, .roomLoop
	ret

IsMobRoomEligible:
	ld a, [GenerationRoom]
	ld b, a
	ld a, [CriticalRoute]
	cp a, b
	jr z, .invalid
	ld a, [CriticalRouteLength]
	dec a
	ld e, a
	ld d, 0
	ld hl, CriticalRoute
	add hl, de
	ld a, [hl]
	cp a, b
	jr z, .invalid
	ld e, b
	ld d, 0
	ld hl, RoomTraversalClasses
	add hl, de
	ld a, [hl]
	and a
	jr nz, .invalid
	scf
	ret
.invalid
	and a
	ret

CountMobCandidates:
	xor a
	ld [MobCandidateCount], a
	ld [MobLocalY], a
.row
	xor a
	ld [MobLocalX], a
.column
	call IsMobCandidate
	jr nc, .next
	ld hl, MobCandidateCount
	inc [hl]
.next
	ld hl, MobLocalX
	inc [hl]
	ld a, [hl]
	cp a, 9
	jr c, .column
	ld hl, MobLocalY
	inc [hl]
	ld a, [hl]
	ld b, 7
	ld a, [MobType]
	cp a, 2
	jr c, .rowLimitReady
	dec b
.rowLimitReady
	ld a, [MobLocalY]
	cp a, b
	jr c, .row
	ld a, [MobCandidateCount]
	ret

FindMobCandidate:
	xor a
	ld [MobCandidateOrdinal], a
	ld [MobLocalY], a
.row
	xor a
	ld [MobLocalX], a
.column
	call IsMobCandidate
	jr nc, .next
	ld a, [MobCandidateOrdinal]
	ld b, a
	ld a, [MobTargetOrdinal]
	cp a, b
	ret z
	ld hl, MobCandidateOrdinal
	inc [hl]
.next
	ld hl, MobLocalX
	inc [hl]
	ld a, [hl]
	cp a, 9
	jr c, .column
	ld hl, MobLocalY
	inc [hl]
	ld a, [hl]
	ld b, 7
	ld a, [MobType]
	cp a, 2
	jr c, .rowLimitReady
	dec b
.rowLimitReady
	ld a, [MobLocalY]
	cp a, b
	jr c, .row
	ret

IsMobCandidate:
	call IsMobFootprintReserved
	jp c, .invalid
	ld a, [MobLocalX]
	and a
	jp z, .invalid
	cp a, 8
	jp nc, .invalid
	call GetMobCandidatePointer
	ld a, [MobType]
	ld b, 1
	cp a, 2
	jr c, .bodyRow
	ld b, 2
.bodyRow
	ld c, 2
.bodyCell
	push bc
	push hl
	ld a, [hl]
	ld e, a
	ld d, 0
	ld hl, CollisionTypes
	add hl, de
	ld a, [hl]
	pop hl
	and a
	jr nz, .invalidPop
	push hl
	call IsFurnitureCellOpen
	pop hl
	jr nc, .invalidPop
	push hl
	call IsMobCellOpen
	pop hl
	jr nc, .invalidPop
	pop bc
	inc hl
	dec c
	jr nz, .bodyCell
	ld de, 38
	add hl, de
	dec b
	jr nz, .bodyRow
	call AreMobCandidateSidesClear
	jr nz, .invalid
	ld a, [MobType]
	cp a, 3
	jp z, ResolveWeinerCandidateDirection
	and a
	jp z, ResolvePancakeCandidate
	ld a, [MobType]
	cp a, 2
	jr c, .singleSupportRow
	ld a, [MobLocalY]
	add a, 2
	jr .supportRowReady
.singleSupportRow
	ld a, [MobLocalY]
	inc a
.supportRowReady
	call IsMobRowReserved
	jr c, .invalid
	call GetMobCandidatePointer
	ld de, 40
	ld a, [MobType]
	cp a, 2
	jr c, .supportPointerReady
	ld de, 80
.supportPointerReady
	add hl, de
	ld b, 2
.support
	push hl
	ld a, [hl+]
	ld e, a
	ld d, 0
	ld hl, CollisionTypes
	add hl, de
	ld a, [hl]
	pop hl
	and a
	jr z, .invalid
	inc hl
	dec b
	jr nz, .support
	xor a
	ld [MobCandidateDirection], a
	scf
	ret
.invalidPop
	pop bc
.invalid
	and a
	ret

ResolvePancakeCandidate:
	ld a, [MobLocalY]
	add a, 5
	cp a, 8
	jr nc, .invalid
	ld b, a
	ld a, [GenerationRoom]
	call GetRoomDestination
	ld de, 40
.row
	ld a, b
	and a
	jr z, .rowReady
	add hl, de
	dec b
	jr .row
.rowReady
	inc hl
	ld b, 8
.scan
	ld a, [hl+]
	and a
	jr z, .next
	cp a, 17
	jr c, .valid
.next
	dec b
	jr nz, .scan
.invalid
	and a
	ret
.valid
	xor a
	ld [MobCandidateDirection], a
	scf
	ret

ResolveWeinerCandidateDirection:
	ld a, [MobLocalY]
	add a, 2
	call IsMobRowReserved
	jr c, .above
	call GetMobCandidatePointer
	ld de, 80
	add hl, de
	call IsTwoSolidMobSupport
	jr c, .right
.above
	ld a, [MobLocalY]
	and a
	jr z, .invalid
	dec a
	call IsMobRowReserved
	jr c, .invalid
	call GetMobCandidatePointer
	ld de, -40
	add hl, de
	call IsTwoSolidMobSupport
	jr c, .left
	jr .invalid
.right
	ld a, WEINER_DIRECTION_RIGHT
	jr .valid
.left
	ld a, WEINER_DIRECTION_LEFT
.valid
	ld [MobCandidateDirection], a
	scf
	ret
.invalid
	and a
	ret

IsTwoSolidMobSupport:
	ld b, 2
.loop
	ld a, [hl+]
	and a
	jr z, .invalid
	cp a, 17
	jr nc, .invalid
	dec b
	jr nz, .loop
	scf
	ret
.invalid
	and a
	ret

AreMobCandidateSidesClear:
	call GetMobCandidatePointer
	ld a, [MobType]
	ld b, 1
	cp a, 2
	jr c, .row
	ld b, 2
.row
	dec hl
	call IsEmptyMobTerrainCell
	ret nz
	inc hl
	inc hl
	inc hl
	call IsEmptyMobTerrainCell
	ret nz
	ld de, 38
	add hl, de
	dec b
	jr nz, .row
	xor a
	ret

IsEmptyMobTerrainCell:
	push hl
	ld a, [hl]
	ld e, a
	ld d, 0
	ld hl, CollisionTypes
	add hl, de
	ld a, [hl]
	pop hl
	and a
	ret

GetMobCandidatePointer:
	ld a, [GenerationRoom]
	call GetRoomDestination
	ld a, [MobLocalY]
	ld b, a
	ld de, 40
.row
	ld a, b
	and a
	jr z, .rowsReady
	add hl, de
	dec b
	jr .row
.rowsReady
	ld a, [MobLocalX]
	ld e, a
	ld d, 0
	add hl, de
	ret

IsFurnitureCellOpen:
	ld de, LevelMap
	ld a, l
	sub a, e
	ld l, a
	ld a, h
	sbc a, d
	ld h, a
	ld a, l
	and a, 7
	ld e, a
	ld d, 0
	srl h
	rr l
	srl h
	rr l
	srl h
	rr l
	ld bc, FurnitureOccupiedTiles
	add hl, bc
	ld a, [hl]
	ld hl, BitMasks
	add hl, de
	and a, [hl]
	jr nz, .occupied
	scf
	ret
.occupied
	and a
	ret

IsMobCellOpen:
	ld de, LevelMap
	ld a, l
	sub a, e
	ld l, a
	ld a, h
	sbc a, d
	ld h, a
	ld a, l
	and a, 7
	ld e, a
	ld d, 0
	srl h
	rr l
	srl h
	rr l
	srl h
	rr l
	ld bc, MobOccupiedTiles
	add hl, bc
	ld a, [hl]
	ld hl, BitMasks
	add hl, de
	and a, [hl]
	jr nz, .occupied
	scf
	ret
.occupied
	and a
	ret

MarkMobCandidateOccupied:
	call GetMobCandidatePointer
	ld a, [MobType]
	ld b, 1
	cp a, 2
	jr c, .row
	ld b, 2
.row
	ld c, 2
.cell
	push bc
	push hl
	call MarkMobCellOccupied
	pop hl
	pop bc
	inc hl
	dec c
	jr nz, .cell
	ld de, 38
	add hl, de
	dec b
	jr nz, .row
	ret

MarkMobCellOccupied:
	ld de, LevelMap
	ld a, l
	sub a, e
	ld l, a
	ld a, h
	sbc a, d
	ld h, a
	ld a, l
	and a, 7
	ld e, a
	ld d, 0
	srl h
	rr l
	srl h
	rr l
	srl h
	rr l
	ld bc, MobOccupiedTiles
	add hl, bc
	push hl
	ld hl, BitMasks
	add hl, de
	ld a, [hl]
	pop hl
	or a, [hl]
	ld [hl], a
	ret

IsMobFootprintReserved:
	ld a, [MobLocalY]
	call IsMobRowReserved
	ret c
	ld a, [MobType]
	cp a, 2
	jr c, .singleRow
.secondRow
	ld a, [MobLocalY]
	inc a
	jp IsMobRowReserved
.singleRow
	and a
	ret

IsMobRowReserved:
	ld [MobReservationRow], a
	ld a, [GenerationRoom]
	ld e, a
	ld d, 0
	ld hl, RoomPorts
	add hl, de
	ld b, [hl]
	ld hl, RoomWidePorts
	add hl, de
	ld c, [hl]
	bit 0, b
	jr z, .east
	ld a, [MobLocalX]
	cp a, 3
	jr nc, .east
	bit 0, c
	jr nz, .reserved
	ld a, [MobReservationRow]
	cp a, 3
	jr c, .east
	cp a, 7
	jr c, .reserved
.east
	bit 1, b
	jr z, .north
	ld a, [MobLocalX]
	cp a, 6
	jr c, .north
	bit 1, c
	jr nz, .reserved
	ld a, [MobReservationRow]
	cp a, 3
	jr c, .north
	cp a, 7
	jr c, .reserved
.north
	bit 2, b
	jr z, .south
	ld a, [MobReservationRow]
	cp a, 4
	jr nc, .south
	bit 2, c
	jr nz, .reserved
	ld a, [MobLocalX]
	cp a, 2
	jr c, .south
	cp a, 8
	jr c, .reserved
.south
	bit 3, b
	jr z, .clear
	ld a, [MobReservationRow]
	cp a, 4
	jr c, .clear
	bit 3, c
	jr nz, .reserved
	ld a, [MobLocalX]
	cp a, 2
	jr c, .clear
	cp a, 8
	jr c, .reserved
.clear
	and a
	ret
.reserved
	scf
	ret

CreateSelectedWeiner:
	ld a, [GenerationRoom]
	and a, 3
	ld b, a
	add a, a
	ld c, a
	add a, a
	add a, a
	add a, c
	ld b, a
	ld a, [MobLocalX]
	add a, b
	ld b, a
	ld a, [GenerationRoom]
	srl a
	srl a
	add a, a
	add a, a
	add a, a
	ld c, a
	ld a, [MobLocalY]
	add a, c
	ld c, a
	call CreateWeinerAtTile
	ld a, [WeinerCount]
	dec a
	call GetWeinerRecordPointer
	ld de, 7
	add hl, de
	ld a, [MobCandidateDirection]
	ld [hl], a
	ret

CreateSelectedBurger:
	ld a, [GenerationRoom]
	and a, 3
	ld b, a
	add a, a
	ld c, a
	add a, a
	add a, a
	add a, c
	ld b, a
	ld a, [MobLocalX]
	add a, b
	ld b, a
	ld a, [GenerationRoom]
	srl a
	srl a
	add a, a
	add a, a
	add a, a
	ld c, a
	ld a, [MobLocalY]
	add a, c
	ld c, a
	jp CreateBurgerAtTile

CreateSelectedPancake:
	ld a, [GenerationRoom]
	and a, 3
	ld b, a
	add a, a
	ld c, a
	add a, a
	add a, a
	add a, c
	ld b, a
	ld a, [MobLocalX]
	add a, b
	ld b, a
	ld a, [GenerationRoom]
	srl a
	srl a
	add a, a
	add a, a
	add a, a
	ld c, a
	ld a, [MobLocalY]
	add a, c
	ld c, a
	jp CreatePancakeAtTile

CreateSelectedFriedEgg:
	ld a, [GenerationRoom]
	and a, 3
	ld b, a
	add a, a
	ld c, a
	add a, a
	add a, a
	add a, c
	ld b, a
	ld a, [MobLocalX]
	add a, b
	ld b, a
	ld a, [GenerationRoom]
	srl a
	srl a
	add a, a
	add a, a
	add a, a
	ld c, a
	ld a, [MobLocalY]
	add a, c
	ld c, a
	jp CreateFriedEggAtTile

LoadMobSelectionSalt:
	push af
	ld de, DINING_MOB_SELECTION_SALT
	jr ApplyMobSalt

LoadMobPositionSalt:
	push af
	ld de, DINING_MOB_POSITION_SALT

ApplyMobSalt:
	ld a, [MobType]
	ld b, a
	ld a, e
	xor a, b
	ld e, a
	ld a, d
	xor a, b
	ld d, a
.instance
	ld a, [MobSelectedCount]
	xor a, e
	ld e, a
	pop af
	ret

MobSelectionMix:
	ld [GenerationIndex], a
	ld a, [GenerationRandomState]
	ld [MobSavedRandomState], a
	ld a, [GenerationRandomState + 1]
	ld [MobSavedRandomState + 1], a
	ld a, [SelectedSeed]
	ld b, a
	ld a, [SelectedSeed + 1]
	ld c, a
	ld a, b
	or a, c
	jr nz, .seedReady
	ld b, $e1
	ld c, $ac
.seedReady
	push de
	ld a, [GenerationIndex]
	add a, a
	ld e, a
	ld d, 0
	ld hl, FurnitureRoomMix
	add hl, de
	pop de
	ld a, [hl+]
	xor a, b
	xor a, e
	ld [GenerationRandomState], a
	ld a, [hl]
	xor a, c
	xor a, d
	ld [GenerationRandomState + 1], a
	call NextGenerationRandom
	ld a, [GenerationRandomState]
	ld [MobMixResult], a
	ld a, [GenerationRandomState + 1]
	ld [MobMixResult + 1], a
	ld a, [MobSavedRandomState]
	ld [GenerationRandomState], a
	ld a, [MobSavedRandomState + 1]
	ld [GenerationRandomState + 1], a
	ret

MobResultModulo:
	ld a, [MobMixResult]
	ld e, a
	ld a, [MobMixResult + 1]
	ld d, a
	xor a
	ld b, 16
.loop
	sla e
	rl d
	rla
	cp a, c
	jr c, .next
	sub a, c
.next
	dec b
	jr nz, .loop
	ret

SECTION "Dining Room Treasure Generation", ROMX
PlaceDiningRoomTreasure:
	ld hl, TreasureRoomUsed
	ld b, 16
	xor a
.clearUsed
	ld [hl+], a
	dec b
	jr nz, .clearUsed
	ld [TreasureContentsPresent], a
	call BuildTreasureRoomDistances
	ld de, DINING_TREASURE_COUNT_SALT
	xor a
	call MobSelectionMix
	ld c, DINING_TREASURE_MAXIMUM - DINING_TREASURE_MINIMUM + 1
	call MobResultModulo
	add a, DINING_TREASURE_MINIMUM
	ld [MobTargetCount], a
	xor a
	ld [MobSelectedCount], a
	ld a, 2
	ld [MobType], a
.select
	ld a, [MobSelectedCount]
	ld b, a
	ld a, [MobTargetCount]
	cp a, b
	jp z, .promoteIfNeeded
	xor a
	ld [GenerationRoom], a
.countRooms
	call IsMobRoomEligible
	jr nc, .storeEmpty
	call CountTreasureCandidates
	jr .storeCount
.storeEmpty
	xor a
.storeCount
	ld b, a
	ld a, [GenerationRoom]
	ld e, a
	ld d, 0
	ld hl, MobCandidateCounts
	add hl, de
	ld [hl], b
	ld a, [GenerationRoom]
	inc a
	ld [GenerationRoom], a
	cp a, 16
	jr c, .countRooms
	call FindBestTreasureRoom
	ld a, [MobBestFound]
	and a
	jr z, .promoteIfNeeded
	ld a, [MobBestRoom]
	ld [GenerationRoom], a
	ld e, a
	ld d, 0
	ld hl, MobCandidateCounts
	add hl, de
	ld a, [hl]
	ld [MobCandidateCount], a
	ld de, DINING_TREASURE_POSITION_SALT
	call ApplyTreasureInstanceSalt
	ld a, [GenerationRoom]
	call MobSelectionMix
	ld a, [MobCandidateCount]
	ld c, a
	call MobResultModulo
	ld [MobTargetOrdinal], a
	call FindTreasureCandidate
	call MarkMobCandidateOccupied
	ld de, DINING_TREASURE_CONTENTS_SALT
	call ApplyTreasureInstanceSalt
	ld a, [GenerationRoom]
	call MobSelectionMix
	ld a, [MobMixResult]
	and a, 1
	ld [TreasureEggContents], a
	jr z, .contentsReady
	ld [TreasureContentsPresent], a
.contentsReady
	call CreateSelectedTreasureEgg
	ld a, [GenerationRoom]
	ld e, a
	ld d, 0
	ld hl, TreasureRoomUsed
	add hl, de
	ld [hl], 1
	ld hl, MobSelectedCount
	inc [hl]
	jp .select
.promoteIfNeeded
	ld a, [TreasureContentsPresent]
	and a
	ret nz
	ld a, [TreasureEggCount]
	and a
	ret z
	ld c, a
	ld de, DINING_TREASURE_PROMOTION_SALT
	xor a
	call MobSelectionMix
	call MobResultModulo
	call GetTreasureEggRecordPointer
	ld de, 4
	add hl, de
	ld [hl], 1
	ret

BuildTreasureRoomDistances:
	ld hl, TreasureRoomDistances
	ld b, 16
	ld a, $ff
.clearDistances
	ld [hl+], a
	dec b
	jr nz, .clearDistances
	ld hl, CriticalRoute
	ld a, [CriticalRouteLength]
	ld b, a
.markCritical
	ld a, [hl+]
	ld e, a
	ld d, 0
	push hl
	ld hl, TreasureRoomDistances
	add hl, de
	xor a
	ld [hl], a
	pop hl
	dec b
	jr nz, .markCritical
	ld a, 16
	ld [TreasureRelaxPass], a
.pass
	xor a
	ld [GenerationRoom], a
.room
	call RelaxTreasureRoomDistance
	ld hl, GenerationRoom
	inc [hl]
	ld a, [hl]
	cp a, 16
	jp c, .room
	ld hl, TreasureRelaxPass
	dec [hl]
	jr nz, .pass
	ret

RelaxTreasureRoomDistance:
	ld a, [GenerationRoom]
	ld e, a
	ld d, 0
	ld hl, TreasureRoomDistances
	add hl, de
	ld a, [hl]
	ld [TreasureBestDistance], a
	ld hl, RoomPorts
	add hl, de
	ld a, [hl]
	ld [MobCandidateDirection], a
	bit 0, a
	jr z, .east
	ld a, [GenerationRoom]
	dec a
	call ConsiderTreasureDistance
.east
	ld a, [MobCandidateDirection]
	bit 1, a
	jr z, .north
	ld a, [GenerationRoom]
	inc a
	call ConsiderTreasureDistance
.north
	ld a, [MobCandidateDirection]
	bit 2, a
	jr z, .south
	ld a, [GenerationRoom]
	sub a, 4
	call ConsiderTreasureDistance
.south
	ld a, [MobCandidateDirection]
	bit 3, a
	jr z, .store
	ld a, [GenerationRoom]
	add a, 4
	call ConsiderTreasureDistance
.store
	ld a, [GenerationRoom]
	ld e, a
	ld d, 0
	ld hl, TreasureRoomDistances
	add hl, de
	ld a, [TreasureBestDistance]
	ld [hl], a
	ret

ConsiderTreasureDistance:
	ld e, a
	ld d, 0
	ld hl, TreasureRoomDistances
	add hl, de
	ld a, [hl]
	cp a, $ff
	ret z
	inc a
	ld b, a
	ld a, [TreasureBestDistance]
	cp a, b
	ret c
	ret z
	ld a, b
	ld [TreasureBestDistance], a
	ret

CountTreasureCandidates:
	xor a
	ld [MobCandidateCount], a
	ld [MobLocalY], a
.row
	xor a
	ld [MobLocalX], a
.column
	call IsTreasureCandidate
	jr nc, .next
	ld hl, MobCandidateCount
	inc [hl]
.next
	ld hl, MobLocalX
	inc [hl]
	ld a, [hl]
	cp a, 9
	jr c, .column
	ld hl, MobLocalY
	inc [hl]
	ld a, [hl]
	cp a, 6
	jr c, .row
	ld a, [MobCandidateCount]
	ret

FindTreasureCandidate:
	xor a
	ld [MobCandidateOrdinal], a
	ld [MobLocalY], a
.row
	xor a
	ld [MobLocalX], a
.column
	call IsTreasureCandidate
	jr nc, .next
	ld a, [MobCandidateOrdinal]
	ld b, a
	ld a, [MobTargetOrdinal]
	cp a, b
	ret z
	ld hl, MobCandidateOrdinal
	inc [hl]
.next
	ld hl, MobLocalX
	inc [hl]
	ld a, [hl]
	cp a, 9
	jr c, .column
	ld hl, MobLocalY
	inc [hl]
	ld a, [hl]
	cp a, 6
	jr c, .row
	ret

IsTreasureCandidate:
	call IsMobFootprintReserved
	jr c, .invalid
	ld a, [MobLocalX]
	and a
	jr z, .invalid
	cp a, 8
	jr nc, .invalid
	call GetMobCandidatePointer
	ld b, 2
.bodyRow
	ld c, 2
.bodyCell
	push bc
	push hl
	ld a, [hl]
	ld e, a
	ld d, 0
	ld hl, CollisionTypes
	add hl, de
	ld a, [hl]
	pop hl
	and a
	jr nz, .invalidPop
	push hl
	call IsFurnitureCellOpen
	pop hl
	jr nc, .invalidPop
	push hl
	call IsMobCellOpen
	pop hl
	jr nc, .invalidPop
	pop bc
	inc hl
	dec c
	jr nz, .bodyCell
	ld de, 38
	add hl, de
	dec b
	jr nz, .bodyRow
	call GetMobCandidatePointer
	ld de, 80
	add hl, de
	ld b, 2
.support
	push hl
	ld a, [hl+]
	ld e, a
	ld d, 0
	ld hl, CollisionTypes
	add hl, de
	ld a, [hl]
	pop hl
	and a
	jr z, .invalid
	inc hl
	dec b
	jr nz, .support
	scf
	ret
.invalidPop
	pop bc
.invalid
	and a
	ret

FindBestTreasureRoom:
	xor a
	ld [MobBestFound], a
	ld [GenerationRoom], a
.room
	ld a, [GenerationRoom]
	ld e, a
	ld d, 0
	ld hl, MobCandidateCounts
	add hl, de
	ld a, [hl]
	and a
	jp z, .next
	ld hl, TreasureRoomDistances
	add hl, de
	ld a, [hl]
	ld b, a
	ld a, [MobBestFound]
	and a
	jr z, .chooseWithDistance
	ld a, [TreasureBestDistance]
	cp a, b
	jr c, .chooseWithDistance
	jr nz, .next
	ld hl, TreasureRoomUsed
	add hl, de
	ld a, [hl]
	ld b, a
	ld a, [TreasureBestUsed]
	and a
	jr z, .bestUnused
	ld a, b
	and a
	jr z, .choose
	jr .score
.bestUnused
	ld a, b
	and a
	jr nz, .next
.score
	ld de, DINING_TREASURE_ROOM_SALT
	call ApplyTreasureInstanceSalt
	ld a, [GenerationRoom]
	call MobSelectionMix
	ld a, [MobMixResult + 1]
	ld b, a
	ld a, [MobBestScore + 1]
	cp a, b
	jr c, .next
	jr nz, .choose
	ld a, [MobMixResult]
	ld b, a
	ld a, [MobBestScore]
	cp a, b
	jr c, .next
	jr z, .next
	jr .choose
.chooseWithDistance
	ld a, b
	ld [TreasureBestDistance], a
.choose
	ld a, [GenerationRoom]
	ld e, a
	ld d, 0
	ld hl, TreasureRoomUsed
	add hl, de
	ld a, [hl]
	ld [TreasureBestUsed], a
	ld a, [GenerationRoom]
	ld [MobBestRoom], a
	ld de, DINING_TREASURE_ROOM_SALT
	call ApplyTreasureInstanceSalt
	ld a, [GenerationRoom]
	call MobSelectionMix
	ld a, [MobMixResult]
	ld [MobBestScore], a
	ld a, [MobMixResult + 1]
	ld [MobBestScore + 1], a
	ld a, 1
	ld [MobBestFound], a
.next
	ld hl, GenerationRoom
	inc [hl]
	ld a, [hl]
	cp a, 16
	jp c, .room
	ret

ApplyTreasureInstanceSalt:
	ld a, [MobSelectedCount]
	xor a, e
	ld e, a
	ret

CreateSelectedTreasureEgg:
	ld a, [GenerationRoom]
	and a, 3
	ld b, a
	add a, a
	ld c, a
	add a, a
	add a, a
	add a, c
	ld b, a
	ld a, [MobLocalX]
	add a, b
	ld b, a
	ld a, [GenerationRoom]
	srl a
	srl a
	add a, a
	add a, a
	add a, a
	ld c, a
	ld a, [MobLocalY]
	add a, c
	add a, DINING_TREASURE_HEIGHT
	ld c, a
	jp CreateTreasureEggAtTile

IF DEF(FURNITURE_PARITY_TEST)
VerifyMobParity:
	ld hl, MobParityData
	ld a, [WeinerCount]
	cp a, [hl]
	jp nz, .failed
	inc hl
	ld b, a
	ld de, WeinerRecords
.weiner
	ld a, b
	and a
	jr z, .burgers
	ld a, [de]
	cp a, [hl]
	jp nz, .failed
	inc de
	inc hl
	ld a, [de]
	cp a, [hl]
	jp nz, .failed
	inc de
	inc hl
	ld a, [de]
	cp a, [hl]
	jp nz, .failed
	inc hl
	ld a, WEINER_RECORD_SIZE - 6
.skipWeiner
	inc de
	dec a
	jr nz, .skipWeiner
	ld a, [de]
	cp a, [hl]
	jp nz, .failed
	inc hl
	ld a, WEINER_RECORD_SIZE - 7
.finishWeiner
	inc de
	dec a
	jr nz, .finishWeiner
	dec b
	jr .weiner
.burgers
	ld a, [BurgerCount]
	cp a, [hl]
	jp nz, .failed
	inc hl
	ld b, a
	ld de, BurgerRecords
.burger
	ld a, b
	and a
	jr z, .pancakes
	ld a, [de]
	cp a, [hl]
	jp nz, .failed
	inc de
	inc hl
	ld a, [de]
	cp a, [hl]
	jp nz, .failed
	inc de
	inc hl
	ld a, [de]
	cp a, [hl]
	jp nz, .failed
	inc hl
	ld a, BURGER_RECORD_SIZE - 2
.skipBurger
	inc de
	dec a
	jr nz, .skipBurger
	dec b
	jr .burger
.pancakes
	ld a, [PancakeCount]
	cp a, [hl]
	jp nz, .failed
	inc hl
	ld b, a
	ld de, PancakeRecords
.pancake
	ld a, b
	and a
	jr z, .friedEggs
	ld a, [de]
	cp a, [hl]
	jp nz, .failed
	inc de
	inc hl
	ld a, [de]
	cp a, [hl]
	jp nz, .failed
	inc de
	inc hl
	ld a, [de]
	cp a, [hl]
	jp nz, .failed
	inc hl
	ld a, PANCAKE_RECORD_SIZE - 2
.skipPancake
	inc de
	dec a
	jr nz, .skipPancake
	dec b
	jr .pancake
.friedEggs
	ld a, [FriedEggCount]
	cp a, [hl]
	jp nz, .failed
	inc hl
	ld b, a
	ld de, FriedEggRecords
.friedEgg
	ld a, b
	and a
	ret z
	ld a, [de]
	cp a, [hl]
	jp nz, .failed
	inc de
	inc hl
	ld a, [de]
	cp a, [hl]
	jp nz, .failed
	inc de
	inc hl
	ld a, [de]
	cp a, [hl]
	jp nz, .failed
	inc hl
	ld a, FRIED_EGG_RECORD_SIZE - 2
.skipFriedEgg
	inc de
	dec a
	jr nz, .skipFriedEgg
	dec b
	jr .friedEgg
.failed
	jr .failed

VerifyTreasureParity:
	ld hl, TreasureParityData
	ld a, [TreasureEggCount]
	cp a, [hl]
	jr nz, .failed
	inc hl
	ld b, a
	ld de, TreasureEggRecords
.egg
	ld a, b
	and a
	ret z
	ld a, [de]
	cp a, [hl]
	jr nz, .failed
	inc de
	inc hl
	ld a, [de]
	cp a, [hl]
	jr nz, .failed
	inc de
	inc hl
	ld a, [de]
	cp a, [hl]
	jr nz, .failed
	inc de
	inc hl
	inc de
	ld a, [de]
	cp a, [hl]
	jr nz, .failed
	inc hl
	ld a, TREASURE_EGG_RECORD_SIZE - 4
.nextRecord
	inc de
	dec a
	jr nz, .nextRecord
	dec b
	jr .egg
.failed
	jr .failed
ENDC

SECTION "Level Generation Continued", ROM0

IF DEF(FURNITURE_PARITY_TEST)
VerifyFurnitureParity:
	ld hl, LevelMap
	ld de, FurnitureParityMap
	ld b, 5
.outer
	ld c, 0
.inner
	ld a, [de]
	cp a, [hl]
	jr nz, .failed
	inc de
	inc hl
	dec c
	jr nz, .inner
	dec b
	jr nz, .outer
	ret
.failed
	jr .failed
ENDC

GetMapTilePointer:
	ld hl, LevelMap
	ld de, 40
	ld a, c
	and a
	jr z, .rowsReady
.rowLoop
	add hl, de
	dec c
	jr nz, .rowLoop
.rowsReady
	ld e, b
	ld d, 0
	add hl, de
	ret

BitMasks:
	db 1, 2, 4, 8, 16, 32, 64, 128

RoomDestinationPointers:
	dw LevelMap + 0, LevelMap + 10, LevelMap + 20, LevelMap + 30
	dw LevelMap + 320, LevelMap + 330, LevelMap + 340, LevelMap + 350
	dw LevelMap + 640, LevelMap + 650, LevelMap + 660, LevelMap + 670
	dw LevelMap + 960, LevelMap + 970, LevelMap + 980, LevelMap + 990

RoomTemplatePointers:
	dw RoomTemplateData + 0, RoomTemplateData + 80, RoomTemplateData + 160
	dw RoomTemplateData + 240, RoomTemplateData + 320, RoomTemplateData + 400
	dw RoomTemplateData + 480, RoomTemplateData + 560, RoomTemplateData + 640
	dw RoomTemplateData + 720, RoomTemplateData + 800, RoomTemplateData + 880
	dw RoomTemplateData + 960, RoomTemplateData + 1040, RoomTemplateData + 1120

FurnitureRoomMix:
	dw $9e37, $3c6e, $daa5, $78dc, $1713, $b54a, $5381, $f1b8
	dw $8fef, $2e26, $cc5d, $6a94, $08cb, $a702, $4539, $e370, $81a7

INCLUDE "build/dining_room_background.inc"
INCLUDE "build/dining_room_furniture.inc"
INCLUDE "build/dining_room_wallpaper.inc"
INCLUDE "build/dining_room_mobs.inc"
INCLUDE "build/dining_room_treasure.inc"

IF DEF(FURNITURE_PARITY_TEST)
FurnitureParityMap:
	INCBIN "build/runtime_level_parity.tilemap"
MobParityData:
	INCBIN "build/runtime_mob_parity.bin"
TreasureParityData:
	INCBIN "build/runtime_treasure_parity.bin"
ENDC
