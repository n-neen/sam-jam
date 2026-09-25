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
;w_fae_xsize
;w_fae_ysize
;w_fae_var1
;w_fae_var2
;w_fae_var3

.arrow: {
    dw ..main                   ;main
    dw fae_common_giveiframes   ;touch
    dw ..init                   ;init
    dw fae_common_explode       ;shot
    dw ..spritemap              ;spritemap
    dw $0010    ;x size
    dw $0010    ;y size
    
    ..main: {
        phx
        phy
        
        txy
        
        lda w_fae_var1,x        ;var1 = fae state
        asl
        tax
        
        jsr (fae_arrow_statetable,x)
        
        ply
        plx
        rts
    }
    
    ..statetable: {
        dw fae_arrow_moveleft
        dw fae_arrow_moveright
    }
    
    ..moveleft: {
        tyx
        
        lda w_fae_x,x
        dec
        dec
        sta w_fae_x,x
        cmp #$0008
        bpl +
        
        lda #fae_arrow_spritemap_right
        sta w_fae_spritemapptr,x
        
        lda #$0001      ;state = moveright
        sta w_fae_var1,x
        
        +
        rts
    }
    
    ..moveright: {
        tyx
        
        lda w_fae_x,x
        inc
        inc
        sta w_fae_x,x
        cmp #$01f0
        bmi +
        
        lda #fae_arrow_spritemap_left
        sta w_fae_spritemapptr,x
        
        lda #$0000      ;state = moveleft
        sta w_fae_var1,x
        
        +
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
        rts
    }   
    
    ..spritemap: {
        ...left:
            db 01
            ;  xx   yy   tt    vhrrpppt   hh 01 = extra x bit, 02 = size select
            db $00, $00, $a8, %00111101, $02
            
        ...right:
            db 01   ;has h flip
            ;  xx   yy   tt    vhrrpppt   hh 01 = extra x bit, 02 = size select
            db $00, $00, $a8, %01111101, $02
    }
}