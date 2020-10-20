section	.rodata			; we define (global) read-only variables in .rodata section
global main
	global numDrones
	global numDeaths
	global numPrints
	global numDis
	global Seed
	global DronesArray
	global Target
	global CURR
	global SPT
	global SPMAIN
	global initCo
	global numCur
	global AddresCur
	global endCo
	global startCo
	global do_resume
	global resume
	global RNDSpeedorLocPls
	global RNDDegPls
	global Finalval
	global RNDDegChange
	global RNDSpeedChange

	global DronesRutineArray
	global RutineSchedular
	global RutinePrinter
	global RutineTarget

	extern free
	extern calloc
	extern sscanf
	extern printf
	extern Routine_start_target
	extern Routine_start_scheduler
	extern Routine_start_printer
	extern Routine_start_drone
	;extern CreateTargetS
	;valgrind --track-origins=yes --leak-check=full --show-leak-kinds=all ./ass3 1 8 10 30 15019
		format: db "%s", 0	; format string
		ForFloatNEWLINE:db "%lf",10,0
		ForFloat:db "%lf",0
		ForInt:db "%d",0
		ForIntNEWLINE:db "%d",10,0
		ForFloat2:db "%f",0



section	.data
	DronesRutineArrayDELETE:dd 0
	RutineSchedularDELETE:dd 0
	RutinePrinterDELETE: dd 0
	RutineTargetDELETE: dd 0
	STACKDELETE:dd 0
	adrTODEL:dd 0
	numDrones: dd 0	
	numDeaths: dd 0
	numPrints: dd 0
	numDis: dd 0.0					;floating
	Seed: dd 0	
	DronesArray: dd 0
	DronesRutineArray: dd 0
	RutineSchedular: dd 0
	RutinePrinter: dd 0
	RutineTarget: dd 0
	RutineDrone: dd 0
	counter: db  0	
	Target: dd 0
	STKSIZE:dd 16384 ;16*1024
	newRoutine: dd 0
	RoutineFunc:dd 0
	numCur:db 0
	AddresCur:dd 0
	Finalval:dd 0
	varPrint:dd 0
    intMAX:dd 0xFFFF
    speedMax:dd 100.0 
	speedChange:dd 20.0 
	spd1:dd 10.0
	degMax:dd 6.28318530718 ;2pai 
	;degMax:dd 360.0
	degChange:dd 2.0943951024
	deg1:dd 1.0471975512
	deg2:dd 3
	temp: dd 0

	var1:dd 10.0
	var2:dd 11.0
	var3:dd 5.5
	var4:dd 1.57
	var5:dd 20.0

	varX:dd 10.6
	varY:dd 10.7

;llll
%macro CreateTargetS 0
	call RNDSpeedorLocPls
	mov eax,[Finalval] ;random number for scale x  
	mov ebx,[Target]
	mov dword[ebx],eax	
	call RNDSpeedorLocPls
	mov eax,[Finalval] ;random number for scale y 
	mov ebx,[Target]
	add ebx,4
	mov dword[ebx],eax	
	%endmacro
%macro makeRuotin 0
	;make a new routine and puts his addres in newRoutine
	mov eax,8
	mov ebx,1
	push eax
	push 1
	call calloc
	mov [newRoutine],eax
	pop eax
	pop eax
	;first 4 bytes are adres for function
	;second 4 bytes ate adres for stack to the end of it
	mov eax,[newRoutine]
	mov ebx,[RoutineFunc]
	mov dword[eax],ebx	;the func
	mov eax,[STKSIZE]
	mov ebx,1
	push eax
	push ebx
	call calloc
	;mov edx,[temp]
	;mov ecx,[DronesRutineArrayDELETE]
	mov ebx,[STKSIZE]		;check if correct
	add eax,ebx
	mov ebx,[newRoutine]
	mov dword[ebx+4],eax	;point to the end of the stack
	pop eax
	pop eax
	%endmacro

%macro FreeRuotin 0
	;free the routin in newRoutine variable
	mov edx,[newRoutine]
	mov ecx,[STACKDELETE]
	mov ebx,[STKSIZE]
	
	sub ecx,ebx		;to point to the start
	;add ecx,12
	push ecx
	call free		;delete the stack
	pop ecx
	mov edx,[newRoutine]
	push edx
	call free		;delete the routine
	pop ecx
	%endmacro

%macro FreeRuotinDrone 0
	;free the routin in newRoutine variable

	movzx eax,byte[counter]
	mov edx,4
	mul edx
	mov ebx,[DronesRutineArrayDELETE]	;points to the adres of the cur routin
	add eax,ebx
	mov eax,[eax]
	sub eax,[STKSIZE]
	;sub ecx,ebx		;to point to the start
	;add ecx,12
	push eax
	call free		;delete the stack
	pop ecx
	mov edx,[newRoutine]
	push edx
	call free		;delete the routine
	pop ecx
	%endmacro

