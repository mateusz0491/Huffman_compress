.386
.MMX
.MODEL FLAT, C
.DATA
	tabznak byte 256 dup (0)
	tabil dd 256 dup (0)
	tab_compr_bit dd 256 dup (0)
	tab_compr_bit_il byte 256 dup (0)

;	temp_r dd 0
;	temp_i dd 0
;	value_char dd 0

	rozmiar_tab dd 0
	root dd 0
	temp_root dd 0
.CODE
utworz_tablice PROC uses ebx input_text:DWORD, output_data:DWORD
		push esi
		push edi
		push ebp
		mov ecx, 0
		mov ebx, input_text
next_znak:
		mov al, [ebx]
porownaj_znak:
		mov ah, tabznak[ecx]
		cmp al, 0
		je sortuj_tablice
		cmp ah, al
		je rowne
;jezeli nie rowne sprawdza i wpisuje do tablicy nowa wartosc
		cmp ah, 0
		jne nie_zero
		mov tabznak[ecx], al
		mov tabil[4*ecx], 1
		inc rozmiar_tab
		inc ebx
		mov ecx, 0
		jmp next_znak
nie_zero:
		inc ecx
		jmp porownaj_znak
rowne:
		inc tabil[4*ecx]
		mov ecx, 0
		inc ebx
		jmp next_znak

;sortuj tablice
sortuj_tablice:
		mov eax, rozmiar_tab

; na koncu tablicy jest maksymalny element, sortuj do n-1
petla_sortuj:
		dec eax
		cmp eax, 0
		je koniec_tablicy
		push eax
		mov ecx, 0

next_element:
		pop eax
		cmp ecx, eax
		jge petla_sortuj
		push eax

		mov eax, tabil[4*ecx]
		inc ecx
		cmp eax, tabil[4*ecx]
		jg wieksze

		jmp next_element
;zamien miejscami jezeli pierwszy z drugim je¿eli pierwszy jest wiekszy
wieksze:
		mov al, tabznak[ecx]
		push tabil[4*ecx]
		dec ecx

		mov bl, tabznak[ecx]
		mov tabznak[ecx], al
		push tabil[4*ecx]

		inc ecx
		mov tabznak[ecx], bl
		pop tabil[4*ecx]
		dec ecx
		pop tabil[4*ecx]
		inc ecx
		jmp next_element

koniec_tablicy:
		push output_data
		push input_text
		call utworz_drzewo
		call utworz_tab_bitow
		lea eax, tabznak
		pop ebp
		pop edi
		pop esi
ret
utworz_tablice ENDP

;----------------------------------------------------------------


utworz_drzewo PROC input_text:DWORD, output_data:DWORD
		mov ecx, 0
		lea ebx, temp_root
		add ebx, 4
		mov temp_root, ebx
		mov eax, tabil[4*ecx]
		inc ecx
		add eax, tabil[4*ecx]
		mov [ebx], eax
		dec ecx
		add ebx, 4
		lea edx, tabznak[ecx]
		mov eax, 0
		mov al, [edx]
		mov [ebx], al
		add ebx, 4
		inc ecx
		lea edx, tabznak[ecx] 
		mov eax, 0
		mov al, [edx]
		mov [ebx], al
		mov edx, temp_root
		mov root, edx


next_value:
		add ebx, 4
		inc ecx
		mov eax, tabil[4*ecx]
		
	;mov ebx, root
		mov edi, root
		mov esi, rozmiar_tab
		dec esi
		cmp ecx, esi
		je add_value
		cmp eax, [edi]
		jl create_node

add_value:		
		mov eax, [edi]
		add eax, tabil[4*ecx]
		mov [ebx], eax
		mov temp_root, ebx
		add ebx, 4
		mov eax, root
		mov [ebx], eax
		add ebx, 4
		lea edx, tabznak[ecx]
;--------------------------------------
		mov eax, 0
		mov al, [edx]
		mov [ebx], al
;--------------------------------------
		mov edx, temp_root
		mov root, edx
		mov esi, rozmiar_tab
		dec esi
		cmp ecx, esi
		je koniec_utworz_drzewo
		jmp next_value

create_node:
		mov eax, tabil[4*ecx]
		inc ecx
		add eax, tabil[4*ecx]
		mov [ebx], eax
		mov temp_root, ebx
		add ebx, 4
		dec ecx
		lea edx, tabznak[ecx]
;--------------------------------------
		mov eax, 0
		mov al, [edx]
		mov [ebx], al
;--------------------------------------
		add ebx, 4
		inc ecx
		lea edx, tabznak[ecx]
;--------------------------------------
		mov eax, 0
		mov al, [edx]
		mov [ebx], al
;--------------------------------------


	;podepnij nowy wierzcholek do drzewa
		mov edi, root
		mov eax, [edi]
		mov edi, temp_root
		add eax, [edi]
		add ebx, 4
		mov edi, ebx
		mov [ebx], eax
		add ebx, 4
		mov edx, root
		mov [ebx], edx
		add ebx, 4
		mov eax, temp_root
		mov [ebx], eax
		mov root, edi
	;czy koniec tablicy
		mov eax, rozmiar_tab
		dec eax
		cmp ecx, eax
		je koniec_utworz_drzewo
		jmp next_value

koniec_utworz_drzewo:
		mov ebx, root
		mov temp_root, ebx
ret
utworz_drzewo ENDP

;----------------------------------------

utworz_tab_bitow PROC

		mov ecx, 0
	;	mov value_char, 0
	;	mov temp_i, 0
		push 0
		push 0
		push root
		call koduj_znaku

koniec_kodowania:
	
ret
utworz_tab_bitow ENDP

koduj_znaku PROC temp_r:DWORD, temp_i:DWORD, value_char:DWORD
		mov edx, temp_r
go_start:
		mov temp_r, edx
		add edx, 4
		mov eax, [edx]
		movd mm0, eax
		psllq mm0, 32

		movd mm1, eax
		por mm0, mm1


		mov ecx, 0
next_el:
		cmp ecx, rozmiar_tab
		jge go_left
		mov eax, 0
		mov al, tabznak[ecx]
		movd mm3, eax
		psllq mm3, 32

		inc ecx
		cmp ecx, rozmiar_tab
		je check_one
		mov eax, 0
		mov al, tabznak[ecx]
		movd mm4, eax
		por mm3, mm4

		pcmpeqd mm3, mm0
		movd eax, mm3
		cmp eax, 0FFFFFFFFh
		je right_value
check_one:
		psrlq mm3, 32
		movd eax, mm3
		cmp eax, 0FFFFFFFFh
		je left_value
		inc ecx
		jmp next_el

go_left:
		mov ebx, temp_r
		add ebx, 4
		mov edx, [ebx]
		inc temp_i
		jmp go_start

go_right:


left_value:
right_value:
ret
koduj_znaku ENDP

;----------------------------------------
;kompresja danych

END