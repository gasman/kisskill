	org 0xc000
poster_scr
	incbin "assets/poster.scr"
	rept 0x300
		db 0x01
	endm
