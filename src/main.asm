;===========================================================================================
;====================================  M A I N  ============================================
;===========================================================================================
;
;this file contains main, and all top-level states, except those which only have a vector
;here, like main gameplay, which is in its own file. also contains some important
;system routines like fadein, fadeout
;
;there are some assumptions made that main.asm and interrupts.asm will be in the same bank!

main: {
    phk
    plb
    
    lda w_glow_enable
    beq .noglow
    jsl glow_top
    .noglow:
    
    lda w_hdma_enable
    beq .nohdma
    jsl hdma_top
    .nohdma:
    
    jsr layerblending
    
    lda w_programstate
    asl
    tax
    
    jsr (main_table,x)
    
    jsr waitfornmi
    
    jmp main
    
    .table: {
        ;don't forget to make a corresponding define in defines.asm
        ;!state_[name]
        
        dw  setupintro,                 ;0      ;prepare intro text scene
            introhandler,               ;1      ;loads dialog scenes in order when button pressed
            loadintroscene,             ;2      ;load the individual scenes for above
            gameplayvector,             ;3      ;playing the game, top level routine in gameplay.asm
            loadgame,                   ;4      ;set up gameplay initially, and also for room transitions
            loadnongameplayscene,       ;5      ;load dialog scenes that come from gameplay and return to gameplay
            nongameplayhandler,         ;6      ;handle running the above after loading
            setupgameoverscreen,        ;7      ;do game over graphics and tilemap transfurs
            handlegameoverscreen,       ;8      ;display game over and handle interactions
            setuptitle,                 ;9      ;first state that is called. does not use loadscene structures
            handletitlescreen,          ;10     ;handle title menu interactions
            setupoptionsmenu,           ;11     ;load tilemap and bg3 graphics
            handleoptionsmenu,          ;12     ;not really written yet
            setupoverworldvector,       ;13     ;
            handleoverworldvector       ;14     ;
    }
}

setupoverworldvector: {
    jsl overworld_setup
    
    rts
}


handleoverworldvector: {
    jsl overworld_main
    
    rts
}


;===========================================================================================
;=============================== LAYER BLENDING HANDLER ====================================
;===========================================================================================

