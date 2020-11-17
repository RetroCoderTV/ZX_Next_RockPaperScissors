;MACROS
	MACRO BREAKPOINT 
		DW $01DD 
	ENDM

	MACRO CLIPTILES x1,y1,x2,y2
		ld a,x1
		nextreg $1b,a
		ld a,y1
		nextreg $1b,a
		ld a,x2
		nextreg $1b,a
		ld a,y2
		nextreg $1b,a

	ENDM

	MACRO CLIP_LAYER2 x1,x2,y1,y2
		ld a,x1
		nextreg $18,a
		ld a,x2
		nextreg $18,a
		ld a,y1
		nextreg $18,a
		ld a,y2
		nextreg $18,a

	ENDM


	MACRO SUB_HL_A
	neg : add hl,a
	ENDM

TotalFrames DD 0
TBBLUE_REGISTER_SELECT_P_243B equ $243b


wait50:
	ld b,50
.loop:
	push bc
	call WaitForScanlineUnderUla
	pop bc
	djnz .loop
	ret


WaitForScanlineUnderUla:
  
    ; read NextReg $1F - LSB of current raster line
        ld      bc,$243B
        ld      a,$1F
        out     (c),a       ; select NextReg $1F
        inc     b           ; BC = TBBLUE_REGISTER_ACCESS_P_253B
    ; if already at scanline 192, then wait extra whole frame (for super-fast game loops)
.cantStartAt192:
        in      a,(c)       ; read the raster line LSB
        cp      244
        jr      z,.cantStartAt192
    ; if not yet at scanline 192, wait for it ... wait for it ...
.waitLoop:
        in      a,(c)       ; read the raster line LSB
        cp      244
        jr      nz,.waitLoop
    ; and because the max scanline number is between 260..319 (depends on video mode),
    ; I don't need to read MSB. 256+192 = 448 -> such scanline is not part of any mode.
        ret







LAYER2_ACCESS_PORT	EQU 	$123B

		;----------------
		; Original code by Michael Ware adjustd to work with ZXB
		; Plot tile to layer 2 (needs to accept > 256 tiles)
		; in - hl = y/x tile coordinate (0-17, 0-31)
		; in - a = number of tile to display
		;----------------
PlotTile8:
		nextreg $56,17

		ld d,64
		ld e,a					; 11
		mul de

		ld a,%11000000 			; this points to $c000 
		or d		 			; 8
		ex de,hl				; 4			; cannot avoid an ex (de now = yx)
		ld h,a					; 4
		ld a,e
		rlca
		rlca
		rlca
		ld e,a					; 4+4+4+4+4 = 20	; mul x,8
		ld a,d
		rlca
		rlca
		rlca
		ld d,a					; 4+4+4+4+4 = 20	; mul y,8
		and 192
		or 3					; or 3 to keep layer on				; 8
		ld bc,LAYER2_ACCESS_PORT
		out (c),a      ; 21			; select bank

		ld a,d
		and 63
		ld d,a					; clear top 2 bits of y (dest) (4+4+4 = 12)
		; T96 here
		ld a,8					; 7
.plotTilesLoop2:
		push de					; 11
		ldi
		ldi
		ldi
		ldi
		ldi
		ldi
		ldi
		ldi					; 8 * 16 = 128
		
		pop de					; 11
		inc d					; 4 add 256 for next line down
		dec a					; 4
		jr nz,.plotTilesLoop2			; 12/7

		nextreg $56,14 ;$0e
		ret 



FONT_START equ 14
FONT_ASCII_OFFSET equ 33


;HL=mem address start yx
;DE=message address
display_string:
    ld a,(de)
    cp 0
    ret z
    cp ' '
    jp nz,disp_char
	inc a
disp_char:
    sub FONT_ASCII_OFFSET
    push de
    push hl
    call PlotTile8
    pop hl
    pop de

    inc de
    inc l
    jp display_string
   

display_numbers:
    ld c,-100
    call dispnums_add_offset
    ld c,-10
    call dispnums_add_offset
    ld c,-1
dispnums_add_offset:
    ld b,FONT_START
dispnums_inc:
    inc b
    add a,c
    jr c, dispnums_inc
    sub c ;actually adding (its holding minus number)
    push af
    ld a,b
    push hl
    call PlotTile8
    pop hl
    inc l
    pop af
    ret






