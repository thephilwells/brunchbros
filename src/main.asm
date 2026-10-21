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
DEF WEINER_STATE_ACTIVE EQU 1
DEF WEINER_STATE_BURST EQU 2
DEF WEINER_MAX_COUNT EQU 4
DEF WEINER_RECORD_SIZE EQU 11
DEF WEINER_RECORD_ACTIVE EQU 5
DEF WEINER_RECORD_HIT_LATCH EQU 6
DEF ENEMY_BURST_FIRST_TILE EQU 176
DEF ENEMY_BURST_FRAME_DURATION EQU 4
DEF ENEMY_BURST_DURATION EQU 12
DEF BURGER_FIRST_TILE EQU 188
DEF BURGER_IDLE_TILE EQU BURGER_FIRST_TILE
DEF BURGER_WINDUP_TILE EQU BURGER_FIRST_TILE + 2
DEF BURGER_AIRBORNE_TILE EQU BURGER_FIRST_TILE + 4
DEF BURGER_LANDING_TILE EQU BURGER_FIRST_TILE + 6
DEF BURGER_STATE_IDLE EQU 1
DEF BURGER_STATE_WINDUP EQU 2
DEF BURGER_STATE_AIRBORNE EQU 3
DEF BURGER_STATE_LANDING EQU 4
DEF BURGER_STATE_BURST EQU 5
DEF BURGER_MAX_COUNT EQU 4
DEF BURGER_RECORD_SIZE EQU 13
DEF BURGER_RECORD_HIT_LATCH EQU 9
DEF BURGER_IDLE_DURATION EQU 120
DEF BURGER_IDLE_BEAT_DURATION EQU 8
DEF BURGER_WINDUP_DURATION EQU 20
DEF BURGER_LANDING_DURATION EQU 10
DEF BURGER_LAUNCH_VELOCITY EQU -8
DEF BURGER_TERMINAL_VELOCITY EQU 8
DEF BURGER_HIT_KNOCKBACK_DISTANCE EQU 8
DEF PANCAKE_FIRST_TILE EQU 196
DEF PANCAKE_MAX_COUNT EQU 2
DEF PANCAKE_RECORD_SIZE EQU 15
DEF PANCAKE_RECORD_HIT_LATCH EQU 10
DEF PANCAKE_FRAME_DURATION EQU 8
DEF PANCAKE_STATE_ACTIVE EQU 1
DEF PANCAKE_STATE_BURST EQU 2
DEF PANCAKE_OSCILLATION_SPAN EQU 24
DEF PANCAKE_TARGET_RADIUS EQU PANCAKE_OSCILLATION_SPAN / 2
DEF PANCAKE_WALL_RETREAT_STEPS EQU PANCAKE_OSCILLATION_SPAN
DEF PANCAKE_HIT_KNOCKBACK_DISTANCE EQU 8
DEF FRIED_EGG_FIRST_TILE EQU 204
DEF FRIED_EGG_IDLE_TILE EQU FRIED_EGG_FIRST_TILE
DEF FRIED_EGG_STEP_TILE EQU FRIED_EGG_FIRST_TILE + 4
DEF FRIED_EGG_AIRBORNE_TILE EQU FRIED_EGG_FIRST_TILE + 8
DEF FRIED_EGG_LANDING_TILE EQU FRIED_EGG_FIRST_TILE + 12
DEF FRIED_EGG_STATE_GROUNDED EQU 1
DEF FRIED_EGG_STATE_AIRBORNE EQU 2
DEF FRIED_EGG_STATE_LANDING EQU 3
DEF FRIED_EGG_STATE_BURST EQU 4
DEF FRIED_EGG_MAX_COUNT EQU 2
DEF FRIED_EGG_RECORD_SIZE EQU 19
DEF FRIED_EGG_RECORD_HIT_LATCH EQU 14
DEF FRIED_EGG_FRAME_DURATION EQU 8
DEF FRIED_EGG_LANDING_DURATION EQU 8
DEF FRIED_EGG_LAUNCH_VELOCITY EQU -5
DEF FRIED_EGG_TERMINAL_VELOCITY EQU 8
DEF FRIED_EGG_LEVEL_TOLERANCE EQU 28
DEF FRIED_EGG_MAX_HORIZONTAL_VELOCITY EQU 16
DEF FRIED_EGG_HORIZONTAL_ACCELERATION EQU 4
DEF FRIED_EGG_TURN_COMMITMENT EQU 20
DEF FRIED_EGG_HIT_KNOCKBACK_DISTANCE EQU 8
DEF FRIED_EGG_HIT_STUN_DURATION EQU 20
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
IF DEF(BURGER_PLAYTEST)
INCLUDE "build/burger_playtest.inc"
ENDC
IF DEF(PANCAKE_PLAYTEST)
INCLUDE "build/pancake_playtest.inc"
ENDC
IF DEF(FRIED_EGG_PLAYTEST)
INCLUDE "build/fried_egg_playtest.inc"
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
BurgerY: db
BurgerX: dw
BurgerVelY: db
BurgerVelX: db
BurgerState: db
BurgerTimer: db
BurgerTileBase: db
BurgerHealth: db
BurgerHitThisSwing: db
BurgerHitFlashTimer: db
BurgerKnockbackRemaining: db
BurgerKnockbackDirection: db
BurgerRecords: ds BURGER_MAX_COUNT * BURGER_RECORD_SIZE
BurgerCount: db
BurgerLoopIndex: db
BurgerOAMPointer: dw
PancakeY: db
PancakeX: dw
PancakeDirection: db
PancakeState: db
PancakeMoveTimer: db
PancakeAnimTimer: db
PancakeTileBase: db
PancakeRetreatTimer: db
PancakeHealth: db
PancakeHitThisSwing: db
PancakeHitFlashTimer: db
PancakeBurstTimer: db
PancakeKnockbackRemaining: db
PancakeKnockbackDirection: db
PancakeRecords: ds PANCAKE_MAX_COUNT * PANCAKE_RECORD_SIZE
PancakeCount: db
PancakeLoopIndex: db
PancakeOAMPointer: dw
FriedEggY: db
FriedEggX: dw
FriedEggVelY: db
FriedEggDirection: db
FriedEggState: db
FriedEggTimer: db
FriedEggAnimTimer: db
FriedEggTileBase: db
FriedEggVelocityX: db
FriedEggFractionX: db
FriedEggTargetDirection: db
FriedEggTurnCommitment: db
FriedEggHealth: db
FriedEggHitThisSwing: db
FriedEggHitFlashTimer: db
FriedEggKnockbackRemaining: db
FriedEggKnockbackDirection: db
FriedEggStunTimer: db
FriedEggRecords: ds FRIED_EGG_MAX_COUNT * FRIED_EGG_RECORD_SIZE
FriedEggCount: db
FriedEggLoopIndex: db
FriedEggOAMPointer: dw
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
	ld de, EnemyBurstTiles
	ld hl, $8b00
	ld c, 12 * 16
.copyEnemyBurstTiles
	ld a, [de]
	ld [hl+], a
	inc de
	dec c
	jr nz, .copyEnemyBurstTiles
	ld de, BurgerTiles
	ld hl, $8bc0
	ld c, 8 * 16
.copyBurgerTiles
	ld a, [de]
	ld [hl+], a
	inc de
	dec c
	jr nz, .copyBurgerTiles
	ld de, PancakeTiles
	ld hl, $8c40
	ld c, 8 * 16
.copyPancakeTiles
	ld a, [de]
	ld [hl+], a
	inc de
	dec c
	jr nz, .copyPancakeTiles
	ld de, FriedEggTiles
	ld hl, $8cc0
	ld b, 16
.copyFriedEggTilesOuter
	ld c, 16
.copyFriedEggTilesInner
	ld a, [de]
	ld [hl+], a
	inc de
	dec c
	jr nz, .copyFriedEggTilesInner
	dec b
	jr nz, .copyFriedEggTilesOuter

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
	call ClearBurgerRecords
	call ClearPancakeRecords
	call ClearFriedEggRecords
IF DEF(ROOM_VARIANT_PLAYTEST)
	call LoadRoomVariantPlaytest
ELSE
	IF DEF(FRIED_EGG_PLAYTEST)
	call LoadFriedEggPlaytest
	ELSE
	call GenerateLevel
	ENDC
ENDC
IF DEF(PANCAKE_PLAYTEST)
	call LoadPancakePlaytest
	call ClearWeinerRecords
	call ClearBurgerRecords
ELSE
IF DEF(BURGER_PLAYTEST)
	call LoadBurgerPlaytest
ELSE
IF DEF(COMBAT_PLAYTEST)
	call LoadCombatPlaytest
ENDC
ENDC
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
	IF DEF(BURGER_PLAYTEST)
	call InitializeCombatBurger
	ELSE
	call InitializeCombatWeiner
	ENDC
ENDC
IF DEF(PANCAKE_PLAYTEST)
	call InitializePlaytestPancake
ENDC
IF DEF(FRIED_EGG_PLAYTEST)
	call InitializePlaytestFriedEgg
ENDC
	call ReadActionButtons
	ld [PrevButtons], a
IF DEF(EXIT_ANIMATION_PLAYTEST)
	call SetPlayerAtExitThreshold
ENDC
	call UpdateHUDSprites
	call UpdateSprites
	call UpdateWeinerSprites
	call UpdateBurgerSprites
	call UpdatePancakeSprites
	IF DEF(FRIED_EGG_PLAYTEST)
	call UpdateFriedEggSprites
	ENDC
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

IF DEF(BURGER_PLAYTEST)
LoadBurgerPlaytest:
	ld de, BurgerPlaytestMap
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
	ld a, LOW(BURGER_PLAYTEST_PLAYER_X)
	ld [GeneratedPlayerX], a
	ld a, HIGH(BURGER_PLAYTEST_PLAYER_X)
	ld [GeneratedPlayerX + 1], a
	ld a, BURGER_PLAYTEST_PLAYER_Y
	ld [GeneratedPlayerY], a
	call ClearWeinerRecords
	ret
ENDC

IF DEF(PANCAKE_PLAYTEST)
LoadPancakePlaytest:
	ld de, PancakePlaytestMap
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
	ld a, LOW(PANCAKE_PLAYTEST_PLAYER_X)
	ld [GeneratedPlayerX], a
	ld a, HIGH(PANCAKE_PLAYTEST_PLAYER_X)
	ld [GeneratedPlayerX + 1], a
	ld a, PANCAKE_PLAYTEST_PLAYER_Y
	ld [GeneratedPlayerY], a
	ret
ENDC

IF DEF(FRIED_EGG_PLAYTEST)
LoadFriedEggPlaytest:
	ld de, FriedEggPlaytestMap
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
	ld a, LOW(FRIED_EGG_PLAYTEST_PLAYER_X)
	ld [GeneratedPlayerX], a
	ld a, HIGH(FRIED_EGG_PLAYTEST_PLAYER_X)
	ld [GeneratedPlayerX + 1], a
	ld a, FRIED_EGG_PLAYTEST_PLAYER_Y
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
	call UpdateBurgerSprites
	call UpdatePancakeSprites
	IF DEF(FRIED_EGG_PLAYTEST)
	call UpdateFriedEggSprites
	ENDC
	ret
