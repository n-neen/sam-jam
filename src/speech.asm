speech: {
    ;speech text objects
    ;
    ;currently sketching out this structure
    ;need to make sure to not just lazily upload the entire message buffer
    ;for every character
    ;because this will be handled during gameplay, we'll need to reduce lag
    
    ;portrait in bottom left of screen
    ;get string pointer and draw with layer 3 to the right of the portrait
    ;for drawing text associated with a character during gameplay
    
    .top: {
        phk
        plb
        
        lda w_speech_spritemap_ptr  ;if null ptr, no object exists
        beq +
        
        jsr speech_handletext
        ;jsr speech_typechar
        jsr speech_drawsprites
        jsr speech_ticktimer
        
        +
        rtl
    }
    
    .ticktimer: {
        lda w_speech_timer
        beq +
        dec
        sta w_speech_timer
        
        rts
        
        +
        jsl speech_clear
        jsl msg_reset
        rts
    }
    
    .spawn: {
        ;no arrays, only one can exist at a time
        
        ;populate memory from the object's header
        ;draw sprites associated with it
        ;start typing the text
        ;probably rely on bg3 tilemap having been cleared
        ;and scroll the bg3 y scroll to the anchor point
        
        ;maybe we do another screen dimming band like the hud has
        ;should be ok to write another interrupt for that
        
        ;
        
        ;A = pointer to speech object header
        
        phb
        phx
        phy
        
        pea bank(speech)<<8
        plb
        plb
        
        tax
        
        lda $0000,x
        sta w_speech_string_ptr
        
        lda $0002,x
        sta w_speech_spritemap_ptr
        
        lda $0004,x
        sta w_speech_timer
        
        stz w_speech_string_index
        
        ply
        plx
        plb
        rtl
    }
    
    
    .drawsprites: {
        ;no offscreen handling needed
        ;does need high table handling
        ;print pc
        phy
        phx
        phb
        
        pea bank(speech)<<8
        plb
        plb
        
        ldy w_oam_index
        ldx w_speech_spritemap_ptr
        
        lda $0000,x
        and #$00ff
        sta p_0             ;number of sprites
        inx
        
        ..nextsprite
        
        sep #$20
        {
            lda $0000,x
            clc
            adc.b #!speech_icon_anchor_x
            sta w_oam_lo_buffer,y       ;x
            
            lda $0001,x
            clc
            adc.b #!speech_icon_anchor_y
            sta w_oam_lo_buffer+1,y     ;y
            
            lda $0002,x
            sta w_oam_lo_buffer+2,y     ;tile
            
            lda $0003,x
            sta w_oam_lo_buffer+3,y     ;properties
            
            {
                phy
                
                tya                         ;y/4 (for hi table byte array)
                lsr
                lsr
                tay
                
                lda $0004,x
                sta w_oam_hi_bytebuffer,y   ;oam hi buffer
                
                ply
            }
            
        }
        rep #$20
        
        inx
        inx
        inx
        inx
        inx
        
        iny
        iny
        iny
        iny
        
        dec p_0
        bne ..nextsprite
        
        sty w_oam_index
        
        plb
        plx
        ply
        rts
    }
    
    
    .handletext: {
        ;type character
        ;request bg3 tilemap update from nmi handler
        ;if typing is done, wait for timer to be over
        ;or maybe wait for input of a specific button (like A or start)
        phx
        phy
        
        lda w_speech_flags
        bmi +
        
        ;first test thing
        lda #$0000
        sta w_bg3yscroll
        
        jsl layer3on_long
        
        lda #$0001
        sta w_msg_waitflag
        
        ldx w_speech_string_ptr
        ldy #$0013
        jsl msg_display
        
        lda w_speech_flags
        ora #$8000
        sta w_speech_flags
        
        +
        ply
        plx
        rts
    }
    
    
    .typechar: {
        ;frudge this
        ldx w_speech_string_ptr
        lda.l bank(str)<<16,x
        and #$00ff
        beq +
        
        
        lda w_speech_string_ptr
        clc
        adc w_speech_string_index
        tax
        
        ldy #$0012
        
        jsl msg_display
        
        inc w_speech_string_index
        
        +
        rts
    }
    
    
    .clear: {
        phk
        plb
        
        stz w_speech_spritemap_ptr
        stz w_speech_string_ptr
        stz w_speech_timer
        stz w_speech_string_index
        stz w_speech_flags              ;low byte is state
        
        rtl
    }
    
    .testobject: {
      ;ptr to string bank, pointer to this bank         timer initial value
        dw str_speechtest, speech_testobject_spritemap, $0200
        ..spritemap: {
            ;number of sprites
            db 09
            ;  xx   yy   tt   pp         hh 01 = extra x bit, 02 = size select
            db $f0, $f0, $6a, %00111101, $02
            db $00, $f0, $6c, %00111101, $02
            db $10, $f0, $6e, %00111101, $02
            
            db $f0, $00, $8a, %00111101, $02
            db $00, $00, $8c, %00111101, $02
            db $10, $00, $8e, %00111101, $02
            
            db $f0, $10, $aa, %00111101, $02
            db $00, $10, $ac, %00111101, $02
            db $10, $10, $ae, %00111101, $02
        }
    }
}