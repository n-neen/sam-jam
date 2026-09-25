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

.template: {
    dw ..main
    dw ..touch
    dw ..init
    dw ..shot
    dw ..spritemap
    dw $0030    ;x size
    dw $0030    ;y size
    
    ..main: {
        ;runs once per frame
        rts
    }
    
    ..init: {
        ;runs once when the fae is spawned
        rts
    }
    
    ..touch: {
        ;runs when collision is detected
        rts
    }
    
    ..shot: {
        ;runs when shot
        ;runs repeatedly until something else happens btw
        rts
    }
    
    ..spritemap: {
        db 01
        ;  xx   yy   tt    vhrrpppt   hh 01 = extra x bit, 02 = size select
        db $00, $00, $6a, %00111101, $02
    }
}