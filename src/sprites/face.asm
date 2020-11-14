face_x dw 32 
face_y db 32
face_attr2 db 0
face_attr3 db %10000000

face_slot db 0

face_draw:
    ld a,(face_slot)
    nextreg $34,a
    
    ld hl,(face_x)
    ld a,l
    nextreg $35,a

    ld a,(face_y)
    nextreg $36,a
    
    ld a,(face_attr2)
    ld hl,(face_x)
    or h
    nextreg $37,a

    ld a,(face_attr3)
    nextreg $38,a

    ret


