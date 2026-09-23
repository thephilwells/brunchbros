DEF PLAYER_HITBOX_LEFT EQU 6
DEF PLAYER_HITBOX_RIGHT EQU 5
DEF PLAYER_HITBOX_TOP EQU 16
DEF PLAYER_LEDGE_TILE EQU 45
DEF LEDGE_RIGHT EQU 1
DEF LEDGE_LEFT EQU 2
DEF LEVEL_WIDTH_TILES EQU 40
DEF LEVEL_HEIGHT_TILES EQU 32
DEF STREAMED_COLUMN_COUNT EQU 8

; Persistent game state — uninitialized at power-on, set explicitly in Start
SECTION "Player State", WRAM0
PlayerY: db
PlayerX: dw
CameraX: dw
StreamedColumns: db
PlayerTileBase: db
AnimTimer: db
FacingFlip: db
PlayerVelY: db
PrevButtons: db
LandTimer: db
CurrentDpad: db
LedgeSide: db
LedgeTop: db
PlayerGrounded: db
LevelMap: ds LEVEL_WIDTH_TILES * LEVEL_HEIGHT_TILES

; Boot ROM jumps here after the logo/chime; $104-$14F is reserved header space
SECTION "Entry Point", ROM0[$100]
jp Start
ds $150 - @, 0


SECTION "Main", ROM0[$150]
; --- One-time setup: runs once at boot, falls through into MainLoop ---
Start:
	ld sp, $fffe

; Must be in VBlank before disabling the LCD
.waitVBlank:
	ldh a, [$ff44]
	cp a, 144
	jr c, .waitVBlank

; LCD off so we can freely write VRAM/OAM below
	ld hl, $ff40
	res 7, [hl]

; BG indices 0-127 use $9000 with LCDC bit 4 clear; chef sprites stay at $8010.
	ld de, TileData
	ld hl, $9000
	ld b, 8
.copyTilesOuter
	ld c, 0
.copyTilesInner
	ld a, [de]
	ld [hl+], a
	inc de
	dec c
	jr nz, .copyTilesInner
	dec b
	jr nz, .copyTilesOuter

	ld de, FixtureMap
	ld hl, LevelMap
	ld b, 5
.copyLevelOuter
	ld c, 0
.copyLevelInner
	ld a, [de]
	ld [hl+], a
	inc de
	dec c
	jr nz, .copyLevelInner
	dec b
	jr nz, .copyLevelOuter

	ld de, LevelMap
	ld hl, $9800
	ld b, LEVEL_HEIGHT_TILES
.copyVisibleRows
	ld c, 32
.copyVisibleColumns
	ld a, [de]
	ld [hl+], a
	inc de
	dec c
	jr nz, .copyVisibleColumns
	ld a, e
	add a, LEVEL_WIDTH_TILES - 32
	ld e, a
	jr nc, .visibleRowReady
	inc d
.visibleRowReady
	dec b
	jr nz, .copyVisibleRows

	ld a, $e4
	ldh [$ff47], a
	ld a, $e0
	ldh [$ff48], a

; Camera starts at (0,0).
	xor a
	ld [CameraX], a
	ld [CameraX + 1], a
	ld [StreamedColumns], a
	ldh [$ff42], a
	ldh [$ff43], a

	; clear all of OAM
	ld hl, $fe00
	ld a, 0
	ld c, 160
.clearOAM
	ld [hl+], a
	dec c
	jr nz, .clearOAM

; Copy all 12 chef animation frames into VRAM, starting at tile index 1.
	ld de, ChefFrames
	ld hl, $8010
	ld b, 12
.copyChefOuter
	ld c, 64
.copyChefInner
	ld a, [de]
	ld [hl+], a
	inc de
	dec c
	jr nz, .copyChefInner
	dec b
	jr nz, .copyChefOuter

