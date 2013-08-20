loading_stripes

set_stripe_pattern
stripe_ptr
	ld a,255
	inc a
	ld (stripe_ptr+1),a

	cp 52	; once we hit beat 26, slow down the fakeload for the attribute section
	jr nz,no_fakeload_slowdown
	ld bc,6
	ld (flb_rate+1),bc
no_fakeload_slowdown
	cp 65 ; exit on beat 32.5
	ret z

	srl a
	ld l,a
	ld h,0
	ld de,stripe_tbl
	add hl,de

	ld d,(hl)

	ld hl,0x0601	; alternate between these bytes for port writes
	ld c,0xfe
	ld e,0x42	; delay length

stripelp
	rlc d	; get next bit into carry flag
	sbc a,a ; a=255 if carry, 0 if not
	and e	; a=e if carry, 0 if not
	add a,e ; a=e*2 if carry, e if not

	out (c),h
	ld b,a
zzz1
	djnz zzz1

	nop
	nop
	nop
	nop
	nop	; 5 x nop = same length as the rlc logic above
	out (c),l
	ld b,a
zzz2
	djnz zzz2
stripe_gate
	jp stripelp	; interrupt routine will poke this to LD BC,stripelp to exit the loop

	ld a,0xc3 ; opcode for JP
	ld (stripe_gate),a
	ld c,0xfe
	jp set_stripe_pattern

fakeload_leadin equ 0x0270
fake_load_bytes
flb_src
	ld hl,poster_scr - fakeload_leadin
flb_dest
	ld de,0x4000 - fakeload_leadin ; a bit below 0x4000 to get two beats lead-in
	ld a,0x5b ; stop memory writes from passing 0x5b00
	cp d
	ret z
flb_rate
	ld bc,14 ; 14 bytes per frame means that we fakeload bytes at sort of the right speed
	ldir
	ld (flb_dest+1),de
	ld (flb_src+1),hl
	ret

change_stripes
	; break out of stripe_gate
	ld a,0x01 ; opcode for LD BC
	ld (stripe_gate),a
	ret

stripe_tbl
	db 0x00, 0xff
	db 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0x00, 0x00
	db 0x24, 0x24, 0x24, 0x24, 0x24, 0x24, 0xff, 0xff
	db 0xfe, 0xfe, 0xfe, 0xfe, 0x00, 0x00, 0x00, 0x00
	db 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08
