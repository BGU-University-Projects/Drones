section	.rodata			; we define (global) read-only variables in .rodata section
extern Target
	extern DronesArray
	extern numDrones
	extern numDeaths
	extern numPrints
	extern printf
	extern fprintf 
	extern calloc 
	extern free 
	extern endCo
	extern do_resume
	extern resume
	extern DronesRutineArray
	extern RutinePrinter
	extern RutineTarget

	global Routine_start_scheduler
	global ActiveDrones
	global turnCounter
	global droneTurnNumber
	;global scheduler

		format_stringNEWLINE: db "%s", 10, 0	; format string
		format_int: db "%d", 0	; format string
		ForFloatNEWLINE:db "%lf",10,0
		winmsg:db " IS THE WINNER!",0

section	.data
turnCounter: dd 0
ActiveDrones: dd 0	
shouldDie: dd 0
firstVal: dd 0
secondVal: dd 0
counterKill:dd 0
droneTurnNumber:dd 0

section .bss			; we define (global) uninitialized variables in .bss section
	

section .text
	
%macro SurvivelOfTheFitest 0
	mov eax,0
	mov [shouldDie],eax
	mov eax,0
	mov [firstVal],eax
	mov eax,0
	mov [secondVal],eax
	mov eax,0
	mov [counterKill],eax
	CheckAll:
	mov ecx,[counterKill]
	mov edx,[numDrones]
	cmp ecx,edx
	je FinishCheck
	mov eax,[counterKill]
	mov ebx,24
	mul ebx
	add eax,[DronesArray]		;now eax points to the counter-nd Drone
	cmp dword[eax],0
	je DontCheck				;case he already died
	mov ebx,[shouldDie]
	cmp ebx,0					;case its first one and he is alive
	jne NormalState
	mov [shouldDie],eax
	add eax,20
	mov ecx,dword[eax]		
	mov [firstVal],ecx			;lowest score so far
	jmp DontCheck				;no need to check, its first
	NormalState:
	add eax,20
	mov ecx,dword[eax]			;the cur score
	sub eax,20
	mov edx,[firstVal]			;the lowest score so far
	cmp edx,ecx
	jl DontCheck				;if cur is higher then lowest
	mov [shouldDie],eax			;update the should die
	add eax,20
	mov ecx,dword[eax]		
	mov [firstVal],ecx			;update lowest score so far

	DontCheck:
	mov ecx,[counterKill]
	add ecx,1
	mov [counterKill],ecx			;counterPrint++
	jmp CheckAll
	FinishCheck:
	mov eax,[shouldDie]
	mov ebx,0
	mov dword[eax],ebx				;make the loser id =0

	%endmacro
%macro PrintWinner 0
	mov eax,[DronesArray]
	%%.SearchTheOne:
	cmp dword[eax],0
	jne %%.foundtheOne
	add eax,24
	jmp %%.SearchTheOne
	%%.foundtheOne:
	push dword[eax]	
	push format_int
	call printf			;print id
	pop edx
	pop edx
	push winmsg	
	push format_stringNEWLINE
	call printf			;print id
	pop edx
	pop edx
	%endmacro


Routine_start_scheduler:

	mov ebx,[numDrones]
	mov [ActiveDrones],ebx		;init ActiveDrones
	GameLoop:

	mov eax,0
	mov ebx,0
	mov ecx,0
	mov edx,0
	
	mov eax,[turnCounter]
	mov ebx,[numDrones]
	div ebx				;edx=i%N
	;mov edx,[DronesRutineArray]
	mov eax,edx
	
	mov [droneTurnNumber],eax
	mov ebx,24
	mul ebx
	mov edx,[DronesArray]
	add eax,edx
	cmp dword[eax],0	;check if the drone is Active
	je NotActiveDrone
		;should switch to the i’th drone co-routine
		mov eax,[droneTurnNumber]
		mov ebx,[DronesRutineArray]
		mov ecx,4
		mul ecx
		add eax,ebx
		mov ebx,[eax]	;ebx==pointer the the drone co struct
		call resume
	NotActiveDrone:

	mov eax,0
	mov ebx,0
	mov ecx,0
	mov edx,0

	mov eax,[turnCounter]
	mov ebx,[numPrints]
	add eax,1
	div ebx				;edx=i%numPrints
	cmp edx,0
	jne NotNeedPrint
		;switch to the printer co-routine
		mov ebx,[RutinePrinter]
		call resume
	NotNeedPrint:
	mov eax,[ActiveDrones]
	cmp eax,1
	je FINITO
	mov eax,0
	mov ebx,0
	mov ecx,0
	mov edx,0
	
	mov eax,[turnCounter]
	add eax,1
	mov ebx,[numDrones]
	div ebx				;eax=i/numDrones
	cmp edx,0				;edx=i%numDrones
	jne NoNeedToKill			;case (i%numDrones) isnt 0
	mov ebx,[numDeaths]
	div ebx				;edx=(i/numDrones)%numDeaths
	cmp edx,0
	jne NoNeedToKill			;case (i/numDrones)%numDeaths isnt 0
		
	SurvivelOfTheFitest			;destroy the weakest
		
	mov eax,[ActiveDrones]
	sub eax,1
	mov [ActiveDrones],eax		;ActiveDrones --

	NoNeedToKill:
	mov eax,[turnCounter]
	add eax,1
	mov [turnCounter],eax		;counter Turn ++

	mov eax,[ActiveDrones]
	cmp eax,1 					;if only One Drone left
	jne GameLoop
	FINITO:
	;if we here we finished the game
	PrintWinner

	;stop the game (return to main() function or exit)

	;exit>
	;mov	ebx, 1
	;mov	eax, 1
	;int	0x80

	;return>
	call endCo





















