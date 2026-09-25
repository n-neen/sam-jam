;top level label is "shot"

.shield: {
    dw $0008                        ;xsize
    dw $0008                        ;ysize
    dw $0000                        ;base speed
    dw shot_shield_main             ;main ptr
    dw shot_shield_init             ;init ptr
    dw shot_shield_spritemap        ;spritemap ptr
    
    ..init: {
        lda w_player_iframes
        beq +
        
        stz w_shot_xspeed,x
        stz w_shot_yspeed,x
        stz w_shot_ysubspeed,x
        stz w_shot_xsubspeed,x
        
        rts
        
        +
        jmp shot_clear
    }
    
    ..main: {
        rts
    }
    
    ..spritemap: {
        ...0
            db 01
            ;  xx   yy   tt    vhrrpppt   hh 01 = extra x bit, 02 = size select
            db $01, $00, $87, %00111000, $02
    }
}
