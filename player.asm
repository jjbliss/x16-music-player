!to "PLAYER.PRG", cbm

!src "macros.inc"

*=$0801
    !byte $0b,$08,$01,$00,$9e,$32,$30,$36,$31,$00,$00,$00


;ZeroPage registers
;assume that these are very volatile
Z0 = $00
Z1 = $01

;Address storage registers
A0 = $10
A1 = $12
A2 = $14

;Sound
MUSIC_COUNTER = $70 ; and $71
MUSIC_POINTER = $72 ; and $73
MUSIC_ON = $74
YM2151_REG = $9fe0
YM2151_DATA = $9fe1

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
	jmp setup_done

.end_program:
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
	jsr load_from_file_to_highram
	rts

next_music:
	lda MUSIC_ON
	beq .nm_done
	lda MUSIC_COUNTER
	bne .wait
	ldy #0
	lda (MUSIC_POINTER),y
	beq .nm_done
	sta Z0 ; number of commands to read
.nm_loop:
	+ADD_TO_16 MUSIC_POINTER, 1
	lda (MUSIC_POINTER),y
	sta YM2151_REG
	+ADD_TO_16 MUSIC_POINTER, 1
	lda (MUSIC_POINTER),y
	sta YM2151_DATA

	dec Z0
	lda Z0
	bne .nm_loop
	+ADD_TO_16 MUSIC_POINTER, 1
	lda (MUSIC_POINTER),y
	sta MUSIC_COUNTER
	+ADD_TO_16 MUSIC_POINTER, 1
	rts
.wait:
	dec MUSIC_COUNTER
	rts
.nm_done:
	lda #0
	sta MUSIC_ON
	sta MUSIC_POINTER
	jsr reset_sound
	rts


reset_sound:
	ldx #0
.reset_loop:
	txa
	sta YM2151_REG
	lda #0
	sta YM2151_DATA
	txa
	clc
	adc #1
	tax
	bcc .reset_loop
.reset_end:
	rts

;A1 should be pointing to filename
;A2 should be pointing to filename length
load_from_file_to_highram:
	;$FFBA: SETLFS – set LA, FA and SA
	lda #0 ; logical number (?)
	ldx #1 ; device number
	ldy #0 ; secondary address (?)
	jsr SETLFS

	;$FFBD: SETNAM – set filename
	ldy #0
	lda (A2),y
	ldx A1
	ldy A1+1
	jsr SETNAM

	lda Z1
	sta MEMORY_BANK

	lda #<HIGH_RAM
	tax
	lda #>HIGH_RAM
	tay
	lda #0
	jsr LOAD

	rts


	!byte 8
music_filename:
	!pet "music.sp"

irq_redirect:
	!fill 2
