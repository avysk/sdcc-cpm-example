;; crt0.s - Custom crt0.s for a Z80

	.module crt0
	.optsdcc -mz80 sdcccall(1)
	.globl	_main

	.area	_HEADER (ABS)
	.org	0x100

	; we support only CP/M >= 2.2 on a Z80
	ld	c,#0x0C
	call	5
	cp	#0x22
	jr	c,bad_cpm_version
	ld	a,b
	or	a
	jr	nz,bad_cpm_version
	ld	sp,(0x0006)

; now let's copy the second FCB
	ld	hl,#0x6C
	ld	de,#second_fcb
	ld	bc,#36
	ldir
	call	gsinit
	call	_main
	jp	exit

bad_cpm_version:
	ld	de,#msg_bad_cpm_version
	ld	c,#0x09
	call	5
	jp	exit

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
msg_bad_cpm_version:
	.ascii	"Error: CP/M >= 2.2 on Z80 is required.\n\r$"

dma_buffer:
	.ds	128

	.area	_HEAP

	.area	_CODE

exit:
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
get_fcb:
	ld	de,#0x5C
	or	a
	jr	z,get_first
	ld	de,#second_fcb
get_first:
	ret

; Keep a if it is 0xFF, otherwise set to 0
check_ff:
	cp	#0xFF
	ret	z
	xor	a
	ret

;; BDOS F_OPEN for file names supplied on the command line
;; Input: (8-bit value in A) 0 or 1 for the first or second file name
;; Output: (8-bit value in A) 0 on success, 0xFF on failure
_f_open::
	push	af
	call	get_fcb
	call	zero_fcb_fields
	ld	hl,#0x0020
	add	hl,de
	ld	(hl),#0x00	; CR => 0
	ld	c,#0x0F		; BDOS F_OPEN
	call	5
	pop	af
	call	get_fcb
	ld	hl,#0x0020
	add	hl,de
	ld	(hl),#0x00	; CR => 0
	jr	check_ff

;; BDOS F_CLOSE for file names supplied on the command line
;; Input: (8-bit value in A) 0 or 1 for the first or second file name
;; Output: (8-bit value in A) 0 on success, 0xFF on failure
_f_close::
	call	get_fcb
	ld	c,#0x10	; BDOS F_CLOSE
	call	5
	jr	check_ff

;; BDOS F_DELETE for file names supplied on the command line
;; Input: (8-bit value in A) 0 or 1 for the first or second file name
;; Output: (8-bit value in A) 0 on success, 0xFF on failure
_f_delete::
	call	get_fcb
	call	zero_fcb_fields
	ld	c,#0x13	; BDOS F_DELETE
	call	5
	jr	check_ff

;; BDOS F_READ for file names supplied on the command line
;; Input: (8-bit value in A) 0 or 1 for the first or second file name
;; Output: (16-bit value in DE) the address of (128-byte) DMA buffer; 0 for
;; EOF, 0xFFFF on error
_f_read::
	push	af
	ld	de,#dma_buffer
	ld	c,#0x1A	; BDOS F_DMAOFF
	call	5
	pop	af
	call	get_fcb
	ld	c,#0x14	; BDOS F_READ
	call	5
	or	a
	jr	nz,bad
	ld	de,#dma_buffer
	ret
bad:
	dec	a
	jr	nz,read_error
	ld	de,#0x0000	; EOF
	ret
read_error:
	ld	de,#0xFFFF	; error
	ret

;; BDOS F_WRITE for file names supplied on the command line
;; Input: (8-bit value in A) 0 or 1 for the first or second file name
;;        (16-bit value in DE) pointer to 128 bytes of data to write
;; Output: (8-bit value in A) 0 OK, 1 directory full, 2 disk full, other value
;;         some CP/M error
_f_write::
	push	af
	ld	c,#0x1A	; BDOS F_DMAOFF
	call	5
	pop	af
	call	get_fcb
	ld	c,#0x15	; BDOS F_WRITE
	call	5
	ret


;; BDOS F_MAKE for file names supplied on the command line
;; Input: (8-bit value in A) 0 or 1 for the first or second file name
;; Output: (8-bit value in A) 0 on success, 0xFF on failure
;; NOTE: if the file already exists, CP/M will return to CCP
_f_make::
	call	get_fcb
	ld	c,#0x16	; BDOS F_MAKE
	call	5
	jr	check_ff

;; BDOS F_SIZE for file names supplied on the command line
;; Input: (8-bit value in A) 0 or 1 for the first or second file name
;; Output: (32-bit value in HLDE) file size in 128-byte records
_f_size::
	call	get_fcb
	push	de
	ld	c,#0x23	; BDOS F_SIZE
	call	5
	pop	ix
	ld	h,#0x00
	ld	l,(ix+#0x23)
	ld	d,(ix+#0x21)
	ld	e,(ix+#0x22)
	ret

	.area   _GSINIT
gsinit:
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
