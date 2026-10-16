DEF PLAYER_HITBOX_LEFT EQU 6
DEF PLAYER_HITBOX_RIGHT EQU 5
DEF PLAYER_HITBOX_TOP EQU 16
DEF PLAYER_LEDGE_TILE EQU 45
DEF LEDGE_RIGHT EQU 1
DEF LEDGE_LEFT EQU 2
DEF LEVEL_WIDTH_TILES EQU 40
DEF LEVEL_HEIGHT_TILES EQU 32
DEF STREAMED_COLUMN_COUNT EQU 8
DEF EXIT_ANIMATION_FRAMES EQU 32
DEF EXIT_ANIMATION_FINISHED EQU $ff
DEF EXIT_OPEN_TILE_BASE EQU 81
DEF ATTACK_DURATION EQU 19
DEF PLAYER_ATTACK_WINDUP_TILE EQU 49
DEF PLAYER_ATTACK_STRIKE_TILE EQU 53
DEF PLAYER_ATTACK_RECOVERY_TILE EQU 57
DEF PAN_ATTACK_WINDUP_TILE EQU 61
DEF PAN_ATTACK_STRIKE_TILE EQU 65
DEF PAN_ATTACK_RECOVERY_TILE EQU 69
DEF HUD_FULL_HEART_TILE EQU 73
DEF HUD_HALF_HEART_TILE EQU 74
DEF HUD_EMPTY_HEART_TILE EQU 75
DEF HUD_MAX_HEALTH EQU 6
DEF WEINER_FIRST_TILE EQU 76
DEF WEINER_VERTICAL_FIRST_TILE EQU 92
DEF WEINER_CORNER_FIRST_TILE EQU 108
DEF WEINER_FRAME_DURATION EQU 8
DEF WEINER_DIRECTION_RIGHT EQU 0
DEF WEINER_DIRECTION_DOWN EQU 1
DEF WEINER_DIRECTION_LEFT EQU 2
DEF WEINER_DIRECTION_UP EQU 3
DEF WEINER_TURN_CONCAVE EQU 1
DEF WEINER_TURN_CONVEX EQU 2
DEF WEINER_MAX_COUNT EQU 4
DEF WEINER_RECORD_SIZE EQU 11
DEF WEINER_RECORD_ACTIVE EQU 5
DEF WEINER_RECORD_HIT_LATCH EQU 6
DEF PLAYER_DEATH_TILE EQU 172
DEF DEATH_STATE_ACTIVE EQU 1
DEF DEATH_STATE_GAME_OVER EQU 2
DEF DEATH_HOLD_FRAMES EQU 60
DEF DEATH_LAUNCH_VELOCITY EQU -6
DEF DEATH_TERMINAL_VELOCITY EQU 8
DEF GAME_OVER_G_TILE EQU 87
DEF GAME_OVER_M_TILE EQU 88
DEF GAME_OVER_V_TILE EQU 89
IF DEF(ROOM_VARIANT_PLAYTEST)
INCLUDE "build/room_variant_playtest.inc"
ENDC
IF DEF(COMBAT_PLAYTEST)
INCLUDE "build/combat_playtest.inc"
ENDC
DEF TITLE_BLANK_TILE EQU 17
DEF TITLE_A_TILE EQU 116
DEF TITLE_B_TILE EQU 117
DEF TITLE_C_TILE EQU 118
DEF TITLE_E_TILE EQU 119
DEF TITLE_H_TILE EQU 120
DEF TITLE_N_TILE EQU 121
DEF TITLE_O_TILE EQU 122
DEF TITLE_P_TILE EQU 123
DEF TITLE_R_TILE EQU 124
DEF TITLE_S_TILE EQU 125
DEF TITLE_T_TILE EQU 126
DEF TITLE_U_TILE EQU 127

; Persistent game state — uninitialized at power-on, set explicitly in Start
SECTION "Player State", WRAM0
PlayerY: db
PlayerX: dw
CameraX: dw
CameraY: db
StreamedColumns: db
PlayerTileBase: db
AnimTimer: db
FacingFlip: db
PlayerSpriteAttributes: db
PlayerVelY: db
PrevButtons: db
LandTimer: db
CurrentDpad: db
LedgeSide: db
LedgeTop: db
PlayerGrounded: db
FallingPastWorld: db
ExitAnimationTimer: db
AttackTimer: db
AttackPanTileBase: db
CurrentHealth: db
PlayerInvulnerabilityTimer: db
PlayerKnockbackRemaining: db
PlayerKnockbackDirection: db
DeathState: db
DeathScreenY: dw
DeathVelocity: db
DeathHoldTimer: db
WeinerY: db
WeinerX: dw
WeinerAnimTimer: db
WeinerTileBase: db
WeinerActive: db
WeinerHitThisSwing: db
WeinerDirection: db
WeinerTurnKind: db
WeinerTurnTimer: db
WeinerCornerDistance: db
WeinerRecords: ds WEINER_MAX_COUNT * WEINER_RECORD_SIZE
WeinerCount: db
WeinerLoopIndex: db
WeinerOAMPointer: dw
TitleSeedCounter: dw
LevelMap: ds LEVEL_WIDTH_TILES * LEVEL_HEIGHT_TILES

SECTION "Shadow OAM", WRAM0, ALIGN[8]
ShadowOAM: ds 160

SECTION "OAM DMA State", HRAM
hOAMDMA: ds 10

; Boot ROM jumps here after the logo/chime; $104-$14F is reserved header space
SECTION "Entry Point", ROM0[$100]
jp Start
ds $150 - @, 0


SECTION "Main", ROM0[$150]
; --- One-time setup: runs once at boot, falls through into MainLoop ---
Start:
	ld sp, $fffe

; Must be in VBlank before disabling the LCD
.waitBootVBlank:
	ldh a, [$ff44]
	cp a, 144
	jr c, .waitBootVBlank

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

	ld a, $e4
	ldh [$ff47], a
	ld a, $e0
	ldh [$ff48], a

; Camera starts at (0,0).
	xor a
	ld [CameraX], a
	ld [CameraX + 1], a
	ld [CameraY], a
	ld [StreamedColumns], a
	ldh [$ff42], a
	ldh [$ff43], a

	ld hl, ShadowOAM
	xor a
	ld c, 160
.clearShadowOAM
	ld [hl+], a
	dec c
	jr nz, .clearShadowOAM

	ld de, OAMDMARoutine
	ld hl, hOAMDMA
	ld c, OAMDMARoutineEnd - OAMDMARoutine
.copyOAMDMARoutine
	ld a, [de]
	ld [hl+], a
	inc de
	dec c
	jr nz, .copyOAMDMARoutine
	call hOAMDMA

	ld de, ChefFrames
	ld hl, $8010
	ld b, 18
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

	ld de, HUDTiles
	ld hl, $8490
	ld b, 3 * 16
.copyHUDTiles
	ld a, [de]
	ld [hl+], a
	inc de
	dec b
	jr nz, .copyHUDTiles

	ld de, WeinerTiles
	ld hl, $84c0
	ld b, 96
.copyWeinerTilesOuter
	ld c, 16
.copyWeinerTilesInner
	ld a, [de]
	ld [hl+], a
	inc de
	dec c
	jr nz, .copyWeinerTilesInner
	dec b
	jr nz, .copyWeinerTilesOuter
	ld de, DeathTiles
	ld hl, $8ac0
	ld c, 64
.copyDeathTiles
	ld a, [de]
	ld [hl+], a
	inc de
	dec c
	jr nz, .copyDeathTiles

	call LoadTitleScreen
	xor a
	ld [TitleSeedCounter], a
	ld [TitleSeedCounter + 1], a
	call ReadActionButtons
	ld [PrevButtons], a

	ld a, %10000001
	ldh [$ff40], a

IF DEF(FURNITURE_PARITY_TEST)
	jp StartGame
ENDC

