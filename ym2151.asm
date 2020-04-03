!Zone YM2151{
ym_frame:
	lda (MUSIC_POINTER)
	+BEQ_LONG .ym_zero
	sta Z0 ; number of commands to read
	stz YM_ZERO_FRAMES
.nm_loop:
	+INC_MUSIC_POINTER
	lda (MUSIC_POINTER)
	sta Z2
	+INC_MUSIC_POINTER
	lda (MUSIC_POINTER)
	sta Z3
	jsr ym_add_buffer

	dec Z0
	lda Z0
	bne .nm_loop
	rts
.wait:
	dec MUSIC_COUNTER
	rts
.ym_zero:
	lda #$FF
	sta YM_ZERO_FRAMES
	rts

; Ring Buffer
ym_write:
	ldx RB_HEAD
	cpx RB_TAIL
	beq .ym_write_done
	lda #$80
.ym_wait:
	and YM2151_DATA
	bne .ym_wait
	lda RINGBUFFER,X
	sta YM2151_REG
	inx
	lda RINGBUFFER,X
	sta YM2151_DATA
	inx
	stx RB_HEAD
.ym_write_done:
	rts


;Will add Z2 and Z3 to buffer
ym_add_buffer:
	lda RB_TAIL
	clc
	adc #2 ; check if ring buffer is full
	cmp RB_HEAD
	beq .ym_buffer_done
	sta RB_TAIL
	sbc #2
	tax
	lda Z2
	sta RINGBUFFER,x
	inx
	lda Z3
	sta RINGBUFFER,x
.ym_buffer_done:
	rts

ym_reset:
	ldx #0
.reset_loop:
	jsr wait
	stx YM2151_REG
	nop ; real HW fails if you immediately write DATA after ADDRESS
	stz YM2151_DATA
	inx
	txa
	bne .reset_loop
.reset_end:
	rts
}