.gameplay
	call UpdateCameraState
	call UpdateHUDSprites
	call AdvanceWeiners
	call AdvanceBurgers
	call AdvancePancakes
	IF DEF(FRIED_EGG_PLAYTEST)
	call AdvanceFriedEggs
	ENDC
	call UpdateSprites
	call UpdateWeinerSprites
	call UpdateBurgerSprites
	call UpdatePancakeSprites
	IF DEF(FRIED_EGG_PLAYTEST)
	call UpdateFriedEggSprites
	ENDC
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
	call ResetBurgerHitLatches
	call ResetPancakeHitLatch
	call ResetFriedEggHitLatches
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
	call TryPanHitBurgers
	call TryPanHitPancakes
	call TryPanHitFriedEggs
	call TryWeinerContacts
	call TryBurgerContacts
	call TryPancakeContacts
	call TryFriedEggContacts

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
	ld a, WEINER_STATE_ACTIVE
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
	call ClearBurgerRecords
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
	ld b, a
	ld a, [WeinerCount]
	cp a, b
	ret z
	ld a, b
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
	ld b, a
	ld a, [WeinerCount]
	cp a, b
	ret z
	ld a, b
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
	ld b, a
	ld a, [WeinerCount]
	cp a, b
	ret z
	ld a, b
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
	ld b, a
	ld a, [WeinerCount]
	cp a, b
	ret z
	ld a, b
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
	cp a, WEINER_STATE_BURST
	jr z, AdvanceEnemyBurst
	cp a, WEINER_STATE_ACTIVE
	ret nz
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

AdvanceEnemyBurst:
	ld hl, WeinerAnimTimer
	inc [hl]
	ld a, [hl]
	cp a, ENEMY_BURST_DURATION
	jr nc, .finished
	and a, ENEMY_BURST_FRAME_DURATION - 1
	ret nz
	ld hl, WeinerTileBase
	ld a, [hl]
	add a, 4
	ld [hl], a
	ret
.finished
	xor a
	ld [WeinerActive], a
	ret

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
	cp a, WEINER_STATE_ACTIVE
	ret nz
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
	call StartEnemyBurst
	ret

StartEnemyBurst:
	xor a
	ld [WeinerAnimTimer], a
	ld a, ENEMY_BURST_FIRST_TILE
	ld [WeinerTileBase], a
	ld a, WEINER_STATE_BURST
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
	cp a, WEINER_STATE_ACTIVE
	ret nz
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
	ld a, [WeinerX + 1]
	ld d, a
	ld a, [CameraX + 1]
	cp a, d
	jr c, .leftEdgeClear
	jr nz, .hidden
	ld a, [WeinerX]
	ld e, a
	ld a, [CameraX]
	cp a, e
	jr z, .leftEdgeClear
	jr nc, .hidden
.leftEdgeClear
	ld a, [CameraX]
	add a, 160
	ld e, a
	ld a, [CameraX + 1]
	adc a, 0
	ld d, a
	ld a, [WeinerX]
	add a, 16
	ld c, a
	ld a, [WeinerX + 1]
	adc a, 0
	cp a, d
	jr c, .vertical
	jr nz, .hidden
	ld a, c
	cp a, e
	jr c, .vertical
	jr nz, .hidden
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
	ld a, [WeinerActive]
	cp a, WEINER_STATE_BURST
	jr z, .orientationReady
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

SECTION "BURGER Runtime", ROMX
ClearBurgerRecords:
	ld hl, BurgerY
	ld b, BURGER_RECORD_SIZE
	xor a
.clearScratch
	ld [hl+], a
	dec b
	jr nz, .clearScratch
	ld hl, BurgerRecords
	ld b, BURGER_MAX_COUNT * BURGER_RECORD_SIZE
.clearRecords
	ld [hl+], a
	dec b
	jr nz, .clearRecords
	ld [BurgerCount], a
	ret

GetBurgerRecordPointer:
	ld hl, BurgerRecords
	and a
	ret z
	ld de, BURGER_RECORD_SIZE
.advance
	add hl, de
	dec a
	jr nz, .advance
	ret

LoadBurgerRecord:
	call GetBurgerRecordPointer
	ld de, BurgerY
	ld b, BURGER_RECORD_SIZE
.copy
	ld a, [hl+]
	ld [de], a
	inc de
	dec b
	jr nz, .copy
	ret

StoreBurgerRecord:
	call GetBurgerRecordPointer
	ld de, BurgerY
	ld b, BURGER_RECORD_SIZE
.copy
	ld a, [de]
	inc de
	ld [hl+], a
	dec b
	jr nz, .copy
	ret

InitializeBurgerScratch:
	xor a
	ld [BurgerVelY], a
	ld [BurgerTimer], a
	ld [BurgerHitThisSwing], a
	ld [BurgerHitFlashTimer], a
	ld [BurgerKnockbackRemaining], a
	ld [BurgerKnockbackDirection], a
	ld a, 1
	ld [BurgerVelX], a
	ld a, BURGER_STATE_IDLE
	ld [BurgerState], a
	ld a, BURGER_IDLE_TILE
	ld [BurgerTileBase], a
	ld a, 2
	ld [BurgerHealth], a
	ret

CreateBurgerAtTile:
	ld a, c
	inc a
	add a, a
	add a, a
	add a, a
	ld [BurgerY], a
	ld h, 0
	ld l, b
	add hl, hl
	add hl, hl
	add hl, hl
	ld a, l
	ld [BurgerX], a
	ld a, h
	ld [BurgerX + 1], a
	call InitializeBurgerScratch
	ld a, [BurgerCount]
	push af
	call StoreBurgerRecord
	pop af
	inc a
	ld [BurgerCount], a
	ret

IF DEF(BURGER_PLAYTEST)
InitializeCombatBurger:
	call ClearBurgerRecords
	ld a, BURGER_PLAYTEST_BURGER_Y
	ld [BurgerY], a
	ld a, LOW(BURGER_PLAYTEST_BURGER_X)
	ld [BurgerX], a
	ld a, HIGH(BURGER_PLAYTEST_BURGER_X)
	ld [BurgerX + 1], a
	call InitializeBurgerScratch
	xor a
	call StoreBurgerRecord
	ld a, 1
	ld [BurgerCount], a
	ret
ENDC

ResetBurgerHitLatches:
	ld hl, BurgerRecords + BURGER_RECORD_HIT_LATCH
	ld de, BURGER_RECORD_SIZE
	ld b, BURGER_MAX_COUNT
	xor a
.loop
	ld [hl], a
	add hl, de
	dec b
	jr nz, .loop
	ret

AdvanceBurgers:
	xor a
	ld [BurgerLoopIndex], a
.loop
	ld a, [BurgerLoopIndex]
	ld b, a
	ld a, [BurgerCount]
	cp a, b
	ret z
	ld a, b
	push af
	call LoadBurgerRecord
	call AdvanceBurger
	pop af
	push af
	call StoreBurgerRecord
	pop af
	inc a
	ld [BurgerLoopIndex], a
	jr .loop

AdvanceBurger:
	ld a, [BurgerState]
	and a
	ret z
	ld hl, BurgerHitFlashTimer
	ld a, [hl]
	and a
	jr z, .state
	dec [hl]
.state
	ld a, [BurgerState]
	cp a, BURGER_STATE_BURST
	jp z, AdvanceBurgerBurst
	ld a, [BurgerKnockbackRemaining]
	and a
	jp nz, ApplyBurgerKnockback
	ld a, [BurgerState]
	cp a, BURGER_STATE_IDLE
	jr z, AdvanceBurgerIdle
	cp a, BURGER_STATE_WINDUP
	jr z, AdvanceBurgerWindup
	cp a, BURGER_STATE_AIRBORNE
	jp z, AdvanceBurgerAirborne
	jp AdvanceBurgerLanding

AdvanceBurgerIdle:
	ld hl, BurgerTimer
	inc [hl]
	ld a, [hl]
	cp a, BURGER_IDLE_DURATION
	jr nc, StartBurgerWindup
	and a, BURGER_IDLE_BEAT_DURATION * 4 - 1
	cp a, BURGER_IDLE_BEAT_DURATION * 3
	ld a, BURGER_IDLE_TILE
	jr c, .storeTile
	ld a, BURGER_AIRBORNE_TILE
.storeTile
	ld [BurgerTileBase], a
	ret

StartBurgerWindup:
	xor a
	ld [BurgerTimer], a
	ld a, BURGER_STATE_WINDUP
	ld [BurgerState], a
	ld a, BURGER_WINDUP_TILE
	ld [BurgerTileBase], a
	ld a, [PlayerX + 1]
	ld b, a
	ld a, [BurgerX + 1]
	cp a, b
	jr c, .right
	jr nz, .left
	ld a, [PlayerX]
	ld b, a
	ld a, [BurgerX]
	add a, 8
	cp a, b
	jr c, .right
.left
	ld a, -1
	ld [BurgerVelX], a
	ret
.right
	ld a, 1
	ld [BurgerVelX], a
	ret

AdvanceBurgerWindup:
	ld hl, BurgerTimer
	inc [hl]
	ld a, [hl]
	cp a, BURGER_WINDUP_DURATION
	ret c
	xor a
	ld [BurgerTimer], a
	ld a, BURGER_LAUNCH_VELOCITY
	ld [BurgerVelY], a
	ld a, BURGER_STATE_AIRBORNE
	ld [BurgerState], a
	ld a, BURGER_AIRBORNE_TILE
	ld [BurgerTileBase], a
	ret

AdvanceBurgerAirborne:
	ld hl, BurgerVelY
	ld a, [hl]
	inc a
	bit 7, a
	jr nz, .storeVelocity
	cp a, BURGER_TERMINAL_VELOCITY + 1
	jr c, .storeVelocity
	ld a, BURGER_TERMINAL_VELOCITY
.storeVelocity
	ld [hl], a
	and a
	jp z, AdvanceBurgerHorizontal
	bit 7, a
	jr nz, .rising
	ld b, a
.fallStep
	call BurgerSupportBelow
	jr z, .landing
	ld hl, BurgerY
	inc [hl]
	dec b
	jr nz, .fallStep
	jp AdvanceBurgerHorizontal
.landing
	call AdvanceBurgerHorizontal
	call BurgerSupportBelow
	ret nz
	jp StartBurgerLanding
.rising
	cpl
	inc a
	ld b, a
.riseStep
	call BurgerCeilingAbove
	jr z, .headBump
	ld hl, BurgerY
	dec [hl]
	dec b
	jr nz, .riseStep
	jp AdvanceBurgerHorizontal
.headBump
	xor a
	ld [BurgerVelY], a
	jp AdvanceBurgerHorizontal

StartBurgerLanding:
	xor a
	ld [BurgerVelY], a
	ld [BurgerTimer], a
	ld a, BURGER_STATE_LANDING
	ld [BurgerState], a
	ld a, BURGER_LANDING_TILE
	ld [BurgerTileBase], a
	ret