TitleLoop:
.waitTitleNotVBlank
	ldh a, [$ff44]
	cp a, 144
	jr nc, .waitTitleNotVBlank
.waitTitleVBlank
	ldh a, [$ff44]
	cp a, 144
	jr c, .waitTitleVBlank

	ld hl, TitleSeedCounter
	inc [hl]
	jr nz, .readTitleButtons
	inc hl
	inc [hl]

.readTitleButtons
	call ReadActionButtons
	ld d, a
	cpl
	ld e, a
	ld a, [PrevButtons]
	and a, e
	ld e, a
	ld a, d
	ld [PrevButtons], a
	bit 3, e
	jr z, TitleLoop

	ldh a, [$ff04]
	ld b, a
	ld a, [TitleSeedCounter]
	xor a, b
	ld [GenerationRandomState], a
	swap b
	ld a, [TitleSeedCounter + 1]
	xor a, b
	ld [GenerationRandomState + 1], a
	ld a, [GenerationRandomState]
	ld b, a
	ld a, [GenerationRandomState + 1]
	or a, b
	jr nz, .seedReady
	ld a, $e1
	ld [GenerationRandomState], a
	ld a, $ac
	ld [GenerationRandomState + 1], a
.seedReady
	call NextGenerationRandom
	ld a, [GenerationRandomState]
	ld [SelectedSeed], a
	ld a, [GenerationRandomState + 1]
	ld [SelectedSeed + 1], a

StartGame:
	ld a, HUD_MAX_HEALTH
	ld [CurrentHealth], a
	call LoadCurrentLevel
	jp MainLoop

LoadCurrentLevel:
	call DisableLCD
	call ClearWeinerRecords
IF DEF(ROOM_VARIANT_PLAYTEST)
	call LoadRoomVariantPlaytest
ELSE
	call GenerateLevel
ENDC
IF DEF(COMBAT_PLAYTEST)
	call LoadCombatPlaytest
ENDC

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

	xor a
	ld [CameraX], a
	ld [CameraX + 1], a
	ld [CameraY], a
	ld [StreamedColumns], a
	ldh [$ff42], a
	ldh [$ff43], a

	ld a, [GeneratedPlayerY]
	ld [PlayerY], a
	ld a, [GeneratedPlayerX]
	ld [PlayerX], a
	ld a, [GeneratedPlayerX + 1]
	ld [PlayerX + 1], a
	ld a, 1
	ld [PlayerTileBase], a
	ld a, 0
	ld [AnimTimer], a
	ld a, 0
	ld [FacingFlip], a
	ld [PlayerSpriteAttributes], a
	ld [ExitAnimationTimer], a
	ld [AttackTimer], a
	ld [AttackPanTileBase], a
	ld [PlayerVelY], a
	ld [LandTimer], a
	ld [CurrentDpad], a
	ld [LedgeSide], a
	ld [LedgeTop], a
	ld [PlayerGrounded], a
	ld [FallingPastWorld], a
	ld [PlayerInvulnerabilityTimer], a
	ld [PlayerKnockbackRemaining], a
	ld [PlayerKnockbackDirection], a
	ld [DeathState], a
	ld [DeathScreenY], a
	ld [DeathScreenY + 1], a
	ld [DeathVelocity], a
	ld [DeathHoldTimer], a
IF DEF(COMBAT_PLAYTEST)
	call InitializeCombatWeiner
ENDC
	call ReadActionButtons
	ld [PrevButtons], a
IF DEF(EXIT_ANIMATION_PLAYTEST)
	call SetPlayerAtExitThreshold
ENDC
	call UpdateHUDSprites
	call UpdateSprites
	call UpdateWeinerSprites
	call hOAMDMA

	ld a, %10000011
	ldh [$ff40], a
	ret

DisableLCD:
	ldh a, [$ff40]
	bit 7, a
	ret z
.waitVBlank
	ldh a, [$ff44]
	cp a, 144
	jr c, .waitVBlank
	ld hl, $ff40
	res 7, [hl]
	ret

IF DEF(COMBAT_PLAYTEST)
LoadCombatPlaytest:
	ld de, CombatPlaytestMap
	ld hl, LevelMap
	ld b, 5
.outer
	ld c, 0
.inner
	ld a, [de]
	ld [hl+], a
	inc de
	dec c
	jr nz, .inner
	dec b
	jr nz, .outer
	ld a, LOW(COMBAT_PLAYTEST_PLAYER_X)
	ld [GeneratedPlayerX], a
	ld a, HIGH(COMBAT_PLAYTEST_PLAYER_X)
	ld [GeneratedPlayerX + 1], a
	ld a, COMBAT_PLAYTEST_PLAYER_Y
	ld [GeneratedPlayerY], a
	ret
ENDC

AdvanceLevelSeed:
	call NextGenerationRandom
	ld a, [GenerationRandomState]
	ld [SelectedSeed], a
	ld a, [GenerationRandomState + 1]
	ld [SelectedSeed + 1], a
	ret

IF DEF(ROOM_VARIANT_PLAYTEST)
LoadRoomVariantPlaytest:
	ld de, RoomVariantPlaytestMap
	ld hl, LevelMap
	ld b, 5
.outer
	ld c, 0
.inner
	ld a, [de]
	ld [hl+], a
	inc de
	dec c
	jr nz, .inner
	dec b
	jr nz, .outer
	ld a, LOW(PLAYTEST_PLAYER_X)
	ld [GeneratedPlayerX], a
	ld a, HIGH(PLAYTEST_PLAYER_X)
	ld [GeneratedPlayerX + 1], a
	ld a, PLAYTEST_PLAYER_Y
	ld [GeneratedPlayerY], a
	ret
ENDC

LoadTitleScreen:
	ld hl, $9800
	ld bc, 32 * 32
.clear
	ld [hl], TITLE_BLANK_TILE
	inc hl
	dec bc
	ld a, b
	or a, c
	jr nz, .clear

	ld de, TitleNameTiles
	ld hl, $9800 + 6 * 32 + 4
	ld b, 11
.copyName
	ld a, [de]
	ld [hl+], a
	inc de
	dec b
	jr nz, .copyName

	ld de, TitlePromptTiles
	ld hl, $9800 + 11 * 32 + 4
	ld b, 11
.copyPrompt
	ld a, [de]
	ld [hl+], a
	inc de
	dec b
	jr nz, .copyPrompt
	ret

LoadGameOverScreen:
	call DisableLCD
	ld de, GameOverFontTiles
	ld hl, $9570
	ld c, 48
.copyFont
	ld a, [de]
	ld [hl+], a
	inc de
	dec c
	jr nz, .copyFont
	ld hl, $9800
	ld bc, 32 * 32
.clearMap
	ld [hl], TITLE_BLANK_TILE
	inc hl
	dec bc
	ld a, b
	or a, c
	jr nz, .clearMap
	ld de, GameOverTiles
	ld hl, $9800 + 8 * 32 + 5
	ld b, 9
.copyName
	ld a, [de]
	ld [hl+], a
	inc de
	dec b
	jr nz, .copyName
	ld de, TitlePromptTiles
	ld hl, $9800 + 11 * 32 + 4
	ld b, 11
.copyPrompt
	ld a, [de]
	ld [hl+], a
	inc de
	dec b
	jr nz, .copyPrompt
	xor a
	ld [CameraX], a
	ld [CameraX + 1], a
	ld [CameraY], a
	ldh [$ff42], a
	ldh [$ff43], a
	ld hl, ShadowOAM
	ld c, 160
.clearSprites
	ld [hl+], a
	dec c
	jr nz, .clearSprites
	call hOAMDMA
	call ReadActionButtons
	ld [PrevButtons], a
	ld a, %10000001
	ldh [$ff40], a
	ret

GameOverLoop:
.waitNotVBlank
	ldh a, [$ff44]
	cp a, 144
	jr nc, .waitNotVBlank
