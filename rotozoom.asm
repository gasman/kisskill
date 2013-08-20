	org 0xc000
texture
	rept 64
	db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
	endm

map
	ds 0x0600

sine
	include "roto_sine.asm"

runner2_sprites
	incbin "assets/runner_sprites.bin"

runner2_up_sprites
	incbin "assets/runner_up_sprites.bin"

	org 0xe800

;	ld hl,0
;	ld de,0x4000
;	ld bc,0x1800
;	ldir

	ld b,43
stat1_lp
	push bc
	halt

	call runner2_frame

	halt

	call runner2_frame
	call plotsome
	ld hl,texture
	call rota_straightcopy

	pop bc
	djnz stat1_lp

	ld b,32
twist1_lp
	halt

	push bc

	ld a,40
	add a,b
	ld h,a
	ld l,0 ; hl=a*256
	srl h
	rr l ; hl = a*128
	srl h
	rr l ; hl = a*64

	ld d,h
	ld e,l ; de = a*64
	srl d
	rr e ; de = a*32
	add hl,de ; hl = a*96
	srl d
	rr e ; de = a*16
	add hl,de ; hl = a*112

	ld (x_offset+1),hl

	ld a,79
	sub b
	ld h,a
	ld l,0
	srl h
	rr l
	ld (y_offset+1),hl

	ld a,b
	add a,a
	add a,64
	call set_rotation

	call plotsome

	call rotozoom

	pop bc
	djnz twist1_lp

	ld hl,0x4806
	ld (runner2_screenpos+1),hl
	ld b,43
stat2_lp
	push bc
	halt

	call runner2_frame

	halt

	call runner2_frame
	call plotsome
	ld hl,texture + 64*8 + 40
	call rota_90copy

	pop bc
	djnz stat2_lp

	ld b,32
twist2_lp
	halt
	push bc

	ld h,b
	ld l,0 ; hl=256t
	srl h
	rr l ; hl = 128t
	srl h
	rr l ; hl = 64t

	ld d,h
	ld e,l ; de = 64t
	srl d
	rr e ; de = 32t
	add hl,de ; hl = 96t
	srl d
	rr e ; de = 16t
	add hl,de ; hl = 112t
	ld a,h
	add a,b
	ld d,a
	ld e,l ; de = 368t
	ld hl,0x3f80
	sbc hl,de
	ld (x_offset+1),hl

	ld a,126
	add a,b
	ld h,a
	ld l,0
	srl h
	rr l
	srl h
	rr l
	ld (y_offset+1),hl

	ld a,128
	sub b
	sub b
	call set_rotation

	call rotozoom

	pop bc
	djnz twist2_lp

	ld b,86 ; not 75?
stat3_lp
	push bc
	halt
	call runner2_up_frame
	halt
	call runner2_up_frame

	ld hl,texture + 64*8 + 32
	call rota_straightcopy
	pop bc
	djnz stat3_lp

	ret

set_rotation
rotarota
			ld h,high sine
			ld l,a
			ld a,(hl)

			sla a
			ld e,a
			sbc a,a
			ld d,a	; use this as sin t
			ld (row_xstep+1),de
			
			ld a,l
			add a,64
			ld l,a
			ld a,(hl)
			sla a
			ld e,a
			sbc a,a
			ld d,a	; use this as cos t (1/4 phase ahead of sin t)
			ld (char_xstep+1),de
			ld (row_ystep+1),de

			ld a,l
			add a,64
			ld l,a
			ld a,(hl)
			sla a
			ld e,a
			sbc a,a
			ld d,a	; use this as -sin t (1/2 phase ahead of sin t)
			ld (char_ystep+1),de

;			ld hl,(y_offset+1)
;			ld de,0x0180
;			add hl,de
;			ld (y_offset+1),hl
;
;			ld hl,(x_offset+1)
;			ld de,0x0040
;			add hl,de
;			ld (x_offset+1),hl
		ret

