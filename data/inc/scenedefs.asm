
scenedef: {
    macro scenedefentry(label)
        ;not using this in actual entries for now
        dl <label>                  ;long pointer to the scene data ;$0
        dw <label>_pal              ;inbank pointer to palette,     ;$3
        dw <label>_gfx              ;graphics,                      ;$5
        dw <label>_map              ;tilemap                        ;$7
        dw datasize(<label>_gfx)    ;graphics size                  ;$9
        dw datasize(<label>_map)    ;tilemap size                   ;$b
        dw properties_<label>       ;gameplay properties            ;$d; in scenedef
        dw hdmalist_<label>         ;list of hdma objects to spawn  ;$f
        dw glowlist_<label>         ;list of glow objects to spawn  ;$11
        dw bgdata_<label>           ;                               ;$13
        db !layer_blend_default     ;one byte, index for main.asm   ;$15
    endmacro
    
    ;run superfamiconv to output every scene using at most the bottom 7 palettes
    ;of bg palette area. reserve top 16 colors for bg3!
    ;the routine load_romtocolorbuffer will start at the second palette
    
;===========================================================================================
;======================================== scene definitions ================================
;===========================================================================================

;contains common data for nongameplay, dialogue scenes; and gameplay rooms

    
;====================================== intro scenes =======================================
    .intro1:
        dl intro1                           ;long pointer to the scene data ;$0
        dw intro1_pal                       ;inbank pointer to palette,     ;$3
        dw intro1_gfx                       ;graphics,                      ;$5
        dw intro1_map                       ;tilemap                        ;$7
        dw datasize(intro1_gfx)             ;graphics size                  ;$9
        dw datasize(intro1_map)             ;tilemap size                   ;$b
        dw properties_intro1                ;gameplay properties            ;$d; in scenedef
        dw $0000                            ;list of hdma objects to spawn  ;$f
        dw glowlist_intro1                  ;list of glow objects to spawn  ;$11
        dw $0000                            ;background data list           ;$13
        db !layer_blend_intro               ;one byte, index for handler    ;$15

;=================================== gameplay rooms ========================================
    .overworld:
        dl overworld_data                   ;long pointer to the scene data ;$0
        dw overworld_data_pal               ;inbank pointer to palette,     ;$3
        dw overworld_data_gfx               ;graphics,                      ;$5
        dw overworld_data_map               ;tilemap                        ;$7
        dw datasize(overworld_data_gfx)     ;graphics size                  ;$9
        dw datasize(overworld_data_map)     ;tilemap size                   ;$b
        dw properties_overworld             ;gameplay properties            ;$d; in scenedef
        dw $0000                            ;list of hdma objects to spawn  ;$f
        dw $0000                            ;list of glow objects to spawn  ;$11
        dw $0000                            ;background data list           ;$13
        db !layer_blend_default             ;one byte, index for handler    ;$15


    .room1:             ;%scenedefentry(room1)
        dl room1                            ;long pointer to the scene data ;$0
        dw room1_pal                        ;inbank pointer to palette,     ;$3
        dw room1_gfx                        ;graphics,                      ;$5
        dw room1_map                        ;tilemap                        ;$7
        dw datasize(room1_gfx)              ;graphics size                  ;$9
        dw datasize(room1_map)              ;tilemap size                   ;$b
        dw properties_room1                 ;gameplay properties            ;$d; in scenedef
        dw $0000                            ;list of hdma objects to spawn  ;$f
        dw glowlist_gameplaydefault         ;list of glow objects to spawn  ;$11
        dw bgdata_room1                     ;background data list           ;$13
        db !layer_blend_default_withbg2m    ;one byte, index for handler    ;$15



}

;===========================================================================================
;==================================== scene properties =====================================
;===========================================================================================

properties: {
    ;contains separate sections for the properites that differ
    ;among gameplay and nongameplay scenes
    
    
; ============================ dialogue scenes (nongameplay) ===============================
    
    .intro1: {                 ;intro 1
        dw !state_loadintroscene    ;program state to enter
        dw str_intro1               ;text string pointer
        db $08                      ;starting line for text
        dw $0000                    ;init routine
        dw str_credits              ;scrolling text commands (ptr to strings.asm)
    }

; ===================================== gameplay ===========================================
; ===================================== rooms ==============================================

    .room1: {                           ;description                ;number of bytes in
        dw !state_loadgame              ;program mode to use        ;0
        dw $0001, $0001                 ;starting camera position   ;2,4
        dw $0028, $0058                 ;starting player position   ;6,8
        dw objlist_room1                ;object list pointer        ;a
        dw collisionmap_room1           ;                           ;c
        dw faelist_room1                ;list of fae for the room   ;e
        dw str_hudstring_room1          ;string to print on hud     ;$10
    }
    
    .overworld: {
        dw !state_setupoverworld        ;program mode to use        ;0
        dw $0001, $0001                 ;starting camera position   ;2,4
        dw $0028, $0058                 ;starting player position   ;6,8
        dw objlist_overworld            ;object list pointer        ;a
        dw collisionmap_room1           ;                           ;c
        dw faelist_overworld            ;list of fae for the room   ;e
        dw str_hudstring_room1          ;string to print on hud     ;$10
    }
}


;=================================== HDMA OBJECTS LISTS ====================================
;not implemented yet

hdmalist: {
    .pieces: {                                      ;channel
        dw hdma_sinewave_indirect, $1042            ;1
        dw hdma_glitch_bands_indirect, $0f42        ;2
        dw hdma_sinewave_indirect, $0e42            ;3
        dw hdma_sinewave_indirect, $0d42            ;4
        dw $ffff                                    ;end
    }
    
    .agony: {
        dw hdma_sinewave_indirect, $1042            ;1
        dw $ffff
    }
    
    .blue: {
        dw hdma_interleaved_direct, $0f02           ;bg2 x
        dw hdma_sinewave_indirect,  $1042           ;bg2 y
        ;dw hdma_sinewave_indirect,  $0e42           ;bg1 y
        dw $ffff
    }
    
    .triangle: {
        dw hdma_interleaved_direct,     $0f02       ;bg2 x
        dw hdma_interleaved_direct,     $0d02       ;bg1 x
        
        dw hdma_sinewave_indirect,      $0e42       ;bg1 y
        dw hdma_sinewave_indirect,      $1042       ;bg2 y
        dw $ffff
    }
    
    .lobes: {
        ;dw hdma_interleaved_direct,     $0d02       ;bg1 x
        ;dw hdma_interleaved_direct,     $0e02       ;bg1 y
        
        ;dw hdma_interleaved_direct,     $0f02       ;bg2 x
        dw hdma_sinewave_indirect,      $1042       ;bg2 y
        dw $ffff
    }
}


;=================================== GLOW OBJECTS LISTS ====================================
;not implemented yet

glowlist: {
    .intro1: {
        dw glow_meetsisters
        dw $ffff
    }
    
    .gameplaydefault: {
        dw glow_animationtest
        dw $ffff
    }
}

;=================================== LAYER 2 BACKGROUND DATA ====================================

bgdata: {
    .room1:
        dl room1bg2map
        dw datasize(room1bg2map)
}