.waitVBlank
	ldh a, [$ff44]
	cp a, 144
	jr c, .waitVBlank
	call ReadActionButtons
	ld d, a
	cpl
	ld e, a
	ld a, [PrevButtons]
	and a, e
	ld e, a
	ld a, d
	ld [PrevButtons], a
	bit 3, e
	jr z, GameOverLoop
	jp ReturnToTitle

ReturnToTitle:
	call DisableLCD
	call LoadTitleScreen
	xor a
	ld [DeathState], a
	ld [TitleSeedCounter], a
	ld [TitleSeedCounter + 1], a
	ldh [$ff42], a
	ldh [$ff43], a
	call ReadActionButtons
	ld [PrevButtons], a
	ld a, %10000001
	ldh [$ff40], a
	jp TitleLoop

UpdateHUDSprites:
	ld a, [CurrentHealth]
	ld d, a
	ld hl, ShadowOAM + $20
	ld e, 120
	ld c, 3
.heart
	ld a, 16
	ld [hl+], a
	ld a, e
	ld [hl+], a
	ld a, d
	and a, a
	jr z, .empty
	cp a, 1
	jr z, .half
	ld a, HUD_FULL_HEART_TILE
	dec d
	dec d
	jr .write
.half
	ld a, HUD_HALF_HEART_TILE
	ld d, 0
	jr .write
.empty
	ld a, HUD_EMPTY_HEART_TILE
.write
	ld [hl+], a
	xor a
	ld [hl+], a
	ld a, e
	add a, 16
	ld e, a
	dec c
	jr nz, .heart
	ret

ReadActionButtons:
	ld a, %00010000
	ldh [$ff00], a
	ldh a, [$ff00]
	ldh a, [$ff00]
	ret

PrepareSpriteBuffer:
	ld a, [DeathState]
	cp a, DEATH_STATE_ACTIVE
	jr nz, .gameplay
	call UpdateHUDSprites
	call UpdateDeathSprite
	call UpdateWeinerSprites
	ret
.gameplay
	call UpdateCameraState
	call UpdateHUDSprites
	call AdvanceWeiners
	call UpdateSprites
	call UpdateWeinerSprites
	ret

UpdateCameraState:
	ld a, [PlayerX + 1]
	and a, a
	jr nz, .subtractX
	ld a, [PlayerX]
	cp a, 80
	jr c, .minimumX

.subtractX
	ld a, [PlayerX]
	sub a, 80
	ld e, a
	ld a, [PlayerX + 1]
	sbc a, 0
	and a, a
	jr nz, .maximumX
	ld a, e
	cp a, 161
	jr c, .storeX

.maximumX
	ld a, 160
	ld [CameraX], a
	xor a
	ld [CameraX + 1], a
	jr .calculateY

.minimumX
	xor a
	ld [CameraX], a
	ld [CameraX + 1], a
	jr .calculateY

.storeX
	ld a, e
	ld [CameraX], a
	xor a
	ld [CameraX + 1], a

.calculateY
	ld a, [PlayerY]
	cp a, 72
	jr c, .minimumY
	sub a, 72
	cp a, 113
	jr c, .storeY
	ld a, 112
	jr .storeY

.minimumY
	xor a
.storeY
	ld [CameraY], a
	ret

; --- Main loop: runs once per frame, forever ---
MainLoop:
	call PrepareSpriteBuffer
