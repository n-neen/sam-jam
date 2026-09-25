;ram reference:

;        
;        w_overworld_sam: {
;            ...x:           :   skip 2  ;onscreen position for sprite drawing
;            ...y:           :   skip 2
;            ...anim_counter :   skip 2
;        }
;    }









overworld: {
    .setup: {
        ;top level state
        
        ;turn off screen
        ;load graphics, tilemap, palette
        ;need node system for putting the player on levels
        
        ;we get here with the screen off
        
        stz w_oam_index
        
        jsl disablenmi_long
        jsl screenoff_long
        
        jsl load_scene
        
        ;#overworld_sprites_pal
        
        stz w_oam_index
        jsl oam_cleanhibytebuffer
        
        
        ; =========================== graphics ==============================
        
        lda #bank(overworld_sprites)            ;graphics bank
        sta p_2
        
        lda #overworld_sprites_gfx              ;gfx pointer
        sta p_0
        
        lda #datasize(overworld_sprites_gfx)    ;gfx size
        jsl load_romtobuffer                    ;copy gfx to buffer
        
        lda #datasize(overworld_sprites_gfx)    ;gfx size
        ldx #!spritegfx                         ;destination in vram
        jsl load_buffertovram                   ;dma gfx to vram
        
        ; =========================== palette ==============================
        
        ;copies sprite palettes only
        
        ldx #$0100
        -
        lda.l overworld_sprites_pal,x
        sta.l w_cgrambuffer+$0100,x
        dex
        dex
        bpl -
        
        
        jsl fae_clearall
        jsl fae_spawnall
        jsl fae_top
        
        lda w_scene_layerblend
        sta w_layerblendmode
        
        lda #$1003
        sta.l w_cgrambuffer     ;set backdrop lol yeah that's right just do this
        
        jsl oam_cleanbuffer       
        jsl oam_constructhibuffer 
        
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
        
        phk
        plb
        
        stz w_oam_index
        jsl oam_cleanhibytebuffer
        
        
        jsl fae_top
        
        
        jsl oam_cleanbuffer       
        jsl oam_constructhibuffer 
        
        rtl
    }
    
        ;do this at some point
        ;w:
        ;    .overworld: 
        ;        ..node: 
        ;            ...ptr:         :   skip 2
        ;            ...x:           :   skip 2
        ;            ...y:           :   skip 2
        ;            ...scene_target :   skip 2  ;where to go when game starts
        ;            ...unlocked     :   skip 2  ;boolean for can we move
        ;            ...exits        :   skip 2  ;valid directions to leave node
        ;        
        ;        
        ;        ..path: 
        ;            ...ptr:         :   skip 2  ;one signed byte per frame for movement?
        ;            ...timer        :   skip 2
        ;            ...state        :   skip 2
        ;       


    
    .node: {
        ..0: {
            db $15                      ;x
            db $bd                      ;y
            dw scenedef_room1           ;target room
            dw overworld_node_exit_0    ;valid directions to move
        }
        
        ..1: {
            db $45                      ;x
            db $96                      ;y
            dw scenedef_room1           ;target room
            dw overworld_node_exit_1    ;valid directions to move
        }
        
        ..exit: {
                ;target node, path ptr
            ...0:
                dw $0000, $0000                             ;up
                dw $0000, $0000                             ;down
                dw $0000, $0000                             ;left
                dw overworld_node_1, overworld_node_path_0  ;right
                
            ...1:
                dw $0000, $0000                             ;up
                dw overworld_node_0, overworld_node_path_1  ;down
                dw $0000, $0000                             ;left
                dw $0000, $0000                             ;right
        }
        
        ..path: {
            ...0: {
                db 00, 00, 00, 00, $ff  ;input playback? ext file?
            }
            
            ...1: {
                db 00, 00, 00, 00, $ff  ;input playback?
            }
            
            ...2: {
                db 00, 00, 00, 00, $ff  ;input playback?
            }
            
            ...3: {
                db 00, 00, 00, 00, $ff  ;input playback?
            }
        }
    }
    
    
    
}