AdvanceBurgerLanding:
	ld hl, BurgerTimer
	inc [hl]
	ld a, [hl]
	cp a, BURGER_LANDING_DURATION
	ret c
	xor a
	ld [BurgerTimer], a
	ld a, BURGER_STATE_IDLE
	ld [BurgerState], a
	ld a, BURGER_IDLE_TILE
	ld [BurgerTileBase], a
	ret

AdvanceBurgerBurst:
	ld hl, BurgerTimer
	inc [hl]
	ld a, [hl]
	cp a, ENEMY_BURST_DURATION
	jr nc, .finished
	and a, ENEMY_BURST_FRAME_DURATION - 1
	ret nz
	ld hl, BurgerTileBase
	ld a, [hl]
	add a, 4
	ld [hl], a
	ret
.finished
	xor a
	ld [BurgerState], a
	ret

AdvanceBurgerHorizontal:
	ld a, [BurgerVelX]
	bit 7, a
	jr nz, .left
	call BurgerWallRight
	jr z, ReverseBurgerDirection
	ld hl, BurgerX
	inc [hl]
	ret nz
	inc hl
	inc [hl]
	ret
.left
	call BurgerWallLeft
	jr z, ReverseBurgerDirection
	ld hl, BurgerX
	ld a, [hl]
	and a
	jr nz, .decrementLow
	inc hl
	dec [hl]
	dec hl
.decrementLow
	dec [hl]
	ret

ReverseBurgerDirection:
	ld a, [BurgerVelX]
	cpl
	inc a
	ld [BurgerVelX], a
	ret

BurgerWallRight:
	ld a, [BurgerX]
	add a, 16
	ld e, a
	ld a, [BurgerX + 1]
	adc a, 0
	ld c, a
	ld a, [BurgerY]
	sub a, 7
	ld d, a
	call IsWall
	ret z
	ld a, [BurgerX]
	add a, 16
	ld e, a
	ld a, [BurgerX + 1]
	adc a, 0
	ld c, a
	ld a, [BurgerY]
	dec a
	ld d, a
	jp IsWall

BurgerWallLeft:
	ld a, [BurgerX]
	sub a, 1
	ld e, a
	ld a, [BurgerX + 1]
	sbc a, 0
	ld c, a
	ld a, [BurgerY]
	sub a, 7
	ld d, a
	call IsWall
	ret z
	ld a, [BurgerX]
	sub a, 1
	ld e, a
	ld a, [BurgerX + 1]
	sbc a, 0
	ld c, a
	ld a, [BurgerY]
	dec a
	ld d, a
	jp IsWall

BurgerCeilingAbove:
	ld a, [BurgerX]
	add a, 1
	ld e, a
	ld a, [BurgerX + 1]
	adc a, 0
	ld c, a
	ld a, [BurgerY]
	sub a, 9
	ld d, a
	call IsWall
	ret z
	ld a, [BurgerX]
	add a, 14
	ld e, a
	ld a, [BurgerX + 1]
	adc a, 0
	ld c, a
	ld a, [BurgerY]
	sub a, 9
	ld d, a
	jp IsWall

BurgerSupportBelow:
	ld a, [BurgerX]
	add a, 1
	ld e, a
	ld a, [BurgerX + 1]
	adc a, 0
	ld c, a
	ld a, [BurgerY]
	inc a
	ld d, a
	call IsSupport
	ret z
	ld a, [BurgerX]
	add a, 14
	ld e, a
	ld a, [BurgerX + 1]
	adc a, 0
	ld c, a
	ld a, [BurgerY]
	inc a
	ld d, a
	jp IsSupport

TryPanHitBurgers:
	xor a
	ld [BurgerLoopIndex], a
.loop
	ld a, [BurgerLoopIndex]
	ld b, a
	ld a, [BurgerCount]
	cp a, b
	ret z
	ld a, b
	push af
	call LoadBurgerRecord
	call TryPanHitBurger
	pop af
	push af
	call StoreBurgerRecord
	pop af
	inc a
	ld [BurgerLoopIndex], a
	jr .loop

TryPanHitBurger:
	ld a, [BurgerState]
	and a
	ret z
	cp a, BURGER_STATE_BURST
	ret z
	ld a, [BurgerHitThisSwing]
	and a
	ret nz
	ld a, [AttackTimer]
	and a
	ret z
	ld a, [AttackPanTileBase]
	and a
	ret z
	call CheckBurgerAttackX
	ret nc
	call CheckBurgerAttackY
	ret nc
	ld a, 1
	ld [BurgerHitThisSwing], a
	ld hl, BurgerHealth
	dec [hl]
	jr z, StartBurgerBurst
	ld a, 12
	ld [BurgerHitFlashTimer], a
	call StartBurgerKnockback
	ret

StartBurgerKnockback:
	ld a, BURGER_HIT_KNOCKBACK_DISTANCE
	ld [BurgerKnockbackRemaining], a
	ld a, [BurgerX]
	add a, 8
	ld l, a
	ld a, [BurgerX + 1]
	adc a, 0
	ld h, a
	ld a, [PlayerX]
	add a, 6
	ld e, a
	ld a, [PlayerX + 1]
	adc a, 0
	ld d, a
	ld a, l
	sub a, e
	ld l, a
	ld a, h
	sbc a, d
	ld h, a
	bit 7, h
	jr nz, .left
	ld a, 1
	jr .store
.left
	ld a, -1
.store
	ld [BurgerKnockbackDirection], a
	ld [BurgerVelX], a
	ret

ApplyBurgerKnockback:
	ld a, [BurgerKnockbackDirection]
	bit 7, a
	jr nz, .left
	call BurgerWallRight
	jr z, .blocked
	ld hl, BurgerX
	inc [hl]
	jr nz, .moved
	inc hl
	inc [hl]
	jr .moved
.left
	call BurgerWallLeft
	jr z, .blocked
	ld hl, BurgerX
	ld a, [hl]
	and a
	jr nz, .decrementLow
	inc hl
	dec [hl]
	dec hl
.decrementLow
	dec [hl]
.moved
	ld hl, BurgerKnockbackRemaining
	dec [hl]
	ret
.blocked
	xor a
	ld [BurgerKnockbackRemaining], a
	ret

StartBurgerBurst:
	xor a
	ld [BurgerTimer], a
	ld [BurgerHitFlashTimer], a
	ld a, ENEMY_BURST_FIRST_TILE
	ld [BurgerTileBase], a
	ld a, BURGER_STATE_BURST
	ld [BurgerState], a
	ret

CheckBurgerAttackX:
	ld a, [AttackPanTileBase]
	cp a, PAN_ATTACK_WINDUP_TILE
	jp z, CheckBurgerCloseX
	ld a, [FacingFlip]
	and a
	jr nz, .left
	ld a, [BurgerX]
	add a, 8
	ld l, a
	ld a, [BurgerX + 1]
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
	ld a, [BurgerX]
	add a, 8
	ld e, a
	ld a, [BurgerX + 1]
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

CheckBurgerCloseX:
	ld a, [BurgerX]
	add a, 8
	ld l, a
	ld a, [BurgerX + 1]
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
	inc a
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

CheckBurgerAttackY:
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
	jr .boundsReady
.checkStrike
	cp a, PAN_ATTACK_STRIKE_TILE
	jr nz, .recovery
	ld a, b
	sub a, 16
	ld b, a
	jr .boundsReady
.recovery
	ld a, b
	sub a, 8
	ld b, a
.boundsReady
	ld a, [BurgerY]
	dec a
	cp a, b
	jr c, .miss
	ld a, [BurgerY]
	sub a, 8
	ld d, a
	ld a, c
	cp a, d
	jr c, .miss
	scf
	ret
.miss
	and a
	ret

TryBurgerContacts:
	xor a
	ld [BurgerLoopIndex], a
.loop
	ld a, [BurgerLoopIndex]
	ld b, a
	ld a, [BurgerCount]
	cp a, b
	ret z
	ld a, b
	push af
	call LoadBurgerRecord
	call TryBurgerContact
	pop af
	push af
	call StoreBurgerRecord
	pop af
	inc a
	ld [BurgerLoopIndex], a
	jr .loop

TryBurgerContact:
	ld a, [BurgerState]
	and a
	ret z
	cp a, BURGER_STATE_BURST
	ret z
	ld a, [PlayerInvulnerabilityTimer]
	and a
	ret nz
	call CheckBurgerCloseX
	ret nc
	ld a, [PlayerY]
	dec a
	ld b, a
	ld a, [BurgerY]
	sub a, 8
	ld c, a
	ld a, b
	cp a, c
	jr c, .miss
	ld a, [PlayerY]
	sub a, PLAYER_HITBOX_TOP
	ld b, a
	ld a, [BurgerY]
	dec a
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
	ld a, [BurgerX]
	add a, 8
	ld e, a
	ld a, [BurgerX + 1]
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

UpdateBurgerSprites:
	ld a, [WeinerOAMPointer]
	ld [BurgerOAMPointer], a
	ld a, [WeinerOAMPointer + 1]
	ld [BurgerOAMPointer + 1], a
	xor a
	ld [BurgerLoopIndex], a
.loop
	ld a, [BurgerLoopIndex]
	ld b, a
	ld a, [BurgerCount]
	cp a, b
	jr z, HideUnusedEnemySprites
	ld a, b
	push af
	call LoadBurgerRecord
	call UpdateBurgerSprite
	pop af
	inc a
	ld [BurgerLoopIndex], a
	ld a, [BurgerOAMPointer]
	add a, 16
	ld [BurgerOAMPointer], a
	jr nc, .loop
	ld hl, BurgerOAMPointer + 1
	inc [hl]
	jr .loop

HideUnusedEnemySprites:
	ld a, [WeinerCount]
	ld b, a
	ld a, [BurgerCount]
	add a, b
	ld b, a
	ld a, WEINER_MAX_COUNT
	sub a, b
	ret z
	ld b, a
	ld a, [BurgerOAMPointer]
	ld l, a
	ld a, [BurgerOAMPointer + 1]
	ld h, a
	xor a
.block
	ld [hl], a
	ld de, 4
	add hl, de
	ld [hl], a
	add hl, de
	ld [hl], a
	add hl, de
	ld [hl], a
	add hl, de
	dec b
	jr nz, .block
	ret

UpdateBurgerSprite:
	ld a, [BurgerOAMPointer]
	ld l, a
	ld a, [BurgerOAMPointer + 1]
	ld h, a
	ld a, [BurgerState]
	and a
	jp z, HideBurgerSprite
	ld a, [BurgerHitFlashTimer]
	bit 1, a
	jp nz, HideBurgerSprite
	ld a, [BurgerX + 1]
	ld d, a
	ld a, [CameraX + 1]
	cp a, d
	jr c, .leftEdgeClear
	jp nz, HideBurgerSprite
	ld a, [BurgerX]
	ld e, a
	ld a, [CameraX]
	cp a, e
	jr z, .leftEdgeClear
	jp nc, HideBurgerSprite
