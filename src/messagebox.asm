msg: {
    .display: {
        ;x = message pointer
        ;y = starting line
        
        ;used in routine
        ;p_0 = long pointer to string
        
        stx p_0
        
        lda #bank(str)
        sta p_2
        
        tya
        asl
        asl
        asl
        asl
        asl
        asl
        sta w_msg_start
        tax                     ;x = starting index in tilemap (line * 32)*2 again for tilemap (2 bytes per tile)
        ldy #$0000              ;y = starting index in source text
        
        ..loop:
        lda [p_0],y
        and #$00ff
        beq ..done
        
        cmp #$0020                      ;characters < $20 are control characters
        bpl ..notcontrol
        jsr msg_handlecontrolchars
        bra ..control
        ..notcontrol:
        
        sec
        sbc #$0020                      ;align ascii with tiles
        ora #$2000                      ;add priority bit
        sta.l w_msgbuffer,x             ;write to ram. possibly hirom area so needs this
        
        
        {   ;use this if you want to type out one character per frame
            phy
            phx
            
            lda #$0001
            sta w_msg_uploadflag
            txa
            inc
            inc
            sta w_msg_size
            
            lda w_msg_waitflag
            bne ..nowait
            
            lda w_hdma_enable
            beq +
            jsl hdma_top
            +
            
            lda w_glow_enable
            beq +
            jsl glow_top
            +
            
            jsl waitfornmi_long
            ..nowait
            
            
            ;jsl gameplay               ;could call gameplay here too
            
            ;lda w_programstate
            ;cmp #!state_gameplay
            ;bne ..notgameplay
            ;jsl gameplay_shadow         ;this is a better idea but still not ideal
            ;..notgameplay
            
            
            ;maybe gameplay and scene handler both have shadow modes?
            ;scene handler doesn't need to do anyhting else, so i think gameplay
            ;is the only one that needs this
            
            plx
            ply
        }
        
        inx
        inx
        ..control:
        iny     ;if it was a control character, inc source index but not destination index
        bra ..loop
        
        
        ..done:
        
        ;stx w_msg_size
        rtl
    }
    
    
    .displayspeech: {
        
        
        lda w_speech_string_ptr
        sta p_0
        
        lda #((str&$ff0000)>>16)    ;text string bank
        sta p_2
        
        
        
        tya
        asl
        asl
        asl
        asl
        asl
        asl
        sta w_msg_start
        
        rtl
    }
    
    
    .handlecontrolchars: {
        ;low byte of A = ascii character
        ;   (control characters are under $20)
        ;x = tilemap index
        ;y = source text index
        
        cmp.w #!msg_newline
        bne +
        
        ;if newline:
        
        pha
        txa
        
        clc
        adc #$0040      ;add $20*2 (two bytes of tilemap) to go down a line
        and #$ffc0      ;remove bits lower than $40 to align to left
        
        tax
        pla
        
        +
        rts
    }
    
    
    .reset: {
        jsl msg_cleartilemap
        
        lda #$0001
        sta w_msg_uploadflag
        lda #$0800
        sta w_msg_size
        
        jsl layer3off_long
        
        rtl
    }
    
    
    .cleartilemap: {
        phb
        phx
        
        pea.w (($ff0000&w_msgbuffer)>>8)+0     ;db = message buffer bank (7e)
        plb
        plb
        
        ldx #$0100
        
        -
        stz.w w_msgbuffer,x
        stz.w w_msgbuffer+$100,x
        stz.w w_msgbuffer+$200,x
        stz.w w_msgbuffer+$300,x
        stz.w w_msgbuffer+$400,x
        stz.w w_msgbuffer+$500,x
        stz.w w_msgbuffer+$600,x
        stz.w w_msgbuffer+$700,x
        dex
        dex
        bpl -
        
        plx
        plb
        rtl
    }

    
    
    .upload: {
        lda #(!bg3tilemap)
        sta w_dmabaseaddr
        
        lda.w #w_msgbuffer
        sta w_dmasrcptr
        
        lda.w #(($ff0000&w_msgbuffer)>>16)+0
        sta w_dmasrcbank
        
        lda w_msg_size
        sta w_dmasize
        
        jsl dma_vramtransfur
        
        rtl
    }
    
;===========================================================================================
;============================== SCROLLING TEXT SYSTEM ======================================
;===========================================================================================
            ;this was a huge pain to write
            ;line numbers that are multiples of $20 lines end up
            ;in a section of w_msg_buffer that overflows into $7f
            ;(the $40 bytes under $7fe000)
            ;so you can either write a special case for this
            ;or just don't use multiples of $20
            ;actually, i added an ORA #$0001 that fixed this lol
            
            ;this subsystem is pretty reckless with clobbering x and y
            ;thankfully it doesn't end up mattering
    
    
    
    
    .scroll: {
    
;============================== SCROLL_MAIN ================================================
        ..main: {
            
            phk
            plb
            
            lda w_scene_timer
            cmp #!scrolling_text_delay
            bmi +
            
            ;jsr msg_scroll_advance     ;broken
            lda w_msg_scrollpixels
            inc
            sta w_msg_scrollpixels
            and #$00ff
            sta w_bg3yscroll
            
            jsr msg_scroll_seam
            
            lda w_controller
            bit #!controller_up         ;press up to speed up
            bne +
            
            jsl waitfornmi_long         ;halve the speeb, replaces call to msg_scroll_advance above
            
            +
            rtl
        }
        
        
;============================== SCROLL_ADVANCE =============================================
        ..advance: {
            ;call is commented out, don't use this.
            
            ;subpixel implementation
            ;this does not work at all
            ;the scrolling is fine, but the loading seam does not function unless
            ;we are going at exactly one pixel per frame of speed
            ;which reaaaally sucks, but i am going to revert to that just so it works
            ;surely someday i will fix this bug right?
            ;rewrite this whole thing a fifth time?
            
            
            phx
            
            ldx w_scene_gameprops                          ;does not work anymore cuz
            lda.l (bank(scenedef)<<16)+0|$0009,x           ;this data was removed from scenedef
            
            ;format for speed.subspeed is fixed point:
            ;one word, ssbb
            ;where:
            ;ss = speed
            ;bb = subspeed
            
            stz p_4
            
            pha
            and #$00ff
            xba
            ;subpixel speed
            sta p_4
            
            pla
            and #$ff00
            xba
            sta p_6
            
            lda w_msg_scrollsubpos
            clc
            adc p_4
            sta w_msg_scrollsubpos
            
            lda w_msg_scrollpixels      ;add the carry/pixel speed
            adc p_6
            sta w_msg_scrollpixels
            and #$00ff
            sta w_bg3yscroll
            
            plx
            rts
        }
        
;===========================================================================================
        ;deprecated scroll functions from when this was controlled with up and down on dpad
        ..input: {
            ;not used anymore
            lda w_controller
            and #(!controller_up|!controller_dn)
            
            bit #!controller_up
            beq +
            {
                ;if up pressed
                pha
                jsr msg_scroll_up
                pla
            }
            +
            
            bit #!controller_dn
            beq +
            {
                ;if down pressed
                pha
                jsr msg_scroll_down
                pla
            }
            +
            
            rts
        }
        
        
        ..up: {
            ;not used anymore
            lda w_bg3yscroll
            dec
            and #$00ff
            sta w_bg3yscroll
            
            ldx #$3863              ;tile to fill rows with while scrolling up
            stx p_0
            jsr msg_scroll_seam
            
            rts
        }
        
        
        ..down: {
            ;not used anymore
            lda w_bg3yscroll
            inc
            and #$00ff
            sta w_bg3yscroll
            
            ldx #$2000              ;high priority nothin
            stx p_0
            jsr msg_scroll_seam
            
            rts
        }
        
        
;================================== HANDLENONTEXTCOMMAND ===================================
        ..handlenontextcommand: {
            ;the scrolling text lists use one word for line counts to indicate the line
            ;to write text on. the $8000 bit is a flag to indicate that we need to run
            ;one of these functions instead. the bottom 15 bits are an index into this jump table
        
            ;A = the contents of p_0 referenced as a pointer,
            ;y = index into string list
            
            phx
            phy
            phb
            
            phk
            plb
            
            and #$7fff
            asl
            tax
            
            iny
            iny
            lda [p_0],y
            
            jsr (msg_scroll_nontextcommands,x)
            
            lda w_msg_scrollindex       ;advance to next line:string pointer
            clc
            adc #$0004
            sta w_msg_scrollindex
            
            plb
            ply
            plx
            rts
        }
        
        ..nontextcommands: {
            dw msg_scroll_writebackdrop,        ;0
               msg_scroll_spawnglow,            ;1
               msg_scroll_spawnhdma             ;2
        }
        
        ..writebackdrop: {
            ;A = command argument
            ;x = command index if you cared about that (probably not)
            
            sta w_cgrambuffer   ;set backdrop color
            
            rts
        }
        
        ..spawnglow: {
            ;A = command argument
            ;spawn color cycling object
            ;spawner finds slot on its own
            
            tay
            jsl glow_spawn
            
            rts
        }
        
        ..spawnhdma: {
            ;A = command argument
            ;spawn hdma object to slot 7
            
            tay
            ldx #$0007*2
            jsl hdma_spawn
            
            rts
        }
        
        
;================================== SCROLL_WRITELINE =======================================
        ..writeline: {
            ;w_bg3yscroll will be 1 less than having the $0008 bit
            ;x = index into w_msgbuffer
            ;y is free to use
            
            ;p_0 = long pointer to line count:string
            ;p_4 used to put value down to or $0001 it
            
            ;print pc
            
            ldy w_msg_scrollindex
            
            lda w_scene_scrolltextptr       ;check if this matches a prescribed line for writing
            sta p_0
            
            lda #bank(str)
            sta p_2
            
            lda [p_0],y                             ;check for non-text command
            bpl +
            jsr msg_scroll_handlenontextcommand     ;run non-text command
            bra ...clearline                        ;if we did, end the line
            +
            ora #$0001                      ;this prevents the bug with text lines that
            sta p_4                         ;are multiples of $20 not capable of being shown
            
            ldy w_msg_scrollindex
            
            lda w_msg_scrollpixels
            inc
            lsr
            lsr
            lsr                             ;(w_bg3yscroll+1)/8 = text line
            ;cmp [p_0],y
            cmp p_4                         ;
            bne ...clearline
            
            ;we have a line count match
            ;p_0 contains long pointer to the line count. string pointer is the word after that
            lda [p_0],y
            inc p_0                         ;pointer+2 goes past the line count to the string pointer
            inc p_0
            lda [p_0],y
            sta p_0                         ;p_0 now long pointer to string (referenced)
            
            inx                             ;off by one character somehow
            inx
            
            ldy #$0000
            -
            lda [p_0],y
            and #$00ff
            beq ...finishline
            sec
            sbc #$0020                      ;align with ascii
            ora #$2000                      ;add priority bit
            sta.l w_msgbuffer,x
            ...next
            inx
            inx
            iny
            cpy #$0020
            bne -
            
            lda w_msg_scrollindex       ;advance to next line:string pointer
            clc
            adc #$0004
            sta w_msg_scrollindex
            
            +
            rts
            
            ...clearline:
            
            inx     ;why?
            inx

            ldy #$0000
            
            lda #$2000
            -
            sta w_msgbuffer,x
            inx
            inx
            iny
            cpy #$0020
            bmi -
            
            rts
            
            ...finishline:
            
            ;y starts at 0 and goes towards $1f for the line anyway, so just leave it in tact
            
            ;inx
            ;inx
            ;dey
            
            lda #$2000
            -
            sta w_msgbuffer,x
            inx
            inx
            iny
            cpy #$0020
            bmi -
            
            lda w_msg_scrollindex       ;advance to next line:string pointer
            clc
            adc #$0004
            sta w_msg_scrollindex
            
            rts
        }
        
;================================== SCROLL_SEAM ============================================
        ..seam: {
            ;this is the only call from scroll_main
            ;and we figure out here if we have bg3yscroll%8
            ;and if so, get the line's index into the $800 byte array at w_msgbuffer
            ;there's a bug with this where $40 bytes of it overflows into $7f
            ;hopefully won't matter
            ;but it means that line counts that are multiples of $20 lines
            ;won't be displayed. so there's an ORA #$0001 in msg_scroll_writeline to hide this bug
            
            lda w_bg3yscroll        ;load tiles in advance of the scroll to keep it offscreen,
            sec
            sbc #$0015              ;this subtraction moves the seam further offscreen
            
            bit #$0007              ;only load rows when scroll mod 8
            bne +
            dec
            dec
            
            asl                     ;some kinda math
            asl
            asl
            clc
            adc #$004e
            
            cmp #$0800              ;wrap when > $800
            bmi ...nowrap
            ...wrap
            sec
            sbc #$0800
            ...nowrap
            tax

            jsr msg_scroll_writeline

            lda #$0800
            sta w_msg_size
            sta w_msg_uploadflag
            
            +
            rts
        }
    }
    
}