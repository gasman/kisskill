osc_frame
osc_bar_ctr
	ld c,0
osc_frame_ctr
	ld a,151
	dec a
	jp nz,osc_frame_noloop

	; move to next bar
	inc c
	ld a,151
osc_frame_noloop
	ld (osc_frame_ctr+1),a
	ld b,a
	ld a,c
	ld (osc_bar_ctr+1),a
	and 0x03
	jp nz,osc_vert_plot_bunch

	; enter with b = frame number, counting down from 150
osc_horz_plot_bunch
	ld a,b
	cp 1
	jr z,osc_horz_unplot_bunch ; on final frame, unplot instead

	ld a,146 ; would be 150, but we want the 4 trailing frames too
	sub b

	push af
	ld c,0x01
	call osc_horz_plot
	pop af
	inc a

	push af
	ld c,0x04
	call osc_horz_plot
	pop af
	inc a

	push af
	ld c,0x05
	call osc_horz_plot
	pop af
	inc a

	push af
	ld c,0x0d
	call osc_horz_plot
	pop af
	inc a

	ld c,0x3f
	call osc_horz_plot
	ret

osc_horz_unplot_bunch
	ld a,144
	ld c,0x01
	call osc_horz_plot
	ld a,145
	ld c,0x01
	call osc_horz_plot
	ld a,146
	ld c,0x01
	call osc_horz_plot
	ld a,147
	ld c,0x01
	call osc_horz_plot
	ld a,148
	ld c,0x01
	call osc_horz_plot
	ret

	; plot oscilloscope horizontally.
	; Enter with a = frame of wave data to show (0...149)
	; c = attribute byte
osc_horz_plot
	cp 150 ; if a>150, treat as negative (add 150 to make it mod 150)
	jp c,osc_horz_nowrap
	add a,150
osc_horz_nowrap
	ld l,a
	ld h,0
	ld a,c
	ld (osc_horz_attrib+1),a
	add hl,hl
	add hl,hl
	add hl,hl
	add hl,hl
	add hl,hl ; 32 bytes per frame
	ld de,osc_data
	add hl,de
	ex de,hl

osc_horz_plot_origin
	ld bc,0x5800
osc_horz_plot_lp
	ld a,(de)

	; cp 16
	; call nc,oblit

	ld l,a
	ld h,0
	add hl,hl
	add hl,hl
	add hl,hl
	add hl,hl
	add hl,hl
	add hl,bc
osc_horz_attrib
	ld (hl),0x3f
	inc c
	inc de
	ld a,c
osc_horz_plot_limit
	cp 0x20
	jp c,osc_horz_plot_lp
	ret

	; enter with b = frame number, counting down from 150
osc_vert_plot_bunch

	; munge horizontal plotter to be higher up for next time round
	ld hl,0x5780
	ld (osc_horz_plot_origin+1),hl
	ld a,0xa0
	ld (osc_horz_plot_limit+1),a

	ld a,b
	cp 1
	jr z,osc_vert_unplot_bunch ; on final frame, unplot instead

	ld a,146 ; would be 150, but we want the 4 trailing frames too
	sub b

	push af
	ld c,0x01
	call osc_vert_plot
	pop af
	inc a

	push af
	ld c,0x04
	call osc_vert_plot
	pop af
	inc a

	push af
	ld c,0x05
	call osc_vert_plot
	pop af
	inc a

	push af
	ld c,0x0d
	call osc_vert_plot
	pop af
	inc a

	ld c,0x3f
	call osc_vert_plot
	ret

osc_vert_unplot_bunch
	ld a,144
	ld c,0x01
	call osc_vert_plot
	ld a,145
	ld c,0x01
	call osc_vert_plot
	ld a,146
	ld c,0x01
	call osc_vert_plot
	ld a,147
	ld c,0x01
	call osc_vert_plot
	ld a,148
	ld c,0x01
	call osc_vert_plot
	ret

	; Enter with a = frame of wave data to show (0...149)
	; c = attribute byte
osc_vert_plot
	cp 150 ; if a>150, treat as negative (add 150 to make it mod 150)
	jp c,osc_vert_nowrap
	add a,150
osc_vert_nowrap
	ld l,a
	ld h,0
	ld a,c
	ld (osc_vert_attrib+1),a
	add hl,hl
	add hl,hl
	add hl,hl
	add hl,hl
	add hl,hl ; 32 bytes per frame
	ld de,osc_data
	add hl,de
	ex de,hl
	ld bc,0x580b
osc_vert_plot_lp
	ld a,(de)
	ld l,a
	ld h,0
	add hl,bc

	; support masking on dissolve effect
	ld a,(hl)
	cp 0x41
	jr z,osc_vert_nodraw

osc_vert_attrib
	ld (hl),0x3f

osc_vert_nodraw
	ld hl,0x0020
	add hl,bc
	ld b,h
	ld c,l
	inc de
	ld a,b
	cp 0x5b
	jp c,osc_vert_plot_lp
	ret

; --- fade out by attribute value (slow + inefficient) ---
osc_fade
	ld hl,0x5800
osc_fade_lp
	rept 8
		ld a,(hl)
		add a,240
		ld b,a
		sbc a,a
		and b
		or 1
		ld (hl),a
		inc hl
	endm
	ld a,h
	cp 0x5b
	jp c,osc_fade_lp
	ret

; --- obliterate background - semi-broken ---
oblit
	push hl
	push de

oblit_src
	ld hl,0x0200
	ld a,r
	xor (hl)
	inc hl
	ld (oblit_src+1),hl
	ld e,a
	ld d,0x40

	rept 8
		ld a,(hl)
		ld (de),a
		inc d
		inc l
	endm

	pop de
	pop hl

	ret

unplot_buf
	ds 64
unplot_buf_end equ $
