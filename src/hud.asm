string_space db ' ',0
string_go db 'GO!',0
GO_LENGTH equ ($-string_go)-1
string_win1 db 'P1 WIN!',0
string_win2 db 'P2 WIN!',0
WIN_LENGTH equ ($-string_win2)-1
string_draw db 'A DRAW!',0
DRAW_LENGTH equ ($-string_draw)-1

MESSAGE_X equ 16 
MESSAGE_Y equ 11
SCORE_X equ 31
P1_SCORE_Y equ 23
P2_SCORE_Y equ 0





;INPUT:
;DE=message ptr
;A=half length of string
show_message:
    ld l,a
    ld a,MESSAGE_X
    sub l
    ld l,a
    ld h,MESSAGE_Y
    call display_string
    ret


;INPUT:
;B=length
delete_message:
    push bc
    ld a,b
    and %11111110
    rrca
    ld b,a
    ld a,MESSAGE_X
    sub b
    pop bc
    ld l,a
.do_del:  
    ld h,MESSAGE_Y
    ld de, string_space
    push hl
    push de
    push bc
    call display_string
    pop bc
    pop de
    pop hl
    inc l
    djnz .do_del
    
    ret

show_scores:
    ld b,'0'
    ld a,(player_top_score)
    add a,b
    sub FONT_ASCII_OFFSET
    ld l,SCORE_X
    ld h,P2_SCORE_Y
    call PlotTile8

    ld b,'0'
    ld a,(player_bottom_score)
    add a,b
    sub FONT_ASCII_OFFSET
    ld l,SCORE_X
    ld h,P1_SCORE_Y
    call PlotTile8

    ret



clear_screen_fonts:
    ld h,0
    ld l,0
    ld a,' '+1
    sub FONT_ASCII_OFFSET
    ld b,a
.clear_line:
    push hl
    push de
    push bc
    ld a,b
    call PlotTile8
    pop bc
    pop de
    pop hl
    inc l
    ld a,l
    cp ZX48_SCREEN_WIDTH_CELLS
    jr c, .clear_line
    inc h
    ld l,0
    ld a,h
    cp ZX48_SCREEN_HEIGHT_CELLS
    jr c, .clear_line

    ret