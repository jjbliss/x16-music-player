!to "PLAYER.PRG", cbm
!cpu 65c02
!src "macros.inc"

*=$0801
    !byte $0b,$08,$01,$00,$9e,$32,$30,$36,$31,$00,$00,$00


;ZeroPage registers
;assume that these are very volatile
Z0 = $00
Z1 = $01
Z2 = $02
Z3 = $03

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

DELAY_AMOUNT = 1

;Ring Buffer
RINGBUFFER = $0500 ; choose a page of memory that is dedicated as a ring buffer
RB_HEAD = $15
RB_TAIL = $16

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
  ldy #DELAY_AMOUNT
.busy_loop:
  nop
  dey
  bne .busy_loop
  jsr ym_write
	jmp setup_done

.end_program:
	rts
;
; wait:
;   ldy #DELAY_AMOUNT
; .busy_loop:
;   nop
;   dey
;   bne .busy_loop
;   rts

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
  sta Z2
	+ADD_TO_16 MUSIC_POINTER, 1
	lda (MUSIC_POINTER),y
  sta Z3
  jsr ym_add_buffer

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
  ldy #DELAY_AMOUNT
.reset_busy_loop:
  nop
  dey
  bne .reset_busy_loop
  stx YM2151_REG
  nop ; real HW fails if you immediately write DATA after ADDRESS
  stz YM2151_DATA
  inx
  bne .reset_loop
.reset_end:
  rts

; Ring Buffer
ym_write:
  ldx RB_HEAD
  cpx RB_TAIL
  beq .ym_write_done
;   lda #$80
; .ym_wait:
;   and YM2151_DATA
;   bne .ym_wait
  lda RINGBUFFER,X
  sta YM2151_REG
  inx
  lda RINGBUFFER,X
  sta YM2151_DATA
  inx
  stx RB_HEAD
.ym_write_done:
  rts

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
