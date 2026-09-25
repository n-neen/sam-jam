gameplay: {
    phk
    plb
    
    jsl hud_handleglow                  ;this set up parameters for an interrupt that
                                        ;happens on scanline 8, so needs to happen early
                                        ;in the game logic. unless you're ok with this 
                                        ;having data from last frame (maybe fine)
    
    stz w_player_direction
    stz w_scroll_direction
    stz w_player_collisiontype          ;not really used
    stz w_oam_index
    stz w_msg_waitflag
    stz w_gameplayfadeoutstate
    
    jsl oam_cleanhibytebuffer
    
    jsl hud_draw                        ;1: draws hud
    jsl speech_top                      ;2: draws speech boxes
    
    jsl player_main                     ;3: draws player
    jsl scroll_main
    jsl scroll_bg2
    
    jsl obj_runmain
    jsl obj_collision
    
    .hudwordtest: {
        ;test
        ;clear the hud area so the fae collision test result
        ;can be seen
        
        lda w_player_iframes
        bne +
        lda #$2020
        sta w_hud_buffer+10
        sta w_hud_buffer+12
        +
    }
    
    jsl shot_top                        ;4: draws shots
    
    jsl fae_top                         ;5: draws fae
                                        ;then finalize oam
    jsl oam_cleanbuffer                 ;write $e0e0 to the remainder of the oam buffer not used by this frame
    jsl oam_constructhibuffer           ;construct the real (two bits per sprite) oam hi table from the byte table (one byte per sprite)
    
    ;end of this gameplay frame's logic
    ;if we have a fadeout queued, do that now
    
    lda w_gameplayfadeoutstate
    beq +
    {
        sta w_programstate              ;change program state then fade out
        jsl fadeout_long
    }
    +
    rtl
    
    
    .shadow: {
        ;stripped down gameplay to allow player to move during text
        ;but does not allow for collision
        
        ;not currently used
        
        stz w_player_direction
        stz w_scroll_direction
        
        jsl player_main
        jsl scroll_main
        
        jsl shot_top
        
        jsl fae_top
        
        jsl oam_cleanbuffer                 ;write $e0e0 to the remainder of the oam buffer not used by this frame
        jsl oam_constructhibuffer           ;construct the real (two bits per sprite) oam hi table from the byte table (one byte per sprite)
        
        
        rtl
    }
    
    
}