layerblending: {
    lda w_layerblendmode
    asl
    tax
    
    sep #$20
    jsr (layerblending_list,x)
    rep #$20
    
    rts
    
    .list: {
        dw  .default,           ;0
            .weird,             ;1
            .titlescreen,       ;2
            .intro,             ;3
            .gameover,          ;4
            .scene_pieces,      ;5
            .scene_agony,       ;6
            .default_withbg2m,  ;7
            .default_nosprites, ;8
            .scene_triangle,    ;9
            .scene_blue         ;10
    }
    
    .default_withbg2m: {
        ;default screen configuration, used in main gameplay
        ;also with bg2 in main screen
        
        lda #%00000000
        sta w_colormathlogic
        ;sta $2130
        
        lda #%10100011      ;color math layers
        sta w_colormathlayers
        ;sta $2131
        
        lda #%00010111      ;main screen layers
        sta w_mainscreenlayers
        ;sta $212c
        
        lda #%00000000      ;subscreen layers
        sta w_subscreenlayers
        ;sta $212d
        rts
    }
    
    .default: {
        ;default screen configuration, used in main gameplay
        
        lda #%00000000
        sta w_colormathlogic
        ;sta $2130
        
        lda #%10100001      ;color math layers
        sta w_colormathlayers
        ;sta $2131
        
        lda #%00010101      ;main screen layers
        sta w_mainscreenlayers
        ;sta $212c
        
        lda #%00000000      ;subscreen layers
        sta w_subscreenlayers
        ;sta $212d
        
        rts
    }
    
    .default_nosprites: {
        ;default screen configuration, used in main gameplay
        
        lda #%00000000
        sta w_colormathlogic
        ;sta $2130
        
        lda #%10100001      ;color math layers
        sta w_colormathlayers
        ;sta $2131
        
        lda #%00000101      ;main screen layers
        sta w_mainscreenlayers
        ;sta $212c
        
        lda #%00000000      ;subscreen layers
        sta w_subscreenlayers
        ;sta $212d
        
        rts
    }
    
    .scene_agony: {
        lda #%00000010
        sta w_colormathlogic
        ;sta $2130
        
        lda #%00100011      ;color math layers
        sta w_colormathlayers
        ;sta $2131
        
        lda #%10000101      ;main screen layers
        sta w_mainscreenlayers
        ;sta $212c
        
        lda #%00000010      ;subscreen layers
        sta w_subscreenlayers
        ;sta $212d
        
        rts
    }
    
    .scene_pieces: {
        lda #%00000010
        sta w_colormathlogic
        ;sta $2130
        
        lda #%10100011      ;color math layers
        sta w_colormathlayers
        ;sta $2131
        
        lda #%00000101      ;main screen layers
        sta w_mainscreenlayers
        ;sta $212c
        
        lda #%00000010      ;subscreen layers
        sta w_subscreenlayers
        ;sta $212d
        
        rts
    }
    
    .scene_triangle: {
        lda #%00000010
        sta w_colormathlogic
        ;sta $2130
        
        lda #%11100001      ;color math layers
        sta w_colormathlayers
        ;sta $2131
        
        lda #%00000110      ;main screen layers
        sta w_mainscreenlayers
        ;sta $212c
        
        lda #%00000001      ;subscreen layers
        sta w_subscreenlayers
        ;sta $212d
        
        rts
    }
    
    .scene_blue: {
        lda #%00000010
        sta w_colormathlogic
        ;sta $2130
        
        lda #%00100011      ;color math layers
        sta w_colormathlayers
        ;sta $2131
        
        lda #%00000100      ;main screen layers
        sta w_mainscreenlayers
        ;sta $212c
        
        lda #%00000010      ;subscreen layers
        sta w_subscreenlayers
        ;sta $212d
        
        rts
    }
    
    .gameover: {
        ;lda.b #!bg1tileshifted|(!spritegfxshifted<<4)     ;sprites and bg2 use same graphics here
        ;sta $210b
        
        lda #%00000010
        sta w_colormathlogic
        ;sta $2130
        
        lda #%10000011      ;color math layers: 1, 2; subtractive mode
        sta w_colormathlayers
        ;sta $2131
        
        lda #%00010001      ;main screen layers: 1
        sta w_mainscreenlayers
        ;sta $212c
        
        lda #%00000000      ;subscreen layers: nothing
        sta w_subscreenlayers
        ;sta $212d
        
        rts
    }
    
    
    .weird: {
        ;
        rts
    }
    
    .intro: {
        lda #%00000010
        sta w_colormathlogic
        ;sta $2130
        
        lda #%00000000      ;color math layers
        sta w_colormathlayers
        ;sta $2131
        
        lda #%00000101      ;main screen layers
        sta w_mainscreenlayers
        ;sta $212c
        
        lda #%00000000      ;subscreen layers
        sta w_subscreenlayers
        ;sta $212d
        
        rts
    }
    
    .titlescreen: {
        lda #%00000010
        sta w_colormathlogic
        ;sta $2130
        
        lda #%10000110      ;color math layers: 1, 2, 3; additive mode
        sta w_colormathlayers
        ;sta $2131
        
        lda #%00010111      ;main screen layers
        sta w_mainscreenlayers
        ;sta $212c
        
        lda #%00000000      ;subscreen layers
        sta w_subscreenlayers
        ;sta $212d
        
        rts
    }
}




;===========================================================================================
;============================ STATE 9:    S E T U P T I T L E ==============================
;===========================================================================================

