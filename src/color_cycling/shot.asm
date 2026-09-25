;top level label is "glow"

.shot: {
    dw glow_shot_init, glow_shot_routine, glow_shot_list
    
    ;this thing doesn't make any sense and isn't currently used
    
    ..init: {
        ;find out if shots exist?
        rts
    }
    
    ..routine: {
        ;delete if no shots?
        rts
        
        phx
        phy
        
        ;uhhh
        ;get max shot index
        ;check if slot taken
        ldy #!shot_count*2
        lda w_shot_id,y
        bne +
        
        jsr glow_clear
        
        +
        ply
        plx
        rts
    }
    
    ..list: {
        dw $000a    ;number of frames (timer nominal value)
        dw $01e2    ;starting index from start of cg ram buffer
            ;the colors
        dw $7fff, $0000, glow_inst_done
        dw $0000, $7fff, glow_inst_done
        dw glow_inst_loop
    }
}