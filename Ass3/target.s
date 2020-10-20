section	.rodata			; we define (global) read-only variables in .rodata section
extern Target
	extern DronesRutineArray
	extern RutineSchedular
	extern RutinePrinter
	extern do_resume
	extern resume
	extern droneTurnNumber
	extern RNDSpeedorLocPls
	extern RNDDegPls
	extern Finalval

	extern RNDSpeedorLocPls
	extern RNDDegPls
	extern Finalval
	extern RNDDegChange
	extern RNDSpeedChange

	global Routine_start_target
	;global CreateTargetS
	

section	.data
	varX:dd 5.6
	varY:dd 5.7
	

section .bss			; we define (global) uninitialized variables in .bss section
	

section .text
	

Routine_start_target:

createTarget:
	call RNDSpeedorLocPls
	mov eax,[Finalval] ;random number for scale x   floatttttttttttttttttttttttt
	mov ebx,[Target]
	mov dword[ebx],eax	

	call RNDSpeedorLocPls
	mov eax,[Finalval] ;random number for scale y   floatttttttttttttttttttttttt
	mov ebx,[Target]
	add ebx,4
	mov dword[ebx],eax	

		mov eax,[droneTurnNumber]
		mov ebx,[DronesRutineArray]
		mov ecx,4
		mul ecx
		add eax,ebx
		mov ebx,[eax]	;ebx=pointer the the drone co struct
		call resume

jmp Routine_start_target
	






















