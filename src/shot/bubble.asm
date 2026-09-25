;top level label is "shot"

.bubble: {
    dw $0008                        ;xsize
    dw $0008                        ;ysize
    dw $0001                        ;base speed
    dw shot_bubble_main             ;main ptr
    dw shot_common_init_basespeed   ;init ptr
    dw shot_bubble_spritemap        ;spritemap ptr
    
    ..init: {
        ;see shot/common.asm
    }
    
    ..main: {
        phy
        
        sep #$20
        {
            lda w_shot_globalcounter
            inc
            sta w_shot_globalcounter
            and #%00000010
            sta p_0
            
            lda w_shot_counter,x
            inc
            sta w_shot_counter,x
            and #%00000100
            lsr
            eor p_0
            sta w_shot_pal,x
        }
        rep #$20
        
        lda w_shot_counter,x
        bit #$0007
        beq +
        
        lda w_shot_counter,x
        and #$000e
        tay
        lda shot_bubble_spritemaplist,y
        sta w_shot_spritemap_ptr,x
        
        
        +
        ply
        rts
    }
    
    ..spritemaplist: {
        dw shot_bubble_spritemap_0,
           shot_bubble_spritemap_1,
           shot_bubble_spritemap_2,
           shot_bubble_spritemap_3,
           shot_bubble_spritemap_3,
           shot_bubble_spritemap_2,
           shot_bubble_spritemap_1,
           shot_bubble_spritemap_0
    }
    
    ..spritemap: {
        ...0
            db 01
            ;  xx   yy   tt    vhrrpppt   hh 01 = extra x bit, 02 = size select
            ;db $04, $04, $6a, %10111110, $00
            db $01, $00, $62, %00111110, $02
        ...1
            db 01
            ;  xx   yy   tt    vhrrpppt   hh 01 = extra x bit, 02 = size select
            ;db $04, $04, $6a, %01111110, $00
            db $00, $01, $60, %00111110, $02
        ...2
            db 01
            ;  xx   yy   tt    vhrrpppt   hh 01 = extra x bit, 02 = size select
            ;db $04, $04, $6a, %11111110, $00
            db $01, $01, $62, %00111110, $02
        ...3
            db 01
            ;  xx   yy   tt    vhrrpppt   hh 01 = extra x bit, 02 = size select
            ;db $04, $04, $6a, %00111110, $00
            db $00, $00, $80, %00111110, $02
    }
}