setuptitle: {
    sei
    jsr screenoff
    jsr disablenmi
    
    sep #$20
    {
        lda #%00001001
        sta $2105
    }
    rep #$20
    
    ;============================== load bg1 tilemap =============================
    ;tilemap to buffer
    lda #bank(title_bg1map)
    sta p_2
        
    lda #title_bg1map                   ;tilemap pointer
    sta p_0
        
    lda #datasize(title_bg1map)         ;tilemap size
    jsl load_romtolevelbuffer           ;copy tilemap to level buffer
        
    ;buffer to vram
    lda #datasize(title_bg1map)         ;tilemap size
    ldx #!bg1tilemap                    ;destination in vram
    jsl load_levelbuffertovram          ;dma tilemap to vram
    
    ;============================== load bg1 graphics ============================
    ;graphics to buffer
    lda #bank(title_bg1gfx)
    sta p_2
        
    lda #title_bg1gfx
    sta p_0
        
    lda #datasize(title_bg1gfx)
    jsl load_romtobuffer
    
    ;load title bg1 graphics to vram
    lda #datasize(title_bg1gfx)         ;gfx size
    ldx #!bg1tiles                      ;destination in vram
    jsl load_buffertovram               ;dma gfx to vram
    
    ;============================== load bg2 graphics ============================
    ;graphics to buffer
    lda #bank(title_bg2gfx)
    sta p_2
        
    lda #title_bg2gfx
    sta p_0
        
    lda #datasize(title_bg2gfx)
    jsl load_romtobuffer
    
    ;load title bg1 graphics to vram
    lda #datasize(title_bg2gfx)         ;gfx size
    ldx #!bg1tiles+$200                 ;destination in vram
    jsl load_buffertovram               ;dma gfx to vram
    
    ;============================== load bg2 tilemap =============================
    ;tilemap to buffer
    
    lda #bank(title_bg2map)
    sta p_2
        
    lda #title_bg2map                   ;tilemap pointer
    sta p_0
        
    lda #datasize(title_bg2map)         ;tilemap size
    jsl load_romtolevelbuffer           ;copy tilemap to level buffer
        
    ;buffer to vram
    lda #datasize(title_bg2map)         ;tilemap size
    ldx #!bg2tilemap                    ;destination in vram
    jsl load_levelbuffertovram          ;dma tilemap to vram
    
    ;============================== load bg3 graphics ============================
    ;gfx to buffer
    lda #bank(title_bg3gfx)
    sta p_2
        
    lda #title_bg3gfx
    sta p_0
        
    lda #datasize(title_bg3gfx)
    jsl load_romtobuffer

    ;buffer to vram
    lda #datasize(title_bg3gfx)         ;gfx size
    ldx #!bg3tiles                      ;destination in vram
    jsl load_buffertovram               ;dma gfx to vram
    
    ;============================== load bg3 tilemap =============================
    lda #bank(title_bg3map)
    sta p_2
        
    lda #title_bg3map                   ;tilemap pointer
    sta p_0
        
    lda #datasize(title_bg3map)         ;tilemap size
    jsl load_romtolevelbuffer           ;copy tilemap to level buffer

    ;load title bg3 tilemap to vram
    lda #datasize(title_bg3map)         ;tilemap size
    ldx #!bg3tilemap                    ;destination in vram
    jsl load_levelbuffertovram          ;dma tilemap to vram
    
    ;============================= load title palette ============================
    lda #bank(title_pal)
    ldx #title_pal
    jsl load_romtocolorbuffer
    
    ;load bg3palette
    ;inline because frudge it we'll do it live
    ldx #$0020
    -
    lda.l title_pal+$20,x
    sta w_cgrambuffer,x
    dex
    dex
    bpl -
    
    lda #$0000
    sta w_cgrambuffer+2
    lda #$7fff
    sta w_cgrambuffer+4     ;you are going to regret this
    lda #$03dd
    sta w_cgrambuffer
    
    ;=================== load title sprite graphics ==============================
    lda #bank(title_spritegfx)
    sta p_2
        
    lda #title_spritegfx
    sta p_0
        
    lda #datasize(title_spritegfx)
    jsl load_romtobuffer
        
    lda #datasize(title_spritegfx)      ;gfx size
    ldx #!spritegfx                     ;destination in vram
    jsl load_buffertovram               ;dma gfx to vram
    
    ;=================== load title sprite palettes ==============================
    
    ldx #$0100
    -
    lda.l title_spritepal,x
    sta.l w_cgrambuffer+$100,x
    dex
    dex
    bpl -
    
    
    ;initialize title menu state, draw sprites for fade-in
    ;spawn glow objects and run once
    
    stz w_oam_index
    stz w_menu_state
    jsl title_drawcursor_long
    jsl oam_cleanbuffer
    
    ;
    
    jsl glow_clearall
    
    lda #$0001
    sta w_glow_enable
    
    ldy #glow_title
    jsl glow_spawn
    
    ;
    
    jsl hdma_clearall
    jsl hdma_clearchannels
    
    ;ldy #hdma_sinewave_indirect
    ;ldx #$0002
    ;lda #!hdma_params_default
    ;;lda #$0e42
    ;jsl hdma_spawn
    
    ;ldy #hdma_sinewave_indirect
    ;ldx #$0004
    ;lda #$0d42
    ;jsl hdma_spawn
    
    lda #$0001
    sta w_hdma_enable
    
    jsl hdma_top
    
    ;
    
    ;init ppu for title screen
    lda #$00ff
    sta w_bg3yscroll
    
    ;lda #$0070
    ;sta w_bg2yscroll
    
    lda #!layer_blend_titlescreen
    sta w_layerblendmode
    
    lda.l s_roomptr         ;if saveram room ptr = 0, write default starting room
    bne +
    lda #!starting_room
    sta.l s_roomptr
    +
    
    jsr enablenmi
    jsr waitfornmi
    
    lda #!fade_bitmask_title
    sta w_fadebitmask
    
    lda #!fade_timer_title
    sta w_fadetimer
    
    jsr fadein
    
    lda #!state_handletitlescreen
    sta w_programstate
    
    rts
}


