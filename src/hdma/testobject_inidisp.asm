;top level label is "hdma"

.testobject_inidisp: {
    ;to create the structure
    dw ..init, ..routine
    dl ..table          ;bank byte is written last
    dw $0000            ;parameters for $43x0/43x1: ppu target is high byte. transfur type is low byte
    
    ..init: {
        ;x = object index
        
        ;lda #$0000              ;target is high byte ($2100), params 00
        ;sta w_hdma_params,x
        
        rts
    }
    
    ..routine: {
        rts
    }
    
    ..table: {
        ;gradient of screen brightness
        ;3 lines each value
        
        db $01, $00
        db $01, $01
        db $01, $02
        db $01, $03
        db $01, $04
        db $01, $05
        db $01, $06
        db $01, $07
        db $01, $08
        db $01, $09
        db $01, $0a
        db $01, $0b
        db $01, $0c
        db $01, $0d
        db $01, $0e
        db $01, $0f

        db $02, $0f
        db $02, $0e
        db $02, $0d
        db $02, $0c
        db $02, $0b
        db $02, $0a
        db $02, $09
        db $02, $08
        db $02, $07
        db $02, $06
        db $02, $05
        db $02, $04
        db $02, $03
        db $02, $02
        db $02, $01
        
        db $03, $00
        db $03, $01
        db $03, $02
        db $03, $03
        db $03, $04
        db $03, $05
        db $03, $06
        db $03, $07
        db $03, $08
        db $03, $09
        db $03, $0a
        db $03, $0b
        db $03, $0c
        db $03, $0d
        db $03, $0e
        db $03, $0f
        
        db $04, $0f
        db $04, $0e
        db $04, $0d
        db $04, $0c
        db $04, $0b
        db $04, $0a
        db $04, $09
        db $04, $08
        db $04, $07
        db $04, $06
        db $04, $05
        db $04, $04
        db $04, $03
        db $04, $02
        db $04, $01
        
        db $05, $00
        db $05, $01
        db $05, $02
        db $05, $03
        db $05, $04
        db $05, $05
        db $05, $06
        db $05, $07
        db $05, $08
        db $05, $09
        db $05, $0a
        db $05, $0b
        db $05, $0c
        db $05, $0d
        db $05, $0e
        db $05, $0f
        
        db $00
    }
    
}