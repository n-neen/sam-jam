;===========================================================================================
;======================================== SCROLLING ========================================
;===========================================================================================

scroll: {
    .main: {
        ;determine which directions to scroll
        
        ;this doesn't work anymore
        ;need to update based on what is actually moved
        ;not directions held
        
        lda w_player_x_onscreen
        cmp #!camera_box_lf_bound           ;if > x bound (towards center of screen),
        bpl ..skipleft
        {
            lda w_player_xspeed             ;and x pseed is negative
            bpl ..skipleft
            
            {
                lda w_scroll_direction
                ora #!controller_lf         ;add left to scroll direction
                sta w_scroll_direction
            }
        }
        ..skipleft:
        
        
        lda w_player_x_onscreen
        cmp #!camera_box_rt_bound           ;if < x bound (towards center of screen),
        bmi ..skipright
        {
            lda w_player_xspeed             ;and x speed is positive
            bmi ..skipright
            
            {
                lda w_scroll_direction
                ora #!controller_rt         ;add right to scroll direction
                sta w_scroll_direction
            }
        }
        ..skipright:
        
        
        lda w_player_y_onscreen
        cmp #!camera_box_up_bound           ;if > y bound (towards center of screen),
        bpl ..skipup
        {
            lda w_player_yspeed             ;and y speed is negative
            bpl ..skipup
            
            {
                lda w_scroll_direction
                ora #!controller_up         ;add up to scroll direction
                sta w_scroll_direction
            }
        }
        ..skipup:
        
        
        
        lda w_player_y_onscreen
        cmp #!camera_box_dn_bound           ;if < y bound (towards center of screen),
        bmi ..skipdown
        
        {
            lda w_player_yspeed             ;and y speed is positive
            bmi ..skipdown
            {
                lda w_scroll_direction
                ora #!controller_dn         ;add down to scroll direction
                sta w_scroll_direction
            }
        }
        ..skipdown:
        
        ;handle scrolling each direction
        
        lda w_scroll_direction
        
        bit #!controller_up
        beq ..noup
        jsr scroll_up
        ..noup:
        
        bit #!controller_dn
        beq ..nodown
        jsr scroll_down
        ..nodown:
        
        bit #!controller_lf
        beq ..noleft
        jsr scroll_left
        ..noleft:
        
        bit #!controller_rt
        beq ..noright
        jsr scroll_right
        ..noright:
        
        ;apply camera to bg1 scroll
        ;currently this doesn't make all that much sense
        ;but i think the idea was that it would be useful later?
        ;curious
        
        lda w_level_camerax
        sta w_bg1xscroll
        
        lda w_level_cameray
        sta w_bg1yscroll
        
        
        rtl
    }
    
    .up: {
        pha
        
        lda w_level_cameray
        cmp w_scroll_upbound
        bmi +
        
        lda w_level_camerasuby
        clc
        adc w_player_ysubspeed
        sta w_level_camerasuby
        
        lda w_level_cameray
        adc w_player_yspeed
        sta w_level_cameray
        
        +
        
        pla
        rts
    }
    
    .down: {
        pha
        
        lda w_level_cameray
        cmp w_scroll_downbound
        bpl +
        
        lda w_level_camerasuby
        clc
        adc w_player_ysubspeed
        sta w_level_camerasuby
        
        lda w_level_cameray
        adc w_player_yspeed
        sta w_level_cameray
        
        +
        
        pla
        rts
    }

    .left: {
        pha
        
        lda w_level_camerax
        cmp w_scroll_leftbound
        bmi +                       ;comment out to test loading seam
        
        lda w_level_camerasubx
        clc
        adc w_player_xsubspeed
        sta w_level_camerasubx
        
        lda w_level_camerax
        adc w_player_xspeed
        sta w_level_camerax
        
        +
        
        pla
        rts
    }

    .right: {
        pha
        
        lda w_level_camerax
        cmp w_scroll_rightbound
        bpl +                       ;comment out to test loading seam
        
        lda w_level_camerasubx
        clc
        adc w_player_xsubspeed
        sta w_level_camerasubx
        
        lda w_level_camerax
        adc w_player_xspeed
        sta w_level_camerax
        
        +
        
        pla
        rts
    }
    
    
;===================================== scrolling seam ======================================
    .seam: {
        ..main: {
            ;check for seam update
            ;nmi routine
            
            ;broken nonsense
            
            lda w_scroll_direction
            
            bit #!controller_lf
            beq +
            {
                lda #-$0200
                sta p_2
                
                lda #$0004
                sta p_0
                jsr scroll_seam_horizontal      ;behind camera
            
                lda #$0000
                sta p_0
                jsr scroll_seam_horizontal      ;camera position
                
                lda #$fffc
                sta p_0
                jsr scroll_seam_horizontal      ;ahead of camera
                
                lda #$fff8
                sta p_0
                jsr scroll_seam_horizontal
                
                ;lda #$fff4
                ;sta p_0
                ;jsr scroll_seam_horizontal
            }
            +
            
            bit #!controller_rt
            beq +
            {
                lda #$0200
                sta p_2
                
                lda #$fffc
                sta p_0
                jsr scroll_seam_horizontal      ;behind camera
                
                lda #$0000
                sta p_0
                jsr scroll_seam_horizontal      ;camera position
                
                lda #$0004
                sta p_0
                jsr scroll_seam_horizontal      ;ahead of camera
                
                lda #$0008
                sta p_0
                jsr scroll_seam_horizontal
                
                ;lda #$000c
                ;sta p_0
                ;jsr scroll_seam_horizontal
                
                ;
            }
            +
            
            
            rtl
        }
        
        ..fillbuffer: {
            ;this doesn't work even a little bit
            ;ok it kinda does now
            
            ldy #$0000
            
            lda w_level_camerax
            clc
            adc p_0
            lsr
            lsr
            ;lsr
            
            sta p_6
            
            lda w_level_cameray     ;(/8, *$20)
            asl
            asl
            clc
            adc p_6
            
            tax
            
            -
            lda.l l_level,x
            ;lda.l room1_map,x
            sta w_seambuffer,y
            
            txa
            clc
            adc #$0040
            tax
            
            iny
            iny
            cpy #datasize(w_seambuffer)-2
            bmi -
            
            
            
            rts
        }
        
        
        ..left: {
            lda #$fff8
            sta p_0
            bra scroll_seam_horizontal
        }
        
        ..right: {
            lda #$0100
            sta p_0
            ;fall through
        }
        
        
        ..horizontal: {
            ;p_0 = either w_bg1xscroll, or a space 4-8 pixels ahead of it
            
            ;broken nonsense
            
            jsr scroll_seam_fillbuffer
            
            phx
            
            lda w_bg1xscroll
            clc
            adc p_0
            bit #$0007
            bne ...skip
            
            ;clc
            ;adc p_0             ;add offset for moving left (-$80) or right ($0180)
            sec
            sbc #$0180
            
            clc
            adc p_2
            
            lsr
            lsr
            ;lsr
            and #$00fe          ;how did this just work....
            
            tax
            sep #$10
            lda scroll_seam_horizontal_columnlist,x
            ;clc
            ;adc p_8
            
            clc
            adc #!bg1tilemap
            
            sta $2116
                                        ;width  register
            ldx.b #$81                  ;1      write pattern: increment by 32 words
            stx $2115
            
            ldx #$01                    ;1      transfur mode
            stx $4300
            
            ldx #$18                    ;1      register dest (vram port)
            stx $4301
            
            lda #w_seambuffer           ;2      source addr
            sta $4302
            
            ldx.b #bank(w)              ;1      source bank
            stx $4304
            
            lda #datasize(w_seambuffer) ;2      transfur size
            sta $4305
            
            ldx #$01                    ;1      enable transfur on dma channel 0
            stx $420b
            
            rep #$10
            
            ...skip
            plx
            rts
            
            ...columnlist:
                dw $0400, $0401, $0402, $0403, $0404, $0405, $0406, $0407, $0408, $0409, $040a, $040b, $040c, $040d, $040e, $040f,
                   $0410, $0411, $0412, $0413, $0414, $0415, $0416, $0417, $0418, $0419, $041a, $041b, $041c, $041d, $041e, $041f,
                   
                   $0000, $0001, $0002, $0003, $0004, $0005, $0006, $0007, $0008, $0009, $000a, $000b, $000c, $000d, $000e, $000f,
                   $0010, $0011, $0012, $0013, $0014, $0015, $0016, $0017, $0018, $0019, $001a, $001b, $001c, $001d, $001e, $001f,
                   
                   $0400, $0401, $0402, $0403, $0404, $0405, $0406, $0407, $0408, $0409, $040a, $040b, $040c, $040d, $040e, $040f,
                   $0410, $0411, $0412, $0413, $0414, $0415, $0416, $0417, $0418, $0419, $041a, $041b, $041c, $041d, $041e, $041f,
                   
                   $0000, $0001, $0002, $0003, $0004, $0005, $0006, $0007, $0008, $0009, $000a, $000b, $000c, $000d, $000e, $000f,
                   $0010, $0011, $0012, $0013, $0014, $0015, $0016, $0017, $0018, $0019, $001a, $001b, $001c, $001d, $001e, $001f
        }
        
        
    }
    
    .bg2: {
        ;todo
        
        lda w_bg1xscroll
        lsr
        lsr
        sta w_bg2xscroll
        
        lda w_bg1yscroll
        lsr
        lsr
        sta w_bg2yscroll
        
        rtl
    }
}