!to "VERAPLAYER.PRG", cbm
!cpu 65c02
!src "macros.inc"
!src "vera.inc"

*=$0801
	!byte $0b,$08,$01,$00,$9e,$32,$30,$36,$31,$00,$00,$00


;ZeroPage registers
;assume that these are very volatile
Z0 = $00
Z1 = $01
Z2 = $02
Z3 = $03

channel = $30
pitch = $31 ;and  $32
volume = $33
wave = $34

;Address storage registers
A0 = $10
A1 = $12
A2 = $14

;Sound
MUSIC_COUNTER = $70 ; and $71
MUSIC_POINTER = $72 ; and $73
MUSIC_ON = $74



DELAY_AMOUNT = $20


;Memory
HIGH_RAM = $A000
MEMORY_BANK = $9F61

;Routines
LOAD = $FFD5
SAVE = $FFD8
SETLFS = $FFBA
SETNAM = $FFBD



;=================================================
;=================================================
;
;   main code
;
;-------------------------------------------------
setup:
	+SYS_SET_IRQ irq_handler
	+VERA_ENABLE_IRQ
	cli
	jsr music_setup


setup_done:
	lda MUSIC_ON
	beq .end_program
	jsr wait
	jmp setup_done

.end_program:
	jsr reset_sound
	rts

wait:
	ldy #DELAY_AMOUNT
.busy_loop:
	nop
	dey
	bne .busy_loop
	rts

;=================================================
; irq_handler
;   This is essentially my "do_frame".
;-------------------------------------------------
; INPUTS: (none)
;
;-------------------------------------------------
; MODIFIES: A, X, Y
;
irq_handler:
	;check that this is a VSYNC interrupt
	lda VERA_irq
	and #1 ;check that vsync bit is set
	beq .vsync_end ; if vsync bit not set, skip to end

	;jmp to here if not VSYNC interrupt
	jsr next_music
	+VERA_ENABLE_IRQ
	+VERA_END_IRQ
.vsync_end:

	jmp (irq_redirect)




music_setup:
	lda #0
	sta MUSIC_COUNTER
	+SYS_WRITE_16 MUSIC_POINTER, HIGH_RAM
	lda #1
	sta MUSIC_ON
	;load file
	+SYS_WRITE_16 A1, music_filename
	+SYS_WRITE_16 A2, (music_filename - 1)
	+SYS_SET_RAM_BANK 2
	jsr load_from_file_to_highram

	+SYS_SET_RAM_BANK 2
	jsr reset_sound
	lda #1
	sta Z1
	rts

next_music:
	lda MUSIC_ON
	+BEQ_LONG .nm_done
	lda MUSIC_COUNTER
	+BNE_LONG .wait
	lda (MUSIC_POINTER)
	+BEQ_LONG .nm_done
	sta Z0 ; number of channels to read
.nm_loop:
	+INC_MUSIC_POINTER
	lda (MUSIC_POINTER)
	sta channel
	+INC_MUSIC_POINTER
	lda (MUSIC_POINTER)
	sta pitch
	+INC_MUSIC_POINTER
	lda (MUSIC_POINTER)
	sta pitch+1
	+INC_MUSIC_POINTER
	lda (MUSIC_POINTER)
	sta volume
	+INC_MUSIC_POINTER
	lda (MUSIC_POINTER)
	sta wave

	+SYS_WRITE_24 A0, VERA_psg
	lda channel
	asl
	asl
	+ADD_A_TO_16 A0
	+VERA_SET_ADDR_IND A0, 1
	lda pitch
	sta VERA_data
	lda pitch+1
	sta VERA_data
	lda volume
	sta VERA_data
	lda wave
	sta VERA_data

	dec Z0
	lda Z0
	+BNE_LONG .nm_loop
	+INC_MUSIC_POINTER
	lda (MUSIC_POINTER)
	sta MUSIC_COUNTER
	+INC_MUSIC_POINTER
	rts
.wait:
	dec MUSIC_COUNTER
	rts
.nm_done:
	lda #0
	sta MUSIC_ON
	sta MUSIC_POINTER
	jsr reset_sound
	+SYS_RESTORE_IRQ
	rts


reset_sound:
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



!src "fileio.asm"

	!byte 9
music_filename:
	!pet "music.vsp"




irq_redirect:
	!fill 2
