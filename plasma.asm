plasma_init

	; black on black to hide background
	ld hl,0x5800
	ld de,0x5801
	ld (hl),l
	ld bc,0x02ff
	ldir

	; fill screen with background pattern
	ld de,0x4000 ; somewhere before start of screen memory
	ld bc,0x1800 ; enough loop iterations to fill the screen
	ld h,b ; somewhere in ROM
background_lp
	ld a,(hl)
	and 0xaa
	ld (de),a
	inc de
	cpi
	jp pe,background_lp

	ret

	; run for 120 beats or slightly less... (120 beats = 1125 frames)
	; say 110 => 1031 frames

plasma_run

	ld a,6
	out (254),a

	ld bc,375-11
frame_lp
	push bc
	halt

	call plasma
	call plasma_update

	halt

	call plasma_update
	call p_count_beats

	pop bc

	dec bc
	ld a,b
	or c
	jp nz,frame_lp

	ld b,11 ; 11 frames to clear 8 lines each time
frame_lp1a
	push bc
	halt

	call plasma
	call plasma_update

	halt

	call plasma_update
	call p_count_beats

clearforleap_pos
	ld hl,leap_ytable
	ld b,8
	xor a
clearforleap_rowlp
	ld e,(hl)
	inc hl
	ld d,(hl)
	inc hl
	rept 8
		ld (de),a
		inc e
	endm
	djnz clearforleap_rowlp
	ld (clearforleap_pos+1),hl

	pop bc
	djnz frame_lp1a



; now tweak sky_wkspc so that the area covering the sprite is black on cyan (0x68)
; not blue on cyan (0x6d)
	ld b,11
	ld hl,sky_wkspc + 0x014c
	ld de,0x18
	ld a,0x68
tweak_sky_lp
	rept 8
		ld (hl),a
		inc l
	endm
	add hl,de
	djnz tweak_sky_lp

	ld hl,leap_sprite1
	call leap_init
	ld b,50
framelp1
	push bc
	halt

	call plasma
	call plasma_update

	halt

	call plasma_update
	call p_count_beats
	call leapframe

	pop bc
	djnz framelp1

	ld hl,leap_sprite2
	call leap_init
	ld b,25
framelp2
	push bc
	halt
	call plasma
	call plasma_update
	halt
	call plasma_update
	call p_count_beats
	call leapframe
	pop bc
	djnz framelp2

	ld hl,leap_sprite3
	call leap_init
	ld b,25
framelp3
	push bc
	halt
	call plasma
	call plasma_update
	halt
	call plasma_update
	call p_count_beats
	call leapframe
	pop bc
	djnz framelp3

	ld hl,leap_sprite4
	call leap_init
	ld b,25
framelp4
	push bc
	halt
	call plasma
	call plasma_update
	halt
	call plasma_update
	call p_count_beats
	call leapframe
	pop bc
	djnz framelp4

	ld hl,leap_sprite5
	call leap_init
	ld b,17
framelp5
	push bc
	halt
	call plasma
	call plasma_update
	halt
	call plasma_update
	call p_count_beats
	call leapclear
	pop bc
	djnz framelp5

; now tweak sky_wkspc so that the area covering the sprite is cyan on cyan (0x6d)
	ld b,11
	ld hl,sky_wkspc + 0x014c
	ld de,0x18
	ld a,0x6d
untweak_sky_lp
	rept 8
		ld (hl),a
		inc l
	endm
	add hl,de
	djnz untweak_sky_lp

	ld b,8
framelp5a
	push bc
	halt
	call plasma
	call plasma_update
	halt
	call plasma_update
	call p_count_beats

refillforleap_pos
	ld hl,leap_ytable
	ld bc,0
	exx
	ld b,11
refillforleap_rowlp
	exx
	ld e,(hl)
	inc hl
	ld d,(hl)
	inc hl
	rept 8
		ld a,(bc)
		and 0xaa
		ld (de),a
		inc e
		inc bc
	endm
	exx
	djnz refillforleap_rowlp
	exx
	ld (refillforleap_pos+1),hl

	pop bc
	djnz framelp5a

	ld bc,50
frame_exit_lp
	push bc
	halt
	call plasma
	call plasma_update
	halt
	call plasma_update
	call p_count_beats
	pop bc

	dec bc
	ld a,b
	or c
	jp nz,frame_exit_lp

	ret

