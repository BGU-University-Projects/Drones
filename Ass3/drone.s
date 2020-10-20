section	.rodata			; we define (global) read-only variables in .rodata section
extern Target
	extern DronesArray
	extern printf
  	extern fprintf 
	extern numDrones
	extern turnCounter
	extern numDis
	extern DronesRutineArray
	extern RutineSchedular
	extern RutinePrinter
	extern RutineTarget
	extern do_resume
	extern resume
	extern droneTurnNumber

	extern RNDSpeedorLocPls
	extern RNDDegPls
	extern Finalval
	extern RNDDegChange
	extern RNDSpeedChange

	global Routine_start_drone

section	.data
	newSpeed: dd 0
	newDegree: dd 0
	curDrone: dd 0
	resultX: dd 0
	resultY: dd 0
	generalresult: dd 0
	curSpeed:dd 0
	curRadian:dd 0
	curX:dd 0
	Zero:dd 0
	curY:dd 0
	MAXSPEED:dd 100.0
	MAXDEG: dd 6.283
	MAXEdge:dd 100.0
	disSQR:dd 0
	var1:dd 2.3
	var2:dd 1.5
	var:dd 0



section .bss			; we define (global) uninitialized variables in .bss section
	

section .text
	
%macro MoveToCurDirection 0
		mov edx,[curDrone]	;edx=cur Drone
		mov eax,dword[edx+4]
		mov [curX],eax	;ecx=x position
		mov eax,dword[edx+8]
		mov [curY],eax	;ecx=Y position
		mov eax,dword[edx+12]
		mov [curSpeed],eax	;ebx=speed
		mov eax,dword[edx+16]
		mov [curRadian],eax	;ebx=degree is in radianl

		;new x=(cur x pos)+ (speed)(sin cur degree)
		;new y=(cur y pos)+ (speed)(cos cur degree)

	;move X
	finit ; initialize the x87 subsystem
		fld dword[curRadian]		;put in the degree in rad
		Fsin						;doing SIN
		fmul dword[curSpeed]		;multiply the speed
		fadd dword[curX]
		fst dword[curX]				;update the result to variable X

	;move Y
	finit ; initialize the x87 subsystem
		fld dword[curRadian]		;put in the degree in rad
		Fcos						;doing SIN
		fmul dword[curSpeed]		;multiply the speed
		fadd dword[curY]
		fst dword[curY]				;update the result to variable Y

	;check cur X<100
		finit ; initialize the x87 subsystem
		fld dword[MAXEdge]
		fld dword[curX]
		fcomip
		;fsub dword[MAXEdge]
		;fst dword[var]
		;mov eax,dword[var]
		;cmp eax,0
		jc noNeedX
		finit
		fld dword[curX]
		fsub dword[MAXEdge]
		fst dword[var]
		mov ecx,dword[var]
		mov dword[curX],ecx
		noNeedX:

		;check cur X>0
		finit ; initialize the x87 subsystem
		fld dword[curX]
		fld dword[Zero]
		fcomip
		;fsub dword[MAXEdge]
		;fst dword[var]
		;mov eax,dword[var]
		;cmp eax,0
		jc noNeedX2
		finit
		fld dword[curX]
		fadd dword[MAXEdge]
		fst dword[var]
		mov ecx,dword[var]
		mov dword[curX],ecx
		noNeedX2:

	;check cur Y<100
		finit ; initialize the x87 subsystem
		;fld dword[curY]
		;fsub dword[MAXEdge]
		;fst dword[var]
		;mov eax,dword[var]
		;cmp eax,0
		fld dword[MAXEdge]
		fld dword[curY]
		fcomip
		jc noNeedY
		finit
		fld dword[curY]
		fsub dword[MAXEdge]
		fst dword[var]
		mov ecx,dword[var]
		mov dword[curY],ecx
		noNeedY:

		;check cur y>0
		finit ; initialize the x87 subsystem
		fld dword[curY]
		fld dword[Zero]
		fcomip
		;fsub dword[MAXEdge]
		;fst dword[var]
		;mov eax,dword[var]
		;cmp eax,0
		jc noNeedY2
		finit
		fld dword[curY]
		fadd dword[MAXEdge]
		fst dword[var]
		mov ecx,dword[var]
		mov dword[curY],ecx
		noNeedY2:

	;update the drone
		mov edx,[curDrone]	;edx=cur Drone
		mov eax,dword[curX]
		mov dword[edx+4],eax	;x position
		mov eax,dword[curY]
		mov dword[edx+8],eax	;Y position

	%endmacro

