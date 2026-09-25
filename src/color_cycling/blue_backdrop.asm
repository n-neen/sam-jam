;top level label is "glow"

.bluebackdrop: {
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
        dw $0000    ;starting index from start of cg ram buffer
        
        dw $0402, glow_inst_done
        dw $0403, glow_inst_done
        dw $0804, glow_inst_done
        dw $0805, glow_inst_done
        dw $0C06, glow_inst_done
        dw $1008, glow_inst_done
        
        dw $0C06, glow_inst_done
        dw $0805, glow_inst_done
        dw $0804, glow_inst_done
        dw $0403, glow_inst_done
        dw $0402, glow_inst_done
        dw glow_inst_loop
    }
}