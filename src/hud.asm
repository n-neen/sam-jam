

hud: {
    .draw: {
        phb
        phx
        phy
        
        phk
        plb
        
        ldx #$0000
        ldy w_oam_index
        
        sep #$20
        {
            ..nextletter
            ;do this first since if the tile is blank we bail
            lda w_hud_buffer,x          ;tile index
            cmp.b #!hud_end
            beq ..end
            sec 
            sbc.b #!hud_ascii_offset    ;align ascii with tiles
            beq ..skip
            sta w_oam_lo_buffer+2,y
            
            lda #%00110000              ;properties:
            sta w_oam_lo_buffer+3,y     ;palette 0, high priority, first page
            
            cpx #!hud_row_length
            bpl ..secondrow
            
            lda.b #!hud_first_row_y_pos
            bra ..firstrow
            
            ..secondrow:
            lda.b #!hud_second_row_y_pos
            
            ..firstrow:
            sta w_oam_lo_buffer+1,y     ;temp, just do one row for now [y position]
            
            txa                         ;buffer index * 8 = pixels along row we are
            asl
            asl
            asl
            sta w_oam_lo_buffer,y       ;x position
            
            iny
            iny
            iny
            iny
            
            ..skip
            inx
            cpx #!hud_row_length*2
            bmi ..nextletter
            
            ..end:
        }
        rep #$20
        
        sty w_oam_index
        
        ply
        plx
        plb
        rtl
    }
    
    
    .init: {
        ;clear buffer
        ;if any tile in the buffer is blank (ascii $20) then we skip drawing it
        phb
        phx
        
        phk
        plb
        
        sep #$20
        {
            ldx #!hud_buffer_size
            lda #$20                ;ascii blank letter
            
            -
            sta w_hud_buffer,x
            dex
            bpl -
        }
        rep #$20
        
        plx
        plb
        rtl
    }
    
    .writeroomstring: {
        ;currently fixed at 10 (decimal) characters
        
        phb
        phx
        phy
        
        pea.w bank(str)<<8
        plb
        plb
        
        lda.l w_level_hudstring_ptr
        clc
        adc #!hud_room_string_length
        tay
        
        sep #$20
        {
            ldx #!hud_room_string_length
            
            -
            lda $0000,y
            sta.l w_hud_buffer+22,x     ;hoefully someday i rember why 22
            
            dey
            dex
            bpl -
            
        }
        rep #$20
        
        ply
        plx
        plb
        rtl
    }
    
    
    .handleglow: {
        ;assumes db
        phx
        
        lda w_hud_glow
        beq ..noglow
        
        sep #$30
        
        lda w_nmicounter
        asl
        asl
        adc w_nmicounter+1
        tax                             ;x = table index for red
        
        asl
        clc
        adc #$80
        sta p_0                         ;p_0 = table index for green
        
        sec
        sbc #$c0
        sta p_2                         ;p_2 = table index for blue
        
        lda hud_handleglow_sinetable,x
        ora #%00100000
        sta w_hud_colortint_r
        
        ldx p_0
        lda hud_handleglow_sinetable,x
        ora #%01000000
        sta w_hud_colortint_g
        
        ldx p_2
        lda hud_handleglow_sinetable,x
        ora #%10000000
        sta w_hud_colortint_b
        
        rep #$30
        plx
        rtl
        
        ..noglow:
        sep #$20
        
        ;default color: grey
        ;still split into r,g,g because of how the interrupt is written
        ;could write two interrupts to save a tiny amount of time
        ;in the non-glow case. but who cares?
        
        lda #%00101111
        sta w_hud_colortint_r
        
        lda #%01001111
        sta w_hud_colortint_g
        
        lda #%10001111
        sta w_hud_colortint_b
        
        rep #$20
        plx
        rtl
        
        ..sinetable: {
         db $10, $10, $10, $11, $11, $11, $12, $12,
            $13, $13, $13, $14, $14, $14, $15, $15,
            $15, $16, $16, $16, $17, $17, $17, $18,
            $18, $18, $19, $19, $19, $1a, $1a, $1a,
            $1a, $1b, $1b, $1b, $1b, $1c, $1c, $1c,
            $1c, $1d, $1d, $1d, $1d, $1d, $1e, $1e,
            $1e, $1e, $1e, $1e, $1e, $1e, $1f, $1f,
            $1f, $1f, $1f, $1f, $1f, $1f, $1f, $1f,
            $1f, $1f, $1f, $1f, $1f, $1f, $1f, $1f,
            $1f, $1f, $1f, $1e, $1e, $1e, $1e, $1e,
            $1e, $1e, $1e, $1d, $1d, $1d, $1d, $1d,
            $1c, $1c, $1c, $1c, $1b, $1b, $1b, $1b,
            $1a, $1a, $1a, $1a, $19, $19, $19, $18,
            $18, $18, $17, $17, $17, $16, $16, $16,
            $15, $15, $15, $14, $14, $14, $13, $13,
            $13, $12, $12, $11, $11, $11, $10, $10,
            $10, $0f, $0f, $0e, $0e, $0e, $0d, $0d,
            $0c, $0c, $0c, $0b, $0b, $0b, $0a, $0a,
            $0a, $09, $09, $09, $08, $08, $08, $07,
            $07, $07, $06, $06, $06, $05, $05, $05,
            $05, $04, $04, $04, $04, $03, $03, $03,
            $03, $02, $02, $02, $02, $02, $01, $01,
            $01, $01, $01, $01, $01, $01, $00, $00,
            $00, $00, $00, $00, $00, $00, $00, $00,
            $00, $00, $00, $00, $00, $00, $00, $00,
            $00, $00, $00, $01, $01, $01, $01, $01,
            $01, $01, $01, $02, $02, $02, $02, $02,
            $03, $03, $03, $03, $04, $04, $04, $04,
            $05, $05, $05, $05, $06, $06, $06, $07,
            $07, $07, $08, $08, $08, $09, $09, $09,
            $0a, $0a, $0a, $0b, $0b, $0b, $0c, $0c,
            $0c, $0d, $0d, $0e, $0e, $0e, $0f, $0f
        }
    }
    
    ;dis worx
    ;lda #w_player_hp
    ;ldx #$0007
    ;jsl hud_writethreedigitnumber
    
    
    .writethreedigitnumber: {
        ;A = pointer to number to write
            ;number must be bcd
        ;x = index into w_hud_buffer
        
        ;print pc
        
        sta p_0
        lda (p_0)
        
        pha
        pha
        
        and #$000f              ;rightmost digit
        clc
        adc #$0030
        sep #$20
        sta w_hud_buffer,x      ;index from argument
        rep #$20
        
        pla                     ;second digit
        and #$00f0
        lsr
        lsr
        lsr
        lsr
        clc
        adc #$0030
        sep #$20
        sta w_hud_buffer-1,x    ;index from argument
        rep #$20
        
        pla                     ;third digit
        and #$0f00
        xba
        clc
        adc #$0030
        sep #$20
        sta w_hud_buffer-2,x    ;index from argument
        rep #$20
        
        rtl
    }
    
    
    .test: {
        phb
        phx
        
        phk
        plb
        
        ldx #datasize(hud_test_string)-1
        
        sep #$20
        {
            -
            lda hud_test_string,x
            sta w_hud_buffer,x
            
            dex
            bpl -
        }
        rep #$20
        
        plx
        plb
        rtl
        
        ..string: {
            db "life:                           "
            db "            hud string", !hud_end
        }
    }
}

.dummylabel3:
    ;for datasize of above