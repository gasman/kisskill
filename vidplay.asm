	include "esxdos/esxdos.inc"
	
vidplay_init
	ld ix,filename
	; attempt to open file
	ld a,'*'
	ld b,FA_READ
	rst 0x08
	db F_OPEN
	call c,error

	ld (file_handle),a

	; read a few bytes, which has the effect of setting IDE registers to the starting sector
	ld ix,buffer
	ld bc,0x000b
	rst 0x08
	db F_READ
	call c,close_and_abort

	; record current sector number
	ld ix,sector_number
	in a,(0xaf)
	ld (ix),a
	in a,(0xb3)
	ld (ix+1),a
	in a,(0xb7)
	ld (ix+2),a
	in a,(0xbb)
	ld (ix+3),a

	; close file
	ld a,(file_handle)
	rst 0x08
	db F_CLOSE
	ret

request_sectors
	ld ix,sector_number
	out (0xab),a	; sector count register
	ld l,a

	ld a,(ix+0)
	out (0xaf),a	; LBA 0..7
	add a,l 	; advance position by 'l' sectors
	ld (ix+0),a
	
	ld a,(ix+1)
	out (0xb3),a	; LBA 8..15
	adc a,0
	ld (ix+1),a
	
	ld a,(ix+2)
	out (0xb7),a	; LBA 16..23
	adc a,0
	ld (ix+2),a
	
	ld a,(ix+3)
	out (0xbb),a	; LBA 24..28
	adc a,0
	ld (ix+3),a

	ld a,0x20	; command for READ SECTORS
	out (0xbf),a
	ret

vidplay_final
	ld bc,609 ; final frame count
	jp vidplay_frame

vidplay_chorus2
	ld bc,592 ; frame count for chorus 2 ; was 582
	jp vidplay_frame

vidplay_play
	ld bc,627; frame count ; was 624

vidplay_frame
	halt

	push bc

	ld a,14 ; read 14 sectors per video frame
	call request_sectors

video_page
	ld a,0x17
	xor 0x0a	; toggle between page 5 shown/page 7 in memory and page 7 shown/page 5 in memory
	ld (video_page+1),a
	ld bc,0x7ffd
	out (c),a

	ld b,27 ; 27 blocks of 256 bytes
	ld c,0xa3	; IDE data register
	ld hl,0xc000
load_screen_block
	push bc

wait_ready
	in a,(0xbf)	; wait for 'ready' status
	add a,a	; test bit 7; will carry if set (meaning not ready)
	jr c,wait_ready

	rept 256
		ini
	endm

	pop bc
	dec b
	jp nz,load_screen_block

	pop bc
	dec bc
	ld a,b
	or c
	jp nz,vidplay_frame

	ld bc,0x7ffd ; restore paging to standard arrangement
	ld a,0x10
	out (c),a

	ret

; close file and exit with error.
close_and_abort
	ld a,(file_handle)
	rst 0x08
	db F_CLOSE
error
	ld a,2
	out (254),a
	ld a,6
	out (254),a
	jp error

file_handle
	db 0

filename
	db "kisskill.dat", 0
buffer
	ds 16
sector_number
	ds 4
