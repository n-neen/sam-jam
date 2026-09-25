;used to be at the end of main.asm until it became too large


;===========================================================================================
;========================= B E G I N   S C E N E   T R A N S I T I O N =====================
;===========================================================================================
;populate scene area of memory
;typically call this then immediately call load_scene

;there are three types of scenes:
;
;=gameplay scenes, also called rooms
;
;=two types of dialog/text scenes:
; -intro scenes
; -nongameplay scenes, which are called from gameplay rooms and return to gameplay rooms
    ;such as through the dialogtrigger object
    

scenetransition: {
    ;arguments:
    ;x = scene pointer to scene header in scenedef bank
    
    phk
    plb
    
    stx w_scene_ptr                         ;save this first
    
    phb
    
    pea.w bank(scenedef)<<8                 ;db = scene def bank
    plb
    plb
    
    lda $0000,x
    sta.l w_scene_definitionptr
    
    lda $0002,x
    and #$00ff
    sta.l w_scene_bank
    
    lda $0003,x
    sta.l w_scene_palptr
    
    lda $0005,x
    sta.l w_scene_gfxptr
    
    lda $0007,x
    sta.l w_scene_mapptr
    
    lda $0009,x
    sta.l w_scene_gfxsize
    
    lda $000b,x
    sta.l w_scene_tilemapsize
    
    lda $000f,x
    sta.l w_scene_hdmalistptr
    
    lda $0011,x
    sta.l w_scene_glowlistptr
    
    lda $0013,x
    sta.l w_scene_bg2dataptr
    
    lda $0015,x
    and #$00ff
    sta.l w_scene_layerblend
    
    lda $000d,x
    sta.l w_scene_gameprops     ;keep this last regardless of what new things get added
                                ;to scenedef. because this is a pointer to all folowing data
    
    tax     ;x = pointer to gameplay properties, if it's a gameplay room
            ;otherwise, it's a dialogue scene properties list
    
    ;scene dialogue/gameplay properties
    
    lda $0000,x
    sta.l w_scene_mode
    
    cmp #!state_overworld
    beq .overworld
    
    cmp #!state_loadgame        ;if not gameplay, go to nongameplay
    bne .notgameplay
    
    .overworld:
    .gameplay:                  ;else, gameplay
    
    lda $0002,x
    sta.l w_level_camerastartx
    
    lda $0004,x
    sta.l w_level_camerastarty
    
    lda $0006,x
    sta.l w_level_playerstartx
    
    lda $0008,x
    sta.l w_level_playerstarty
    
    lda $000a,x
    sta.l w_level_objlist_ptr
    
    lda $000c,x
    sta.l w_level_collisionmap_ptr
    
    lda $000e,x
    sta.l w_level_faelist_ptr
    
    lda $0010,x
    sta.l w_level_hudstring_ptr
    
    plb
    rts
    
    .notgameplay:
    
    lda $0002,x
    sta.l w_scene_strptr        ;eventually, script (list of text pointers)
    
    lda $0004,x
    and #$00ff
    sta.l w_scene_strline       ;what line to start text on
    
    lda $0005,x
    sta.l w_scene_init
    
    lda $0007,x
    sta.l w_scene_scrolltextptr ;ptr to scroll commands in strings.asm
    
    plb
    rts
    
    .long: {
        jsr scenetransition
        rtl
    }
}



;===========================================================================================
;===================================== LOCATEONTILE ========================================
;===========================================================================================
;(player_y/8)*level_width+(player_x/8)

;this returns a tile index into l_level_collision
;if you wanted, could get tile x,y by saving these right-shifted values below
;
;this uses the next suggested position in advance of where the player is
;could make this take argument otherwhere and use it for both current tile
;and future (next suggested position) tile

