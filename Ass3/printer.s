section	.rodata			; we define (global) read-only variables in .rodata section
extern Target
	extern DronesArray
	extern printf
  	extern fprintf 
	extern numDrones
	extern DronesRutineArray
	extern RutineSchedular
	extern RutineTarget
	extern do_resume
	extern resume

	global Routine_start_printer

	format_stringNEWLINE: db "%s", 10, 0	; format string
	format_string: db "%s", 0	; format string
	format_int: db "%d", 0	
	format_intNEWLINE:db "%d",10, 0	 
	ForFloatNEWLINE:db "%.2f",10,0
	ForFloat:db "%.2f",0

section	.data
	sep: db ",",0
	lensep:  equ $ - sep
	counterPrint:dd 0
	cur:dd 0
	to_deg: dd 57.295779513

	varX:dd 5.6
	varY:dd 5.7
	varPrint:dd 0

section .bss			; we define (global) uninitialized variables in .bss section
	
section .text

%macro PrintPlease 0
	;varPrint should hold the var
	finit
	sub esp,8
	fld dword[varPrint]
	fstp qword[esp]	
	push ForFloat
	call printf	
	pop eax
	add esp,8
	%endmacro

%macro PrintPleaseNEWLINE 0
	;varPrint should hold the var
	finit
	sub esp,8
	fld dword[varPrint]
	fstp qword[esp]	
	push ForFloatNEWLINE
	call printf	
	pop eax
	add esp,8
	%endmacro

%macro PrintSep 0
	push sep
	push format_string
	call printf
	pop eax
	pop eax
	%endmacro


%macro printTarget 0
	mov eax,[Target]
	mov ebx,dword[eax]		;ebx= scale x of target
	;mov ebx,[varX]
	mov [varPrint],ebx
	PrintPlease
	PrintSep
	mov eax,[Target]
	add eax,4
	mov ebx,dword[eax]		;ebx= scale y of target
	mov [varPrint],ebx
	PrintPleaseNEWLINE
	%endmacro

%macro printDrone 0
	mov eax,[counterPrint]
	mov ebx,24
	mul ebx
	add eax,[DronesArray]		;now eax points to the counter-nd Drone
	mov dword[cur],eax				;cur point to the start drone
	mov ebx,dword[eax]
	cmp ebx,0
	je %%.NoPrint
	push ebx	
	push format_int
	call printf			;print id
	pop edx
	pop edx
	
	PrintSep
	
	mov eax,[cur]
	add eax,4
	mov ebx,dword[eax]
	mov [varPrint],ebx

	PrintPlease			;print x scale 

	PrintSep

	mov eax,[cur]
	add eax,8
	mov ebx,dword[eax]
	mov [varPrint],ebx
	PrintPlease			;print y scale 

	PrintSep

	mov eax,[cur]
	add eax,16
	mov ebx,dword[eax]
	finit
	fld dword[eax]
	fmul dword[to_deg]
	fld dword[varPrint]
	;mov [varPrint],ebx
	PrintPlease			;print deg 
	PrintSep

	mov eax,[cur]
	add eax,12
	mov ebx,dword[eax]
	mov [varPrint],ebx
	PrintPlease			;print speed 
	PrintSep

	mov eax,[cur]
	add eax,20
	mov ebx,dword[eax]
	push ebx	
	push format_intNEWLINE
	call printf			;print Score
	pop edx
	pop edx

	%%.NoPrint:
	%endmacro


Routine_start_printer:

PrintGame:
	mov eax,0
	mov [counterPrint],eax	;init counter

	printTarget
	PrintAll:
	mov ecx,[counterPrint]
	mov edx,[numDrones]
	cmp ecx,edx
	je FinishPrint

	printDrone

	mov ecx,[counterPrint]
	add ecx,1
	mov [counterPrint],ecx	;counterPrint++
	jmp PrintAll
	FinishPrint:

;kkkkkkkkkkkkkkkkkkkkkkkkk
	;mov ebx,1
	;mov eax,1
	;int	0x80

	mov ebx,[RutineSchedular]
	call resume
jmp Routine_start_printer





















