shot: {
    .top: {
        phk
        plb
        
        jsr shot_runmain
        jsr shot_moveall
        jsr shot_cullall
        jsr shot_collision
        jsr shot_drawall
        
        rtl
    }
    
    .runmain: {
        ;i guess you could use this for animations
        
        ldx #!shot_count*2
        
        -
        lda w_shot_mainptr,x
        beq +
        jsr (w_shot_mainptr,x)
        +
        dex
        dex
        bpl -
        
        
        rts
    }
    
    .draw: {
        ;arguments:
        ;x = shot index
        
        ;used in routine:
        ;p_0 = x position on screen
        ;p_2 = y position on screen
        ;p_4 = number of sprites in spritemap to draw
        ;p_8 = palette bits
        
        phb
        phx
        phy
        
        phk
        plb
        
        lda w_shot_x,x
        sec
        sbc w_level_camerax
        sta p_0                     ;x position on screen
        
        lda w_shot_y,x
        sec
        sbc w_level_cameray
        sta p_2                     ;y position on screen
        
        lda w_shot_pal,x
        and #$00ff
        sta p_8
        
        lda w_shot_spritemap_ptr,x
        tay                         ;y = spritemap pointer
        
        ldx w_oam_index
        
        pea.w bank(shot)<<8         ;just in case we put spritemaps elsewhere
        plb
        plb
        
        lda $0000,y
        and #$00ff
        sta p_4
        iny
        
        ..nextsprite
        
        sep #$20
        {
            lda $0000,y             ;x pos from spritemap (relative to object)
            clc                         ;signed byte
            adc p_0                 ;onscreen position
            sta.l w_oam_lo_buffer,x
            
            lda $0001,y             ;y pos from spritemap (relative to object)
            clc                         ;signed byte
            adc p_2                 ;onscreen position
            sta.l w_oam_lo_buffer+1,x
            
            lda $0002,y             ;tile index
            sta.l w_oam_lo_buffer+2,x
            
            lda $0003,y             ;flips/properties
            eor p_8
            sta.l w_oam_lo_buffer+3,x
            
            ;high table
            
            {
                phx
                
                txa                         ;x/4 (for hi table byte array)
                lsr
                lsr
                tax
                
                lda $0004,y
                sta.l w_oam_hi_bytebuffer,x     ;oam hi buffer
                
                plx
            }
        }
        rep #$20
        
        iny
        iny
        iny
        iny
        iny
        
        inx
        inx
        inx
        inx
        
        dec p_4
        bne ..nextsprite
        
        stx w_oam_index
        
        ply
        plx
        plb
        rts
    }
    
    .cullall: {
        ldx #!shot_count*2
        
        -
        lda w_shot_id,x
        beq +
        jsr shot_cull
        +
        dex
        dex
        bpl -
        
        rts
    }
    
    .cull: {
        ;x = shot index
        ;print pc
        
        lda w_level_camerax
        clc
        adc #$00f0
        cmp w_shot_x,x
        bpl +
        jsr shot_clear
        +
        
        lda w_level_camerax
        cmp w_shot_x,x
        bmi +
        jsr shot_clear
        +
        
        lda w_level_cameray
        clc
        adc #$00e8
        cmp w_shot_y,x
        bpl +
        jsr shot_clear
        +
        
        lda w_level_cameray
        cmp w_shot_y,x
        bmi +
        jsr shot_clear
        +
        
        rts
    }
    
    .drawall: {
        ldx #!shot_count*2
        
        -
        lda w_shot_spritemap_ptr,x
        beq +
        jsr shot_draw
        +
        dex
        dex
        bpl -
        
        rts
    }
    
    .findslot: {
        ldx #!shot_count*2
        
        -
        lda w_shot_id,x
        beq ..slotfound
        dex
        dex
        bpl -
        ;returns x = $fffe if no slot found
        
        ..slotfound:
        ;returns x = available shot index
        rts
    }
    
    .collision: {
        ;this nested for loop lags like hell
        ;currently we have 16 shots as max, but maybe we could get away with 8 or fewer
        phx
        
        ldx #!shot_count*2
        
        {   ;for each shot,
            -
            lda w_shot_id,x     ;for every shot that exists, check every fae that exists for collision
            beq +
            phx
            txy                 ;in the inner loop, y = shot index
            jsr shot_collision_checkfae
            plx
            +
            dex
            dex
            bpl -
        }
        
        plx
        rts
        
        ..checkfae: {
            ;y = shot index
            
            ;for each fae,
            ldx #!fae_count*2
            
            -
            lda w_fae_id,x
            beq +
            {
                ;arguments:
                ;x = fae index
                ;y = shot index
                
                ;p_0 = left bound
                ;p_2 = right bound
                ;p_4 = bottom bound
                ;p_6 = top bound
                
                ;calc shot hitbox
                
                lda w_shot_x,y              ;shot x - x size = left bound
                sec
                sbc w_shot_xsize,y
                sta p_0                     ;in p_0
                
                lda w_shot_x,y              ;shot x + x size = right bound
                clc
                adc w_shot_xsize,y          ;in p_2
                sta p_2
                
                lda w_shot_y,y              ;shot y + y size = bottom bound
                clc
                adc w_shot_ysize,y
                sta p_4                     ;in p_4
                
                lda w_shot_y,y              ;shot y - y size = top bound
                sec
                sbc w_shot_ysize,y
                sta p_6                     ;in p_6
                
                ;
                ;calc fae hitbox
                ;
                
                lda w_fae_x,x
                clc
                adc w_fae_xsize,x
                cmp p_0             ;shot left bound
                bmi +
                
                lda w_fae_x,x
                sec
                sbc w_fae_xsize,x
                cmp p_2             ;shot right bound
                bpl +
                
                lda w_fae_y,x
                sec
                sbc w_fae_ysize,x
                cmp p_4             ;shot bottom bound
                bpl +
                
                lda w_fae_y,x
                clc
                adc w_fae_ysize,x
                cmp p_6             ;shot top bound
                bmi +
                
                lda w_fae_shotptr,x
                beq +
                jsl fae_runshot
                phx
                tyx
                jsr shot_clear
                plx
                
                +
                ;no collision
            
            
            }
            ;next x
            +
            dex
            dex
            bpl -
            
            rts
        }
    }
    
    .hit: {
        ;x = fae index
        ;y = shot index
        
        ;maybe don't need this. inlined it above
        ;i guess for optimization
        
        ;oh also this jsr,x needs to be in the fae bank (currently $81)
        ;so don't use this lmoa
        
        phx
        phy
        
        jsr (w_fae_shotptr,x)
        
        ply
        plx
        rts
    }
    
    
    .spawn: {
        ;a = shot header ptr
        
        phx
        phy
        phb
        
        sta p_0                     ;shot header ptr
        
        jsr shot_findslot
        
        ;x = shot index
        bmi ..noslotavailable
        
        phk
        plb
        
        lda p_0
        tay
        
        sta w_shot_id,x
        
        lda $0000,y
        sta w_shot_xsize,x
        
        lda $0002,y
        sta w_shot_ysize,x
        
        lda $0004,y
        sta w_shot_basespeed,x
        
        lda $0006,y
        sta w_shot_mainptr,x
        
        lda $0008,y
        sta w_shot_initptr,x
        
        lda $000a,y
        sta w_shot_spritemap_ptr,x
        
        ;instance data
        
        lda w_player_x
        sec
        sbc #$0004
        sta w_shot_x,x
        
        lda w_player_subx
        sta w_shot_subx,x
        
        lda w_player_y
        sec
        sbc #$0004
        sta w_shot_y,x
        
        lda w_player_suby
        sta w_shot_suby,x
        
        lda w_player_xspeed
        sta w_shot_xspeed,x
        
        lda w_player_xsubspeed
        sta w_shot_xsubspeed,x
        
        lda w_player_yspeed
        sta w_shot_yspeed,x
        
        lda w_player_ysubspeed
        sta w_shot_ysubspeed,x
        
        jsr (w_shot_initptr,x)
        
        ..noslotavailable
        plb
        ply
        plx
        rtl
    }
    
    .basespeedsign: {
        ;x = shot index
        ;uses w_player_lastknowndirection to choose sign of w_shot_basespeed
        ;puts base x speed in p_0
        ;puts base y speed in p_2
        
        lda w_player_lastknowndirection
        bit #!controller_rt
        beq ..nort
        {
            ;if direction bit for right present,
            pha
            lda w_shot_basespeed,x
            sta p_0
            pla
        }
        ..nort
        
        bit #!controller_lf
        beq ..nolf
        {
            ;if direction bit for left present,
            ;then base x speed is ngeative, invert sign
            pha
            lda w_shot_basespeed,x
            eor #$ffff
            inc
            sta p_0
            pla
        }
        ..nolf
        
        bit #!controller_up
        beq ..noup
        {
            ;if direction bit for up present,
            ;then base y speed is negative, invert sign
            pha
            lda w_shot_basespeed,x
            eor #$ffff
            inc
            sta p_2
            pla
        }
        ..noup    

        bit #!controller_dn
        beq ..nodn
        {
            ;if direction bit for down present,
            pha
            lda w_shot_basespeed,x
            sta p_2
            pla
        }
        ..nodn
        
        rts
    }
    
    .move: {
        ;x   = shot index
        ;stz p_0
        ;stz p_2
        
        ;jsr shot_basespeedsign
        ;p_0 = base x speed
        ;p_2 = base y speed
        
        lda w_shot_subx,x
        clc
        adc w_shot_xsubspeed,x
        sta w_shot_subx,x
        
        lda w_shot_x,x
        adc w_shot_xspeed,x
        ;clc
        ;adc p_0
        sta w_shot_x,x
        
        lda w_shot_suby,x
        clc
        adc w_shot_ysubspeed,x
        sta w_shot_suby,x
        
        lda w_shot_y,x
        adc w_shot_yspeed,x
        ;clc
        ;adc p_2
        sta w_shot_y,x
        
        rts
    }
    
    .moveall: {
        phk
        plb
        
        ldx #!shot_count*2
        
        -
        lda w_shot_id,x
        beq +
        jsr shot_move
        +
        dex
        dex
        bpl -
        
        rts
    }
    
    
    .clearall: {
        phk
        plb
        
        ldx #!shot_count*2
        
        -
        jsr shot_clear
        dex
        dex
        bpl -
        
        rtl
    }
    
    .clear: {
        ;x = index
        
        stz w_shot_id,x
        stz w_shot_x,x
        stz w_shot_y,x
        stz w_shot_subx,x
        stz w_shot_suby,x
        stz w_shot_xspeed,x
        stz w_shot_xsubspeed,x
        stz w_shot_yspeed,x
        stz w_shot_ysubspeed,x
        stz w_shot_spritemap_ptr,x
        stz w_shot_xsize,x
        stz w_shot_ysize,x
        stz w_shot_basespeed,x
        stz w_shot_mainptr,x
        stz w_shot_initptr,x
        stz w_shot_pal,x
        stz w_shot_counter,x
        
        rts
    }
    
    
    
    
}