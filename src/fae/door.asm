;top level label is "fae"

;ram reference

;w_fae_id
;w_fae_x
;w_fae_subx
;w_fae_y
;w_fae_suby
;w_fae_spritemapptr
;w_fae_touchptr
;w_fae_mainptr
;w_fae_initptr
;w_fae_shotptr
;w_fae_xsize
;w_fae_ysize
;w_fae_var1
;w_fae_var2
;w_fae_var3

.door: {
    dw ..main
    dw ..touch
    dw ..init
    dw ..shot
    dw ..spritemap
    dw $0010    ;x size
    dw $0010    ;y size
    
    ..main: {
        ;print pc
        
        phy
        phb
        
        phk
        plb
        
        lda w_nmicounter
        and #$001c
        lsr
        tay
        
        lda fae_door_spritemaplist,y
        sta w_fae_spritemapptr,x
        
        plb
        ply
        rts
    }
    
    ..init: {
        ;runs once when the fae is spawned
        rts
    }
    
    ..touch: {
        phx
        
        lda.l w_fae_var1,x          ;get scene pointer
        tax
        jsl scenetransition_long    ;populate scene area of memory
        
        lda w_scene_mode            ;transition to program state
        sta w_gameplayfadeoutstate
        
        plx
        rts
    }
    
    ..shot: {
        ;runs when shot
        ;runs repeatedly until something else happens btw
        rts
    }
    
    ..spritemaplist: {
        dw fae_door_spritemap_0     ;0
        dw fae_door_spritemap_1
        dw fae_door_spritemap_2
        dw fae_door_spritemap_3
        dw fae_door_spritemap_0     ;0
        dw fae_door_spritemap_1
        dw fae_door_spritemap_2
        dw fae_door_spritemap_3
        dw fae_door_spritemap_0     ;0
        dw fae_door_spritemap_1
        dw fae_door_spritemap_2
        dw fae_door_spritemap_3


    }
    
    ..spritemap: {
        ...0
            db 01
            ;  xx   yy   tt    vhrrpppt   hh 01 = extra x bit, 02 = size select
            db $00, $00, $a0, %00111010, $02
        ...1
            db 01
            ;  xx   yy   tt    vhrrpppt   hh 01 = extra x bit, 02 = size select
            db $00, $00, $a2, %00111010, $02
        ...2
            db 01
            ;  xx   yy   tt    vhrrpppt   hh 01 = extra x bit, 02 = size select
            db $00, $00, $a4, %00111010, $02
        ...3
            db 01
            ;  xx   yy   tt    vhrrpppt   hh 01 = extra x bit, 02 = size select
            db $00, $00, $a6, %00111010, $02
            
            ;switched palette
            
        ...4
            db 01
            ;  xx   yy   tt    vhrrpppt   hh 01 = extra x bit, 02 = size select
            db $00, $00, $a0, %00111110, $02
        ...5
            db 01
            ;  xx   yy   tt    vhrrpppt   hh 01 = extra x bit, 02 = size select
            db $00, $00, $a2, %00111110, $02
        ...6
            db 01
            ;  xx   yy   tt    vhrrpppt   hh 01 = extra x bit, 02 = size select
            db $00, $00, $a4, %00111110, $02
        ...7
            db 01
            ;  xx   yy   tt    vhrrpppt   hh 01 = extra x bit, 02 = size select
            db $00, $00, $a6, %00111110, $02
    }
}