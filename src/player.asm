;===========================================================================================
;======================================= PLAYER ============================================
;===========================================================================================


player: {
;======================================= INIT ==============================================
;called from loadgame state. set up initial player state
;player position is set in 'scenetransition' in main.asm

    .init: {
        lda w_level_playerstartx
        sta w_player_x
        
        lda w_level_playerstarty
        sta w_player_y
        
        lda #!player_xsize_default
        sta w_player_xsize
        
        lda #!player_ysize_default
        sta w_player_ysize
        
        stz w_player_xspeed
        stz w_player_xsubspeed
        
        stz w_player_yspeed
        stz w_player_ysubspeed
        
        stz w_player_iframes
        
        ;jsr player_olddraw             ;test sprite not real
        ;jsr player_draw                ;don't think this is necessary anymore
        
        rtl
    }
    
;===================================== CALCHITBOX ==========================================

    .calchitbox: {
        ;x   = pointer to ram variable to use for horizontal
        ;y   = pointer to ram variable to use for vertical
        ;p_4 = hitbox size (except not right now)
        
        stx p_0
        sty p_2
        ;sta p_4
        
        ;lda w_player_x              ;player x - x size = left bound
        lda (p_0)
        sec
        sbc w_player_xsize
        ;sbc p_4
        sta w_player_hitboxleft
        
        ;lda w_player_x              ;player x + x size = right bound
        lda (p_0)
        clc
        adc w_player_xsize
        ;adc p_4
        sta w_player_hitboxright
        
        ;lda w_player_y              ;player y + y size = bottom bound
        lda (p_2)
        clc
        adc w_player_ysize
        ;adc p_4
        sta w_player_hitboxbottom
        
        ;lda w_player_y              ;player y + y size = top bound
        lda (p_2)
        sec
        sbc w_player_ysize
        ;sbc p_4
        sta w_player_hitboxtop
        
        rts
    }
    
;======================================= HITBOXSIZE ========================================
;the call to this in player_main is currently commented out
;added this based on a comment mysty made about doing something like this
;for collision reasons. but i think what actually i should do is check ahead of the player
;and not literally expand the hitbox. so, this is unlikely to be needed

    .hitboxsize: {
        lda w_player_direction
        beq +
        
        lda #!player_xsize_default-4        ;if moving... why is subtracting making it bigger?
        sta w_player_xsize
        
        lda #!player_ysize_default-4
        sta w_player_ysize
        
        rts
        
        +
        lda #!player_xsize_default          ;if not moving
        sta w_player_xsize
        
        lda #!player_ysize_default
        sta w_player_ysize
        
        rts
    }
    
    
;========================================= TICKIFRAMES =====================================
;count iframes down to 0
;
    
    .tickiframes: {
        lda w_player_hurtglowcooldown
        beq +
        
        dec
        sta w_player_hurtglowcooldown
        +
        
        lda w_player_iframes
        beq +
        dec
        sta w_player_iframes
        +
        
        rts
    }
    
;================================ UPDATELASTKNOWNDIRECTION =================================
;if direction = 0, don't update previous direction. otherwise, update previous direction
;
    .updatelastknowndirection: {
        lda w_player_direction
        beq +
        
        sta w_player_lastknowndirection
        
        +
        rts
    }
    
;==================================== COLLISIONWRAPPER =====================================
;runs player_collision to get collision reactions in each direction
;right before this, player_calchitbox is run with w_player_nextx/nexty
;at some point after, it's run again with w_player_x/y

    .collisionwrapper: {
        ldx #w_player_hitboxleft    ;hitbox left edge
        ldy #w_player_y
        lda #w_player_tileindex
        jsl locateontile            ;translate player pixel position into tile index (using next suggested position)
        jsr player_collision        ;
        
        ldx #w_player_hitboxright   ;hitbox right edge
        ldy #w_player_y
        lda #w_player_tileindex
        jsl locateontile            ;translate player pixel position into tile index (using next suggested position)
        jsr player_collision        ;
        
        ldx #w_player_x
        ldy #w_player_hitboxtop     ;top edge
        lda #w_player_tileindex
        jsl locateontile            ;translate player pixel position into tile index (using next suggested position)
        jsr player_collision        ;
        
        ldx #w_player_x
        ldy #w_player_hitboxbottom  ;bottom edge
        lda #w_player_tileindex
        jsl locateontile            ;translate player pixel position into tile index (using next suggested position)
        jsr player_collision        ;
        
        rts
    }
    
    
;===================================== CHECKFORDEATH =======================================
    .checkfordeath: {
        lda w_player_hp
        bmi ++                          ;if negative, die
        bne +                           ;if not 0, exit
                                        ;if 0, die
        ++
        lda w_scene_ptr                 ;save room for resume game
        sta.l s_roomptr
        
        lda #!state_setupgameoverscreen
        sta w_gameplayfadeoutstate
        
        +
        rts
    }
    
;===========================================================================================
;======================================= PLAYER_MAIN =======================================
;===========================================================================================
;high level player routine called from main gameplay
;handles taking input, collision, movement, locating on screen and drawing
;
    .main: {
        phk
        plb
        
        stz w_player_keepprevlocation
        
        jsr player_updatepreviousposition
        
        jsr player_input            ;get input. adds direction bits to w_player_direction
        ;jsr player_boundscheck      ;hardcoded test harness for level bounds
        jsr player_tickiframes      ;count iframes down to 0
        
        lda w_player_direction      ;suggested directions
        jsr player_suggestlocation  ;calculate nextx/y position for checking what collision would be
        
        ldx #w_player_nextx
        ldy #w_player_nexty
        jsr player_calchitbox       ;use for collision with tiles, use next suggested position
        
        jsr player_collisionwrapper ;comment out to test loading seam
        
        jsr player_applyvelocity    ;use subspeed and speed to affect player position
        jsr player_decelerate       ;use the same to do the same (but inverse, if dpad not held)
        
        lda w_player_direction
        jsr player_move             ;move in the directions of remaining direction bits
        
        ldx #w_player_x
        ldy #w_player_y
        jsr player_calchitbox       ;use for collision with objects and fae, use actual updated position
        
        jsr player_updatelastknowndirection
        
        jsr player_checkfordeath
        
        lda #w_player_hp
        ldx #$0007
        jsl hud_writethreedigitnumber
        
        ;locate player on screen
        
        lda w_player_x
        sec
        sbc w_level_camerax
        sta w_player_x_onscreen
        
        lda w_player_y
        sec
        sbc w_level_cameray
        sta w_player_y_onscreen
        
        ;then draw
        
        jsr player_draw
        
        rtl
    }
    
;====================================== UPDATEPREVIOUSPOSITION =============================

    .updatepreviousposition: {
        lda w_player_x
        sta w_player_prevx
        
        lda w_player_y
        sta w_player_prevy
        
        lda w_player_subx
        sta w_player_prevsubx
        
        lda w_player_suby
        sta w_player_prevsuby
        
        rts
    }

;======================================= DECELERATE ========================================
;if no direction bits are present, call player_move for the opposite direction
;for which we have speed
;e.g., if we have positive x speed (going right), call player_move for going left
    
    .decelerate: {
        pha
        lda w_player_direction
        bne ..return
        
        lda w_player_xspeed
        bmi +
        lda #!controller_lf
        jsr player_move
        +
        
        lda w_player_xspeed
        bpl +
        lda #!controller_rt
        jsr player_move
        +
        
        lda w_player_yspeed
        bmi +
        lda #!controller_up
        jsr player_move
        +
        
        lda w_player_yspeed
        bpl +
        lda #!controller_dn
        jsr player_move
        +
        
        
        ..return
        pla
        rts
    }
    
;======================================= APPLYVELOCITY =====================================
;subpixel and subspeed to subpixel and pixel 32 bit adds
;
    .applyvelocity: {
        ..y
            lda w_player_suby
            clc
            adc w_player_ysubspeed
            sta w_player_suby
            
            lda w_player_y
            adc w_player_yspeed
            sta w_player_y
            
        ..x
            lda w_player_subx
            clc
            adc w_player_xsubspeed
            sta w_player_subx
            
            lda w_player_x
            adc w_player_xspeed
            sta w_player_x
        
        rts
    }
    
;======================================= SUGGESTLOCATION =====================================
;subpixel and subspeed to subpixel and pixel 32 bit adds
;same as the above but happens earlier in the logic
;uses previous location and makes a suggested next location, which is teh nused for collision checks
;
    .suggestlocation: {
        ..y
        
            lda w_player_prevsuby
            clc
            adc w_player_ysubspeed
            sta w_player_nextsuby
            
            lda w_player_prevy
            adc w_player_yspeed
            sta w_player_nexty
        
        ..x
        
            lda w_player_prevsubx
            clc
            adc w_player_xsubspeed
            sta w_player_nextsubx
            
            lda w_player_prevx
            adc w_player_xspeed
            sta w_player_nextx
        
        rts
    }
    
;============================================ MOVE =========================================
;takes argument in A for direction bits (same as controller's dpad bits)
;32 adds speed to velocity
;
    
    .move: {
        ;A = direction bits
        
        bit #!controller_up
        beq ..noup
        {
            pha
            bit w_player_keepprevlocation
            bne +
            jsr player_move_up
            bra ++
            +
            
            ;lda w_player_prevx
            ;sta w_player_x
            ++
            pla
        }
        ..noup
        
        bit #!controller_dn
        beq ..nodn
        {
            pha
            bit w_player_keepprevlocation
            bne +
            jsr player_move_down
            bra ++
            +
            
            ;lda w_player_prevy
            ;sta w_player_y
            ++
            pla
        }
        ..nodn
        
        bit #!controller_lf
        beq ..nolf
        {
            pha
            bit w_player_keepprevlocation
            bne +
            jsr player_move_left
            bra ++
            +
            
            ;lda w_player_prevx
            ;sta w_player_x
            ++
            pla
        }
        ..nolf
        
        
        bit #!controller_rt
        beq ..nort
        {
            pha
            bit w_player_keepprevlocation
            bne +
            jsr player_move_right
            bra ++
            +
            
            ;lda w_player_prevx
            ;sta w_player_x
            ++
            pla
        }
        ..nort
        
        rts
        
        ..up: {
            lda w_player_yspeed
            cmp.w #-!player_max_speed
            bmi ...skip
            
            lda w_player_ysubspeed
            sec
            sbc #!player_y_subvelocity
            sta w_player_ysubspeed
            
            lda w_player_yspeed
            sbc #!player_y_velocity
            sta w_player_yspeed
            
            ...skip
            
            rts
        }
        
        ..down: {
            lda w_player_yspeed
            cmp.w #!player_max_speed
            bpl ...skip
            
            lda w_player_ysubspeed
            clc
            adc #!player_y_subvelocity
            sta w_player_ysubspeed
            
            lda w_player_yspeed
            adc #!player_y_velocity
            sta w_player_yspeed 
            
            ...skip
            
            rts
        }
        
        ..right: {
            lda w_player_xspeed
            cmp.w #!player_max_speed
            bpl ...skip
            
            lda w_player_xsubspeed
            clc
            adc #!player_x_subvelocity
            sta w_player_xsubspeed
            
            lda w_player_xspeed
            adc #!player_x_velocity
            sta w_player_xspeed
            
            ...skip
            
            rts
        }
        
        ..left: {
            lda w_player_xspeed
            cmp.w #-!player_max_speed
            bmi ...skip
            
            lda w_player_xsubspeed
            sec
            sbc #!player_x_subvelocity
            sta w_player_xsubspeed
            
            lda w_player_xspeed
            sbc #!player_x_velocity
            sta w_player_xspeed
            
            ...skip
            
            rts
        }
    }
    

;======================================= COLLISION =========================================
;w_player_keepprevlocation
;contains 4 flags, one for each direction
;signaling to the later call to player_move that we should skip updating position in that direction

;collision format is one byte:
;%aaaatttt
;a = argument; data to pass to tile collision handler
;t = tile collision type, used to index jump table
    
    .collision: {
        phx
        phy
        
        ldx w_player_tileindex          ;next suggested collision based on w_player_nextx/nexty
        lda.l l_level_collision,x
        pha
        
        and #$000f                      ;x = bottom nibble = collision type
        asl
        tax                             ;for jump table index
        
        pla
        and #$00f0                      ;y = second nibble = argument
        lsr
        lsr
        lsr
        lsr
        tay
        
        jsr (player_collision_table,x)
        
        ply
        plx
        rts
        
        ..table: {
            dw player_collision_air,                ;0
               player_collision_solid,              ;1
               player_collision_directionalwall,    ;2
               player_collision_test                ;3
        }
        
        ..test: {
            ;brk #$00
            rts
        }
        
        ..air: {
            ;what could even want to happen here?
            rts
        }
        
        ..directionalwall: {
            ;y = top nibble of collision byte
            ;in this context, the top nibble is the same as used in direction/controller bits 
            ;!controller_up                        =       $0800
            ;!controller_dn                        =       $0400
            ;!controller_lf                        =       $0200
            ;!controller_rt                        =       $0100
            
            tya
            xba         ;line up nibble with dpad bits of controller
            ;a = direction bits from collided tile
            
            jsr player_decelerate
            jsr player_decelerate
            jsr player_decelerate
            jsr player_decelerate
            jsr player_move
            jsr player_move
            jsr player_move
            jsr player_move


            
            rts
        }
        
        ..solid: {
            ;y = top nibble of collision byte
            
            lda w_player_direction
            beq ...nodirection
            
            bit #!controller_up
            beq +
            {
                pha
                ;stz w_player_yspeed
                ;stz w_player_ysubspeed
                
                ora w_player_keepprevlocation
                sta w_player_keepprevlocation
                
                ;lda #$8000
                ;sta w_player_ysubspeed
                
                lda w_player_lastknowndirection
                eor #!controller_up
                sta w_player_direction
                
                lda #!controller_dn
                jsr player_move
                jsr player_move
                
                pla
            }
            +
            
            bit #!controller_dn
            beq +
            {
                pha
                
                ora w_player_keepprevlocation
                sta w_player_keepprevlocation
                
                lda w_player_lastknowndirection
                eor #!controller_dn
                sta w_player_direction
                
                lda #!controller_up
                jsr player_move
                jsr player_move
                
                ;lda #$8000
                ;sta w_player_ysubspeed
                pla
            }
            +
            
            bit #!controller_lf
            beq +
            {
                pha
                
                ora w_player_keepprevlocation
                sta w_player_keepprevlocation
                
                lda w_player_lastknowndirection
                eor #!controller_lf
                sta w_player_direction
                
                lda #!controller_rt
                jsr player_move
                jsr player_move
                
                pla
            }
            +
            
            bit #!controller_rt
            beq +
            {
                pha
                
                ora w_player_keepprevlocation
                sta w_player_keepprevlocation
                
                lda w_player_lastknowndirection
                eor #!controller_rt
                sta w_player_direction
                
                lda #!controller_lf
                jsr player_move
                jsr player_move
                
                pla
            }
            +
            
            rts
            
            ...nodirection:
            lda w_player_lastknowndirection
            eor #$ffff
            
            jsr player_move
            jsr player_move
            jsr player_move
            jsr player_move
            rts
        }
    }
    
;======================================== BOUNDSCHECK ===================================
;very old hardcoded bounds check for the full room map
;eventually, i want to have a tile object that can modify the bounds used here
;crude ass walls
    
    .boundscheck: {
        ;todo: add level bounds to level metadata
        
        lda w_player_x          ;left bound
        cmp #$0004
        bpl +
        {
            lda #$0004
            sta w_player_x
            
            lda w_player_xspeed
            eor #$ffff
            inc
            sta w_player_xspeed
        }
        +
        
        lda w_player_x          ;right bound
        cmp #$01f0
        bmi +
        {
            lda #$01f0
            sta w_player_x
            
            lda w_player_xspeed
            eor #$ffff
            inc
            sta w_player_xspeed
        }
        +
        
        lda w_player_y          ;top bound
        cmp #$0004
        bpl +
        {
            lda #$0004
            sta w_player_y
            
            lda w_player_yspeed
            eor #$ffff
            inc
            sta w_player_yspeed
        }
        +
        
        lda w_player_y          ;bottom bound
        cmp #$01d0
        bmi +
        {
            lda #$01d0
            sta w_player_y
            
            lda w_player_yspeed
            eor #$ffff
            inc
            sta w_player_yspeed
        }
        +
        
        rts
    }
    

;======================================= INPUT =============================================
;read the controller's wram mirror
;adds controller bits (which become direction bits at this point) to the player movement
;
;
    .input: {
        lda w_controller
        
        bit #!controller_up
        beq ..noup
        {
            ;if up pressed
            pha
            
            lda w_player_direction      ;add up to the direction
            ora #!controller_up
            sta w_player_direction
            
            pla
        }
        ..noup:
        
        bit #!controller_dn
        beq ..nodn
        {
            ;if dn pressed
            pha
            
            lda w_player_direction      ;add down to the direction
            ora #!controller_dn
            sta w_player_direction
            
            pla
        }
        ..nodn:
        
        bit #!controller_lf
        beq ..nolf
        {
            ;if lf pressed
            pha
            
            lda w_player_direction      ;add left to the direction
            ora #!controller_lf
            sta w_player_direction
            
            pla
        }
        ..nolf:
        
        bit #!controller_rt
        beq ..nort
        {
            ;if rt pressed
            pha
            
            lda w_player_direction      ;add rt to the direction
            ora #!controller_rt
            sta w_player_direction
            
            pla
        }
        ..nort:
        
        bit #!controller_b
        beq ..nob
        {
            ;if b pressed, stop moving
            pha
            
            stz w_player_xspeed
            stz w_player_yspeed
            
            stz w_player_ysubspeed
            stz w_player_ysubspeed
            
            stz w_player_suby
            stz w_player_subx
            
            stz w_player_direction
            
            pla
        }
        ..nob:
        
        bit #!controller_x
        beq ..nox
        {
            ;if x pressed
            pha
            
            lda w_nmicounter
            bit #!player_shot_allowed_bitmask
            bne +
            
            lda #shot_bubble
            jsl shot_spawn
            
            +
            pla
        }
        ..nox:
        
        bit #!controller_y
        beq ..noy
        {
            ;if y pressed,
            pha
            
            jsr player_decelerate
            jsr player_decelerate
            
            pla
        }
        ..noy:
        
        bit #!controller_a
        beq ..noa
        {
            ;if a pressed
            pha
            
            ;jsl msg_reset
            lda #speech_testobject
            jsl speech_spawn
            
            pla
        }
        ..noa:
        
        bit #!controller_l
        beq ..nol
        {
            ;if l pressed
            pha
            
            jsl shot_clearall
            
            pla
        }
        ..nol:
        
        bit #!controller_st
        beq ..nost
        {
            ;if start pressed
            pha
            
            lda #$0001
            sta w_hud_glow          ;turn on hud glow
            
            pla
        }
        ..nost:
        
        bit #!controller_sl
        beq ..nosl
        {
            ;if select pressed
            pha
            
            stz w_hud_glow          ;turn off hud glow
            
            ;also save game
            lda w_scene_ptr                 ;save room for resume game
            sta.l s_roomptr
            
            pla
        }
        ..nosl:
        
        bit #!controller_r
        beq ..nor
        {
            ;if select pressed
            pha
            
            lda w_nmicounter
            bit #$0007
            beq +
            jsr player_invertpalette
            +
            
            pla
        }
        ..nor:
        
        
        rts
    }
    
;=========================================== OLDDRAW =======================================
;should delete this. not used anymore. new draw is way better
    
    .olddraw: {
        ;not used anymore
        sep #$20
        
        ldx #$0000
        
        phk
        plb
        
        lda w_nmicounter
        bit #$07
        bne +
        
        lda w_player_animationtimer
        inc
        sta w_player_animationtimer
        cmp #$08
        bmi +
        stz w_player_animationtimer
        lda #$00
        +
        ldy w_player_animationtimer
        
        lda w_player_x_onscreen
        sta w_oam_lo_buffer,x       ;x pos
        inx
        
        lda w_player_y_onscreen
        sta w_oam_lo_buffer,x       ;y pos
        inx
        
        
        rep #$20
        lda w_player_direction
        bit #!controller_lf|!controller_rt
        bne ..h
        lda player_olddraw_animationlist_vert,y
        bra ..v
        ..h
        lda player_olddraw_animationlist_horz,y
        ..v
        sep #$20
        
        sta w_oam_lo_buffer,x       ;tile
        inx
        
        lda #%00111110              ;properties
        sta w_oam_lo_buffer,x
        inx
        
        ;stx oamindex
        
        rep #$20
        
        rts
        
        ..animationlist_vert: {
            db $c0, $c1, $c2, $c3, $c4, $c5, $c6, $c7, $c8
        }
        
        ..animationlist_horz: {
            db $d0, $d1, $d2, $d3, $d4, $d5, $d6, $d7, $d8
        }
    }
    
;========================================== INVERTPALETTE ==================================
;invert every color of sprite palette 7 (in the color buffer)
;
    
    .invertpalette: {
        lda w_nmicounter
        bit #$0003
        bne +
        
        ldx #$0020
        
        -
        lda.l w_cgrambuffer+$1e0,x
        eor #$7fff
        sta.l w_cgrambuffer+$1e0,x
        dex
        dex
        bpl -
        
        +
        rts
    }
    
    
;======================================== PLAYER_DRAW ======================================
;no offscreen handling
;does have oam high table handling
    
    .draw: {
        ;used in routine:
        ;p_0 = counter for number of sprites to draw
        ;p_2 = used to halve x radius for drawing offset
        ;p_4 = used to halve y radius for drawing offset
        
        ;print hex(w_player_x)
        
        phb
        phx
        phy
        
        phk
        plb
        
        lda w_player_iframes        ;if iframes = 0, continue
        beq +                       ;if iframes > 0
        lda w_nmicounter            ;and nmicounter %1,
        bit #$0001                  ;skip drawing
        beq ..noskip
        jmp ..skip
        ..noskip
        
        +
        
        ;lda w_player_xsize
        ;lsr
        ;sta p_2
        
        ;lda w_player_ysize
        ;lsr
        ;sta p_4
        
        ldx w_oam_index
        
        lda w_nmicounter
        bit #$0007
        bne +
        
        lda w_player_animationtimer             ;timer cycling 0-8
        inc
        sta w_player_animationtimer
        cmp #$0008
        bmi +
        stz w_player_animationtimer
        lda #$0000
        +
        lda w_player_animationtimer             ;y = index for spritemap lists
        asl
        tay
        
        lda w_player_direction
        bit #!controller_lf|!controller_rt
        bne ..h
        lda player_spritemaplist_vertical,y
        bra ..v
        ..h
        lda player_spritemaplist_horizontal,y
        ..v
        
        tay                                     ;y = ptr to spritemap
        
        lda $0000,y
        and #$00ff
        sta p_0                                 ;number of sprites to draw
        iny                                     ;y = pointer to first spritemap
        
        ..nextsprite
        
        lda $0000,y
        and #$00ff
        clc
        adc w_player_x_onscreen
        ;sec
        ;sbc p_2
        sta w_oam_lo_buffer,x       ;x pos
        
        lda $0001,y
        and #$00ff
        clc
        adc w_player_y_onscreen
        ;sec
        ;sbc p_4
        sta w_oam_lo_buffer+1,x     ;y pos
        
        lda $0002,y
        and #$00ff
        sta w_oam_lo_buffer+2,x     ;tile
        
        lda $0003,y                 ;properties
        and #$00ff
        sta w_oam_lo_buffer+3,x
        
        iny                         ;y=y+5 (next spritemap)
        iny
        iny
        iny
        iny
        
        inx                         ;x=x+4 (next oam entry)
        inx
        inx
        inx
        dec p_0
        bne ..nextsprite
        
        stx w_oam_index
        
        ..skip
        
        rep #$20
        
        ply
        plx
        plb
        rts
    }
    
    .spritemaplist: {
        ..vertical
            dw player_spritemap_0
            dw player_spritemap_1
            dw player_spritemap_2
            dw player_spritemap_3
            dw player_spritemap_4
            dw player_spritemap_5
            dw player_spritemap_6
            dw player_spritemap_7
            dw player_spritemap_8
        ..horizontal
            dw player_spritemap_9
            dw player_spritemap_10
            dw player_spritemap_11
            dw player_spritemap_12
            dw player_spritemap_13
            dw player_spritemap_14
            dw player_spritemap_15
            dw player_spritemap_16
            dw player_spritemap_17
    }
    
    
    .spritemap: {
        ;the player spritemaps ;p
        
        ; xx yy tt pp hh
        ; ^  ^  ^  ^  ^
        ; x  ^  ^  ^  high table bits
        ;    y  ^  properties
        ;       tile
        ;
        
        ..circle: {
            db 04
            ;   xx     yy     tt   vhppccct   hh
            db $00-4, $00-4, $c9, %00110000, $00
            db $00-4, $08-4, $c9, %10110000, $00
            db $08-4, $00-4, $c9, %01110000, $00
            db $08-4, $08-4, $c9, %11110000, $00
        }
        
        ;vertical ====================================================================================
        ..0: {
            ;number of sprites
            db $01
             ;  xx   yy   tt   pp         hh
            db $00, $00, $c0, %00111000, $00
            
        }
        
        ..1: {
            ;number of sprites
            db $01
             ;  xx   yy   tt   pp         hh
            db $00, $00, $c1, %00111000, $00
        }
        
        ..2: {
            ;number of sprites
            db $01
             ;  xx   yy   tt   pp         hh
            db $00, $00, $c2, %00111000, $00
        }
        
        ..3: {
            ;number of sprites
            db $01
             ;  xx   yy   tt   pp         hh
            db $00, $00, $c3, %00111000, $00
        }
        
        ..4: {
            ;number of sprites
            db $01
             ;  xx   yy   tt   pp         hh
            db $00, $00, $c4, %00111000, $00
        }
        
        ..5: {
            ;number of sprites
            db $01
             ;  xx   yy   tt   pp         hh
            db $00, $00, $c5, %00111000, $00
        }
        
        ..6: {
            ;number of sprites
            db $01
             ;  xx   yy   tt   pp         hh
            db $00, $00, $c6, %00111000, $00
        }
        
        ..7: {
            ;number of sprites
            db $01
             ;  xx   yy   tt   pp         hh
            db $00, $00, $c7, %00111000, $00
        }
        
        ..8: {
            ;number of sprites
            db $01
             ;  xx   yy   tt   pp         hh
            db $00, $00, $c8, %00111000, $00
        }
        
        ;horizontal ====================================================================================
        
        ..9: {
            ;number of sprites
            db $01
             ;  xx   yy   tt   pp         hh
            db $00, $00, $d0, %00111000, $00
        }
        
        ..10: {
            ;number of sprites
            db $01
             ;  xx   yy   tt   pp         hh
            db $00, $00, $d1, %00111000, $00
        }
        
        ..11: {
            ;number of sprites
            db $01
             ;  xx   yy   tt   pp         hh
            db $00, $00, $d2, %00111000, $00
        }
        
        ..12: {
            ;number of sprites
            db $01
             ;  xx   yy   tt   pp         hh
            db $00, $00, $d3, %00111000, $00
        }
        
        ..13: {
            ;number of sprites
            db $01
             ;  xx   yy   tt   pp         hh
            db $00, $00, $d4, %00111000, $00
        }
        
        ..14: {
            ;number of sprites
            db $01
             ;  xx   yy   tt   pp         hh
            db $00, $00, $d5, %00111000, $00
        }
        
        ..15: {
            ;number of sprites
            db $01
             ;  xx   yy   tt   pp         hh
            db $00, $00, $d6, %00111000, $00
        }
        
        ..16: {
            ;number of sprites
            db $01
             ;  xx   yy   tt   pp         hh
            db $00, $00, $d7, %00111000, $00
        }
        
        ..17: {
            ;number of sprites
            db $01
             ;  xx   yy   tt   pp         hh
            db $00, $00, $d8, %00111000, $00
        }
        
    }
}
