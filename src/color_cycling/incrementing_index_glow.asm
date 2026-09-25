;top level label is "glow"

.incrementing: {
    dw ..init, ..routine, ..list
    
    ..init: {
        ;runs once when the object is created
        rts
    }
    
    ..routine: {
        lda w_glow_colorindexstart,x
        inc
        cmp #$00f8
        bmi +
        lda #$0000
        +
        sta w_glow_colorindexstart,x
        
        rts
    }
    
    ..list: {
        dw $0000    ;number of frames (timer nominal value)
        dw $0000    ;starting index from start of cg ram buffer
            ;the colors
        dw $001f
        dw $7c00
        dw $03c0
        dw $7C1E, glow_inst_done
        dw glow_inst_loop
    }
}

dw $01FF
dw $0DBE
dw $1D7E
dw $2D3E
dw $3CFE
dw $4CBE
dw $5C7E
dw $7C1E
