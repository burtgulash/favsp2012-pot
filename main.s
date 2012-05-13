		.h8300s

; ------------- symbol -------------
		.equ	syscall,0x1FF00
		.equ	GETS,0x113
		.equ	PUTS,0x114
		

; ------------- data -------------
		.data

delenec:	.asciz	"Delenec: "
delitel:	.asciz	"Delitel: "
podil:		.asciz	"Podil: "
zbytek:		.asciz	"Zbytek: "
buffer:		.space	32+1		; staci 4+1

par_nec:	.long	delenec
par_tel:	.long	delitel
par_dil:	.long	podil
par_tek:	.long	zbytek
par_buf:	.long	buffer

; -------- stack ------
		.align	2
		.space	128
stck:


; ------------- text -------------
		.text
		.global	_start



_div:	
		push.l	ER6
		mov.l	ER7,ER6
		push.l	ER1
		push.l	ER2
		push.l	ER3
		push.l	ER4
		; ------------------------
		

		mov.l	@(8,ER6),ER0	; a
		mov.l	@(12,ER6),ER1	; b	
		
		xor.w	R2,R2			; q
		mov.w	R1,R3			; x
		
		mov.w	R0,R4
		shlr.w	R4
		

L1:
		cmp.w	R4,R3				; R3 > R4 -> L2
		bhi		L2
		shll.w	R3
		bra 	shift_loop
L2:


L3:
		cmp.w	R1,R3				; R3 < R1 -> L4
		blo		L4
		
		cmp.w	R3,R0				; R0 < R3 -> L5
		blo		L5
		or.w	#1,R2
		sub.w	R3,R0
L5:
		shlr.w	R3
		shll.w	R2
		
		bra		L3
L4:

		shlr.w	R2				; fix last redundant shift
		
		mov.w	R0,E0
		xor.w	R0,R0
		or.w	R2,R0


		; ------------------------
		pop.l	R4	
		pop.l	R3
		pop.l	R2
		pop.l	R1
		mov.l	ER6,ER7
		pop.l	ER6
		rts




_from_hex:
		push.l	ER6
		mov.l	ER7,ER6	
		push.l	ER1
		push.l	ER2
		push.l	ER3
		; ------------------------

		mov.l	@(8,ER6),ER1
		mov.w	#16,R3
		xor.l	ER0,ER0

L6:
		mov.b	@ER1,R2L
		cmp.b	#0,R2L	; test for end of string (\r, \n or '0' ?)
		beq		L7
		add.b	#-'0',R2L
		cmp.b	#10,R2L
		blt		L8
		add.b	#('0'-'A'+10),R2L
L8:
		mulxs.w	R3,ER0
		and.w	#0xFF,R0
		add.w	R2,R0

		inc.l	#1,ER1
		bra		L6
L7:	

		; ------------------------
		pop.L	ER3
		pop.l	ER2
		pop.l	ER1
		mov.l	ER6,ER7
		pop.l	ER6




_to_hex:
		push.l	ER6
		mov.l	ER7,ER6
		push.l	ER1
		push.l	ER2
		push.l	ER3
		push.l	ER4
		; ------------------------

		mov.l	@(8,ER6),ER1
		mov.l	@(12,ER6),ER0
		mov.w	#16,R3
		xor.l	ER4,ER4

L9:
		cmp.w	#0,R0
		beq		L11
		divxs.w	R3,ER0
		mov.w	E0,R2
		add.b	#'0',R2L
		cmp.b	#('0'+10),R2L
		blt		L10
		add.b	#('A'-'0'-10),R2L
L10:
		push.b	R2L
		inc.l	ER4
		bra		L9

L11:
		cmp.l	#0,ER4	
		beq		L12
		pop.b	R2L
		mov.b	R2L,@ER1
		inc.l	#1,ER1
		dec.l	#1,ER4
		bra 	L11
L12:

		; ------------------------
		pop.l	ER4
		pop.l	ER3
		pop.l	ER2
		pop.l	ER1
		mov.l	ER6,ER7
		pop.l	ER6


.macro	PRINT	PAR
		push.w	R0
		push.l	ER1
		mov.w	#PUTS,R0
		mov.l	#\PAR,ER1
		jsr		@syscall
		pop.l	ER1
		pop.w	R0
.endm

.macro	INPUT	PAR
		push.w	R0
		push.l	ER1
		mov.w	#GETS,R0
		mov.l	#\PAR,ER1
		jsr		@syscall
		pop.l	ER1
		pop.w	R0
.endm


_start:	mov.l	#stck,ER7

; TODO printovat newliny po kazdym printu
; --- ziskat delenec ---
		PRINT 	par_nec
		INPUT	par_buf
		push.l	#buffer
		jsr		@_from_hex
		add.l	#4,ER7
		mov.w	R0,R1

; --- ziskat delitel ---
		PRINT 	par_tel
		INPUT	par_buf
		push.l	#buffer
		jsr		@_from_hex
		add.l	#4,ER7
		mov.w	R0,R2

; --- vydelit ---
		push.w	R2
		push.w	R1
		jsr		@_div	; Podil v R0, Zbytek v E0
		add.l	#8,ER7

; --- TODO print vysledky ---
		PRINT	par_dil
		push.l	#buffer 	; --- FIXME je tam #, @ nebo nic? ---
		push.w	R0			; --- FIXME parametry spatne?
		jsr		@_to_hex
		add.l	#8,ER7
		PRINT 	par_buf
		
; --- TODO print zbytek ---
		PRINT	par_tek

mbora:		
		bra	mbora

		.end

