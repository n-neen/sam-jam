
errhandle: {
    ;brk, cop vector point here
    jml errhandle
}


irq: {
    rep #$30
    phb
    pha
    phx
    phy
    
    jml .setbank
    .setbank:
    
    phk
    plb
    
    lda $4211               ;acknowledge interrupt
    
    lda w_irq_command
    beq +
    
    asl
    tax
    jsr (irq_commandlist,x) ;run interrupt command
    jsr irq_settarget       ;set next interrupt target based on command.
                            ;commands should return with w_irq_command 
                            ;set to the next irq command index
    +
    rep #$30
    ply
    plx
    pla
    plb
    rti
    
    .commandlist: {
        ;irq command pointer list
        dw $0000            ;0
        dw irq_hudstart     ;1
        dw irq_hudend       ;2
        dw irq_speechstart  ;3
        dw irq_speechend    ;4
    }
    
    .enable: {
        ;notably does not cli
        
        sep #$20
        
        phk
        plb
        
        lda w_nmitimen
        ora #%00110000
        sta w_nmitimen
        sta $4200
        
        rep #$20
        rts
    }
    
    .disable: {
        ;notably does not sei
        
        sep #$20
        
        phk
        plb
        
        lda w_nmitimen
        and #%11001111
        sta w_nmitimen
        sta $4200
        
        rep #$20
        rts
    }
    
    .settarget: {
        ;sets h-dot (h) and scanline (v) targets for next interrupt
        ;based on w_irq_command
        ;it is expected that every irq will set the w_irq_command
        ;for the next irq that is desired
        
        phx
        
        lda w_irq_command
        asl
        tax
        
        lda irq_settarget_htable,x
        sta $4207
        
        lda irq_settarget_vtable,x
        sta $4209
        
        plx
        rts
        
        ..htable: {
            dw $0000    ;0 null command
            dw $00a8    ;1 hud start
            dw $00a8    ;2 hud end
            dw $00a8    ;3 speech start
            dw $00a8    ;3 speech end
        }
        
        ..vtable: {
            dw $0000                    ;0 null command
            dw !hud_first_row_y_pos-1   ;1 hud start
            dw !hud_second_row_y_pos+9  ;2 hud end
            dw $0097                    ;3 speech start
            dw $00d8                    ;3 speech end
        }
    }
    
    .hudstart: {
        ;irq command 1
        
        sep #$20
        
        lda w_hud_colortint_r
        sta $2132
        
        lda w_hud_colortint_g
        sta $2132
        
        lda w_hud_colortint_b
        sta $2132
        
        lda.b #!irq_command_hud_end
        sta w_irq_command
        
        rep #$20
        
        rts
    }
    
    
    .hudend: {
        ;irq command 2
        
        sep #$20
        
        lda #%11100000
        sta $2132
        
        lda w_speech_spritemap_ptr
        bne ..speechirq
        
        lda.b #!irq_command_hud_start
        sta w_irq_command
        
        rep #$20
        
        rts
        
        ..speechirq
        
        lda.b #!irq_command_speech_start
        sta w_irq_command
        
        rep #$20
        
        rts
    }
    
    .speechstart: {
        ;irq command 3
        
        sep #$20
        
        lda w_hud_colortint_r
        sta $2132
        
        lda w_hud_colortint_g
        sta $2132
        
        lda w_hud_colortint_b
        sta $2132
        
        lda.b #!irq_command_speech_end
        sta w_irq_command
        
        rep #$20
        
        rts
    }
    
    
    .speechend: {
        ;irq command 4
        
        sep #$20
        
        lda #%11100000
        sta $2132
        
        lda.b #!irq_command_hud_start
        sta w_irq_command
        
        rep #$20
        
        rts
    }
    
    
    ;player character cgblast line irq stuff is all deprecated
    ;and unlikely to ever be used
    ;mainly because it only ever worked properly on mesen
    ;console tests failed to work as expected
    
    
    .playerlinebuildcolorlist: {
        php
        
        pea $7e7e
        plb
        plb
        
        sep #$10
        
        lda w_nmicounter
        and #$00ff
        tax
        
        ldy #$0080
        
        {
            -
            lda.l cgblastcolors,x
            sta.w w_cgblastbuffer,y
            
            dex
            dex
            dey
            dey
            bpl -
        }
        
        plp
        rts
    }
    
    .setupplayerline: {
        cli
        
        lda w_player_y_onscreen
        inc
        inc
        sta $4209
        
        lda #$0040
        sta $4207
        
        sep #$20
        {
            lda w_nmitimen
            ora #%00110000      ;enable h and v for irq
            sta w_nmitimen
        }
        rep #$20
        
        ;lda #!irq_playerline
        sta w_irq_command
        
        rts
    }
    
    .updateplayerline: {
        ;huh
        
        rts
    }
    
    .playerline: {
        
        sep #$10
        
        ldx #$f0                    ;1      cgadd
        stx $2121
        
        ldx #%00000010              ;1      transfur mode: write twice
        stx $4300
        stx $4310
        
        ldx #$22                    ;1      register dest (cgram write)
        stx $4301
        stx $4311
        
        lda w_nmicounter
        asl
        and #$007e
        ora #cgblastcolors          ;2      source addr
        sta $4302
        
        lda #black
        sta $4312
        
        ldx #$c1                    ;1      source bank
        stx $4304
        
        ldx #$c1
        stx $4314
        
        lda #$0080                  ;2      transfur size
        sta $4305
        
        lda #$0002
        sta $4315
        
        ldx #$03                    ;1      enable transfur on dma channels 0+1
        stx $420b
        
        rep #$10
        
        rts
    }
}


