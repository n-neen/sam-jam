;===========================================================================================
;===========================================================================================
;======================================= RAM  LABELS =======================================
;===========================================================================================
;===========================================================================================


;the conventions is that top level ram labels are one letter

;p = pseudoregisters
;d = direct page
;w = work ram
;l = level data

org $00

p: {
    ;pseudoregisters
    
    .0   : skip 1
    .1   : skip 1
    .2   : skip 1
    .3   : skip 1
    .4   : skip 1
    .5   : skip 1
    .6   : skip 1
    .7   : skip 1
    .8   : skip 1
    .9   : skip 1
    .a   : skip 1
    .b   : skip 1
    .c   : skip 1
    .d   : skip 1
    .e   : skip 1
    .f   : skip 1
    .10  : skip 1
    .11  : skip 1
    .12  : skip 1
}

;======================================= direct page =======================================

d: {
    org $10
    
    ;todo: move ppu register buffers into here
    
    .hcounter   :   skip 2      ;these should be deprecated
    .vcounter   :   skip 2
}



;========================================= work ram ========================================
org $7e0100
w: {
    print "work ram start: ", pc
    .nmicounter             : skip 2
    .nmiflag                : skip 2
    .lagcounter             : skip 2
    
    .gameplayfadeoutstate   : skip 2
    
    ;ppu register buffers
    .screenbrightness       : skip 2
    .bg1xscroll             : skip 2
    .bg1yscroll             : skip 2
    
    .bg2xscroll             : skip 2
    .bg2yscroll             : skip 2
    
    .bg3xscroll             : skip 2
    .bg3yscroll             : skip 2
    
    .subscreenlayers        : skip 1
    .mainscreenlayers       : skip 1
    .colormathlayers        : skip 1
    .colormathlogic         : skip 1
    
    ;dma arguments
    .dmabaseaddr            : skip 2
    .dmasrcptr              : skip 2
    .dmasrcbank             : skip 2
    .dmasize                : skip 2
    
    .controller             : skip 2
    .controller2            : skip 2
    .programstate           : skip 2
    
    .prestate               : skip 2        ;not sure if using this
    .fadetimer              : skip 2
    .fadebitmask            : skip 2
    .fadenextstate          : skip 2        ;deprecated
    
    .testsceneindex         : skip 2
    
    .nmitimen               : skip 2
    
    .irq: {
        ..command           : skip 2
    }
    
    .layerblendmode         : skip 2
    
    .player: {
        print "player start ", pc
        ..x                     : skip 2
        ..subx                  : skip 2
        ..y                     : skip 2
        ..suby                  : skip 2
        
        ..prevx                 : skip 2
        ..prevsubx              : skip 2
        ..prevy                 : skip 2
        ..prevsuby              : skip 2
        
        ..nextx                 : skip 2
        ..nextsubx              : skip 2
        ..nexty                 : skip 2
        ..nextsuby              : skip 2
        
        ..keepprevlocation      : skip 2
        
        ..xspeed                : skip 2
        ..yspeed                : skip 2
        ..xsubspeed             : skip 2
        ..ysubspeed             : skip 2
        
        ..x_onscreen            : skip 2
        ..y_onscreen            : skip 2
        
        ..direction             : skip 2
        ..lastknowndirection    : skip 2
        
        ..animationtimer        : skip 2
        
        ..xsize                 : skip 2
        ..ysize                 : skip 2
        
        ..hitboxleft            : skip 2
        ..hitboxright           : skip 2
        ..hitboxtop             : skip 2
        ..hitboxbottom          : skip 2
        
        ..collisiontype         : skip 2
        ..tileindex             : skip 2
        
        ..iframes               : skip 2    ;boolean
        ..hp                    : skip 2
        ..invertpalette         : skip 2    ;boolean
        ..hurtglowcooldown      : skip 2    ;maybe this isn't needed? idk..
        
        print "player end   ", pc
    }
    
    .level: {
        ..camerax           : skip 2
        ..cameray           : skip 2
        
        ..camerasubx        : skip 2
        ..camerasuby        : skip 2
        
        ..camerastartx      : skip 2
        ..camerastarty      : skip 2
        
        ..playerstartx      : skip 2
        ..playerstarty      : skip 2
        
        ..objlist_ptr       : skip 2
        ..objlistindex      : skip 2
        ..collisionmap_ptr  : skip 2
        ..faelist_ptr       : skip 2
        
        ..hudstring_ptr     : skip 2
    }
    
    .scroll: {
        ..direction     : skip 2
        
        ..leftbound     : skip 2
        ..rightbound    : skip 2
        ..upbound       : skip 2
        ..downbound     : skip 2
        
        ..cameraspeed    : skip 2
        ;..camerayspeed   : skip 2
        
        ..camerasubspeed : skip 2
        ;..cameraysubspeed: skip 2
        
        ;todo: put other camera stuff here
    }
    
    .nextscene          : skip 2        ;scene to return to after dialog
    
    .scene: {
        ..ptr           : skip 2        ;location of scenedef in scenedef.asm
        ..definitionptr : skip 2        ;location of scene data that follows
        ..bank          : skip 2
        ..palptr        : skip 2
        ..gfxptr        : skip 2
        ..mapptr        : skip 2
        ..gfxsize       : skip 2
        ..tilemapsize   : skip 2
        ..gameprops     : skip 2        ;pointer to rom where the following was gotten
        ..mode          : skip 2        ;program mode to use for scene
        ..strptr        : skip 2
        ..strline       : skip 2
        ..timer         : skip 2
        ..init          : skip 2
        ..scrolltextptr : skip 2        ;base pointer, use w_msg_scrollptr for base ptr+index=current ptr
        ..hdmalistptr   : skip 2
        ..glowlistptr   : skip 2
        ..bg2dataptr    : skip 2
        ..layerblend    : skip 2
    }
    
    .msg: {
        ..uploadflag    :   skip 2
        ..size          :   skip 2
        ..start         :   skip 2
        ..ptr           :   skip 2
        ..index         :   skip 2
        ..waitflag      :   skip 2
        
        ..scrollsubpos  :   skip 2
        ..scrollptr     :   skip 2      ;base ptr+index
        ..scrollindex   :   skip 2
        
        ..scrollpixels  :   skip 2
    }
    
    .obj: {
        macro objarrayentry(length, name)
            !a #= 0
            
            ..<name>:
            
            while !a < <length>
                
                ..<name>_!a:
                skip 2
                
               !a #= !a+2
            endwhile
        endmacro
        ;%objarrayentry((2*!obj_count+2), id)
        
        print "obj start: ", pc
        ..id                :   skip 2*!obj_count+2
        ..xsize             :   skip 2*!obj_count+2
        ..ysize             :   skip 2*!obj_count+2
        ..init              :   skip 2*!obj_count+2
        ..main              :   skip 2*!obj_count+2
        ..touch             :   skip 2*!obj_count+2
        ..tile              :   skip 2*!obj_count+2
        ..draw              :   skip 2*!obj_count+2
        ..collisionmap      :   skip 2*!obj_count+2
        
        ..x                 :   skip 2*!obj_count+2
        ..y                 :   skip 2*!obj_count+2
        ..var1              :   skip 2*!obj_count+2
        ..var2              :   skip 2*!obj_count+2
        ..var3              :   skip 2*!obj_count+2
        
        ..screenupdates     :   skip 2  ;the first four bits control screen updates in vblank
        ..drawindex         :   skip 2  ;
        ..index             :   skip 2  ;
        ..tileindex         :   skip 2  ;
        print "obj end:   ", pc
    }
    
    .oam: {
        print "oam buffer: ", pc
        ..index         : skip 2
        ..lo_buffer     : skip 512      ;lo_buffer and hi_buffer get uploaded
        ..hi_buffer     : skip 32       ;
        ..hi_bytebuffer : skip 128      ;use these bytes to construct the real table
        ;if oam overflows it will clobber the next thing
    }
    
    .hud: {
        ;uhhh
        ;make a text buffer? 32 chars per line, 2 lines
        !hud_buffer_size    =   $0040
        ..buffer:       : skip !hud_buffer_size
        ..glow          : skip 2        ;boolean, zero or nonzero
        ..colortint:
            ...r        : skip 1        ;5 bits for $2132
            ...g        : skip 1        ;5 bits for $2132
            ...b        : skip 1        ;5 bits for $2132
    }
    
    .fae: {
        !fae_count      =   $0018
        print "fae start: ", pc
        ..id            : skip 2*!fae_count+2
        ..x             : skip 2*!fae_count+2
        ..subx          : skip 2*!fae_count+2
        ..y             : skip 2*!fae_count+2
        ..suby          : skip 2*!fae_count+2
        ..spritemapptr  : skip 2*!fae_count+2
        ..touchptr      : skip 2*!fae_count+2
        ..shotptr       : skip 2*!fae_count+2
        ..mainptr       : skip 2*!fae_count+2
        ..initptr       : skip 2*!fae_count+2
        ..xsize         : skip 2*!fae_count+2
        ..ysize         : skip 2*!fae_count+2
        ..var1          : skip 2*!fae_count+2
        ..var2          : skip 2*!fae_count+2
        ..var3          : skip 2*!fae_count+2
        print "fae end:   ", pc
    }
    
    .shot: {
        !shot_count     =   $0008
        print "shot start: ", pc
        ..globalcounter : skip 2
        ..id            : skip 2*!shot_count+2
        ..x             : skip 2*!shot_count+2
        ..y             : skip 2*!shot_count+2
        ..subx          : skip 2*!shot_count+2
        ..suby          : skip 2*!shot_count+2
        ..xspeed        : skip 2*!shot_count+2
        ..xsubspeed     : skip 2*!shot_count+2
        ..yspeed        : skip 2*!shot_count+2
        ..ysubspeed     : skip 2*!shot_count+2
        ..spritemap_ptr : skip 2*!shot_count+2
        ..xsize         : skip 2*!shot_count+2
        ..ysize         : skip 2*!shot_count+2
        ..basespeed     : skip 2*!shot_count+2
        ..mainptr       : skip 2*!shot_count+2
        ..initptr       : skip 2*!shot_count+2
        ..pal           : skip 2*!shot_count+2      ;high byte is free
        ..counter       : skip 2*!shot_count+2
        print "shot end:   ", pc
    }
    
    .speech: {
        ..spritemap_ptr     :   skip 2
        ..string_ptr        :   skip 2
        ..timer             :   skip 2
        ..string_index      :   skip 2
        ..flags             :   skip 2
    }
    
    .menu: {
        ..state             :   skip 2
        ..var1              :   skip 2      ;bg2 x subpixels on title screen
        ..var2              :   skip 2      ;bg2 y subpixels on title screen
        ..var3              :   skip 2      ;bg2 y scroll subpixel speed
    }
    
    .hdma: {                           ;w_hdma
        ;object independent
        ..channels  : skip 2
        ..enable    : skip 2

        ;object arrays
        !k_hdma_objects_count   =   $0007
        ..id        :   skip 2*!k_hdma_objects_count+2
        ..init      :   skip 2*!k_hdma_objects_count+2
        ..routine   :   skip 2*!k_hdma_objects_count+2
        ..timer     :   skip 2*!k_hdma_objects_count+2
        ..table     :   skip 2*!k_hdma_objects_count+2
        ..params    :   skip 2*!k_hdma_objects_count+2  ;for $4300 and $4301 write at once
        ..var       :   skip 2*!k_hdma_objects_count+2
        ..bank      :   skip 2*!k_hdma_objects_count+2  ;low byte = direct bank, high byte = indirect bank
    }
    
    .glow: {
        !glow_objects_count = $0007
        
        ..enable            : skip 2
        
        ..globaltimer       : skip 2
        
        ..id                : skip 2*!glow_objects_count+2
        ..init              : skip 2*!glow_objects_count+2
        ..routine           : skip 2*!glow_objects_count+2
        ..timer             : skip 2*!glow_objects_count+2
        ..timerstart        : skip 2*!glow_objects_count+2
        ..colorindex        : skip 2*!glow_objects_count+2
        ..list              : skip 2*!glow_objects_count+2
        ..liststart         : skip 2*!glow_objects_count+2
        ..colorindexstart   : skip 2*!glow_objects_count+2
    }
    
    .savedata: {
        ..room              :   skip 2
        ..playerhp          :   skip 2
    }
    
    .seambuffer             :   skip 64
    
    .overworld: {
        ..node: {
            ...ptr:         :   skip 2
            ...x:           :   skip 2
            ...y:           :   skip 2
            ...scene_target :   skip 2  ;where to go when game starts
            ...unlocked     :   skip 2  ;boolean for can we move
            ...exits        :   skip 2  ;valid directions to leave node
        }
        
        ..path: {
            ...ptr:         :   skip 2  ;one signed byte per frame for movement?
            ...timer        :   skip 2
            ...state        :   skip 2
        }
        
        ..sam: {
            ...x:           :   skip 2  ;onscreen position for sprite drawing
            ...y:           :   skip 2
            ...anim_counter :   skip 2
        }
    }
    
    .vram: {
        ;7 bytes entries
        !vram_queue_size    =   $0008
        ..queue     :   skip 7*!vram_queue_size
        ...index     :   skip 2
    }
    
    print "work ram end:   ", pc
    
    org $7e2000
    .indirecthdmatable      :   skip $1e0       ;there is some padding here that can maybe be trimmed
    .indirecthdmatable2     :   skip $1e0
    
    org $7ec000
    .cgrambuffer            :   skip !k_cgrambuffersize
    
    org $7ee000
    .msgbuffer              :   skip $800
    
    org $7ef000
    .cgblastbuffer          :   skip $80
}

org $7f0000


;decompressionbuffer overlaps level data:
;decompress graphics here, upload to vram, then decompress level data here


l: {
    .level: {
        ..screen0   :   skip $800           ;7f0000
        ..screen1   :   skip $800           ;7f0800
        ..screen2   :   skip $800           ;7f1000
        ..screen3   :   skip $800           ;7f1800
        
        ..collision :   skip $1000          ;7f2000-3000
        
    }
    .decompressionbuffer    :   skip $8000  ;7f3000-7fb000
}

;save ram
org $306000         ;$306000-$306800
s: {
    .string         :   skip 10 ;datasize(checksram_string)
    .roomptr        :   skip 2
    .playerhp       :   skip 2
    
}