rotozoom
y_offset
	ld hl,0x0000 ; initial texture y
char_ystep
	ld de,0xff80 ; -sin(30deg) - y step for each char
	ld bc,map
	exx
x_offset
	ld hl,0x0000 ; initial texture x
char_xstep
	ld de,0x00de ; cos(30deg) - x step for each char
	ld b,24
	ld c,0x3f ; texture width
rotozoom_row
		push de
		push hl

		exx
		push de
		push hl
		push bc
		exx

		rept 32
			ld a,h ; integer portion of texture_x
			and c ; modulo texture width
			add hl,de ; advance texture x
			exx
			ld (bc),a ; store texture x pos
			inc c
			ld a,h ; integer portion of texture_y
			and 0x3f ; modulo texture height
			ld (bc),a ; store texture y pos
			inc c
			add hl,de ; advance texture y
			exx
		endm

		exx
		pop bc
		ld hl,64
		add hl,bc
		ld b,h
		ld c,l
		pop hl
row_ystep
		ld de,0x00de ; cos(30deg) - y step for each row
		add hl,de
		pop de
		exx

		pop hl
row_xstep
		ld de,0x0080 ; sin(30deg) - x step for each row
		add hl,de
		pop de

	dec b
	jp nz,rotozoom_row

	halt

	ld (spback+1),sp

	ld sp,map
	ld d,1
	ld bc,0x5aff
plot_lp
	rept 3
		pop hl ; h = y offset, l = x offset
			; need to get from 00yyyyyy 00xxxxxx to 1100yyyy yyxxxxxx
		ld a,d ; a=1
		scf
		rr h
		rra
		rr h
		rra
		or l
		ld l,a

		ld a,(hl)
		ld (bc),a
		dec bc ; b = 0101 1000 or 0101 1001 or 0101 1010 when in range; 0101 0fff if not, so test bit 3
	endm
	bit 3,b
	jp nz,plot_lp

spback
	ld sp,0

	ret

rota_straightcopy
	ld de,0x5800
	ld b,24
rota_straightlp
	push bc

	rept 32
	ld a,(de)
	cp 0x30 ; skip overwriting yellow/black
	jr z,$+4
	ld a,(hl)
	ld (de),a
	inc hl
	inc de
	endm

	ld bc,32
	add hl,bc
	pop bc
	dec b
	jp nz, rota_straightlp
	ret

rota_90copy
	ld de,0x5800
	ld b,24
rota_90lp
	push bc
	push hl

	ld bc,64
	rept 32
	ld a,(de)
	cp 0x30
	jr z,$+4
	ld a,(hl)
	ld (de),a
	inc de
	add hl,bc
	endm

	pop hl
	dec l
	pop bc
	dec b
	jp nz,rota_90lp
	ret

plotsome
plotpos
	ld de,plotdata
	ld b,8 ; 8 plots per frame
plotsome_lp
	push bc
	ex de,hl
	ld e,(hl) ; read x/y
	inc hl
	ld d,(hl)
	inc hl
	ex de,hl
	xor a ; convert to offset
	srl h
	rra
	srl h
	rra
	or l
	ld l,a
	ld bc,texture
	add hl,bc ; tex address in hl
	ld a,(de) ; read colour
	inc de
	ld (hl),a ; write to tex
	ld bc,65
	add hl,bc ; move to shadow char
	ld a,(hl)
	and 0xfe ; if this doesn't zero out the byte, we're on top of a ribbon so don't write the shadow back
	jr nz,rib_noshadow1
	ld (hl),a
rib_noshadow1
	pop bc
	djnz plotsome_lp
	ld (plotpos+1),de
	ret

