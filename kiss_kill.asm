; pasmo-compatible macro to assemble the following code at the next n-byte page boundary
align   macro n
        org ($ + n - 1) / n * n
        endm

	org 0x8000

	call vidplay_init

	di
	ld a,0xbe
	ld i,a
	im 2

	ld bc,0x7ffe
wait_space_to_start
	in a,(c)
	and 1
	jr nz,wait_space_to_start
	ei

	ld de,4
	call wait_for_beat

	; page 3 (second contended page) for loadingstripes data
	ld bc,0x7ffd
	ld a,(25003)
	out (c),a

	ld hl,change_stripes
	ld (beat_interrupt_ptr+1),hl
	ld hl,fake_load_bytes
	ld (std_interrupt_ptr+1),hl

	call loading_stripes
	xor a
	out (254),a

	ld hl,no_interrupt
	ld (beat_interrupt_ptr+1),hl
	ld (std_interrupt_ptr+1),hl

	; page 0 for oscilloscope data
	ld bc,0x7ffd
	ld a,0x10
	out (c),a

	ld de,71
	call wait_for_beat

	ld hl,osc_frame
	ld (std_interrupt_ptr+1),hl

	ld de,92
	call wait_for_beat
	call lightning

	call spriteplay ; on the radio
	call otr_static_fade

	ld de,120
	call wait_for_beat
	call spriteplay_clap

	call oyl_fade

	ld hl,runner_and_osc_int
	ld (std_interrupt_ptr+1),hl

	ld de,150 ; first Kiss! Kill!
	call wait_for_beat
	
	ld hl,no_interrupt
	ld (beat_interrupt_ptr+1),hl
	ld (std_interrupt_ptr+1),hl

	call quarterscreen2

	; page 6 (second uncontended page) for rotozoomer
	ld bc,0x7ffd
	ld a,(25001)
	out (c),a
	call rotozoom_start

	; page 1 (first contended page)
	ld bc,0x7ffd
	ld a,(25002)
	out (c),a
	call vsplit

	ld de,230 ; first chorus
	call wait_for_beat
	call vidplay_play

	ld hl,0x4000
	ld de,0x4001
	ld (hl),l
	ld bc,0x1aff
	ldir

	ld b,18
	call attrfuzz

	ld de,368
	call wait_for_beat
	call falling

	ld b,18
	call attrfuzz

	; page 4 (first uncontended page) for spiral
	ld bc,0x7ffd
	ld a,(25000)
	out (c),a
	call spiral_start

	ld de,472 ; second chorus
	call wait_for_beat
	call vidplay_chorus2

	ld bc,0x7ffd
	ld a,0x10
	out (c),a

	call plasma_init
	ld de,598 ; bridge
	call wait_for_beat
	call plasma_run


	ld de,720 ; final chorus
	call wait_for_beat
	xor a
	out (254),a
	call vidplay_final

	call tvnoise

	di
	im 1
	ei
	ret

runner_and_osc_int
	call runner_frame
	call osc_frame
	ret

wait_for_beat
	ld hl,(beat_counter+1)
	or a
	sbc hl,de
	ret nc
	halt
	jr wait_for_beat

	include "loadingstripes.asm"
	include "loadingstripes_data.sym"

	include "oscilloscope.asm"

	include "lightning.asm"

	include "spriteplay.asm"

	include "deltaplay.asm"
	include "quarterscreen.asm"

	include "vidplay.asm"

	include "tvnoise.asm"

	include "runner.asm"

	include "falling.asm"

	include "attrfuzz.asm"

	org 0xbe00
	rept 0x101
		db 0xbf
	endm

	org 0xbfbf
	push af
	push bc
	push de
	push hl
beat_frame_counter
	ld a,75
	sub 8
	jp nc,beat_counter_noreset
	push af
beat_counter
	ld hl,0
	inc hl
	ld (beat_counter+1),hl
beat_interrupt_ptr
	call no_interrupt
	pop af
	add a,75
beat_counter_noreset
	ld (beat_frame_counter+1),a

std_interrupt_ptr
	call no_interrupt

	pop hl
	pop de
	pop bc
	pop af
	ei
no_interrupt
	ret

	org 0xc000
	include "plasma.asm"

osc_data
	include "assets/oscilloscope_data.asm"

vsplit_data equ 0xc000
rotozoom_start equ 0xe800
spiral_start equ 0xf000