;===========================================================================================
;===================== STATE 10:    H A N D L E T I T L E S C R E E N ======================
;===========================================================================================

handletitlescreen: {
    ;jsl glow_top       ;happens in main now
    ;jsl hdma_top
    
    jsl title_main
    
    rts
}

;===========================================================================================
;======================= STATE 11:    S E T U P O P T I O N S M E N U ======================
;===========================================================================================

setupoptionsmenu: {
    ;fade, load bg3 tilemap, set up menu
    ;retain bg1/2 from title
    
    sei
    jsr irq_disable
    jsr waitfornmi
    jsr fadeout
    jsr disablenmi
    
    ;============================== load bg3 graphics ============================
    jsl load_bg3tilesupload
    
    ;============================== load bg3 tilemap =============================
    lda #bank(title_optionsbg3map)
    sta p_2
        
    lda #title_optionsbg3map                    ;tilemap pointer
    sta p_0
        
    lda #datasize(title_optionsbg3map)          ;tilemap size
    jsl load_romtolevelbuffer                   ;copy tilemap to level buffer

    ;load title bg3 tilemap to vram
    lda #datasize(title_optionsbg3map)          ;tilemap size
    ldx #!bg3tilemap                            ;destination in vram
    jsl load_levelbuffertovram                  ;dma tilemap to vram
    
    ;
    
    stz w_menu_state
    stz w_menu_var1
    stz w_menu_var2
    stz w_menu_var3
    
    stz w_oam_index
    jsl oam_cleanbuffer
    jsl oam_constructhibuffer
    
    jsr enablenmi
    jsr waitfornmi
    jsr fadein
    cli
    jsr irq_enable
    
    lda #!state_handleoptionsmenu
    sta w_programstate
    
    rts
}

;===========================================================================================
;===================== STATE 11:    H A N D L E O P T I O N S M E N U ======================
;===========================================================================================


handleoptionsmenu: {
    ;jsl glow_top
    
    jsl title_optionsmenu
    
    ;returned state depends on outcome of menu
    
    lda w_programstate
    cmp #!state_handleoptionsmenu
    beq +
    {   ;if state changed upstream,
        sta w_programstate              ;proceed to that ... wait a minute
        stz w_menu_state
        jsr fadeout                     ;fadeout
    }
    +
    rts
}


;===========================================================================================
;=================== STATE 7:   L O A D N O N G A M E P L A Y S C E N E ====================
;===========================================================================================
;assumes that a call to scenetransition has been done


