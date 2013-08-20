vsplit
	; first quarter: 0x4000, 0x4880
	ld a,0x42
	ld hl,0x5800
	call vsplit_attr

	ld b,14
	ld hl,vsplit_data
vs1lp
	push bc
	halt
	ld de,0x4000
	call delta_frame
	halt
	ld de,0x4880
	call delta_frame
	pop bc
	djnz vs1lp

	; second quarter: 0x4008, 0x4888
	ld a,0x44
	ld hl,0x5808
	call vsplit_attr

	ld b,14
	ld hl,vsplit_data
vs2lp
	push bc
	halt
	ld de,0x4008
	call delta_frame
	halt
	ld de,0x4888
	call delta_frame
	pop bc
	djnz vs2lp

	; third quarter: 0x4010, 0x4890
	ld a,0x43
	ld hl,0x5810
	call vsplit_attr

	ld b,14
	ld hl,vsplit_data
vs3lp
	push bc
	halt
	ld de,0x4010
	call delta_frame
	halt
	ld de,0x4890
	call delta_frame
	pop bc
	djnz vs3lp

	; fourth quarter: 0x4018, 0x4898
	ld a,0x46
	ld hl,0x5818
	call vsplit_attr

	ld b,14
	ld hl,vsplit_data
vs4lp
	push bc
	halt
	ld de,0x4018
	call delta_frame
	halt
	ld de,0x4898
	call delta_frame
	pop bc
	djnz vs4lp
	ret



; enter with a = attr, hl = addr
vsplit_attr
	ld b,24
	ld de,0x0018
vsplit_attr_lp
	rept 8
		ld (hl),a
		inc hl
	endm
	add hl,de
	djnz vsplit_attr_lp
	ret

delta_frame
	ld (spback+1),sp
	ld sp,hl

	ex de,hl
	dec hl 	; initial hl (screen position) is display position - 1,
		; so that a write to the first byte can be denoted by an offset of +1
	xor a
deltalp
	pop de
	ld b,d
	ld d,0
	cp e
	jr z,delta_done
	add hl,de
	ld (hl),b
	jp deltalp

delta_done
	; transfer sp (current delta data pointer) to hl
	ld hl,0
	add hl,sp
spback
	ld sp,0
	ret

upde
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

uphl
	inc h
	ld a,h
	and 7
	ret nz
	ld a,l
	add a,32
	ld l,a
	ret c
	ld a,h
	sub 8
	ld h,a
	ret
