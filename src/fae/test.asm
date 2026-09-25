;top level label is "fae"


.test: {
    dw ..main                   ;main routine
    dw fae_common_giveiframes   ;touch routine
    dw ..init                   ;init routine
    dw fae_common_explode       ;shot routine
    dw ..spritemap              ;spritemap
    
    dw $0009    ;x size
    dw $000b    ;y size
    
    ..main: {
        ;runs once per frame
        
        ;move fae with controller 2
        
        lda w_controller2
        bit #!controller_lf
        beq +
        {
            ;if lf pressed
            pha
            lda w_fae_x,x
            sec
            sbc w_fae_var1,x
            sta w_fae_x,x
            pla
        }
        +
        
        bit #!controller_rt
        beq +
        {
            ;if rt pressed
            pha
            lda w_fae_x,x
            clc
            adc w_fae_var1,x
            sta w_fae_x,x
            pla
        }
        +
        
        bit #!controller_up
        beq +
        {
            ;if up pressed
            pha
            lda w_fae_y,x
            sec
            sbc w_fae_var1,x
            sta w_fae_y,x
            pla
        }
        +
        
        bit #!controller_dn
        beq +
        {
            ;if dn pressed
            pha
            lda w_fae_y,x
            clc
            adc w_fae_var1,x
            sta w_fae_y,x
            pla
        }
        +
        
        rts
    }
    
    ..shot: {
        ;
        rts
    }
    
    ..init: {
        ;lda #$0080
        ;sta w_fae_x,x
        
        ;lda #$0180
        ;sta w_fae_y,x
        rts
    }
    
    ..touch: {
        ;not used, see pointers at top of file
        
        rts
    }
    
    ..spritemap: {
        ;number of sprites
        db 01
        ;  xx   yy   tt   pp         hh 01 = extra x bit, 02 = size select
        db $00, $00, $82, %00111100, $02

    }
}