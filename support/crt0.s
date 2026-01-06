;  crt0.s - Custom crt0.s for a Z80

	.module crt0
	.optsdcc -mz80 sdcccall(1)
	.globl	_main

	.area	_HEADER (ABS)
	.org	0x100
	ld	sp,(0x0006)

; now let's copy the second FCB
	ld	hl,#0x6C
	ld	de,#second_fcb
	ld	bc,#36
	ldir
	call	gsinit
	call	_main
	jp	_exit

	.area	_HOME
	.area	_CODE
	.area	_INITIALIZER
	.area	_GSINIT
	.area	_GSFINAL

	.area	_DATA
	.area	_INITIALIZED
	.area	_BSEG
	.area	_BSS
second_fcb:
	.ds	36

	.area	_HEAP

	.area	_CODE

_exit::
	jp	0	; CP/M warm boot

_getchar::
	ld	c,#1	; BDOS C_READ
	jp	5
_putchar::
	ld	e,a
	ld	c,#2	; BDOS C_WRITE
	jp	5


zero_fcb_fields:
	ld	hl,#0x000C
	add	hl,de
	ld	(hl),#0x00	; EX => 0
	inc	hl
	ld	(hl),#0x00	; S1 => 0
	inc	hl
	ld	(hl),#0x00	; S2 => 0
	inc	hl
	ld	(hl),#0x00	; RC => 0
	ret

; Loads in de the address of FCB for the file name supplied on the command line
; Input: (8-bit value in A) 0 or 1 for the first or second file name
; Output: DE points to the FCB
_get_fcb:
	ld	de,#0x5C
	or	a
	jr	z,get_first
	ld	de,#second_fcb
get_first:
	ret

; Keep a if it is 0xFF, otherwise set to 0
_check_ff:
	cp	#0xFF
	ret	z
	xor	a
	ret

;; BDOS F_OPEN for file names supplied on the command line
;; Input: (8-bit value in A) 0 or 1 for the first or second file name
;; Output: (8-bit value in A) 0 on success, 0xFF on failure
_f_open::
	push	af
	call	_get_fcb
	ld	hl,#0x0020
	add	hl,de
	ld	(hl),#0x00	; CR => 0
	ld	c,#0x0F		; BDOS F_OPEN
	call	5
	pop	af
	call	_get_fcb
	ld	hl,#0x0020
	add	hl,de
	ld	(hl),#0x00	; CR => 0
	jr	_check_ff

;; BDOS F_CLOSE for file names supplied on the command line
;; Input: (8-bit value in A) 0 or 1 for the first or second file name
;; Output: (8-bit value in A) 0 on success, 0xFF on failure
_f_close::
	call	_get_fcb
	ld	c,#0x10	; BDOS F_CLOSE
	call	5
	jr	_check_ff

;; BDOS F_DELETE for file names supplied on the command line
;; Input: (8-bit value in A) 0 or 1 for the first or second file name
;; Output: (8-bit value in A) 0 on success, 0xFF on failure
_f_delete::
	call	_get_fcb
	ld	c,#0x13	; BDOS F_DELETE
	call	5
	jr	_check_ff

;; BDOS F_MAKE for file names supplied on the command line
;; Input: (8-bit value in A) 0 or 1 for the first or second file name
;; Output: (8-bit value in A) 0 on success, 0xFF on failure
;; NOTE: if the file already exists, CP/M will return to CCP
_f_make::
	call	_get_fcb
	ld	c,#0x16	; BDOS F_MAKE
	call	5
	jr	_check_ff

	.area   _GSINIT
gsinit::
	; Initialize global/static variables
	ld	bc,#l__DATA
	ld	a,b
	or	a,c
	; if there is no data to initialize, skip
	jr	Z,zeroed_data
	; write zero to first byte of data segment
	ld	hl,#s__DATA
	ld	(hl),#0x00
	dec	bc
	ld	a,b
	or	a,c
	; if we had to initialize only one byte, done
	jr	Z,zeroed_data
	; otherwise, repeatedly copy (just written zero) to the next byte
	ld	e,l
	ld	d,h
	inc	de
	ldir
zeroed_data:

	ld	bc, #l__INITIALIZER
	ld	a, b
	or	a, c
	jr	Z, gsinit_next
	ld	de, #s__INITIALIZED
	ld	hl, #s__INITIALIZER
	ldir


.area   _GSFINAL
gsinit_next:
	ret
; vim:set ft=z80:
