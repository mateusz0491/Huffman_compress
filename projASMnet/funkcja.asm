.386
.MMX
.MODEL FLAT, C
.DATA
	tabznak byte 256 dup (0)
	tabil dd 256 dup (0)
	tab_compr_bit dd 256 dup (0)
	tab_compr_bit_il byte 256 dup (0)

	temp_r dd 0
	temp_i byte 0
	value_char dd 0

	rozmiar_tab dd 0
	root dd 0
	temp_root dd 0
.CODE
utworz_tablice PROC uses ebx input_text:DWORD, output_data:DWORD
		push esi
		push edi
		push ebp
		push esp
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
		mov edx, rozmiar_tab

; na koncu tablicy jest maksymalny element, sortuj do n-1
petla_sortuj:
		dec edx
		cmp edx, 0
		je koniec_tablicy
	;	push eax
		mov ecx, 0

next_element:
	;	pop eax
		cmp ecx, edx
		jge petla_sortuj
	;	push eax

		mov ebx, tabil[4*ecx]
		inc ecx
		cmp ebx, tabil[4*ecx]
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
		call utworz_drzewo
		call utworz_tab_bitow

		push output_data
		push input_text
		call huffman_code

		add esp, 8
		mov eax, output_data
		mov ebx, eax
		pop esp
		pop ebp
		pop edi
		pop esi
ret
utworz_tablice ENDP

;----------------------------------------------------------------


utworz_drzewo PROC
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
go_next:
	;	mov eax, tabil[4*ecx]
		cmp ecx, rozmiar_tab
		je end_code
		call koduj_znaku
		inc ecx
		jmp go_next

end_code:
ret
utworz_tab_bitow ENDP

koduj_znaku PROC
start:
		lea eax, tab_compr_bit
		mov esi, root
		mov value_char, 0
		mov temp_i, 0
		mov eax, 0
		mov al, tabznak[ecx]
		movd mm0, eax
		psllq mm0, 32
		movd mm1, eax
		por mm0, mm1

		mov ebx, root
		mov temp_root, ebx
go_next_node:
		mov ebx, [temp_root]
		mov eax, [ebx]
		cmp eax, 0
		jne go_node
		mov eax, 0
		mov [esi], eax
		jmp start
go_node:
		inc temp_i
		mov ebx, temp_root
		add ebx, 4
		mov eax, [ebx]
		movd mm2, eax
		psllq mm2, 32
		add ebx, 4
		mov eax, [ebx]
		movd mm3, eax
		por mm2, mm3

		movq mm3, mm2

		pcmpeqd mm2, mm0
		movd eax, mm2
		cmp eax, 0FFFFFFFFh
		je go_right_end

		psrlq mm2, 32
		movd eax, mm2
		cmp eax, 0FFFFFFFFh
		je go_left_end

		pcmpeqd mm3, mm4

		movd eax, mm3
		psrlq mm3, 32
		movd ebx, mm3
		;FFFFFFFF
		cmp ebx, 0FFFFFFFFh
		jne go_left

		cmp eax, 0FFFFFFFFh
		jne go_right
		jmp start
go_left:
		mov edx, temp_root
		add edx, 4
		mov esi, edx
		mov ebx, [edx]
		mov temp_root, ebx
		shl value_char, 1
		mov edx, value_char
		mov ebx, 0
		or edx, ebx
		mov value_char, edx
		jmp go_next_node

go_right:
		mov edx, temp_root
		add edx, 8
		mov esi, edx
		mov ebx, [edx]
		mov temp_root, ebx
		shl value_char, 1
		mov edx, value_char
		mov ebx, 1
		or edx, ebx
		mov value_char, edx
		jmp go_next_node

go_left_end:
		mov ebx, temp_root
		add ebx, 4
		mov edx, 0
		mov [ebx], edx
		shl value_char, 1
		mov edx, value_char
		mov ebx, 0
		or edx, ebx

		mov tab_compr_bit[4*ecx], edx
		mov al, temp_i
		mov tab_compr_bit_il[ecx], al
		jmp go_end

go_right_end:
		mov ebx, temp_root
		mov edx, 0
		mov [ebx], edx
		add ebx, 8
		mov [ebx], edx
		shl value_char, 1
		mov edx, value_char
		mov ebx, 1
		or edx, ebx

		mov tab_compr_bit[4*ecx], edx
		mov al, temp_i
		mov tab_compr_bit_il[ecx], al
		jmp go_end

go_end:
ret
koduj_znaku ENDP
;----------------------------------------
;kompresja danych

huffman_code PROC input_text:DWORD, output_data:DWORD, adr_back:DWORD

		mov ebx, [input_text]
		mov edx, [output_data]
		lea eax, tabznak
		pxor mm0, mm0
		mov temp_i, 64
next_znak:
		mov eax, 0
		mov al, [ebx]
		cmp al, 0
		je koniec
		mov ecx, 0
next_el_tab:
		cmp al, tabznak[ecx]
		je koduj
		inc ecx
		jmp next_el_tab

koduj:
		mov eax, tab_compr_bit[4*ecx]
		movd mm1, eax
		mov eax, 0
		mov al, temp_i
		mov cl, tab_compr_bit_il[ecx]
		sub al, cl
		movd mm2, eax
		psllq mm1, mm2
		mov temp_i, al
		por mm0, mm1
		cmp al, 32
		jl load_to_output
	;	mov [edx], eax
	;	add edx, 4
		add ebx, 1
		jmp next_znak

load_to_output:
		pxor mm3, mm3
		por mm3, mm0
		psrlq mm3, 32
		movd eax, mm3
		mov [edx], eax
		add edx, 4
		psllq mm0, 32
		mov al, temp_i
		add al, 32
		mov temp_i, al
		jmp next_znak
koniec:
		mov ebx, [output_data]
ret
huffman_code ENDP

END