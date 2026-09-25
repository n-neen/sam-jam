;top level label is "hdma"

.glitch_bands_indirect: {
    ;this is the same as sinewave_indirect but does some horrible wrong math
    ;on the table writes
    ;looks pretty cool so i forked it out to here
    ;uses the same indirect table
    ;....is what i would say if i didn't need to make a second table! ah ha ha
    
    dw ..init, ..routine
    dl ..table                              ;bank byte is written last
    dw $1042                                ;parameters for $43x0/43x1
    
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
        
        lda w_nmicounter
        sta p_0
        eor #$ffff
        inc
        sta p_2
        
        tax
        
        sep #$30
        
        ldy #$40
        -
        lda.l hdma_1fsinetable,x
        eor p_0
        sta.w w_indirecthdmatable2,y
        
        lda.l hdma_1fsinetable+$40,x
        eor p_2
        sta.w w_indirecthdmatable2+$40,y
        
        lda.l hdma_1fsinetable+$80,x
        eor p_0
        sta.w w_indirecthdmatable2+$80,y
        
        lda.l hdma_1fsinetable+$c0,x
        eor p_2
        sta.w w_indirecthdmatable2+$c0,y
        
        lda.l hdma_1fsinetable+$0,x
        eor p_0
        sta.w w_indirecthdmatable2+$100,y
        
        lda.l hdma_1fsinetable+$40,x
        eor p_2
        sta.w w_indirecthdmatable2+$140,y
        
        lda.l hdma_1fsinetable+$80,x
        eor p_0
        sta.w w_indirecthdmatable2+$180,y
        
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
        %indirecthdmatable(w_indirecthdmatable2)
        db $00
    }
}