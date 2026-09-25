;top level label is 'fae'

.common:
    ..explode: {
        ;eventually we'll have shot reactions and that's the main place it'll go
        
        ;changes the fae's identity, main routine to that of the explosion
        ;also needs to stop touch routine from running repeatedly
        ;(and eventually when shot reactions exist, zero that pointer too)
        ;var1 is used as an index into spritemap list for running animation
        
        lda #fae_explosion
        sta w_fae_id,x
        
        lda #fae_explosion_main
        sta w_fae_mainptr,x
        
        stz w_fae_touchptr,x
        
        stz w_fae_shotptr,x
        
        lda #datasize(fae_explosion_spritemaplist)/2
        sta w_fae_var1,x
        
        ;could set init and run it here too, but i dcurrently don't have a use for that
        
        rts
    }
    
    ..hurtplayer: {
        ;touch reaction
        
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
        rts
    }
    
    
    ..giveiframes: {
        ;touch reaction
        ;x = fae index
        
        lda #!player_frames_default
        sta w_player_iframes
        
        jmp fae_common_bounce
        
        ;write some structure to "how much contact damage and enemy does"
        
        ;lda w_player_hp
        ;sec
        ;sec w_fae_contactdamage,x
        ;sta w_player_hp
        
        ;or
        
        ;phx
        ;lda w_fae_id,x
        ;tax
        ;lda.l (bank(fae)<<16)+!contactdamage,x     ;!contactdamage is how far into the header it is
        ;sta p_0
        ;lda w_player_hp
        ;sec
        ;sbc p_0
        ;sta w_player_hp
        ;plx
        ;
        
        
        rts
    }
    
    
    ..stop: {
        ;touch reaction
        ;x = fae index
        
        stz w_player_yspeed
        stz w_player_ysubspeed
        
        stz w_player_xspeed
        stz w_player_xsubspeed
        
        rts
    }
    
    
    ..bounce: {
        ;touch reaction
        ;x = fae index
        ;kinda just inverts speeds but also slow down a bit
        
        lda w_player_yspeed
        bmi +
        dec
        bra ++
        +
        inc
        ++
        eor #$ffff
        inc
        sta w_player_yspeed
        stz w_player_ysubspeed
        
        
        lda w_player_xspeed
        bmi +
        dec
        bra ++
        +
        inc
        ++
        eor #$ffff
        inc
        sta w_player_xspeed
        stz w_player_xsubspeed
        
        rts
    }
}