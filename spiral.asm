	org 0xc000
texture
	rept 64
	db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	endm

map
	ds 0x0600

sine
	include "roto_sine.asm"

runrt_sprites
	incbin "assets/runner_sprites.bin"
runlt_sprites
	incbin "assets/runner_left_sprites.bin"
runup_sprites
	incbin "assets/runner_up_sprites.bin"
rundn_sprites
	incbin "assets/runner_down_sprites.bin"

	org 0xf000

	ld hl,0x4000
	ld de,0x4001
	ld bc,0x17ff
	ld (hl),l
	ldir

	xor a
	out (254),a

	ld b,150
frame1_lp
	halt
	push bc
	call trail1
	call rota_farcopy
	call runrt_frame
	call runlt_frame
	pop bc
	djnz frame1_lp

	ld b,100
frame2a_lp
	halt
	push bc
	call trail2
	call rota_farcopy
	call runrt_frame
	call runlt_frame
	call runup_frame
	call rundn_frame
	pop bc
	djnz frame2a_lp

	ld b,50
frame2b_lp
	halt
	push bc
	call trail2
	call rota_farcopy
	call runup_frame
	call rundn_frame
	pop bc
	djnz frame2b_lp

	ld hl,0x40e0
	ld (runrt_screenpos+1),hl
	ld hl,0x48bf
	ld (runlt_screenpos+1),hl

	xor a
	ld (runrt_frameno+1),a
	ld (runlt_frameno+1),a

	ld b,36
frame3a_lp
	halt
	push bc
	call trail3
	call rota_farcopy
	call runup_frame
	call rundn_frame
	call runrt_frame
	call runlt_frame
	pop bc
	djnz frame3a_lp

	; turn cyan crossovers into black on cyan
	ld hl,texture + 64*2 + 14
	ld a,0x28
	ld de,64-8
	ld b,8
crossover1_lp
	rept 8
		ld (hl),a
		inc l
	endm
	add hl,de
	djnz crossover1_lp

	ld hl,texture + 64*54 + 42
	ld a,0x28
	ld de,64-8
	ld b,8
crossover2_lp
	rept 8
		ld (hl),a
		inc l
	endm
	add hl,de
	djnz crossover2_lp

	ld b,50-36
frame3b_lp
	halt
	push bc
	call trail3
	call rota_farcopy
	call runup_frame
	call rundn_frame
	call runrt_frame
	call runlt_frame
	pop bc
	djnz frame3b_lp

	ld b,14
frame3c_lp
	halt
	push bc
	call trail3
	call rota_farcopy
	call runrt_frame
	call runlt_frame
	pop bc
	djnz frame3c_lp

	ld b,86
frame3d_lp
	halt
	push bc
	call runrt_frame
	call runlt_frame
	pop bc
	djnz frame3d_lp

	ld b,100
frame4a_lp
	halt
	push bc
	call trail4
	call rota_farcopy
	call runrt_frame
	call runlt_frame
	pop bc
	djnz frame4a_lp

	ld b,50-6
frame4b_lp
	halt
	push bc
	call trail4
	call rota_farcopy
	pop bc
	djnz frame4b_lp

zoom_duration equ 40

	ld b,zoom_duration
frame_lp
	halt
	push bc

	ld a,b
	add a,b
	add a,b
	add a,a
	add a,255-(zoom_duration*6)
	ld (mul+1),a

	ld a,128+(zoom_duration*3)
	sub b
	sub b
	sub b
	call set_rotation

	call rotozoom

	pop bc
	djnz frame_lp

	ret

mul
	ld a,0
	ld b,h
	ld c,l
	ld hl,0

mul_lp
	add a,a
	jr nc,mul_noadd
	add hl,bc
mul_noadd
	or a
	ret z

	sra b
	rr c

	jp mul_lp

set_rotation
			ld d,high sine
			ld e,a
			ld a,(de)

			sla a
			ld l,a
			sbc a,a
			ld h,a	; use this as sin t
			call mul
			ld (row_xstep+1),hl

			ld a,e
			add a,64
			ld e,a
			ld a,(de)
			sla a
			ld l,a
			sbc a,a
			ld h,a	; use this as cos t (1/4 phase ahead of sin t)
			call mul
			ld (char_xstep+1),hl
			ld (row_ystep+1),hl

			ld a,e
			add a,64
			ld e,a
			ld a,(de)
			sla a
			ld l,a
			sbc a,a
			ld h,a	; use this as -sin t (1/2 phase ahead of sin t)
			call mul
			ld (char_ystep+1),hl

			; x needs to be offset by -16*char_xstep and -12*row_xstep
			ld hl,(row_xstep+1)
			add hl,hl
			add hl,hl ; 4*row_xstep
			ld e,l
			ld d,h
			add hl,hl
			add hl,de ; 12*row_xstep
			ex de,hl
			ld hl,(char_xstep+1)
			add hl,hl
			add hl,hl
			add hl,hl
			add hl,hl ; 16*char_xstep
			add hl,de
			ex de,hl
			ld hl,0
			sbc hl,de
			ld (x_offset+1),hl

			; y needs to be offset by -16*char_ystep and -12*row_ystep
			ld hl,(row_ystep+1)
			add hl,hl
			add hl,hl ; 4*row_ystep
			ld e,l
			ld d,h
			add hl,hl
			add hl,de ; 12*row_ystep
			ex de,hl
			ld hl,(char_ystep+1)
			add hl,hl
			add hl,hl
			add hl,hl
			add hl,hl ; 16*char_ystep
			add hl,de
			ex de,hl
			ld hl,0
			sbc hl,de
			ld (y_offset+1),hl

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

rota_farcopy
	ld hl,texture + 40*64
	ld de,0x5800

	call rota_far_half
	ld hl,texture

rota_far_half
	ld b,12
rota_farlp
	push bc

	push hl
	ld bc,32
	add hl,bc

	rept 16
	ldi
	inc hl
	endm

	pop hl

	rept 16
	ldi
	inc hl
	endm

	ld bc,128-32
	add hl,bc

	pop bc
	djnz rota_farlp
	ret

trail1
trail1pos
	ld a,32
	dec a
	and 0x3f
	ld (trail1pos+1),a

	push af
	ld hl,texture+128*7
	or l
	ld l,a
	call trail1_col
	pop af
	cpl
	and 0x3f
	ld hl,texture+128*21
	or l
	ld l,a
	call trail1_col

	ret

trail1_col
	ld b,8
	ld de,64
	ld a,0x30 ; yellow paper
trail1_lp
	ld (hl),a
	add hl,de
	djnz trail1_lp
	ret

trail2
trail2pos
	ld a,39
	inc a
	and 0x3f
	ld (trail2pos+1),a
	ld b,a

	sub 14
	cp 8
	ret c

	push bc
	ld h,b
	ld l,0
	srl h
	rr l
	srl h
	rr l
	ld de,texture+14
	add hl,de
	call trail2_row

	pop af
	cpl
	and 0x3f
	ld h,a
	ld l,0
	srl h
	rr l
	srl h
	rr l
	ld de,texture+42
	add hl,de
	call trail2_row

	ret

trail2_row
	ld b,8
	ld a,0x18 ; magenta paper
trail2_lp
	ld (hl),a
	inc l
	djnz trail2_lp
	ret

trail3
trail3pos
	ld a,32
	dec a
	and 0x3f
	ld (trail3pos+1),a
	ld b,a

	sub 42
	cp 8
	ret c

	ld a,b
	sub 14
	cp 8
	jp c,trail3_alt

	ld a,b
	push af
	ld hl,texture+128*1
	or l
	ld l,a
	call trail3_col
	pop af
	cpl
	and 0x3f
	ld hl,texture+128*27
	or l
	ld l,a
	call trail3_col

	ret

trail3_alt
	ld a,b
	push af
	ld hl,texture+128*1
	or l
	ld l,a
	call trail3_altcol
	pop af
	cpl
	and 0x3f
	ld hl,texture+128*27
	or l
	ld l,a
	call trail3_altcol

	ret

trail3_col
	ld b,8
	ld de,64
	ld a,0x28 ; cyan paper
trail3_lp
	ld (hl),a
	add hl,de
	djnz trail3_lp
	ret

trail3_altcol
	ld b,8
	ld de,64
	ld a,0x28+5 ; cyan paper/cyan ink
trail3_altlp
	ld (hl),a
	add hl,de
	djnz trail3_altlp
	ret

trail4
trail4pos
	ld a,39
	inc a
	and 0x3f
	ld (trail4pos+1),a
	ld b,a

	sub 14
	cp 8
	ret c

	ld a,b
	sub 54
	cp 8
	ret c

	push bc
	ld h,b
	ld l,0
	srl h
	rr l
	srl h
	rr l
	ld de,texture+2
	add hl,de
	call trail4_row

	pop af
	cpl
	and 0x3f
	ld h,a
	ld l,0
	srl h
	rr l
	srl h
	rr l
	ld de,texture+54
	add hl,de
	call trail4_row

	ret