; Set the player's starting position and initial animation frame, then place all 4 sprites from it
	ld a, 184
	ld [PlayerY], a
	ld a, 24
	ld [PlayerX], a
	ld a, 1
	ld [PlayerX + 1], a
	ld a, 1
	ld [PlayerTileBase], a
	ld a, 0
	ld [AnimTimer], a
	ld a, 0
	ld [FacingFlip], a
	ld a, 0
	ld [PlayerVelY], a
	ld a, $ff
	ld [PrevButtons], a
	ld a, 0
	ld [LandTimer], a
	ld [LedgeSide], a
	ld [PlayerGrounded], a
	call UpdateSprites

; LCD on: BG + sprites enabled, BG tile data at $9000
	ld a, %10000011
	ldh [$ff40], a

; --- Main loop: runs once per frame, forever ---
MainLoop:
; Sync to a fresh VBlank (two phases — see docs/LEARNING.md for why one phase isn't enough)
.waitNotVBlank
	ldh a, [$ff44]
	cp a, 144
	jr nc, .waitNotVBlank

.waitVBlank
	ldh a, [$ff44]
	cp a, 144
	jr c, .waitVBlank

; Commit streamed background, camera, and sprite state while VRAM/OAM are accessible.
	ld a, [PlayerX + 1]
	and a, a
	jr nz, .scxSubtract
	ld a, [PlayerX]
	cp a, 80
	jr c, .scxMin

.scxSubtract
	ld a, [PlayerX]
	sub a, 80
	ld e, a
	ld a, [PlayerX + 1]
	sbc a, 0
	and a, a
	jr nz, .scxMax
	ld a, e
	cp a, 161
	jr c, .scxStore

.scxMax
	ld a, 160
	ld [CameraX], a
	xor a
	ld [CameraX + 1], a
	jr .scxReady

.scxMin
	xor a
	ld [CameraX], a
	ld [CameraX + 1], a
	jr .scxReady

.scxStore
	ld a, e
	ld [CameraX], a
	xor a
	ld [CameraX + 1], a

.scxReady
	call UpdateStreaming
	ld a, [CameraX]
	ldh [$ff43], a

	ld a, [PlayerY]
	cp a, 72
	jr c, .scyMin

	sub a, 72
	cp a, 113
	jr c, .scyDone
	ld a, 112
	jr .scyDone

.scyMin
	ld a, 0

.scyDone
	ldh [$ff42], a
	call UpdateSprites

; Read the D-pad (needed both for animation mode below and movement further down)
	ld a, %00100000
	ldh [$ff00], a
	ldh a, [$ff00]
	ldh a, [$ff00]
	ld b, a
	ld [CurrentDpad], a

	ld a, %00010000
	ldh [$ff00], a
	ldh a, [$ff00]
	ldh a, [$ff00]
	ld d, a

	cpl
	ld e, a
	ld a, [PrevButtons]
	and e
	ld e, a

	ld a, d
	ld [PrevButtons], a

	ld a, [LedgeSide]
	and a, a
	jr z, .notHanging

	ld a, PLAYER_LEDGE_TILE
	ld [PlayerTileBase], a
	bit 3, b
	jr z, .dropFromLedge
	ld a, e
	bit 0, a
	jr nz, .jumpFromLedge
	jp MainLoop

.dropFromLedge
	ld a, 0
	ld [LedgeSide], a
	ld [PlayerVelY], a
	jp .applyGravity

.jumpFromLedge
	ld a, [LedgeSide]
	ld c, a
	ld a, 0
	ld [LedgeSide], a
	ld a, -8
	ld [PlayerVelY], a
	ld a, c
	cp a, LEDGE_RIGHT
	jr nz, .jumpFromLeftLedge
	call DecrementPlayerX
	ld a, $20
	ld [FacingFlip], a
	jp .applyGravity

.jumpFromLeftLedge
	call IncrementPlayerX
	ld a, 0
	ld [FacingFlip], a
	jp .applyGravity

.notHanging

; Determine walking vs idle from the D-pad reading, advance animation accordingly
	ld a, b
	and a, %00000011
	cp a, %00000011
	jr z, .doIdle

; --- Walking ---
	ld a, [PlayerTileBase]
	cp a, 9
	jr c, .walkStart
	cp a, 30
	jr c, .walkContinue

.walkStart

	ld a, 9
	ld [PlayerTileBase], a
	ld a, 0
	ld [AnimTimer], a
	jr .animDone

.walkContinue
	ld a, [AnimTimer]
	inc a
	ld [AnimTimer], a
	cp a, 8
	jr c, .animDone

	ld a, 0
	ld [AnimTimer], a

	ld a, [PlayerTileBase]
	add a, 4
	cp a, 33
	jr nz, .walkStore
	ld a, 9
.walkStore
	ld [PlayerTileBase], a
	jr .animDone

; --- Idle ---
.doIdle
	ld a, [PlayerTileBase]
	cp a, 9
	jr c, .idleContinue

	ld a, 1
	ld [PlayerTileBase], a
	ld a, 0
	ld [AnimTimer], a
	jr .animDone

.idleContinue
	ld a, [AnimTimer]
	inc a
	ld [AnimTimer], a
	cp a, 16
	jr c, .animDone

	ld a, 0
	ld [AnimTimer], a

	ld a, [PlayerTileBase]
	xor a, 4
	ld [PlayerTileBase], a

.animDone
	ld a, e
	bit 0, a
	jr z, .noJump
	ld a, b
	bit 3, a
	jr nz, .checkJumpSupport
	call TryDropThrough
	jp c, .applyGravity

.checkJumpSupport
	ld a, [PlayerY]
	cp a, 255
	jr z, .grounded

	call LoadPlayerXLeft
	ld a, [PlayerY]
	ld d, a
	call IsSupport
	jr z, .grounded

	call LoadPlayerX
	ld a, [PlayerY]
	ld d, a
	call IsSupport
	jr z, .grounded

	call LoadPlayerXRight
	ld a, [PlayerY]
	ld d, a
	call IsSupport
	jr nz, .noJump

.grounded
	ld a, -8
	ld [PlayerVelY], a
	ld a, 0
	ld [PlayerGrounded], a

.noJump
	ld a, [PlayerGrounded]
	and a, a
	jr z, .checkRight
	bit 3, b
	jp z, .applyGravity

; movement (uses the D-pad reading from the top of the loop)
.checkRight
	bit 0, b
	jr nz, .notRight
	call LoadPlayerXRightEdge
	ld a, [PlayerY]
	sub a, PLAYER_HITBOX_TOP
	ld d, a
	call IsWall
	jr z, .notRight

	call LoadPlayerXRightEdge
	ld a, [PlayerY]
	sub a, 8
	ld d, a
	call IsWall
	jr z, .notRight

	call LoadPlayerXRightEdge
	ld a, [PlayerY]
	sub a, 1
	ld d, a
	call IsWall
	jr z, .notRight

	call IncrementPlayerX
	ld a, 0
	ld [FacingFlip], a
.notRight

	bit 1, b
	jr nz, .notLeft
	call LoadPlayerXLeftEdge
	ld a, [PlayerY]
	sub a, PLAYER_HITBOX_TOP
	ld d, a
	call IsWall
	jr z, .notLeft

	call LoadPlayerXLeftEdge
	ld a, [PlayerY]
	sub a, 8
	ld d, a
	call IsWall
	jr z, .notLeft

	call LoadPlayerXLeftEdge
	ld a, [PlayerY]
	sub a, 1
	ld d, a
	call IsWall
	jr z, .notLeft

	call DecrementPlayerX
	ld a, $20
	ld [FacingFlip], a
.notLeft

; Gravity: accelerate downward velocity, capped while falling
.applyGravity
	ld a, 0
	ld [PlayerGrounded], a
	ld a, [PlayerVelY]
	add a, 1
	bit 7, a
	jr nz, .velDone
	cp a, 17
	jr c, .velDone
	ld a, 16
.velDone
	ld [PlayerVelY], a

; Compute tentative new Y; branch on rising vs falling
	ld b, a
	ld a, [PlayerY]
	add a, b
	ld b, a

	ld a, [PlayerVelY]
	bit 7, a
	jp nz, .checkRising

; Falling: if this overflowed past the world's bottom edge, land there directly
	jp c, .worldBottom

	ld a, [PlayerY]
	add a, 7
	jp c, .applyFall
	and a, $f8
	ld c, a

; Check crossed tile tops so a fast fall cannot skip an 8px platform.
.scanFall
	ld a, c
	cp b
	jr z, .checkFallTop
	jp nc, .checkLedges
.checkFallTop
	ld d, c
	push bc
	call LoadPlayerXLeft
	call IsSupport
	pop bc
	jr z, .landedAtTop

	ld d, c
	push bc
	call LoadPlayerX
	call IsSupport
	pop bc
	jr z, .landedAtTop

	ld d, c
	push bc
	call LoadPlayerXRight
	call IsSupport
	pop bc
	jr z, .landedAtTop

	ld a, c
	add a, 8
	jp c, .checkLedges
	ld c, a
	jr .scanFall

.checkLedges
	ld a, [PlayerY]
	sub a, 8
	add a, 7
	and a, $f8
	ld c, a

.scanLedges
	ld a, b
	sub a, 8
	cp c
	jr c, .applyFall
	ld a, c
	push bc
	call TryLedgeCatch
	pop bc
	jr c, .gravityDone
	ld a, c
	add a, 8
	jr c, .applyFall
	ld c, a
	jr .scanLedges

.landedAtTop
	ld a, c
	ld [PlayerY], a
	jp .landed

.checkRising
; Rising: check the top edge at the tentative Y
	call LoadPlayerXLeft
	ld a, b
	sub a, PLAYER_HITBOX_TOP
	ld d, a
	call IsWall
	jr z, .headBump

	call LoadPlayerX
	ld a, b
	sub a, PLAYER_HITBOX_TOP
	ld d, a
	call IsWall
	jr z, .headBump

	call LoadPlayerXRight
	ld a, b
	sub a, PLAYER_HITBOX_TOP
	ld d, a
	call IsWall
	jr z, .headBump

.applyFall
	ld a, b
	ld [PlayerY], a
	jr .gravityDone

.headBump
	ld a, 0
	ld [PlayerVelY], a
	jr .gravityDone

.worldBottom
	ld a, 255
	ld [PlayerY], a
	jr .landed

.landed
	ld a, [PlayerVelY]
	cp a, 3
	jr c, .noLandFX
	ld a, 8
	ld [LandTimer], a
.noLandFX
	ld a, 0
	ld [PlayerVelY], a
	ld a, 1
	ld [PlayerGrounded], a

.gravityDone

; Clamp player position to the 320×256px logical world.
	ld a, [PlayerX + 1]
	and a, a
	jr nz, .xNotTooLow
	ld a, [PlayerX]
	cp a, 8
	jr nc, .xNotTooLow
	ld a, 8
	ld [PlayerX], a
	xor a
	ld [PlayerX + 1], a
.xNotTooLow
	ld a, [PlayerX + 1]
	cp a, 1
	jr c, .xNotTooHigh
	jr nz, .clampXHigh
	ld a, [PlayerX]
	cp a, 57
	jr c, .xNotTooHigh
.clampXHigh
	ld a, 56
	ld [PlayerX], a
	ld a, 1
	ld [PlayerX + 1], a
.xNotTooHigh

	ld a, [PlayerY]
	cp a, 16
	jr nc, .yNotTooLow
	ld a, 16
	ld [PlayerY], a
	ld a, 0
	ld [PlayerVelY], a
.yNotTooLow

; Jump-pose override: takes priority over idle/walk when airborne or just landed
	ld a, [LandTimer]
	and a, a
	jr z, .checkAirborne

	dec a
	ld [LandTimer], a
	ld a, 41
	ld [PlayerTileBase], a
	jr .poseOverrideDone

.checkAirborne
	ld a, [PlayerGrounded]
	and a, a
	jr z, .checkVelocity
	ld a, [CurrentDpad]
	bit 3, a
	jr nz, .poseOverrideDone
	ld a, 0
	ld [AnimTimer], a
	ld a, 41
	ld [PlayerTileBase], a
	jr .poseOverrideDone

.checkVelocity
	ld a, [PlayerVelY]
	and a, a
	jr z, .poseOverrideDone

	bit 7, a
	jr z, .showAscent

	cp a, 252
	jr nc, .showAscent

	ld a, 33
	ld [PlayerTileBase], a
	jr .poseOverrideDone

.showAscent
	ld a, 37
	ld [PlayerTileBase], a

.poseOverrideDone

	jp MainLoop

IncrementPlayerX:
	ld hl, PlayerX
	inc [hl]
	ret nz
	inc hl
	inc [hl]
	ret

DecrementPlayerX:
	ld hl, PlayerX
	ld a, [hl]
	and a, a
	jr nz, .decrementLow
	inc hl
	dec [hl]
	dec hl
.decrementLow
	dec [hl]
	ret

LoadPlayerX:
	ld a, [PlayerX]
	ld e, a
	ld a, [PlayerX + 1]
	ld c, a
	ret

LoadPlayerXLeft:
	call LoadPlayerX
	ld a, e
	sub a, PLAYER_HITBOX_LEFT
	ld e, a
	ld a, c
	sbc a, 0
	ld c, a
	ret

LoadPlayerXRight:
	call LoadPlayerX
	ld a, e
	add a, PLAYER_HITBOX_RIGHT
	ld e, a
	ld a, c
	adc a, 0
	ld c, a
	ret

LoadPlayerXLeftEdge:
	call LoadPlayerX
	ld a, e
	sub a, PLAYER_HITBOX_LEFT + 1
	ld e, a
	ld a, c
	sbc a, 0
	ld c, a
	ret

LoadPlayerXRightEdge:
	call LoadPlayerX
	ld a, e
	add a, PLAYER_HITBOX_RIGHT + 1
	ld e, a
	ld a, c
	adc a, 0
	ld c, a
	ret

UpdateStreaming:
	ld a, [CameraX]
	srl a
	srl a
	srl a
	cp a, STREAMED_COLUMN_COUNT + 1
	jr c, .desiredReady
	ld a, STREAMED_COLUMN_COUNT
.desiredReady
	ld b, a
	ld a, [StreamedColumns]
	cp a, b
	ret z
	jr c, .streamForward

	dec a
	ld [StreamedColumns], a
	ld c, a
	call StreamColumn
	ret

.streamForward
	ld c, a
	add a, 32
	call StreamColumn
	ld a, [StreamedColumns]
	inc a
	ld [StreamedColumns], a
	ret

StreamColumn:
	ld e, a
	ld d, 0
	ld hl, LevelMap
	add hl, de
	ld d, h
	ld e, l
	ld h, $98
	ld l, c
	ld b, LEVEL_HEIGHT_TILES
.copyRow
	ld a, [de]
	ld [hl], a
	ld a, e
	add a, LEVEL_WIDTH_TILES
	ld e, a
	jr nc, .sourceReady
	inc d
.sourceReady
	ld a, l
	add a, 32
	ld l, a
	jr nc, .destinationReady
	inc h
.destinationReady
	dec b
	jr nz, .copyRow
	ret

; Projects PlayerY/PlayerX (world coords) into the 4 OAM entries, converting to screen coords via SCX/SCY
UpdateSprites:
	ldh a, [$ff42]
	ld b, a
	ldh a, [$ff43]
	ld c, a
	ld hl, $fe00
	ld a, [FacingFlip]
	and a, a
	jr nz, .flipped

; --- Facing right (normal) ---
	ld a, [PlayerY]
	sub a, b
	ld [hl+], a
	ld a, [PlayerX]
	sub a, c
	ld [hl+], a
	ld a, [PlayerTileBase]
	ld [hl+], a
	ld a, 0
	ld [hl+], a

	ld a, [PlayerY]
	sub a, b
	ld [hl+], a
	ld a, [PlayerX]
	add a, 8
	sub a, c
	ld [hl+], a
	ld a, [PlayerTileBase]
	add a, 1
	ld [hl+], a
	ld a, 0
	ld [hl+], a

	ld a, [PlayerY]
	add a, 8
	sub a, b
	ld [hl+], a
	ld a, [PlayerX]
	sub a, c
	ld [hl+], a
	ld a, [PlayerTileBase]
	add a, 2
	ld [hl+], a
	ld a, 0
	ld [hl+], a

	ld a, [PlayerY]
	add a, 8
	sub a, b
	ld [hl+], a
	ld a, [PlayerX]
	add a, 8
	sub a, c
	ld [hl+], a
	ld a, [PlayerTileBase]
	add a, 3
	ld [hl+], a
	ld a, 0
	ld [hl+], a

	ret

; --- Facing left (flipped): swap left/right tiles within each row, set flip bit ---
.flipped
	ld a, [PlayerY]
	sub a, b
	ld [hl+], a
	ld a, [PlayerX]
	sub a, c
	ld [hl+], a
	ld a, [PlayerTileBase]
	add a, 1
	ld [hl+], a
	ld a, $20
	ld [hl+], a

	ld a, [PlayerY]
	sub a, b
	ld [hl+], a
	ld a, [PlayerX]
	add a, 8
	sub a, c
	ld [hl+], a
	ld a, [PlayerTileBase]
	ld [hl+], a
	ld a, $20
	ld [hl+], a

	ld a, [PlayerY]
	add a, 8
	sub a, b
	ld [hl+], a
	ld a, [PlayerX]
	sub a, c
	ld [hl+], a
	ld a, [PlayerTileBase]
	add a, 3
	ld [hl+], a
	ld a, $20
	ld [hl+], a

	ld a, [PlayerY]
	add a, 8
	sub a, b
	ld [hl+], a
	ld a, [PlayerX]
	add a, 8
	sub a, c
	ld [hl+], a
	ld a, [PlayerTileBase]
	add a, 2
	ld [hl+], a
	ld a, $20
	ld [hl+], a

	ret

ReadLevelTile:
	push bc
	ld a, e
	srl a
	srl a
	srl a
	bit 0, c
	jr z, .columnReady
	add a, 32
.columnReady
	push af

	ld a, d
	srl a
	srl a
	srl a
	ld h, 0
	ld l, a
	add hl, hl
	add hl, hl
	add hl, hl
	ld b, h
	ld c, l
	add hl, hl
	add hl, hl
	add hl, bc

	pop af
	ld c, a
	ld b, 0
	add hl, bc
	ld bc, LevelMap
	add hl, bc
	ld a, [hl]
	pop bc
	ret

CollisionAt:
	call ReadLevelTile
	ld e, a
	ld d, 0
	ld hl, CollisionTypes
	add hl, de
	ld a, [hl]
	ret

IsWall:
	call CollisionAt
	cp a, 1
	ret

IsSupport:
	call CollisionAt
	and a, a
	jr z, .empty
	xor a
	ret
.empty
	ld a, 1
	or a
	ret

TryDropThrough:
	ld a, [PlayerGrounded]
	and a, a
	jr z, .notOneWay

	call LoadPlayerXLeft
	ld a, [PlayerY]
	ld d, a
	call CollisionAt
	cp a, 1
	jr z, .notOneWay

	call LoadPlayerX
	ld a, [PlayerY]
	ld d, a
	call CollisionAt
	cp a, 1
	jr z, .notOneWay

	call LoadPlayerXRight
	ld a, [PlayerY]
	ld d, a
	call CollisionAt
	cp a, 1
	jr z, .notOneWay

	call LoadPlayerXLeft
	ld a, [PlayerY]
	ld d, a
	call CollisionAt
	cp a, 2
	jr z, .drop

	call LoadPlayerX
	ld a, [PlayerY]
	ld d, a
	call CollisionAt
	cp a, 2
	jr z, .drop

	call LoadPlayerXRight
	ld a, [PlayerY]
	ld d, a
	call CollisionAt
	cp a, 2
	jr nz, .notOneWay

.drop
; Start below the current tile-top boundary so swept falling collision cannot re-land on it.
	ld a, [PlayerY]
	inc a
	ld [PlayerY], a
	xor a
	ld [PlayerVelY], a
	ld [PlayerGrounded], a
	ld [LandTimer], a
	scf
	ret

.notOneWay
	and a, a
	ret

TryLedgeCatch:
	ld [LedgeTop], a
	ld a, [CurrentDpad]
	bit 3, a
	jp z, .notCaught
	bit 0, a
	jr nz, .tryLeft

	call LoadPlayerXRightEdge
	ld a, [LedgeTop]
	ld d, a
	call IsWall
	jr nz, .tryLeft

	call LoadPlayerXRightEdge
	ld a, [LedgeTop]
	dec a
	ld d, a
	call IsWall
	jr z, .tryLeft

	call LoadPlayerXRight
	ld a, [LedgeTop]
	ld d, a
	call IsWall
	jr z, .tryLeft

	call LoadPlayerXRightEdge
	ld a, e
	and a, $f8
	sub a, PLAYER_HITBOX_RIGHT + 1
	ld [PlayerX], a
	ld a, c
	sbc a, 0
	ld [PlayerX + 1], a
	ld a, 0
	ld [FacingFlip], a
	ld a, LEDGE_RIGHT
	jr .caught

.tryLeft
	ld a, [CurrentDpad]
	bit 1, a
	jr nz, .notCaught

	call LoadPlayerXLeftEdge
	ld a, [LedgeTop]
	ld d, a
	call IsWall
	jr nz, .notCaught

	call LoadPlayerXLeftEdge
	ld a, [LedgeTop]
	dec a
	ld d, a
	call IsWall
	jr z, .notCaught

	call LoadPlayerXLeft
	ld a, [LedgeTop]
	ld d, a
	call IsWall
	jr z, .notCaught

	call LoadPlayerXLeftEdge
	ld a, e
	and a, $f8
	add a, 8 + PLAYER_HITBOX_LEFT
	ld [PlayerX], a
	ld a, c
	adc a, 0
	ld [PlayerX + 1], a
	ld a, $20
	ld [FacingFlip], a
	ld a, LEDGE_LEFT

.caught
	ld [LedgeSide], a
	ld a, [LedgeTop]
	add a, 8
	ld [PlayerY], a
	ld a, 0
	ld [PlayerVelY], a
	ld [PlayerGrounded], a
	ld [LandTimer], a
	ld a, PLAYER_LEDGE_TILE
	ld [PlayerTileBase], a
	scf
	ret

.notCaught
	and a
	ret

TileData:
	INCBIN "build/dining_room.2bpp"

FixtureMap:
	INCBIN "build/room_template_playtest.tilemap"
FixtureMapEnd:
ASSERT FixtureMapEnd - FixtureMap == LEVEL_WIDTH_TILES * LEVEL_HEIGHT_TILES

CollisionTypes:
	INCBIN "build/dining_room_collision.bin"

ChefFrames:
	INCBIN "build/chef_idle0.2bpp"
	INCBIN "build/chef_idle1.2bpp"
	INCBIN "build/chef_walk0.2bpp"
	INCBIN "build/chef_walk1.2bpp"
	INCBIN "build/chef_walk2.2bpp"
	INCBIN "build/chef_walk3.2bpp"
	INCBIN "build/chef_walk4.2bpp"
	INCBIN "build/chef_walk5.2bpp"
	INCBIN "build/chef_jump.2bpp"
	INCBIN "build/chef_ascent.2bpp"
	INCBIN "build/chef_crouch.2bpp"
	INCBIN "build/chef_ledge.2bpp"
