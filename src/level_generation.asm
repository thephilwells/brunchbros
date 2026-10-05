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

SECTION "Level Generation", ROM0
GenerateLevel:
IF DEF(FURNITURE_PARITY_TEST)
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
	call PlaceDiningRoomBackground
	call PlaceDiningRoomFurniture
IF DEF(FURNITURE_PARITY_TEST)
	call VerifyFurnitureParity
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
	dw $8fef, $2e26, $cc5d, $6a94, $08cb, $a702, $4539, $e370

INCLUDE "build/dining_room_background.inc"
INCLUDE "build/dining_room_furniture.inc"

IF DEF(FURNITURE_PARITY_TEST)
FurnitureParityMap:
	INCBIN "build/runtime_level_parity.tilemap"
ENDC
