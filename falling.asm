falling
;	ld b,50 ; 300 frames, 6 frames on each iteration
	ld b,44 ; a bit less, so that we have fuzz afterwards

fall_lp
	push bc
	halt
	call do_wall
	call upd_spr32
	call upd_spr24
	call upd_spr16

	halt
	call do_wall
	call upd_spr32

	halt
	call do_wall
	call upd_spr32
	call upd_spr24

	halt
	call do_wall
	call upd_spr32
	call upd_spr16

	halt
	call do_wall
	call upd_spr32
	call upd_spr24

	halt
	call do_wall
	call upd_spr32
	pop bc
	djnz fall_lp
	ret

upd_spr32
spr32pos
	ld b,0 ; y
	ld c,16 ; x
	call sprite32

	ld a,(spr32pos+1)
	inc a
	cp 192
	ret z
	ld (spr32pos+1),a
	ret

upd_spr24
spr24pos
	ld b,32
	ld c,0x1c
	call sprite24

	ld a,(spr24pos+1)
	inc a
	cp 192
	ret z
	ld (spr24pos+1),a
	ret

upd_spr16
spr16pos
	ld b,88
	ld c,0x02
	call sprite16

	ld a,(spr16pos+1)
	inc a
	cp 192
	ret z
	ld (spr16pos+1),a
	ret

do_wall
wall_pos
	ld hl,wall_bg
	ld de,0x5800
	ld b,24
wall_row
	push bc

	rept 32
	ldi
	endm

	pop bc
	ld a,h
	and 1 + (high wall_bg)
	ld h,a
	djnz wall_row

	ld hl,(wall_pos+1)
	ld bc,32
	add hl,bc
	ld a,h
	and 1 + (high wall_bg)
	ld h,a
	ld (wall_pos+1),hl
	ret


; enter with b=y (pix), c=x (char); return with screen address in de
calc_screen_addr
	ld l,b ; y
	ld h,high ypositions
	ld a,(hl)
	add a,c ; x
	ld e,a
	inc h
	ld d,(hl)
	ret

sprite32
	call calc_screen_addr
	ld hl,falling_32
	ld b,96

sprite32lp
	push bc
	push de

	ldi
	ldi
	ldi
	ldi

	pop de
	call upde
	pop bc

	ld a,0x58
	cp d
	ret z

	djnz sprite32lp
	ret

sprite24
	call calc_screen_addr
	ld hl,falling_24
	ld b,72
sprite24lp
	push bc
	push de

	ldi
	ldi
	ldi

	pop de
	call upde
	pop bc

	ld a,0x58
	cp d
	ret z

	djnz sprite24lp
	ret

sprite16
	call calc_screen_addr
	ld hl,falling_16
	ld b,48
sprite16lp
	push bc
	push de

	ldi
	ldi

	pop de
	call upde
	pop bc

	ld a,0x58
	cp d
	ret z

	djnz sprite16lp
	ret

;upde
;	inc d
;	ld a,d
;	and 7
;	ret nz
;	ld a,e
;	add a,32
;	ld e,a
;	ret c
;	ld a,d
;	sub 8
;	ld d,a
;	ret

falling_32
	incbin "falling-32x96.bin"
falling_24
	incbin "falling-24x72.bin"
falling_16
	incbin "falling-16x48.bin"

	align 0x0200
wall_bg
	db  7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,23, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7
	db  7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,23, 7, 7, 7, 7, 7, 7, 7, 7,23, 7, 7, 7,23, 7, 7, 7, 7, 7, 7
	db 23, 7, 7, 7, 7,23, 7, 7, 7, 7, 7, 7, 7,23, 7, 7, 7, 7, 7, 7, 7, 7,23, 7,23, 7, 7, 7, 7, 7, 7, 7
	db  7,23, 7, 7,23, 7, 7, 7, 7, 7, 7, 7, 7, 7,23, 7, 7, 7,23, 7, 7, 7, 7,23, 7, 7, 7, 7,23, 7, 7, 7
	db  7, 7,23, 7, 7, 7,23, 7, 7, 7, 7, 7, 7, 7, 7,23, 7,23, 7, 7, 7, 7, 7, 7, 7, 7, 7,23, 7, 7, 7, 7
	db  7, 7, 7,23, 7, 7, 7,23, 7,23, 7, 7, 7, 7, 7, 7,23, 7, 7, 7, 7, 7, 7, 7, 7, 7,23, 7, 7, 7, 7, 7
	db  7, 7, 7, 7, 7, 7, 7, 7,23, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7
	db  7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7
	db  7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,23, 7, 7, 7, 7, 7, 7, 7
	db  7,23, 7, 7, 7, 7, 7, 7, 7, 7,23, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,23, 7, 7, 7, 7, 7, 7
	db  7, 7,23, 7, 7, 7,23, 7, 7, 7, 7,23, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,23, 7, 7, 7,23, 7, 7, 7, 7, 7
	db  7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,23, 7, 7, 7, 7,23, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7
	db  7, 7, 7, 7,23, 7, 7, 7, 7,23, 7, 7, 7,23, 7,23, 7, 7, 7, 7,23, 7, 7, 7, 7, 7, 7, 7,23, 7, 7, 7
	db  7, 7, 7,23, 7, 7, 7, 7,23, 7, 7, 7, 7, 7,23, 7, 7,23, 7,23, 7, 7, 7, 7, 7, 7, 7,23, 7, 7, 7,23
	db  7, 7, 7, 7, 7, 7, 7,23, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,23, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,23, 7
	db  7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,23, 7, 7

ypositions
	rept 256, n
	db (n & 0x38)<<2
	endm
	rept 256, n
	db 0x40|(n & 0x07)|(n & 0xc0)>>3
	endm