%macro initCo 0		
	;ID should be in [numCur], 0 if not relevente
	;adres of structur should be in [AddresCur]
	movzx ebx, byte[numCur]				; get co-routine ID number
	mov ecx,[AddresCur]
	mov eax,ebx
	mov edx,4
	mul edx
	add eax,ecx
	mov ebx, eax			; get pointer to COi struct
	mov eax, dword[ebx+0]            ; get initial EIP value – pointer to COi function
	mov [SPT], ESP	             	 ; save ESP value
	mov esp, [EBX+4]           	 	; get initial ESP value – pointer to COi stack
	push eax 	                 	 ; push initial “return” address
	pushfd		                  	; push flags
	pushad		               		; push all other registers
	mov [ebx+4], esp             	; save new SPi value (after all the pushes)
	mov ESP, [SPT]	                ; restore ESP value
	%endmacro

startCo:
	;adres of structur should be in [AddresCur]
	pushad					; save registers of main ()
	mov [SPMAIN], ESP		; save ESP of main ()
	;mov EBX, [EBP+8]		; gets ID of a scheduler co-routine
	;mov ecx,[AddresCur]
	;mov EBX, [EBX*4 + ecx]	; gets a pointer to a scheduler struct
	mov EBX,[AddresCur]
	jmp do_resume			; resume a scheduler co-routine

endCo:
	mov	ESP, [SPMAIN]   ; restore ESP of main()
	popad				; restore registers of main()
	ret

resume:		                ; save state of current co-routine
	pushfd
	pushad
	mov	EDX, [CURR]
	mov	[EDX+4], ESP   	 ; save current ESP
do_resume: 		            ; load ESP for resumed co-routine
	mov	ESP, [EBX+4]
	mov	[CURR], EBX
	popad		            ; restore resumed co-routine state
	popfd
	ret		            	; "return" to resumed co-routine



section .bss			; we define (global) uninitialized variables in .bss section
	CURR:	resd	1
	SPT:	resd	1   ; temporary stack pointer
	SPMAIN:	resd	1   ; stack pointer of main
	rndVal:resd 4
	rndVal2:resd 4



section .text

%macro PrintPleaseint 0
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
%macro PrintPleasefloat 0
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

%macro Print_it 2
	pushad
	push dword %1
	push  %2
	call printf
	pop edx
	pop edx
	popad
%endmacro

%macro SCANF 3
	pushad
	push dword %3
	push dword %2
	push dword %1
	call sscanf
	pop edx
	pop edx
	pop edx
	popad
%endmacro

%macro xor_bit2 0
	mov ax,word[rndVal]
	mov bx,ax
	and bx,1				;to check where result? bx is the 16 bit
	mov cx,ax
	and cx,4				;to check where result? cx is the 14 bit
	shr cx,2
	xor bx,cx				;xor
	mov cx,ax
	and cx,8				;to check where result? cx is the 13 bit
	shr cx,3
	xor bx,cx				;xor
	mov cx,ax
	and cx,32				;to check where result? cx is the 14 bit
	shr cx,5
	xor bx,cx				;xor og 16th and 14 th
		shr ax,1				;shift right
	movzx ebx,bx			;if the result is 0 do nothing
	cmp ebx,0
	je endXor
	movzx eax,ax
		;or eax,132768		;2^15
		or eax,1000000000000000b
	endXor:
	mov word[rndVal],ax

%endmacro

rndPls:
	push ebp
	mov ebp, esp
	pushad
  	mov edx, 0   ; counter
  	rndLoop:
    cmp edx, 16
    JE FinishLoop
    mov ebx, 0   

	xor_bit2

	add edx,1
    JMP rndLoop
  	FinishLoop:
	mov esp, ebp       
	pop ebp			       
ret

RNDSpeedorLocPls:
  	push ebp
	mov ebp, esp
	pushad
	finit
	call rndPls
	;mov eax,dword[rndVal]
	;mov [varPrint],eax
	;PrintPleasefloat

	mov eax,dword[rndVal]

	finit
	fld dword[rndVal] 
	lll:
	fmul dword[speedMax]                       
	fdiv dword[intMAX] 
	fst dword[Finalval]  

	;fst dword[varPrint]                  
	;PrintPleaseint
	;PrintPleasefloat

	mov eax, dword [Finalval]

  	mov esp, ebp       
	pop ebp			       
ret

RNDSpeedChange:
  	push ebp
	mov ebp, esp
	pushad
	finit
	call rndPls

	;mov [varPrint],eax
	;PrintPleaseint

	mov eax,dword[rndVal]
	finit
	fld dword[rndVal] 
	fmul dword[speedChange]                       
	fdiv dword[intMAX]
	fsub dword[spd1]
	fst dword[Finalval]  

	;fst dword[varPrint]                  
	;PrintPleaseint
	;PrintPleasefloat

	mov eax, dword [Finalval]
  	mov esp, ebp       
	pop ebp			       
