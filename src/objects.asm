;===========================================================================================
;===================================                   =====================================
;===================================   O B J E C T S   =====================================
;===================================                   =====================================
;===========================================================================================

;this is the file for routines of the object system
;at the bottom of this file is incsrc /obj_def.asm
;that file is for writing individual objects in this system
;
;
;w_obj_var1: tile for drawing
;w_obj_var2
;w_obj_var3: used to hold pointers for door and text trigger objects
;


obj: {
    .readcollision: {
        ;x = obj index
        
        phb
        phx
        phy
        php
        
        phk
        plb
        
        stx w_obj_index
        
        lda w_obj_collisionmap,x
        tay
        
        sep #$20
        {
            lda $0000,y
            beq .end
            sta p_8
            iny
            
            .nexttile:
            
            lda $0000,y         ;tile x pos
            sta p_0
            
            lda $0001,y         ;tile y post
            sta p_2
            
            lda $0002,y         ;tile collision value
            sta p_4
            
            jsr obj_writecollision
            
            iny
            iny
            iny
            
            dec p_8
            bne .nexttile
        }
        rep #$20
        
        .end:
        plp
        ply
        plx
        plb
        rts
    }
    
    
    .writecollision: {
        ;x = object index
        
        ;(obj_y * level_width) + obj_x
        
        ;p_0 = tile x position
        ;p_2 = tile y position
        ;p_4 = tile collision value to write
        ;
        
        phx
        phy
        php
        
        sep #$20
        
        lda w_obj_y,x
        clc
        adc p_2             ;add y offset
        
        sta $4202
        
        lda.b #!level_width
        sta $4203
        
        rep #$20
        nop
        
        lda $4216
        
        clc
        adc w_obj_x,x
        clc
        sep #$20
        adc p_0             ;add x offset
        rep #$20
        
        sta w_obj_tileindex
        
        tax
        
        sep #$20
        lda p_4
        sta.l l_level_collision,x
        rep #$20
        
        plp
        ply
        plx
        rts
    }
    
    
    .drawall: {
        phb
        
        phk
        plb
        
        ldx #!obj_count*2
        -
        
        lda w_obj_id,x          ;if slot empty, exit
        beq +
        
        lda w_obj_draw,x        ;if null tile, exit (do not draw)
        beq +
        
        jsr obj_draw
        jsr obj_readcollision
        
        +
        dex
        dex
        bpl -
        
        
        plb
        rtl
    }
    
    
    .draw: {
        lda w_obj_draw,x
        
        tay                 ;y = draw instruction pointer
        lda $0000,y
        and #$00ff
        beq ..return
        sta p_6             ;number of tiles to draw
        
        iny                 ;y = pointed at first tile
        
        -
        sep #$20
        {
            stz p_1         ;these bytes can be dirty from other usages of p_0/p_2 in 16 bit A
            stz p_3         ;just clean them up here ok
            
            lda $0000,y     ;signed byte (x pos) of tile relative to object tile
            clc
            adc w_obj_x,x
            sta p_0         ;x tile to write to
            
            lda $0001,y
            clc
            adc w_obj_y,x
            sta p_2         ;y tile to write to
        }
        rep #$20
        
        lda $0002,y
        sta w_obj_tile,x
        
        jsr obj_plot
        
        iny
        iny
        iny
        iny
        
        dec p_6
        bne -
        
        ..return
        rts
    }
    
    
    
    .plot: {
        ;x = object index
        
        ;single tile test
        ;(y-1) * 32 + x = tilemap index
        ;can then know based on range which screen it is in
        
        ;p_0    used for x coordinate
        ;p_2    used for y coordinate
        ;p_4    used for adding screen offsets
        
        phy
        phx
        
        stx w_obj_index
        stz w_obj_drawindex
        
        ;lda w_obj_x,x       ;x
        ;lda w_player_x
        ;lsr
        ;lsr
        ;lsr
        ;sta p_0
        
        ;lda w_obj_y,x       ;y
        ;lda w_player_y
        ;lsr
        ;lsr
        ;lsr
        ;sta p_2
        
        lda p_0                 ;if x > $20, we're on right half of screen
        cmp #$0020
        bpl ..righthalf
        
        ..lefthalf:             ;else, we're on left half
        lda p_2
        cmp #$0020
        bpl +
        
        ldx #!obj_flag_update_screen0   ;if y < $20, we're in screen 0
        lda #$0000
        jsr obj_screen
        bra ..write
        +
        
        ldx #!obj_flag_update_screen2   ;if y > $20, we're in screen 2
        lda #$1000
        jsr obj_screen
        bra ..write
        ++
        
        ..righthalf:                    ;we're on right half
        lda p_2
        cmp #$0020
        bmi +
        
        ldx #!obj_flag_update_screen3
        lda #$1800
        jsr obj_screen          ;if y > $20, (and on right half), we're in screen 3
        bra ..write
        +
        
        ldx #!obj_flag_update_screen1
        lda #$0800
        jsr obj_screen          ;else, screen 1
        ++
        
        ..write
        tax
        ldy w_obj_index
        lda w_obj_tile,y        ;tile to draw
        sta.l l_level,x
        
        ..return:
        plx
        ply
        rts
    }
    
    
    .screen: {
        sta p_4                     ;a = screen offset
        
        txa
        ora w_obj_screenupdates
        sta w_obj_screenupdates     ;add screen to screen update list
        
        lda p_0
        and #$001f
        sta p_0
        ;screen relative position
        
        lda p_2
        and #$001f
        sta p_2
        ;screen relative position
        
        sep #$20
        
        lda p_2
        sta $4202
        
        lda #$20
        sta $4203
        
        rep #$20
        nop
        
        lda $4216           ;result = y*32
        asl
        
        clc
        adc p_0
        adc p_0             ;y*32+x*2
        
        clc
        adc p_4             ;+ screen
        
        ;return with A = index
        rts
    }
    
    
    .collision: {
        ;check all objects for collision with player
        
        ;jsl player_calchitbox
        ;going to call this higher up in main gameplay now that fae need it too
        ;w_player_hitbox vars now populated for the below
        phx
        
        ldx #!obj_count*2   ;for each object that exists
        
        -
        
        lda w_obj_id,x
        beq +
        
        jsr obj_collision_check
        bcc +
        
        jsr (w_obj_touch,x)
        
        +
        dex
        dex
        bpl -
        
        plx
        rtl
        
        ..check: {
            ;x = object index
            
            ;we start out with tile coordinates and radii
            ;then convert to pixels for checking against player position
            
            lda w_obj_x,x           ;object x - obj x size = left bound
            sec
            sbc w_obj_xsize,x
            asl #3                  ;*3 for tile -> pixel
            sta p_4
            
            lda w_obj_x,x           ;object x + obj x size = right bound
            clc
            adc w_obj_xsize,x
            asl #3                  ;*3 for tile -> pixel
            sta p_6
            
            lda w_obj_y,x           ;object y + obj y size = bottom bound
            clc
            adc w_obj_ysize,x
            asl #3                  ;*3 for tile -> pixel
            sta p_8
            
            lda w_obj_y,x           ;object y - obj y size = top bound
            sec
            sbc w_obj_ysize,x
            asl #3                  ;*3 for tile -> pixel
            sta p_a
            
            ;for current object, calculated right before this:
            ;p_4    =   left bound
            ;p_6    =   right bound
            ;p_8    =   bottom bound
            ;p_a    =   top bound
            
            lda w_player_hitboxleft
            cmp p_4
            bmi +
            
            lda w_player_hitboxright
            cmp p_6
            bpl +
            
            lda w_player_hitboxbottom
            cmp p_8
            bpl +
            
            lda w_player_hitboxtop
            cmp p_a
            bmi +
            
            sec     ;no collision
            rts
            
            +
            clc     ;collision
            rts
        }
    }
    
    
    
    .spawnall: {
        phb
        
        pea.w (objlist>>8)+0            ;db = object list bank
        plb                             ;so all ram access needs to be long
        plb
        
        
        ldx #!obj_count*2               ;for x = 2*obj slots
        {
            -
            lda.l w_level_objlist_ptr
            clc
            adc.l w_level_objlistindex  ;objlist + index = what we are currently looking at
            tay
            
            jsr obj_spawn               ;spawn object pointed at by the result of the above
            bcs ..done
            
            ..nextslot:
            lda.l w_level_objlistindex  ;advance to next object entry
            clc
            adc #(!obj_list_entry_length)
            sta.l w_level_objlistindex
            
            dex                         ;next object slot
            dex
            bpl -
        }
        
        ..done:                         ;reached terminator
        
        ;routine will return with x = $fffe if we ran out of slots (probably)
        
        plb
        rtl
    }
    
    
    .dynamicspawn: {
        ;p_0 = x position
        ;p_2 = y position
        ;a = object type
        phk
        plb
        
        pha
        
        ldx #!obj_count*2               ;find empty slot
        {
            -
            lda w_obj_id,x
            bne +
            
            ;slot found
            bra ..slotfound
            
            +
            dex
            dex
            bpl -
        }
        
        ..noslot:                       ;returns x = fffe if no slot
        pla
        rtl
        
        
        ..slotfound:
        pla
        
        sta w_obj_id,x
        
        tay
        
        lda $0000,y
        and #$00ff
        sta.l w_obj_xsize,x
        
        lda $0001,y
        and #$00ff
        sta.l w_obj_ysize,x
        
        lda $0002,y
        sta.l w_obj_init,x
        
        lda $0004,y
        sta.l w_obj_main,x
        
        lda $0006,y
        sta.l w_obj_touch,x
        
        lda $0008,y
        sta.l w_obj_draw,x
        
        lda $000a,y
        sta.l w_obj_collisionmap,x
        
        lda p_0
        sta.l w_obj_x,x
        
        lda p_2
        sta.l w_obj_y,x
        
        jsr obj_draw                    ;draw object
        jsr (w_obj_init,x)              ;run init routine
        
        rtl
    }
    
    .spawn: {
        ;spawn an object, w_level_objlistindex into the current room's object list
        
        ;x = object index
        ;y = object list pointer + object list index (pointer to object list entry)
        
        lda $0000,y         ;this section is related to this instance of the object
        cmp #$ffff
        beq ..done
        sta.l w_obj_id,x
        
        lda $0002,y
        and #$00ff
        sta.l w_obj_x,x
        
        lda $0003,y
        and #$00ff
        sta.l w_obj_y,x
        
        lda $0004,y
        sta.l w_obj_var1,x
        
        lda $0006,y
        sta.l w_obj_var2,x
        
        lda $0008,y
        sta.l w_obj_var3,x
        
        lda.l w_obj_id,x    ;this section is from the object definition
        tay
        
        lda $0000,y
        and #$00ff
        sta.l w_obj_xsize,x
        
        lda $0001,y
        and #$00ff
        sta.l w_obj_ysize,x
        
        lda $0002,y
        sta.l w_obj_init,x
        
        lda $0004,y
        sta.l w_obj_main,x
        
        lda $0006,y
        sta.l w_obj_touch,x
        
        lda $0008,y
        sta.l w_obj_draw,x
        
        lda $000a,y
        sta.l w_obj_collisionmap,x
        
        clc
        rts
        
        ..done:
        sec
        rts
        
        ..long: {
            phb
            
            pea.w (objlist>>8)+0            ;db = object list bank
            plb                             ;so all ram access needs to be long
            plb
            
            jsr obj_spawn
            
            plb
            rtl
        }
    }
    
    .clearall: {
        phk
        plb
        
        stz w_level_objlistindex
        
        ldx #!obj_count*2
        
        -
        jsr obj_clear
        dex
        dex
        
        bpl -
        
        rtl
    }
    
    .clear: {
        ;x = object index
        
        stz w_obj_id,x
        stz w_obj_xsize,x
        stz w_obj_ysize,x
        stz w_obj_init,x
        stz w_obj_main,x
        
        stz w_obj_x,x
        stz w_obj_y,x
        stz w_obj_var1,x
        stz w_obj_var2,x
        stz w_obj_var3,x
        
        rts
    }
    
    .runinit: {
        ;runs all init routines for objects that exist
        
        ;this runs with forced blank enabled, in loadgame state,
        ;right after all objects are spawned
        
        phb
        
        phk
        plb
        
        ldx #!obj_count*2
        
        -
        lda w_obj_id,x
        beq +
        
        jsr (w_obj_init,x)
        
        +
        dex
        dex
        bpl -
        
        plb
        rtl
    }
    
    .runmain: {
        ;runs all main routines for objects that exist
        
        ;runs during main gameplay
        
        phb
        
        phk
        plb
        
        ldx #!obj_count*2
        
        -
        lda w_obj_id,x
        beq +
        
        jsr (w_obj_main,x)
        
        +
        dex
        dex
        bpl -
        
        plb
        rtl
    }
    
    
    ;object definitions
    incsrc "./src/obj_def.asm"
}