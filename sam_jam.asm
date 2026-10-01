lorom

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
        incsrc "./src/fae/overworld_sam.asm"
        
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
    
org $838000                             ;bank for scenes, dialog and room data
    incsrc "./data/inc/scenedefs.asm"
    incsrc "./data/inc/objlists.asm"
    incsrc "./data/inc/faelists.asm"
    incsrc "./data/inc/strings.asm"
    incsrc "./data/inc/scrolldata.asm"
    print "83 end: ", pc, " scenedef, obj/fae lists, strings"
    
org $848000
    incsrc "./data/inc/84.asm"
    print "84 end: ", pc, " bg3 font"
    
org $858000
    incsrc "./data/inc/85.asm"
    print "85 end: ", pc, " game over data"
    
org $868000
    incsrc "./data/inc/86.asm"
    print "86 end: ", pc, " sprite gfx"

org $878000
    incsrc "./data/inc/87.asm"
    print "87 end: ", pc, " overworld gfx, tilemap, palette, path data"
    
org $888000
    incsrc "./data/inc/88.asm"
    print "88 end: ", pc, " "

org $898000
    incsrc "./data/inc/89.asm"
    print "89 end: ", pc, " title screen 1"
    
org $8a8000
    incsrc "./data/inc/8a.asm"
    print "8a end: ", pc, " title screen 2"
    
org $8b8000
    incsrc "./data/inc/8b.asm"
    print "8b end: ", pc, " room1, its bg2"
    
org $8c8000
    incsrc "./data/inc/collision_maps.asm"
    print "8c end: ", pc, " collision maps"
    
org $8d8000
    incsrc "./data/inc/8d.asm"
    print "8d end: ", pc, " "
    
org $8e8000
    incsrc "./data/inc/8e.asm"
    print "8e end: ", pc
    
org $8f8000
    incsrc "./data/inc/8f.asm"
    print "8f end: ", pc, " "
    
    ;pad the rom
    ;checksum will not calculate correctly if we don't have a whole bank
    ;at the end of the rom
    
org $8fffff
    db $00

;===========================================================================================
;==================================               ==========================================
;==================================  H E A D E R  ==========================================
;==================================               ==========================================
;===========================================================================================


org $80ffc0                             ;game header
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