;==================================================================;
;		Printf string on screen
;
;==================================================================;

.model tiny
.code

org 100h

Start:
jmp Main

PR_START		= 	 160 * 8 + 10
VIDEOSEG        = 	 0b800h					; adress of videoseg
COLOR			=	 4eh					; color of all


;=========================== MY PRINT =============================;
;!!	Input:	offset my_string in stack && arg to stack, bp = adr of start args in stack
;!! Exit:	printf string
;!! Destroy:	I don't know what is here!
;!!
;==================================================================;

my_printf proc
				pop cx
				mov [saved_adr], cx			; save adr of return
				pop si						; si = offset[my_string]

				mov bx, PR_START			; bx = start position

sycle_start:	
				mov al, [si]				; al = *si
				cmp al, '$'
				je printf_end
				
				cmp al, '%'					; if(is arg?)
				jne dump_print				;

				add si, 1					; si++

				sub bp, 2
				mov ah, [bp]				;
				mov [cur_per], ah			; get current per

				mov al, [si]				; get symbol after '%'			

				mov [s_counter], si 		; Save counter


				cmp al, 'c'					; ascii +
				jne Next_0				
				sub bx, 2
				mov al, [cur_per]
				mov es:[bx], al
				mov es:[bx+1], COLOR
				add bx, 2					
				jmp Next_5

Next_0:			cmp al, 'd'					; 10-rich +
				jne Next_1				
				call T_create
				jmp Next_5

Next_1:			cmp al, 'o'					; 8-rich +
				jne Next_2
				call E_create
				jmp Next_5

Next_2:			cmp al, 'b'					; binary +
				jne Next_3
				call B_create
				jmp Next_5

Next_3:			cmp al, 'x'					; 16-rich +				
				jne Next_4
				call H_create
				jmp Next_5

Next_4:			cmp al, 's'					; string
				jne Next_5				
				;! CALL !

Next_5:
				mov si, [s_counter]			; recower counter
				
											; !-!-!-!-!-!-!-!-!-!-!-!-!-!-!
											; !     many moves with %	  !
											; !-!-!-!-!-!-!-!-!-!-!-!-!-!-!
				jmp end_dump_print

dump_print:
				mov es:[bx], al
				mov es:[bx + 1], COLOR		; printf not %
				add bx, 2

end_dump_print:								

				
				add si, 1					; si++
				jmp sycle_start


printf_end:
				mov cx, [saved_adr]
				push cx						; return of saved adr 
				ret
my_printf endp

;======================== ascii --> h DECLARE (cx = accii) =================
;!!	input:	mem_1 = accii	bx = start of print
;!!	exit:	bx = end of printf
;!!	Destroy:	si, dx, ax
;===========================================================================

H_create proc	

		mov al, [cur_per]
		xor si, si
		sub bx, 2
H_start:	
		add bx, 2			; bx = bx + 2
		xor dx, dx			; dx = 0
		or dl, 11110000b		; -2 chasa zisny na otladky
		and dl, al			; get last 4 bits from al
		shl al, 4h			; move to next 4 bits in al
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

		add bx, 2
		ret
H_create endp

;====================== ascii --> 8-razr (cur_per = symbol) ===============
;!! Input:	cur_per = current peremennaya, bx = where printf
;!!	Exit:	bx = end of printf
;!!	Destroy:	si, dx, ax
;!!
;==========================================================================

E_create proc
		xor si, si
		sub bx, 2

E_start:	add bx, 2
		xor ax, ax
		xor dx, dx

		cmp si, 0
		je E_fir
		or dl, 11100000b
		and dl, [cur_per]
		shr dl, 5h
		shl [cur_per], 3h			; Pick 3 bits
		jmp E_calc		

E_fir:		or dl, 11000000b
		and dl, [cur_per]
		shr dl, 6h
		shl [cur_per], 2h			; Pick 2 left bits

E_calc:
		add dl, 30h
		mov es:[bx], dl
		mov es:[bx+1], COLOR		; printer
		
		add si, 1
		cmp si, 3
		jne E_start			; -2 hour of my life


		add bx, 2
		ret
E_create endp

;========================= ascii --> binary =============================
;!! Input:	cur_per = curren peremennaya, bx = adress in videoseg
;!!	Exit:	bx = end of printf
;!!	Destroy:	si, dx
;========================================================================

B_create proc
		xor si, si
		sub bx, 2

B_start:	add bx, 2
		xor dx, dx
		or dl, 10000000b
		and dl, [cur_per]
		shr dl, 7h
		shl [cur_per], 1h			; Get the leftest bit
		
		add dl, '0'
		mov es:[bx], dl
		mov es:[bx + 1], COLOR		; print it

		add si, 1
		cmp si, 8h			; do it again
		jne B_start

		add bx, 2
	
		ret
B_create endp

;====================== ascii --> 10-razr ===============================
;!! Input:	cur_per = curren peremennaya, bx = adress in videoseg
;!!	Exit:	bx = end of printf
;!!	Destroy:	ax, bx, dx, si
;========================================================================

T_create proc

		mov es:[bx + 1], COLOR
		mov es:[bx + 3], COLOR		; place backgrownd
		sub bx, 2

		xor ax, ax
		mov dl, 0ah
		mov al, [cur_per]			; Get symbol
		add bx, 6
	
T_start:	sub bx, 2
		div dl				; Get fir cifra
		mov dh, ah

		cmp al, 0h			; if end of num
		je T_end			; break

		add ah, 30h
		mov es:[bx], ah

		xor ah, ah
		jmp T_start

T_end:		add ah, 30h
		mov es:[bx], ah			; print ostatok
		add bx, 2
		ret
T_create endp


;==================================================================;
;========================== MAIN START ============================;
;==================================================================;
Main:
				mov ax, VIDEOSEG
				mov es, ax

				mov cx, 0h

				push cx
				mov bp, sp					; get adress of start args
				push d_sym
				push o_sym
				push b_sym
				push ten_sym
				push c_sym
				push offset[my_string]				

				call my_printf

pop_syc:		pop cx
				cmp cx, 0h					; pop lishnee
				jne pop_syc					

				mov ax, 4c00h           	; exit(0)
                int 21h
				jmp Mem_end
;------------------------------------------------------------------;
;						   MEMORY PART							   ;
;------------------------------------------------------------------;

saved_adr		dw	0
d_sym			dw	1ah
o_sym			dw	0ah
b_sym			dw	0fh
ten_sym			dw	0fh
c_sym			dw	01h

s_counter		dw	0
cur_per			db	'0'
my_string		db	'16-> %x 8-> %o 2-> %b 10-> %d assci-> %c$'
num_of_arg		db	0

Mem_end:
end Start
;==================================================================;
;========================== MAIN END ==============================;
;==================================================================;


