;===========================================================================================
;===================================  LOADING ROUTINES  ====================================
;===========================================================================================

    
load: {
    .scene: {
        phb
        phx
        
        phk
        plb
        
        ;copy tilemap to buffer
        
        ;this now specifically puts layer 1 tilemap in l_level
        
        lda w_scene_bank
        sta p_2
        
        lda w_scene_mapptr          ;tilemap pointer
        sta p_0
        
        lda w_scene_tilemapsize     ;tilemap size
        jsl load_romtolevelbuffer   ;copy tilemap to level buffer
        
        ;upload buffer to vram
        
        lda w_scene_tilemapsize     ;tilemap size
        ldx #!bg1tilemap            ;destination in vram
        jsl load_levelbuffertovram  ;dma tilemap to vram
        
        ;copy graphics to buffer
        
        lda w_scene_bank            ;contains bank byte in low
        sta p_2
        
        lda w_scene_gfxptr          ;gfx pointer
        sta p_0
        
        lda w_scene_gfxsize         ;gfx size
        jsl load_romtobuffer        ;copy gfx to buffer
        
        ;upload buffer to vram
        
        lda w_scene_gfxsize         ;gfx size
        ldx #!bg1tiles              ;destination in vram
        jsl load_buffertovram       ;dma gfx to vram
        
        ;copy palette to ram buffer
            
        lda w_scene_bank
        ldx w_scene_palptr
        jsl load_romtocolorbuffer
        
        jsr enablenmi
        jsr waitfornmi
        
        plx
        plb
        rtl
    }
    
    .bg2fromscenedata: {
        phb
        phx
        phy
        
        pea.w bank(scenedef)<<8
        plb
        plb
        
        lda.l w_scene_bg2dataptr
        tax
        
        lda $0000,x         ;ptr to background tilemap
        sta p_0
        
        lda $0002,x         ;bank for same
        and #$00ff
        sta p_2
        
        lda $0003,x         ;size
        pha
        jsl load_romtobuffer
        pla
        
        ;A = tilemap size from stack, above
        ldx #!bg2tilemap            ;destination in vram
        jsl load_buffertovram       ;dma tilemap to vram
        
        plx
        ply
        plb
        rtl
    }
    
    .collisionmap: {
        ;p_0 = short pointer in collisionmap bank)
        ;print pc
        
        phb
        phx
        phy
        
        pea.w bank(collisionmap)<<8
        plb
        plb
        
        lda.l w_level_collisionmap_ptr
        sta p_0
        
        ldy #!collision_map_size
        ldx #!collision_map_size
        
        -
        lda (p_0),y
        sta l_level_collision,x
        dex
        dex
        dey
        dey
        bpl -
        
        ply
        plx
        plb
        rtl
    }
    
    
    .romtobuffer: {
        ;copy from rom to buffer
        ;eventually decompression will replace this
        
        ;arguments:
        ;p_0 = long pointer
        ;a   = size, forced to be even. max $8000
        
        ;could write a copy of this for > $8000
        ;halve size, tax, use x as half-size counter
        ;but realistically i don't think we'll need it
        ;and it would be even slower
        
        phy
        phb
        
        and #$fffe
        tay
        
        pea.w (($ff0000&l_decompressionbuffer)>>8)+0
        plb
        plb     ;db = buffer bank (7f)
        
        -
        lda [p_0],y                     ;copy from [long pointer] + y
        sta.w l_decompressionbuffer,y   ;to buffer + y
        dey
        dey
        bpl -
        
        plb
        ply
        rtl
    }
    
    .romtolevelbuffer: {
        ;copy paste from above :/
        
        ;copy from rom to buffer
        ;eventually decompression will replace this
        
        ;arguments:
        ;p_0 = long pointer
        ;a   = size, must be < $8000
        
        phy
        phb
        
        and #$7fff
        tay
        
        pea.w (($ff0000&l_level)>>8)+0
        plb
        plb     ;db = buffer bank (7f)
        
        -
        lda [p_0],y                     ;copy from [long pointer] + y
        sta.w l_level,y                 ;to buffer + y
        dey
        dey
        bpl -
        
        plb
        ply
        rtl
    }
    
    
    .buffertovram: {
        ;copy from decompression buffer to vram
        ;fixed start location, variable size
        
        ;arguments:
        ;a = size
        ;x = vram destination
        phb
        
        phk
        plb
        
        sta w_dmasize
        stx w_dmabaseaddr
        
        lda #l_decompressionbuffer
        sta w_dmasrcptr
        
        ;print pc
        lda #(($ff0000&l_decompressionbuffer)>>16)
        sta w_dmasrcbank
        
        jsl dma_vramtransfur
        
        plb
        rtl
    }
    
    
    .levelbuffertovram: {
        ;copy paste of above :/
        
        
        ;copy from decompression buffer to vram
        ;fixed start location, variable size
        
        ;arguments:
        ;a = size
        ;x = vram destination
        phb
        
        phk
        plb
        
        sta w_dmasize
        stx w_dmabaseaddr
        
        lda #l_level
        sta w_dmasrcptr
        
        ;print pc
        lda #(($ff0000&l_level)>>16)
        sta w_dmasrcbank
        
        jsl dma_vramtransfur
        
        plb
        rtl
    }
    
    
    .romtocolorbuffer: {
        ;a = palette bank (in low byte)
        ;x = palette pointer
        ;copies an entire palette to cg ram buffer
        ;skips first palette line ($20 bytes)
        
        phb
        phy
        
        stx p_0
        
        xba
        pha
        plb
        plb     ;db = palette bank
        
        ldy #$00e0
        ldx #$00e0
        
        -
        lda (p_0),y
        sta.l w_cgrambuffer+$20,x
        dex
        dex
        dey
        dey
        bpl -
        
        ply
        plb
        rtl
    }
    
    .playerpal: {
        ;copies sprite palettes only
        
        ldx #$0100
        -
        lda.l playersprite_pal,x
        sta.l w_cgrambuffer+$0100,x
        dex
        dex
        bpl -
        
        rtl
    }
    
    .playergfx: {
        lda.w #datasize(playersprite_gfx)
        sta w_dmasize
        
        lda #playersprite_gfx
        sta w_dmasrcptr
        
        lda.w #((playersprite_gfx)>>16)+0
        sta w_dmasrcbank
        
        lda #!spritegfx
        sta w_dmabaseaddr
        
        jsl dma_vramtransfur
        
        rtl
    }
    
    
    .bg3colortobuffer: {
        phb
        
        pea.w (($ff0000&bg3data)>>8)+0       ;db = bank of bg3data (palette)
        plb
        plb
        
        ldx #$0020
        
        -
        lda bg3data_pal,x
        sta w_cgrambuffer,x
        dex
        dex
        bpl -
        
        plb
        rtl
    }
    
    
    .bg3tilemapupload: {
        lda #(!bg3tilemap)
        sta w_dmabaseaddr
        
        lda.w #w_msgbuffer
        sta w_dmasrcptr
        
        lda.w #(($ff0000&w_msgbuffer)>>16)+0
        sta w_dmasrcbank
        
        lda #$0800
        sta w_dmasize
        
        jsl dma_vramtransfur
        
        rtl
    }
    
    
    .bg3tilemaptobuffer: {
        ;copy from rom to buffer
        
        phb
        phx
        
        pea.w (($ff0000&bg3data)>>8)+0
        plb
        plb
        
        ldx #$0800
        
        -
        lda bg3data_testmap,x
        sta.l w_msgbuffer,x
        dex
        dex
        bpl -
        
        plx
        plb
        rtl
    }
    
    
    .bg3tilesupload: {
        ;copy graphics from rom to vram
        
        lda #(!bg3tiles)
        sta w_dmabaseaddr
        
        lda.w #bg3data_gfx
        sta w_dmasrcptr
        
        lda.w #(($ff0000&bg3data)>>16)+0
        sta w_dmasrcbank
        
        lda #$0800
        sta w_dmasize
        
        jsl dma_vramtransfur
        
        rtl
    }
    
    
    .bg2test: {
        ;layer 2 test
        
        sep #$20
        {
            ;lda w_subscreenlayers
            ;ora #%00000010
            ;sta w_subscreenlayers
            
            lda w_mainscreenlayers
            ora #%00000010
            sta w_mainscreenlayers
            
            ;lda #%10110011
            ;sta w_colormathlayers
            
            ;lda #%00000010
            ;sta w_colormathlogic
        }
        rep #$20
        
        lda #bg2test
        sta p_0
        
        lda #bank(bg2test)
        sta p_2
        
        lda #$0800
        jsl load_romtobuffer
        
        lda #$0800                  ;tilemap size
        ldx #!bg2tilemap            ;destination in vram
        jsl load_buffertovram       ;dma tilemap to vram
        
        
        
        rtl
    }
    
    
    .updatelevelscreen: {
        ;screen 0, 1, 2 or 3
        
        lda w_obj_screenupdates
        beq ..return
        ;if bits exist, we have at least one update queued
        
        bit #!obj_flag_update_screen0
        beq +
            
        {
            lda w_obj_screenupdates
            and #(!obj_flag_update_screen0^$ffff)+0     ;remove update bit
            sta w_obj_screenupdates
            
            lda #!bg1tilemap+0
            sta w_dmabaseaddr
            
            lda #l_level_screen0
            bra ..update                                ;can only afford one update per nmi
            +
        }
        
        bit #!obj_flag_update_screen1
        beq +
        
        {
            lda w_obj_screenupdates
            and #(!obj_flag_update_screen1^$ffff)+0     ;remove update bit
            sta w_obj_screenupdates
            
            lda #!bg1tilemap+$400
            sta w_dmabaseaddr
            
            lda #l_level_screen1
            bra ..update                                ;can only afford one update per nmi
            +
        }
        
        bit #!obj_flag_update_screen2
        beq +
        
        {
            lda w_obj_screenupdates
            and #(!obj_flag_update_screen2^$ffff)+0     ;remove update bit
            sta w_obj_screenupdates
            
            lda #!bg1tilemap+$800
            sta w_dmabaseaddr
            
            lda #l_level_screen2
            bra ..update                                ;can only afford one update per nmi
            +
        }
        
        bit #!obj_flag_update_screen3
        beq +
        
        {
            lda w_obj_screenupdates
            and #(!obj_flag_update_screen3^$ffff)+0     ;remove update bit
            sta w_obj_screenupdates
            
            lda #!bg1tilemap+$c00
            sta w_dmabaseaddr
            
            lda #l_level_screen3
            ;bra ..update                               ;can only afford one update per nmi
            +
        }
        
        ..update:
        
        sta w_dmasrcptr                     ;A = buffer location from above
        
        lda #$0800
        sta w_dmasize
        
        lda.w #(l_level>>16)+0
        sta w_dmasrcbank
        
        jsl dma_vramtransfur
        
        ..return:
        rtl
    }
}


