;top level label is "glow"

.trianglemid: {
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
        dw $000f    ;number of frames (timer nominal value)
        dw $0042    ;starting index from start of cg ram buffer
        
        dw $000A, glow_inst_done
        dw $0848, glow_inst_done
        dw $14A7, glow_inst_done
        dw $2106, glow_inst_done
        dw $2D65, glow_inst_done
        dw $35A3, glow_inst_done
        dw $4202, glow_inst_done
        dw $5AC0, glow_inst_done
        dw $4E61, glow_inst_done
        dw $4202, glow_inst_done
        dw $35A3, glow_inst_done
        dw $2D65, glow_inst_done
        dw $2106, glow_inst_done
        dw $14A7, glow_inst_done
        dw $000A, glow_inst_done
        dw $080B, glow_inst_done
        dw $140D, glow_inst_done
        dw $200E, glow_inst_done
        dw $2C10, glow_inst_done
        dw $3411, glow_inst_done
        dw $4013, glow_inst_done
        dw $5816, glow_inst_done
        dw $4C14, glow_inst_done
        dw $4013, glow_inst_done
        dw $3411, glow_inst_done
        dw $2C10, glow_inst_done
        dw $200E, glow_inst_done
        dw $140D, glow_inst_done
        dw $000A, glow_inst_done
        
        dw glow_inst_loop
    }
}