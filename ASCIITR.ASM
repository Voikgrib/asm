;---------------------------------------------------------------------;
;                   Create ramka on screen                            
;                                                                     
;---------------------------------------------------------------------;

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

H_create proc	
		xor si, si
H_start:	
		add bx, 2			; bx = bx + 2
		xor dx, dx			; dx = 0
		or dl, 11110000b		; -2 chasa zisny na otladky
		and dl, [mem_1]			; get last 4 bits from mem_1
		shl [mem_1], 4h			; move to next 4 bits in mem_1
		shr dl, 4h			; dl looks like "0000 xxxx"
		cmp dl, 0ah			; is num or letter?
		jb H_num

		add dl, 'A'			; if dl >= 10
		sub dl, 0ah
		mov es:[bx], dl			; is letter
		mov es:[bx+1], COLOR
		jmp H_end

H_num:		add dl, '0'			; if dl < 10
		mov es:[bx], dl			; is num
		mov es:[bx+1], COLOR

H_end:		
		add si, 1
		cmp si, 2
		jne H_start
		
		mov al, [mem_2]
		mov [mem_1], al

		ret
H_create endp

;====================== ascii --> 8-razr (mem_1 = symbol) ===============

E_create proc
		xor si, si

E_start:	add bx, 2
		xor ax, ax
		xor dx, dx

		cmp si, 0
		je E_fir
		or dl, 11100000b
		and dl, [mem_1]
		shr dl, 5h
		shl [mem_1], 3h			; Pick 3 bits
		jmp E_calc		

E_fir:		or dl, 11000000b
		and dl, [mem_1]
		shr dl, 6h
		shl [mem_1], 2h			; Pick 2 left bits

E_calc:
		add dl, 30h
		mov es:[bx], dl
		mov es:[bx+1], COLOR		; printer
		
		add si, 1
		cmp si, 3
		jne E_start			; -2 hour of my life

		mov al, [mem_2]
		mov [mem_1], al			; refresh mem_1

		ret
E_create endp

;========================= ascii --> binary =============================

B_create proc
		xor si, si

B_start:	add bx, 2
		xor dx, dx
		or dl, 10000000b
		and dl, [mem_1]
		shr dl, 7h
		shl [mem_1], 1h			; Get the leftest bit
		
		add dl, '0'
		mov es:[bx], dl
		mov es:[bx + 1], COLOR		; print it

		add si, 1
		cmp si, 8h			; do it again
		jne B_start

		mov al, [mem_2]			; -10 min of my life
		mov [mem_1], al			; :)
	
		ret
B_create endp

;====================== ascii --> 10-razr ===============================

T_create proc
		xor ax, ax
		mov dl, 0ah
		mov al, [mem_1]			; Get symbol
		add bx, 6
	
T_start:	sub bx, 2
		div dl				; Get fir cifra
		mov dh, ah

		cmp al, 0h			; if end of num
		je T_end			; break

		add ah, 30h
		mov es:[bx], ah
;		mov es:[bx + 1], COLOR		; printf

		xor ah, ah
		jmp T_start

T_end:		add ah, 30h
		mov es:[bx], ah			; print ostatok
;		mov es:[bx+1], COLOR

		ret
T_create endp

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

;======================= ASCII GET ======================================

Getch:		xor ah, ah			; ax = 0
		mov al, 1h
		int 16h				; ah = getch()
		mov [mem_1], al
		mov [mem_2], al

		mov es:[328], al
		mov es:[329], 0eh			; DEBUG

;============================= RAMKA PRINT (si = end) ===================
Ramka:		
		call RamkaPrint			; si = END!

;==================== LINE PRINT (bx = start pos, si &line) =============
	
Text:		mov si, offset meow		; si = &meow
		mov bx, L_U_CORNER + 162
		call Printer			; print(meow)

		mov bx, cx
		add bx, 0a0h
		mov si, offset info_h
		call Printer			; print 16razr
		call H_create

		mov bx, cx
		add bx, 0a0h
		mov si, offset info_e
		call Printer			; print 8razr
		call E_create			; // Byaka

		mov bx, cx
		add bx, 0a0h
		mov si, offset info_b
		call Printer			; print 2razr
		call B_create

		mov bx, cx
		add bx, 0a0h
		mov si, offset info_t
		call Printer			; print 10razr
		call T_create

;========================================================================

      		mov ax, 4c00h           	; exit(0)
                int 21h
		
		jmp Mem_end 
meow 		db 	'I ', 03h, ' cats!$'
info_h		db 	'16-rich = $'
info_e		db 	'8-rich = $'
info_b		db	'binary = $'
info_t		db	'10-rich = $'
mem_1		db	0
mem_2		db 	0

Mem_end:

end Start

;=======================================================================
'======================== MAIN END =====================================
;=======================================================================