.leftEdgeClear
	ld a, [CameraX]
	add a, 160
	ld e, a
	ld a, [CameraX + 1]
	adc a, 0
	ld d, a
	ld a, [BurgerX]
	add a, 16
	ld c, a
	ld a, [BurgerX + 1]
	adc a, 0
	cp a, d
	jr c, .vertical
	jp nz, HideBurgerSprite
	ld a, c
	cp a, e
	jr c, .vertical
	jp nz, HideBurgerSprite
.vertical
	ld a, [BurgerY]
	add a, 8
	jr c, .bottomEdge
	ld e, a
	ld a, [CameraY]
	cp a, e
	jp nc, HideBurgerSprite
.bottomEdge
	ld a, [CameraY]
	add a, 144
	jr c, .visible
	ld e, a
	ld a, [BurgerY]
	sub a, 8
	cp a, e
	jp nc, HideBurgerSprite
.visible
	ld a, [BurgerState]
	cp a, BURGER_STATE_BURST
	jp z, UpdateBurgerBurstSprite
	ld a, [CameraY]
	ld b, a
	ld a, [CameraX]
	ld c, a
	ld a, [BurgerVelX]
	bit 7, a
	ld d, 0
	jr z, .attributesReady
	ld d, $20
.attributesReady
	ld a, [BurgerY]
	add a, 9
	sub a, b
	ld [hl+], a
	ld a, [BurgerX]
	add a, 8
	sub a, c
	ld [hl+], a
	ld a, [BurgerTileBase]
	ld e, a
	ld a, d
	and a
	ld a, e
	jr z, .firstTileReady
	inc a
.firstTileReady
	ld [hl+], a
	ld a, d
	ld [hl+], a
	ld a, [BurgerY]
	add a, 9
	sub a, b
	ld [hl+], a
	ld a, [BurgerX]
	add a, 16
	sub a, c
	ld [hl+], a
	ld a, [BurgerTileBase]
	ld e, a
	ld a, d
	and a
	ld a, e
	jr nz, .secondTileReady
	inc a
.secondTileReady
	ld [hl+], a
	ld a, d
	ld [hl+], a
	xor a
	ld [hl], a
	ld de, 4
	add hl, de
	ld [hl], a
	ret

UpdateBurgerBurstSprite:
	ld a, [CameraY]
	ld b, a
	ld a, [CameraX]
	ld c, a
	ld a, [BurgerY]
	add a, 4
	sub a, b
	ld d, a
	ld a, [BurgerX]
	add a, 8
	sub a, c
	ld e, a
	ld a, d
	ld [hl+], a
	ld a, e
	ld [hl+], a
	ld a, [BurgerTileBase]
	ld [hl+], a
	xor a
	ld [hl+], a
	ld a, d
	ld [hl+], a
	ld a, e
	add a, 8
	ld [hl+], a
	ld a, [BurgerTileBase]
	inc a
	ld [hl+], a
	xor a
	ld [hl+], a
	ld a, d
	add a, 8
	ld [hl+], a
	ld a, e
	ld [hl+], a
	ld a, [BurgerTileBase]
	add a, 2
	ld [hl+], a
	xor a
	ld [hl+], a
	ld a, d
	add a, 8
	ld [hl+], a
	ld a, e
	add a, 8
	ld [hl+], a
	ld a, [BurgerTileBase]
	add a, 3
	ld [hl+], a
	xor a
	ld [hl], a
	ret

HideBurgerSprite:
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

SECTION "PANCAKE Runtime", ROMX
ClearPancakeRecords:
	ld hl, PancakeY
	ld b, 15
	xor a
.clearScratch
	ld [hl+], a
	dec b
	jr nz, .clearScratch
	ld hl, PancakeRecords
	ld b, PANCAKE_MAX_COUNT * PANCAKE_RECORD_SIZE
.clearRecords
	ld [hl+], a
	dec b
	jr nz, .clearRecords
	ld [PancakeCount], a
	ret

GetPancakeRecordPointer:
	ld hl, PancakeRecords
	and a
	ret z
	ld de, PANCAKE_RECORD_SIZE
.advance
	add hl, de
	dec a
	jr nz, .advance
	ret

LoadPancakeRecord:
	call GetPancakeRecordPointer
	ld de, PancakeY
	ld b, PANCAKE_RECORD_SIZE
.copy
	ld a, [hl+]
	ld [de], a
	inc de
	dec b
	jr nz, .copy
	ret

StorePancakeRecord:
	call GetPancakeRecordPointer
	ld de, PancakeY
	ld b, PANCAKE_RECORD_SIZE
.copy
	ld a, [de]
	inc de
	ld [hl+], a
	dec b
	jr nz, .copy
	ret

InitializePancakeScratch:
	ld hl, PancakeDirection
	ld b, 12
	xor a
.clear
	ld [hl+], a
	dec b
	jr nz, .clear
	ld a, -1
	ld [PancakeDirection], a
	ld a, PANCAKE_STATE_ACTIVE
	ld [PancakeState], a
	ld a, PANCAKE_FIRST_TILE
	ld [PancakeTileBase], a
	ld a, 2
	ld [PancakeHealth], a
	ret

CreatePancakeAtTile:
	ld a, c
	add a, a
	add a, a
	add a, a
	ld [PancakeY], a
	ld h, 0
	ld l, b
	add hl, hl
	add hl, hl
	add hl, hl
	ld a, l
	ld [PancakeX], a
	ld a, h
	ld [PancakeX + 1], a
	call InitializePancakeScratch
	ld a, [PancakeCount]
	push af
	call StorePancakeRecord
	pop af
	inc a
	ld [PancakeCount], a
	ret

IF DEF(PANCAKE_PLAYTEST)
InitializePlaytestPancake:
	call ClearPancakeRecords
	ld a, PANCAKE_PLAYTEST_PANCAKE_Y
	ld [PancakeY], a
	ld a, LOW(PANCAKE_PLAYTEST_PANCAKE_X)
	ld [PancakeX], a
	ld a, HIGH(PANCAKE_PLAYTEST_PANCAKE_X)
	ld [PancakeX + 1], a
	call InitializePancakeScratch
	xor a
	call StorePancakeRecord
	ld a, 1
	ld [PancakeCount], a
	ret
ENDC

AdvancePancakes:
	xor a
	ld [PancakeLoopIndex], a
.loop
	ld a, [PancakeLoopIndex]
	ld b, a
	ld a, [PancakeCount]
	cp a, b
	ret z
	ld a, b
	push af
	call LoadPancakeRecord
	call AdvancePancake
	pop af
	push af
	call StorePancakeRecord
	pop af
	inc a
	ld [PancakeLoopIndex], a
	jr .loop

AdvancePancake:
	ld a, [PancakeState]
	and a
	ret z
	ld hl, PancakeHitFlashTimer
	ld a, [hl]
	and a
	jr z, .state
	dec [hl]
.state
	ld a, [PancakeState]
	cp a, PANCAKE_STATE_BURST
	jp z, AdvancePancakeBurst
	ld a, [PancakeKnockbackRemaining]
	and a
	jp nz, ApplyPancakeKnockback
	ld hl, PancakeAnimTimer
	inc [hl]
	ld a, [hl]
	cp a, PANCAKE_FRAME_DURATION
	jr c, .movement
	xor a
	ld [hl], a
	ld a, [PancakeTileBase]
	add a, 2
	cp a, PANCAKE_FIRST_TILE + 8
	jr c, .storeTile
	ld a, PANCAKE_FIRST_TILE
.storeTile
	ld [PancakeTileBase], a
.movement
	ld hl, PancakeMoveTimer
	ld a, [hl]
	and a
	jr z, .readyToMove
	dec [hl]
	ret
.readyToMove
	ld a, [PancakeRetreatTimer]
	and a
	jr z, .aim
	call SetPancakeRetreatCooldown
	ld a, [PancakeRetreatTimer]
	dec a
	ld [PancakeRetreatTimer], a
	jr .move
.aim
	call SetPancakeTargetCooldown
	call AimPancakeAtPlayer
.move
	ld a, [PancakeDirection]
	bit 7, a
	jr nz, .left
	call PancakeWallRight
	jr z, .reverseLeft
	ld hl, PancakeX
	inc [hl]
	ret nz
	inc hl
	inc [hl]
	ret
.reverseLeft
	ld a, -1
	ld [PancakeDirection], a
	ld a, PANCAKE_WALL_RETREAT_STEPS
	ld [PancakeRetreatTimer], a
	ret

.left
	call PancakeWallLeft
	jr z, .reverseRight
	ld hl, PancakeX
	ld a, [hl]
	and a
	jr nz, .decrementLow
	inc hl
	dec [hl]
	dec hl
.decrementLow
	dec [hl]
	ret
.reverseRight
	ld a, 1
	ld [PancakeDirection], a
	ld a, PANCAKE_WALL_RETREAT_STEPS
	ld [PancakeRetreatTimer], a
	ret

AdvancePancakeBurst:
	ld hl, PancakeBurstTimer
	inc [hl]
	ld a, [hl]
	cp a, ENEMY_BURST_DURATION
	jr nc, .finished
	and a, ENEMY_BURST_FRAME_DURATION - 1
	ret nz
	ld hl, PancakeTileBase
	ld a, [hl]
	add a, 4
	ld [hl], a
	ret
.finished
	xor a
	ld [PancakeState], a
	ret

AimPancakeAtPlayer:
	ld a, [PancakeX]
	add a, 8
	ld l, a
	ld a, [PancakeX + 1]
	adc a, 0
	ld h, a
	ld a, [PlayerX]
	add a, 6
	ld e, a
	ld a, [PlayerX + 1]
	adc a, 0
	ld d, a
	ld a, e
	sub a, PANCAKE_TARGET_RADIUS
	ld e, a
	ld a, d
	sbc a, 0
	ld d, a
	ld a, h
	cp a, d
	jr c, .right
	jr nz, .upperBound
	ld a, l
	cp a, e
	jr c, .right
.upperBound
	ld a, [PlayerX]
	add a, 6 + PANCAKE_TARGET_RADIUS
	ld e, a
	ld a, [PlayerX + 1]
	adc a, 0
	ld d, a
	ld a, h
	cp a, d
	jr c, .keepDirection
	jr nz, .left
	ld a, l
	cp a, e
	jr c, .keepDirection
	ret z
.left
	ld a, -1
	ld [PancakeDirection], a
	ret
.right
	ld a, 1
	ld [PancakeDirection], a
.keepDirection
	ret

SetPancakeTargetCooldown:
	ld a, [PancakeX]
	add a, 8
	ld l, a
	ld a, [PancakeX + 1]
	adc a, 0
	ld h, a
	ld a, [PlayerX]
	add a, 6
	ld e, a
	ld a, [PlayerX + 1]
	adc a, 0
	ld d, a
	ld a, l
	sub a, e
	ld l, a
	ld a, h
	sbc a, d
	ld h, a
	bit 7, h
	jr z, .magnitudeReady
	ld a, l
	cpl
	ld l, a
	ld a, h
	cpl
	ld h, a
	inc hl
