DEF PORT_WEST EQU $01
DEF PORT_EAST EQU $02
DEF PORT_NORTH EQU $04
DEF PORT_SOUTH EQU $08
DEF TRAVERSAL_LEDGE_CATCH EQU 1

SECTION "Level Generation State", WRAM0
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

SECTION "Level Generation", ROM0
GenerateLevel:
IF GENERATED_LEVEL_SEED == 0
	ld a, $e1
	ld [GenerationRandomState], a
	ld a, $ac
	ld [GenerationRandomState + 1], a
ELSE
	ld a, LOW(GENERATED_LEVEL_SEED)
	ld [GenerationRandomState], a
	ld a, HIGH(GENERATED_LEVEL_SEED)
	ld [GenerationRandomState + 1], a
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
	ld b, a
	ld a, [GenerationRoom]
	inc a
	cp a, b
	jr z, .horizontalExit
	ld a, [GenerationRoom]
	dec a
	cp a, b
	jr nz, .nextCandidate
.horizontalExit
	ld a, [GenerationRoom]
	ld e, a
	ld d, 0
	ld hl, RoomPorts
	add hl, de
	bit 3, [hl]
	jr nz, .nextCandidate
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
	jr z, .chooseAnyHorizontal
	ld c, a
	call GenerationRandomModulo
	ld e, a
	ld d, 0
	ld hl, FrontierTo
	add hl, de
	ld a, [hl]
	ld [GenerationRoom], a
	ld e, a
	ld d, 0
	ld hl, RoomTraversalClasses
	add hl, de
	ld [hl], TRAVERSAL_LEDGE_CATCH
	ld hl, RoomPorts
	add hl, de
	ld a, [hl]
	ld b, a
	and a, PORT_WEST | PORT_EAST
	cp a, PORT_WEST | PORT_EAST
	jr nz, .singleDirection
	ld a, [GenerationRandomState + 1]
	and a, 1
	jr z, .wideWest
	jr .wideEast
.singleDirection
	bit 0, b
	jr nz, .wideWest
.wideEast
	ld a, [GenerationRoom]
	ld b, a
	inc a
	ld c, a
	jp SetWideConnection
.wideWest
	ld a, [GenerationRoom]
	ld c, a
	dec a
	ld b, a
	jp SetWideConnection

.chooseAnyHorizontal
	xor a
	ld [FrontierCount], a
	ld [GenerationRoom], a
.horizontalLoop
	ld a, [GenerationRoom]
	cp a, 16
	jr z, .chooseHorizontal
	ld e, a
	ld d, 0
	ld hl, RoomPorts
	add hl, de
	bit 1, [hl]
	jr z, .nextHorizontal
	ld a, [FrontierCount]
	ld e, a
	ld d, 0
	ld hl, FrontierFrom
	add hl, de
	ld a, [GenerationRoom]
	ld [hl], a
	inc a
	ld hl, FrontierTo
	add hl, de
	ld [hl], a
	ld a, [FrontierCount]
	inc a
	ld [FrontierCount], a
.nextHorizontal
	ld a, [GenerationRoom]
	inc a
	ld [GenerationRoom], a
	jr .horizontalLoop
.chooseHorizontal
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

SetWideConnection:
	ld a, b
	ld e, a
	ld d, 0
	ld hl, RoomWidePorts
	add hl, de
	set 1, [hl]
	ld a, c
	ld e, a
	ld d, 0
	ld hl, RoomWidePorts
	add hl, de
	set 0, [hl]
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
	bit 0, [hl]
	ld a, [GenerationRoom]
	call GetRoomDestination
	ld de, 121
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
	jr ClearWideBoundary

ClearWideEast:
	ld a, [GenerationRoom]
	call GetRoomDestination
	ld de, 49
	add hl, de

ClearWideBoundary:
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

VerifyGeneratedLevel:
	ld hl, LevelMap
	ld de, HostSeedLevelMap
	ld b, 5
.outer
	ld c, 0
.inner
	ld a, [de]
	cp a, [hl]
	jr nz, .mismatch
	inc de
	inc hl
	dec c
	jr nz, .inner
	dec b
	jr nz, .outer
	xor a
	ret
.mismatch
	ld a, 1
	and a
	ret

GenerationFailure:
	jr GenerationFailure

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
