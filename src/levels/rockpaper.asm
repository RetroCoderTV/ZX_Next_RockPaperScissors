HANDS_WIDTH equ 16*8 ;16px Magnified by 8
HANDS_HEIGHT equ 16*8 ;16px Magnified by 8

HANDS_X equ (FULLSCREEN_WIDTH/2)-(HANDS_WIDTH/2)


;states:
CHOOSING equ 0
ROCK equ 1
PAPER equ 2
SCISSORS equ 3


;players:
PLAYERS_TOP equ 0
PLAYERS_BOTTOM equ 1


;Hand sprite attributes:
PLAYER_TOP_ATTR2 equ %00001100 ;PPPPMMR8 (P=palette, M=Mirror, R=Rotate, 8=X8/msb)
player_top_attr3 db %11000000 ;VEPPPPPP (P=pattern)
PLAYER_TOP_ATTR4 equ %00011110

PLAYER_BOTTOM_ATTR2 equ %00000000
player_bottom_attr3 db %11000000 ;VEPPPPPP (P=pattern)
PLAYER_BOTTOM_ATTR4 equ %00011110


ATTR3_CHOOSING equ %11000000
ATTR3_ROCK equ %11000001
ATTR3_PAPER equ %11000010
ATTR3_SCISSORS equ %11000011


player_top_choice db CHOOSING
player_bottom_choice db CHOOSING
choices_complete db FALSE

player_top_score db 0
player_bottom_score db 0


draw_hands:
    ; BREAKPOINT
    ld a,PLAYERS_TOP
    nextreg $34,a
    
    ld a,HANDS_X ;minus 32 due to mirroring
    nextreg $35,a

    xor a
    nextreg $36,a
    
    ld a,PLAYER_TOP_ATTR2
    nextreg $37,a

    ld a,(player_top_attr3)
    nextreg $38,a

    ld a,PLAYER_TOP_ATTR4
    nextreg $39,a



    ld a,PLAYERS_BOTTOM
    nextreg $34,a
    
    ld a,HANDS_X
    nextreg $35,a

    ld a,FULLSCREEN_HEIGHT-HANDS_HEIGHT
    nextreg $36,a
    
    ld a,PLAYER_BOTTOM_ATTR2
    nextreg $37,a

    ld a,(player_bottom_attr3)
    nextreg $38,a

    ld a,PLAYER_BOTTOM_ATTR4
    nextreg $39,a

    ret
;




init_new_turn:
    ld a,ATTR3_CHOOSING
    ld (player_top_attr3),a
    ld (player_bottom_attr3),a

    ld a,CHOOSING
    ld (player_top_choice),a
    ld (player_bottom_choice),a

    xor a
    ld (choices_complete),a

    call draw_hands
    ret



rockpaper_update:

    ld a,(choices_complete)
    cp TRUE
    ret z

    ld a,(player_bottom_choice)
    cp CHOOSING
    jp z, .bottoms_turn
    call nz, .tops_turn

    ld a,(player_top_choice)
    cp CHOOSING
    ret z

    call show_result

    ret
.bottoms_turn: 
    call get_choice_bottom
    ret
.tops_turn:
    call get_choice_top

    ret



get_choice_bottom:
    ;todo: show message saying to press "R P or S" (or just create buttons)
    ld a,(keypressed_R)
    cp TRUE
    jp z, .rock
    ld a,(keypressed_P)
    cp TRUE
    jp z, .paper
    ld a,(keypressed_S)
    cp TRUE
    jp z, .scissors
    ret
.rock:
    ld a,ATTR3_ROCK
    ld (player_bottom_attr3),a
    ld a,ROCK
    ld (player_bottom_choice),a
    ret
.paper:
    ld a,ATTR3_PAPER
    ld (player_bottom_attr3),a
    ld a,PAPER
    ld (player_bottom_choice),a
    ret
.scissors:
    ld a,ATTR3_SCISSORS
    ld (player_bottom_attr3),a
    ld a,SCISSORS
    ld (player_bottom_choice),a
    ret


get_choice_top:
    ;todo: do check if this is AI or human player

    ;if AI...
.choose_random:
    ld a,r ;getRand
    and %00000011 ;3
    cp 0
    jr z, .choose_random

    ld (player_top_attr3),a
    cp ROCK
    jr z, .rock
    cp PAPER
    jr z, .paper
    cp SCISSORS
    jr z, .scissors

    ;if here its error:
    BREAKPOINT
.rock:
    ld a,ATTR3_ROCK
    ld (player_top_attr3),a
    ld a,ROCK
    ld (player_top_choice),a
    ret
.paper:
    ld a,ATTR3_PAPER
    ld (player_top_attr3),a
    ld a,PAPER
    ld (player_top_choice),a
    ret
.scissors:
    ld a,ATTR3_SCISSORS
    ld (player_top_attr3),a
    ld a,SCISSORS
    ld (player_top_choice),a
    ret




show_result:
    ld a,TRUE
    ld (choices_complete),a
    
    call draw_hands
    
    call find_winner

    ret

find_winner:
    ld a,(player_bottom_choice)
    cp ROCK
    jr z, .rock
    cp PAPER
    jr z, .paper
    cp SCISSORS
    jr z, .scissors

    ;get here, then its error
    BREAKPOINT
.rock:
    ld a,(player_top_choice)
    cp ROCK
    jr z, .ended_draw
    cp PAPER
    jr z, .top_won
    jr .bottom_won
.paper:
    ld a,(player_top_choice)
    cp ROCK
    jr z, .bottom_won
    cp PAPER
    jr z, .ended_draw
    jr .top_won
.scissors:
    ld a,(player_top_choice)
    cp ROCK
    jr z, .top_won
    cp PAPER
    jr z, .bottom_won
    jr .ended_draw
.top_won:
    ld hl,player_top_score
    inc (hl)
    jr .complete_turn
.bottom_won:
    ld hl,player_bottom_score
    inc (hl)
    jr .complete_turn
.ended_draw:
    ;todo: there will be a message saying "draw!"
.complete_turn:
    ;todo: figure out why these delays are so fast
    ld bc,0xFFFF
    call wait_plus_raster
    ld bc,0xFFFF
    call wait_plus_raster
    ld bc,0xFFFF
    call wait_plus_raster
    ld bc,0xFFFF
    call wait_plus_raster
    ld bc,0xFFFF
    call wait_plus_raster
    
    call init_new_turn
    ret

;(nb. P1 is bottom player, P2 is either AI or human)
;messages
;GO!
;P1 WIN!
;P2 WIN!
;DRAW!