.magnitudeReady
	ld a, h
	and a
	jr nz, .medium
	ld a, l
	cp a, 5
	jr c, .fast
	cp a, 9
	jr c, .medium
	cp a, 13
	jr c, .slow
.medium
	ld a, 1
	ld [PancakeMoveTimer], a
	ret
.slow
	ld a, 3
	ld [PancakeMoveTimer], a
	ret
.fast
	xor a
	ld [PancakeMoveTimer], a
	ret

SetPancakeRetreatCooldown:
	ld a, [PancakeRetreatTimer]
	cp a, 21
	jr nc, .slow
	cp a, 17
	jr nc, .medium
	cp a, 9
	jr nc, .fast
	cp a, 5
	jr nc, .medium
.slow
	ld a, 3
	ld [PancakeMoveTimer], a
	ret
.medium
	ld a, 1
	ld [PancakeMoveTimer], a
	ret
.fast
	xor a
	ld [PancakeMoveTimer], a
	ret

PancakeWallRight:
	ld a, [PancakeX]
	add a, 16
	ld e, a
	ld a, [PancakeX + 1]
	adc a, 0
	ld c, a
	ld a, [PancakeY]
	inc a
	ld d, a
	call IsWall
	ret z
	ld a, [PancakeY]
	add a, 6
	ld d, a
	jp IsWall

PancakeWallLeft:
	ld a, [PancakeX]
	sub a, 1
	ld e, a
	ld a, [PancakeX + 1]
	sbc a, 0
	ld c, a
	ld a, [PancakeY]
	inc a
	ld d, a
	call IsWall
	ret z
	ld a, [PancakeY]
	add a, 6
	ld d, a
	jp IsWall

ResetPancakeHitLatch:
	ld hl, PancakeRecords + PANCAKE_RECORD_HIT_LATCH
	ld de, PANCAKE_RECORD_SIZE
	ld b, PANCAKE_MAX_COUNT
	xor a
.loop
	ld [hl], a
	add hl, de
	dec b
	jr nz, .loop
	ret

TryPanHitPancakes:
	xor a
	ld [PancakeLoopIndex], a
.loop
	ld a, [PancakeLoopIndex]
	ld b, a
	ld a, [PancakeCount]
	cp a, b
	ret z
	ld a, b
	push af
	call LoadPancakeRecord
	call TryPanHitPancake
	pop af
	push af
	call StorePancakeRecord
	pop af
	inc a
	ld [PancakeLoopIndex], a
	jr .loop

TryPanHitPancake:
	ld a, [PancakeState]
	cp a, PANCAKE_STATE_ACTIVE
	ret nz
	ld a, [PancakeHitThisSwing]
	and a
	ret nz
	ld a, [AttackTimer]
	and a
	ret z
	ld a, [AttackPanTileBase]
	and a
	ret z
	call CheckPancakeAttackX
	ret nc
	call CheckPancakeAttackY
	ret nc
	ld a, 1
	ld [PancakeHitThisSwing], a
	ld hl, PancakeHealth
	dec [hl]
	jr z, StartPancakeBurst
	ld a, 12
	ld [PancakeHitFlashTimer], a
	call StartPancakeKnockback
	ret

StartPancakeBurst:
	xor a
	ld [PancakeBurstTimer], a
	ld [PancakeHitFlashTimer], a
	ld a, ENEMY_BURST_FIRST_TILE
	ld [PancakeTileBase], a
	ld a, PANCAKE_STATE_BURST
	ld [PancakeState], a
	ret

StartPancakeKnockback:
	ld a, PANCAKE_HIT_KNOCKBACK_DISTANCE
	ld [PancakeKnockbackRemaining], a
	ld a, [PancakeX]
	add a, 8
	ld l, a
	ld a, [PancakeX + 1]
	adc a, 0
	ld h, a
	ld a, [PlayerX]
	add a, 6
	ld e, a
	ld a, [PlayerX + 1]
	adc a, 0
	ld d, a
	ld a, l
	sub a, e
	ld l, a
	ld a, h
	sbc a, d
	ld h, a
	bit 7, h
	jr nz, .left
	ld a, 1
	jr .store
.left
	ld a, -1
.store
	ld [PancakeKnockbackDirection], a
	ld [PancakeDirection], a
	ret

ApplyPancakeKnockback:
	ld a, [PancakeKnockbackDirection]
	bit 7, a
	jr nz, .left
	call PancakeWallRight
	jr z, .blocked
	ld hl, PancakeX
	inc [hl]
	jr nz, .moved
	inc hl
	inc [hl]
	jr .moved
.left
	call PancakeWallLeft
	jr z, .blocked
	ld hl, PancakeX
	ld a, [hl]
	and a
	jr nz, .decrementLow
	inc hl
	dec [hl]
	dec hl
.decrementLow
	dec [hl]
.moved
	ld hl, PancakeKnockbackRemaining
	dec [hl]
	ret
.blocked
	xor a
	ld [PancakeKnockbackRemaining], a
	ret

CheckPancakeAttackX:
	ld a, [AttackPanTileBase]
	cp a, PAN_ATTACK_WINDUP_TILE
	jp z, CheckPancakeCloseX
	ld a, [FacingFlip]
	and a
	jr nz, .left
	ld a, [PancakeX]
	add a, 8
	ld l, a
	ld a, [PancakeX + 1]
	adc a, 0
	ld h, a
	ld a, [PlayerX]
	ld e, a
	ld a, [PlayerX + 1]
	ld d, a
	jr .compare
.left
	ld a, [PlayerX]
	ld l, a
	ld a, [PlayerX + 1]
	ld h, a
	ld a, [PancakeX]
	add a, 8
	ld e, a
	ld a, [PancakeX + 1]
	adc a, 0
	ld d, a
.compare
	ld a, l
	sub a, e
	ld l, a
	ld a, h
	sbc a, d
	ld h, a
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

CheckPancakeCloseX:
	ld a, [PancakeX]
	add a, 8
	ld l, a
	ld a, [PancakeX + 1]
	adc a, 0
	ld h, a
	ld a, [PlayerX]
	add a, 6
	ld e, a
	ld a, [PlayerX + 1]
	adc a, 0
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
	inc a
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

CheckPancakeAttackY:
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
	jr .boundsReady
.checkStrike
	cp a, PAN_ATTACK_STRIKE_TILE
	jr nz, .recovery
	ld a, b
	sub a, 16
	ld b, a
	jr .boundsReady
.recovery
	ld a, b
	sub a, 8
	ld b, a
.boundsReady
	ld a, [PancakeY]
	add a, 7
	cp a, b
	jr c, .miss
	ld a, [PancakeY]
	ld d, a
	ld a, c
	cp a, d
	jr c, .miss
	scf
	ret
.miss
	and a
	ret

TryPancakeContacts:
	xor a
	ld [PancakeLoopIndex], a
.loop
	ld a, [PancakeLoopIndex]
	ld b, a
	ld a, [PancakeCount]
	cp a, b
	ret z
	ld a, b
	push af
	call LoadPancakeRecord
	call TryPancakeContact
	pop af
	push af
	call StorePancakeRecord
	pop af
	inc a
	ld [PancakeLoopIndex], a
	jr .loop

TryPancakeContact:
	ld a, [PancakeState]
	cp a, PANCAKE_STATE_ACTIVE
	ret nz
	ld a, [PlayerInvulnerabilityTimer]
	and a
	ret nz
	call CheckPancakeCloseX
	ret nc
	ld a, [PlayerY]
	dec a
	ld b, a
	ld a, [PancakeY]
	ld c, a
	ld a, b
	cp a, c
	jr c, .miss
	ld a, [PancakeY]
	add a, 7
	ld c, a
	ld a, [PlayerY]
	sub a, PLAYER_HITBOX_TOP
	ld b, a
	ld a, c
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
	add a, 6
	ld l, a
	ld a, [PlayerX + 1]
	adc a, 0
	ld h, a
	ld a, [PancakeX]
	add a, 8
	ld e, a
	ld a, [PancakeX + 1]
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

UpdatePancakeSprites:
	ld a, [BurgerOAMPointer]
	ld [PancakeOAMPointer], a
	ld a, [BurgerOAMPointer + 1]
	ld [PancakeOAMPointer + 1], a
	xor a
	ld [PancakeLoopIndex], a
.loop
	ld a, [PancakeLoopIndex]
	ld b, a
	ld a, [PancakeCount]
	cp a, b
	jr z, HideUnusedPancakeSprites
	ld a, b
	push af
	call LoadPancakeRecord
	call UpdatePancakeSprite
	pop af
	inc a
	ld [PancakeLoopIndex], a
	ld a, [PancakeOAMPointer]
	add a, 16
	ld [PancakeOAMPointer], a
	jr nc, .loop
	ld hl, PancakeOAMPointer + 1
	inc [hl]
	jr .loop

HideUnusedPancakeSprites:
	ld a, [PancakeCount]
	ld b, a
	ld a, PANCAKE_MAX_COUNT
	sub a, b
	ret z
	ld b, a
	ld a, [PancakeOAMPointer]
	ld l, a
	ld a, [PancakeOAMPointer + 1]
	ld h, a
	xor a
.block
	ld [hl], a
	ld de, 4
	add hl, de
	ld [hl], a
	add hl, de
	ld [hl], a
	add hl, de
	ld [hl], a
	add hl, de
	dec b
	jr nz, .block
	ret

UpdatePancakeSprite:
	ld a, [PancakeOAMPointer]
	ld l, a
	ld a, [PancakeOAMPointer + 1]
	ld h, a
	ld a, [PancakeState]
	and a
	jp z, HidePancakeSprite
	ld a, [PancakeHitFlashTimer]
	bit 1, a
	jp nz, HidePancakeSprite
	ld a, [PancakeX + 1]
	ld d, a
	ld a, [CameraX + 1]
	cp a, d
	jr c, .leftEdgeClear
	jp nz, HidePancakeSprite
	ld a, [PancakeX]
	ld e, a
	ld a, [CameraX]
	cp a, e
	jr z, .leftEdgeClear
	jp nc, HidePancakeSprite
.leftEdgeClear
	ld a, [CameraX]
	add a, 160
	ld e, a
	ld a, [CameraX + 1]
	adc a, 0
	ld d, a
	ld a, [PancakeX]
	add a, 16
	ld c, a
	ld a, [PancakeX + 1]
	adc a, 0
	cp a, d
	jr c, .vertical
	jp nz, HidePancakeSprite
	ld a, c
	cp a, e
	jr c, .vertical
	jp nz, HidePancakeSprite
.vertical
	ld a, [PancakeY]
	add a, 8
	jr c, .bottomEdge
	ld e, a
	ld a, [CameraY]
	cp a, e
	jp nc, HidePancakeSprite
.bottomEdge
	ld a, [CameraY]
	add a, 144
	jr c, .visible
	ld e, a
	ld a, [PancakeY]
	cp a, e
	jp nc, HidePancakeSprite
