	org 0x8000

	; set up interrupt table at 0xbe00
	ld hl,0xbe00
	ld de,0xbe01
	ld (hl),0xbf
	ld bc,0x0100
	ldir

	ld a,0xc3 ; JP
	ld (0xbfbf),a
	ld hl,interrupt
	ld (0xbfc0),hl

	ld d,0x11
	call check_contended
	ld d,0x13
	call check_contended
	ld d,0x14
	call check_contended
	ld d,0x16
	call check_contended
	ret

check_contended
	ld bc,0x7ffd
	out (c),d

	di
	ld a,0xbe
	ld i,a
	im 2
	ei

	ld bc,0
	halt
	or a

countlp
	ld hl,(0xc000)
	inc bc
	jr nc,countlp

	di
	im 1
	ei

	ld a,b
	cp 8

	jr c,is_contended
; not contended - record page from 25000 onward
uncont_list
	ld hl,25000
	ld (hl),d
	inc hl
	ld (uncont_list+1),hl
	ret
is_contended
; contended - record page from 25002 onward
cont_list
	ld hl,25002
	ld (hl),d
	inc hl
	ld (cont_list+1),hl
	ret

interrupt
	scf
	ei
	ret