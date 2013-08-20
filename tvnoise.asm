tvnoise
	; set page 7 screen to white
	ld bc,0x7ffd
	ld a,0x07
	out (c),a
	ld hl,0xd800
	ld de,0xd801
	ld bc,0x02ff
	ld (hl),0x3f
	ldir
	; set page 5 screen to black (with white ink)
	ld hl,0x4000
	ld de,0x4001
	ld bc,0x1800
	ld (hl),l
	ldir
	ld bc,0x02ff
	ld (hl),0x07
	ldir

	ld b,120 ; was 50
noisewaitlp
	halt
	push bc
	ld a,0x42
	ld bc,0x0150 ; reduce to cover overheads of heavier interrupt routine
	call noiseframe
	pop bc
	djnz noisewaitlp

	ld b,0x42*2 ; was 0x42
	ld hl,0x0150 ; reduce to cover overheads of heavier interrupt routine
noiseframelp
	halt

	push bc
	ld a,b
	srl a
	inc a
	push hl
	ld b,h
	ld c,l

	call noiseframe
	pop hl
	ld de,0x0008 ; was 0x0010
	add hl,de
	pop bc

	djnz noiseframelp

	ld b,0x42/3 ; was 0x42
	ld hl,0x03e0 ; reduce to cover overheads of heavier interrupt routine
	call noiseburst
	ld b,35
	call noisebar

	ld b,0x42/4 ; was 0x42
	ld hl,0x0480 ; reduce to cover overheads of heavier interrupt routine
	call noiseburst

	ld b,32
rayframelp
	halt
	push bc
	ld c,b
	srl c
	call drawray
	pop bc
	djnz rayframelp

; set attrs for logo (black on black except for dot in 13th col)
	xor a
	call candyattr
	call saysattr
	ld a,0x47
	call dotattr

; put logo
	ld hl,logo
	ld de,0x4e44

	ld b,8
putlogo_lp
	push bc

	push hl
	push de
	rept 13
		ldi
	endm
	pop de
	pop hl
	call tvnoise_upde
	push de
	rept 13
		ldi
	endm
	pop de
	call tvnoise_upde

	pop bc
	djnz putlogo_lp

	ld b,colourseq_len - 32
logoframe_lp
	push bc
	halt
	halt
candyseqpos
	ld hl,colourseq + 32
	ld a,(hl)
	inc hl
	ld (candyseqpos+1),hl
	call candyattr

saysseqpos
	ld hl,colourseq
	ld a,(hl)
	inc hl
	ld (saysseqpos+1),hl
	call saysattr
	pop bc
	djnz logoframe_lp

	ld b,48
dotwait_lp
	halt
	djnz dotwait_lp

	ld b,8
dotframe_lp
	halt
	halt
	halt
	halt
	halt
	ld a,b
	dec a
	call dotattr
	djnz dotframe_lp

stoplp
	halt
	jp stoplp

noiseburst
noiseburstlp
	halt

	push bc
	ld a,b
	inc a
	push hl
	ld b,h
	ld c,l

	call noiseframe
	pop hl
	ld de,0x0010
	add hl,de
	pop bc

	djnz noiseburstlp
	ret

noisebar
noisebarlp
	halt
	push bc
	ld a,0x04
	ld bc,0x0530 ; reduce to cover overheads of heavier interrupt routine
	call noiseframe
	pop bc
	djnz noisebarlp
	ret

	; set attrs for the 'candy' part of the logo - enter with attr in a
candyattr
	ld hl,0x5944
	ld b,7
cattr1
	ld (hl),a
	inc l
	djnz cattr1

	ld hl,0x5964
	ld b,7
cattr2
	ld (hl),a
	inc l
	djnz cattr2

	ld hl,0x5984
	ld b,7
cattr3
	ld (hl),a
	inc l
	djnz cattr3
	ret

	; set attrs for the 'says' part of the logo - enter with attr in a
saysattr
	ld hl,0x594b
	ld b,5
sattr1
	ld (hl),a
	inc l
	djnz sattr1

	ld hl,0x596b
	ld b,5
sattr2
	ld (hl),a
	inc l
	djnz sattr2

	ld hl,0x598b
	ld b,5
sattr3
	ld (hl),a
	inc l
	djnz sattr3
	ret

	; set attrs for the dot
dotattr
	ld (0x5970),a
	ld (0x5990),a
	ret

drawray ; enter with c = width of white bit (16 to 0)

	ld hl,0x4880
	ld b,0x10
drawray_lp1
	ld a,b
	cp c
	sbc a,a
	ld (hl),a
	inc l
	djnz drawray_lp1

	ld hl,0x489f
	ld b,0x10
drawray_lp2
	ld a,b
	cp c
	sbc a,a
	ld (hl),a
	dec l
	djnz drawray_lp2

	ld hl,0x4980
	ld b,0x10
drawray_lp3
	ld a,b
	cp c
	sbc a,a
	ld (hl),a
	inc l
	djnz drawray_lp3

	ld hl,0x499f
	ld b,0x10
drawray_lp4
	ld a,b
	cp c
	sbc a,a
	ld (hl),a
	dec l
	djnz drawray_lp4

	ret

noiseframe
	; enter with:
	; a=height of noise panel. 0x42 = a little bit less than full screen
	; bc=delay before noise. 0x0150 = a little bit past the top of the screen
prenoiselp
	cpi
	jp pe,prenoiselp

	ld b,a
	call noiseframemain
	exx
	xor a
	out (c),a ; screen black for the remainder of the frame
	ld (noisepos+1),hl
	ret

noiseframemain ; enter with b=height of noise panel
	exx
	ld d,0x0f
	ld bc,0x7ffc
noisepos
	ld hl,0
nextbyte
	exx
	dec b
	ret z
	exx

	ld e,(hl) ; read byte from rom
	inc hl
	res 5,h
	scf
fizz
	rr e
	jr z,nextbyte
	sbc a,a
	and d
	out (c),a
	xor d
	out (c),a
	xor d
	out (c),a
	xor d
	out (c),a
	jp fizz

tvnoise_upde
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

logo
	include "candysays_logo.asm"

colourseq
	db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db 1,1,0,0,1,1,0,0,1,1,2,2,3,3,2,2,1,1,2,2,3,3,4,4,4,4,4,4,4,4
	db 5,5,5,5,5,5,5,5,4,4,3,3,3,3,3,3,4,4,5,5,5,4,4,5,5,5,4,4,4,4,3,3,3
	db 2,2,1,1,1,1,1,1,2,2,1,1,1,0,0,1,1
	db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
colourseq_len equ $ - colourseq