runner2_frame
	ld a,3
	dec a
	jr nz,runner2_skipframe

	call runner2_advance
	call runner2_draw_currframe

	; set the attrib of the leading edge of the runner to 0x30 (black on yellow), IF it was previously 0x36 (yellow on yellow)
	ld hl,(runner2_screenpos+1)
	inc l
	inc l
	inc l
	; screen addr is 010yyyyy yyyxxxxx, 010yy000 yyyxxxxx for top line of char
	; need to make it 010110yy yyyxxxxx for attribute
	ld a,h
	srl a
	srl a
	srl a
	or 0x58
	ld h,a

	ld bc,32
	ld a,(hl)
	cp 0x36
	jr nz,noyellow1
	ld (hl),0x30
noyellow1
	add hl,bc
	ld a,(hl)
	cp 0x36
	jr nz,noyellow2
	ld (hl),0x30
noyellow2
	add hl,bc
	ld a,(hl)
	cp 0x36
	jr nz,noyellow3
	ld (hl),0x30
noyellow3
	add hl,bc
	ld a,(hl)
	cp 0x36
	jr nz,noyellow4
	ld (hl),0x30
noyellow4

	ld a,3
runner2_skipframe
	ld (runner2_frame+1),a
	ret

runner2_advance
	ld a,(runner2_frameno+1)
	inc a
	cp 12
	jr nz,runner2_nowrap
	xor a
runner2_nowrap
	ld (runner2_frameno+1),a

	jr z,runner2_nextchar
	cp 3
	jr z,runner2_nextchar
	cp 6
	jr z,runner2_nextchar
	cp 9
	jr z,runner2_nextchar

	ret

runner2_nextchar
	ld a,(runner2_screenpos+1)
	inc a
	ld (runner2_screenpos+1),a
	ret

runner2_draw_currframe

runner2_frameno
	ld b,0
runner2_screenpos
	ld de,0x48a0

	; enter with b=frame no, de=screen pos
runner2_draw_frame
	ld h,b
	ld l,0
	srl h
	rr l
	ld bc,runner2_sprites
	add hl,bc

	ld a,e
	and 0x1f
	; left clipping positions
	cp 0
	jp z,runner2_draw_frame_w1
	cp 1
	jp z,runner2_draw_frame_w2
	cp 2
	jp z,runner2_draw_frame_w3

runner2_draw_frame_w4
	ld b,32
runner2_rowlp_w4
	push de

	ld a,(hl)
	ld (de),a
	inc l
	inc e

	ld a,(hl)
	ld (de),a
	inc l
	inc e

	ld a,(hl)
	ld (de),a
	inc l
	inc e

	ld a,(hl)
	ld (de),a
	inc hl

	pop de
	call upde2

	djnz runner2_rowlp_w4
	ret

upde2
	inc d
	ld a,d
	and 7
	ret nz
	ld a,e
	add a,32
	ld e,a
	ret c
	ld a,d
	sub 8
	ld d,a
	ret

	; left clip to 3 chars
runner2_draw_frame_w3
	ld b,32
	inc e
runner2_rowlp_w3
	push de

	inc l

	ld a,(hl)
	ld (de),a
	inc l
	inc e

	ld a,(hl)
	ld (de),a
	inc l
	inc e

	ld a,(hl)
	ld (de),a
	inc hl

	pop de
	call upde2

	djnz runner2_rowlp_w3
	ret

	; left clip to 2 chars
runner2_draw_frame_w2
	ld b,32
	inc e
	inc e

runner2_rowlp_w2
	inc l
	inc l

	ld a,(hl)
	ld (de),a
	inc l
	inc e

	ld a,(hl)
	ld (de),a
	inc hl

	dec e
	call upde2

	djnz runner2_rowlp_w2
	ret

	; left clip to 1 char
runner2_draw_frame_w1
	ld b,32

	inc e
	inc e
	inc e

runner2_rowlp_w1
	inc l
	inc l
	inc l

	ld a,(hl)
	ld (de),a
	inc hl

	call upde2

	djnz runner2_rowlp_w1
	ret