leap_init
	ld (leapsprite_addr+1),hl
	ld hl,row_seq
	ld (rowseq_pos+1),hl
	ld a,81
	ld (leapframe_ctr+1),a
	ret

leapframe
leapframe_ctr
	ld a,85/5
	dec a
	ret z
	ld (leapframe_ctr+1),a

	call paintleaprow
	call paintleaprow
	call paintleaprow
	call paintleaprow
	call paintleaprow
	ret

leapclear
	ld a,(leapframe_ctr+1)
	dec a
	ret z
	ld (leapframe_ctr+1),a
	call clearleaprow
	call clearleaprow
	call clearleaprow
	call clearleaprow
	call clearleaprow
	ret

paintleaprow
rowseq_pos
	ld hl,row_seq
	ld a,(hl)
	inc hl
	ld (rowseq_pos+1),hl

	; translate a to screen pos
	ld l,a
	ld h,0
	add hl,hl
	ld bc,leap_ytable+14
	add hl,bc
	ld e,(hl)
	inc hl
	ld d,(hl)

	; translate a to sprite pos
	ld l,a
	ld h,0
	add hl,hl
	add hl,hl
	add hl,hl
leapsprite_addr
	ld bc,leap_sprite1
	add hl,bc

	; copy
	rept 8
	ldi
	endm
	ret

clearleaprow
	ld hl,(rowseq_pos+1)
	ld a,(hl)
	inc hl
	ld (rowseq_pos+1),hl

	; translate a to screen pos
	ld l,a
	ld h,0
	add hl,hl
	ld bc,leap_ytable+14
	add hl,bc
	ld e,(hl)
	inc hl
	ld d,(hl)
	xor a

	; copy
	rept 8
	ld (de),a
	inc e
	endm
	ret

row_seq
	db 23, 13, 57, 63, 12, 75, 45, 48, 56, 29, 32, 61, 39, 26, 19, 9, 22, 3, 31, 34, 47, 60, 49, 10, 51, 58, 38, 41, 53, 43, 68, 18, 6, 55, 46, 69, 77, 79, 65, 66, 27, 8, 50, 0, 4, 36, 21, 72, 1, 59, 67, 33, 24, 25, 80, 62, 30, 37, 14, 35, 76, 74, 78, 54, 52, 28, 73, 5, 64, 7, 15, 16, 2, 42, 17, 71, 40, 20, 70, 44, 11
	; padding
	db 0,0,0,0,0,0,0,0

leap_ytable
	dw 0x488c, 0x498c, 0x4a8c, 0x4b8c, 0x4c8c, 0x4d8c, 0x4e8c, 0x4f8c
	dw 0x48ac, 0x49ac, 0x4aac, 0x4bac, 0x4cac, 0x4dac, 0x4eac, 0x4fac
	dw 0x48cc, 0x49cc, 0x4acc, 0x4bcc, 0x4ccc, 0x4dcc, 0x4ecc, 0x4fcc
	dw 0x48ec, 0x49ec, 0x4aec, 0x4bec, 0x4cec, 0x4dec, 0x4eec, 0x4fec

	dw 0x500c, 0x510c, 0x520c, 0x530c, 0x540c, 0x550c, 0x560c, 0x570c
	dw 0x502c, 0x512c, 0x522c, 0x532c, 0x542c, 0x552c, 0x562c, 0x572c
	dw 0x504c, 0x514c, 0x524c, 0x534c, 0x544c, 0x554c, 0x564c, 0x574c
	dw 0x506c, 0x516c, 0x526c, 0x536c, 0x546c, 0x556c, 0x566c, 0x576c
	dw 0x508c, 0x518c, 0x528c, 0x538c, 0x548c, 0x558c, 0x568c, 0x578c
	dw 0x50ac, 0x51ac, 0x52ac, 0x53ac, 0x54ac, 0x55ac, 0x56ac, 0x57ac
	dw 0x50cc, 0x51cc, 0x52cc, 0x53cc, 0x54cc, 0x55cc, 0x56cc, 0x57cc
;	dw 0x50ec, 0x51ec, 0x52ec, 0x53ec, 0x54ec, 0x55ec, 0x56ec, 0x57ec

leap_sprite1
	incbin "leap.bin"
leap_sprite2 equ leap_sprite1 + 8*81
leap_sprite3 equ leap_sprite2 + 8*81
leap_sprite4 equ leap_sprite3 + 8*81
leap_sprite5 equ leap_sprite1 + 0x0690 ; handy whitespace here

