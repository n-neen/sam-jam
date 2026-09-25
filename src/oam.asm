oam: {
    ;oam buffer happens like this:
    ;hud gets drawn
    ;player gets drawn
    ;fae get drawn
    
    ;call oam_cleanbuffer, which starts at the w_oam_index that was last left
    ;by sprite drawing routines and writes $e0e0 to the remainder of the buffer
    ;the above happens any time after all drawing routines in game logic have been run,
    ;so usually the end of the game logic.
    
    ;but at the start of the frame is when the hi byte buffer needs to be cleared though
    ;because all the drawing routines need to be able to write to it
    
    ;so it goes like this:
    
    ;start of gameplay logic
    ;jsl oam_cleanhibytebuffer
    ;bunch of stuff, including all the spritemap drawing routines
    ;then
    ;jsl oam_cleanbuffer
    ;jsl oam_constructhibuffer
    ;then, in vblank, upload the buffer
    
    .uploadbuffer: {
        ;runs in vblank
        
        phx
        php
        
        sep #$10                        ;8 bit x/y mode
        rep #$20                        ;16 bit A
        
                                        ;width  register
        stz $2102                       ;1      oam high starting addr = 0
        
        ldx #$00                        ;1      transfur mode
        stx $4300
        
        ldx #$04                        ;1      register dest (oam add)
        stx $4301
        
        ldx.b #(($ff0000&w_oam)>>16)    ;1      source bank
        stx $4304
        
        lda.w #w_oam_lo_buffer          ;2      source addr
        sta $4302
        
        lda #$0220                      ;2      transfur size = 542 bytes (oam table size)
        sta $4305
        
        ldx #$01                        ;1      enable transfur on dma channel 0             
        stx $420b
        
        plp
        plx
        rtl
    }
    
    .cleanbuffer: {
        ;remove stale sprites after sprites for this frame are drawn
        
        ldx w_oam_index
        lda #$e0e0
        
        -
        sta w_oam_lo_buffer,x
        inx
        inx
        cpx #$01fe          ;uhh is that right or no?
        bmi -
        
        rtl
    }
    
    .cleanhibytebuffer: {
        phk
        plb
        
        ldx #!oam_hi_byte_buffer_size
        
        -
        stz w_oam_hi_bytebuffer,x
        dex
        dex
        bpl -
        
        rtl
    }
    
    .constructhibuffer: {
        ;todo: clear both oam high buffers every frame
        
        phx
        phy
        phb
        
        phk
        plb
        
        ldx #!oam_hi_byte_buffer_size
        ldy #$001f
        
        sep #$20            ;%00000000
        {
            -
            stz p_8
            
            lda w_oam_hi_bytebuffer,x
            ora p_8
            sta p_8
            
            lda w_oam_hi_bytebuffer+1,x
            asl
            asl
            ora p_8
            sta p_8
            
            lda w_oam_hi_bytebuffer+2,x
            asl
            asl
            asl
            asl
            ora p_8
            sta p_8
            
            lda w_oam_hi_bytebuffer+3,x
            asl
            asl
            asl
            asl
            asl
            asl
            ora p_8
            sta p_8
            
            sta w_oam_hi_buffer,y
            
            dex
            dex
            dex
            dex
            
            dey
            
            bpl -
        }
        rep #$20
        
        plb
        ply
        plx
        rtl
    }
}
    
