.386
.MMX
.MODEL FLAT, C
.DATA
	tabznak byte 256 dup (0)
	tabil dd 256 dup (0)
	rozmiar_tab dd 0
	znak byte 0
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
;zamien miejscami jezeli pierwszy z drugim je�eli pierwszy jest wiekszy
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
		call kompresuj
		lea eax, tabznak
		pop ebp
		pop edi
		pop esi
ret
utworz_tablice ENDP

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
ret
utworz_drzewo ENDP

;kompresja danych
kompresuj PROC

;		push input_text

;		mov edx, root
;		mov temp_root, edx
;		mov ebx, edx
;		add ebx, 4
;		mov edx, [ebx]
;		mov eax, [edx]
;		movd mm0, eax
;		add ebx, 4
;		mov edx, [ebx]
;		mov eax, [edx]
;		movd mm1, eax
		;movd mm2, input_text


koniec_kompresuj:
		
ret
kompresuj ENDP

END