;only use these for contants
;DO NOT include # in constants

!exampleconstant = $1234        ;only this
!badconstant     = #$1234       ;never this

;================================ program state constants ==================================

!state_introsetup           =   $0000
!state_introhandler         =   $0001
!state_loadintroscene       =   $0002
!state_gameplay             =   $0003
!state_loadgame             =   $0004
!state_loadnongame          =   $0005
!state_nongamehandler       =   $0006
!state_setupgameoverscreen  =   $0007
!state_handlegameoverscreen =   $0008
!state_setuptitle           =   $0009
!state_handletitlescreen    =   $000a
!state_setupoptionsmenu     =   $000b
!state_handleoptionsmenu    =   $000c

!state_setupoverworld       =   $000d
!state_overworld            =   $000e

;pre-state
;currently not used

!pre_state_none     =   $0000
!pre_state_start    =   $0001
!pre_state_out      =   $0002
!pre_state_in       =   $0003
!pre_state_done     =   $0004


;================================ constants ==================================

!fade_bitmask_default       =   $0001       ;used in main.asm
!fade_timer_default         =   $0010       ;not used

!fade_bitmask_title         =   $0003       ;used in main.asm
!fade_timer_title           =   $0020       ;not used


;================================ camera/scroll/level

!scroll_upbound_default     =   $0001       ;used in scroll.asm
!scroll_downbound_default   =   $00ff
!scroll_leftbound_default   =   $0001
!scroll_rightbound_default  =   $00ff

!camera_subspeed_default    =   $8000       ;default speed = speed.subspeed, set in main.asm
!camera_speed_default       =   $0001

!camera_box_up_bound        =   $0040       ;used in scroll.asm
!camera_box_dn_bound        =   $0090
!camera_box_lf_bound        =   $0040
!camera_box_rt_bound        =   $00b0

!collision_type_air             =   $0000   ;used in player.asm
!collision_type_preventup       =   $0001
!collision_type_preventdown     =   $0002
!collision_type_preventleft     =   $0003
!collision_type_preventright    =   $0004
!collision_type_solid           =   $0005

!collision_map_size             =   $1000

!level_width                    =   $40

!starting_room                  =   scenedef_overworld

;================================ player

!player_xsize_default           =   $0004
!player_ysize_default           =   $0004

!player_x_subvelocity           =   $0800
!player_x_velocity              =   $0000

!player_y_subvelocity           =   $0800
!player_y_velocity              =   $0000

!player_max_speed               =   0003

!player_frames_default          =   $00c0

!player_hp_default              =   $0007

!player_shot_allowed_bitmask    =   $0007       ;BIT tested with w_nmicounter
                                                            ;maybe timer is better?
!player_hurt_cooldown_default   =   $0020


;================================ oam

!oam_hi_byte_buffer_size        =   $001f*4

;================================ messagebox

!msg_newline                = $0a       ;used in messagebox.asm
!msg_end                    = $00       ;and in strings.asm
!msg_scroll_entry_length    = $03       ;in stings.asm
!scrolling_text_delay       = $0080

;================================ hud
!hud_end                    = $ff
!hud_first_row_y_pos        = $10
!hud_second_row_y_pos       = $18

!hud_row_length             = $0020
!hud_ascii_offset           = $20

!hud_room_string_length     = $0009

;================================ irq

!irq_command_hud_start      = $01
!irq_command_hud_end        = $02
!irq_command_speech_start   = $03
!irq_command_speech_end     = $04

;================================ hdma

!hdma_params_default        = $ffff

;================================ layer blending

!layer_blend_default            = $0000     ;for gameplay
!layer_blend_weird              = $0001
!layer_blend_titlescreen        = $0002
!layer_blend_intro              = $0003
!layer_blend_gameover           = $0004
!layer_blend_scene_pieces       = $0005     ;scene specific mode, has "scene" in name
!layer_blend_scene_agony        = $0006     ;scene specific mode, has "scene" in name
!layer_blend_default_withbg2m   = $0007     ;for gameplay with bg2 in main screen
!layer_blend_default_nosprites  = $0008     ;for nongameplay scenes without sprites
!layer_blend_scene_triangle     = $0009     ;scene specific mode
!layer_blend_scene_blue         = $000a     ;scene specific mode


;================================ object

!obj_count      =   $001f

!obj_list_entry_length      =   datasize(objlist_definitionstart)

!obj_flag_update_screen0    =   %0000000000000001
!obj_flag_update_screen1    =   %0000000000000010
!obj_flag_update_screen2    =   %0000000000000100
!obj_flag_update_screen3    =   %0000000000001000


;controller bit constants
!controller_b                         =       $8000
!controller_y                         =       $4000
!controller_sl                        =       $2000
!controller_st                        =       $1000
!controller_up                        =       $0800
!controller_dn                        =       $0400
!controller_lf                        =       $0200
!controller_rt                        =       $0100
!controller_a                         =       $0080
!controller_x                         =       $0040
!controller_l                         =       $0020
!controller_r                         =       $0010

!controller_no_dpad                   =       (!controller_st|!controller_sl|!controller_b|!controller_a|!controller_x|!controller_y|!controller_l|!controller_r)

;================================ fae

!fae_list_entry_length      =   datasize(faelist_definitionstart)

;================================ speech text objects

!speech_icon_anchor_x       =   $10
!speech_icon_anchor_y       =   $a8

;================================ game over menu

!gameover_menu_state_left   =   $0000
!gameover_menu_state_right  =   $0001

;================================ title menu

!title_menu_state_startgame     =   $0000
!title_menu_state_resumegame    =   $0001
!title_menu_state_options       =   $0002

;================================= module bank constants ===================================

;these are more often than not not being inlined
;at the site where needed

;!MODULEbanklong           =   (MODULE&$ff0000)
;!MODULEbankword           =   !MODULEbanklong>>8
;!MODULEbankshort          =   !MODULEbanklong>>16

!dmabanklong           =   (dma&$ff0000)
!dmabankword           =   !dmabanklong>>8
!dmabankshort          =   !dmabanklong>>16



;================================ vram address constants ===================================
;before shifting into the format needed to actually use
;with the ppu registers

!bg1tiles           =       $0000
!bg2tiles           =       $0000
!bg3tiles           =       $4000

!bg1tilemap         =       $4800       ;5000
!bg2tilemap         =       $5800       ;6000
!bg3tilemap         =       $5c00       ;6400

!spritegfx          =       $6000


;reference for how much to shift these

!bg1tileshifted     =       !bg1tiles>>12
!bg2tileshifted     =       !bg2tiles>>12
!bg3tileshifted     =       !bg3tiles>>12

!bg1tilemapshifted  =       !bg1tilemap>>10
!bg2tilemapshifted  =       !bg2tilemap>>10
!bg3tilemapshifted  =       !bg3tilemap>>10

!spritegfxshifted   =       !spritegfx>>12

;================================ cgram constants ===================================

!k_cgrambuffersize  =       $0200

;================================ sram constants ===================================
!sram_size          =       $0800



;============================== scrolling constants =================================

!k_scroll_columnsize    =   $0020
!k_scroll_rowsize       =   $0020               ;keep convention of ram labels = one letter
!k_level_bank           =   (l&$ff0000)>>16     ;label 'l' is for level, it's not a numeral '1'
