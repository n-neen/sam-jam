;top level label is "hdma"

.sinewave_indirect: {
    dw ..init, ..routine
    dl ..table                  ;bank byte is written last
    dw $1042                    ;parameters for $43x0/43x1
    
    ..init: {
        ;lda #$1042              ;target is high byte ($2110), params $42 (indirect, write twice)
        ;sta w_hdma_params,x
        
        lda w_hdma_bank,x       ;set indirect bank (kept in high byte of w_hdma_bank)
        ora #bank(w_indirecthdmatable)<<8
        sta w_hdma_bank,x
        
        ;fall through and run the main routine once
    }
    
    ..routine: {
        phb
        phx
        phy
        
        pea.w bank(w_indirecthdmatable)<<8
        plb
        plb
        
        lda w_hdma_timer,x
        inc
        sta w_hdma_timer,x
        
        tax
        
        sep #$30
        
        ldy #$40
        -
        lda.l hdma_neg30sinetable,x                ;hdma_1fsinetable, hdma_neg30sinetable, hdma_neg30sinetabledoubled
        sta.w w_indirecthdmatable,y
        
        lda.l hdma_neg30sinetable+$40,x
        sta.w w_indirecthdmatable+$40,y
        
        lda.l hdma_neg30sinetable+$80,x
        sta.w w_indirecthdmatable+$80,y
        
        lda.l hdma_neg30sinetable+$c0,x
        sta.w w_indirecthdmatable+$c0,y
        
        lda.l hdma_neg30sinetable+$0,x
        sta.w w_indirecthdmatable+$100,y
        
        lda.l hdma_neg30sinetable+$40,x
        sta.w w_indirecthdmatable+$140,y
        
        lda.l hdma_neg30sinetable+$80,x
        sta.w w_indirecthdmatable+$180,y
        
        dex
        dex
        dey
        dey
        
        cpy #$fe
        bne -
        
        rep #$30
        ply
        plx
        plb
        rts
    }
    
    ..table: {
        %indirecthdmatable(w_indirecthdmatable)
        db $00
    }
}