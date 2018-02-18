;---------------------------------------------------------------------;
;                   Create ramka on screen                            
;                                                                     
;---------------------------------------------------------------------;

.model tiny
.code

org 100h
L_U_CORNER	= 25 * 80 - 10
LENGH		= 9h
HIGH		= 2h
VIDEOSEG        = 0b800h
Start:          mov ax, VIDEOSEG       		;
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
		je Text
		
		add dx, 1			; dx++

		cmp bx, si			
		jne Line			; while in colums
	
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
		jmp Next			

Nechet:		mov ax, HIGH
		mov cx, 50h
		mul cx
		add ax, 50h
		add ax, L_U_CORNER
		mov bx, ax
		xor ax, ax			

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

meow db		'I ', 03h, ' cats!$'

end Start

;=======================================================================


