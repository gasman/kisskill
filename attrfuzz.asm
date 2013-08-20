; enter with b = frame count/2
attrfuzz
	ld hl,0
	ld (attrfuzz_src+1),hl
attrfuzz_frmlp
	halt
	halt
	push bc
	call attrfuzz_frame
	pop bc
	djnz attrfuzz_frmlp
	ret

attrfuzz_frame
attrfuzz_src
	ld hl,0
	ld de,0x5800
	ld b,0

attrfuzz_lp
	rept 3
	ld c,(hl)
	srl c
	sbc a,a
	and c
	ld (de),a
	inc de
	inc hl
	endm
	djnz attrfuzz_lp

	ld (attrfuzz_src+1),hl
	ret
