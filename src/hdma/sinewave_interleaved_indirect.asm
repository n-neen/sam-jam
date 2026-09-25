;top level label is "hdma"

.interleaved_indirect: {
    dw ..init, ..routine
    dl ..table
    dw $0f42 
    
    ..init: {
        
        lda w_hdma_bank,x       ;set indirect bank
        ora #$7e00
        sta w_hdma_bank,x
        
        ;fall through and run the main routine once
    }
    
    ..routine: {
        ;this is a pain to write, still doesn't really work
        
        phb
        phx
        phy
        
        pea.w bank(w_indirecthdmatable2)<<8
        plb
        plb
        
        lda w_hdma_timer,x        ;not indexing by x makes this use the last slot (for object 0)
        inc                       ;we don't use object 0 so use this as a global timer
        sta w_hdma_timer,x
        
        tax
        
        lda #$00e0
        sta p_2
        
        sep #$30
        ldy #$20
        ;ldx #$e0
        
        ...loop:
        lda.l hdma_1fsinetable,x                 ;hdma_1fsinetable, hdma_neg30sinetable, hdma_neg30sinetabledoubled
        sta.w w_indirecthdmatable2,y
        eor #$ff
        inc
        sta.w w_indirecthdmatable2+2,y
        
        lda.l hdma_1fsinetable,x                 ;hdma_1fsinetable, hdma_neg30sinetable, hdma_neg30sinetabledoubled
        sta.w w_indirecthdmatable2+$40,y
        eor #$ff
        inc
        sta.w w_indirecthdmatable2+$42,y
        
        lda.l hdma_1fsinetable,x                 ;hdma_1fsinetable, hdma_neg30sinetable, hdma_neg30sinetabledoubled
        sta.w w_indirecthdmatable2+$80,y
        eor #$ff
        inc
        sta.w w_indirecthdmatable2+$82,y
        
        lda.l hdma_1fsinetable,x                 ;hdma_1fsinetable, hdma_neg30sinetable, hdma_neg30sinetabledoubled
        sta.w w_indirecthdmatable2+$c0,y
        eor #$ff
        inc
        sta.w w_indirecthdmatable2+$c2,y
        
        dey
        dey
        dey
        dey
        
        dex
        
        dec p_2
        bne ...loop
        
        rep #$30
        ply
        plx
        plb
        rts
    }
    
    ..table: {
        %indirecthdmatable(w_indirecthdmatable2)
        db $00
    }
}