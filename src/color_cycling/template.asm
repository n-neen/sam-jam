;top level label is "glow"

.template: {
    dw ..init, ..routine, ..list
    
    ..init: {
        ;runs once when the object is created
        rts
    }
    
    ..routine: {
        ;runs once per frame
        rts
    }
    
    ..list: {
        dw $000a    ;number of frames (timer nominal value)
        dw $01e2    ;starting index from start of cg ram buffer
            ;the colors
        dw $color1, $color2, glow_inst_done ;proceed to next line after counter is 0
        dw glow_inst_loop                   ;return to top of list (and to start of color index)
    }
}