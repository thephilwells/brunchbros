DiningFurnitureWidths: db 4, 2, 4, 4
DiningFurnitureHeights: db 2, 2, 3, 2
DiningFurnitureTilePointers:
	dw DiningFurnitureTiles0
	dw DiningFurnitureTiles1
	dw DiningFurnitureTiles2
	dw DiningFurnitureTiles3
DiningFurnitureAlternateTilePointers:
	dw 0
	dw DiningFurnitureTiles1Alternate
	dw 0
	dw 0
DiningFurnitureTiles0:
	db 51, 52, 52, 53, 54, 17, 17, 55
DiningFurnitureTiles1:
	db 17, 56, 57, 58
DiningFurnitureTiles1Alternate:
	db 76, 17, 77, 78
DiningFurnitureTiles2:
	db 59, 60, 60, 61, 62, 62, 62, 62, 63, 63, 63, 63
DiningFurnitureTiles3:
	db 112, 113, 113, 114, 115, 115, 115, 115
