

;A1 should be pointing to filename
;A2 should be pointing to filename length
load_from_file_to_highram:
	lda MEMORY_BANK
	pha

	+SYS_SET_RAM_BANK 1

	;$FFBA: SETLFS – set LA, FA and SA
	lda #0 ; logical number (?)
	ldx #8 ; device number
	ldy #0 ; secondary address (?)
	jsr SETLFS

	;$FFBD: SETNAM – set filename
	ldy #0
	lda (A2),y
	sta Z0
	stz Z1
	+SYS_COPY_FROM_IND_VARSIZE A1, blank_string_space, Z0
	ldy #0
	lda (A2),y
	ldx #<blank_string_space
	ldy #>blank_string_space
	jsr SETNAM

	pla
	sta MEMORY_BANK

	lda #<HIGH_RAM
	tax
	lda #>HIGH_RAM
	tay
	lda #0
	jsr LOAD
	rts

blank_string_space:
	!fill $20