trail4_row
	ld b,8
	ld a,0x12 ; red paper
trail4_lp
	ld (hl),a
	inc l
	djnz trail4_lp
	ret

; == run right ==
runrt_frame
	ld a,3
	dec a
	jr nz,runrt_skipframe

	call runrt_advance
	call runrt_draw_currframe

	ld a,3
runrt_skipframe
	ld (runrt_frame+1),a
	ret

runrt_advance
	ld a,(runrt_frameno+1)
	inc a
	cp 12
	jr nz,runrt_nowrap
	xor a
runrt_nowrap
	ld (runrt_frameno+1),a

	jr z,runrt_nextchar
	cp 3
	jr z,runrt_nextchar
	cp 6
	jr z,runrt_nextchar
	cp 9
	jr z,runrt_nextchar

	ret

runrt_nextchar
	ld a,(runrt_screenpos+1)
	inc a
	ld (runrt_screenpos+1),a
	ret

runrt_draw_currframe

runrt_frameno
	ld b,0
runrt_screenpos
	ld de,0x4020

	; enter with b=frame no, de=screen pos
runrt_draw_frame
	ld h,b
	ld l,0
	srl h
	rr l
	ld bc,runrt_sprites
	add hl,bc

	ld a,e
	and 0x1f
	; left clipping positions
	jp z,run_lclip_1
	dec e
	dec a
	jp z,run_lclip_2
	dec e
	dec a
	jp z,run_lclip_3
	dec e

	add a,232
	ret c
	inc a
	jp z,run_rclip_1
	inc a
	jp z,run_rclip_2
	inc a
	jp z,run_rclip_3
	inc a

	jp run_noclip

; == run left ==
runlt_frame
	ld a,3
	dec a
	jr nz,runlt_skipframe

	call runlt_advance
	call runlt_draw_currframe

	ld a,3
runlt_skipframe
	ld (runlt_frame+1),a
	ret

runlt_advance
	ld a,(runlt_frameno+1)
	inc a
	cp 12
	jr nz,runlt_nowrap
	xor a
runlt_nowrap
	ld (runlt_frameno+1),a

	jr z,runlt_nextchar
	cp 3
	jr z,runlt_nextchar
	cp 6
	jr z,runlt_nextchar
	cp 9
	jr z,runlt_nextchar

	ret

runlt_nextchar
	ld a,(runlt_screenpos+1)
	dec a
	ld (runlt_screenpos+1),a
	ret

runlt_draw_currframe

runlt_frameno
	ld b,0
runlt_screenpos
	ld de,0x507f

	; enter with b=frame no, de=screen pos
runlt_draw_frame
	ld h,b
	ld l,0
	srl h
	rr l
	ld bc,runlt_sprites
	add hl,bc

	ld a,e
	and 0x1f

	add a,0xe1
	; right clipping positions
	jp z,run_rclip_1
	inc a
	jp z,run_rclip_2
	inc a
	jp z,run_rclip_3

	add a,0x14
	jp c,run_noclip

	; left clipping positions
	inc e
	inc a
	jp z,run_lclip_3
	inc e
	inc a
	jp z,run_lclip_2
	inc e
	inc a
	jp z,run_lclip_1
	ret

; == runner sprite routines - enter with hl=sprite, de=screen ==
run_noclip
	ld b,32
run_heightb
run_rowlp_w4
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

	djnz run_rowlp_w4
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
run_lclip_3
	ld b,32
run_lclip3_lp
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

	djnz run_lclip3_lp
	ret

	; right clip to 3 chars
run_rclip_3
	ld b,32
run_rclip3_lp
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

	inc hl

	pop de
	call upde2

	djnz run_rclip3_lp
	ret

	; left clip to 2 chars
run_lclip_2
	ld b,32

run_lclip2_lp
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

	djnz run_lclip2_lp
	ret

	; right clip to 2 chars
run_rclip_2
	ld b,32

run_rclip2_lp
	ld a,(hl)
	ld (de),a
	inc l
	inc e

	ld a,(hl)
	ld (de),a
	inc l
	inc l

	inc hl

	dec e
	call upde2

	djnz run_rclip2_lp
	ret

	; left clip to 1 char
run_lclip_1
	ld b,32

run_lclip1_lp
	inc l
	inc l
	inc l

	ld a,(hl)
	ld (de),a
	inc hl

	call upde2

	djnz run_lclip1_lp
	ret

	; right clip to 1 char
