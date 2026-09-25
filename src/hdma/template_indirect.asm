;top level label is "hdma"

.template_indirect: {
    dw ..init, ..routine
    dl ..table                  ;bank byte is written last
    dw $0040                    ;parameters for $43x0/43x1: ppu target is high byte. transfur type is low byte
    
    ..init: {
        ;lda #$0040              ;target is high byte ($21xx), params $40 (indirect)
        ;sta w_hdma_params,x
        
        lda w_hdma_bank,x       ;set indirect bank
        ora #$7e00
        sta w_hdma_bank,x
        
        ;fall through and run the main routine once
    }
    
    ..routine: {
        phb
        phx
        phy
        
        pea $7e7e
        plb
        plb
        
        ;build the table
        
        ply
        plx
        plb
        rts
    }
    
    ..table: {
        macro indirecthdmatable(startaddr)
            !a #= 0
            while !a < $1b4
                db $01 : dw <startaddr>+!a
                !a #= !a+2
            endwhile
            
        endmacro
        %indirecthdmatable($2000)
        db $00
    }
}