.visible
	ld a, [PancakeState]
	cp a, PANCAKE_STATE_BURST
	jp z, UpdatePancakeBurstSprite
	ld a, [CameraY]
	ld b, a
	ld a, [CameraX]
	ld c, a
	ld a, [PancakeY]
	add a, 16
	sub a, b
	ld [hl+], a
	ld a, [PancakeX]
	add a, 8
	sub a, c
	ld [hl+], a
	ld a, [PancakeTileBase]
	ld [hl+], a
	xor a
	ld [hl+], a
	ld a, [PancakeY]
	add a, 16
	sub a, b
	ld [hl+], a
	ld a, [PancakeX]
	add a, 16
	sub a, c
	ld [hl+], a
	ld a, [PancakeTileBase]
	inc a
	ld [hl+], a
	xor a
	ld [hl+], a
	ld de, 4
	add hl, de
	ld [hl], a
	add hl, de
	ld [hl], a
	ret

UpdatePancakeBurstSprite:
	ld a, [CameraY]
	ld b, a
	ld a, [CameraX]
	ld c, a
	ld a, [PancakeY]
	add a, 12
	sub a, b
	ld d, a
	ld a, [PancakeX]
	add a, 8
	sub a, c
	ld e, a
	ld a, d
	ld [hl+], a
	ld a, e
	ld [hl+], a
	ld a, [PancakeTileBase]
	ld [hl+], a
	xor a
	ld [hl+], a
	ld a, d
	ld [hl+], a
	ld a, e
	add a, 8
	ld [hl+], a
	ld a, [PancakeTileBase]
	inc a
	ld [hl+], a
	xor a
	ld [hl+], a
	ld a, d
	add a, 8
	ld [hl+], a
	ld a, e
	ld [hl+], a
	ld a, [PancakeTileBase]
	add a, 2
	ld [hl+], a
	xor a
	ld [hl+], a
	ld a, d
	add a, 8
	ld [hl+], a
	ld a, e
	add a, 8
	ld [hl+], a
	ld a, [PancakeTileBase]
	add a, 3
	ld [hl+], a
	xor a
	ld [hl], a
	ret

HidePancakeSprite:
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

SECTION "FRIED_EGG Runtime", ROMX
ClearFriedEggRecords:
	ld hl, FriedEggY
	ld b, FRIED_EGG_RECORD_SIZE
	xor a
.clearScratch
	ld [hl+], a
	dec b
	jr nz, .clearScratch
	ld hl, FriedEggRecords
	ld b, FRIED_EGG_MAX_COUNT * FRIED_EGG_RECORD_SIZE
.clearRecords
	ld [hl+], a
	dec b
	jr nz, .clearRecords
	ld [FriedEggCount], a
	ret

GetFriedEggRecordPointer:
	ld hl, FriedEggRecords
	and a
	ret z
	ld de, FRIED_EGG_RECORD_SIZE
.advance
	add hl, de
	dec a
	jr nz, .advance
	ret

LoadFriedEggRecord:
	call GetFriedEggRecordPointer
	ld de, FriedEggY
	ld b, FRIED_EGG_RECORD_SIZE
.copy
	ld a, [hl+]
	ld [de], a
	inc de
	dec b
	jr nz, .copy
	ret

StoreFriedEggRecord:
	call GetFriedEggRecordPointer
	ld de, FriedEggY
	ld b, FRIED_EGG_RECORD_SIZE
.copy
	ld a, [de]
	inc de
	ld [hl+], a
	dec b
	jr nz, .copy
	ret

IF DEF(FRIED_EGG_PLAYTEST)
InitializePlaytestFriedEgg:
	ld a, FRIED_EGG_PLAYTEST_EGG_Y
	ld [FriedEggY], a
	ld a, LOW(FRIED_EGG_PLAYTEST_EGG_X)
	ld [FriedEggX], a
	ld a, HIGH(FRIED_EGG_PLAYTEST_EGG_X)
	ld [FriedEggX + 1], a
	xor a
	ld [FriedEggVelY], a
	ld [FriedEggTimer], a
	ld [FriedEggAnimTimer], a
	ld [FriedEggFractionX], a
	ld [FriedEggTurnCommitment], a
	ld [FriedEggHitThisSwing], a
	ld [FriedEggHitFlashTimer], a
	ld [FriedEggKnockbackRemaining], a
	ld [FriedEggKnockbackDirection], a
	ld [FriedEggStunTimer], a
	ld a, -1
	ld [FriedEggDirection], a
	ld [FriedEggTargetDirection], a
	ld a, -FRIED_EGG_MAX_HORIZONTAL_VELOCITY
	ld [FriedEggVelocityX], a
	ld a, FRIED_EGG_STATE_GROUNDED
	ld [FriedEggState], a
	ld a, FRIED_EGG_IDLE_TILE
	ld [FriedEggTileBase], a
	ld a, 3
	ld [FriedEggHealth], a
	xor a
	call StoreFriedEggRecord
	ld a, 1
	ld [FriedEggCount], a
	ret
ENDC

ResetFriedEggHitLatches:
	ld hl, FriedEggRecords + FRIED_EGG_RECORD_HIT_LATCH
	ld de, FRIED_EGG_RECORD_SIZE
	ld b, FRIED_EGG_MAX_COUNT
	xor a
.loop
	ld [hl], a
	add hl, de
	dec b
	jr nz, .loop
	ret

AdvanceFriedEggs:
	xor a
	ld [FriedEggLoopIndex], a
.loop
	ld a, [FriedEggLoopIndex]
	ld b, a
	ld a, [FriedEggCount]
	cp a, b
	ret z
	ld a, b
	push af
	call LoadFriedEggRecord
	call AdvanceFriedEgg
	pop af
	push af
	call StoreFriedEggRecord
	pop af
	inc a
	ld [FriedEggLoopIndex], a
	jr .loop

AdvanceFriedEgg:
	ld a, [FriedEggState]
	and a
	ret z
	ld hl, FriedEggHitFlashTimer
	ld a, [hl]
	and a
	jr z, .state
	dec [hl]
.state
	ld a, [FriedEggState]
	cp a, FRIED_EGG_STATE_BURST
	jp z, AdvanceFriedEggBurst
	ld a, [FriedEggKnockbackRemaining]
	and a
	jp nz, ApplyFriedEggKnockback
	ld a, [FriedEggStunTimer]
	and a
	jp nz, AdvanceStunnedFriedEgg
	ld a, [FriedEggState]
	cp a, FRIED_EGG_STATE_AIRBORNE
	jp z, AdvanceFriedEggAirborne
	cp a, FRIED_EGG_STATE_LANDING
	jp z, AdvanceFriedEggLanding
	call FriedEggSupportBelow
	jp nz, StartFriedEggFall
	call AnimateGroundedFriedEgg
	call FriedEggPlayerSameLevel
	jr c, .pursue
	call BrakeFriedEggVelocity
	jp AdvanceFriedEggHorizontal
.pursue
	call ChooseFriedEggDirection
	jp AdvanceFriedEggHorizontal

AdvanceStunnedFriedEgg:
	ld hl, FriedEggStunTimer
	dec [hl]
	ld a, [FriedEggState]
	cp a, FRIED_EGG_STATE_AIRBORNE
	jp z, AdvanceFriedEggAirborne
	cp a, FRIED_EGG_STATE_LANDING
	jp z, AdvanceFriedEggLanding
	call FriedEggSupportBelow
	jp nz, StartFriedEggFall
	ret

AnimateGroundedFriedEgg:
	ld hl, FriedEggAnimTimer
	inc [hl]
	ld a, [hl]
	cp a, FRIED_EGG_FRAME_DURATION
	ret c
	xor a
	ld [hl], a
	ld a, [FriedEggTileBase]
	cp a, FRIED_EGG_IDLE_TILE
	ld a, FRIED_EGG_IDLE_TILE
	jr nz, .store
	ld a, FRIED_EGG_STEP_TILE
.store
	ld [FriedEggTileBase], a
	ret

AdvanceFriedEggBurst:
	ld hl, FriedEggTimer
	inc [hl]
	ld a, [hl]
	cp a, ENEMY_BURST_DURATION
	jr nc, .finished
	and a, ENEMY_BURST_FRAME_DURATION - 1
	ret nz
	ld hl, FriedEggTileBase
	ld a, [hl]
	add a, 4
	ld [hl], a
	ret
.finished
	xor a
	ld [FriedEggState], a
	ret

FriedEggPlayerSameLevel:
	ld a, [PlayerY]
	ld b, a
	ld a, [FriedEggY]
	sub a, b
	jr nc, .absoluteReady
	cpl
	inc a
.absoluteReady
	cp a, FRIED_EGG_LEVEL_TOLERANCE + 1
	ret

ChooseFriedEggDirection:
	ld a, [PlayerX]
	add a, 6
	ld e, a
	ld a, [PlayerX + 1]
	adc a, 0
	ld d, a
	ld a, [FriedEggX]
	add a, 8
	ld l, a
	ld a, [FriedEggX + 1]
	adc a, 0
	ld h, a
	ld a, e
	sub a, l
	ld a, d
	sbc a, h
	bit 7, a
	ld b, -1
	jr nz, SetFriedEggTargetDirection
.right
	ld b, 1

SetFriedEggTargetDirection:
	ld a, [FriedEggTargetDirection]
	cp a, b
	jr z, .continueTurn
	ld a, b
	ld [FriedEggTargetDirection], a
	ld a, [FriedEggVelocityX]
	and a
	jr z, .accelerate
	xor a, b
	bit 7, a
	jr z, .accelerate
	ld a, FRIED_EGG_TURN_COMMITMENT - 1
	ld [FriedEggTurnCommitment], a
	ret
.continueTurn
	ld hl, FriedEggTurnCommitment
	ld a, [hl]
	and a
	jr z, .accelerate
	dec [hl]
	ret
.accelerate
	ld a, b
	ld b, a
	jr AccelerateFriedEggVelocity

AccelerateFriedEggVelocity:
	bit 7, b
	jr nz, .left
	ld a, [FriedEggVelocityX]
	add a, FRIED_EGG_HORIZONTAL_ACCELERATION
	bit 7, a
	jr nz, .store
	cp a, FRIED_EGG_MAX_HORIZONTAL_VELOCITY + 1
	jr c, .store
	ld a, FRIED_EGG_MAX_HORIZONTAL_VELOCITY
	jr .store
.left
	ld a, [FriedEggVelocityX]
	sub a, FRIED_EGG_HORIZONTAL_ACCELERATION
	bit 7, a
	jr z, .store
	cp a, -FRIED_EGG_MAX_HORIZONTAL_VELOCITY
	jr nc, .store
	ld a, -FRIED_EGG_MAX_HORIZONTAL_VELOCITY
.store
	ld [FriedEggVelocityX], a
	and a
	ret z
	bit 7, a
	ld a, 1
	jr z, .storeDirection
	ld a, -1
.storeDirection
	ld [FriedEggDirection], a
	ret

BrakeFriedEggVelocity:
	xor a
	ld [FriedEggTurnCommitment], a
	ld a, [FriedEggVelocityX]
	and a
	ret z
	bit 7, a
	jr nz, .negative
	sub a, FRIED_EGG_HORIZONTAL_ACCELERATION
	jr nc, .store
	xor a
	jr .store
