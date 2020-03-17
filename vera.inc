!ifdef VERA_INC !eof
VERA_INC=1

;=================================================
;=================================================
;
;   Memory-mapped registers
;
;-------------------------------------------------

!addr {
	VERA_base = $9f20
	VERA_addr_low   = VERA_base+0
	VERA_addr_high  = VERA_base+1
	VERA_addr_bank  = VERA_base+2
	VERA_data       = VERA_base+3
	VERA_data2      = VERA_base+4
	VERA_CTRL       = VERA_base+5
	VERA_irq_ctrl   = VERA_base+6
	VERA_irq        = VERA_base+7
	VERA_IRQ_L		= VERA_base+8

	;Display Composer
	VERA_DC = $9F29
	;WITH DC_SEL 0
	DC_VIDEO		= VERA_DC+0
	DC_HSCALE		= VERA_DC+1
	DC_VSCALE		= VERA_DC+2
	DC_BORDER		= VERA_DC+3
	;WITH DC_SEL 1
	DC_HSTART		= VERA_DC+0
	DC_HSTOP		= VERA_DC+1
	DC_VSTART		= VERA_DC+2
	DC_VSTOP		= VERA_DC+3

	;Layer 0
	VERA_L0 = $9F2D
	L0_CONFIG 		= VERA_L0+0
	L0_MAPBASE		= VERA_L0+1
	L0_TILEBASE		= VERA_L0+2
	L0_HSCROLL_L	= VERA_L0+3
	L0_HSCROLL_H	= VERA_L0+4
	L0_VSCROLL_L	= VERA_L0+5
	L0_VSCROLL_H	= VERA_L0+6

	;Layer 1
	VERA_L1 = $9F34
	L1_CONFIG 		= VERA_L1+0
	L1_MAPBASE		= VERA_L1+1
	L1_TILEBASE		= VERA_L1+2
	L1_HSCROLL_L	= VERA_L1+3
	L1_HSCROLL_H	= VERA_L1+4
	L1_VSCROLL_L	= VERA_L1+5
	L1_VSCROLL_H	= VERA_L1+6

	;Audio
	VERA_AUDIO = $9F3B
	AUDIO_CTRL 		= VERA_AUDIO+0
	AUDIO_RATE 		= VERA_AUDIO+1
	AUDIO_DATA 		= VERA_AUDIO+2


;	VRAM_composer = $F0000
	VRAM_palette  = $1FA00
;	VRAM_layer0   = $F2000
;	VRAM_layer1   = $F3000
;	VRAM_sprinfo  = $F4000
	VRAM_sprdata  = $1FC00

	VERA_psg		= $1F9C0

	VROM_petscii = $1F000
}

;=================================================
;=================================================
;
;   Macros
;
;-------------------------------------------------


!macro DC_SEL_0 {
	lda VERA_CTRL
	AND #%11111101
	sta VERA_CTRL
}

!macro DC_SEL_1 {
	lda VERA_CTRL
	ORA #%00000010
	sta VERA_CTRL
}

!macro LAYER_0_OFF {
	+DC_SEL_0
	lda DC_VIDEO
	and #%11101111
	sta DC_VIDEO
}

!macro LAYER_1_OFF {
	+DC_SEL_0
	lda DC_VIDEO
	and #%11011111
	sta DC_VIDEO
}

!macro LAYER_0_ON {
	+DC_SEL_0
	lda DC_VIDEO
	ora #%00010000
	sta DC_VIDEO
}

!macro LAYER_1_ON {
	+DC_SEL_0
	lda DC_VIDEO
	ora #%00100000
	sta DC_VIDEO
}

!macro VIDEO_DISABLE {
	+DC_SEL_0
	lda DC_VIDEO
	and #%11111100
	sta DC_VIDEO
}

!macro VGA_VIDEO_ENABLE {
	+DC_SEL_0
	lda DC_VIDEO
	and #%11111100
	ora #%00000001
	sta DC_VIDEO
}

;=================================================
; VERA_SELECT_ADDR
;   Select which address channel to configure (VERA_data vs. VERA_data2)
;-------------------------------------------------
; INPUTS:   .addr	0 for VERA_data
;					1 for VERA_data2
;
;-------------------------------------------------
; MODIFIES: A
;
!macro VERA_SELECT_ADDR .addr {
	lda #.addr
	sta VERA_ctrl
}

!macro VERA_SET_ADDR .addr, .stride {
	lda #<(.addr)
	sta VERA_addr_low
	lda #<(.addr >> 8)
	sta VERA_addr_high
	lda #(((.addr >> 16) & %00000001 )| (.stride << 4))
	sta VERA_addr_bank
}

!macro VERA_SET_ADDR .addr {
	+VERA_SET_ADDR .addr, 1
}

!macro VERA_SET_ADDR_IND .addr, .stride {
	lda .addr
	sta VERA_addr_low
	lda .addr+1
	sta VERA_addr_high
	lda .addr+2
	ora #(.stride << 4 )
	sta VERA_addr_bank
}


;=================================================
; VERA_RESET
;   Reset the Vera to its default settings.
;	See official documentation for specifics.
;-------------------------------------------------
; INPUTS:   (none)
;
;-------------------------------------------------
; MODIFIES: A
;
!macro VERA_RESET {
	lda VERA_CTRL
	ora #$80
	sta VERA_CTRL
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
; VERA_DISABLE_IRQ
;   Set VERA to not interrupt on VSYNC
;-------------------------------------------------
; INPUTS:   (none)
;
;-------------------------------------------------
; MODIFIES: A
;
!macro VERA_DISABLE_IRQ {
	lda #$0
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