decompress: {
    ;RLE decompression
    ;format to be output by a python script i have yet to write
    
    ;p_0                    = long pointer to source (p_2 is the bank)
    ;p_4                    = counter for repeats
    ;l_decompressionbuffer  = destination
    
    ;format:
    ;ss ss = size in words (number of times to repeat)
    ;dd dd = the data to repeat s times
    ;repeat until terminator (size of $0000)
    phb
    phx
    phy
    
    pei (p_1)   ;db = source bank
    plb
    plb
    
    ldy #$fffe
    ldx #$0000
    
    .next
    
    iny
    iny
    
    lda (p_0),y                     ;read size
    beq .done
    sta p_4
    
    iny                             ;next word
    iny
    
    lda (p_0),y                     ;fill
    -
    sta.l l_decompressionbuffer,x
    inx
    inx
    dec p_4
    bne -
    bra .next
    
    .done
    ply
    plx
    plb
    rtl
}

decompressiontest: {
    lda #decompressiontestdata
    sta p_0
    
    lda #bank(decompressiontestdata)
    sta p_2
    
    jsl decompress
    
    rtl
}



decompressiontestdata: {
    .1
        dw $0008        ;repeat counter
        dw $1234        ;fill word
        
        dw $0080        
        dw $5678
        
        dw $0000        ;end
    
    .2
        dw $0800        ;repeat counter
        dw $1122
        
        dw $0000
}