;===========================================================================================
;==================================  COLOR CYCLING =========================================
;======================================= GLOWS =============================================
;===========================================================================================
;===========================================================================================

;spawning an object:
    ;ldy #glow_incrementing
    ;jsl glow_spawn
    
    ;or
    
    ;ldy #glow_incrementing
    ;ldx #$0004
    ;jsl glow_spawn_knownslot

    ;or
    
    ;add an entry to a scene's glowlist and it will be spawned during scene loading
    ;currently only implemented for nongameplay/intro scenes

glow: {
    .top: {
        ;top level handler for color cycling
        phb
        
        phk
        plb
        
        lda w_glow_enable
        beq +
        
        jsr glow_runroutines
        jsr glow_handleall
        
        +
        plb
        rtl
    }
    
    
    .handleall: {
        ldx.w #!glow_objects_count*2
        
        {                               ;for x = number of slots
            ..loop
            
            lda w_glow_id,x
            beq +
            
            
            lda w_glow_timer,x
            dec
            sta w_glow_timer,x
            bpl +
            
            ;if timer is up:
            -
            lda w_glow_list,x
            tay
            
            lda $0000,y
            bpl ++
            
            jsr glow_execinstruction    ;if negative, it's an instruction pointer
            bra +
            
            ++
            jsr glow_writecolors        ;if positive, it's a color
            bra -
            
            
            +
            
            dex
            dex
            bpl ..loop                       ;next x
        }
        
        rts
    }
    
    
    .execinstruction: {
        ;x = glow object index
        ;y = instruction list pointer
        ;a = pointer to instruction to run
        
        sta p_3
        jmp (p_3)
    }
    
    
    .inst: {
        ..done: {
            ;x = glow object index
            ;y = instruction list ptr
            
            lda w_glow_timerstart,x
            sta w_glow_timer,x
            
            lda w_glow_list,x
            inc
            inc
            sta w_glow_list,x
            
            lda w_glow_colorindexstart,x
            sta w_glow_colorindex,x
            
            rts
        }
        
        ..loop: {
            ;x = glow object index
            
            lda w_glow_liststart,x
            sta w_glow_list,x
            
            lda w_glow_colorindexstart,x
            sta w_glow_colorindex,x
            
            lda w_glow_timerstart,x
            sta w_glow_timer,x
            
            rts
        }
        
        
        ..settimer: {
            ;x = glow object index
            ;y = instruction list ptr
            
            lda $0002,y
            sta w_glow_timer,x
            sta w_glow_timerstart,x
            
            lda w_glow_list,x
            clc
            adc #$0004
            sta w_glow_list,x
            
            rts
        }
    }
    
    
    
    .writecolors: {
        ;x   = glow object index
        ;y   = instruction list ptr
        ;a   = color
        phy
        
        ldy w_glow_colorindex,x
        
        phx
        tyx
        sta.l w_cgrambuffer,x
        plx
        
        lda w_glow_list,x
        inc
        inc
        sta w_glow_list,x
        
        lda w_glow_colorindex,x
        inc
        inc
        sta w_glow_colorindex,x
        
        ply
        rts
    }
    
    
    .spawnfromlist: {
        phb
        
        phk
        plb
        
        ldx w_scene_glowlistptr
        beq ..return
        
        lda #!glow_objects_count*2
        sta p_8
        {
            ..loop:
            
            lda.l (bank(scenedef)<<16)+0,x
            cmp #$ffff
            beq ..returnandenable
            
            tay                     ;y = glow object id
            
            phx
            ldx p_8                 ;x = glow object index
            jsl glow_spawn_knownslot
            plx
            
            inx
            inx
            
            dec p_8
            dec p_8
            bpl ..loop
        }
        
        ..returnandenable:
        lda #$0001
        sta w_glow_enable
        
        ..return
        plb
        rtl
    }
    
    
    .spawn: {
        ;y = object id
        ;returns:
        ;x = object index
        ;object spawned, init routine run if spawned
        ;x = $fffe if no slot found
        phb
        
        phk
        plb
        
        ldx #!glow_objects_count*2
        
        -
        lda w_glow_id,x
        beq ..foundslot
        dex
        dex
        bpl -
        
        plb
        rtl
        
        ..foundslot:
        
        tya
        sta w_glow_id,x
        
        lda $0000,y
        sta w_glow_init,x
        
        lda $0002,y
        sta w_glow_routine,x
        
        lda $0004,y
        sta w_glow_list,x
        
        lda w_glow_list,x
        tay
        
        lda $0000,y                 ;timer
        sta w_glow_timer,x
        sta w_glow_timerstart,x
        
        lda $0002,y                 ;starting color index
        sta w_glow_colorindex,x
        sta w_glow_colorindexstart,x
        
        lda w_glow_list,x           ;advance list to first entry
        clc
        adc #$0004
        sta w_glow_list,x
        sta w_glow_liststart,x      ;back this up to easily loop back on loop command
        
        lda w_glow_init,x
        beq +
        jsr (w_glow_init,x)
        +
        
        plb
        rtl
        
        ..knownslot: {
            ;x is a known value from glow_spawnfromlist
            ;and so exludes the for loop in glow_spawn
            
            phb
            
            phk
            plb
            
            bra glow_spawn_foundslot
        }
    }
    
    
    .clearall: {
        phb
        
        phk
        plb
        
        ldx.w #!glow_objects_count*2
        
        -
        jsr glow_clear
        dex
        dex
        bpl -
        
        plb
        rtl
    }
    
    
    .clear: {
        ;x = object index
        
        stz w_glow_id,x
        stz w_glow_init,x
        stz w_glow_routine,x
        stz w_glow_timer,x
        stz w_glow_colorindex,x
        stz w_glow_list,x
        stz w_glow_liststart,x
        stz w_glow_colorindexstart,x
        
        rts
    }
    
    
    .runroutines: {
        ldx.w #!glow_objects_count*2
        
        -
        lda w_glow_routine,x
        beq +
        jsr (w_glow_routine,x)
        +
        dex
        dex
        bpl -
        
        rts
    }
}