.negative
	add a, FRIED_EGG_HORIZONTAL_ACCELERATION
	bit 7, a
	jr nz, .store
	xor a
.store
	ld [FriedEggVelocityX], a
	ret

AdvanceFriedEggHorizontal:
	ld a, [FriedEggVelocityX]
	and a
	ret z
	bit 7, a
	jr nz, .left
	ld b, a
	ld a, [FriedEggFractionX]
	add a, b
	cp a, 16
	jr nc, .moveRight
	ld [FriedEggFractionX], a
	ret
.moveRight
	sub a, 16
	ld [FriedEggFractionX], a
	jp MoveFriedEggHorizontal
.left
	cpl
	inc a
	ld b, a
	ld a, [FriedEggFractionX]
	sub a, b
	jr c, .moveLeft
	ld [FriedEggFractionX], a
	ret
.moveLeft
	add a, 16
	ld [FriedEggFractionX], a
	jp MoveFriedEggHorizontal

StartFriedEggFall:
	xor a
	ld [FriedEggVelY], a
	jr StartFriedEggAirborne

StartFriedEggJump:
	ld a, FRIED_EGG_LAUNCH_VELOCITY
	ld [FriedEggVelY], a
StartFriedEggAirborne:
	ld a, FRIED_EGG_STATE_AIRBORNE
	ld [FriedEggState], a
	ld a, FRIED_EGG_AIRBORNE_TILE
	ld [FriedEggTileBase], a
	ret

AdvanceFriedEggAirborne:
	ld hl, FriedEggVelY
	ld a, [hl]
	inc a
	bit 7, a
	jr nz, .storeVelocity
	cp a, FRIED_EGG_TERMINAL_VELOCITY + 1
	jr c, .storeVelocity
	ld a, FRIED_EGG_TERMINAL_VELOCITY
.storeVelocity
	ld [hl], a
	and a
	jp z, AdvanceFriedEggHorizontal
	bit 7, a
	jr nz, .rising
	ld b, a
.fallStep
	call FriedEggSupportBelow
	jr z, StartFriedEggLanding
	ld hl, FriedEggY
	inc [hl]
	dec b
	jr nz, .fallStep
	jp AdvanceFriedEggHorizontal
.rising
	cpl
	inc a
	ld b, a
.riseStep
	call FriedEggCeilingAbove
	jr z, .headBump
	ld hl, FriedEggY
	dec [hl]
	dec b
	jr nz, .riseStep
	jp AdvanceFriedEggHorizontal
.headBump
	xor a
	ld [FriedEggVelY], a
	jp AdvanceFriedEggHorizontal

StartFriedEggLanding:
	ld hl, FriedEggY
	inc [hl]
	xor a
	ld [FriedEggVelY], a
	ld [FriedEggTimer], a
	ld a, FRIED_EGG_STATE_LANDING
	ld [FriedEggState], a
	ld a, FRIED_EGG_LANDING_TILE
	ld [FriedEggTileBase], a
	ret

AdvanceFriedEggLanding:
	ld hl, FriedEggTimer
	inc [hl]
	ld a, [hl]
	cp a, FRIED_EGG_LANDING_DURATION
	ret c
	xor a
	ld [FriedEggTimer], a
	ld [FriedEggAnimTimer], a
	ld a, FRIED_EGG_STATE_GROUNDED
	ld [FriedEggState], a
	ld a, FRIED_EGG_IDLE_TILE
	ld [FriedEggTileBase], a
	ret

MoveFriedEggHorizontal:
	ld a, [FriedEggDirection]
	bit 7, a
	jr nz, .left
	call FriedEggWallRight
	jr z, .blocked
	ld hl, FriedEggX
	inc [hl]
	ret nz
	inc hl
	inc [hl]
	ret
.left
	call FriedEggWallLeft
	jr z, .blocked
	ld hl, FriedEggX
	ld a, [hl]
	and a
	jr nz, .decrementLow
	inc hl
	dec [hl]
	dec hl
.decrementLow
	dec [hl]
	ret
.blocked
	ld a, [FriedEggState]
	cp a, FRIED_EGG_STATE_AIRBORNE
	ret z
	call FriedEggForwardTopBlocked
	jp nz, StartFriedEggJump
	xor a
	ld [FriedEggVelocityX], a
	ld [FriedEggFractionX], a
	ld [FriedEggTurnCommitment], a
	ret

FriedEggForwardTopBlocked:
	ld a, [FriedEggDirection]
	bit 7, a
	jr nz, .left
	ld a, [FriedEggX]
	add a, 16
	ld e, a
	ld a, [FriedEggX + 1]
	adc a, 0
	jr .probe
.left
	ld a, [FriedEggX]
	sub a, 1
	ld e, a
	ld a, [FriedEggX + 1]
	sbc a, 0
.probe
	ld c, a
	ld a, [FriedEggY]
	sub a, 15
	ld d, a
	jp IsWall

FriedEggWallRight:
	ld a, [FriedEggX]
	add a, 16
	ld e, a
	ld a, [FriedEggX + 1]
	adc a, 0
	ld c, a
	ld a, [FriedEggY]
	sub a, 15
	ld d, a
	call IsWall
	ret z
	ld a, [FriedEggX]
	add a, 16
	ld e, a
	ld a, [FriedEggX + 1]
	adc a, 0
	ld c, a
	ld a, [FriedEggY]
	sub a, 8
	ld d, a
	call IsWall
	ret z
	ld a, [FriedEggX]
	add a, 16
	ld e, a
	ld a, [FriedEggX + 1]
	adc a, 0
	ld c, a
	ld a, [FriedEggY]
	dec a
	ld d, a
	jp IsWall

FriedEggWallLeft:
	ld a, [FriedEggX]
	sub a, 1
	ld e, a
	ld a, [FriedEggX + 1]
	sbc a, 0
	ld c, a
	ld a, [FriedEggY]
	sub a, 15
	ld d, a
	call IsWall
	ret z
	ld a, [FriedEggX]
	sub a, 1
	ld e, a
	ld a, [FriedEggX + 1]
	sbc a, 0
	ld c, a
	ld a, [FriedEggY]
	sub a, 8
	ld d, a
	call IsWall
	ret z
	ld a, [FriedEggX]
	sub a, 1
	ld e, a
	ld a, [FriedEggX + 1]
	sbc a, 0
	ld c, a
	ld a, [FriedEggY]
	dec a
	ld d, a
	jp IsWall

FriedEggCeilingAbove:
	ld a, [FriedEggX]
	add a, 1
	ld e, a
	ld a, [FriedEggX + 1]
	adc a, 0
	ld c, a
	ld a, [FriedEggY]
	sub a, 16
	ld d, a
	call IsWall
	ret z
	ld a, [FriedEggX]
	add a, 14
	ld e, a
	ld a, [FriedEggX + 1]
	adc a, 0
	ld c, a
	ld a, [FriedEggY]
	sub a, 16
	ld d, a
	jp IsWall

FriedEggSupportBelow:
	ld a, [FriedEggX]
	add a, 1
	ld e, a
	ld a, [FriedEggX + 1]
	adc a, 0
	ld c, a
	ld a, [FriedEggY]
	inc a
	ld d, a
	call IsSupport
	ret z
	ld a, [FriedEggX]
	add a, 14
	ld e, a
	ld a, [FriedEggX + 1]
	adc a, 0
	ld c, a
	ld a, [FriedEggY]
	inc a
	ld d, a
	jp IsSupport

TryPanHitFriedEggs:
	xor a
	ld [FriedEggLoopIndex], a
.loop
	ld a, [FriedEggLoopIndex]
	ld b, a
	ld a, [FriedEggCount]
	cp a, b
	ret z
	ld a, b
	push af
	call LoadFriedEggRecord
	call TryPanHitFriedEgg
	pop af
	push af
	call StoreFriedEggRecord
	pop af
	inc a
	ld [FriedEggLoopIndex], a
	jr .loop

TryPanHitFriedEgg:
	ld a, [FriedEggState]
	and a
	ret z
	cp a, FRIED_EGG_STATE_BURST
	ret z
	ld a, [FriedEggHitThisSwing]
	and a
	ret nz
	ld a, [AttackTimer]
	and a
	ret z
	ld a, [AttackPanTileBase]
	and a
	ret z
	call CheckFriedEggAttackX
	ret nc
	call CheckFriedEggAttackY
	ret nc
	ld a, 1
	ld [FriedEggHitThisSwing], a
	ld hl, FriedEggHealth
	dec [hl]
	jp z, StartFriedEggBurst
	ld a, 12
	ld [FriedEggHitFlashTimer], a
	call StartFriedEggKnockback
	ret

StartFriedEggKnockback:
	ld a, FRIED_EGG_HIT_KNOCKBACK_DISTANCE
	ld [FriedEggKnockbackRemaining], a
	ld a, [FriedEggX]
	add a, 8
	ld l, a
	ld a, [FriedEggX + 1]
	adc a, 0
	ld h, a
	ld a, [PlayerX]
	add a, 6
	ld e, a
	ld a, [PlayerX + 1]
	adc a, 0
	ld d, a
	ld a, l
	sub a, e
	ld l, a
	ld a, h
	sbc a, d
	ld h, a
	bit 7, h
	jr nz, .left
	ld a, 1
	jr .store
.left
	ld a, -1
.store
	ld [FriedEggKnockbackDirection], a
	ld [FriedEggDirection], a
	bit 7, a
	ld a, FRIED_EGG_MAX_HORIZONTAL_VELOCITY
	jr z, .storeVelocity
	ld a, -FRIED_EGG_MAX_HORIZONTAL_VELOCITY
.storeVelocity
	ld [FriedEggVelocityX], a
	xor a
	ld [FriedEggFractionX], a
	ld [FriedEggTurnCommitment], a
	ret

ApplyFriedEggKnockback:
	ld a, [FriedEggKnockbackDirection]
	bit 7, a
	jr nz, .left
	call FriedEggWallRight
	jr z, .blocked
	ld hl, FriedEggX
	inc [hl]
	jr nz, .moved
	inc hl
	inc [hl]
	jr .moved
.left
	call FriedEggWallLeft
	jr z, .blocked
	ld hl, FriedEggX
	ld a, [hl]
	and a
	jr nz, .decrementLow
	inc hl
	dec [hl]
	dec hl
.decrementLow
	dec [hl]
.moved
	ld hl, FriedEggKnockbackRemaining
	dec [hl]
	ret nz
	jr FinishFriedEggKnockback
.blocked
	xor a
	ld [FriedEggKnockbackRemaining], a

FinishFriedEggKnockback:
	xor a
	ld [FriedEggVelocityX], a
	ld [FriedEggFractionX], a
	ld [FriedEggTurnCommitment], a
	ld a, FRIED_EGG_HIT_STUN_DURATION
	ld [FriedEggStunTimer], a
	ret

