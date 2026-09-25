;===========================================================================================
;========================================= HDMA ============================================
;===========================================================================================

;hdma object:
    ;init routine   ;runs once when it is created
    ;main routine   ;runs once per frame
    ;hdma target
    ;indirect or direct
    ;table source bank
    ;(object's index in hdma system arrays)/2 is used as hdma channel
    
    ;do not use channel 0 for hdma
    ;channel 0 is reserved for regular dma
    
    ;w_hdma_params contains data to write to both $4300 and $4301
        ;ttpp
        ;p = params
        ;t = ppu target

    ;spawning an object:

        ;ldy.w #hdma_testobject_bg1x_indirect
        ;ldx #$0006     ;channel*2
        ;jsl hdma_spawn
    
    ;enabling hdma:
    
        ;lda #$0001
        ;sta w_hdma_enable

    ;disabling hdma:
    
        ;stz w_hdma_enable
        ;jsl hdma_clearall
        ;jsl hdma_clearchannels     ;needs blanking?, writes to $43xx

;because the [hdma object slot]/2 = hdma channel, and we're not using channel 0 (reserved for regular dma),
;the end of the arrays are never going to be used by an object
;so, w_hdma_timer could be considered a global timer that all objects can increase and reference
;this would ease some of the logical problem of having two instances of the same object do the exact same thing


;scenedef has lists of hdma objects to spawn for scenes (currently only implemented in nongameplay/intro scenes


;todo: move this somehwere sane
        macro indirecthdmatable(startaddr)
            !a #= 0
            while !a < $1c0
                db $01 : dw <startaddr>+!a
                !a #= !a+2
            endwhile
        endmacro






hdma: {
    .nmihandler: {
        ;look for object slots that are occupied
        ;use the object's prarmeters to configure the hdma channel
        
        ;ok we unroll this
        
        ;print "hdma start", pc
        
        macro hdmachannelconfig(channel)
            !regbitmask #= (<channel>)<<4               ;obj slot 3 = bitmask $30
                                                        ;mask onto hdma reg addr
            lda.w w_hdma_id+((<channel>)<<1)
            beq ?+++
            
            lda.w w_hdma_params+((<channel>)<<1)        ;$43x0/43x1
            sta.w $4300|!regbitmask
            
            lda.w w_hdma_bank+((<channel>)<<1)
            and.w #$00ff
            sta.w $4304|!regbitmask
            
            ;bit.w #$0040
            ;beq ?+
            
            lda.w w_hdma_bank+((<channel>)<<1)          ;if indirect
            and.w #$ff00                                ;set indirect bank (high byte)
            xba
            sta.w $4307|!regbitmask
            
            lda.w w_hdma_table+((<channel>)<<1)
            sta.w $4305|!regbitmask
            
            ;bra ?++
            
            ?+                                           ;if direct (woops this is nonsense)
            
            ;lda.w w_hdma_bank+((<channel>)<<1)
            ;and.w #$00ff
            ;sta.w $4304|!regbitmask
            
            ?++
            lda.w w_hdma_table+((<channel>)<<1)
            sta.w $4302|!regbitmask
            
            lda.w #($0100)|($0001<<(<channel>))
            ora.w w_hdma_channels
            sta.w w_hdma_channels
            
            ?+++
        endmacro
        
        lda.w w_hdma_enable
        bne .enabled
        jmp .disabled
        
        .enabled:
        
        %hdmachannelconfig(1)
        %hdmachannelconfig(2)
        %hdmachannelconfig(3)
        %hdmachannelconfig(4)
        %hdmachannelconfig(5)
        %hdmachannelconfig(6)
        %hdmachannelconfig(7)
        
        .merge:
        sep #$20
        lda w_hdma_channels
        sta $420c
        rep #$20
        
        rtl
        
        .disabled:
        lda #$0000
        bra .merge
    }
    
    
    .top: {
        ;main routine for when gameplay is happening
        ;iterate over slots
        ;run main routine for each
        phb
        
        phk
        plb
        
        ldx.w #!k_hdma_objects_count*2
        -
        
        lda w_hdma_id,x
        beq +
        
        phx
        jsr (w_hdma_routine,x)
        plx
        
        +
        dex
        dex
        bpl -
        
        plb
        rtl
    }
    
    .spawnfromlist: {
        phb
        
        lda w_scene_hdmalistptr
        beq ..return
        
        tax                                 ;x = ptr to list in scenedef
        
        pea.w bank(scenedef)<<8
        plb
        plb
        
        lda #!k_hdma_objects_count*2        ;not enough registers :D
        sta p_8
        {
            ..loop
            
            lda $0000,x
            cmp #$ffff
            beq ..returnandenable
            
            tay                             ;y = object id
            
            lda $0002,x                     ;A = hdma properties
            
            phx
            ldx p_8                         ;x = object index
            jsl hdma_spawn
            plx
            
            inx
            inx
            inx
            inx
            
            dec p_8
            dec p_8
            bne ..loop
        }
        
        ..returnandenable
        lda #$0001
        sta.l w_hdma_enable
        
        ..return:
        plb
        rtl
    }
    
    .spawn: {
        ;y = pointer to object header
        
        ;x = object index
        ;x also = hdma channel
        ;x cannot be 0
        ;x cannot be > 7
        
        ;A = properties for $43x0/43x1
        ;if A = $ffff, then use properties from hdma object definition instead
        
        phb
        
        phk
        plb
        
        cmp #!hdma_params_default
        beq .default
        
        sta w_hdma_params,x
        bra .nodefault
        
        .default:
        lda $0007,y
        sta w_hdma_params,x
        
        .nodefault:
        
        tya
        sta w_hdma_id,x         ;object id (pointer to header)
        
        lda $0000,y             ;object init routine
        sta w_hdma_init,x
        
        lda $0002,y             ;object main routine
        sta w_hdma_routine,x
        
        lda $0004,y             ;object table pointer
        sta w_hdma_table,x
        
        lda $0006,y             ;object table bank
        and #$00ff
        sep #$20
        sta w_hdma_bank,x
        rep #$20
        
        jsr (w_hdma_init,x)     ;run init routine
        
        plb
        rtl
    }
    
    
    .clearall: {
        phb
        
        phk
        plb
        
        ldx.w #!k_hdma_objects_count*2
        -
        
        jsr hdma_clear
        dex
        dex
        bpl -
        
        plb
        rtl
    }
    
    
    .clear: {
        ;x = object index
        
        stz w_hdma_id,x
        stz w_hdma_init,x
        stz w_hdma_routine,x
        stz w_hdma_timer,x
        stz w_hdma_table,x
        stz w_hdma_params,x
        stz w_hdma_bank,x
        
        rts
    }
    
    .clearchannel: {
        ;x = hdma object index
        
        ;wait... this probably isn't lining up with register addresses
        ;because obj index is *2 of hdma channel
        ;oops
        ;fix that before using this
        
        txa     ;hdma channel << 4
        asl
        asl
        asl
        asl
        tax
        
        stz $4300,x
        stz $4302,x
        stz $4304,x
        stz $4306,x
        stz $4308,x
        
        rts
    }
    
    
    .clearchannels: {
        phb
        
        phk
        plb
        
        ;stz $4300
        ;stz $4302
        ;stz $4304
        ;stz $4306
        ;stz $4308
        
        stz w_hdma_channels
        
        stz $4310
        stz $4312
        stz $4314
        stz $4316
        stz $4318
        
        stz $4320
        stz $4322
        stz $4324
        stz $4326
        stz $4328
        
        stz $4330
        stz $4332
        stz $4334
        stz $4336
        stz $4338
        
        stz $4340
        stz $4342
        stz $4344
        stz $4346
        stz $4348
        
        stz $4350
        stz $4352
        stz $4354
        stz $4356
        stz $4358
        
        stz $4360
        stz $4362
        stz $4364
        stz $4366
        stz $4368
        
        stz $4370
        stz $4372
        stz $4374
        stz $4376
        stz $4378
        
        sep #$20
        stz $420c
        rep #$20
        
        plb
        rtl
    }
    
    
    .1fsinetable: { ;0 to 31
         db $10, $10, $10, $11, $11, $11, $12, $12,
            $13, $13, $13, $14, $14, $14, $15, $15,
            $15, $16, $16, $16, $17, $17, $17, $18,
            $18, $18, $19, $19, $19, $1a, $1a, $1a,
            $1a, $1b, $1b, $1b, $1b, $1c, $1c, $1c,
            $1c, $1d, $1d, $1d, $1d, $1d, $1e, $1e,
            $1e, $1e, $1e, $1e, $1e, $1e, $1f, $1f,
            $1f, $1f, $1f, $1f, $1f, $1f, $1f, $1f,
            $1f, $1f, $1f, $1f, $1f, $1f, $1f, $1f,
            $1f, $1f, $1f, $1e, $1e, $1e, $1e, $1e,
            $1e, $1e, $1e, $1d, $1d, $1d, $1d, $1d,
            $1c, $1c, $1c, $1c, $1b, $1b, $1b, $1b,
            $1a, $1a, $1a, $1a, $19, $19, $19, $18,
            $18, $18, $17, $17, $17, $16, $16, $16,
            $15, $15, $15, $14, $14, $14, $13, $13,
            $13, $12, $12, $11, $11, $11, $10, $10,
            $10, $0f, $0f, $0e, $0e, $0e, $0d, $0d,
            $0c, $0c, $0c, $0b, $0b, $0b, $0a, $0a,
            $0a, $09, $09, $09, $08, $08, $08, $07,
            $07, $07, $06, $06, $06, $05, $05, $05,
            $05, $04, $04, $04, $04, $03, $03, $03,
            $03, $02, $02, $02, $02, $02, $01, $01,
            $01, $01, $01, $01, $01, $01, $00, $00,
            $00, $00, $00, $00, $00, $00, $00, $00,
            $00, $00, $00, $00, $00, $00, $00, $00,
            $00, $00, $00, $01, $01, $01, $01, $01,
            $01, $01, $01, $02, $02, $02, $02, $02,
            $03, $03, $03, $03, $04, $04, $04, $04,
            $05, $05, $05, $05, $06, $06, $06, $07,
            $07, $07, $08, $08, $08, $09, $09, $09,
            $0a, $0a, $0a, $0b, $0b, $0b, $0c, $0c,
            $0c, $0d, $0d, $0e, $0e, $0e, $0f, $0f
            
         db $10, $10, $10, $11, $11, $11, $12, $12,
            $13, $13, $13, $14, $14, $14, $15, $15,
            $15, $16, $16, $16, $17, $17, $17, $18,
            $18, $18, $19, $19, $19, $1a, $1a, $1a,
            $1a, $1b, $1b, $1b, $1b, $1c, $1c, $1c,
            $1c, $1d, $1d, $1d, $1d, $1d, $1e, $1e,
            $1e, $1e, $1e, $1e, $1e, $1e, $1f, $1f,
            $1f, $1f, $1f, $1f, $1f, $1f, $1f, $1f,
            $1f, $1f, $1f, $1f, $1f, $1f, $1f, $1f,
            $1f, $1f, $1f, $1e, $1e, $1e, $1e, $1e,
            $1e, $1e, $1e, $1d, $1d, $1d, $1d, $1d,
            $1c, $1c, $1c, $1c, $1b, $1b, $1b, $1b,
            $1a, $1a, $1a, $1a, $19, $19, $19, $18,
            $18, $18, $17, $17, $17, $16, $16, $16,
            $15, $15, $15, $14, $14, $14, $13, $13,
            $13, $12, $12, $11, $11, $11, $10, $10,
            $10, $0f, $0f, $0e, $0e, $0e, $0d, $0d,
            $0c, $0c, $0c, $0b, $0b, $0b, $0a, $0a,
            $0a, $09, $09, $09, $08, $08, $08, $07,
            $07, $07, $06, $06, $06, $05, $05, $05,
            $05, $04, $04, $04, $04, $03, $03, $03,
            $03, $02, $02, $02, $02, $02, $01, $01,
            $01, $01, $01, $01, $01, $01, $00, $00,
            $00, $00, $00, $00, $00, $00, $00, $00,
            $00, $00, $00, $00, $00, $00, $00, $00,
            $00, $00, $00, $01, $01, $01, $01, $01,
            $01, $01, $01, $02, $02, $02, $02, $02,
            $03, $03, $03, $03, $04, $04, $04, $04,
            $05, $05, $05, $05, $06, $06, $06, $07,
            $07, $07, $08, $08, $08, $09, $09, $09,
            $0a, $0a, $0a, $0b, $0b, $0b, $0c, $0c,
            $0c, $0d, $0d, $0e, $0e, $0e, $0f, $0f
    }
    
    .neg30sinetable: {      ;-30 to 30
     db $00, $01, $01, $02, $03, $04, $04, $05, $06, $07, $07, $08, $09, $09, $0a, $0b,
        $0b, $0c, $0d, $0d, $0e, $0f, $0f, $10, $11, $11, $12, $12, $13, $14, $14, $15,
        $15, $16, $16, $17, $17, $18, $18, $19, $19, $19, $1a, $1a, $1a, $1b, $1b, $1b,
        $1c, $1c, $1c, $1c, $1d, $1d, $1d, $1d, $1d, $1e, $1e, $1e, $1e, $1e, $1e, $1e,
        $1e, $1e, $1e, $1e, $1e, $1e, $1e, $1e, $1d, $1d, $1d, $1d, $1d, $1c, $1c, $1c,
        $1c, $1b, $1b, $1b, $1a, $1a, $1a, $19, $19, $19, $18, $18, $17, $17, $16, $16,
        $15, $15, $14, $14, $13, $12, $12, $11, $11, $10, $0f, $0f, $0e, $0d, $0d, $0c,
        $0b, $0b, $0a, $09, $09, $08, $07, $07, $06, $05, $04, $04, $03, $02, $01, $01,
        $00, -$1, -$1, -$2, -$3, -$4, -$4, -$5, -$6, -$7, -$7, -$8, -$9, -$9, -$a, -$b,
        -$b, -$c, -$d, -$d, -$e, -$f, -$f, -$10, -$11, -$11, -$12, -$12, -$13, -$14, -$14, -$15,
        -$15, -$16, -$16, -$17, -$17, -$18, -$18, -$19, -$19, -$19, -$1a, -$1a, -$1a, -$1b, -$1b, -$1b,
        -$1c, -$1c, -$1c, -$1c, -$1d, -$1d, -$1d, -$1d, -$1d, -$1e, -$1e, -$1e, -$1e, -$1e, -$1e, -$1e,
        -$1e, -$1e, -$1e, -$1e, -$1e, -$1e, -$1e, -$1e, -$1d, -$1d, -$1d, -$1d, -$1d, -$1c, -$1c, -$1c,
        -$1c, -$1b, -$1b, -$1b, -$1a, -$1a, -$1a, -$19, -$19, -$19, -$18, -$18, -$17, -$17, -$16, -$16,
        -$15, -$15, -$14, -$14, -$13, -$12, -$12, -$11, -$11, -$10, -$f, -$f, -$e, -$d, -$d, -$c,
        -$b, -$b, -$a, -$9, -$9, -$8, -$7, -$7, -$6, -$5, -$4, -$4, -$3, -$2, -$1, -$1
        
     db $00, $01, $01, $02, $03, $04, $04, $05, $06, $07, $07, $08, $09, $09, $0a, $0b,
        $0b, $0c, $0d, $0d, $0e, $0f, $0f, $10, $11, $11, $12, $12, $13, $14, $14, $15,
        $15, $16, $16, $17, $17, $18, $18, $19, $19, $19, $1a, $1a, $1a, $1b, $1b, $1b,
        $1c, $1c, $1c, $1c, $1d, $1d, $1d, $1d, $1d, $1e, $1e, $1e, $1e, $1e, $1e, $1e,
        $1e, $1e, $1e, $1e, $1e, $1e, $1e, $1e, $1d, $1d, $1d, $1d, $1d, $1c, $1c, $1c,
        $1c, $1b, $1b, $1b, $1a, $1a, $1a, $19, $19, $19, $18, $18, $17, $17, $16, $16,
        $15, $15, $14, $14, $13, $12, $12, $11, $11, $10, $0f, $0f, $0e, $0d, $0d, $0c,
        $0b, $0b, $0a, $09, $09, $08, $07, $07, $06, $05, $04, $04, $03, $02, $01, $01,
        $00, -$1, -$1, -$2, -$3, -$4, -$4, -$5, -$6, -$7, -$7, -$8, -$9, -$9, -$a, -$b,
        -$b, -$c, -$d, -$d, -$e, -$f, -$f, -$10, -$11, -$11, -$12, -$12, -$13, -$14, -$14, -$15,
        -$15, -$16, -$16, -$17, -$17, -$18, -$18, -$19, -$19, -$19, -$1a, -$1a, -$1a, -$1b, -$1b, -$1b,
        -$1c, -$1c, -$1c, -$1c, -$1d, -$1d, -$1d, -$1d, -$1d, -$1e, -$1e, -$1e, -$1e, -$1e, -$1e, -$1e,
        -$1e, -$1e, -$1e, -$1e, -$1e, -$1e, -$1e, -$1e, -$1d, -$1d, -$1d, -$1d, -$1d, -$1c, -$1c, -$1c,
        -$1c, -$1b, -$1b, -$1b, -$1a, -$1a, -$1a, -$19, -$19, -$19, -$18, -$18, -$17, -$17, -$16, -$16,
        -$15, -$15, -$14, -$14, -$13, -$12, -$12, -$11, -$11, -$10, -$f, -$f, -$e, -$d, -$d, -$c,
        -$b, -$b, -$a, -$9, -$9, -$8, -$7, -$7, -$6, -$5, -$4, -$4, -$3, -$2, -$1, -$1
        
     db $00, $01, $01, $02, $03, $04, $04, $05, $06, $07, $07, $08, $09, $09, $0a, $0b,
        $0b, $0c, $0d, $0d, $0e, $0f, $0f, $10, $11, $11, $12, $12, $13, $14, $14, $15,
        $15, $16, $16, $17, $17, $18, $18, $19, $19, $19, $1a, $1a, $1a, $1b, $1b, $1b,
        $1c, $1c, $1c, $1c, $1d, $1d, $1d, $1d, $1d, $1e, $1e, $1e, $1e, $1e, $1e, $1e,
        $1e, $1e, $1e, $1e, $1e, $1e, $1e, $1e, $1d, $1d, $1d, $1d, $1d, $1c, $1c, $1c,
        $1c, $1b, $1b, $1b, $1a, $1a, $1a, $19, $19, $19, $18, $18, $17, $17, $16, $16,
        $15, $15, $14, $14, $13, $12, $12, $11, $11, $10, $0f, $0f, $0e, $0d, $0d, $0c,
        $0b, $0b, $0a, $09, $09, $08, $07, $07, $06, $05, $04, $04, $03, $02, $01, $01,
        $00, -$1, -$1, -$2, -$3, -$4, -$4, -$5, -$6, -$7, -$7, -$8, -$9, -$9, -$a, -$b,
        -$b, -$c, -$d, -$d, -$e, -$f, -$f, -$10, -$11, -$11, -$12, -$12, -$13, -$14, -$14, -$15,
        -$15, -$16, -$16, -$17, -$17, -$18, -$18, -$19, -$19, -$19, -$1a, -$1a, -$1a, -$1b, -$1b, -$1b,
        -$1c, -$1c, -$1c, -$1c, -$1d, -$1d, -$1d, -$1d, -$1d, -$1e, -$1e, -$1e, -$1e, -$1e, -$1e, -$1e,
        -$1e, -$1e, -$1e, -$1e, -$1e, -$1e, -$1e, -$1e, -$1d, -$1d, -$1d, -$1d, -$1d, -$1c, -$1c, -$1c,
        -$1c, -$1b, -$1b, -$1b, -$1a, -$1a, -$1a, -$19, -$19, -$19, -$18, -$18, -$17, -$17, -$16, -$16,
        -$15, -$15, -$14, -$14, -$13, -$12, -$12, -$11, -$11, -$10, -$f, -$f, -$e, -$d, -$d, -$c,
        -$b, -$b, -$a, -$9, -$9, -$8, -$7, -$7, -$6, -$5, -$4, -$4, -$3, -$2, -$1, -$1
        
    }
    
    .neg30sinetabledoubled: {
     db $00, $00, $01, $01, $01, $02, $02, $03, $03, $03, $04, $04, $04, $05, $05, $05,
        $06, $06, $07, $07, $07, $08, $08, $08, $09, $09, $09, $0a, $0a, $0a, $0b, $0b,
        $0b, $0c, $0c, $0c, $0d, $0d, $0d, $0e, $0e, $0e, $0f, $0f, $0f, $10, $10, $10,
        $11, $11, $11, $12, $12, $12, $12, $13, $13, $13, $14, $14, $14, $14, $15, $15,
        $15, $15, $16, $16, $16, $16, $17, $17, $17, $17, $18, $18, $18, $18, $19, $19,
        $19, $19, $19, $1a, $1a, $1a, $1a, $1a, $1a, $1b, $1b, $1b, $1b, $1b, $1b, $1c,
        $1c, $1c, $1c, $1c, $1c, $1c, $1c, $1d, $1d, $1d, $1d, $1d, $1d, $1d, $1d, $1d,
        $1d, $1d, $1e, $1e, $1e, $1e, $1e, $1e, $1e, $1e, $1e, $1e, $1e, $1e, $1e, $1e,
        $1e, $1e, $1e, $1e, $1e, $1e, $1e, $1e, $1e, $1e, $1e, $1e, $1e, $1e, $1e, $1d,
        $1d, $1d, $1d, $1d, $1d, $1d, $1d, $1d, $1d, $1d, $1c, $1c, $1c, $1c, $1c, $1c,
        $1c, $1c, $1b, $1b, $1b, $1b, $1b, $1b, $1a, $1a, $1a, $1a, $1a, $1a, $19, $19,
        $19, $19, $19, $18, $18, $18, $18, $17, $17, $17, $17, $16, $16, $16, $16, $15,
        $15, $15, $15, $14, $14, $14, $14, $13, $13, $13, $12, $12, $12, $12, $11, $11,
        $11, $10, $10, $10, $0f, $0f, $0f, $0e, $0e, $0e, $0d, $0d, $0d, $0c, $0c, $0c,
        $0b, $0b, $0b, $0a, $0a, $0a, $09, $09, $09, $08, $08, $08, $07, $07, $07, $06,
        $06, $05, $05, $05, $04, $04, $04, $03, $03, $03, $02, $02, $01, $01, $01, $00,
        $00, $00, -$1, -$1, -$1, -$2, -$2, -$3, -$3, -$3, -$4, -$4, -$4, -$5, -$5, -$5,
        -$6, -$6, -$7, -$7, -$7, -$8, -$8, -$8, -$9, -$9, -$9, -$a, -$a, -$a, -$b, -$b,
        -$b, -$c, -$c, -$c, -$d, -$d, -$d, -$e, -$e, -$e, -$f, -$f, -$f, -$10, -$10, -$10,
        -$11, -$11, -$11, -$12, -$12, -$12, -$12, -$13, -$13, -$13, -$14, -$14, -$14, -$14, -$15, -$15,
        -$15, -$15, -$16, -$16, -$16, -$16, -$17, -$17, -$17, -$17, -$18, -$18, -$18, -$18, -$19, -$19,
        -$19, -$19, -$19, -$1a, -$1a, -$1a, -$1a, -$1a, -$1a, -$1b, -$1b, -$1b, -$1b, -$1b, -$1b, -$1c,
        -$1c, -$1c, -$1c, -$1c, -$1c, -$1c, -$1c, -$1d, -$1d, -$1d, -$1d, -$1d, -$1d, -$1d, -$1d, -$1d,
        -$1d, -$1d, -$1e, -$1e, -$1e, -$1e, -$1e, -$1e, -$1e, -$1e, -$1e, -$1e, -$1e, -$1e, -$1e, -$1e,
        -$1e, -$1e, -$1e, -$1e, -$1e, -$1e, -$1e, -$1e, -$1e, -$1e, -$1e, -$1e, -$1e, -$1e, -$1e, -$1d,
        -$1d, -$1d, -$1d, -$1d, -$1d, -$1d, -$1d, -$1d, -$1d, -$1d, -$1c, -$1c, -$1c, -$1c, -$1c, -$1c,
        -$1c, -$1c, -$1b, -$1b, -$1b, -$1b, -$1b, -$1b, -$1a, -$1a, -$1a, -$1a, -$1a, -$1a, -$19, -$19,
        -$19, -$19, -$19, -$18, -$18, -$18, -$18, -$17, -$17, -$17, -$17, -$16, -$16, -$16, -$16, -$15,
        -$15, -$15, -$15, -$14, -$14, -$14, -$14, -$13, -$13, -$13, -$12, -$12, -$12, -$12, -$11, -$11,
        -$11, -$10, -$10, -$10, -$f, -$f, -$f, -$e, -$e, -$e, -$d, -$d, -$d, -$c, -$c, -$c,
        -$b, -$b, -$b, -$a, -$a, -$a, -$9, -$9, -$9, -$8, -$8, -$8, -$7, -$7, -$7, -$6,
        -$6, -$5, -$5, -$5, -$4, -$4, -$4, -$3, -$3, -$3, -$2, -$2, -$1, -$1, -$1, $00
    }
}