; Sync to a fresh VBlank (two phases — see docs/LEARNING.md for why one phase isn't enough)
.waitNotVBlank
	ldh a, [$ff44]
	cp a, 144
	jr nc, .waitNotVBlank

.waitVBlank
	ldh a, [$ff44]
	cp a, 144
	jr c, .waitVBlank

	call hOAMDMA
	call UpdateStreaming
	call DrawOpenExitDoor
	ld a, [CameraX]
	ldh [$ff43], a
	ld a, [CameraY]
	ldh [$ff42], a
	ld a, [DeathState]
	cp a, DEATH_STATE_ACTIVE
	jp z, AdvancePlayerDeath

; Read the D-pad (needed both for animation mode below and movement further down)
	ld a, %00100000
	ldh [$ff00], a
	ldh a, [$ff00]
	ldh a, [$ff00]
	ld b, a
	ld [CurrentDpad], a

	call ReadActionButtons
	ld d, a

	cpl
	ld e, a
	ld a, [PrevButtons]
	and e
	ld e, a

	ld a, d
	ld [PrevButtons], a
	ld hl, PlayerInvulnerabilityTimer
	ld a, [hl]
	and a
	jr z, .invulnerabilityReady
	dec [hl]
.invulnerabilityReady

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
	ld a, [ExitAnimationTimer]
	and a
	jr z, .checkExit
	cp a, EXIT_ANIMATION_FINISHED
	jr z, .loadNextLevel
	call AdvanceExitDescent
	jp MainLoop

.loadNextLevel
	call AdvanceLevelSeed
	call LoadCurrentLevel
	jp MainLoop

.checkExit
	push bc
	push de
	call TryStartExitDescent
	pop de
	pop bc
	jp c, MainLoop

	ld a, [PlayerKnockbackRemaining]
	and a
	jr z, .checkAttackInput
	call ApplyPlayerKnockback
	jp .applyGravity

.checkAttackInput
	ld a, [AttackTimer]
	and a
	jr nz, .attackInputDone
	ld a, b
	bit 3, a
	jr z, .attackInputDone
	ld a, e
	bit 1, a
	jr z, .attackInputDone
	ld a, ATTACK_DURATION
	ld [AttackTimer], a
	push bc
	push de
	call ResetWeinerHitLatches
	pop de
	pop bc
.attackInputDone

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
	ld [FallingPastWorld], a
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

	jr nc, .fallTargetReady
	ld a, 1
	ld [FallingPastWorld], a
	ld b, 255
.fallTargetReady

	ld a, [PlayerY]
	add a, 7
	jr c, .finishFall
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
	jr c, .finishFall
	ld a, c
	push bc
	call TryLedgeCatch
	pop bc
	jr c, .gravityDone
	ld a, c
	add a, 8
	jr c, .finishFall
	ld c, a
	jr .scanLedges

.finishFall
	ld a, [FallingPastWorld]
	and a, a
	jr nz, .worldBottom
	jr .applyFall

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
	ld a, [AttackTimer]
	and a
	jr z, .attackPoseDone
	dec a
	ld [AttackTimer], a
	jr z, .attackPoseDone
	cp a, 13
	jr nc, .attackWindup
	cp a, 7
	jr nc, .attackStrike
	ld a, PLAYER_ATTACK_RECOVERY_TILE
	ld [PlayerTileBase], a
	ld a, PAN_ATTACK_RECOVERY_TILE
	ld [AttackPanTileBase], a
	jr .attackPoseDone
.attackStrike
	ld a, PLAYER_ATTACK_STRIKE_TILE
	ld [PlayerTileBase], a
	ld a, PAN_ATTACK_STRIKE_TILE
	ld [AttackPanTileBase], a
	jr .attackPoseDone
.attackWindup
	ld a, PLAYER_ATTACK_WINDUP_TILE
	ld [PlayerTileBase], a
	ld a, PAN_ATTACK_WINDUP_TILE
	ld [AttackPanTileBase], a
.attackPoseDone
	call TryPanHitWeiners
	call TryWeinerContacts

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

ApplyPlayerKnockback:
	ld hl, PlayerKnockbackRemaining
	dec [hl]
	ld a, [PlayerKnockbackDirection]
	bit 7, a
	jr nz, .left
	call LoadPlayerXRightEdge
	ld a, [PlayerY]
	sub a, PLAYER_HITBOX_TOP
	ld d, a
	call IsWall
	ret z
	call LoadPlayerXRightEdge
	ld a, [PlayerY]
	sub a, 8
	ld d, a
	call IsWall
	ret z
	call LoadPlayerXRightEdge
	ld a, [PlayerY]
	dec a
	ld d, a
	call IsWall
	ret z
	jp IncrementPlayerX
.left
	call LoadPlayerXLeftEdge
	ld a, [PlayerY]
	sub a, PLAYER_HITBOX_TOP
	ld d, a
	call IsWall
	ret z
	call LoadPlayerXLeftEdge
	ld a, [PlayerY]
	sub a, 8
	ld d, a
	call IsWall
	ret z
	call LoadPlayerXLeftEdge
	ld a, [PlayerY]
	dec a
	ld d, a
	call IsWall
	ret z
	jp DecrementPlayerX

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
UpdateDeathSprite:
	ld a, [DeathScreenY + 1]
	and a
	jr z, .visible
	ld hl, ShadowOAM
	ld b, 32
	xor a
.hide
	ld [hl+], a
	dec b
	jr nz, .hide
	ret
.visible
	ld a, [PlayerY]
	push af
	ld a, [CameraY]
	ld b, a
	ld a, [DeathScreenY]
	add a, b
	ld [PlayerY], a
	call UpdateSprites
	pop af
	ld [PlayerY], a
	ret

UpdateSprites:
	ld a, [ExitAnimationTimer]
	cp a, EXIT_ANIMATION_FINISHED
	jr nz, .visible
	ld hl, ShadowOAM
	ld b, 32
	xor a
.hide
	ld [hl+], a
	dec b
	jr nz, .hide
	ret
.visible
	ld a, [PlayerInvulnerabilityTimer]
	and a
	jr z, .opaque
	bit 2, a
	jr nz, .opaque
	ld hl, ShadowOAM
	ld b, 32
	xor a
	jr .hide
.opaque
	ld a, [CameraY]
	ld b, a
	ld a, [CameraX]
	ld c, a
	ld hl, ShadowOAM
	ld a, [FacingFlip]
	and a, a
	jp nz, UpdateSpritesFlipped

; --- Facing right (normal) ---
	ld a, [PlayerY]
	sub a, b
	ld [hl+], a
	ld a, [PlayerX]
	sub a, c
	ld [hl+], a
	ld a, [PlayerTileBase]
	ld [hl+], a
	ld a, [PlayerSpriteAttributes]
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
	ld a, [PlayerSpriteAttributes]
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
	ld a, [PlayerSpriteAttributes]
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
	ld a, [PlayerSpriteAttributes]
	ld [hl+], a

	call UpdateAttackPan
	ret

UpdateAttackPan:
	ld a, [AttackTimer]
	and a
	jr nz, UpdateAttackPanVisible
	jp HideAttackPanSprites

HideAttackPanSprites:
	xor a
	ld [ShadowOAM + $10], a
	ld [ShadowOAM + $14], a
	ld [ShadowOAM + $18], a
	ld [ShadowOAM + $1c], a
	ret
UpdateAttackPanVisible:
	ld a, [CameraY]
	ld b, a
	ld a, [CameraX]
	ld c, a
	ld a, [PlayerY]
	ld d, a
	ld a, [AttackPanTileBase]
	cp a, PAN_ATTACK_WINDUP_TILE
	jr nz, .checkStrikeY
	ld a, d
	sub a, 5
	ld d, a
	jr .yReady
.checkStrikeY
	cp a, PAN_ATTACK_STRIKE_TILE
	jr nz, .yReady
	ld a, d
	sub a, 4
	ld d, a
.yReady
	ld a, [FacingFlip]
	and a
	jr nz, .flippedPan
	ld a, [PlayerX]
	ld e, a
	ld a, [AttackPanTileBase]
	cp a, PAN_ATTACK_WINDUP_TILE
	jr z, .rightXReady
	ld a, e
	add a, 8
	ld e, a
.rightXReady

	ld a, d
	sub a, b
	ld [hl+], a
	ld a, e
	sub a, c
	ld [hl+], a
	ld a, [AttackPanTileBase]
	ld [hl+], a
	xor a
	ld [hl+], a

	ld a, d
	sub a, b
	ld [hl+], a
	ld a, e
	add a, 8
	sub a, c
	ld [hl+], a
	ld a, [AttackPanTileBase]
	inc a
	ld [hl+], a
	xor a
	ld [hl+], a

	ld a, d
	add a, 8
	sub a, b
	ld [hl+], a
	ld a, e
	sub a, c
	ld [hl+], a
	ld a, [AttackPanTileBase]
	add a, 2
	ld [hl+], a
	xor a
	ld [hl+], a

	ld a, d
	add a, 8
	sub a, b
	ld [hl+], a
	ld a, e
	add a, 8
	sub a, c
	ld [hl+], a
	ld a, [AttackPanTileBase]
	add a, 3
	ld [hl+], a
	xor a
	ld [hl+], a
	ret

.flippedPan
	ld a, [PlayerX]
	ld e, a
	ld a, [AttackPanTileBase]
	cp a, PAN_ATTACK_WINDUP_TILE
	jr z, .leftXReady
	ld a, e
	sub a, 8
	ld e, a
.leftXReady
	ld a, d
	sub a, b
	ld [hl+], a
	ld a, e
	sub a, c
	ld [hl+], a
	ld a, [AttackPanTileBase]
	inc a
	ld [hl+], a
	ld a, $20
	ld [hl+], a

	ld a, d
	sub a, b
	ld [hl+], a
	ld a, e
	add a, 8
	sub a, c
	ld [hl+], a
	ld a, [AttackPanTileBase]
	ld [hl+], a
	ld a, $20
	ld [hl+], a

	ld a, d
	add a, 8
	sub a, b
	ld [hl+], a
	ld a, e
	sub a, c
	ld [hl+], a
	ld a, [AttackPanTileBase]
	add a, 3
	ld [hl+], a
	ld a, $20
	ld [hl+], a

	ld a, d
	add a, 8
	sub a, b
	ld [hl+], a
	ld a, e
	add a, 8
	sub a, c
	ld [hl+], a
	ld a, [AttackPanTileBase]
	add a, 2
	ld [hl+], a
	ld a, $20
	ld [hl+], a
	ret

SECTION "WEINER Runtime", ROMX
ClearWeinerRecords:
	ld hl, WeinerRecords
	ld b, WEINER_MAX_COUNT * WEINER_RECORD_SIZE
	xor a
.clear
	ld [hl+], a
	dec b
	jr nz, .clear
	ld [WeinerCount], a
	ret

GetWeinerRecordPointer:
	ld hl, WeinerRecords
	and a
	ret z
	ld de, WEINER_RECORD_SIZE
.advance
	add hl, de
	dec a
	jr nz, .advance
	ret

LoadWeinerRecord:
	call GetWeinerRecordPointer
	ld de, WeinerY
	ld b, WEINER_RECORD_SIZE
.copy
	ld a, [hl+]
	ld [de], a
	inc de
	dec b
	jr nz, .copy
	ret

StoreWeinerRecord:
	call GetWeinerRecordPointer
	ld de, WeinerY
	ld b, WEINER_RECORD_SIZE
.copy
	ld a, [de]
	inc de
	ld [hl+], a
	dec b
	jr nz, .copy
	ret

InitializeWeinerScratch:
	xor a
	ld [WeinerAnimTimer], a
	ld [WeinerHitThisSwing], a
	ld [WeinerDirection], a
	ld [WeinerTurnKind], a
	ld [WeinerTurnTimer], a
	ld [WeinerCornerDistance], a
	ld a, WEINER_FIRST_TILE
	ld [WeinerTileBase], a
	ld a, 1
	ld [WeinerActive], a
	ret

CreateWeinerAtTile:
	ld a, c
	add a, a
	add a, a
	add a, a
	ld [WeinerY], a
	ld h, 0
	ld l, b
	add hl, hl
	add hl, hl
	add hl, hl
	ld a, l
	ld [WeinerX], a
	ld a, h
	ld [WeinerX + 1], a
	call InitializeWeinerScratch
	ld a, [WeinerCount]
	push af
	call StoreWeinerRecord
	pop af
	inc a
	ld [WeinerCount], a
	ret

IF DEF(COMBAT_PLAYTEST)
InitializeCombatWeiner:
	call ClearWeinerRecords
	ld a, COMBAT_PLAYTEST_WEINER_Y
	ld [WeinerY], a
	ld a, LOW(COMBAT_PLAYTEST_WEINER_X)
	ld [WeinerX], a
	ld a, HIGH(COMBAT_PLAYTEST_WEINER_X)
	ld [WeinerX + 1], a
	call InitializeWeinerScratch
	xor a
	call StoreWeinerRecord
	ld a, 1
	ld [WeinerCount], a
	ret
ENDC

AdvanceWeiners:
	xor a
	ld [WeinerLoopIndex], a
.loop
	ld a, [WeinerLoopIndex]
	cp a, WEINER_MAX_COUNT
	ret z
	push af
	call LoadWeinerRecord
	call AdvanceWeinerAnimation
	pop af
	push af
	call StoreWeinerRecord
	pop af
	inc a
	ld [WeinerLoopIndex], a
	jr .loop

ResetWeinerHitLatches:
	ld hl, WeinerRecords + WEINER_RECORD_HIT_LATCH
	ld de, WEINER_RECORD_SIZE
	ld b, WEINER_MAX_COUNT
	xor a
.loop
	ld [hl], a
	add hl, de
	dec b
	jr nz, .loop
	ret

TryPanHitWeiners:
	xor a
	ld [WeinerLoopIndex], a
.loop
	ld a, [WeinerLoopIndex]
	cp a, WEINER_MAX_COUNT
	ret z
	push af
	call LoadWeinerRecord
	call TryPanHitWeiner
	pop af
	push af
	call StoreWeinerRecord
	pop af
	inc a
	ld [WeinerLoopIndex], a
	jr .loop

TryWeinerContacts:
	xor a
	ld [WeinerLoopIndex], a
.loop
	ld a, [WeinerLoopIndex]
	cp a, WEINER_MAX_COUNT
	ret z
	push af
	call LoadWeinerRecord
	call TryWeinerContact
	pop af
	push af
	call StoreWeinerRecord
	pop af
	inc a
	ld [WeinerLoopIndex], a
	jr .loop

UpdateWeinerSprites:
	ld hl, ShadowOAM + $2c
	ld a, l
	ld [WeinerOAMPointer], a
	ld a, h
	ld [WeinerOAMPointer + 1], a
	xor a
	ld [WeinerLoopIndex], a
.loop
	ld a, [WeinerLoopIndex]
	cp a, WEINER_MAX_COUNT
	ret z
	push af
	call LoadWeinerRecord
	call UpdateWeinerSprite
	pop af
	inc a
	ld [WeinerLoopIndex], a
	ld a, [WeinerOAMPointer]
	add a, 16
	ld [WeinerOAMPointer], a
	jr nc, .loop
	ld hl, WeinerOAMPointer + 1
	inc [hl]
	jr .loop

AdvanceWeinerAnimation:
	ld a, [WeinerActive]
	and a
	ret z
	ld a, [WeinerTurnKind]
	and a
	jp nz, AdvanceWeinerTurn
	ld hl, WeinerAnimTimer
	inc [hl]
	ld a, [hl]
	cp a, WEINER_FRAME_DURATION
	ret c
	xor a
	ld [hl], a
	ld a, [WeinerTileBase]
	add a, 4
	ld b, WEINER_FIRST_TILE + 16
	ld c, WEINER_FIRST_TILE
	ld a, [WeinerDirection]
	and a, 1
	jr z, .rangeReady
	ld b, WEINER_VERTICAL_FIRST_TILE + 16
	ld c, WEINER_VERTICAL_FIRST_TILE
.rangeReady
	ld a, [WeinerTileBase]
	add a, 4
	cp a, b
	jr c, .storeTile
	ld a, c
.storeTile
	ld [WeinerTileBase], a
	cp a, c
	jr z, .advance
	ld b, c
	ld c, a
	ld a, b
	add a, 12
	cp a, c
	ret nz
.advance
	call WeinerForwardBlocked
	jr c, StartWeinerConcaveTurn
	call WeinerHasForwardSupport
	jr nc, StartWeinerConvexTurn
	jp MoveWeinerForward

StartWeinerConcaveTurn:
	ld a, WEINER_TURN_CONCAVE
	ld [WeinerTurnKind], a
	xor a
	ld [WeinerTurnTimer], a
	jp SetWeinerCornerTileBase

StartWeinerConvexTurn:
	call MeasureWeinerSupportRun
	ld a, WEINER_TURN_CONVEX
	ld [WeinerTurnKind], a
	xor a
	ld [WeinerTurnTimer], a
	jp SetWeinerCornerTileBase

AdvanceWeinerTurn:
	ld hl, WeinerTurnTimer
	inc [hl]
	ld a, [hl]
	ld b, 8
	ld a, [WeinerTurnKind]
	cp a, WEINER_TURN_CONVEX
	jr nz, .frameTimeReady
	ld b, 4
.frameTimeReady
	ld a, [WeinerTurnTimer]
	cp a, b
	jr nz, .checkFinish
	ld hl, WeinerTileBase
	ld a, [hl]
	add a, 4
	ld [hl], a
.checkFinish
	ld a, [WeinerTurnKind]
	cp a, WEINER_TURN_CONVEX
	ld b, 8
	jr z, .durationReady
	ld b, 16
.durationReady
	ld a, [WeinerTurnTimer]
	cp a, b
	ret c
	ld a, [WeinerTurnKind]
	cp a, WEINER_TURN_CONVEX
	jr nz, .turnLeft
	call SnapWeinerAroundConvexCorner
	ld a, [WeinerDirection]
	inc a
	and a, 3
	jr .storeDirection
.turnLeft
	ld a, [WeinerDirection]
	dec a
	and a, 3
.storeDirection
	ld [WeinerDirection], a
	xor a
	ld [WeinerTurnKind], a
	ld [WeinerTurnTimer], a
	ld [WeinerAnimTimer], a
	jp SetWeinerNormalTileBase

SetWeinerNormalTileBase:
	ld a, [WeinerDirection]
	and a, 1
	ld a, WEINER_FIRST_TILE
	jr z, .store
	ld a, WEINER_VERTICAL_FIRST_TILE
.store
	ld [WeinerTileBase], a
	ret

SetWeinerCornerTileBase:
	ld a, [WeinerTurnKind]
	dec a
	swap a
	add a, a
	ld b, a
	ld a, [WeinerDirection]
	add a, a
	add a, a
	add a, a
	add a, b
	add a, WEINER_CORNER_FIRST_TILE
	ld [WeinerTileBase], a
	ret

MoveWeinerForward:
	ld a, [WeinerDirection]
	and a
	jp z, IncrementWeinerX
	dec a
	jp z, IncrementWeinerY
	dec a
	jp z, DecrementWeinerX
	jp DecrementWeinerY

SnapWeinerAroundConvexCorner:
	ld a, [WeinerCornerDistance]
	ld b, a
	ld a, [WeinerDirection]
	and a
	jr z, .right
	dec a
	jr z, .down
	dec a
	jr z, .left
.up
	call SubtractWeinerDistanceFromY
	jp AddSixteenToWeinerX
.right
	call AddWeinerDistanceToX
	jp AddSixteenToWeinerY
.down
	call AddWeinerDistanceToY
	jp SubtractSixteenFromWeinerX
.left
	call SubtractWeinerDistanceFromX
	jp SubtractSixteenFromWeinerY

AddWeinerDistanceToX:
	ld hl, WeinerX
	ld a, [hl]
	add a, b
	ld [hl+], a
	ret nc
	inc [hl]
	ret

SubtractWeinerDistanceFromX:
	ld hl, WeinerX
	ld a, [hl]
	sub a, b
	ld [hl+], a
	ret nc
	dec [hl]
	ret

AddWeinerDistanceToY:
	ld hl, WeinerY
	ld a, [hl]
	add a, b
	ld [hl], a
	ret

SubtractWeinerDistanceFromY:
	ld hl, WeinerY
	ld a, [hl]
	sub a, b
	ld [hl], a
	ret

AddSixteenToWeinerX:
	ld hl, WeinerX
	ld a, [hl]
	add a, 16
	ld [hl+], a
	ret nc
	inc [hl]
	ret

SubtractSixteenFromWeinerX:
	ld hl, WeinerX
	ld a, [hl]
	sub a, 16
	ld [hl+], a
	ret nc
	dec [hl]
	ret

AddSixteenToWeinerY:
	ld hl, WeinerY
	ld a, [hl]
	add a, 16
	ld [hl], a
	ret

SubtractSixteenFromWeinerY:
	ld hl, WeinerY
	ld a, [hl]
	sub a, 16
	ld [hl], a
	ret

MeasureWeinerSupportRun:
	xor a
	ld [WeinerCornerDistance], a
.probe
	ld a, [WeinerCornerDistance]
	cp a, 16
	ret z
	ld b, a
	ld a, [WeinerDirection]
	and a
	jr z, .right
	dec a
	jr z, .down
	dec a
	jr z, .left
.up
	ld b, 16
	call LoadWeinerXOffset
	ld a, [WeinerCornerDistance]
	ld b, a
	ld a, 15
	sub a, b
	ld b, a
	ld a, [WeinerY]
	add a, b
	jr .test
.right
	call LoadWeinerXOffset
	ld a, [WeinerY]
	add a, 16
	jr .test
.down
	call LoadWeinerXMinusOne
	ld a, [WeinerY]
	add a, b
	jr .test
.left
	ld a, 15
	sub a, b
	ld b, a
	call LoadWeinerXOffset
	ld a, [WeinerY]
	dec a
.test
	ld d, a
	call IsWall
	ret nz
	ld hl, WeinerCornerDistance
	inc [hl]
	jr .probe

IncrementWeinerX:
	ld hl, WeinerX
	inc [hl]
	ret nz
	inc hl
	inc [hl]
	ret

DecrementWeinerX:
	ld hl, WeinerX
	ld a, [hl]
	dec a
	ld [hl+], a
	inc a
	ret nz
	dec [hl]
	ret

IncrementWeinerY:
	ld hl, WeinerY
	inc [hl]
	ret

DecrementWeinerY:
	ld hl, WeinerY
	dec [hl]
	ret

WeinerForwardBlocked:
	ld a, [WeinerDirection]
	and a
	jr z, .right
	dec a
	jr z, .down
	dec a
	jr z, .left
.up
	ld b, 1
	call LoadWeinerXOffset
	ld a, [WeinerY]
	dec a
	ld d, a
	call IsWall
	jr z, .blocked
	ld b, 14
	call LoadWeinerXOffset
	ld a, [WeinerY]
	dec a
	ld d, a
	jr .secondProbe
.right
	ld b, 16
	call LoadWeinerXOffset
	ld a, [WeinerY]
	inc a
	ld d, a
	call IsWall
	jr z, .blocked
	ld b, 16
	call LoadWeinerXOffset
	ld a, [WeinerY]
	add a, 14
	ld d, a
	jr .secondProbe
.down
	ld b, 1
	call LoadWeinerXOffset
	ld a, [WeinerY]
	add a, 16
	ld d, a
	call IsWall
	jr z, .blocked
	ld b, 14
	call LoadWeinerXOffset
	ld a, [WeinerY]
	add a, 16
	ld d, a
	jr .secondProbe
.left
	call LoadWeinerXMinusOne
	ld a, [WeinerY]
	inc a
	ld d, a
	call IsWall
	jr z, .blocked
	call LoadWeinerXMinusOne
	ld a, [WeinerY]
	add a, 14
	ld d, a
.secondProbe
	call IsWall
	jr z, .blocked
	and a
	ret
.blocked
	scf
	ret

WeinerHasForwardSupport:
	ld a, [WeinerDirection]
	and a
	jr z, .right
	dec a
	jr z, .down
	dec a
	jr z, .left
.up
	ld b, 16
	call LoadWeinerXOffset
	ld a, [WeinerY]
	dec a
	jr .probe
.right
	ld b, 16
	call LoadWeinerXOffset
	ld a, [WeinerY]
	add a, 16
	jr .probe
.down
	call LoadWeinerXMinusOne
	ld a, [WeinerY]
	add a, 16
	jr .probe
.left
	call LoadWeinerXMinusOne
	ld a, [WeinerY]
	dec a
.probe
	ld d, a
	call IsWall
	jr z, .supported
	and a
	ret
.supported
	scf
	ret

LoadWeinerXOffset:
	ld a, [WeinerX]
	add a, b
	ld e, a
	ld a, [WeinerX + 1]
	adc a, 0
	ld c, a
	ret

LoadWeinerXMinusOne:
	ld a, [WeinerX]
	sub a, 1
	ld e, a
	ld a, [WeinerX + 1]
	sbc a, 0
	ld c, a
	ret

TryPanHitWeiner:
	ld a, [WeinerActive]
	and a
	ret z
	ld a, [WeinerHitThisSwing]
	and a
	ret nz
	ld a, [AttackTimer]
	and a
	ret z
	ld a, [AttackPanTileBase]
	and a
	ret z
	call CheckWeinerAttackX
	ret nc
	call CheckWeinerAttackY
	ret nc
	ld a, 1
	ld [WeinerHitThisSwing], a
	xor a
	ld [WeinerActive], a
	ret

CheckWeinerAttackX:
	ld a, [AttackPanTileBase]
	cp a, PAN_ATTACK_WINDUP_TILE
	jp z, CheckWeinerCloseX
.forward
	ld a, [FacingFlip]
	and a
	jr nz, .left
	ld a, [WeinerX]
	add a, 8
	ld l, a
	ld a, [WeinerX + 1]
	adc a, 0
	ld h, a
	ld a, [PlayerX]
	ld e, a
	ld a, [PlayerX + 1]
	ld d, a
	ld a, l
	sub a, e
	ld l, a
	ld a, h
	sbc a, d
	ld h, a
	jr .compare
.left
	ld a, [PlayerX]
	ld l, a
	ld a, [PlayerX + 1]
	ld h, a
	ld a, [WeinerX]
	add a, 8
	ld e, a
	ld a, [WeinerX + 1]
	adc a, 0
	ld d, a
	ld a, l
	sub a, e
	ld l, a
	ld a, h
	sbc a, d
	ld h, a
.compare
	bit 7, h
	jr nz, .miss
	ld a, h
	and a
	jr nz, .miss
	ld a, l
	cp a, 21
	ret
.miss
	and a
	ret

CheckWeinerCloseX:
	ld a, [WeinerX]
	add a, 8
	ld l, a
	ld a, [WeinerX + 1]
	adc a, 0
	ld h, a
	ld a, [PlayerX]
	ld e, a
	ld a, [PlayerX + 1]
	ld d, a
	ld a, l
	sub a, e
	ld l, a
	ld a, h
	sbc a, d
	ld h, a
	bit 7, h
	jr z, .compare
	ld a, l
	cpl
	add a, 1
	ld l, a
	ld a, h
	cpl
	adc a, 0
	ld h, a
.compare
	ld a, h
	and a
	jr nz, .miss
	ld a, l
	cp a, 13
	ret
.miss
	and a
	ret

CheckWeinerAttackY:
	ld a, [PlayerY]
	ld b, a
	ld c, a
	dec c
	ld a, [AttackPanTileBase]
	cp a, PAN_ATTACK_WINDUP_TILE
	jr nz, .checkStrike
	ld a, b
	sub a, 24
	ld b, a
	ld a, c
	sub a, 16
	ld c, a
	jr .attackBoundsReady
.checkStrike
	cp a, PAN_ATTACK_STRIKE_TILE
	jr nz, .recovery
	ld a, b
	sub a, 16
	ld b, a
	jr .attackBoundsReady
.recovery
	ld a, b
	sub a, 8
	ld b, a
.attackBoundsReady
	ld a, [WeinerY]
	add a, 14
	cp a, b
	jr c, .miss
	ld a, [WeinerY]
	inc a
	ld d, a
	ld a, c
	cp a, d
	jr c, .miss
	scf
	ret
.miss
	and a
	ret

TryWeinerContact:
	ld a, [WeinerActive]
	and a
	ret z
	ld a, [PlayerInvulnerabilityTimer]
	and a
	ret nz
	call CheckWeinerCloseX
	ret nc
	ld a, [PlayerY]
	dec a
	ld b, a
	ld a, [WeinerY]
	inc a
	ld c, a
	ld a, b
	cp a, c
	jr c, .miss
	ld a, [PlayerY]
	sub a, PLAYER_HITBOX_TOP
	ld b, a
	ld a, [WeinerY]
	add a, 14
	cp a, b
	jr c, .miss
	ld a, [CurrentHealth]
	and a
	ret z
	dec a
	ld [CurrentHealth], a
	and a
	jp z, StartPlayerDeath
	ld a, 60
	ld [PlayerInvulnerabilityTimer], a
	ld a, 4
	ld [PlayerKnockbackRemaining], a
	ld a, [PlayerX]
	ld l, a
	ld a, [PlayerX + 1]
	ld h, a
	ld a, [WeinerX]
	add a, 8
	ld e, a
	ld a, [WeinerX + 1]
	adc a, 0
	ld d, a
	ld a, l
	sub a, e
	ld l, a
	ld a, h
	sbc a, d
	ld h, a
	ld a, h
	or a, l
	jr z, .knockLeft
	bit 7, h
	jr nz, .knockLeft
	ld a, 1
	jr .storeKnockback
.knockLeft
	ld a, -1
.storeKnockback
	ld [PlayerKnockbackDirection], a
	xor a
	ld [AttackTimer], a
	ld [AttackPanTileBase], a
	ld [LedgeSide], a
	ld [AnimTimer], a
	ld a, 41
	ld [PlayerTileBase], a
	ret
.miss
	ret

UpdateWeinerSprite:
	ld a, [WeinerOAMPointer]
	ld l, a
	ld a, [WeinerOAMPointer + 1]
	ld h, a
	ld a, [WeinerActive]
	and a
	jr z, .hidden
	ld a, [WeinerX]
	add a, 16
	ld e, a
	ld a, [WeinerX + 1]
	adc a, 0
	ld d, a
	ld a, [CameraX + 1]
	cp a, d
	jr c, .rightEdge
	jr nz, .hidden
	ld a, [CameraX]
	cp a, e
	jr nc, .hidden
.rightEdge
	ld a, [CameraX]
	add a, 160
	ld e, a
	ld a, [CameraX + 1]
	adc a, 0
	ld d, a
	ld a, [WeinerX + 1]
	cp a, d
	jr c, .vertical
	jr nz, .hidden
	ld a, [WeinerX]
	cp a, e
	jr nc, .hidden
.vertical
	ld a, [WeinerY]
	add a, 16
	jr c, .bottomEdge
	ld e, a
	ld a, [CameraY]
	cp a, e
	jr nc, .hidden
.bottomEdge
	ld a, [CameraY]
	add a, 144
	jr c, .visible
	ld e, a
	ld a, [WeinerY]
	cp a, e
	jr nc, .hidden
	jr .visible
.hidden
	xor a
	ld [hl], a
	ld de, 4
	add hl, de
	ld [hl], a
	add hl, de
	ld [hl], a
	add hl, de
	ld [hl], a
	ret
.visible
	ld a, [CameraY]
	ld b, a
	ld a, [CameraX]
	ld c, a
	xor a
	ld d, a
	ld a, [WeinerTurnKind]
	and a
	jr nz, .orientationReady
	ld a, [WeinerDirection]
	cp a, WEINER_DIRECTION_LEFT
	jr c, .orientationReady
	ld d, $60
.orientationReady
	ld a, [WeinerOAMPointer]
	ld l, a
	ld a, [WeinerOAMPointer + 1]
	ld h, a
	ld a, [WeinerY]
	add a, 16
	sub a, b
	ld [hl+], a
	ld a, [WeinerX]
	add a, 8
	sub a, c
	ld [hl+], a
	ld a, [WeinerTileBase]
	ld e, a
	ld a, d
	and a
	ld a, e
	jr z, .firstTileReady
	add a, 3
.firstTileReady
	ld [hl+], a
	ld a, d
	ld [hl+], a
	ld a, [WeinerY]
	add a, 16
	sub a, b
	ld [hl+], a
	ld a, [WeinerX]
	add a, 16
	sub a, c
	ld [hl+], a
	ld a, [WeinerTileBase]
	ld e, a
	ld a, d
	and a
	ld a, e
	jr z, .secondNormal
	add a, 2
	jr .secondTileReady
.secondNormal
	inc a
.secondTileReady
	ld [hl+], a
	ld a, d
	ld [hl+], a
	ld a, [WeinerY]
	add a, 24
	sub a, b
	ld [hl+], a
	ld a, [WeinerX]
	add a, 8
	sub a, c
	ld [hl+], a
	ld a, [WeinerTileBase]
	ld e, a
	ld a, d
	and a
	ld a, e
	jr z, .thirdNormal
	inc a
	jr .thirdTileReady
.thirdNormal
	add a, 2
.thirdTileReady
	ld [hl+], a
	ld a, d
	ld [hl+], a
	ld a, [WeinerY]
	add a, 24
	sub a, b
	ld [hl+], a
	ld a, [WeinerX]
	add a, 16
	sub a, c
	ld [hl+], a
	ld a, [WeinerTileBase]
	ld e, a
	ld a, d
	and a
	ld a, e
	jr z, .fourthNormal
	jr .fourthTileReady
.fourthNormal
	add a, 3
.fourthTileReady
	ld [hl+], a
	ld a, d
	ld [hl], a
	ret

SECTION "Main Continued", ROM0

StartPlayerDeath:
	ld a, DEATH_STATE_ACTIVE
	ld [DeathState], a
	ld a, [PlayerY]
	ld b, a
	ld a, [CameraY]
	ld c, a
	ld a, b
	sub a, c
	ld [DeathScreenY], a
	xor a
	ld [DeathScreenY + 1], a
	ld [AttackTimer], a
	ld [AttackPanTileBase], a
	ld [LedgeSide], a
	ld [PlayerInvulnerabilityTimer], a
	ld [PlayerKnockbackRemaining], a
	ld [PlayerSpriteAttributes], a
	ld a, PLAYER_DEATH_TILE
	ld [PlayerTileBase], a
	ld a, DEATH_HOLD_FRAMES
	ld [DeathHoldTimer], a
	ld a, DEATH_LAUNCH_VELOCITY
	ld [DeathVelocity], a
	ret

AdvancePlayerDeath:
	ld hl, DeathHoldTimer
	ld a, [hl]
	and a
	jr z, .advance
	dec [hl]
	jp MainLoop
.advance
	ld a, [DeathVelocity]
	ld e, a
	ld d, 0
	bit 7, e
	jr z, .velocityReady
	dec d
.velocityReady
	ld hl, DeathScreenY
	ld a, [hl]
	add a, e
	ld [hl+], a
	ld a, [hl]
	adc a, d
	ld [hl], a
	ld a, [DeathVelocity]
	bit 7, a
	jr nz, .accelerate
	cp a, DEATH_TERMINAL_VELOCITY
	jr nc, .positionReady
.accelerate
	inc a
	ld [DeathVelocity], a
.positionReady
	ld a, [DeathScreenY + 1]
	and a
	jr z, .checkBottom
	bit 7, a
	jp nz, MainLoop
	jr .gameOver
.checkBottom
	ld a, [DeathScreenY]
	cp a, 160
	jp c, MainLoop
.gameOver
	ld a, DEATH_STATE_GAME_OVER
	ld [DeathState], a
	call LoadGameOverScreen
	jp GameOverLoop

; --- Facing left (flipped): swap left/right tiles within each row, set flip bit ---
UpdateSpritesFlipped:
	ld a, [PlayerY]
	sub a, b
	ld [hl+], a
	ld a, [PlayerX]
	sub a, c
	ld [hl+], a
	ld a, [PlayerTileBase]
	add a, 1
	ld [hl+], a
	ld a, [PlayerSpriteAttributes]
	or a, $20
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
	ld a, [PlayerSpriteAttributes]
	or a, $20
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
	ld a, [PlayerSpriteAttributes]
	or a, $20
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
	ld a, [PlayerSpriteAttributes]
	or a, $20
	ld [hl+], a

	call UpdateAttackPan
	ret

TryStartExitDescent:
	ld a, [PlayerGrounded]
	and a
	jr z, .notStarted
	ld a, [CurrentDpad]
	bit 3, a
	jr nz, .notStarted
	call LoadPlayerX
	ld a, [PlayerY]
	sub a, 8
	ld d, a
	call ReadLevelTile
	cp a, 25
	jr c, .notStarted
	cp a, 31
	jr nc, .notStarted
	call SetPlayerAtExitThreshold
	call OpenExitDoor
	ld a, EXIT_ANIMATION_FRAMES
	ld [ExitAnimationTimer], a
	ld a, $80
	ld [PlayerSpriteAttributes], a
	ld a, 9
	ld [PlayerTileBase], a
	xor a
	ld [FacingFlip], a
	ld [PlayerVelY], a
	ld [LandTimer], a
	ld [LedgeSide], a
	ld [AttackTimer], a
	scf
	ret
.notStarted
	and a
	ret

SetPlayerAtExitThreshold:
	ld a, [GeneratedExitX]
	ld l, a
	ld h, 0
	add hl, hl
	add hl, hl
	add hl, hl
	ld de, 8
	add hl, de
	ld a, l
	ld [PlayerX], a
	ld a, h
	ld [PlayerX + 1], a
	ld a, [GeneratedExitY]
	add a, 3
	add a, a
	add a, a
	add a, a
	ld [PlayerY], a
	ret

OpenExitDoor:
	ld a, [GeneratedExitX]
	ld b, a
	ld a, [GeneratedExitY]
	ld c, a
	call GetMapTilePointer
	ld a, EXIT_OPEN_TILE_BASE
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

DrawOpenExitDoor:
	ld a, [ExitAnimationTimer]
	and a
	ret z
	ld a, [GeneratedExitX]
	ld b, a
	ld a, [GeneratedExitY]
	ld c, a
	ld d, EXIT_OPEN_TILE_BASE
	ld e, 3
.rowLoop
	call WriteExitBackgroundTile
	inc b
	inc d
	call WriteExitBackgroundTile
	dec b
	inc c
	inc d
	dec e
	jr nz, .rowLoop
	ret

WriteExitBackgroundTile:
	push de
	ld h, 0
	ld l, c
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	ld de, $9800
	add hl, de
	ld a, b
	and a, 31
	ld e, a
	ld d, 0
	add hl, de
	pop de
	ld [hl], d
	ret

AdvanceExitDescent:
	ld a, [ExitAnimationTimer]
	cp a, EXIT_ANIMATION_FINISHED
	ret z
	and a, 1
	jr nz, .vertical
	call IncrementPlayerX

.vertical
	ld a, [ExitAnimationTimer]
	and a, 3
	jr nz, .animation
	ld a, [ExitAnimationTimer]
	cp a, 4
	jr z, .animation
	ld hl, PlayerY
	inc [hl]
.animation
	ld a, [ExitAnimationTimer]
	and a, 3
	jr nz, .timer
	ld a, [PlayerTileBase]
	add a, 4
	cp a, 33
	jr c, .storeFrame
	ld a, 9
.storeFrame
	ld [PlayerTileBase], a
.timer
	ld hl, ExitAnimationTimer
	dec [hl]
	ret nz
	ld [hl], EXIT_ANIMATION_FINISHED
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
	ld [AttackTimer], a
	ld a, PLAYER_LEDGE_TILE
	ld [PlayerTileBase], a
	scf
	ret

.notCaught
	and a
	ret

INCLUDE "src/level_generation.asm"

TileData:
	INCBIN "build/dining_room.2bpp"

TitleNameTiles:
	db TITLE_B_TILE, TITLE_R_TILE, TITLE_U_TILE, TITLE_N_TILE, TITLE_C_TILE, TITLE_H_TILE
	db TITLE_BLANK_TILE, TITLE_B_TILE, TITLE_R_TILE, TITLE_O_TILE, TITLE_S_TILE

TitlePromptTiles:
	db TITLE_P_TILE, TITLE_R_TILE, TITLE_E_TILE, TITLE_S_TILE, TITLE_S_TILE
	db TITLE_BLANK_TILE, TITLE_S_TILE, TITLE_T_TILE, TITLE_A_TILE, TITLE_R_TILE, TITLE_T_TILE

GameOverTiles:
	db GAME_OVER_G_TILE, TITLE_A_TILE, GAME_OVER_M_TILE, TITLE_E_TILE, TITLE_BLANK_TILE
	db TITLE_O_TILE, GAME_OVER_V_TILE, TITLE_E_TILE, TITLE_R_TILE

GameOverFontTiles:
	db $ff, $3c, $ff, $40, $ff, $40, $ff, $5c, $ff, $44, $ff, $44, $ff, $38, $ff, $00
	db $ff, $44, $ff, $6c, $ff, $54, $ff, $54, $ff, $44, $ff, $44, $ff, $44, $ff, $00
	db $ff, $44, $ff, $44, $ff, $44, $ff, $44, $ff, $44, $ff, $28, $ff, $10, $ff, $00

RoomTemplateData:
	INCBIN "build/room_templates.bin"
RoomTemplateDataEnd:
ASSERT RoomTemplateDataEnd - RoomTemplateData == 15 * 10 * 8

IF DEF(ROOM_VARIANT_PLAYTEST)
RoomVariantPlaytestMap:
	INCBIN "build/room_variant_playtest.tilemap"
RoomVariantPlaytestMapEnd:
ASSERT RoomVariantPlaytestMapEnd - RoomVariantPlaytestMap == LEVEL_WIDTH_TILES * LEVEL_HEIGHT_TILES
ENDC

OAMDMARoutine:
	ld a, HIGH(ShadowOAM)
	ldh [$ff46], a
	ld a, 40
.wait
	dec a
	jr nz, .wait
	ret
OAMDMARoutineEnd:
ASSERT OAMDMARoutineEnd - OAMDMARoutine == 10

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
	INCBIN "build/chef_attack_windup.2bpp"
	INCBIN "build/chef_attack_strike.2bpp"
	INCBIN "build/chef_attack_recovery.2bpp"
	INCBIN "build/pan_attack_windup.2bpp"
	INCBIN "build/pan_attack_strike.2bpp"
	INCBIN "build/pan_attack_recovery.2bpp"

HUDTiles:
	INCBIN "build/hud_hearts.2bpp"

DeathTiles:
	INCBIN "build/chef_death.2bpp"

SECTION "WEINER Assets", ROMX
WeinerTiles:
	INCBIN "build/weiner_motion.2bpp"

IF DEF(COMBAT_PLAYTEST)
CombatPlaytestMap:
	INCBIN "build/combat_playtest.tilemap"
CombatPlaytestMapEnd:
ASSERT CombatPlaytestMapEnd - CombatPlaytestMap == LEVEL_WIDTH_TILES * LEVEL_HEIGHT_TILES
ENDC