locateontile: {
    ;w_player_hitbox variables at this point are calculated for
    ;w_player_nextx/nexty
    
    ;x = pointer to variable for horizontal
    ;y = pointer to variable for vertical
    ;a = pointer to destination
    ;sei
    
    stx p_2
    sty p_4
    sta p_6
    
    lda (p_2)
    lsr
    lsr
    lsr
    sta p_0             ;player next suggested x pixel position/8 = player x tile position
    
    lda (p_4)
    lsr
    lsr
    lsr                 ;player next suggested y pixel position/8
    
    sep #$20
    
    sta $4202
    
    lda.b #!level_width ;player y*level width
    sta $4203
    
    rep #$20
    nop
    
    lda $4216
    
    clc
    adc p_0             ;+ player x
    
    ;sta w_player_tileindex
    sta (p_6)
    
    ;cli
    rtl
}




;===========================================================================================
;==================== routines for turning layers on and off ===============================
;===========================================================================================

spritesoff: {
    sep #$20
    
    lda w_mainscreenlayers
    and #%11101111
    sta w_mainscreenlayers
    
    rep #$20
    rts
}


layer3on: {
    sep #$20
    lda w_mainscreenlayers
    ora #%00000100
    sta w_mainscreenlayers
    rep #$20
    
    rts
    
    .long: {
        jsr layer3on
        rtl
    }
}


layer3off: {
    sep #$20
    lda w_mainscreenlayers
    and #%11111011
    sta w_mainscreenlayers
    rep #$20
    
    rts
    
    .long: {
        jsr layer3off
        rtl
    }
}

;===========================================================================================
;              common calls for loading gameplay, nongameplay, and intro scenes
;===========================================================================================

initspecialfx: {
    ;initialize special effects for new scene
    
    lda w_scene_layerblend
    sta w_layerblendmode
    
    lda w_scene_bg2dataptr
    beq +
    jsl load_bg2fromscenedata
    jsl scroll_bg2              ;set initial bg2 scroll
    +
    
    .forresumedgame:
    
    jsl glow_clearall
    jsl glow_spawnfromlist
    
    jsl hdma_clearall
    jsl hdma_clearchannels
    jsl hdma_spawnfromlist
    
    rts
}

;===========================================================================================
;============================= fade in and out routines ====================================
;===========================================================================================


fadeout: {
    ;screen must be ON when this is called
    jsr enablenmi
    jsr screenon        ;in fact just do this to be sure
    
    -
    
    jsr handlevfxduringfade
    
    jsr waitfornmi
    
    lda w_nmicounter
    bit w_fadebitmask
    bne -
    
    lda w_screenbrightness
    dec
    sta w_screenbrightness
    bne -
    
    jsr screenoff
    rts
    
    .long: {
        jsr fadeout
        rtl
    }
}


fadein: {
    jsr enablenmi
    stz w_screenbrightness
    
    -
    
    jsr handlevfxduringfade
    
    jsr waitfornmi
    
    lda w_nmicounter
    bit w_fadebitmask
    bne -
    
    lda w_screenbrightness
    inc
    sta w_screenbrightness
    cmp #$000f
    bne -
    
    ;returns with screen brightness = $0f
    jsr screenon
    rts
    
    .long: {
        jsr fadein
        rtl
    }
}

handlevfxduringfade: {
    ;handle visual effects during fade in or out
    lda w_hdma_enable
    beq +
    jsl hdma_top
    +
    
    lda w_glow_enable
    beq +
    jsl glow_top
    +
    
    jsr layerblending
    
    rts
}

checksram: {
    phb
    phx
    
    pea bank(s)<<8
    plb
    plb
    
    ldx #datasize(checksram_string)-2
    -
    lda s_string,x
    cmp.l checksram_string,x
    bne .init
    dex
    dex
    bpl -
    
    plx
    plb
    rtl
    
    .init:
    
    ldx #!sram_size                     ;clear, then
    -
    stz s,x
    dex
    dex
    bpl -
    
    ldx #datasize(checksram_string)-2   ;write string
    -
    lda.l checksram_string,x
    sta s_string,x
    dex
    dex
    bpl -
    
    plx
    plb
    rtl
    
    .string: {
        db "robot past"     ;length = $0a
    }
    .dummylabel
}