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

.explosion: {
    dw ..main               ;main routine
    dw ..touch              ;touch routine
    dw ..init               ;init routine
    dw ..shot               ;shot routine
    dw ..spritemap          ;spritemap
    dw $0030                ;x size
    dw $0030                ;y size
    
    ..main: {
        ;runs once per frame
        ;x = fae index
        ;w_fae_var1 = timer
        ;w_fae_var2 = spritemap index
        
        ;var1 is set to count down before we get here
        
        lda w_nmicounter
        bit #$0003
        bne +
        
        lda w_fae_var1,x
        dec
        sta w_fae_var1,x
        bpl ++
        
        jsr fae_clear
        bra +
        
        ++
        
        asl
        tay
        
        lda fae_explosion_spritemaplist,y
        sta w_fae_spritemapptr,x
        
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
        ;runs when hit by a shot
        rts
    }
    
    ..spritemaplist: {
        dw fae_explosion_spritemap_0
        dw fae_explosion_spritemap_1
        dw fae_explosion_spritemap_2
        dw fae_explosion_spritemap_3
        dw fae_explosion_spritemap_4
        dw fae_explosion_spritemap_5
        dw fae_explosion_spritemap_6
        dw fae_explosion_spritemap_7
        dw fae_explosion_spritemap_8
        dw fae_explosion_spritemap_9
        dw fae_explosion_spritemap_10
        dw fae_explosion_spritemap_11
        dw fae_explosion_spritemap_12
        dw fae_explosion_spritemap_13
        dw fae_explosion_spritemap_14
        dw fae_explosion_spritemap_15
    }
    
    ..spritemap: {
        ...0
            db 01
            ;  xx   yy   tt    vhrrpppt   hh 01 = extra x bit, 02 = size select
            db $00, $00, $64, %00111110, $02
        ...1
            db 01
            ;  xx   yy   tt    vhrrpppt   hh 01 = extra x bit, 02 = size select
            db $00, $00, $66, %00111100, $02
        ...2
            db 01
            ;  xx   yy   tt    vhrrpppt   hh 01 = extra x bit, 02 = size select
            db $00, $00, $68, %00111110, $02
        ...3
            db 01
            ;  xx   yy   tt    vhrrpppt   hh 01 = extra x bit, 02 = size select
            db $00, $00, $6a, %00111100, $02
        ...4
            db 01
            ;  xx   yy   tt    vhrrpppt   hh 01 = extra x bit, 02 = size select
            db $00, $00, $6c, %00111110, $02
        ...5
            db 01
            ;  xx   yy   tt    vhrrpppt   hh 01 = extra x bit, 02 = size select
            db $00, $00, $6e, %00111100, $02
            
        ...6
            db 03
            ;  xx   yy   tt    vhrrpppt   hh 01 = extra x bit, 02 = size select
            db $00, $00, $6d, %00111110, $02
            db $fd, $fe, $64, %00111100, $02
            db $04, $03, $64, %00111100, $02
            
        ...7
            db 03
            ;  xx   yy   tt    vhrrpppt   hh 01 = extra x bit, 02 = size select
            db $00, $00, $6c, %00111100, $02
            db $00, $fb, $6c, %00111110, $02
            db $02, $00, $6c, %00111100, $02
        ...8
            db 04
            ;  xx   yy   tt    vhrrpppt   hh 01 = extra x bit, 02 = size select
            db $00, $00, $6b, %00111110, $02
            db $fe, $02, $66, %00111100, $00
            db $05, $08, $65, %00111100, $00
            db $09, $06, $6b, %00111110, $02
        ...9
            db 05
            ;  xx   yy   tt    vhrrpppt   hh 01 = extra x bit, 02 = size select
            db $00, $00, $6a, %00111100, $02
            
            db $00, $00, $68, %00111100, $02
            db $f8, $ef, $67, %00111110, $00
            db $f5, $13, $66, %00111100, $00
            db $11, $10, $66, %00111110, $00
            db $12, $11, $64, %00111100, $00
        ...10
            db 01
            ;  xx   yy   tt    vhrrpppt   hh 01 = extra x bit, 02 = size select
            db $00, $00, $69, %00111110, $02
            db $e7, $e9, $66, %00111100, $02
            db $12, $02, $69, %00111100, $00

        ...11
            db 01
            ;  xx   yy   tt    vhrrpppt   hh 01 = extra x bit, 02 = size select
            db $00, $00, $68, %00111100, $02
        ...12
            db 01
            ;  xx   yy   tt    vhrrpppt   hh 01 = extra x bit, 02 = size select
            db $00, $00, $67, %00111110, $02
        ...13
            db 01
            ;  xx   yy   tt    vhrrpppt   hh 01 = extra x bit, 02 = size select
            db $00, $00, $66, %00111100, $02
        ...14
            db 01
            ;  xx   yy   tt    vhrrpppt   hh 01 = extra x bit, 02 = size select
            db $00, $00, $65, %00111110, $02
        ...15
            db 01
            ;  xx   yy   tt    vhrrpppt   hh 01 = extra x bit, 02 = size select
            db $00, $00, $64, %00111100, $02
    }
}