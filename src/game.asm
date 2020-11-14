framecounter8 db 0
framecounter16 dw 0


human_player_count db 1 ;todo: this has not been handled yet (game kinda only makes sense for one player, not many people would play 2 player for this game)




game_init:
    ; call layer2_init

    nextreg $15, %00000111 ;sprites/layers system register
    nextreg $43, %00110000 ;enhanced ula control register
    nextreg $68, %10000000 ;ula control register

    xor a ;black
    nextreg $4c,a ;tilemap transparency colour 
    nextreg $14,a; global transparency colour

    nextreg $56,14
    ld b,SPRITE_COUNT
    ld hl,$c000
    call sprites_init
    

    call init_new_turn


    ret


game_update:
    call check_keys
    ld b,11
    call WaitRasterLine

    ld a,(framecounter8)
    inc a
    ld (framecounter8),a

    ld hl,(framecounter16)
    inc hl
    ld (framecounter16),hl

    
    
    call rockpaper_update
    
    ret

game_draw:
   
    ret


