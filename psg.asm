!Zone PSG {
psg_frame:
	lda (MUSIC_POINTER)
	+BEQ_LONG .psg_zero
	sta Z0 ; number of writes
	stz PSG_ZERO_FRAMES
.pf_loop:
	+INC_MUSIC_POINTER
	lda (MUSIC_POINTER)
	sta Z2
	+INC_MUSIC_POINTER
	lda (MUSIC_POINTER)
	sta Z3

	+SYS_WRITE_24 A0, VERA_psg
	lda Z2
	+ADD_A_TO_16 A0
	+VERA_SET_ADDR_IND A0, 0
	lda Z3
	sta VERA_data

	dec Z0
	lda Z0
	+BNE_LONG .pf_loop
	rts
.psg_zero:
	lda #$FF
	sta PSG_ZERO_FRAMES
	rts


psg_reset:
	ldx #0
	+VERA_SET_ADDR VERA_psg, 1
.reset_loop:
	;jsr wait
	stz VERA_data
	stz VERA_data
	stz VERA_data
	stz VERA_data
	inx
	txa
	cmp #16
	bne .reset_loop
.reset_end:
	rts
}