ret

RNDDegPls:
  	push ebp
	mov ebp, esp
	pushad
	finit
	call rndPls

	;mov [varPrint],eax
	;PrintPleaseint

	mov eax,dword[rndVal]
	
	finit
	fld dword[rndVal] 
	fmul dword[degMax]                       
	fdiv dword[intMAX] 
	fst dword[Finalval]  

	;fst dword[varPrint]                  
	;PrintPleaseint
	;PrintPleasefloat

	mov eax, dword [Finalval]

  	mov esp, ebp       
	pop ebp			       
ret

RNDDegChange:
  	push ebp
	mov ebp, esp
	pushad
	finit
	call rndPls

	;mov [varPrint],eax
	;PrintPleaseint

	mov eax,dword[rndVal]
	finit
	fld dword[rndVal] 
	fmul dword[degChange]                       
	fdiv dword[intMAX]
	;fidiv dword[deg2]
	fsub dword[deg1]
	fst dword[Finalval]  

	;fst dword[varPrint]                  
	;PrintPleaseint
	;PrintPleasefloat

	mov eax, dword [Finalval]
  	mov esp, ebp       
	pop ebp			       
ret

main:
	
	push ebp
	mov ebp, esp	
	pushad
	mov eax,0
	mov [counter],al				;init counterrrrrr

	mov edx , [ebp+8]
	mov eax , [ebp+12]				;ebx=pointer to argv array
	
	;mov dword[rndVal],44257 
		;call RNDSpeedorLocPls
		;call RNDSpeedorLocPls
		;call RNDSpeedorLocPls
		;call RNDSpeedorLocPls
		;call RNDSpeedorLocPls
		;call RNDSpeedorLocPls
		;call RNDSpeedorLocPls

	;jmp afterRead
;reading the argsssss
		SCANF [eax+4],ForInt,numDrones
		SCANF [eax+8],ForInt,numDeaths
		SCANF [eax+12],ForInt,numPrints
		SCANF [eax+16],ForFloat2,numDis
		SCANF [eax+20],ForInt,rndVal
		jmp afterRead2

afterRead:
		mov eax,1
		mov  [numDrones] , eax
		mov eax,1
		mov  [numDeaths] , eax
		mov eax,1
		mov  [numPrints] , eax
		mov eax,[var5]
		mov  [numDis] , eax
		mov eax,0xACE1
		mov  [Seed] , eax
		mov [rndVal],eax

	afterRead2:
;make the Target Routine
	mov ebx,Routine_start_target		;get the label addres
	mov [RoutineFunc],ebx
	makeRuotin							;make the rutine
	mov ebx,[newRoutine]
	mov [RutineTarget],ebx				;put its adres in the variable

	mov [AddresCur],ebx
	mov byte[numCur],0
	mov edx,dword[ebx+4]
	mov [RutineTargetDELETE],edx

	initCo
;make the Scheduler Routine
	mov ebx,Routine_start_scheduler		;get the label addres
	mov [RoutineFunc],ebx
	makeRuotin							;make the rutine
	mov ebx,[newRoutine]
	mov [RutineSchedular],ebx				;put its adres in the variable
	mov [AddresCur],ebx
	mov byte[numCur],0
	mov edx,dword[ebx+4]
	mov [RutineSchedularDELETE],edx
	initCo
;make the printer Routine
	mov ebx,Routine_start_printer		;get the label addres
	mov [RoutineFunc],ebx
	makeRuotin							;make the rutine
	mov ebx,[newRoutine]
	mov [RutinePrinter],ebx				;put its adres in the variable
	mov [AddresCur],ebx
	mov byte[numCur],0
	mov edx,dword[ebx+4]
	mov [RutinePrinterDELETE],edx
	initCo
