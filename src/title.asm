title: {
    .main: {
        phk
        plb
        
        lda w_menu_var2         ;bg2 y scroll subpixels
        clc
        adc w_menu_var3         ;bg2 y scroll subpixel speed
        sta w_menu_var2
        
        lda w_bg2yscroll
        adc #$0000
        sta w_bg2yscroll
        

        lda w_menu_var1         ;bg2 x scroll subpixels
        clc
        adc #$4000              ;bg2 x scroll subpixel speed
        sta w_menu_var1
        
        lda w_bg2xscroll
        adc #$0000
        sta w_bg2xscroll
        
        lda w_nmicounter
        bit #$0007
        bne +
        
        lda w_menu_state
        asl
        tax
        jsr (title_statetable,x)
        
        +
        stz w_oam_index
        jsr title_drawcursor
        jsl oam_cleanbuffer
        
        rtl
    }
    
    .statetable: {
        dw title_menustartgame,         ;0
           title_menuresumegame,        ;1
           title_menuoptions            ;2
    }
    
    .menustartgame: {
        lda #$0000
        sta w_menu_var3
        
        
        
        lda w_controller
        
        bit #!controller_dn
        beq ..nodn
        {
            ;if dn pressed
            pha
            lda #!title_menu_state_resumegame
            sta w_menu_state
            pla
        }
        ..nodn
        
        bit #!controller_a|!controller_st
        beq ..noa
        {
            ;if dn pressed
            pha
            jsr title_startgame
            pla
        }
        ..noa
        
        
        rts
    }
    
    .menuresumegame: {
        lda #$4000
        sta w_menu_var3
        
        
        lda w_controller
        
        bit #!controller_up
        beq ..noup
        {
            ;if dn pressed
            pha
            lda #!title_menu_state_startgame
            sta w_menu_state
            pla
        }
        ..noup
        
        bit #!controller_dn
        beq ..nodn
        {
            ;if dn pressed
            pha
            lda #!title_menu_state_options
            sta w_menu_state
            pla
        }
        ..nodn
        
        bit #!controller_a|!controller_st
        beq ..noa
        {
            ;if dn pressed
            pha
            jsr title_resumegame
            pla
        }
        ..noa
        
        
        rts
    }
    
    .resumegame: {
        jsl setupresumedgame
        
        rts
    }
    
    .menuoptions: {
        lda #$e000
        sta w_menu_var3
        
        
        
        
        lda w_controller
        bit #!controller_up
        beq ..noup
        {
            ;if up pressed
            pha
            lda #!title_menu_state_resumegame
            sta w_menu_state
            pla
        }
        ..noup
        
        bit #!controller_a|!controller_st
        beq ..noa
        {
            ;if dn pressed
            pha
            ;do options menu eventually
            
            lda #$0001
            sta w_fadebitmask
            
            lda #!state_setupoptionsmenu
            sta w_programstate
            
            pla
        }
        ..noa
        
        
        rts
    }
    
    
    .startgame: {
        ;start intro
        
        lda #!state_introsetup
        sta w_programstate
        
        lda #!fade_bitmask_default
        sta w_fadebitmask
        
        jsl fadeout_long
        jsl msg_reset
        
        rts
    }
    
    
    .drawcursor: {
        ;used in routine
        ;p_0 = number of sprites to draw
        ;p_2 = used for y position
        ;p_4 = used for x position
        ;p_6 = used for sprite tile selection (via nmi counter)
        
        phb
        phx
        phy
        
        phk
        plb
        
        lda w_nmicounter
        and #$001c
        lsr
        lsr
        sta p_6
        
        lda w_menu_state
        asl
        asl
        tax
        
        lda title_cursorpositions,x         ;x position
        sta p_4
        
        lda title_cursorpositions+2,x       ;y position
        sta p_2
        
        ldy w_oam_index
        ldx #title_cursorspritemap
        
        lda $0000,x
        and #$00ff
        sta p_0             ;number of sprites
        inx
        
        ..nextsprite
        
        sep #$20
        {
            lda $0000,x
            clc
            adc.b p_4
            sta w_oam_lo_buffer,y       ;x
            
            lda $0001,x
            clc
            adc.b p_2
            sta w_oam_lo_buffer+1,y     ;y
            
            lda $0002,x
            clc
            adc p_6
            sta w_oam_lo_buffer+2,y     ;tile
            
            lda $0003,x
            sta w_oam_lo_buffer+3,y     ;properties
            
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
        
        ply
        plx
        plb
        rts
        
        ..long: {
            jsr title_drawcursor
            rtl
        }
    }
    
    .cursorpositions: {
            ;x,     y
        dw $0030,   $0098       ;position when on "start game"
        dw $0030,   $00ae       ;position when on "resume game"
        dw $0030,   $00c4       ;position when on "options"
    }
    
    .cursorspritemap: {
        db 01
        ;  xx   yy   tt    vhrrpppt   hh 01 = extra x bit, 02 = size select
        db $00, $00, $00, %01110010, $00
        db $00, $00, $01, %01110010, $00
    }
    
    
    .optionsmenu: {
        lda w_controller
        beq +
        
        lda #!state_setuptitle
        sta w_programstate
        
        +
        rtl
    }
}