;===========================================================================================
;===================================                   =====================================
;===================================    N    M    I    =====================================
;===================================                   =====================================
;===========================================================================================


nmi: {
    rep #$30
    phb
    pha
    phx
    phy
    
    phk
    plb
    
    jml .setbank
    .setbank:
    
    sep #$10
    {
        ldx $4210
        ldx w_nmiflag
    }
    rep #$10
    beq .lag
    
    ;nmi stuf goez here
    
    jsr colorbufferupload
    jsr nmippuregisters
    jsl oam_uploadbuffer
    jsl load_updatelevelscreen
    jsl hdma_nmihandler
    ;jsl scroll_seam_main                   ;uncomment to test loading seam
    
    lda w_msg_uploadflag
    beq +
    jsr bg3upload
    +
    
    jsr readcontroller
    
    stz w_nmiflag
    
    .return
    ply
    plx
    pla
    plb
    inc w_nmicounter
    rti
    
    .lag
    inc w_lagcounter
    bra .return
}


bg3upload: {
    jsl msg_upload
    stz w_msg_uploadflag
    rts
}


vramqueue: {
    .handle: {
        ;unimplemented, unfinished
        
        
        ;7 byte entries
        ;dddd, ssss, 4321c0
        ;dest  size  long ptr to source
        
        ;still need routines for adding entries amd deleting them
        
        lda w_vram_queue_index
        ;this is the index of the /next/ entry so need to back up one entry
        beq +
        
        -
        sec
        sbc #$0007
        beq +
        
        tax
        -
        lda $00,x
        sta w_dmabaseaddr
        
        lda $02,x
        sta w_dmasize
        
        lda $04,x
        sta w_dmasrcptr
        
        lda $06,x
        and #$00ff
        sta w_dmasrcbank
        
        jsl dma_vramtransfur
        
        lda w_vram_queue_index
        sec
        sbc #$0007
        bne -
        beq +
        
        bra -
        
        +
        rts
    }
    
    .add: {
        ;arguments:
        ;a   = size
        ;x   = vram destination
        ;p_0 = long pointer to data
        
        ;todo
        
        clc
        adc #$0007
        rtl
    }
    
    .clear: {
        ldx #!vram_queue_size*7
        
        stz w_vram_queue_index
        
        -
        stz w_vram_queue,x
        dex
        dex
        bpl -
        
        rtl
    }
}


