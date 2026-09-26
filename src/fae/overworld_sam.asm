.oversam: {

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

    dw ..main
    dw ..touch
    dw ..init
    dw ..shot
    dw ..spritemap
    dw $0008    ;x size
    dw $0008    ;y size
    
    ..main: {
        phy
        phx
        phb
        
        phk
        plb
        
        ;presumably:
        ;get input
        ;animate
        ;act on input
        
        ;print pc
        
        ;jsr fae_oversam_debuginput
        
        lda w_fae_var1,x                ;state
        asl
        tay
        
        lda fae_oversam_statelist,y
        sta p_0
        
        pea fae_oversam_main_return-1
        
        txy                             ;get fae index in both x and y
        jmp (p_0)
        
        ...return:
        
        plb
        plx
        ply
        rts
    }
    
    ..statelist: {
        dw fae_oversam_idle         ;0
        dw fae_oversam_moving       ;1
        dw fae_oversam_waiting      ;2
    }
    
    ..idle: {
        lda w_controller
        bit #!controller_up
        beq +
        {
            pha
            
            ;check if up is valid
            lda #!overworld_exit_up
            jsr fae_oversam_checkdir
            
            pla
        }
        +
        
        bit #!controller_dn
        beq +
        {
            pha
            
            ;check if down is valid
            lda #!overworld_exit_down
            jsr fae_oversam_checkdir
            
            pla
        }
        +
        
        bit #!controller_lf
        beq +
        {
            pha
            
            ;check if left is valid
            lda #!overworld_exit_left
            jsr fae_oversam_checkdir
            
            pla
        }
        +
        
        bit #!controller_rt
        beq +
        {
            pha
            
            ;check if right is valid
            lda #!overworld_exit_right
            jsr fae_oversam_checkdir
            
            pla
        }
        +
        
        jsr fae_oversam_locate
        
        rts
    }
    
    
    ..moving: {
        ;
        rts
    }
    
    
    ..checkdir: {
        ;A = direction to check
        phx
        phb
        
        pea.w bank(overworld)<<8
        plb
        plb
        
        asl
        asl
        sta p_2
        
        lda w_overworld_node_exits
        clc
        adc p_2
        
        tax                         ;x = pointer to overworld_node_exit
        
        lda $0000,x
        beq ...notvalid
        
        ;check if level beaten also eventually
        
        tax                         ;x = node ptr
        
        jsl overworld_loadnode      ;load noad
        
        lda #$0010
        sta w_fae_var2,y            ;counter
        
        lda #!oversam_state_waiting
        sta w_fae_var1,y            ;state = wait
        
        ...notvalid:
        plb
        plx
        rts
    }
    
    
    ..waiting: {
        lda w_fae_var2,y
        dec
        sta w_fae_var2,y
        beq ...done
        
        rts
        
        ...done:
        lda #!oversam_state_idle
        sta w_fae_var1,x
        
        rts
    }
    
    
    ..locate: {
        ;locate on node position
        
        lda w_overworld_node_x
        sta w_fae_x,x
        
        lda w_overworld_node_y
        sta w_fae_y,x
        
        rts
    }
    
    
    ..init: {
        lda #overworld_node_0
        sta w_overworld_node_ptr
        tax
        
        jsl overworld_loadnode
        jsr fae_oversam_locate
        
        rts
    }
    
    ..debuginput: {
        lda w_controller
        bit #!controller_up
        beq +
        {
            pha
            
            lda w_fae_y,x
            sec
            sbc #$0001
            sta w_fae_y,x
            sta $42
            
            pla
        }
        +
        
        
        bit #!controller_dn
        beq +
        {
            pha
            
            lda w_fae_y,x
            clc
            adc #$0001
            sta w_fae_y,x
            sta $42
            
            pla
        }
        +
        
        
        bit #!controller_lf
        beq +
        {
            pha
            
            lda w_fae_x,x
            sec
            sbc #$0001
            sta w_fae_x,x
            sta $40
            
            pla
        }
        +
        
        
        bit #!controller_rt
        beq +
        {
            pha
            
            lda w_fae_x,x
            clc
            adc #$0001
            sta w_fae_x,x
            sta $40
            
            pla
        }
        +
        
        
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
        db $00, $00, $00, %00110000, $02
    }
}
