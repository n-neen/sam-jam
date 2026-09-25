.template: {
    db $02, $02             ;x, y radii
    dw ..init               ;\
    dw ..main               ; routine pointers
    dw ..touch              ;/
    dw ..draw               ;draw instruction ptr
    dw ..collisionmap       ;
    
    ;var1   
    ;var2   text starting line
    ;var3   text string pointer
    
    ..init: {
        ;
        rts
    }
    
    ..main: {
        ;
        rts
    }
    
    ..touch: {
        ;based on hitbox
        rts
    }
    
    ..draw: {
        db $01                              ;number of tiles
        db $00, $00 : dw $0000              ;x,y position; tile to draw
    }
    
    ..collisionmap: {
        db $01                      ;number of tiles
        db $00, $00, $00            ;x,y relative to object: tile collision to write
    }
}




.door: {
    ;first object written is for initiating room transitions
    ;wrote object system 4.5.26 and this along with it
    ;tested, working
    
    db $02, $02             ;x, y radii
    dw obj_door_init        ;\
    dw obj_door_main        ; routine pointers
    dw obj_door_touch       ;/
    dw obj_door_draw        ;draw instruction ptr
    dw obj_door_collisionmap
    
    ..init: {
        ;runs once when object is spawned
        
        rts
    }
    
    ..main: {
        ;runs once per frame in main gameplay
        rts
    }
    
    ..touch: {
        ;runs when player overlaps object
        phx
        
        lda w_obj_var3,x            ;get scene pointer
        tax
        jsr scenetransition         ;populate scene area of memory
        
        lda w_scene_mode            ;transition to program state
        sta w_gameplayfadeoutstate
        ;sta w_programstate          ;indicated by scene data
        
        ;jsl fadeout_long
        
        plx
        rts
    }
    
    ..draw: {
        db $04                      ;number of tiles to draw
        db $00, $00 : dw $4234      ;x,y relative to object tile; tile to draw
        db $ff, $ff : dw $8234      ;x,y relative to object tile; tile to draw
        db $00, $ff : dw $0234      ;x,y relative to object tile; tile to draw
        db $ff, $00 : dw $c234      ;x,y relative to object tile; tile to draw
        
    }
    
    ..collisionmap: {
        db $00                      ;number of tiles
    }
}

.scroll: {
    db $01, $01             ;x, y radii
    dw ..init               ;\
    dw ..main               ; routine pointers
    dw ..touch              ;/
    dw ..draw               ;draw instruction ptr
    dw ..collisionmap       ;
    
    ;var1 = pointer to scroll limits for up, down, left, right; and x,y size
    ;var2
    ;var3
    
    ;scrolldata.asm contains:
        ;camera bounds
        ;dw $0001    ;up
        ;dw $0001    ;down
        ;dw $007f    ;left
        ;dw $00ff    ;right
        
        ;db $02, $02 ;x, y size for instance of object
    
    ..init: {
        phx
        phy
        
        txy
        
        lda w_obj_var1,x
        tax
        
        lda.l (bank(scrolldata)<<16)+8,x
        
        sep #$20
        {
            sta w_obj_xsize,y
            
            xba
            
            sta w_obj_ysize,y
        }
        rep #$20
        
        ply
        plx
        rts
    }
    
    ..main: {
        ;
        rts
    }
    
    ..touch: {
        phx
        
        lda w_obj_var1,x
        tax
        
        lda.l (bank(scrolldata)<<16)+0,x
        sta w_scroll_upbound
        
        lda.l (bank(scrolldata)<<16)+2,x
        sta w_scroll_downbound
        
        lda.l (bank(scrolldata)<<16)+4,x
        sta w_scroll_leftbound
        
        lda.l (bank(scrolldata)<<16)+6,x
        sta w_scroll_rightbound
        
        plx
        rts
    }
    
    ..draw: {
        db $01
        db $00, $00 : dw $8222
    }
    
    ..collisionmap: {
        db $00                      ;number of tiles
        db $00, $00, $03            ;x,y relative to object: tile collision to write
    }
}


.solid: {
    db $01, $01             ;x, y radii
    dw ..init               ;\
    dw ..main               ; routine pointers
    dw ..touch              ;/
    dw ..draw               ;draw instruction ptr
    dw ..collisionmap
    
    ..init: {
        ;
        rts
    }
    
    ..main: {
        ;
        rts
    }
    
    ..touch: {
        rts
    }
    
    ..draw: {
        db $01
        db $00, $00 : dw $0234
    }
    
    ..collisionmap: {
        db $09                      ;number of tiles
        db $ff, $ff, $03            ;x,y relative to object: tile collision to write
        db $00, $ff, $03            ;x,y relative to object: tile collision to write
        db $01, $ff, $03            ;x,y relative to object: tile collision to write
        db $ff, $00, $03            ;x,y relative to object: tile collision to write
        db $00, $00, $03            ;x,y relative to object: tile collision to write
        db $01, $00, $03            ;x,y relative to object: tile collision to write
        db $ff, $01, $03            ;x,y relative to object: tile collision to write
        db $00, $01, $03            ;x,y relative to object: tile collision to write
        db $01, $01, $03            ;x,y relative to object: tile collision to write
    }
}


.texttrigger: {
    db $02, $02             ;x, y radii
    dw ..init               ;\
    dw ..main               ; routine pointers
    dw ..touch              ;/
    dw ..draw               ;draw instruction ptr
    dw ..collisionmap
    
    ;var1   
    ;var2   text starting line
    ;var3   text string pointer
    
    ..init: {
        rts
    }
    
    ..main: {
        rts
    }
    
    ..touch: {
        ;x = obj index
        
        phx
        
        jsl layer3on_long
        stz w_bg3yscroll
        
        lda w_obj_var2,x        ;var2 = text starting line
        tay
        lda w_obj_var3,x        ;var3 = text string pointer
        tax
        jsl msg_display         ;call message box
        
        lda #$0001
        sta w_msg_uploadflag
        
        plx
        
        jsr obj_clear           ;delete
        rts
    }
    
    ..draw: {
        db $01
        db $00, $00 : dw $0234
    }
    
    ..collisionmap: {
        db $00                      ;number of tiles
    }
}


.dialogtrigger: {
    db $02, $02             ;x, y radii
    dw ..init               ;\
    dw ..main               ; routine pointers
    dw ..touch              ;/
    dw ..draw               ;draw instruction ptr
    dw ..collisionmap
    
    ;var1   next scene after dialog
    ;var2   string pointer
    ;var3   scene pointer for dialog
    
    ..init: {
        rts
    }
    
    ..main: {
        rts
    }
    
    ..touch: {
        ;x = obj index
        phx
        phx
        
        lda w_obj_var3,x
        tax
        jsl scenetransition_long    ;populate memory for next scene
        plx
        
        lda w_obj_var2,x            ;string ptr
        sta w_scene_strptr
        
        lda w_obj_var1,x            ;next scene to go to after text is over
        sta w_nextscene
        
        ;lda #!state_loadnongame
        lda w_scene_mode            ;transition to program state
        ;sta w_programstate          ;indicated by scene data
        sta w_gameplayfadeoutstate
        
        ;jsl fadeout_long
        
        jsl msg_reset
        
        plx
        rts
    }
    
    ..draw: {
        db $03
        db $ff, $ff : dw $00ff
        db $00, $00 : dw $00ff
        db $01, $01 : dw $00ff
    }
    
    ..collisionmap: {
        db $00                      ;number of tiles
    }
}