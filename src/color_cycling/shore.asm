;top level label is "glow"

.shore: {
    dw ..init, ..routine, ..list
    
    ..init: {
        ;runs once when the object is created
        
        lda #$7f00
        sta.l w_cgrambuffer
        
        ;lda #!player_sprite_ship
        ;sta w_player_sprite_index
        
        rts
    }
    
    ..routine: {
        ;runs once per frame
        rts
    }
    
    ..list: {
        dw $000b    ;number of frames (timer nominal value)
        dw $0000    ;starting index from start of cg ram buffer
            ;the colors
        dw $7f00, glow_inst_done ;proceed to next line after counter is 0
        dw $7f08, glow_inst_done ;proceed to next line after counter is 0
        dw $7f09, glow_inst_done ;proceed to next line after counter is 0
        dw $7f0a, glow_inst_done ;proceed to next line after counter is 0
        dw $7f0a, glow_inst_done ;proceed to next line after counter is 0
        dw $7f0b, glow_inst_done ;proceed to next line after counter is 0
        dw $7f0b, glow_inst_done ;proceed to next line after counter is 0
        dw $7f0a, glow_inst_done ;proceed to next line after counter is 0
        dw $7f09, glow_inst_done ;proceed to next line after counter is 0
        dw $7f08, glow_inst_done ;proceed to next line after counter is 0
        dw $7f04, glow_inst_done ;proceed to next line after counter is 0
        dw $7f02, glow_inst_done ;proceed to next line after counter is 0
        dw $7f00, glow_inst_done ;proceed to next line after counter is 0
        dw glow_inst_loop                   ;return to top of list (and to start of color index)
    }
}