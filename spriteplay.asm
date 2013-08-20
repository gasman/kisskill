spriteplay
	ld b,75

spriteplay_lp
	halt
	halt
	push bc

	ld a,3
	call request_sectors

	ld hl,0x4081
	call spl_8_lines
	ld hl,0x40a1
	call spl_8_lines
	ld hl,0x40c1
	call spl_8_lines
	ld hl,0x40e1
	call spl_8_lines
	ld hl,0x4801
	call spl_8_lines
	ld hl,0x4821
	call spl_8_lines
	ld hl,0x4841
	call spl_8_lines
	ld hl,0x4861
	call spl_8_lines
	ld hl,0x4881
	call spl_8_lines
	ld hl,0x48a1
	call spl_8_lines
;	ld hl,0x4840
;	call spl_8_lines
;	ld hl,0x4860
;	call spl_8_lines

	pop bc
	djnz spriteplay_lp
	ret

spriteplay_clap
	ld b,61
spriteplay_clap_lp
	halt
	halt
	push bc
	ld a,2
	call request_sectors

	ld hl,0x4804
	call spl_8x8
	ld hl,0x4824
	call spl_8x8
	ld hl,0x4844
	call spl_8x8
	ld hl,0x4864
	call spl_8x8
	ld hl,0x4884
	call spl_8x8
	ld hl,0x48a4
	call spl_8x8
	ld hl,0x48c4
	call spl_8x8
	ld hl,0x48e4
	call spl_8x8
	ld hl,0x5004
	call spl_8x8
	ld hl,0x5024
	call spl_8x8

	pop bc
	djnz spriteplay_clap_lp
	ret


spl_8_lines
	ld b,8
	ld c,0xa3	; IDE data register

spl_wait_ready
	in a,(0xbf)	; wait for 'ready' status
	add a,a	; test bit 7; will carry if set (meaning not ready)
	jr c,spl_wait_ready

spl_8_lines_lp
	push bc
	push hl
	rept 14
		ini
	endm
	in a,(c) ; dummy reads
	in a,(c)

	pop hl
	inc h
	pop bc
	djnz spl_8_lines_lp
	ret


spl_8x8
	ld b,8
	ld c,0xa3	; IDE data register

spl_8x8_wait_ready
	in a,(0xbf)	; wait for 'ready' status
	add a,a	; test bit 7; will carry if set (meaning not ready)
	jr c,spl_8x8_wait_ready

spl_8x8_lines_lp
	push bc
	push hl
	rept 8
		ini
	endm

	pop hl
	inc h
	pop bc
	djnz spl_8x8_lines_lp
	ret
