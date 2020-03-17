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

!macro SYS_RESTORE_IRQ {
	lda irq_redirect
    sta $0314
	lda irq_redirect+1
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

;=================================================
; SYS_WRITE_24
;   Stores a given 24-bit value to location.
;-------------------------------------------------
; INPUTS:
;           .dst    Destination address
;           .value   value to write
;
;-------------------------------------------------
; MODIFIES: A, X, Y, $FB-$FF
;
!macro SYS_WRITE_24 .dst, .value {
  lda #<.value
  sta .dst
  lda #>.value
  sta .dst+1
  lda #^.value
  sta .dst+2
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


;=================================================
; ADD_A_TO_16
;   Add to 16-bit data
;-------------------------------------------------
; INPUTS:   (none)
;
;-------------------------------------------------
; MODIFIES: $FF
;
!macro ADD_A_TO_16 .address {
    sta $FF
    lda .address
    clc
    adc $FF
    sta .address
    lda .address+1
    adc #0
    sta .address+1
}

;MUSIC SPECIFIC

!macro INC_MUSIC_POINTER {
	+ADD_TO_16 MUSIC_POINTER, 1
	lda MUSIC_POINTER+1
	cmp #$C0
	bne .imp_end
	inc MEMORY_BANK
	lda #$A0
	sta MUSIC_POINTER+1
.imp_end:

}

;Utility macros

!macro BEQ_LONG .lbl {
	bne .bel1
	jmp	.lbl
.bel1:
}

!macro BNE_LONG .lbl {
	beq .bel1
	jmp	.lbl
.bel1:
}


!macro SYS_SET_RAM_BANK .value {
	lda #.value
	sta MEMORY_BANK
}



!macro SYS_COPY_FROM_IND_VARSIZE .src, .dst, .size {
    lda .src ;.src to $FC $FB
    sta $FB
	lda .src+1
    sta $FC
    lda #<.dst ;.dst to $FE $FD
    sta $FD
    lda #>.dst
    sta $FE

	lda .size+1
	beq .small
.big:
                    ; If we have at least 1 full page to copy, then include the
                    ; page copy portion which needs a 5th byte to track the number
                    ; of pages to copy.

        lda .size+1 ; number of pages to copy
        sta $FF

        ldy #$00 ; reset y for our loop

-       lda ($FB),Y ; indirect index source memory address
        sta ($FD),Y ; indirect index dest memory address
        iny
        bne -       ; loop until our dest goes over 255

        inc $FC     ; increment high order source memory address
        inc $FE     ; increment high order dest memory address

        dec $FF     ; decrement number of pages remaining
        bne -       ; If we still have at least 1 page to copy, go back and copy it


		lda .size
		beq .end
.small:
                    ; If we're not copying exactly some number of pages, include
                    ; the "copy the rest of it" section
        ldy #0
        ldx .size

-       lda ($FB),Y
        sta ($FD),Y
        iny
        dex
        bne -
.end:
}