%macro mayDestroy 0
	mov edx,[curDrone]
	mov eax,dword[edx+4]	;Drone cur X pos
	mov ecx,[Target]
	mov ecx,dword[ecx]		;Target cur X pos

	finit
	mov [curX],eax
	fld dword[curX]
	mov [curX],ecx
	fsub dword[curX]
	fst st1
	fmulp		;^2
	fst dword[resultX]
	;sub eax,ecx
	;mul eax				;^2
	;mov [resultX],eax
	mov eax,dword[edx+8]	;Drone cur Y pos
	mov ecx,[Target]
	mov ecx,dword[ecx+4]		;Target cur Y pos
	finit
		mov [curX],eax
	fld dword[curX]
		mov [curX],ecx
	fsub dword[curX]
	fst st1
	fmulp		;^2
	fst dword[resultY]

	finit			;make disSQR
	;mov eax,[numDis]
	fld dword[numDis]
	;fsub ecx
	fst st1
	fmulp		;^2
	fst dword[disSQR]
	;sub eax,ecx
	;mul eax				;^2
	;mov [resultY],eax
	;add eax,[resultX]		
	;mov ebx,eax				;ebx is the cur dis
	;mov eax,[numDis]
	;mul eax				;eax is dis to hit
	finit
	fld dword[resultX]
	fadd dword[resultY]				
	;fsub dword[disSQR]
	;fst dword[curX]
	;mov eax,[curX]
	;cmp eax,0
	fld dword[disSQR]
	fcomip
	jc %%.NoHit
	;if we here we can hit!!!
	;inc the Score
	mov edx,[curDrone]
	mov eax,dword[edx+20]
	add eax,1
	mov dword[edx+20],eax
	mov ebx,[RutineTarget]
	call resume
	%%.NoHit:
	%endmacro

Routine_start_drone:

DroneTurn:

	mov eax,[droneTurnNumber]
	mov ebx,24
	mul ebx
	add eax,[DronesArray]	;points to the cur Drone
	mov [curDrone],eax

;check if mayDestroy
	mayDestroy
;generate new changes
	call RNDDegChange
	mov eax,[Finalval]
	mov dword[newDegree],eax; generate a random number in range [-60,60] degrees, with 16 bit resolution
	call RNDSpeedChange
	mov eax,[Finalval]
	mov dword[newSpeed],eax ; generate random number in range [-10,10], with 16 bit resolution

;do the movment
	MoveToCurDirection
;update new degree
	
	mov eax,[curDrone]
	mov ebx,[eax+16]		;ebx=cur degree
	mov ecx,[newDegree]		;ecx=degree change
	;add ebx,ecx				
	finit
	finit
	mov [var],ebx
	fld dword[var]
	mov [var],ecx
	fadd dword[var]			;cur+change degree
	fst dword[var]			
	mov eax,[curDrone]
	mov ebx,[var]
	mov dword[eax+16],ebx	;update cur deg
	fld dword[MAXDEG]
	fld dword[var]
	fcomip
	jc noNeedDeg
	fld dword[var]
	fsub dword[MAXDEG]
	fst dword[var]			
	mov eax,[curDrone]
	mov ebx,[var]
	mov dword[eax+16],ebx	;update cur deg
	noNeedDeg:
	finit
	finit
	finit


;update new speed
	mov eax,[curDrone]
	mov ebx,[eax+12]		;ebx=cur speed
	mov ecx,[newSpeed]		;ecx=speed change
	;add ebx,ecx				
	finit
	finit
	mov [var],ebx
	fld dword[var]
	mov [var],ecx
	fadd dword[var]			;cur+change speed
	fst dword[var]			
	mov eax,[curDrone]
	mov ebx,[var]
	mov dword[eax+12],ebx	;update cur speed
	fld dword[MAXSPEED]
	fld dword[var]
	fcomip
	jc noNeedspeed
	fld dword[var]
	fsub dword[MAXSPEED]
	fst dword[var]			
	mov eax,[curDrone]
	mov ebx,[var]
	mov dword[eax+12],ebx	;update cur speed
	noNeedspeed:
	finit
	finit
	finit

;resume
	mov ebx,[RutineSchedular]
	call resume
jmp Routine_start_drone


















