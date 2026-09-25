;top level label is "glow"

.playerhurt: {
    dw  ..init,      ;init
        ..routine,   ;routine
        ..list       ;instruction list
        
    ..init:
        lda #!player_hurt_cooldown_default
        sta w_player_hurtglowcooldown
        rts
        
    ..routine:
        rts
        
    ..list: {
        dw $0002    ;number of frames (timer nominal value)
        dw $0180    ;starting color index from start of cg ram buffer
        dw $3838, $7FFF, $0000, $7BD2, $7BCA, $7BC2, $7BC6, $7B46, $7B5A, $7B4A, $7B56, $7AD6, $7B52, $7A4A, $7C1F, $7AC6, glow_inst_done,
           $30B8, $77F9, $04A3, $73D3, $73CC, $73C6, $6BAA, $7749, $6B5A, $6B2D, $6737, $6AD7, $6B34, $726D, $6419, $7AEA, glow_inst_done,
           $2D59, $6FF4, $0D47, $6BD5, $6FCE, $6FCA, $5FAE, $736D, $5B5B, $5B30, $5318, $5ED8, $5F36, $6A90, $5014, $7B2E, glow_inst_done,
           $29FA, $6BEF, $15EB, $63D7, $6BD1, $6BCF, $53B2, $7390, $4B5C, $4B14, $42FA, $52FA, $5338, $62D4, $3C0F, $7B52, glow_inst_done,
           $229B, $63EA, $1A8F, $5BD9, $63D3, $63D3, $4396, $6F94, $3B5C, $3B17, $2EDB, $42FB, $431A, $5AF7, $280A, $7B96, glow_inst_done,
           $1BDD, $57E0, $2BD7, $4BDD, $5BD8, $5BDC, $2B9E, $6BDB, $1B7E, $1AFE, $0ABE, $2B1E, $2B1E, $4B5E, $0000, $7FFF, glow_inst_done,
           $1F3C, $5BE5, $2333, $53DB, $5FD5, $5FD7, $379A, $6BB7, $2B5D, $2AFA, $1ABC, $36FC, $371C, $531A, $1405, $7BBA, glow_inst_done,
           $229B, $63EA, $1A8F, $5BD9, $63D3, $63D3, $4396, $6F94, $3B5C, $3B17, $2EDB, $42FB, $431A, $5AF7, $280A, $7B96, glow_inst_done,
           $29FA, $6BEF, $15EB, $63D7, $6BD1, $6BCF, $53B2, $7390, $4B5C, $4B14, $42FA, $52FA, $5338, $62D4, $3C0F, $7B52, glow_inst_done,
           $2D59, $6FF4, $0D47, $6BD5, $6FCE, $6FCA, $5FAE, $736D, $5B5B, $5B30, $5318, $5ED8, $5F36, $6A90, $5014, $7B2E, glow_inst_done,
           $3838, $7FFF, $0000, $7BD2, $7BCA, $7BC2, $7BC6, $7B46, $7B5A, $7B4A, $7B56, $7AD6, $7B52, $7A4A, $7C1F, $7AC6, glow_inst_done
        dw glow_clear
    }
}