;top level label is "hdma"

.screensplit: {
    ;main screen layers
    
    dw ..init, ..routine
    dl ..table          ;bank byte is written last
    dw $2c00            ;parameters for $43x0/43x1: ppu target is high byte. transfur type is low byte
    
    ..init: {
        ;x = object index
        
        ;lda #$2c00              ;target is high byte ($21xx) to $43x1, params is low byte to $43x0
        ;sta w_hdma_params,x
        
        rts
    }
    
    ..routine: {
        rts
    }
    
    ..table: {
        ;direct hdma table
                ;000s4321
        db $40, %00010101   ;number of lines, value to write        main screen = 1, 3, sprites
        db $58, %00010101   ;number of lines, value to write
        db $48, %00010110   ;number of lines, value to write        main screen = 2, 3, sprites
        
        db $00
    }
    
}