p_count_beats
p_beat_frame_counter
	ld a,75
	sub 16
	jp nc,p_beat_counter_noreset
	push af
p_beat_counter
	ld hl,0
	inc hl
	ld (p_beat_counter+1),hl
p_beat_interrupt_ptr
	call p_beat
	pop af
	add a,75
	ld (p_beat_frame_counter+1),a
	ret

p_beat_counter_noreset
	ld (p_beat_frame_counter+1),a
	call sky_render
	call sky_show
	ret

p_beat
	ld a,0x1f
	inc a
	and 0x1f
	ld (p_beat+1),a
	ld l,a
	ld h,0
	ld de,beat_seq
	add hl,de
	ld a,(hl)
	bit 0,a
	jp nz,new_rects

	bit 1,a
	call nz,new_palette

	call sky_render
	call sky_show

	ret


new_rects
	ld hl,mask
	ld b,0
	xor a
mask_clear_lp
	ld (hl),a
	inc hl
	ld (hl),a
	inc hl
	ld (hl),a
	inc hl
	djnz mask_clear_lp

rect_seq_pos
	ld ix,rect_seq
	call new_rect
	call new_rect
	call new_rect
	ld (rect_seq_pos+2),ix
	ret

new_rect
	ld h,(ix+0) ; left
	ld l,(ix+1) ; top
	ld c,(ix+2) ; width
	ld b,(ix+3) ; height
	ld a,(ix+4) ; colour
	ld de,5
	add ix,de
	ld e,h

mask_rect
	ld h,0
	add hl,hl
	add hl,hl
	add hl,hl
	add hl,hl
	add hl,hl
	ld d,0
	add hl,de

	ld de,mask

	; de = attr display, hl = offset into attr display, bc = height/width, a = colour
fill_attr_rect
	add hl,de

mask_row_lp
	push bc
	push hl
	ld b,c
mask_col_lp
		ld (hl),a
		inc l
	djnz mask_col_lp

	pop hl
	ld de,0x0020
	add hl,de
	pop bc
	djnz mask_row_lp
	ret

new_palette
palette_seq_pos
	ld hl,palette_seq
	ld a,(hl)
	inc hl
	ld (palette_sel+2),a
	ld a,(hl)
	inc hl
	out (254),a
	ld (palette_seq_pos+1),hl
	ret

plasma_update
	ld a,(plasma_x0 + 1)
	add a,3
	ld (plasma_x0 + 1),a

	ld a,(plasma_y0 + 1)
	dec a
	ld (plasma_y0 + 1),a

	ld a,(plasma_y1 + 1)
	add a,5
	ld (plasma_y1 + 1),a

	ld a,(pal_offset+1)
	add a,7
	ld (pal_offset+1),a
	ret

plasma

plasma_x0
	ld hl,sine
plasma_dx0
	ld c,10
	exx
plasma_x1
	ld hl,sine

	ld b,32
plasma_dx1
	ld c,9
	ld de,plasma_row_data

plasma_row_lp
	exx
	ld a,c ; advance plasma_x0
	add a,l
	ld l,a
	ld a,(hl) ; read sine element
	exx
	add a,(hl) ; add other sine element
	ld (de),a ; write to data table
	inc e ; advance data table
	ld a,c ; advance plasma_x2
	add a,l
	ld l,a
	djnz plasma_row_lp

plasma_y0
	ld hl,sine
plasma_dy0
	ld c,13
	exx
plasma_y1
	ld hl,sine

	ld b,24
plasma_dy1
	ld c,23
	ld de,plasma_col_data

plasma_col_lp
	exx
	ld a,c ; advance plasma_y0
	add a,l
	ld l,a
	ld a,(hl) ; read sine element
	exx
	add a,(hl) ; add other sine element
	ld (de),a ; write to data table
	inc e ; advance data table
	ld a,c ; advance plasma_y2
	add a,l
	ld l,a
	djnz plasma_col_lp

; apply pal offset to plasma_col_data
pal_offset
	ld d,0
	ld hl,plasma_col_data
	ld b,24
pal_offset_lp
	ld a,(hl)
	add a,d
	ld (hl),a
	inc l
	djnz pal_offset_lp


	ld de,0x5800
	ld hl,mask
	exx

palette_sel
	ld de,palette5
	ld hl,plasma_col_data
	ld b,24

