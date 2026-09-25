hirom

optimize dp always
optimize address mirrors

incsrc "./src/defines.asm"
incsrc "./src/ram_labels.asm"

;===========================================================================================
;===================================               =========================================
;===================================   B A N K S   =========================================
;===================================               =========================================
;===========================================================================================



;================================= code banks =======================================

;indented incsrcs are ones which the label from the main module file carries into the
;files whose incs are indented. the top file is for the system routines, and the
;subsequent files are objects in the system.

;so currently this is for the fae, shot, and color cycling systems
;notably, the tile object system does not do this

org $808000                             ;main system bank
    incsrc "./src/boot.asm"
    incsrc "./src/main.asm"
    incsrc "./src/common.asm"
    incsrc "./src/gameover.asm"
    incsrc "./src/gameplay.asm"
    incsrc "./src/interrupts.asm"
    incsrc "./src/dma.asm"
    incsrc "./src/oam.asm"
    incsrc "./src/scroll.asm"
    incsrc "./src/loading.asm"
    incsrc "./src/player.asm"
    incsrc "./src/messagebox.asm"
    incsrc "./src/objects.asm"          ;also contains inc for obj_def.asm for individual objects
    incsrc "./src/hud.asm"
    incsrc "./src/speech.asm"
    incsrc "./src/title.asm"
    incsrc "./src/scene_init_routines.asm"
    
    incsrc "./src/shot/shot.asm"
        incsrc "./src/shot/common.asm"
        incsrc "./src/shot/bubble.asm"
        incsrc "./src/shot/shield.asm"
    
    incsrc "./src/overworld.asm"
    
    print "80 end: ", pc, " main system bank"
    
org $818000
    incsrc "./src/fae/fae.asm"
        incsrc "./src/fae/common.asm"
        incsrc "./src/fae/test.asm"
        incsrc "./src/fae/arrow.asm"
        incsrc "./src/fae/explosion.asm"
        incsrc "./src/fae/door.asm"
        
    print "81 end: ", pc, " fae code, spritemaps"
    
    
org $828000
    incsrc "./src/color_cycling/color_cycling.asm"
        incsrc "./src/color_cycling/title.asm"
        incsrc "./src/color_cycling/animationtest.asm"
        incsrc "./src/color_cycling/playerhurt.asm"
        incsrc "./src/color_cycling/incrementing_index_glow.asm"
        incsrc "./src/color_cycling/agony.asm"
        incsrc "./src/color_cycling/meetsisters_introscene.asm"
        incsrc "./src/color_cycling/blue_backdrop.asm"
        incsrc "./src/color_cycling/triangle_backdrop.asm"
        incsrc "./src/color_cycling/triangle_glow_mid.asm"
        
    incsrc "./src/hdma/hdma.asm"
        incsrc "./src/hdma/sinewave_indirect.asm"
        incsrc "./src/hdma/glitch_bands_indirect.asm"
        ;incsrc "./src/hdma/testobject_inidisp.asm"
        ;incsrc "./src/hdma/testobject_coldata.asm"
        ;incsrc "./src/hdma/screensplit.asm"
        incsrc "./src/hdma/sinewave_interleaved_indirect.asm"
        incsrc "./src/hdma/interleaved_direct.asm"
        
print "82 end: ", pc, " color cycling, hdma"
    
;================================= data banks =======================================
    
org $c00000                             ;bank for scenes, dialog and room data
    incsrc "./data/inc/scenedefs.asm"
    incsrc "./data/inc/objlists.asm"
    incsrc "./data/inc/faelists.asm"
    incsrc "./data/inc/strings.asm"
    incsrc "./data/inc/scrolldata.asm"
    print "c0 end: ", pc, " scenedef, obj/fae lists, strings"
    
org $c10000
    incsrc "./data/inc/c1.asm"
    print "c1 end: ", pc, " scene data, bg3 font"
    
org $c20000
    incsrc "./data/inc/c2.asm"
    print "c2 end: ", pc, " scene/room data"
    
org $c30000
    incsrc "./data/inc/c3.asm"
    print "c3 end: ", pc, " scene data, sprite gfx, room data"

org $c40000
    incsrc "./data/inc/c4.asm"
    print "c4 end: ", pc, " overworld gfx, tilemap, palette"
    
org $c50000
    incsrc "./data/inc/c5.asm"
    print "c5 end: ", pc, " scene data, bg2 background tilemap"
    
org $c60000
    incsrc "./data/inc/c6.asm"
    print "c6 end: ", pc, " ice cave room data"
    
org $c70000
    incsrc "./data/inc/c7.asm"
    print "c7 end: ", pc
    
org $c80000
    incsrc "./data/inc/collision_maps.asm"
    print "c8 end: ", pc, " collision maps"
    
org $c90000
    incsrc "./data/inc/c9.asm"
    print "c9 end: ", pc, " game over tilemaps, graphics, palettes"
    
org $ca0000
    incsrc "./data/inc/ca.asm"
    print "ca end: ", pc
    
org $cb0000
    incsrc "./data/inc/cb.asm"
    print "cb end: ", pc, " title screen tilemaps, graphics, palettes"
    
org $cc0000
    incsrc "./data/inc/cc.asm"
    print "cc end: ", pc
    
org $cd0000
    ;
    print "cd end: ", pc
    
org $ce0000
    ;
    print "ce end: ", pc
    
org $cf0000
    ;incsrc "./sound/example_project_test/example-project.inc"
    ;incsrc "./sound/example_project_test/example-project.asm"
    ;incbin "./sound/example_project_test/example-project.bin"
    print "cf end: ", pc
    
    
    ;pad the rom
    ;checksum will not calculate correctly if we don't have a whole bank
    ;at the end of the rom
    
org $cfffff
    db $00

;===========================================================================================
;==================================               ==========================================
;==================================  H E A D E R  ==========================================
;==================================               ==========================================
;===========================================================================================


org $c0ffc0                             ;game header
    db "robot past           "          ;cartridge name
    db $31                              ;fastrom, hirom
    db $02                              ;rom + ram + sram
    db $0a                              ;rom size = 1mb
    db $01                              ;sram size = 2kb
    db $00                              ;country code
    db $ff                              ;developer code
    db $00                              ;rom version
    dw $FFFF                            ;checksum complement
    dw $FFFF                            ;checksum
    
    ;interrupt vectors
    
    ;native mode
    dw errhandle, errhandle, errhandle, errhandle, errhandle, nmi, errhandle, irq
    
    ;emulation mode
    dw errhandle, errhandle, errhandle, errhandle, errhandle, errhandle, boot, errhandle