;top level label is "hdma"

.testobject_coldata: {
    dw ..init, ..routine
    dl ..table          ;bank byte is written last
    dw $3200            ;parameters for $43x0/43x1: ppu target is high byte. transfur type is low byte
    
    ..init: {
        ;x = object index
        
        ;lda #$3200              ;target is high byte ($2100), params 00
        ;sta w_hdma_params,x
        
        
        rts
    }
    
    ..routine: {
        rts
    }
    
    ..table: {
        db $40, $01|$80 ;b
        db $40, $08|$40 ;g
        db $40, $1f|$20 ;r

        db $00
    }
    
}