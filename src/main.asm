; Persistent game state — uninitialized at power-on, set explicitly in Start
SECTION "Player State", WRAM0
PlayerY: db
PlayerX: db

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

; Copy the 4 player tiles into VRAM, starting at tile index 1 (tile 0 stays background)
	ld de, PlayerTileData
	ld hl, $8010
	ld c, 64
.copyPlayerTile
	ld a, [de]
	ld [hl+], a
	inc de
	dec c
	jr nz, .copyPlayerTile

; Set the player's starting position, then place all 4 sprites from it
	ld a, 88
	ld [PlayerY], a
	ld a, 88
	ld [PlayerX], a
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

	; handle d-pad inputs
	ld a, %00100000
	ldh [$ff00], a
	ldh a, [$ff00]
	ldh a, [$ff00]
	ld b, a

	bit 0, b
	jr nz, .notRight
	ld a, [PlayerX]
	inc a
	ld [PlayerX], a
.notRight

	bit 1, b
	jr nz, .notLeft
	ld a, [PlayerX]
	dec a
	ld [PlayerX], a
.notLeft

	bit 2, b
	jr nz, .notUp
	ld a, [PlayerY]
	dec a
	ld [PlayerY], a
.notUp

	bit 3, b
	jr nz, .notDown
	ld a, [PlayerY]
	inc a
	ld [PlayerY], a
.notDown

	call UpdateSprites

	jr MainLoop

; Projects PlayerY/PlayerX into the 4 OAM entries (2x2 grid), offsetting by 8px per quadrant
UpdateSprites:
	ld hl, $fe00

	ld a, [PlayerY]
	ld [hl+], a
	ld a, [PlayerX]
	ld [hl+], a
	ld a, 1
	ld [hl+], a
	ld a, 0
	ld [hl+], a

	ld a, [PlayerY]
	ld [hl+], a
	ld a, [PlayerX]
	add a, 8
	ld [hl+], a
	ld a, 2
	ld [hl+], a
	ld a, 0
	ld [hl+], a

	ld a, [PlayerY]
	add a, 8
	ld [hl+], a
	ld a, [PlayerX]
	ld [hl+], a
	ld a, 3
	ld [hl+], a
	ld a, 0
	ld [hl+], a

	ld a, [PlayerY]
	add a, 8
	ld [hl+], a
	ld a, [PlayerX]
	add a, 8
	ld [hl+], a
	ld a, 4
	ld [hl+], a
	ld a, 0
	ld [hl+], a

	ret

TileData:
	INCBIN "build/background.2bpp"

PlayerTileData:
	INCBIN "build/player.2bpp"