runner2_up_frame
	ld a,3
	dec a
	jr nz,runner2_up_skipframe

	call runner2_up_advance
	call runner2_up_draw_currframe

	; set the attrib of the leading edge of the runner to 0x30 (black on yellow), IF it was previously 0x36 (yellow on yellow)
	ld hl,(runner2_up_screenpos+1)
	; screen addr is 010yyyyy yyyxxxxx, 010yy000 yyyxxxxx for top line of char
	; need to make it 010110yy yyyxxxxx for attribute
	ld a,h
	srl a
	srl a
	srl a
	or 0x58
	ld h,a

	ld a,(hl)
	cp 0x36
	jr nz,noyellow1u
	ld (hl),0x30
noyellow1u
	inc l
	ld a,(hl)
	cp 0x36
	jr nz,noyellow2u
	ld (hl),0x30
noyellow2u
	inc l
	ld a,(hl)
	cp 0x36
	jr nz,noyellow3u
	ld (hl),0x30
noyellow3u
	inc l
	ld a,(hl)
	cp 0x36
	jr nz,noyellow4u
	ld (hl),0x30
noyellow4u

	ld a,3
runner2_up_skipframe
	ld (runner2_up_frame+1),a
	ret

runner2_up_advance
	ld a,(runner2_up_frameno+1)
	inc a
	cp 12
	jr nz,runner2_up_nowrap
	xor a
runner2_up_nowrap
	ld (runner2_up_frameno+1),a

	jr z,runner2_up_nextchar
	cp 3
	jr z,runner2_up_nextchar
	cp 6
	jr z,runner2_up_nextchar
	cp 9
	jr z,runner2_up_nextchar

	ret

runner2_up_nextchar
	ld hl,(runner2_up_screenpos+1)
	; screen address is nny7y6y2y1y0 y5y4y3x4x3x2x1x0
	; so rotate y2y1y0 out of the way and add 32
	rrc h
	rrc h
	rrc h
	ld bc,-32
	add hl,bc
	rlc h
	rlc h
	rlc h
	ld (runner2_up_screenpos+1),hl
	ret

runner2_up_draw_currframe

runner2_up_frameno
	ld b,0
runner2_up_screenpos
	ld de, 0x5083; was 0x5063

	; enter with b=frame no, de=screen pos
runner2_up_draw_frame
	ld h,b
	ld l,0
	srl h
	rr l
	ld bc,runner2_up_sprites
	add hl,bc

	jp runner2_draw_frame_w4

	org 0xf000
