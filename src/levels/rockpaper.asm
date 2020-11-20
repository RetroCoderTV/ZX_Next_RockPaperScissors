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

single_player_mode db FALSE







draw_hands:
    ld a,PLAYERS_TOP
    nextreg $34,a
    
    ld a,HANDS_X ;minus 32 due to mirroring
    nextreg $35,a

    xor a ;Y=0
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

    ld a,FULLSCREEN_HEIGHT-HANDS_HEIGHT ;Y
    nextreg $36,a
    
    ld a,PLAYER_BOTTOM_ATTR2
    nextreg $37,a

    ld a,(player_bottom_attr3)
    nextreg $38,a

    ld a,PLAYER_BOTTOM_ATTR4
    nextreg $39,a

    ret
;

init_new_match:
    call clear_screen_fonts

    xor a
    ld (player_top_score),a
    ld (player_bottom_score),a

    call init_new_turn
    ret 


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

    ld de,string_turn1
    call display_message_turn

    call show_scores

    
    ret




rockpaper_update:
    call check_keys
    
    ld a,(choices_complete)
    cp TRUE
    ret z

    ld a,(player_bottom_choice)
    cp CHOOSING
    jp z, .bottoms_turn
    

    ld a,(player_top_choice)
    cp CHOOSING
    jp z, .tops_turn

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
    ld de,string_turn2
    call display_message_turn
    
    call check_keys


    ;todo: do check if this is AI or human player
    ld a,(single_player_mode)
    cp TRUE
    jp z, .choose_random

.get_choice_top_human:
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
    ;if AI...
.choose_random:
    ld a,r ;getRand
    and %00000011 ;a<=3
    cp 0
    jr z, .choose_random

    ld (player_top_attr3),a
    cp ROCK
    jr z, .rock
    cp PAPER
    jr z, .paper
    cp SCISSORS
    jr z, .scissors

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
    ld de,string_win2
    ld a,WIN_LENGTH/2
    call show_message

    ld hl,player_top_score
    inc (hl)
    jr .complete_turn
.bottom_won:
    ld de,string_win1
    ld a,WIN_LENGTH/2
    call show_message

    ld hl,player_bottom_score
    inc (hl)
    jr .complete_turn
.ended_draw:
    ld de,string_draw
    ld a,DRAW_LENGTH/2
    call show_message
.complete_turn:
    ;todo: figure out why these delays are so fast
    call wait50

    call show_scores
    
    ld b,DRAW_LENGTH ;note if we changed the length of one string (P1 P2 DRAW) then this would need a rewrite
    call delete_message


    ld a,(player_bottom_score)
    cp 3
    jr nc, .winner_bottom

    ld a,(player_top_score)
    cp 3
    jr nc, .winner_top

    call init_new_turn
    ret
.winner_top:
    ld l,0
    ld h,0
    ld de,string_win2
    jr .fill_line
.winner_bottom:
    ld l,0
    ld h,0
    ld de,string_win1
    jr .fill_line
.fill_line:
    push hl
    push de
    push bc
    call display_string
    pop bc
    pop de
    pop hl
    ld a,l
    add a,WIN_LENGTH
    ld l,a
    cp 31-WIN_LENGTH
    jr c, .fill_line
    ld a,h
    cp ZX48_SCREEN_HEIGHT_CELLS-2
    jr nc, .begin_next_match
    inc h
    inc h

    ld l,0
    jr c, .fill_line

.begin_next_match:
    call wait50
    call wait50

    call init_new_match
    ret



