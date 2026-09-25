;===========================================================================================
;===========================================================================================
;=================================== R O O M   D A T A =====================================
;===========================================================================================
;===========================================================================================


flamecircle: {
    .pal:   incbin "./data/pal/flame_circle.pal"
    .gfx:   incbin "./data/gfx/flame_circle.gfx"
    .map:   incbin "./data/map/flame_circle.map"
    
    .props:
        dw $ffff
}

city: {
    .pal:   incbin "./data/pal/city3.pal"
    .gfx:   incbin "./data/gfx/city3.gfx"
    .map:   incbin "./data/map/city3.map"
    
    .props:
        dw $ffff
}

bg2test:
room1bg2map:    incbin "./data/map/room1_bg2.map"
    .dummylabel:
