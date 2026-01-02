;  crt0.s - Custom crt0.s for a Z80

	.module crt0
	.optsdcc -mz80 sdcccall(1)
	.globl	_main

	.area	_HEADER (ABS)
	.org	0x100
	ld	sp,(0x0006)

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

	.area   _GSINIT
gsinit::
	ld	bc, #l__INITIALIZER
	ld	a, b
	or	a, c
	jr	Z, gsinit_next
	ld	de, #s__INITIALIZED
	ld	hl, #s__INITIALIZER
	ldir

gsinit_next:

	.area   _GSFINAL
	ret
; vim:set ft=z80:
