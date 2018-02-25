;---------------------------------------------------------------------;
;                   Create ramka on screen                            
;                                                                     
;---------------------------------------------------------------------;

.model tiny
.code

org 100h

Start:	
jmp Main					; Inache ne compilit

L_U_CORNER	= 25 * 80 - 10
LENGH		= 0ch
HIGH		= 2h
VIDEOSEG        = 0b800h

YGOL_1		= 0c9h				; Left Up corner
YGOL_2		= 0c8h				; Left Down corner
YGOL_3		= 0bbh				; Right Up corner
YGOL_4		= 0bch				; Right Down corner
STENA		= 0bah				; Wall
POL		= 0cdh				; pol/potolok
COLOR		= 4eh				; color of all

;========================================================================

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

;========================================================================
;=========================== MAIN START =================================
;========================================================================

Main:
	        mov ax, VIDEOSEG       		;
                mov es, ax             		; es = VIDEOSEG
                mov bx, L_U_CORNER		; bx = senter
		mov dx, 0h		 	; dl = 0
		mov si, L_U_CORNER + LENGH * 2  ; si = end of cur line

						; printf ramka
Line:		mov ax, ' '			; al = ' '
		mov es:[bx], al			; place ramka
		mov es:[bx+1], 4eh		; red backgrownd

		add bx, 2			; bx = bx + 2

		xor ah, ah
		int 16h				; BIOS 16h	
		
		cmp bx, si			; while end Line
		jne Line

		add si, 0a0h			; si = si + 160
		mov ax, si			;
		sub ax, LENGH * 2		;
		mov bx, ax			; move on L_U_CORNER

		cmp dx, HIGH			
		je Ramka
		
		add dx, 1			; dx++

		cmp bx, si			
		jne Line			; while in colums

;============================= RAMKA PRINT (si = end) ===================
Ramka:		
		call RamkaPrint			; si = END!!!!!

;========================================================================
	
Text:		mov si, offset meow		; si = &meow
		
		mov ax, HIGH			; proverka na chetnost
		and ax, 1h
		cmp ax, 1h
		je Nechet
		jne Chet 

Chet:		mov ax, HIGH
		mov cx, 50h
		mul cx
		add ax, L_U_CORNER
		mov bx, ax			; bx = sentral line
		xor ax, ax
		add bx, 2
		jmp Next			

Nechet:		mov ax, HIGH
		mov cx, 50h
		mul cx
		add ax, 50h
		add ax, L_U_CORNER
		mov bx, ax
		xor ax, ax
		add bx, 2

;=====================================================================

Next:		mov al, [si]			; al = si*
		inc si				; si++

		cmp al, '$'			; if(al == '$')
		je End_t			;   jump End_t

		mov es:[bx], al			; Text[bx] = cur_sym
		mov es:[bx+1], 4eh		; Y on B
		mov dl, al			; save al

		xor ah, ah			; BIOS 16h
		int 16h

		add bx, 2

		cmp dl, '$'
		jne Next			; while end

End_t:          mov ax, 4c00h           	; exit(0)
                int 21h
		
		jmp Mem_end 
meow db 	'I ', 03h, ' cats!$'

Mem_end:

end Start

;=======================================================================