run_rclip_1
	ld b,32

run_rclip1_lp
	ld a,(hl)
	ld (de),a

	inc l
	inc l
	inc l
	inc hl

	call upde2

	djnz run_rclip1_lp
	ret

; == run up ==
runup_frame
	ld a,3
	dec a
	jr nz,runup_skipframe

	call runup_advance
	call runup_draw_currframe

	ld a,3
runup_skipframe
	ld (runup_frame+1),a
	ret

runup_advance
	ld a,(runup_frameno+1)
	inc a
	cp 12
	jr nz,runup_nowrap
	xor a
runup_nowrap
	ld (runup_frameno+1),a

	jr z,runup_nextchar
	cp 3
	jr z,runup_nextchar
	cp 6
	jr z,runup_nextchar
	cp 9
	jr z,runup_nextchar

	ret

runup_nextchar
	ld a,(runup_ypos+1)
	dec a
	ld (runup_ypos+1),a
	ret

runup_draw_currframe

runup_ypos
	ld e,23

runup_frameno
	ld h,0 ; mul by 128 and add runup_sprites to get sprite address in hl
	ld l,0
	srl h
	rr l
	ld bc,runup_sprites
	add hl,bc

	ld b,0x05 ; xpos
	ld a,e
	sub 2
	ret c
	jp z,run_tclip_1
	dec a
	jp z,run_tclip_2
	dec a
	jp z,run_tclip_3

	sub 17
	jp c,runv_noclip
	jp z,run_bclip_3
	dec a
	jp z,run_bclip_2
	jp run_bclip_1

; == run down ==
rundn_frame
	ld a,3
	dec a
	jr nz,rundn_skipframe

	call rundn_advance
	call rundn_draw_currframe

	ld a,3
rundn_skipframe
	ld (rundn_frame+1),a
	ret

rundn_advance
	ld a,(rundn_frameno+1)
	inc a
	cp 12
	jr nz,rundn_nowrap
	xor a
rundn_nowrap
	ld (rundn_frameno+1),a

	jr z,rundn_nextchar
	cp 3
	jr z,rundn_nextchar
	cp 6
	jr z,rundn_nextchar
	cp 9
	jr z,rundn_nextchar

	ret

rundn_nextchar
	ld a,(rundn_ypos+1)
	inc a
	ld (rundn_ypos+1),a
	ret

rundn_draw_currframe

rundn_ypos
	ld e,253

rundn_frameno
	ld h,0 ; mul by 128 and add runup_sprites to get sprite address in hl
	ld l,0
	srl h
	rr l
	ld bc,rundn_sprites
	add hl,bc

	ld b,23 ; xpos
	ld a,e
	inc a
	jp z,run_tclip_3
	inc a
	jp z,run_tclip_2
	inc a
	jp z,run_tclip_1

	sub 19
	jp c,runv_noclip
	jp z,run_bclip_3
	dec a
	jp z,run_bclip_2
	dec a
	jp z,run_bclip_1
	ret

runv_noclip
	call runup_conv_ypos
	ld b,32
	jp run_heightb

run_tclip_1
	inc e
	inc e
	inc e
	call runup_conv_ypos
	ld bc,96
	add hl,bc
	ld b,8
	jp run_heightb
run_tclip_2
	inc e
	inc e
	call runup_conv_ypos
	ld bc,64
	add hl,bc
	ld b,16
	jp run_heightb
run_tclip_3
	inc e
	call runup_conv_ypos
	ld bc,32
	add hl,bc
	ld b,24
	jp run_heightb

run_bclip_1
	call runup_conv_ypos
	ld b,8
	jp run_heightb
run_bclip_2
	call runup_conv_ypos
	ld b,16
	jp run_heightb
run_bclip_3
	call runup_conv_ypos
	ld b,24
	jp run_heightb

runup_conv_ypos
	push hl
	ld l,e
	ld h,0
	add hl,hl
	ld de,ytable
	add hl,de
	ld a,(hl)
	or b
	ld e,a
	inc hl
	ld d,(hl)
	pop hl
	ret

ytable
	dw 0x4000, 0x4020, 0x4040, 0x4060, 0x4080, 0x40a0, 0x40c0, 0x40e0
	dw 0x4800, 0x4820, 0x4840, 0x4860, 0x4880, 0x48a0, 0x48c0, 0x48e0
	dw 0x5000, 0x5020, 0x5040, 0x5060, 0x5080, 0x50a0, 0x50c0, 0x50e0
