overworld: {
    .setup: {
        ;top level state
        
        ;turn off screen
        ;load graphics, tilemap, palette
        ;need node system for putting the player on levels
        
        ;we get here with the screen off
        
        jsl disablenmi_long
        jsl screenoff_long
        
        jsl load_scene
        
        jsl enablenmi_long
        jsl waitfornmi_long
        jsl fadein_long
        jsl screenon_long
        
        lda #!state_overworld
        sta w_programstate
        
        rtl
    }
    
    
    .main: {
        ;top level state
        
        ;animate sam
        ;if start or A pressed, start game with w_overworld_node_scene_target
        ;if dpad, look up node's valid exit directions
        ;if direction is valid, start moving with w_overworld_path
        ;carry out moving until direction is reached
        
        
        rtl
    }
    
}