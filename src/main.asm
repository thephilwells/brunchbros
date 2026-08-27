; Persistent game state — uninitialized at power-on, set explicitly in Start
SECTION "Player State", WRAM0
PlayerY: db
PlayerX: db
PlayerTileBase: db
AnimTimer: db
FacingFlip: db

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

; Copy the wall tile into VRAM tile 33
	ld de, WallTile
	ld hl, $8210
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

; Place a 4x4 wall block (test obstacle) at tile row 8, column 14
	ld hl, $990e
	ld a, 33
	ld b, 4
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

; BGP and OBP0 both identity — sprite has its own art now, no need to diverge
	ld a, $e0
	ldh [$ff47], a
	ld a, $e0
	ldh [$ff48], a

	; clear all of OAM
	ld hl, $fe00
	ld a, 0
	ld c, 160
.clearOAM
	ld [hl+], a
	dec c
	jr nz, .clearOAM

; Copy all 8 chef animation frames (4 tiles each = 512 bytes) into VRAM, starting at tile index 1
	ld de, ChefFrames
	ld hl, $8010
	ld b, 2
.copyChefOuter
	ld c, 0
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
	and a, %00001111
	cp a, %00001111
	jr z, .doIdle

; --- Walking ---
	ld a, [PlayerTileBase]
	cp a, 9
	jr nc, .walkContinue

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

; Demo: invert the background palette while A is held
	ld a, %00010000
	ldh [$ff00], a
	ldh a, [$ff00]
	ldh a, [$ff00]

	bit 0, a
	jr nz, .aNotPressed
	ld a, $1b
	jr .setPalette
.aNotPressed
	ld a, $e4
.setPalette
	ldh [$ff47], a

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

	bit 2, b
	jr nz, .notUp
	ld a, [PlayerX]
	sub a, 8
	ld e, a
	ld a, [PlayerY]
	sub a, 17
	ld d, a
	call IsWall
	jr z, .notUp

	ld a, [PlayerX]
	add a, 7
	ld e, a
	ld a, [PlayerY]
	sub a, 17
	ld d, a
	call IsWall
	jr z, .notUp

	ld a, [PlayerY]
	dec a
	ld [PlayerY], a
.notUp

	bit 3, b
	jr nz, .notDown
	ld a, [PlayerX]
	sub a, 8
	ld e, a
	ld a, [PlayerY]
	ld d, a
	call IsWall
	jr z, .notDown

	ld a, [PlayerX]
	add a, 7
	ld e, a
	ld a, [PlayerY]
	ld d, a
	call IsWall
	jr z, .notDown

	ld a, [PlayerY]
	inc a
	ld [PlayerY], a
.notDown

; Clamp player position to the screen (16x16 sprite, Y+16/X+8 OAM offset)
	ld a, [PlayerX]
	cp a, 8
	jr nc, .xNotTooLow
	ld a, 8
	ld [PlayerX], a
.xNotTooLow
	ld a, [PlayerX]
	cp a, 153
	jr c, .xNotTooHigh
	ld a, 152
	ld [PlayerX], a
.xNotTooHigh

	ld a, [PlayerY]
	cp a, 16
	jr nc, .yNotTooLow
	ld a, 16
	ld [PlayerY], a
.yNotTooLow
	ld a, [PlayerY]
	cp a, 145
	jr c, .yNotTooHigh
	ld a, 144
	ld [PlayerY], a
.yNotTooHigh

	call UpdateSprites

	jp MainLoop

; Projects PlayerY/PlayerX into the 4 OAM entries (2x2 grid), offsetting by 8px per quadrant
UpdateSprites:
	ld hl, $fe00
	ld a, [FacingFlip]
	and a, a
	jr nz, .flipped

; --- Facing right (normal) ---
	ld a, [PlayerY]
	ld [hl+], a
	ld a, [PlayerX]
	ld [hl+], a
	ld a, [PlayerTileBase]
	ld [hl+], a
	ld a, 0
	ld [hl+], a

	ld a, [PlayerY]
	ld [hl+], a
	ld a, [PlayerX]
	add a, 8
	ld [hl+], a
	ld a, [PlayerTileBase]
	add a, 1
	ld [hl+], a
	ld a, 0
	ld [hl+], a

	ld a, [PlayerY]
	add a, 8
	ld [hl+], a
	ld a, [PlayerX]
	ld [hl+], a
	ld a, [PlayerTileBase]
	add a, 2
	ld [hl+], a
	ld a, 0
	ld [hl+], a

	ld a, [PlayerY]
	add a, 8
	ld [hl+], a
	ld a, [PlayerX]
	add a, 8
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
	ld [hl+], a
	ld a, [PlayerX]
	ld [hl+], a
	ld a, [PlayerTileBase]
	add a, 1
	ld [hl+], a
	ld a, $20
	ld [hl+], a

	ld a, [PlayerY]
	ld [hl+], a
	ld a, [PlayerX]
	add a, 8
	ld [hl+], a
	ld a, [PlayerTileBase]
	ld [hl+], a
	ld a, $20
	ld [hl+], a

	ld a, [PlayerY]
	add a, 8
	ld [hl+], a
	ld a, [PlayerX]
	ld [hl+], a
	ld a, [PlayerTileBase]
	add a, 3
	ld [hl+], a
	ld a, $20
	ld [hl+], a

	ld a, [PlayerY]
	add a, 8
	ld [hl+], a
	ld a, [PlayerX]
	add a, 8
	ld [hl+], a
	ld a, [PlayerTileBase]
	add a, 2
	ld [hl+], a
	ld a, $20
	ld [hl+], a

	ret

; Input: D=Y pixel, E=X pixel. Output: Z set if that tile is the wall (33).
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
	cp a, 33
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

WallTile:
		db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
