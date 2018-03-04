;------------------------------------------------------------;
;		Translate 10-rich string 
;		into 16-rich
;------------------------------------------------------------;

.model tiny
.code

org 100h

Start:	
jmp Main					; Inache ne compilit

L_U_CORNER	= 160 * 8 + 10
LENGH		= 18h
HIGH		= 7h
VIDEOSEG        = 0b800h

YGOL_1		= 0c9h				; Left Up corner
YGOL_2		= 0c8h				; Left Down corner
YGOL_3		= 0bbh				; Right Up corner
YGOL_4		= 0bch				; Right Down corner
STENA		= 0bah				; Wall
POL		= 0cdh				; pol/potolok
COLOR		= 4eh				; color of all

;=================== RAMKA PRINT DECLARE ==============================
;!!	input:	many defines
;!!	exit	bx - D_R corner
;!!	destroy:	cx
;=================================================================

RamkaPrint proc					; Print ramka
		mov bx, L_U_CORNER		
		mov es:[bx], YGOL_1
		mov es:[bx+1], COLOR		; Print first ygol
		add bx, 2

		mov cx, L_U_CORNER + LENGH + LENGH 

Fir_line:	mov es:[bx], pol		; while(not sentr line)
		mov es:[bx+1], COLOR		; printf("=")
		add bx, 2			; bx = bx + 2

		cmp bx, cx
		jne Fir_line		; while end
		
		mov es:[bx], YGOL_3
		mov es:[bx+1], COLOR		

		
New_line:	add bx, 160
		mov dx, bx			; dx = end of new line
		sub bx, LENGH + LENGH		; bx = start of new line
		mov es:[bx], STENA
		mov es:[bx + 1], COLOR		; set left wall

Sentr_line:	add bx, 2
		cmp bx, dx
		jne Sentr_line
		mov es:[bx], STENA		; +---------------------+
		mov es:[bx + 1], COLOR		; | print walls		|
						; | using si position	|
		cmp bx, si			; | as end		|
		je End_line_st			; +---------------------+
		jmp New_line
			
End_line_st:	sub bx, LENGH + LENGH

		mov es:[bx], YGOL_2
		mov es:[bx + 1], COLOR
		add bx, 2

End_line:	mov es:[bx], POL
		mov es:[bx+1], COLOR
		add bx, 2
		cmp bx, si
		jne End_line

		mov es:[bx], YGOL_4
		mov es:[bx+1], COLOR		

		ret
RamkaPrint endp

;========================== PRINT DECLARE ==============================
;!!	Entry	si = offset str
;!!	Exit	bx = adr end of printf
;!!		cx = start of printf
;!!	Destroy	dl, ax
;===================================================================

Printer proc	
		mov cx, bx
Next:		mov al, [si]			; al = si*
		inc si				; si++

		cmp al, '$'			; if(al == '$')
		je End_t			;   jump End_t

		mov es:[bx], al			; Text[bx] = cur_sym
		mov es:[bx+1], 4eh		; Y on B
		mov dl, al			; save al

		add bx, 2

		cmp dl, '$'
		jne Next			; while end

End_t:		ret
Printer endp

;======================== ascii --> h DECLARE (mem_1 = accii) ==============
;!!	input:	mem_1 = accii	bx = start of print
;!!	exit:	bx = end of printf
;!!	Destroy:	si, dx
;===============================================================

H_create proc	
		xor si, si
H_start:	
		add bx, 2			; bx = bx + 2
		xor dx, dx			; dx = 0
		or dx, 1111000000000000b	; -2 chasa zisny na otladky
		and dx, [sc_num]		; get last 4 bits from mem_1
		shl [sc_num], 4h		; move to next 4 bits in mem_1
		shr dh, 4h			; dl looks like "0000 xxxx"
		cmp dh, 0ah			; is num or letter?
		jb H_num

		add dh, 'A'			; if dl >= 10
		sub dh, 0ah
		mov es:[bx], dh			; is letter
		mov es:[bx+1], COLOR
		jmp H_end

H_num:		add dh, '0'			; if dl < 10
		mov es:[bx], dh			; is num
		mov es:[bx+1], COLOR

H_end:		
		add si, 1
		cmp si, 4
		jne H_start
		
		mov ax, [sc_num_save]
		mov [sc_num], ax

		ret
H_create endp


;======================== STRING SCANF ================================
;!!	input:	nothing
;!!	exit:	sc_num_save, sc_num = scanned num
;!!	destroy:	ax, bx, cx, dx
;===================================================================

String_scanf proc
		

Str_sycle:		xor ax, ax
		int 16h

		cmp al, 'q'		; if( al == 'q')
		je Str_end		; return

		xor ah, ah
		mov cl, al

		xor ax, ax
		mov ax, [sc_num]
		mov bx, 0ah
		mul bx			; sc_num = sc_num * 10
		mov [sc_num], ax	

		xor ax, ax
		mov al, cl
		sub al, '0'
		add [sc_num], ax		; sc_num = sc_num + al

		jmp Str_sycle


Str_end:		mov ax, [sc_num]
		mov [sc_num_save], ax
		ret
String_scanf endp

;====================================================================

;===========================================================================
;=================================== MAIN START ============================
;===========================================================================

Main:
	        mov ax, VIDEOSEG       		;
                mov es, ax             		; es = VIDEOSEG
                mov bx, L_U_CORNER		; bx = senter
		mov dx, 0h		 	; dl = 0
		mov si, L_U_CORNER + LENGH * 2  ; si = end of cur line

						; printf ramka
Line:		mov ax, ' '			; al = ' '
		mov es:[bx], al			; place ramka
		mov es:[bx+1], COLOR		; red backgrownd

		add bx, 2			; bx = bx + 2

		cmp bx, si			; while end Line
		jne Line

		add si, 0a0h			; si = si + 160
		mov ax, si			;
		sub ax, LENGH * 2		;
		mov bx, ax			; move on L_U_CORNER

		cmp dx, HIGH			
		je Getch
		
		add dx, 1			; dx++

		cmp bx, si			
		jne Line			; while in colums


Getch:		call String_scanf 			; scanf("[^\n]", &sc_num )

						
Ramka:		
		call RamkaPrint			; si = END!


;------------------------- TRANSLITION PART ------------------------------
; Here was translition in 16-rich
		
		mov bx, L_U_CORNER + 162
		call H_create 

		xor ax, ax


;========================================================================

      		mov ax, 4c00h           	; exit(0)
                int 21h
	
;============================ DATA ==============================
	
		jmp Mem_end 
meow 		db 	'I ', 03h, ' cats!$'
info_h		db 	'16-rich = $'
mem_1		db	0
mem_2		db 	0
sc_num		dw	0
sc_num_save	dw	0

Mem_end:

end Start

;=======================================================================
'======================== MAIN END =====================================
;=======================================================================