loadnongameplayscene: {
    sei
    phk
    plb
    
    jsr waitfornmi
    jsr screenoff
    jsr disablenmi
    
    stz w_hdma_enable       ;both of these get set to true in hdma/glow_spawnfromlist
    stz w_glow_enable       ;calls later. if no objects get spawned (due to null ptr)
                            ;then it stays disabled from these here
    stz w_scene_timer
    
    stz w_bg1xscroll
    
    lda #$03ff
    sta w_bg1yscroll
    
    jsl load_scene
    
    stz w_msg_scrollindex
    stz w_msg_scrollpixels
    
    jsr layer3on
    jsr spritesoff
    
    ;db = program bank from above
    lda w_scene_init
    beq +
    ldx #$0000
    jsr (w_scene_init,x)        ;use rts from here to return to this routine's caller
    +
    
    jsr initspecialfx           ;glow, hdma, bg2
    
    lda #!state_nongamehandler
    sta w_programstate
    
    jsr enablenmi
    jsr waitfornmi
    jsr fadein
    
    rts
}

;===========================================================================================
;======================= STATE 6:    N O N G A M E P L A Y H A N D L E R ===================
;===========================================================================================
;handles dialogue scenes which aren't intro scenes
;goes from gameplay back to gameplay
;assumes w_nextscene has been set to the room we are going to return to

nongameplayhandler: {
    sei
    lda w_scene_timer
    bne +
    stz w_bg3yscroll
    
    ldx w_scene_strptr
    ldy w_scene_strline
    jsl msg_display
    +
    
    lda w_scene_scrolltextptr
    beq +
    jsl msg_scroll_main
    +
    
    lda w_controller
    beq +
    {
        ldx w_nextscene
        jsr scenetransition
        
        lda #!state_loadgame
        sta w_programstate
        
        jsr fadeout
        
        jsl hdma_clearchannels
        stz w_hdma_enable
    }
    +
    
    inc w_scene_timer
    
    rts
}


;===========================================================================================
;========================== STATE 2:   L O A D I N T R O S C E N E =========================
;===========================================================================================
;call scenetransition first, then change state to this.


loadintroscene: {
    sei
    jsr waitfornmi
    jsr screenoff
    jsr disablenmi
    
    stz w_hdma_enable
    stz w_glow_enable
    
    stz w_scene_timer
    stz w_msg_scrollpixels
    
    jsl load_scene
    
    jsr initspecialfx
    
    jsr layer3on
    
    lda #!state_introhandler
    sta w_programstate
    
    jsr waitfornmi
    jsr fadein
    
    rts
}

;===========================================================================================
;============================== STATE 0: I N T R O  S E T U P ==============================
;===========================================================================================
;initial setup for loading graphics, tilemaps of intro sequence

setupintro: {
    sei
    
    phk
    plb
    
    jsr waitfornmi
    jsr disablenmi
    jsr screenoff
    
    ;load graphics, palette, tilemap
    
    stz w_oam_index
    
    stz w_hdma_enable
    jsl hdma_clearall
    jsl hdma_clearchannels
    
    jsl glow_clearall
    stz w_glow_enable
    
    jsl hud_init
    jsl hud_test
    
    lda #!fade_bitmask_default
    sta w_fadebitmask
    
    lda #!fade_timer_default
    sta w_fadetimer
    
    lda #!camera_subspeed_default
    sta w_scroll_camerasubspeed
    
    lda #!camera_speed_default
    sta w_scroll_cameraspeed
    
    ldx.w #scenedef_intro1             ;initial intro scene pointer
    jsr scenetransition
    
    
    jsl load_bg3colortobuffer       ;bg3 palette
    ;jsl load_bg3tilemaptobuffer    ;tilemap copy to buffer
    ;jsl load_bg3tilemapupload      ;upload buffer
    jsl load_bg3tilesupload         ;bg3 tiles to vram
    jsl load_playerpal
    jsl load_playergfx
    
    lda #!player_hp_default         ;number is bcd
    sta w_player_hp ;can't do this in loadgame cause that runs every room transition
    
    lda #!starting_room
    sta.l s_roomptr
    
    lda #$01ff
    sta w_bg3yscroll
    
    stz w_msg_scrollpixels
    
    jsl obj_clearall
    
    jsr enablenmi
    jsr waitfornmi
    
    lda #!state_loadintroscene      ;program state = load text scene (for intro)
    sta w_programstate
    
    rts
}

