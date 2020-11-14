; Sprite Attribute 0
;     X X X X X X X X
	
; Sprite Attribute 1
;     Y Y Y Y Y Y Y Y

; Sprite Attribute 2
;     P P P P XM YM R X8/PR

; Sprite Attribute 3
;     V E N5 N4 N3 N2 N1 N0 (NNNNN=Pattern ID)

; Sprite Attribute 4
; A. Extended Anchor Sprite
;     H N6 T X X Y Y Y8 (H=4bit, T=relatives are composite, XXYY=magnify)
; B. Relative Sprite, Composite Type
;     0 1 N6 X X Y Y PO
; C. Relative Sprite, Unified Type
;     0 1 N6 0 0 0 0 PO


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Upload spritesheet to 16K FPGA Internal Memory
;; Inputs: B=Sprite Count HL=Sprite data Ptr
;; Outputs: none
;; Destroys: A,BC,HL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
sprites_init:
	push bc
	ld a,0							
	ld bc,$303b					
	out (c),a
	pop bc
is_loop:
	push bc							
	ld bc,$005b						
	otir							
	pop bc 							
	djnz is_loop					
	ret 	