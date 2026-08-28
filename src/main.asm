; Persistent game state — uninitialized at power-on, set explicitly in Start
SECTION "Player State", WRAM0
PlayerY: db
PlayerX: db
PlayerTileBase: db
AnimTimer: db
FacingFlip: db
PlayerVelY: db
PrevButtons: db
LandTimer: db

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

; Copy the background tile into VRAM tile 0
	ld de, TileData
	ld hl, $8000
	ld c, 16

.copyTile
	ld a, [de]
	ld [hl+], a
	inc de
	dec c
	jr nz, .copyTile

; Copy the wall tile into VRAM tile 45 (moved from 33 — chef now has 11 frames using tiles 1-44)
	ld de, WallTile
	ld hl, $82d0
	ld c, 16
.copyWall
	ld a, [de]
	ld [hl+], a
	inc de
	dec c
	jr nz, .copyWall

; Clear the whole 32x32 background tile map to tile 0
	ld hl, $9800
	ld a, 0
	ld b,4
.clearMapOuter
	ld c, 0
.clearMapInner
	ld [hl+], a
	dec c
	jr nz, .clearMapInner
	dec b
	jr nz, .clearMapOuter

; Place a 4x2 wall block (test obstacle) at tile row 16, column 14 — 16px tall, flush with the ground
	ld hl, $9a0e
	ld a, 45
	ld b, 2
.wallRow
	ld c, 4
.wallCol
	ld [hl+], a
	dec c
	jr nz, .wallCol
	ld de, 28
	add hl, de
	dec b
	jr nz, .wallRow

; Place a second 4x1 wall block (head-bump test), 16px above the first block's top
	ld hl, $99a8
	ld a, 45
	ld b, 1
.wallRow2
	ld c, 4
.wallCol2
	ld [hl+], a
	dec c
	jr nz, .wallCol2
	ld de, 28
	add hl, de
	dec b
	jr nz, .wallRow2
; Place a third 2x2 wall block (camera landmark, far right) at tile row 16, column 26
	ld hl, $9a1a
	ld a, 45
	ld b, 2
.wallRow3
	ld c, 2
.wallCol3
	ld [hl+], a
	dec c
	jr nz, .wallCol3
	ld de, 30
	add hl, de
	dec b
	jr nz, .wallRow3

; BGP and OBP0 both identity — sprite has its own art now, no need to diverge
	ld a, $e0
	ldh [$ff47], a
	ld a, $e0
	ldh [$ff48], a

; Camera scroll: no scrolling yet, start at (0,0)
	ld a, 0
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

; Copy all 11 chef animation frames (4 tiles each = 704 bytes) into VRAM, starting at tile index 1
	ld de, ChefFrames
	ld hl, $8010
	ld b, 11
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
	ld a, 88
	ld [PlayerY], a
	ld a, 88
	ld [PlayerX], a
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
	call UpdateSprites

; LCD on: BG + sprites enabled, tile data at $8000
	ld a, %10010011
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

; Read the D-pad (needed both for animation mode below and movement further down)
	ld a, %00100000
	ldh [$ff00], a
	ldh a, [$ff00]
	ldh a, [$ff00]
	ld b, a

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

; Jump: A button, edge-detected, only while grounded (screen-bottom or standing on a solid tile)
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

	ld a, e
	bit 0, a
	jr z, .noJump

	ld a, [PlayerY]
	cp a, 255
	jr z, .grounded

	ld a, [PlayerX]
	sub a, 8
	ld e, a
	ld a, [PlayerY]
	ld d, a
	call IsWall
	jr z, .grounded

	ld a, [PlayerX]
	add a, 7
	ld e, a
	ld a, [PlayerY]
	ld d, a
	call IsWall
	jr nz, .noJump

.grounded
	ld a, -8
	ld [PlayerVelY], a

.noJump

; movement (uses the D-pad reading from the top of the loop)
	bit 0, b
	jr nz, .notRight
	ld a, [PlayerX]
	add a, 8
	ld e, a
	ld a, [PlayerY]
	sub a, 16
	ld d, a
	call IsWall
	jr z, .notRight

	ld a, [PlayerX]
	add a, 8
	ld e, a
	ld a, [PlayerY]
	sub a, 1
	ld d, a
	call IsWall
	jr z, .notRight

	ld a, [PlayerX]
	inc a
	ld [PlayerX], a
	ld a, 0
	ld [FacingFlip], a
.notRight

	bit 1, b
	jr nz, .notLeft
	ld a, [PlayerX]
	sub a, 9
	ld e, a
	ld a, [PlayerY]
	sub a, 16
	ld d, a
	call IsWall
	jr z, .notLeft

	ld a, [PlayerX]
	sub a, 9
	ld e, a
	ld a, [PlayerY]
	sub a, 1
	ld d, a
	call IsWall
	jr z, .notLeft

	ld a, [PlayerX]
	dec a
	ld [PlayerX], a
	ld a, $20
	ld [FacingFlip], a
.notLeft

; Gravity: accelerate downward velocity, capped while falling
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
	jr nz, .checkRising

; Falling: if this overflowed past the world's bottom edge, land there directly
	jr c, .worldBottom

; Falling: check both bottom-edge points at the tentative Y
	ld a, [PlayerX]
	sub a, 8
	ld e, a
	ld a, b
	sub a, 1
	ld d, a
	call IsWall
	jr z, .landed

	ld a, [PlayerX]
	add a, 7
	ld e, a
	ld a, b
	sub a, 1
	ld d, a
	call IsWall
	jr z, .landed

	jr .applyFall

.checkRising
; Rising: check both top-edge points at the tentative Y
	ld a, [PlayerX]
	sub a, 8
	ld e, a
	ld a, b
	sub a, 16
	ld d, a
	call IsWall
	jr z, .headBump

	ld a, [PlayerX]
	add a, 7
	ld e, a
	ld a, b
	sub a, 16
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

.gravityDone

; Clamp player position: X to the 256px-wide world, Y to the screen (unchanged for now)
	ld a, [PlayerX]
	cp a, 8
	jr nc, .xNotTooLow
	ld a, 8
	ld [PlayerX], a
.xNotTooLow
	ld a, [PlayerX]
	cp a, 249
	jr c, .xNotTooHigh
	ld a, 248
	ld [PlayerX], a
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

; Camera: SCX follows PlayerX, centered, clamped to the world's scrollable range [0,96]
	ld a, [PlayerX]
	cp a, 80
	jr c, .scxMin

	sub a, 80
	cp a, 97
	jr c, .scxDone
	ld a, 96
	jr .scxDone

.scxMin
	ld a, 0

.scxDone
	ldh [$ff43], a

; Camera: SCY follows PlayerY, centered, clamped to the world's scrollable range [0,112]
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

	jp MainLoop

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

; Input: D=Y pixel, E=X pixel. Output: Z set if that tile is the wall (45).
IsWall:
	ld a, e
	srl a
	srl a
	srl a
	ld c, a

	ld a, d
	srl a
	srl a
	srl a
	ld h, 0
	ld l, a
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl

	ld de, $9800
	add hl, de

	ld d, 0
	ld e, c
	add hl, de

	ld a, [hl]
	cp a, 45
	ret

TileData:
	INCBIN "build/background.2bpp"

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

WallTile:
		db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
