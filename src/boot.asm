
boot: {
    clc
    xce             ;enable native mode
    jml .setbank    ;set bank
    .setbank:
    
    sei             ;disable irq
    
    sep #$20
    {
        lda #$01
        sta $420d       ;enable fastrom
        
        lda #$8f
        sta $2100       ;enable forced blank
    }
    rep #$30
    
    ldx #$1fff
    txs             ;set initial stack pointer
    lda #$0000
    tcd             ;clear dp register
    
    ldy #$0000      ;lmaoooo
    ldx #$0000
    
    
    ;fall through
}

init: {

    .clear7e: {
        pea $7e7e
        plb : plb
        
        ldx #$1ffe
        
        -
        stz $0000,x
        stz $1000,x
        stz $2000,x
        stz $3000,x
        stz $4000,x
        stz $5000,x
        stz $6000,x
        stz $7000,x
        stz $8000,x
        stz $9000,x
        stz $a000,x
        stz $b000,x
        stz $c000,x
        stz $d000,x
        stz $e000,x
        
        dex : dex
        bpl -
    }

    .clear7f: {
        pea $7f7f
        plb : plb
        
        ldx #$1ffe
        
        -
        stz $0000,x
        stz $1000,x
        stz $2000,x
        stz $3000,x
        stz $4000,x
        stz $5000,x
        stz $6000,x
        stz $7000,x
        stz $8000,x
        stz $9000,x
        stz $a000,x
        stz $b000,x
        stz $c000,x
        stz $d000,x
        stz $e000,x
        
        dex : dex
        bpl -
    }
    
    .registers: {
        
        phk
        plb                 ;set db
        
        stz $4201
        stz $4203
        stz $4205
        stz $4207
        stz $4209
        stz $420b
        
        ldx #$0010          ;clear registers $2101-2182
        -
        stz $2101,x
        stz $2111,x
        stz $2121,x
        stz $2131,x
        stz $2141,x
        stz $2151,x
        stz $2161,x
        stz $2171,x
        dex : dex
        bpl -
        
    }
    
    
    .vram: {   
        ;clear vram
        jsl dma_clearvram
        jsl dma_clearcgram
        
    }
    
    .ppu: {
        sep #$20
        
        ;tile layer graphics base addresses
        
        lda.b #!bg1tileshifted|(!bg2tileshifted<<4)     ;bg1|2
        sta $210b
        
        lda.b #!bg3tileshifted                          ;bg3
        sta $210c
        
        lda.b #!spritegfxshifted>>1
        sta $2101
        
        ;tilemap base addresses
        
        lda.b #%00000011|(!bg1tilemapshifted<<2)
        sta $2107
        
        lda.b #%00000000|(!bg2tilemapshifted<<2)
        sta $2108
        
        lda.b #%00000000|(!bg3tilemapshifted<<2)        ;one screen of bg3
        sta $2109
        
        lda.b #%00001001    ;drawing mode: 1 with bg3 priority
        sta $2105
        
        lda #%00000010
        sta w_colormathlogic
        sta $2130
        
        lda #%10110001      ;color math layers: backdrop, layer 1, sprites, subtractive mode
        sta w_colormathlayers
        sta $2131
    
        lda #%00000001
        sta w_mainscreenlayers
        sta $212c
        
        lda #%00000000
        sta w_subscreenlayers
        sta $212d
        
        ;gotta set the bg scroll to -1 because of course we do
        lda #$ff
        stz $210d       ;bg1 x scroll
        stz $210d
        
        sta $210e       ;bg1 y scroll
        sta $210e
        
        stz $210f       ;bg2 x scroll
        stz $210f
        
        sta $2110       ;bg2 y scroll
        sta $2110
        
        stz $2111       ;bg3 x scroll
        stz $2111
        
        lda #$ff
        sta $2112       ;bg3 vertical scroll
        lda #$80
        sta $2112
        
        rep #$20
        
    }
    
    lda #$ffff
    sta w_bg1yscroll
    sta w_bg2yscroll
    
    lda #$00b8
    sta w_bg3yscroll
    
    stz w_bg1xscroll
    stz w_bg2xscroll
    stz w_bg3xscroll
    
    ;lda #$0000
    ;jsl $80e278
    ;jsl $80e0bd             ;sound test. no work
    
    
    ;stz w_programstate
    
    lda #!state_setuptitle
    sta w_programstate
    
    sep #$20
    {
        lda #%10110001      ;enable nmi, irq, and joypad auto-read
        sta $4200
        sta w_nmitimen
    }
    rep #$20
    
    ;check if sram is initialized, and if not, initialize it
    
    jsl checksram
    
    ;lda #$0000
    ;sep #$20
    ;jsl LoadAudioData
    ;rep #$20
    
    
    ;print pc, " decompression test"
    ;jsl decompressiontest
    ;seems to work
    
}

;fall through to main