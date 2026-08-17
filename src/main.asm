SECTION "Entry Point", ROM0[$100]
	jp Start
	ds $150 - @, 0

SECTION "Main", ROM0[$150]
Start:
.waitVBlank:
	ldh a, [$ff44]
	cp a, 144
	jr c, .waitVBlank

	ld hl, $ff40
	res 7, [hl]

	ld de, TileData
	ld hl, $8000
	ld c, 16

.copyTile
	ld a, [de]
	ld [hl+], a
	inc de
	dec c
	jr nz, .copyTile

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

	ld a, $e4
	ldh [$ff47], a

	ld a, %10010001
	ldh [$ff40], a

.hang
	jr .hang

TileData:
    db $55, $55, $AA, $AA, $55, $55, $AA, $AA, $55, $55, $AA, $AA, $55, $55, $AA, $AA