;===========================================================================================
;=============================== STATE 3:   G A M E P L A Y=================================
;===========================================================================================

;high level gameplay
;see gameplay.asm


gameplayvector: {
    
    jsl gameplay
    
    rts
}

;===========================================================================================
;=========================== STATE 1:    I N T R O H A N D L E R ===========================
;===========================================================================================


introhandler: {
    sei
    
    lda w_scene_timer
    bne +
    {
        stz w_bg3yscroll
        jsr layer3on
        
        ldx w_scene_strptr
        ldy w_scene_strline
        jsl msg_display
    }
    +
    
    inc w_scene_timer
    
    lda w_scene_scrolltextptr
    beq +
    jsl msg_scroll_main
    +
    
    lda w_controller
    bit #!controller_no_dpad
    beq .return
    {
        lda w_testsceneindex
        inc
        sta w_testsceneindex            ;advance scene index
        
        lda w_testsceneindex
        asl
        tax
        lda.l introhandler_testtable,x
        tax
        jsr scenetransition             ;initiate scene change
        
        lda w_scene_mode
        sta w_programstate
        
        jsr fadeout
        jsl msg_reset
    }
    .return:
    rts
    
    
    .testtable: {
        dw scenedef_intro1,             ;0
           scenedef_overworld           ;1
    }
}


;===========================================================================================
;================================ STATE 4:   L O A D G A M E ===============================
;===========================================================================================

;set up gameplay
;relies on the scene area of memory being populated by a call to
;'scenetransition' having been done, probably immediately prior
;is used for setting up gameplay for the first time and also
;for doing room transitions between two gameplay rooms

loadgame: {
    sei
    jsr irq_disable
    jsr disablenmi
    jsr screenoff
    sei
    
    phk
    plb
    
    jsl load_scene                  ;depends on a call to scenetransition having been done
    jsl load_bg3colortobuffer
    
    stz w_hud_glow
    jsl hud_handleglow
    
    stz w_oam_index
    jsl oam_cleanbuffer
    jsl oam_cleanhibytebuffer
    
    ;initialize scroll
    stz w_scroll_direction
    
    lda #!scroll_upbound_default
    sta w_scroll_upbound
    
    lda #!scroll_downbound_default
    sta w_scroll_downbound
    
    lda #!scroll_leftbound_default
    sta w_scroll_leftbound
    
    lda #!scroll_rightbound_default
    sta w_scroll_rightbound
    
    ;initialize message tilemap
    jsr layer3off
    jsl msg_cleartilemap
    lda #$0001
    sta w_msg_uploadflag
    lda #$0800
    sta w_msg_size
    
    jsl speech_clear
    
    jsl player_init
    
    jsl hud_writeroomstring
    
    lda #w_player_hp
    ldx #$0007
    jsl hud_writethreedigitnumber
    
    jsl hud_draw
    
    lda w_level_camerastartx
    sta w_level_camerax
    sta w_bg1xscroll
    
    lda w_level_camerastarty
    sta w_level_cameray
    sta w_bg1yscroll
    
    jsl load_collisionmap
    
    jsl obj_clearall
    jsl obj_spawnall
    jsl obj_runinit
    jsl obj_drawall
    
    jsl player_main
    jsl scroll_main
    
    jsr initspecialfx   ;hdma, glows, bg2 tilemap; needs to happen after scroll call
    
    jsl fae_clearall
    jsl fae_spawnall
    jsl fae_top
    
    jsl shot_clearall
    
    ;finalize oam and upload the initial buffer for the fade-in of gameplay
    jsl oam_cleanbuffer
    jsl oam_constructhibuffer
    jsl oam_uploadbuffer
    
    ;set gameplay's irq command (for hud) and turn on irq
    lda.w #!irq_command_hud_start
    sta w_irq_command
    jsr irq_settarget
    jsr irq_enable
    cli
    
    lda #!state_gameplay
    sta w_programstate
    
    jsr enablenmi
    jsr waitfornmi
    jsr fadein
    jsr screenon
    
    rts
}

