;=================================================
; SYS_SET_IRQ
;   Set where the kernal should jump to after
;   its own interrupt handling.
;-------------------------------------------------
; INPUTS:   .address    Label or address of IRQ handler
;
;-------------------------------------------------
; MODIFIES: A
;
!macro SYS_SET_IRQ .address {
    lda $0314
    sta irq_redirect
    lda $0315
    sta irq_redirect+1
    lda #<.address
    sta $0314
    lda #>.address
    sta $0315
}


;=================================================
; SYS_WRITE_16
;   Stores a given 16-bit value to location.
;-------------------------------------------------
; INPUTS:
;           .dst    Destination address
;           .value   value to write
;
;-------------------------------------------------
; MODIFIES: A, X, Y, $FB-$FF
;
!macro SYS_WRITE_16 .dst, .value {
  lda #<.value
  sta .dst
  lda #>.value
  sta .dst+1
}

;Math Macros

;=================================================
; ADD_TO_16
;   Add to 16-bit data
;-------------------------------------------------
; INPUTS:   (none)
;
;-------------------------------------------------
; MODIFIES: (none)
;
!macro ADD_TO_16 .address, .value {
    lda .address
    clc
    adc #<.value
    sta .address
    lda .address+1
    adc #>.value
    sta .address+1
}


;VERA Macros

!addr {
	VERA_base = $9f20
	VERA_addr_low   = VERA_base+0
	VERA_addr_high  = VERA_base+1
	VERA_addr_bank  = VERA_base+2
	VERA_data       = VERA_base+3
	VERA_data2      = VERA_base+4
	VERA_ctrl       = VERA_base+5
	VERA_irq_ctrl   = VERA_base+6
	VERA_irq        = VERA_base+7

	VRAM_composer = $F0000
	VRAM_palette  = $F1000
	VRAM_layer0   = $F2000
	VRAM_layer1   = $F3000
	VRAM_sprinfo  = $F4000
	VRAM_sprdata  = $F5000

	VROM_petscii = $1F000
}

;=================================================
; VERA_ENABLE_IRQ
;   Set VERA to interrupt on VSYNC
;-------------------------------------------------
; INPUTS:   (none)
;
;-------------------------------------------------
; MODIFIES: A
;
!macro VERA_ENABLE_IRQ {
	lda #$1
	sta VERA_irq_ctrl
}

;=================================================
; VERA_END_IRQ
;   Reset the Vera IRQ flag so that it generates interrupts.
;-------------------------------------------------
; INPUTS:   (none)
;
;-------------------------------------------------
; MODIFIES: A
;
!macro VERA_END_IRQ {
	lda #$1
	sta VERA_irq
}


;MUSIC SPECIFIC

!macro INC_MUSIC_POINTER {
	+ADD_TO_16 MUSIC_POINTER, 1
	bcc .imp_end
	inc MEMORY_BANK
.imp_end:

}