StartFriedEggBurst:
	xor a
	ld [FriedEggTimer], a
	ld [FriedEggHitFlashTimer], a
	ld a, ENEMY_BURST_FIRST_TILE
	ld [FriedEggTileBase], a
	ld a, FRIED_EGG_STATE_BURST
	ld [FriedEggState], a
	ret

CheckFriedEggAttackX:
	ld a, [AttackPanTileBase]
	cp a, PAN_ATTACK_WINDUP_TILE
	jp z, CheckFriedEggCloseX
	ld a, [FacingFlip]
	and a
	jr nz, .left
	ld a, [FriedEggX]
	add a, 8
	ld l, a
	ld a, [FriedEggX + 1]
	adc a, 0
	ld h, a
	ld a, [PlayerX]
	ld e, a
	ld a, [PlayerX + 1]
	ld d, a
	jr .compare
.left
	ld a, [PlayerX]
	ld l, a
	ld a, [PlayerX + 1]
	ld h, a
	ld a, [FriedEggX]
	add a, 8
	ld e, a
	ld a, [FriedEggX + 1]
	adc a, 0
	ld d, a
.compare
	ld a, l
	sub a, e
	ld l, a
	ld a, h
	sbc a, d
	ld h, a
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

CheckFriedEggCloseX:
	ld a, [FriedEggX]
	add a, 8
	ld l, a
	ld a, [FriedEggX + 1]
	adc a, 0
	ld h, a
	ld a, [PlayerX]
	add a, 6
	ld e, a
	ld a, [PlayerX + 1]
	adc a, 0
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
	inc a
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

CheckFriedEggAttackY:
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
	jr .boundsReady
.checkStrike
	cp a, PAN_ATTACK_STRIKE_TILE
	jr nz, .recovery
	ld a, b
	sub a, 16
	ld b, a
	jr .boundsReady
.recovery
	ld a, b
	sub a, 8
	ld b, a
.boundsReady
	ld a, [FriedEggY]
	dec a
	cp a, b
	jr c, .miss
	ld a, [FriedEggY]
	sub a, 16
	ld d, a
	ld a, c
	cp a, d
	jr c, .miss
	scf
	ret
.miss
	and a
	ret

TryFriedEggContacts:
	xor a
	ld [FriedEggLoopIndex], a
.loop
	ld a, [FriedEggLoopIndex]
	ld b, a
	ld a, [FriedEggCount]
	cp a, b
	ret z
	ld a, b
	push af
	call LoadFriedEggRecord
	call TryFriedEggContact
	pop af
	push af
	call StoreFriedEggRecord
	pop af
	inc a
	ld [FriedEggLoopIndex], a
	jr .loop

TryFriedEggContact:
	ld a, [FriedEggState]
	and a
	ret z
	cp a, FRIED_EGG_STATE_BURST
	ret z
	ld a, [PlayerInvulnerabilityTimer]
	and a
	ret nz
	call CheckFriedEggContactX
	ret nc
	ld a, [PlayerY]
	dec a
	ld b, a
	ld a, [FriedEggY]
	sub a, 16
	ld c, a
	ld a, b
	cp a, c
	jr c, .miss
	ld a, [PlayerY]
	sub a, PLAYER_HITBOX_TOP
	ld b, a
	ld a, [FriedEggY]
	dec a
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
	add a, 6
	ld l, a
	ld a, [PlayerX + 1]
	adc a, 0
	ld h, a
	ld a, [FriedEggX]
	add a, 8
	ld e, a
	ld a, [FriedEggX + 1]
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

CheckFriedEggContactX:
	ld a, [PlayerX]
	add a, PLAYER_HITBOX_RIGHT
	ld l, a
	ld a, [PlayerX + 1]
	adc a, 0
	ld h, a
	ld a, [FriedEggX]
	add a, 7
	ld e, a
	ld a, [FriedEggX + 1]
	adc a, 0
	ld d, a
	ld a, l
	sub a, e
	ld a, h
	sbc a, d
	bit 7, a
	jr nz, .miss
	ld a, [FriedEggX]
	add a, 8
	ld l, a
	ld a, [FriedEggX + 1]
	adc a, 0
	ld h, a
	ld a, [PlayerX]
	sub a, PLAYER_HITBOX_LEFT
	ld e, a
	ld a, [PlayerX + 1]
	sbc a, 0
	ld d, a
	ld a, l
	sub a, e
	ld a, h
	sbc a, d
	bit 7, a
	jr nz, .miss
	scf
	ret
.miss
	and a
	ret

UpdateFriedEggSprites:
	ld a, [PancakeOAMPointer]
	ld [FriedEggOAMPointer], a
	ld a, [PancakeOAMPointer + 1]
	ld [FriedEggOAMPointer + 1], a
	xor a
	ld [FriedEggLoopIndex], a
.loop
	ld a, [FriedEggLoopIndex]
	ld b, a
	ld a, [FriedEggCount]
	cp a, b
	jr z, HideUnusedFriedEggSprites
	ld a, b
	push af
	call LoadFriedEggRecord
	call UpdateFriedEggSprite
	pop af
	inc a
	ld [FriedEggLoopIndex], a
	ld a, [FriedEggOAMPointer]
	add a, 16
	ld [FriedEggOAMPointer], a
	jr nc, .loop
	ld hl, FriedEggOAMPointer + 1
	inc [hl]
	jr .loop

HideUnusedFriedEggSprites:
	ld a, [FriedEggCount]
	ld b, a
	ld a, FRIED_EGG_MAX_COUNT
	sub a, b
	ret z
	ld b, a
	ld a, [FriedEggOAMPointer]
	ld l, a
	ld a, [FriedEggOAMPointer + 1]
	ld h, a
	xor a
.block
	ld [hl], a
	ld de, 4
	add hl, de
	ld [hl], a
	add hl, de
	ld [hl], a
	add hl, de
	ld [hl], a
	add hl, de
	dec b
	jr nz, .block
	ret

UpdateFriedEggSprite:
	ld a, [FriedEggOAMPointer]
	ld l, a
	ld a, [FriedEggOAMPointer + 1]
	ld h, a
	ld a, [FriedEggState]
	and a
	jp z, HideFriedEggSprite
	ld a, [FriedEggHitFlashTimer]
	bit 1, a
	jp nz, HideFriedEggSprite
	ld a, [FriedEggState]
	cp a, FRIED_EGG_STATE_BURST
	jp z, UpdateFriedEggBurstSprite
	ld a, [CameraY]
	ld b, a
	ld a, [CameraX]
	ld c, a
	ld a, [FriedEggDirection]
	bit 7, a
	ld d, 0
	jr z, .attributesReady
	ld d, $20
.attributesReady
	ld a, [FriedEggY]
	sub a, b
	inc a
	ld e, a
	ld a, [FriedEggX]
	add a, 8
	sub a, c
	ld c, a
	ld a, e
	ld [hl+], a
	ld a, c
	ld [hl+], a
	ld a, [FriedEggTileBase]
	ld b, a
	ld a, d
	and a
	ld a, b
	jr z, .topLeftReady
	inc a
.topLeftReady
	ld [hl+], a
	ld a, d
	ld [hl+], a
	ld a, e
	ld [hl+], a
	ld a, c
	add a, 8
	ld [hl+], a
	ld a, [FriedEggTileBase]
	ld b, a
	ld a, d
	and a
	ld a, b
	jr nz, .topRightReady
	inc a
.topRightReady
	ld [hl+], a
	ld a, d
	ld [hl+], a
	ld a, e
	add a, 8
	ld [hl+], a
	ld a, c
	ld [hl+], a
	ld a, [FriedEggTileBase]
	add a, 2
	ld b, a
	ld a, d
	and a
	ld a, b
	jr z, .bottomLeftReady
	inc a
.bottomLeftReady
	ld [hl+], a
	ld a, d
	ld [hl+], a
	ld a, e
	add a, 8
	ld [hl+], a
	ld a, c
	add a, 8
	ld [hl+], a
	ld a, [FriedEggTileBase]
	add a, 2
	ld b, a
	ld a, d
	and a
	ld a, b
	jr nz, .bottomRightReady
	inc a
.bottomRightReady
	ld [hl+], a
	ld a, d
	ld [hl], a
	ret

UpdateFriedEggBurstSprite:
	ld a, [CameraY]
	ld b, a
	ld a, [CameraX]
	ld c, a
	ld a, [FriedEggY]
	add a, 4
	sub a, b
	ld d, a
	ld a, [FriedEggX]
	add a, 8
	sub a, c
	ld e, a
	ld a, d
	ld [hl+], a
	ld a, e
	ld [hl+], a
	ld a, [FriedEggTileBase]
	ld [hl+], a
	xor a
	ld [hl+], a
	ld a, d
	ld [hl+], a
	ld a, e
	add a, 8
	ld [hl+], a
	ld a, [FriedEggTileBase]
	inc a
	ld [hl+], a
	xor a
	ld [hl+], a
	ld a, d
	add a, 8
	ld [hl+], a
	ld a, e
	ld [hl+], a
	ld a, [FriedEggTileBase]
	add a, 2
	ld [hl+], a
	xor a
	ld [hl+], a
	ld a, d
	add a, 8
	ld [hl+], a
	ld a, e
	add a, 8
	ld [hl+], a
	ld a, [FriedEggTileBase]
	add a, 3
	ld [hl+], a
	xor a
	ld [hl], a
	ret

HideFriedEggSprite:
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

EnemyBurstTiles:
	INCBIN "build/enemy_cloudburst.2bpp"

BurgerTiles:
	INCBIN "build/burger_motion.2bpp"

PancakeTiles:
	INCBIN "build/pancake_motion.2bpp"

FriedEggTiles:
	INCBIN "build/fried_egg_motion.2bpp"

IF DEF(COMBAT_PLAYTEST)
CombatPlaytestMap:
	INCBIN "build/combat_playtest.tilemap"
CombatPlaytestMapEnd:
ASSERT CombatPlaytestMapEnd - CombatPlaytestMap == LEVEL_WIDTH_TILES * LEVEL_HEIGHT_TILES
ENDC

IF DEF(BURGER_PLAYTEST)
BurgerPlaytestMap:
	INCBIN "build/burger_playtest.tilemap"
BurgerPlaytestMapEnd:
ASSERT BurgerPlaytestMapEnd - BurgerPlaytestMap == LEVEL_WIDTH_TILES * LEVEL_HEIGHT_TILES
ENDC

IF DEF(PANCAKE_PLAYTEST)
PancakePlaytestMap:
	INCBIN "build/pancake_playtest.tilemap"
PancakePlaytestMapEnd:
ASSERT PancakePlaytestMapEnd - PancakePlaytestMap == LEVEL_WIDTH_TILES * LEVEL_HEIGHT_TILES
ENDC

IF DEF(FRIED_EGG_PLAYTEST)
FriedEggPlaytestMap:
	INCBIN "build/fried_egg_playtest.tilemap"
FriedEggPlaytestMapEnd:
ASSERT FriedEggPlaytestMapEnd - FriedEggPlaytestMap == LEVEL_WIDTH_TILES * LEVEL_HEIGHT_TILES
ENDC
