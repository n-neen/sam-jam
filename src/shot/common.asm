;top level label is "shot"
.common: {
    ..init_basespeed: {
        stz p_0
        stz p_2
        jsr shot_basespeedsign
        
        lda w_shot_xspeed,x
        clc
        adc p_0
        sta w_shot_xspeed,x
        
        lda w_shot_yspeed,x
        clc
        adc p_2
        sta w_shot_yspeed,x
        rts
    }
}