setupresumedgame: {
    lda #!fade_bitmask_default
    sta w_fadebitmask
    
    jsr fadeout
    ;screen is now off
    jsr disablenmi
    
    jsl hud_init
    jsl hud_test
    
    stz w_oam_index
    
    jsl load_bg3colortobuffer       ;bg3 palette
    ;jsl load_bg3tilemaptobuffer    ;tilemap copy to buffer
    ;jsl load_bg3tilemapupload      ;upload buffer
    jsl load_bg3tilesupload         ;bg3 tiles to vram
    jsl load_playerpal
    jsl load_playergfx
    
    ;eventaully get the following from save ram
    
    ;lda.l s_roomptr
    ;tax
    ldx #scenedef_overworld
    jsl scenetransition_long
    
    lda #!player_hp_default
    sta w_player_hp
    
    ;initialize message tilemap
    jsr layer3off
    jsl msg_cleartilemap
    lda #$0001
    sta w_msg_uploadflag
    lda #$0800
    sta w_msg_size
    
    jsr initspecialfx_forresumedgame        ;make sure hdma on bg2 is over being touched
        
    lda #!state_setupoverworld
    sta w_programstate
    
    jsr enablenmi
    
    rtl
}

;===========================================================================================
;===================== STATE 7:   S E T U P G A M E O V E R S C R E E N ====================
;===========================================================================================

setupgameoverscreen: {
    sei
    jsr irq_disable
    jsr disablenmi
    jsr screenoff
    
    ;do vram transfurs
    
    ; ============================= tilemap =============================
    lda #bank(gameoverdata)     ;tilemap bank
    sta p_2
        
    lda #gameoverdata_map       ;tilemap pointer
    sta p_0
        
    lda #$0800                  ;tilemap size
    jsl load_romtolevelbuffer   ;copy tilemap to level buffer
    
    lda #$0800                  ;tilemap size
    ldx #!bg1tilemap            ;destination in vram
    jsl load_levelbuffertovram  ;dma tilemap to vram
    
    ; ========================= bg2 tilemap =============================
    lda #bank(gameoverdata)     ;tilemap bank
    sta p_2
        
    lda #gameoverdata_bg2map    ;tilemap pointer
    sta p_0
        
    lda #$0800                  ;tilemap size
    jsl load_romtolevelbuffer   ;copy tilemap to level buffer
   
    lda #$0800                  ;tilemap size
    ldx #!bg2tilemap            ;destination in vram
    jsl load_levelbuffertovram  ;dma tilemap to vram
    
    ; =========================== graphics ==============================
    
    lda #bank(gameoverdata)             ;graphics bank
    sta p_2
    
    lda #gameoverdata_gfx               ;gfx pointer
    sta p_0
    
    lda #datasize(gameoverdata_gfx)     ;gfx size
    jsl load_romtobuffer                ;copy gfx to buffer
    
    lda #datasize(gameoverdata_gfx)     ;gfx size
    ldx #!bg1tiles                      ;destination in vram
    jsl load_buffertovram               ;dma gfx to vram
    
    ; ============================= palette =============================
    
    lda #bank(gameoverdata)
    ldx #gameoverdata_pal
    jsl load_romtocolorbuffer
    
    lda #$01ff
    sta w_bg1yscroll
    stz w_bg1xscroll
    
    stz w_bg2xscroll
    stz w_bg2yscroll
    
    stz w_oam_index
    jsl oam_cleanbuffer
    jsl oam_cleanhibytebuffer
    jsl oam_constructhibuffer
    
    phk
    plb
    
    lda #!layer_blend_gameover
    sta w_layerblendmode
    
    stz w_menu_state
    jsl gameover_drawcursor_long
    
    jsr enablenmi
    jsr waitfornmi
    jsr fadein
    jsr screenon
    
    lda #!state_handlegameoverscreen
    sta w_programstate
    
    rts
}

;===========================================================================================
;=================== STATE 8:   H A N D L E G A M E O V E R S C R E E N ====================
;===========================================================================================

handlegameoverscreen: {
    ;see gameover.asm
    
    jsl gameover_main
    
    rts
}