nmippuregisters: {
    sep #$20
    {
        lda w_nmitimen
        sta $4200
        
        lda w_screenbrightness      ;update inidisp
        sta $2100
        
        lda w_bg1xscroll
        sta $210d
        lda w_bg1xscroll+1
        sta $210d
        
        lda w_bg1yscroll
        sta $210e
        lda w_bg1yscroll+1
        sta $210e
        
        lda w_bg2xscroll
        sta $210f
        lda w_bg2xscroll+1
        sta $210f
        
        lda w_bg2yscroll
        sta $2110
        lda w_bg2yscroll+1
        sta $2110
        
        lda w_bg3xscroll
        sta $2111
        lda w_bg3xscroll+1
        sta $2111
        
        lda w_bg3yscroll
        sta $2112
        lda w_bg3yscroll+1
        sta $2112
        
        lda w_mainscreenlayers
        sta $212c
        
        lda w_subscreenlayers
        sta $212d
        
        lda w_colormathlayers
        sta $2131
        
        lda w_colormathlogic
        sta $2130
        
    }
    rep #$20
    
    rts
}


colorbufferupload: {
    ;inline all this and do not use the thing in dma.asm
    ;for fasterness
    
    rep #$20
    sep #$10                                ;width  register
    
    ldx #$00                                ;1      cgadd
    stx $2121
    
    ldx #$02                                ;1      transfur mode: write twice
    stx $4300
    
    ldx #$22                                ;1      register dest (cgram write)
    stx $4301
    
    lda.w #w_cgrambuffer                    ;2      source addr
    sta $4302
    
    ldx.b #((w_cgrambuffer&$ff0000)>>16)+0  ;1      source bank
    stx $4304
    
    lda.w #!k_cgrambuffersize               ;2      transfur size
    sta $4305
    
    ldx #$01                                ;1      enable transfur on dma channel 0
    stx $420b
    
    rep #$10
    
    rts
}


readcontroller: {
    php
    sep #$20
    lda w_nmitimen
    ora #$81
    ;lda #$81            ;enable controller read
    sta $4200
    waitforread:
    lda $4212
    bit #$01
    bne waitforread
    rep #$20
    
    lda $4218           ;store to wram
    sta w_controller
    
    lda $421a
    sta w_controller2
    
    plp
    rts
}

;print pc, " wait for nmi"
waitfornmi: {
    php
    sep #$20
    lda #$01
    sta w_nmiflag
    
    ;lda #$05                   ;uncomment to show cpu, sm style
    ;sta $2100
    ;jsl showcpu
    
    rep #$20
    
    .waitloop: {
        lda w_nmiflag
    } : bne .waitloop
    plp
    rts
    
    .long: {
        jsr waitfornmi
        rtl
    }
}


showcpu: {
    sep #$20
    
    lda $2137
    lda $213f
    
    lda $213c
    sta d_hcounter
    
    lda $2137
    lda $213f
    
    lda $213d
    sta d_vcounter
    
    rep #$20
    rtl
}


screenon: {         ;turn screen brightness on and disable forced blank
    pha
    sep #$20
    lda w_screenbrightness
    and #$7f
    ora #$0f
    sta $2100
    sta w_screenbrightness
    rep #$20
    pla
    rts
    
    .long: {
        jsr screenon
        rtl
    }
}


screenoff: {        ;enable forced blank
    pha
    sep #$20
    lda w_screenbrightness
    ora #$80
    sta $2100
    sta w_screenbrightness
    rep #$20
    pla
    rts
    
    .long: {
        jsr screenoff
        rtl
    }
}


enablenmi: {
    sep #$20
    
    phk
    plb
    
    lda w_nmitimen
    ora #%10000000
    sta $4200
    sta w_nmitimen
    
    rep #$20
    rts
    
    .long: {
        jsr enablenmi
        rtl
    }
}


disablenmi: {
    sep #$20
    
    phk
    plb
    
    lda w_nmitimen
    and #%01111111
    sta $4200
    sta w_nmitimen
    
    rep #$20
    rts
    
    .long: {
        jsr disablenmi
        rtl
    }
}