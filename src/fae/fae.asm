fae: {
    .addspritemap: {
        ;================================== ADD ENTIRE SPRITEMAP TO OAM ==================================
        
        
        ;adds one spritemap to oam
        ;argument:
        ;p_0 = long pointer to spritemap
        ;x = fae index
        
        ;used inroutine:
        ;p_4  = sprite counter
        ;p_6  = fae x onscreen position
        ;p_8  = fae y onscreen position
        ;p_a  = extra x bit
        ;p_c  = just put this value down for a sec to recheck its psr bits
        ;p_e  = used for halving the x radius for drawing offset
        ;p_10 = used for halving the y radius for drawing offset
        
        phx
        phy
        phb
        
        pei (p_1)               ;db = spritemap bank
        plb
        plb
        
        lda w_fae_xsize,x
        lsr
        lsr
        sta p_e
        
        lda w_fae_ysize,x
        lsr
        lsr
        sta p_10
        
        lda w_fae_x,x
        sec
        sbc w_level_camerax
        sec
        sbc p_e
        sta p_6                 ;fae onscreen x position
        
        lda w_fae_y,x
        sec
        sbc w_level_cameray
        sec
        sbc p_10
        sta p_8                 ;fae onscreen y position
        
        ldx p_0                 ;x = spritemap ptr
        ldy w_oam_index         ;y = oam entry point
        
        lda $0000,x
        and #$00ff
        sta p_4                 ;number of sprites
        inx
        
        ..nextsprite
        
        stz p_a                  ;extra x bit if present (clear from previous iteration)
        
        ; =================================== x position ===================================
        
        {
            lda $0000,x                     ;add camera position to fae's
            and #$00ff
            
            xba                             ;check low byte sign
            xba
            bpl +
            
            ora #$ff00                      ;sign extend if needed
            
            +
            clc                             ;object position
            adc p_6                         ;sep/rep is cheaper than sign extending
            sta p_c
            
            cmp #$0100
            bpl ..skip                      ;right offscreen case
            
            lda p_c
            bpl +
            
            ;left offscreen case
            
            and #$00ff                      ;if negative, add extra x bit and remove high byte
            pha
            
            lda #$0001                      ;x high bit to be or'd in in high table write later
            sta p_a
            
            pla
            +
            sta w_oam_lo_buffer,y           ;x
        }
        
        ; =================================== y position ===================================
        
        {
            lda $0001,x
            and #$00ff
            
            xba                             ;check low byte sign
            xba
            bpl +
            
            ora #$ff00                      ;sign extend
            
            +
            clc
            adc p_8
            
            cmp #$00f0                      ;down offscreen case
            bpl ..skip                      ;if far enough offscreen, stop entirely
            
            cmp #$fff0                      ;up offscreen case
            bpl +
            
            ;clump to $e0 based on being inside the offscreen seam (should be enough for 8 and 16px)
            
            lda #$00e0
            
            +
            and #$00ff
            sta w_oam_lo_buffer+1,y         ;y
        }
        
        ; =============================== tile and properties ==============================
        
        lda $0002,x
        and #$00ff
        sta w_oam_lo_buffer+2,y         ;tile
        
        lda $0003,x
        and #$00ff
        sta w_oam_lo_buffer+3,y         ;properties bit field
        
        ; =================================== high table ===================================
        
        {
            phy
            
            tya                         ;y/4 (for hi table byte array)
            lsr
            lsr
            tay
            
            lda $0004,x
            and #$00ff
            ora p_a                         ;add extra x bit if present
            sta w_oam_hi_bytebuffer,y       ;oam hi buffer
            
            ply
        }
        
        iny
        iny
        iny
        iny
        
        ..skip              ;advance spritemap pointer (x) but not oam index (y)
        
        inx
        inx
        inx
        inx
        inx
        
        
        dec p_4
        bne ..nextsprite
        
        sty w_oam_index
        
        ..return
        
        rep #$20
        
        plb
        ply
        plx
        rts
        
        .long: {
            jsr fae_addspritemap
            rtl
        }
    }
    
    
    .top: {
        ;===================================== FAE TOP =====================================
        ;high-level fae routine called from main gameplay
        
        phk
        plb
        
        jsr fae_collision               ;let collision delete them
        jsr fae_runmainroutines         ;let fae manipulate their spritemaps!
        jsr fae_drawall                 ;them draw
        
        rtl
    }
    
    
    .runshot: {
        jsr (w_fae_shotptr,x)
        
        rtl
    }
    
    
    .drawall: {
        lda #bank(fae)
        sta p_2
        
        ldx #!fae_count*2
        
        -
        lda w_fae_spritemapptr,x
        beq +
        sta p_0
        jsr fae_addspritemap
        +
        dex
        dex
        bpl -
        
        rts
    }
    
    .collisionhudtest: {
        ;just prints the word on the hud
        ;there's a test harness at gameplay_hudwordtest
        ;that serves to clear this word occasionally
        
        lda.l fae_collisionhudtest_word
        sta w_hud_buffer+10
        
        lda.l fae_collisionhudtest_word+2
        sta w_hud_buffer+12
        
        rts
        
        ..word:
            db "hit!"
    }
    
    .hitplayertest: {
        ;print pc
        ;
        ;eventually i want to have the fae do variable damage
        ;for ease of writing it, the hud routine uses bcd
        ;but all the fae damage values will be in hex
        ;actually, since i haven't written it yet, maybe the fae contact damage
        ;could be in bcd?
        sed
        
        lda w_player_hp
        sec
        sbc #$0001
        sta w_player_hp
        
        cld
        
        lda w_player_hurtglowcooldown
        bne +
        ldy #glow_playerhurt
        jsl glow_spawn
        +
        
        ;lda w_player_iframes
        ;bne +
        
        ;lda #shot_shield
        ;jsl shot_spawn
        ;+
        
        rts
    }
    
    .collision: {
        lda w_player_iframes
        bne ..nocollision
        
        ldx #!fae_count*2
        
        -
        lda w_fae_touchptr,x
        beq +
        jsr fae_collision_check
        bcc +
        jsr (w_fae_touchptr,x)
        jsr fae_collisionhudtest
        jsr fae_hitplayertest
        +
        dex
        dex
        bpl -
        
        ..nocollision
        rts
        
        ..check: {
            ;x = fae index
            
            lda w_fae_x,x
            clc
            adc w_fae_xsize,x
            cmp w_player_hitboxleft
            bmi +
            
            lda w_fae_x,x
            sec
            sbc w_fae_xsize,x
            cmp w_player_hitboxright
            bpl +
            
            lda w_fae_y,x
            sec
            sbc w_fae_ysize,x
            cmp w_player_hitboxtop
            bpl +
            
            lda w_fae_y,x
            clc
            adc w_fae_ysize,x
            cmp w_player_hitboxbottom
            bmi +
            
            sec     ;collision
            rts
            
            +
            clc     ;no collision
            rts
        }
    }
    
    
    .runmainroutines: {
        phx
        
        ldx #!fae_count*2
        
        -
        lda w_fae_mainptr,x
        beq +
        jsr (w_fae_mainptr,x)
        +
        dex
        dex
        bpl -
        
        plx
        rts
    }
    
    
    .spawnall: {
        ;used in routine
        ;p_6 = hold fae list + index
        
        
        phb
        phx
        phy
        
        pea.w bank(faelist)<<8                  ;db = faelist bank (hirom most likely)
        plb
        plb
        
        lda.l w_level_faelist_ptr                 ;y = fae list pointer
        tay
        
        ..nextfae
        
        lda $0000,y                             ;a = fae id
        cmp #$ffff
        beq ..return                            ;list terminator
        
        phb
        phy
        jsl fae_spawn
        ply
        plb
        
        tya
        clc
        adc #!fae_list_entry_length
        tay
        
        bra ..nextfae
        
        ..return
        ply
        plx
        plb
        rtl
    }
    
    
    .spawn: {
        ;arguments:
        ;x = fae index
        ;y = fae list ptr
        ;a = fae id (pointer to header)
        
        ;used in routine:
        ;p_4 = used to hold fae id temporarily
        
        ;assumes db = faelist bank
        
        phx
        
        sta p_4             ;p_4 = A = fae id, from call
        
        ldx #!fae_count*2
        
        -
        lda.l w_fae_id,x
        beq ..slotfound
        dex
        dex
        bpl -
        bmi ..noslots
        
        ..slotfound:
        
        ;y = pointer to fae list entry
        
        lda $0002,y
        sta.l w_fae_x,x
        
        lda $0004,y
        sta.l w_fae_y,x
        
        lda $0006,y
        sta.l w_fae_var1,x
        
        lda $0008,y
        sta.l w_fae_var2,x
        
        lda $000a,y
        sta.l w_fae_var3,x
        
        lda p_4
        sta.l w_fae_id,x
        tay                 ;y = pointer to fae header
        
        pea.w bank(fae)<<8  ;db = fae bank
        plb
        plb
        
        lda $0000,y
        sta w_fae_mainptr,x
        
        lda $0002,y
        sta w_fae_touchptr,x
        
        lda $0004,y
        sta w_fae_initptr,x
        
        lda $0006,y
        sta w_fae_shotptr,x
        
        lda $0008,y
        sta w_fae_spritemapptr,x
        
        lda $000a,y
        sta w_fae_xsize,x
        
        lda $000c,y
        sta w_fae_ysize,x
        
        
        jsr (w_fae_initptr,x)
        
        ..noslots:
        ;this could return with x = $fffe if no slots found
        ;would need to get rid of phx/plx, or do txy or something and use y
        ;not sure i care about detercting this at the moment, but could
        plx
        rtl
    }
    
    
    
    .clearall: {
        phx
        phb
        
        phk
        plb
        
        ldx #!fae_count*2
        
        -
        jsr fae_clear
        dex
        dex
        bpl -
        
        plb
        plx
        rtl
    }
    
    .clear: {
        ;x = fae index
        
        stz w_fae_id,x
        stz w_fae_x,x
        stz w_fae_subx,x
        stz w_fae_y,x
        stz w_fae_suby,x
        stz w_fae_spritemapptr,x
        stz w_fae_touchptr,x
        stz w_fae_mainptr,x
        stz w_fae_initptr,x
        stz w_fae_xsize,x
        stz w_fae_ysize,x
        stz w_fae_var1,x
        stz w_fae_var2,x
        stz w_fae_var3,x
        
        rts
    }
    
    .spritedrawingtest: {
        phb
        
        phk
        plb
        
        ldx #!fae_count*2           ;first slot
        
        lda #$0080
        sta w_fae_x,x
        
        lda #$0080
        sta w_fae_y,x
        
        lda #fae_quadrant_test1
        sta p_0
        lda #bank(fae)
        sta p_2
        
        ldx #!fae_count*2
        jsl fae_addspritemap
        
        
        
        ldx #(!fae_count-2)*2           ;second slot
        
        lda #$0180
        sta w_fae_x,x
        
        lda #$0080
        sta w_fae_y,x
        
        lda #fae_quadrant_test2
        sta p_0
        lda #bank(fae)
        sta p_2
        
        ldx #(!fae_count-2)*2
        jsl fae_addspritemap
        
        
        
        ldx #(!fae_count-3)*2           ;third slot
        
        lda #$0080
        sta w_fae_x,x
        
        lda #$0180
        sta w_fae_y,x
        
        lda #fae_quadrant_test3
        sta p_0
        lda #bank(fae)
        sta p_2
        
        ldx #(!fae_count-3)*2
        jsl fae_addspritemap
        
        
        
        ldx #(!fae_count-4)*2           ;fourth slot
        
        lda #$0180
        sta w_fae_x,x
        
        lda #$0180
        sta w_fae_y,x
        
        lda #fae_quadrant_test4
        sta p_0
        lda #bank(fae)
        sta p_2
        
        ldx #(!fae_count-4)*2
        jsl fae_addspritemap
        
        
        plb
        rtl
    }
    
    
    .quadrant_test1: {
        db 01
        ;   xx   yy   tt  properties  hh
        db $00, $00, $40, %00111111, $02
    }
    
    .quadrant_test2: {
        db 01
        ;   xx   yy   tt  properties  hh
        db $00, $00, $42, %00111111, $02
    }
    
    .quadrant_test3: {
        db 01
        ;   xx   yy   tt  properties  hh
        db $00, $00, $44, %00111111, $02
    }
    
    .quadrant_test4: {
        db 01
        ;   xx   yy   tt  properties  hh
        db $00, $00, $46, %00111111, $02
    }
    
}