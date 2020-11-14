
    OPT --syntax=abfw     ; recommended sub-syntax of current sjasmplus
    ; "a" - multi-arguments for instructions require double-comma, i.e. `push hl,,de,,bc`
    ;     - this helps to avoid common pitfalls like `sub a,a` becoming 2x `sub a` in default syntax
    ;     - making it single "sub a from a" and enabling non-Zilog syntax `sub a,...`
    ; "b" - whole expression parentheses are legal for memory access only
    ;     - things like "ld b,(variable)" will become errors, as there's only ld b,immediate
    ;     - for regular expression parentheses you can disambiguate `ld b,+(1+2+3)` by unary +
    ; "f" - warn about fake instructions of sjasmplus (if used by accident)
    ;     - to use them intentionally, use comment to suppress warning: `ld hl,de ; fake`
    ;     - one extra warning from this class is Z80N extension `mul`, requiring explicit argument `mul de` or `mul d,e`
    ; "w" - report warnings as errors

    org 0x8000

    DEVICE ZXSPECTRUMNEXT
	CSPECTMAP main.map


start:
	di
	ld sp,$7ffe
	nextreg $7,3 ;set Mhz mode (3=28mhz)
	call game_init	
	jp main_loop

main_loop:
	
	call game_update
	call game_draw
	
	jp main_loop




STACK_SIZE equ 20
stack_bottom ds STACK_SIZE, 0
stack_top db 0  

	include 'retrotools\constants.asm'
	include 'retrotools\tools.asm'	
	include 'retrotools\keycacher.asm'
	include 'retrotools\spritetools.asm'
	
	include 'game.asm'
	include 'levels\rockpaper.asm'
	
	include 'loadbins.asm'



	SAVENEX OPEN "main.nex", start , stack_top
    SAVENEX CORE 3, 0, 0      
    SAVENEX CFG 0, 0            
	SAVENEX AUTO
    SAVENEX CLOSE 



