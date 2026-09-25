;===========================================================================================
;===================================                ========================================
;==================================   S T R I N G S   ======================================
;===================================                ========================================
;===========================================================================================
;
;types of strings:
;   hud strings
;       used to draw strings on the hud, made of sprites, no high table
;       fixed at ten characters long
;
;   scrolling text lists
;       can be called from intro scenes or nongameplay scenes
;       list contains entries of two words:
;           dw linecount, pointer_to_string
;           linecount can also include the $8000 bit to run a non-text command
;           strings can be at most 32 chars (one line), or can end a line early
;
;   other strings can be written to layer 3 from dialogue trigger objects
;   and are also included as elements of the scrolling text
;
;
;



str: {
    .hudstring: {
        ;length is currently mandated by !hud_room_string_length
        ..room1:        db "room1     "
        ..room2:        db "room2     "
        ..icecave1:     db "ice cave 1"
        ..icecave2:     db "ice cave 2"
        ..town:         db "town      "
        ..moonroom:     db "moonroom  "
    }
    
    .piecesspeech: {
        db "      x", !msg_newline
        db "      x", !msg_newline
        db "      x", !msg_newline
        db "      x", !msg_newline
        db "      x", !msg_newline
        db "      x", !msg_newline
        db "xxxxxxx", !msg_newline
        db "xxxxxxx", !msg_newline
        db !msg_end
    }
    
    .speechtest: {
        db "      hey, there are words here", !msg_newline
        db "      and down here too okay", !msg_newline
        db "      yeah but how many words", !msg_newline
        db "      can there be here exactly", !msg_newline
        db "      quite a few more i think", !msg_newline
        db "      wow look at all the words", !msg_newline
        db "now the words can be here too..", !msg_newline
        db "it's so many, let me tell you", !msg_newline
        db !msg_end
    }
    
    .credits: {
        dw $0010, str_credits_0
        dw $0014, str_credits_1
        dw $0020, str_credits_2
        dw $0024, str_credits_3
        dw $0028, str_credits_4
        dw $002c, str_credits_5
        dw $0030, str_credits_6
        dw $0034, str_credits_7
        dw $0038, str_credits_8
        dw $003c, str_credits_9
        dw $0040, str_credits_10
        dw $0044, str_credits_11
        dw $0048, str_credits_12
        dw $004c, str_credits_13
        dw $0050, str_credits_14
        dw $0054, str_credits_15
        dw $006e, str_credits_16
        dw $0070, str_credits_17
        dw $0074, str_credits_18
        dw $8001, $0000
        dw $0000
        
        ..0:  db "           ROBOT PAST", !msg_end
        ..1:  db "         a game by neen", !msg_end
        ..2:  db "the process for making this game", !msg_end
        ..3:  db "was a whirlwind of improvisation", !msg_end
        ..4:  db "  ", !msg_end
        ..5:  db "this game would not be possible", !msg_end
        ..6:  db "without the support of several", !msg_end
        ..7:  db "people, including:", !msg_end
        ..8:  db "             Cera", !msg_end
        ..9:  db "            RT-55J", !msg_end
        ..10: db "             Dagit", !msg_end
        ..11: db "            Alberto", !msg_end
        ..12: db "               *", !msg_end
        ..13: db "the people on metconst who", !msg_end
        ..14: db "taught me a lot about assembly", !msg_end
        ..15: db "               *", !msg_end
        ..16: db "            the", !msg_end
        ..17: db "                  end", !msg_end
        ..18: db " ", !msg_end
    }
    
    .scrollingintro: {
        dw $0004, str_scrollingintro_0
        dw $0008, str_scrollingintro_1
        dw $0010, str_scrollingintro_2
        dw $0020, str_scrollingintro_3
        dw $0028, str_scrollingintro_4
        dw $0000
        
        ..0:  db "     once         upon", !msg_end
        ..1:  db "           a time", !msg_end
        ..2:  db "uhhhhh there was", !msg_end
        ..3:  db "             ...", !msg_end
        ..4:  db "       a thing?", !msg_end
        
    }
    
    .scrolltest: {
        ;scrolling text commands
        ;line to appear on : pointer to string
        dw $0004, str_scrolltest_0
        dw $0010, str_scrolltest_1
        dw $0018, str_scrolltest_2
        dw $0028, str_scrolltest_3
        dw $0038, str_scrolltest_4
        dw $0040, str_scrolltest_5
        dw $0050, str_scrolltest_6
        dw $00ff, str_scrolltest_7
        dw $0123, str_scrolltest_8
        dw $0150, str_scrolltest_9
        dw $0201, str_scrolltest_10
        dw $0000  ;end
        
        ..0:  db "0 words right here", !msg_end
        ..1:  db "1 different words...   line $10", !msg_end
        ..2:  db "2 once upon a tiem   line $18", !msg_end
        ..3:  db "3 THERE WUZ A CAPITAL line $28", !msg_end
        ..4:  db "4  SENTENCE OF WORDZ  LINE $38", !msg_end
        ..5:  db "5  AND THEN UHH line $40", !msg_end
        ..6:  db "6  i needed even more line $50", !msg_end
        ..7:  db "7  because this needs line $ff", !msg_end
        ..8:  db "8  to b infinitey wordline $123", !msg_end
        ..9:  db "9  infintie words line $150", !msg_end
        ..10: db "10 ok this is end line $201", !msg_end
    }
    
    
    .scrolllobes: {
        !scrolllobes_lineinterval = 4
        dw !scrolllobes_lineinterval*1, str_scrolllobes_0
        dw !scrolllobes_lineinterval*2, str_scrolllobes_1
        dw !scrolllobes_lineinterval*3, str_scrolllobes_2
        dw !scrolllobes_lineinterval*4, str_scrolllobes_3
        dw !scrolllobes_lineinterval*5, str_scrolllobes_4
        dw !scrolllobes_lineinterval*6, str_scrolllobes_5
        dw !scrolllobes_lineinterval*7, str_scrolllobes_6
        dw $8001, glow_incrementing
        dw $0000
        
        ..0:   db "0 aaaaaaaa", !msg_end
        ..1:   db "1 bbbbbbbb", !msg_end
        ..2:   db "2 cccccccc", !msg_end
        ..3:   db "3 dddddddd", !msg_end
        ..4:   db "4 eeeeeeee", !msg_end
        ..5:   db "5 and then some dramatic line", !msg_end
        ..6:   db " ", !msg_end
    }
    
    
    .scrolltriangle: {
        !scrolltriangle_lineinterval = 2
        dw !scrolltriangle_lineinterval*1,  str_scrolltriangle_0
        dw !scrolltriangle_lineinterval*2,  str_scrolltriangle_1
        dw !scrolltriangle_lineinterval*3,  str_scrolltriangle_2
        dw !scrolltriangle_lineinterval*4,  str_scrolltriangle_3
        dw !scrolltriangle_lineinterval*5,  str_scrolltriangle_4
        dw !scrolltriangle_lineinterval*6,  str_scrolltriangle_5
        dw !scrolltriangle_lineinterval*7,  str_scrolltriangle_6
        dw !scrolltriangle_lineinterval*8,  str_scrolltriangle_7
        dw !scrolltriangle_lineinterval*9,  str_scrolltriangle_8
        dw !scrolltriangle_lineinterval*10, str_scrolltriangle_9
        dw $8001, glow_trianglemid
        dw !scrolltriangle_lineinterval*11, str_scrolltriangle_10
        dw !scrolltriangle_lineinterval*12, str_scrolltriangle_11
        dw $0000  ;end
        
        ..0:   db "0 now would be a great time", !msg_end
        ..1:   db "1 to", !msg_end
        ..2:   db "2 um", !msg_end
        ..3:   db "3 ...", !msg_end
        ..4:   db "4 a", !msg_end
        ..5:   db "5 b", !msg_end
        ..6:   db "6 c", !msg_end
        ..7:   db "7 d", !msg_end
        ..8:   db "8 e", !msg_end
        ..9:   db "9 f", !msg_end
        ..10:  db "10 spawn a color cycling object", !msg_end
        ..11:  db "11 h", !msg_end
        ..12:  db "12 i", !msg_end
        ..13:  db "13 j", !msg_end
        ..14:  db "14 k", !msg_end
    }
    
    .piecestext: {
        db !msg_end
    }
    
    .blue: {
        db !msg_end
    }
    
    .agony: {
        db "                   test1", !msg_newline
        db "                   test2", !msg_newline
        db "                   test3", !msg_newline
        db "                   test4", !msg_newline
        db "                   test5", !msg_newline
        db "                   test6", !msg_newline
        db "                   test7", !msg_newline
        db "                   test8", !msg_newline
        db "                   test9", !msg_newline
        db "                   test10", !msg_newline
        db "this line is longertest11", !msg_newline
        db "this line is longertest12", !msg_newline
        db "this line is longertest13", !msg_newline
        db "this line is longertest13", !msg_newline
        db "this line is longertest13", !msg_newline
        db "this line is longertest13", !msg_newline
        db "                   test13", !msg_newline
        db "                   test13", !msg_newline
        db "                   test13", !msg_newline
        db "                   test13", !msg_newline
        db "                   test13", !msg_newline
        db "                   test13", !msg_newline
        db "                   test13", !msg_newline
        db "                   test13", !msg_newline
        db !msg_end
    }
    
    .testtext: {
        ;used in a text trigger object
        db !msg_newline
        db !msg_newline
        db "        an act of love"
        db !msg_newline
        db !msg_newline
        db "          remains at last"
        db !msg_newline
        db !msg_newline
        db "            preserved above"
        db !msg_newline
        db !msg_newline
        db "              from robot past"
        
        db !msg_end
    }

    .text2: {
        ;used in a text trigger object
        db "text string 2"
        db !msg_newline
        db !msg_newline
        db !msg_newline
        db "this one is less cool"
        db !msg_end
    }

    .intro1: {
        db "intro text 1"
        db !msg_newline
        db !msg_newline
        db !msg_newline
        db !msg_newline
        db !msg_newline
        db !msg_newline
        db !msg_newline
        db !msg_newline
        db !msg_newline
        db !msg_newline
        db !msg_newline
        db !msg_newline
        db !msg_newline
        db "              intro text 1.1"
        db !msg_end
    }

    .intro2: {
        db "   intro text 2"
        db !msg_end
    }

    .intro3: {
        db "intro text 3 which is way longer"
        db !msg_end
    }

    .intro4: {
        db "intro text 4.0"
        db !msg_newline
        db !msg_newline
        db !msg_newline
        db !msg_newline
        db !msg_newline
        db !msg_newline
        db !msg_newline
        db !msg_newline
        db !msg_newline
        db !msg_newline
        db !msg_newline
        db !msg_newline
        db !msg_newline
        db !msg_newline
        db !msg_newline
        db !msg_newline
        db !msg_newline
        db !msg_newline
        db !msg_newline
        db "intro text 4.1"
        db !msg_end
    }

    .entrance: {
        ;used in a dialogue trigger's dialog scene in ice cave intro
        db "             within"
        db !msg_newline
        db !msg_newline
        db !msg_newline
        db "              this"
        db !msg_newline
        db !msg_newline
        db !msg_newline
        db "              cave"
        db !msg_end
    }
    
    .poem: {
        ;not used
        db "a thought occurs and brings a scream"
        db !msg_newline
        db "out in the agony of returning to me"
        db !msg_newline
        db !msg_newline
        db "the sound of your voice is a melody"
        db !msg_end
    }
    
    
    
}