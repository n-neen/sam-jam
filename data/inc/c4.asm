;===========================================================================================
;===========================================================================================
;=================================== R O O M   D A T A =====================================
;===========================================================================================
;===========================================================================================

overworld_data: {
    .pal:   incbin "./data/pal/overworld.pal"
    .gfx:   incbin "./data/gfx/overworld.chr"
    .map:   incbin "./data/map/overworld.map"
    
    .dummylabel
}

overworld_sprites: {
    .pal:   incbin "./data/pal/sprites/overworld_sprites.pal"
    .gfx:   incbin "./data/gfx/sprites/overworld_sprites.gfx"
    .dummylabel
}

incsrc "./data/inc/overworld_paths.asm"