FONT_START equ 14
FONT_ASCII_OFFSET equ 33


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

;INPUT:
;DE=message ptr
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