quarterscreen2

	; first quarter: 0x4000, 0x4080, 0x4800
	ld a,0x1f ; paper 3 ink 7
	ld hl,0x5800
	call quarterscreen_attr

	ld b,14
qs2_lp1
	push bc
	halt
	call runner_frame
	halt
	call runner_frame

	ld a,3
	call request_sectors

	ld hl,0x4000
	call qs_16x32
	ld hl,0x4080
	call qs_16x32
	ld hl,0x4800
	call qs_16x32
	pop bc
	djnz qs2_lp1

	; second quarter: 0x4010, 0x4090, 0x4810
	ld a,0x0d ; paper 1 ink 5
	ld hl,0x5810
	call quarterscreen_attr

	ld b,14
qs2_lp2
	push bc
	halt
	call runner_frame
	halt
	call runner_frame

	ld a,3
	call request_sectors

	ld hl,0x4010
	call qs_16x32
	ld hl,0x4090
	call qs_16x32
	ld hl,0x4810
	call qs_16x32
	pop bc
	djnz qs2_lp2

	; third quarter: 0x4880, 0x5000, 0x5080
	ld a,0x04 ; paper 0 ink 4
	ld hl,0x5980
	call quarterscreen_attr

	ld b,14
qs2_lp3
	push bc
	halt
	call runner_frame
	halt
	call runner_frame

	ld a,3
	call request_sectors

	ld hl,0x4880
	call qs_16x32
	ld hl,0x5000
	call qs_16x32
	ld hl,0x5080
	call qs_16x32
	pop bc
	djnz qs2_lp3

	; fourth quarter: 0x4890, 0x5010, 0x5090
	ld a,0x16 ; paper 2 ink 6
	ld hl,0x5990
	call quarterscreen_attr

	ld b,14
qs2_lp4
	halt
	halt
	push bc

	ld a,3
	call request_sectors

	ld hl,0x4890
	call qs_16x32
	ld hl,0x5010
	call qs_16x32
	ld hl,0x5090
	call qs_16x32
	pop bc
	djnz qs2_lp4

	; fade out quarter attrs
	ld hl,0x5800
	call quarterscreen_fade
	ld hl,0x5810
	call quarterscreen_fade
	ld hl,0x5980
	call quarterscreen_fade
	ld hl,0x5990
	call quarterscreen_fade

	ret


qs_16x32
	ld c,0xa3	; IDE data register

qs_16x32_wait_ready
	in a,(0xbf)	; wait for 'ready' status
	add a,a	; test bit 7; will carry if set (meaning not ready)
	jr c,qs_16x32_wait_ready

	ld de,0x0020
	call qs_16x8
	add hl,de
	call qs_16x8
	add hl,de
	call qs_16x8
	add hl,de
qs_16x8
	push hl
	ld b,8
qs_16x8_lines_lp
	push bc
	push hl
	rept 16
		ini
	endm

	pop hl
	inc h
	pop bc
	djnz qs_16x8_lines_lp
	pop hl
	ret

; enter with a = attr, hl = addr
quarterscreen_attr
	ld b,12
	ld de,0x0010
quarterscreen_attr_lp
	rept 16
		ld (hl),a
		inc hl
	endm
	add hl,de
	djnz quarterscreen_attr_lp
	ret

quarterscreen_fade
	ld b,8
quarterscreen_fade_lp
	push bc
	push hl

	halt

	ld a,(hl) ; get current attr
	ld b,a
	and 0x07 ; mask ink only
	dec a ; reduce ink
	jr nz,qsf_no_clamp_ink
	inc a ; ink should not go below 1
qsf_no_clamp_ink
	ld c,a ; save ink colour
	ld a,b
	and 0x38  ; mask paper only
	sub 8 ; reduce paper
	jr nc,qsf_no_clamp_paper
	xor a ; do not decrement below 0
qsf_no_clamp_paper
	or c

	call quarterscreen_attr

	pop hl
	pop bc
	djnz quarterscreen_fade_lp
	ret
