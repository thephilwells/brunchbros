SECTION "Entry Point", ROM0[$100]
	jp Start
	ds $150 - @, 0

SECTION "Main", ROM0[$150]
Start:
	jr Start
