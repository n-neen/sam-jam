;top level label is "glow"

.space: {
    dw ..init, ..routine, ..list
    
    ..init: {
        ;
        rts
    }
    
    ..routine: {
        ;
        rts
    }
    
    ..list: {
        dw $0008    ;number of frames (timer nominal value)
        dw $0020    ;starting color index from start of cg ram buffer
            ;the colors
        dw $0000, $001F, $0017, $00DF, $0117, $03FF, $02F3, $03E0, $02E0, $7E23, $4940, $7C00, $3800, $7C1F, $7C0F, $300E, glow_inst_done
        dw $300E, $0000, $001F, $0017, $00DF, $0117, $03FF, $02F3, $03E0, $02E0, $7E23, $4940, $7C00, $3800, $7C1F, $7C0F, glow_inst_done
        dw $7C0F, $300E, $0000, $001F, $0017, $00DF, $0117, $03FF, $02F3, $03E0, $02E0, $7E23, $4940, $7C00, $3800, $7C1F, glow_inst_done
        dw $7C1F, $7C0F, $300E, $0000, $001F, $0017, $00DF, $0117, $03FF, $02F3, $03E0, $02E0, $7E23, $4940, $7C00, $3800, glow_inst_done
        dw $3800, $7C1F, $7C0F, $300E, $0000, $001F, $0017, $00DF, $0117, $03FF, $02F3, $03E0, $02E0, $7E23, $4940, $7C00, glow_inst_done
        dw $7C00, $3800, $7C1F, $7C0F, $300E, $0000, $001F, $0017, $00DF, $0117, $03FF, $02F3, $03E0, $02E0, $7E23, $4940, glow_inst_done
        dw $4940, $7C00, $3800, $7C1F, $7C0F, $300E, $0000, $001F, $0017, $00DF, $0117, $03FF, $02F3, $03E0, $02E0, $7E23, glow_inst_done
        dw $7E23, $4940, $7C00, $3800, $7C1F, $7C0F, $300E, $0000, $001F, $0017, $00DF, $0117, $03FF, $02F3, $03E0, $02E0, glow_inst_done
        dw $02E0, $7E23, $4940, $7C00, $3800, $7C1F, $7C0F, $300E, $0000, $001F, $0017, $00DF, $0117, $03FF, $02F3, $03E0, glow_inst_done
        dw $03E0, $02E0, $7E23, $4940, $7C00, $3800, $7C1F, $7C0F, $300E, $0000, $001F, $0017, $00DF, $0117, $03FF, $02F3, glow_inst_done
        dw $02F3, $03E0, $02E0, $7E23, $4940, $7C00, $3800, $7C1F, $7C0F, $300E, $0000, $001F, $0017, $00DF, $0117, $03FF, glow_inst_done
        dw $03FF, $02F3, $03E0, $02E0, $7E23, $4940, $7C00, $3800, $7C1F, $7C0F, $300E, $0000, $001F, $0017, $00DF, $0117, glow_inst_done
        dw $0117, $03FF, $02F3, $03E0, $02E0, $7E23, $4940, $7C00, $3800, $7C1F, $7C0F, $300E, $0000, $001F, $0017, $00DF, glow_inst_done
        dw $00DF, $0117, $03FF, $02F3, $03E0, $02E0, $7E23, $4940, $7C00, $3800, $7C1F, $7C0F, $300E, $0000, $001F, $0017, glow_inst_done
        dw $0017, $00DF, $0117, $03FF, $02F3, $03E0, $02E0, $7E23, $4940, $7C00, $3800, $7C1F, $7C0F, $300E, $0000, $001F, glow_inst_done
        dw $001F, $0017, $00DF, $0117, $03FF, $02F3, $03E0, $02E0, $7E23, $4940, $7C00, $3800, $7C1F, $7C0F, $300E, $0000, glow_inst_done

        dw glow_inst_loop
    }
}