; at start of loop: de'=screen, hl'=mask, de=palette, hl=plasma_col ptr, b=loop counter
plasma_draw_row_lp
	ld c,(hl) ; fetch plasma_col entry
	inc l ; advance plasma_col

	exx

	ld bc,plasma_row_data

		; now (and for the bulk of the inner loop), de=screen, bc=plasma_row ptr, hl=mask
		; de'=palette, hl'=plasma_col ptr, b' = loop counter, c' = plasma_col entry

	rept 31

		ld a,(bc) ; x component
		inc c ; advance x
		bit 6,(hl)
		jr nz,$+8
		exx
		add a,c ; y component
		ld e,a ; lookup into from texture
		ld a,(de)
		exx
		ld (de),a ; write to screen
		inc e ; advance screen
		inc l ; advance mask

	endm

	bit 6,(hl)
	jr nz,nxt32

	ld a,(bc)
	exx
	add a,c
	ld e,a
	ld a,(de)
	exx
	ld (de),a
nxt32
	inc de
	inc hl

	exx
	dec b
	jp nz,plasma_draw_row_lp

	ret

beat_seq
	db 1 ; not
	db 0
	db 1 ; not
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 1 ; not
	db 0
	db 0
	db 0
	db 1 ; take
	db 1 ; my
	db 1 ; heart
	db 0
	db 2 ; beat
	db 0
	db 0
	db 0
	db 2 ; beat
	db 0
	db 0
	db 0
	db 2 ; beat
	db 0
	db 0
	db 0
	db 1 ; you
	db 1 ; can

palette_seq
	db high palette1, 3, high palette2, 0, high palette3, 1, high palette4, 2, high palette5, 6
	db high palette1, 3, high palette2, 0, high palette3, 1, high palette4, 2, high palette5, 6
	db high palette1, 3, high palette2, 0, high palette3, 1, high palette4, 2, high palette5, 6

rect_seq
	include "random_rects.asm"

sky_render
	ld de,skips
	exx

	ld de,sky_wkspc
	ld b,8
	ld h,high sky_img
sky_scr_lp
	
	exx
	ex de,hl	; fetch next skipval into bc from address in de
	ld c,(hl)
	inc l
	ld b,(hl)
	inc l
	ex de,hl
	
	; initialize hl to -16*skipval
	ld hl,0
	sbc hl,bc
	add hl,hl
	add hl,hl
	add hl,hl
	add hl,hl
	
	push de
left_offset
	ld de,0
	add hl,de
	pop de
	
	exx
	
	rept 32
	exx
	add hl,bc
	ld a,h
	exx
	ld l,a
	ld a,(hl)
	ld (de),a
	inc de
	endm
	
	inc h
	dec b
	jp nz,sky_scr_lp
	
	ld hl,(left_offset+1)
	ld bc,0x0234
	add hl,bc
	ld (left_offset+1),hl
	ret
	
sky_show
	ld hl,mask
	ld bc,sky_wkspc - 64
	ld de,0x5800
	exx
	ld b,0

sky_show_lp
	exx

	ld a,(hl)
	or a
	jp z,sky_noshow_1
	cp 0x42
	jp nz,sky_nocopy_1
	ld a,(bc)
sky_nocopy_1
	ld (de),a
sky_noshow_1
	inc hl
	inc de
	inc bc

	ld a,(hl)
	or a
	jp z,sky_noshow_2
	cp 0x42
	jp nz,sky_nocopy_2
	ld a,(bc)
sky_nocopy_2
	ld (de),a
sky_noshow_2
	inc hl
	inc de
	inc bc

	ld a,(hl)
	or a
	jp z,sky_noshow_3
	cp 0x42
	jp nz,sky_nocopy_3
	ld a,(bc)
sky_nocopy_3
	ld (de),a
sky_noshow_3
	inc hl
	inc de
	inc bc

	exx
	djnz sky_show_lp

	ret

	align 0x0100
sky_img
	incbin "sky.bin"

	align 0x0100
skips
	include "skips.asm"
	align 0x0100
sky_wkspc
	rept 0x300
	db 0x6d
	endm

	align 0x0100
sine
	include "plasma_sine.asm"

palette1
	include "royal_palette.asm"
palette2
	include "melo_pal.asm"
palette3
	include "blues_pal.asm"
palette4
	include "firecode_palette.asm"
palette5
	include "greens_palette.asm"

mask
	ds 0x0300

plasma_row_data
	ds 32
plasma_col_data
	ds 24

preserveme
	db 42