;making the co-rutines Array
	mov eax,[numDrones]	;num of drones
	mov ebx,4				;bytes for each co-rotine address
	push eax
	push ebx
	call calloc
	mov [DronesRutineArray],eax	
	pop eax
	pop eax

	mov eax,[numDrones]	;num of drones
	mov ebx,4				;bytes for each co-rotine address
	push eax
	push ebx
	call calloc
	mov [DronesRutineArrayDELETE],eax	
	pop eax
	pop eax

	mov eax,0
	mov [counter],al				;init counter
	make_Those_dron_rotines:
	mov ebx,Routine_start_drone		;get the label addres
	mov [RoutineFunc],ebx
	makeRuotin						;make the rutine

	mov ebx,[newRoutine]
	movzx eax,byte[counter]
	mov edx,4
	mul edx
	add eax,[DronesRutineArrayDELETE]
	mov ebx,dword[ebx+4]	

	mov dword[eax],ebx

	mov ebx,[newRoutine]
		mov [AddresCur],ebx
		mov edx,ebx
		add edx,4
		mov edx,dword[edx]
		;mov [adrTODEL],edx
		mov byte[numCur],0
		initCo
	mov ebx,[newRoutine]
	movzx eax,byte[counter]
	mov edx,4
	mul edx
	add eax,[DronesRutineArray]			
	mov dword[eax],ebx			
	
	;mov ebx,[adrTODEL]
	;movzx eax,byte[counter]
	;mov edx,4
	;mul edx
	;add eax,[DronesRutineArrayDELETE]			
	;mov dword[eax],ebx					


	movzx eax,byte[counter]
	add eax,1
	mov byte[counter],al				;counter ++
	mov ebx,[numDrones]
	cmp eax,ebx							;if finished drones
	jne make_Those_dron_rotines


;making the target
		push 8
		push 1
		call calloc						
		mov [Target],eax
		pop eax
		pop eax
		CreateTargetS

	mov eax,0
	mov [counter],al				;init counter
;making the drones Array
		mov eax,[numDrones]
		mov ebx,24
		mul ebx
		push eax
		push 1
		call calloc						
		mov [DronesArray],eax
		pop eax
		pop eax
		;filling the Drones Array
		start_loop:

		;generate randon vars fot started drone
		call RNDSpeedorLocPls
		mov eax,[Finalval]
		mov [var1],eax

		call RNDSpeedorLocPls
		mov eax,[Finalval]
		mov [var2],eax

		call RNDSpeedorLocPls
		mov eax,[Finalval]
		mov [var3],eax

		call RNDDegPls
		mov eax,[Finalval]
		mov [var4],eax

		movzx edx,byte[counter]
		mov eax,edx
		mov ebx,24
		mul ebx
		mov ebx,[DronesArray]
		add eax,ebx					;eax=cur start of drone

		movzx edx,byte[counter]
		add edx,1					;to start from drone 1 not 0
		mov dword[eax],edx			;putting the id 
		add eax,4
		mov ecx,[var1]
		mov dword[eax],ecx			;putting random position x 
		add eax,4
		mov ecx,[var2]
		mov dword[eax],ecx			;putting random position y  
		add eax,4
		mov ecx,[var3]
		mov dword[eax],ecx			;putting random speed 		
		add eax,4
		mov ecx,[var4]
		mov dword[eax],ecx;pai/2	;putting random deg in rad		

		add eax,4
		mov dword[eax],0			;putting score
		movzx edx,byte[counter] 
		add edx,1
		mov byte[counter],dl
		movzx ecx,byte[numDrones]
		;sub ecx,48
		cmp ecx,edx					;check if we finished numDrones
		jne start_loop

;if we here we finished Array
		;should start scheduler loop
	mov ebx,[RutineSchedular]
	mov [AddresCur],ebx
	call startCo 



end_of_func: 
	FFREE					 ;free the x87 subsystemm

	mov eax,[DronesArray]
	push eax
	call free				;delete the Array
	pop eax

	mov eax,[Target]
	push eax
	call free				;delete the Target
	pop eax

	mov eax,0
	mov [counter],al				;init counterr
	
	delete_Those_drone_rotines:
	movzx eax,byte[counter]
	mov edx,4
	mul edx
	mov ebx,[DronesRutineArray]			;points to the adres of the cur routin
	add eax,ebx
	mov eax,[eax]
	mov [newRoutine],eax

	FreeRuotinDrone
	
	movzx eax,byte[counter]
	add eax,1
	mov byte[counter],al				;counter ++
	mov ebx,[numDrones]
	cmp eax,ebx							;if finished droness
	jne delete_Those_drone_rotines

	mov eax,[RutineSchedular]
	mov [newRoutine],eax
	mov eax,[RutineSchedularDELETE]
	mov [STACKDELETE],eax
	FreeRuotin

	mov eax,[RutinePrinter]
	mov [newRoutine],eax
	mov eax,[RutinePrinterDELETE]
	mov [STACKDELETE],eax
	FreeRuotin

	mov eax,[RutineTarget]
	mov [newRoutine],eax
	mov eax,[RutineTargetDELETE]
	mov [STACKDELETE],eax
	FreeRuotin

	mov eax,[DronesRutineArrayDELETE]
	push eax
	call free				;delete the Array Rutine
	pop eax

	mov eax,[DronesRutineArray]
	push eax
	call free				;delete the Array Rutine
	pop eax

	popad                   ; Restore caller state (registers)
    mov     esp,ebp    		; place returned value where caller can see it
    pop     ebp             ; Restore caller state
    ret                     ; Back to caller






















