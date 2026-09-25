sceneinit: {
    ;currently has to exist in the same bank as main.asm
    ;gets called from top level state in main.asm
    ;runs during a bunch of high level calls while setting up the
    ;program for a nongameplay scene (currently)
    ;so can probably clobber whatever it wants (except rep #$20)
    ;runs with forced blank so can dma to vram
    
    ;none in fork
}