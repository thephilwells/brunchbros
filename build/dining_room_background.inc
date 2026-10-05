DiningBackgroundWidths: db 4, 2, 2, 1, 4
DiningBackgroundHeights: db 2, 2, 2, 2, 3
DiningBackgroundTopRows: db 3, 3, 3, 3, 2
DiningBackgroundTilePointers:
	dw DiningBackgroundTiles0
	dw DiningBackgroundTiles1
	dw DiningBackgroundTiles2
	dw DiningBackgroundTiles3
	dw DiningBackgroundTiles4
DiningBackgroundTiles0:
	db 32, 33, 34, 35, 36, 37, 38, 39
DiningBackgroundTiles1:
	db 40, 41, 42, 43
DiningBackgroundTiles2:
	db 44, 45, 46, 47
DiningBackgroundTiles3:
	db 48, 49
DiningBackgroundTiles4:
	db 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75
