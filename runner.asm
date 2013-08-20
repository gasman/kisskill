runner_frame
	ld a,3
	dec a
	jr nz,runner_skipframe

	call runner_draw_currframe ; undraw
	call runner_advance
	call runner_draw_currframe

	ld a,3
runner_skipframe
	ld (runner_frame+1),a
	ret

runner_advance
	ld a,(runner_frameno+1)
	inc a
	cp 12
	jr nz,runner_nowrap
	xor a
runner_nowrap
	ld (runner_frameno+1),a

	jr z,runner_nextchar
	cp 3
	jr z,runner_nextchar
	cp 6
	jr z,runner_nextchar
	cp 9
	jr z,runner_nextchar

	ret

runner_nextchar
	ld a,(runner_screenpos+1)
	inc a
	ld (runner_screenpos+1),a
	ret

runner_draw_currframe

runner_frameno
	ld b,0
runner_screenpos
	ld de,0x5063

	; enter with b=frame no, de=screen pos
runner_draw_frame
	ld h,b
	ld l,0
	srl h
	rr l
	ld bc,runner_sprites
	add hl,bc

	ld a,e
	and 0x1f
	cp 3
	jp z,runner_draw_frame_w1
	cp 4
	jp z,runner_draw_frame_w2
	cp 5
	jp z,runner_draw_frame_w3

runner_draw_frame_w4
	ld b,32
runner_rowlp_w4
	push de

	ld a,(de)
	xor (hl)
	ld (de),a
	inc l
	inc e

	ld a,(de)
	xor (hl)
	ld (de),a
	inc l
	inc e

	ld a,(de)
	xor (hl)
	ld (de),a
	inc l
	inc e

	ld a,(de)
	xor (hl)
	ld (de),a
	inc hl

	pop de
	call upde

	djnz runner_rowlp_w4
	ret

	; left clip to 3 chars
runner_draw_frame_w3
	ld b,32
	inc e
runner_rowlp_w3
	push de

	inc l

	ld a,(de)
	xor (hl)
	ld (de),a
	inc l
	inc e

	ld a,(de)
	xor (hl)
	ld (de),a
	inc l
	inc e

	ld a,(de)
	xor (hl)
	ld (de),a
	inc hl

	pop de
	call upde

	djnz runner_rowlp_w3
	ret

	; left clip to 2 chars
runner_draw_frame_w2
	ld b,32
	inc e
	inc e

runner_rowlp_w2
	inc l
	inc l

	ld a,(de)
	xor (hl)
	ld (de),a
	inc l
	inc e

	ld a,(de)
	xor (hl)
	ld (de),a
	inc hl

	dec e
	call upde

	djnz runner_rowlp_w2
	ret

	; left clip to 1 char
runner_draw_frame_w1
	ld b,32

	inc e
	inc e
	inc e

runner_rowlp_w1
	inc l
	inc l
	inc l

	ld a,(de)
	xor (hl)
	ld (de),a
	inc hl

	call upde

	djnz runner_rowlp_w1
	ret

	align 0x100
runner_sprites
	incbin "assets/runner_sprites.bin"