plotdata
	db  0,13,54,  0,14,54,  0,15,54,  0,16,54,   0,19,27,  0,20,27,  0,21,27,  0,22,27
	db  1,13,54,  1,14,54,  1,15,54,  1,16,54,   1,19,27,  1,20,27,  1,21,27,  1,22,27
	db  2,13,54,  2,14,54,  2,15,54,  2,16,54,   2,19,27,  2,20,27,  2,21,27,  2,22,27
	db  3,13,54,  3,14,54,  3,15,54,  3,16,54,   3,19,27,  3,20,27,  3,21,27,  3,22,27
	db  4,13,54,  4,14,54,  4,15,54,  4,16,54,   4,19,27,  4,20,27,  4,21,27,  4,22,27
	db  5,13,54,  5,14,54,  5,15,54,  5,16,54,   5,19,27,  5,20,27,  5,21,27,  5,22,27
	db  6,13,54,  6,14,54,  6,15,54,  6,16,54,   6,19,27,  6,20,27,  6,21,27,  6,22,27
	db  7,13,54,  7,14,54,  7,15,54,  7,16,54,   7,19,27,  7,20,27,  7,21,27,  7,22,27
	db  8,13,54,  8,14,54,  8,15,54,  8,16,54,   8,19,27,  8,20,27,  8,21,27,  8,22,27
	db  9,13,54,  9,14,54,  9,15,54,  9,16,54,   9,19,27,  9,20,27,  9,21,27,  9,22,27
	db 10,13,54, 10,14,54, 10,15,54, 10,16,54,  10,19,27, 10,20,27, 10,21,27, 10,22,27
	db 11,13,54, 11,14,54, 11,15,54, 11,16,54,  11,19,27, 11,20,27, 11,21,27, 11,22,27
	db 12,13,54, 12,14,54, 12,15,54, 12,16,54,  12,19,27, 12,20,27, 12,21,27, 12,22,27
	db 13,13,54, 13,14,54, 13,15,54, 13,16,54,  13,19,27, 13,20,27, 13,21,27, 13,22,27
	db 14,13,54, 14,14,54, 14,15,54, 14,16,54,  14,19,27, 14,20,27, 14,21,27, 14,22,27
	db 15,13,54, 15,14,54, 15,15,54, 15,16,54,  15,19,27, 15,20,27, 15,21,27, 15,22,27
	db 16,13,54, 16,14,54, 16,15,54, 16,16,54,  16,19,27, 16,20,27, 16,21,27, 16,22,27
	db 17,13,54, 17,14,54, 17,15,54, 17,16,54,  17,19,27, 17,20,27, 17,21,27, 17,22,27
	db 18,13,54, 18,14,54, 18,15,54, 18,16,54,  18,19,27, 18,20,27, 18,21,27, 18,22,27
	db 19,13,54, 19,14,54, 19,15,54, 19,16,54,  19,19,27, 19,20,27, 19,21,27, 19,22,27
	db 20,13,54, 20,14,54, 20,15,54, 20,16,54,  20,19,27, 20,20,27, 20,21,27, 20,22,27
	db 21,13,54, 21,14,54, 21,15,54, 21,16,54,  21,19,27, 21,20,27, 21,21,27, 21,22,27
	db 22,13,54, 22,14,54, 22,15,54, 22,16,54,  22,19,27, 22,20,27, 22,21,27, 22,22,27

	db 23,13,54, 23,14,54, 23,15,54, 23,16,54,  19,18,27, 20,18,27, 21,18,27, 22,18,27
	db 24,13,54, 24,14,54, 24,15,54, 24,16,54,  19,17,27, 20,17,27, 21,17,27, 22,17,27
	db 25,13,54, 25,14,54, 25,15,54, 25,16,54,  19,16,27, 20,16,27, 21,16,27, 22,16,27
	db 26,13,54, 26,14,54, 26,15,54, 26,16,54,  19,15,27, 20,15,27, 21,15,27, 22,15,27
	db 27,13,54, 27,14,54, 27,15,54, 27,16,54,  19,14,27, 20,14,27, 21,14,27, 22,14,27
	db 28,13,54, 28,14,54, 28,15,54, 28,16,54,  19,13,27, 20,13,27, 21,13,27, 22,13,27
	db 29,13,54, 29,14,54, 29,15,54, 29,16,54,  19,12,27, 20,12,27, 21,12,27, 22,12,27
	db 30,13,54, 30,14,54, 30,15,54, 30,16,54,  19,11,27, 20,11,27, 21,11,27, 22,11,27
	db 31,13,54, 31,14,54, 31,15,54, 31,16,54,  19,10,27, 20,10,27, 21,10,27, 22,10,27
	db 32,13,54, 32,14,54, 32,15,54, 32,16,54,  19, 9,27, 20, 9,27, 21, 9,27, 22, 9,27
	db 29,17,54, 30,17,54, 31,17,54, 32,17,54,  19, 8,27, 20, 8,27, 21, 8,27, 22, 8,27

	db 29,18,54, 30,18,54, 31,18,54, 32,18,54,  23, 8,27, 23, 9,27, 23,10,27, 23,11,27
	db 29,19,54, 30,19,54, 31,19,54, 32,19,54,  24, 8,27, 24, 9,27, 24,10,27, 24,11,27
	db 29,20,54, 30,20,54, 31,20,54, 32,20,54,  25, 8,27, 25, 9,27, 25,10,27, 25,11,27
	db 29,21,54, 30,21,54, 31,21,54, 32,21,54,  26, 8,27, 26, 9,27, 26,10,27, 26,11,27
	db 29,22,54, 30,22,54, 31,22,54, 32,22,54,  27, 8,27, 27, 9,27, 27,10,27, 27,11,27

	db 29,23,54, 30,23,54, 31,23,54, 32,23,54,  24,12,27, 25,12,27, 26,12,27, 27,12,27
	db 29,24,54, 30,24,54, 31,24,54, 32,24,54,  24,12,27, 25,12,27, 26,12,27, 27,12,27
	db 29,25,54, 30,25,54, 31,25,54, 32,25,54,  24,12,27, 25,12,27, 26,12,27, 27,12,27
	db 29,26,54, 30,26,54, 31,26,54, 32,26,54,  24,12,27, 25,12,27, 26,12,27, 27,12,27

	; p2
	db 29,27,54, 30,27,54, 31,27,54, 32,27,54,  24,12,27, 25,12,27, 26,12,27, 27,12,27

	db 33,24,54, 33,25,54, 33,26,54, 33,27,54,  24,17,27, 25,17,27, 26,17,27, 27,17,27
	db 34,24,54, 34,25,54, 34,26,54, 34,27,54,  24,18,27, 25,18,27, 26,18,27, 27,18,27
	db 35,24,54, 35,25,54, 35,26,54, 35,27,54,  24,19,27, 25,19,27, 26,19,27, 27,19,27
	db 36,24,54, 36,25,54, 36,26,54, 36,27,54,  24,20,27, 25,20,27, 26,20,27, 27,20,27
	db 37,24,54, 37,25,54, 37,26,54, 37,27,54,  24,21,27, 25,21,27, 26,21,27, 27,21,27
	db 38,24,54, 38,25,54, 38,26,54, 38,27,54,  24,22,27, 25,22,27, 26,22,27, 27,22,27

	db 35,23,54, 36,23,54, 37,23,54, 38,23,54,  28,19,27, 28,20,27, 28,21,27, 28,22,27
	db 35,22,54, 36,22,54, 37,22,54, 38,22,54,  29,19,27, 29,20,27, 29,21,27, 29,22,27
	db 35,21,54, 36,21,54, 37,21,54, 38,21,54,  30,19,27, 30,20,27, 30,21,27, 30,22,27
	db 35,20,54, 36,20,54, 37,20,54, 38,20,54,  31,19,27, 31,20,27, 31,21,27, 31,22,27
	db 35,19,54, 36,19,54, 37,19,54, 38,19,54,  32,19,27, 32,20,27, 32,21,27, 32,22,27
	db 35,18,54, 36,18,54, 37,18,54, 38,18,54,  33,19,27, 33,20,27, 33,21,27, 33,22,27

	db 35,17,54, 36,17,54, 37,17,54, 38,17,54,  34,19,27, 34,20,27, 34,21,27, 34,22,27
	db 35,16,54, 36,16,54, 37,16,54, 38,16,54,  34,19,27, 34,20,27, 34,21,27, 34,22,27
	db 35,15,54, 36,15,54, 37,15,54, 38,15,54,  34,19,27, 34,20,27, 34,21,27, 34,22,27
	db 35,14,54, 36,14,54, 37,14,54, 38,14,54,  34,19,27, 34,20,27, 34,21,27, 34,22,27
	db 35,13,54, 36,13,54, 37,13,54, 38,13,54,  34,19,27, 34,20,27, 34,21,27, 34,22,27
	db 35,12,54, 36,12,54, 37,12,54, 38,12,54,  39,19,27, 39,20,27, 39,21,27, 39,22,27
	db 35,11,54, 36,11,54, 37,11,54, 38,11,54,  40,19,27, 40,20,27, 40,21,27, 40,22,27
	db 35,10,54, 36,10,54, 37,10,54, 38,10,54,  41,19,27, 41,20,27, 41,21,27, 41,22,27

	db 39,10,54, 39,11,54, 39,12,54, 39,13,54,  42,19,27, 42,20,27, 42,21,27, 42,22,27
	db 40,10,54, 40,11,54, 40,12,54, 40,13,54,  43,19,27, 43,20,27, 43,21,27, 43,22,27
	db 41,10,54, 41,11,54, 41,12,54, 41,13,54,  44,19,27, 44,20,27, 44,21,27, 44,22,27
	db 42,10,54, 42,11,54, 42,12,54, 42,13,54,  45,19,27, 45,20,27, 45,21,27, 45,22,27
	db 43,10,54, 43,11,54, 43,12,54, 43,13,54,  46,19,27, 46,20,27, 46,21,27, 46,22,27
	db 44,10,54, 44,11,54, 44,12,54, 44,13,54,  47,19,27, 47,20,27, 47,21,27, 47,22,27
	db 45,10,54, 45,11,54, 45,12,54, 45,13,54,  48,19,27, 48,20,27, 48,21,27, 48,22,27
	db 46,10,54, 46,11,54, 46,12,54, 46,13,54,  49,19,27, 49,20,27, 49,21,27, 49,22,27

	db 43,14,54, 44,14,54, 45,14,54, 46,14,54,  50,19,27, 50,20,27, 50,21,27, 50,22,27
	db 43,15,54, 44,15,54, 45,15,54, 46,15,54,  51,19,27, 51,20,27, 51,21,27, 51,22,27
	db 43,16,54, 44,16,54, 45,16,54, 46,16,54,  52,19,27, 52,20,27, 52,21,27, 52,22,27
	db 43,17,54, 44,17,54, 45,17,54, 46,17,54,  53,19,27, 53,20,27, 53,21,27, 53,22,27
	db 43,18,54, 44,18,54, 45,18,54, 46,18,54,  54,19,27, 54,20,27, 54,21,27, 54,22,27
	db 43,18,54, 44,18,54, 45,18,54, 46,18,54,  55,19,27, 55,20,27, 55,21,27, 55,22,27

	db 43,18,54, 44,18,54, 45,18,54, 46,18,54,  52,18,27, 53,18,27, 54,18,27, 55,18,27
	db 43,18,54, 44,18,54, 45,18,54, 46,18,54,  52,17,27, 53,17,27, 54,17,27, 55,17,27
	db 43,18,54, 44,18,54, 45,18,54, 46,18,54,  52,16,27, 53,16,27, 54,16,27, 55,16,27
	db 43,23,54, 44,23,54, 45,23,54, 46,23,54,  52,15,27, 53,15,27, 54,15,27, 55,15,27

	db 43,24,54, 44,24,54, 45,24,54, 46,24,54,  52,14,27, 53,14,27, 54,14,27, 55,14,27
	db 43,25,54, 44,25,54, 45,25,54, 46,25,54,  52,13,27, 53,13,27, 54,13,27, 55,13,27
	db 43,26,54, 44,26,54, 45,26,54, 46,26,54,  52,12,27, 53,12,27, 54,12,27, 55,12,27
	db 43,27,54, 44,27,54, 45,27,54, 46,27,54,  52,11,27, 53,11,27, 54,11,27, 55,11,27
	db 43,28,54, 44,28,54, 45,28,54, 46,28,54,  52,10,27, 53,10,27, 54,10,27, 55,10,27
	db 43,29,54, 44,29,54, 45,29,54, 46,29,54,  52, 9,27, 53, 9,27, 54, 9,27, 55, 9,27

	db 47,26,54, 47,27,54, 47,28,54, 47,29,54,  56, 9,27, 56,10,27, 56,11,27, 56,12,27
	db 48,26,54, 48,27,54, 48,28,54, 48,29,54,  57, 9,27, 57,10,27, 57,11,27, 57,12,27
	db 49,26,54, 49,27,54, 49,28,54, 49,29,54,  58, 9,27, 58,10,27, 58,11,27, 58,12,27
	db 50,26,54, 50,27,54, 50,28,54, 50,29,54,  59, 9,27, 59,10,27, 59,11,27, 59,12,27
	db 51,26,54, 51,27,54, 51,28,54, 51,29,54,  60, 9,27, 60,10,27, 60,11,27, 60,12,27
	db 52,26,54, 52,27,54, 52,28,54, 52,29,54,  61, 9,27, 61,10,27, 61,11,27, 61,12,27
	db 53,26,54, 53,27,54, 53,28,54, 53,29,54,  62, 9,27, 62,10,27, 62,11,27, 62,12,27
	db 54,26,54, 54,27,54, 54,28,54, 54,29,54,  63, 9,27, 63,10,27, 63,11,27, 63,12,27
	db 55,26,54, 55,27,54, 55,28,54, 55,29,54,  63, 9,27, 63,10,27, 63,11,27, 63,12,27
	db 56,26,54, 56,27,54, 56,28,54, 56,29,54,  63, 9,27, 63,10,27, 63,11,27, 63,12,27
	db 57,26,54, 57,27,54, 57,28,54, 57,29,54,  63, 9,27, 63,10,27, 63,11,27, 63,12,27
	db 58,26,54, 58,27,54, 58,28,54, 58,29,54,  63, 9,27, 63,10,27, 63,11,27, 63,12,27
	db 59,26,54, 59,27,54, 59,28,54, 59,29,54,  63, 9,27, 63,10,27, 63,11,27, 63,12,27
	db 60,26,54, 60,27,54, 60,28,54, 60,29,54,  63, 9,27, 63,10,27, 63,11,27, 63,12,27
	db 61,26,54, 61,27,54, 61,28,54, 61,29,54,  63, 9,27, 63,10,27, 63,11,27, 63,12,27
	db 62,26,54, 62,27,54, 62,28,54, 62,29,54,  63, 9,27, 63,10,27, 63,11,27, 63,12,27

	db 59,25,54, 60,25,54, 61,25,54, 62,25,54,  63, 9,27, 63,10,27, 63,11,27, 63,12,27
	db 59,24,54, 60,24,54, 61,24,54, 62,24,54,  63, 9,27, 63,10,27, 63,11,27, 63,12,27
	db 59,23,54, 60,23,54, 61,23,54, 62,23,54,  63, 9,27, 63,10,27, 63,11,27, 63,12,27
	db 59,22,54, 60,22,54, 61,22,54, 62,22,54,  63, 9,27, 63,10,27, 63,11,27, 63,12,27
	db 59,21,54, 60,21,54, 61,21,54, 62,21,54,  63, 9,27, 63,10,27, 63,11,27, 63,12,27
	db 59,20,54, 60,20,54, 61,20,54, 62,20,54,  63, 9,27, 63,10,27, 63,11,27, 63,12,27
	db 59,19,54, 60,19,54, 61,19,54, 62,19,54,  63, 9,27, 63,10,27, 63,11,27, 63,12,27
	db 59,18,54, 60,18,54, 61,18,54, 62,18,54,  63, 9,27, 63,10,27, 63,11,27, 63,12,27
	db 59,17,54, 60,17,54, 61,17,54, 62,17,54,  63, 9,27, 63,10,27, 63,11,27, 63,12,27
	db 59,16,54, 60,16,54, 61,16,54, 62,16,54,  63, 9,27, 63,10,27, 63,11,27, 63,12,27
	db 59,15,54, 60,15,54, 61,15,54, 62,15,54,  63, 9,27, 63,10,27, 63,11,27, 63,12,27

	db 63,15,54, 63,16,54, 63,17,54, 63,18,54,  63, 9,27, 63,10,27, 63,11,27, 63,12,27

	rept 1024
	db 0
	endm
