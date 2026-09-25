;top level label is "glow"

.animationtest: {
    dw ..init,      ;init
       ..routine,   ;routine
       ..list       ;instruction list
    
    ..init:
        rts
    
    ..routine:
        rts
        
        
    ..list: {
        dw $0003    ;number of frames (timer nominal value)
        dw $01a2    ;starting color index from start of cg ram buffer
        dw $5818, $5C78, $60F9, $657A, $69FB, $6E7C, $72FD, $7FFF, $72FD, $6E7C, $69FB, $657A, $60F9, $5C78, $5818, glow_inst_done,
           $5818, $5818, $5C78, $60F9, $657A, $69FB, $6E7C, $72FD, $7FFF, $72FD, $6E7C, $69FB, $657A, $60F9, $5C78, glow_inst_done,
           $5C78, $5818, $5818, $5C78, $60F9, $657A, $69FB, $6E7C, $72FD, $7FFF, $72FD, $6E7C, $69FB, $657A, $60F9, glow_inst_done,
           $60F9, $5C78, $5818, $5818, $5C78, $60F9, $657A, $69FB, $6E7C, $72FD, $7FFF, $72FD, $6E7C, $69FB, $657A, glow_inst_done,
           $657A, $60F9, $5C78, $5818, $5818, $5C78, $60F9, $657A, $69FB, $6E7C, $72FD, $7FFF, $72FD, $6E7C, $69FB, glow_inst_done,
           $69FB, $657A, $60F9, $5C78, $5818, $5818, $5C78, $60F9, $657A, $69FB, $6E7C, $72FD, $7FFF, $72FD, $6E7C, glow_inst_done,
           $6E7C, $69FB, $657A, $60F9, $5C78, $5818, $5818, $5C78, $60F9, $657A, $69FB, $6E7C, $72FD, $7FFF, $72FD, glow_inst_done,
           $72FD, $6E7C, $69FB, $657A, $60F9, $5C78, $5818, $5818, $5C78, $60F9, $657A, $69FB, $6E7C, $72FD, $7FFF, glow_inst_done,
           $7FFF, $72FD, $6E7C, $69FB, $657A, $60F9, $5C78, $5818, $5818, $5C78, $60F9, $657A, $69FB, $6E7C, $72FD, glow_inst_done,
           $72FD, $7FFF, $72FD, $6E7C, $69FB, $657A, $60F9, $5C78, $5818, $5818, $5C78, $60F9, $657A, $69FB, $6E7C, glow_inst_done,
           $6E7C, $72FD, $7FFF, $72FD, $6E7C, $69FB, $657A, $60F9, $5C78, $5818, $5818, $5C78, $60F9, $657A, $69FB, glow_inst_done,
           $69FB, $6E7C, $72FD, $7FFF, $72FD, $6E7C, $69FB, $657A, $60F9, $5C78, $5818, $5818, $5C78, $60F9, $657A, glow_inst_done,
           $657A, $69FB, $6E7C, $72FD, $7FFF, $72FD, $6E7C, $69FB, $657A, $60F9, $5C78, $5818, $5818, $5C78, $60F9, glow_inst_done,
           $60F9, $657A, $69FB, $6E7C, $72FD, $7FFF, $72FD, $6E7C, $69FB, $657A, $60F9, $5C78, $5818, $5818, $5C78, glow_inst_done,
           $5C78, $60F9, $657A, $69FB, $6E7C, $72FD, $7FFF, $72FD, $6E7C, $69FB, $657A, $60F9, $5C78, $5818, $5818, glow_inst_done
        dw glow_inst_loop
    }
}