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
    

    call init_new_match


    ret


game_update:
    ld a,r ;todo: this is just here to check if it helped with the other ld a.r we actually use
    call check_keys
    
    call rockpaper_update
    
    ret

game_draw:
   
    ret


