#include "uart_init.s"

.macro debug_macro
	sub sp, sp, #8 //sp의 값을 감소시킴
	stmdb sp!, {r13, r14}
	stmdb sp!, {r0-r12}	//레지스터의 값들을 담아놓아 값을 유지
	add sp, sp, #68
	mrs r0, cpsr	// r0에 cpsr을 담고
	stmdb sp!, {r0}	//보존한다
	mov r0, r15
	sub r0, r0, #32
	stmdb sp!, {r0}
	sub sp, sp, #60

	uart_init
	bl printing_uart

	ldr r1, [r13]		//보존했던 cpsr을 가져온다
	msr cpsr, r1
	sub r13, r13, #64

	ldmia sp!, {r0-r12}  //담아 놓았던 값들을 불러온다
	add sp, sp, #4
	ldmia sp!, {r14}
	add sp, sp, #8


.endm

printing_uart:		//r0부터 뒤의 값들을 출력하기 위한 과정, 반복작업
	mov r10, r14
	ldr r1, =line
	bl print_val

	ldr r1, =sr0
	bl print_val
	ldr r1, [r13],#4
	bl reg_printing

	ldr r1, =sr1
	bl print_val
	ldr r1, [r13],#4
	bl reg_printing

	ldr r1, =sr2
	bl print_val
	ldr r1, [r13],#4
	bl reg_printing

	ldr r1, =sr3
	bl print_val
	ldr r1, [r13],#4
	bl reg_printing

	ldr r1, =sr4
	bl print_val
	ldr r1, [r13],#4
	bl reg_printing

	ldr r1, =sr5
	bl print_val
	ldr r1, [r13],#4
	bl reg_printing

	ldr r1, =sr6
	bl print_val
	ldr r1, [r13],#4
	bl reg_printing

	ldr r1, =sr7
	bl print_val
	ldr r1, [r13],#4
	bl reg_printing

	ldr r1, =sr8
	bl print_val
	ldr r1, [r13],#4
	bl reg_printing

	ldr r1, =sr9
	bl print_val
	ldr r1, [r13],#4
	bl reg_printing

	ldr r1, =sr10
	bl print_val
	ldr r1, [r13],#4
	bl reg_printing

	ldr r1, =sr11
	bl print_val
	ldr r1, [r13],#4
	bl reg_printing

	ldr r1, =sr12
	bl print_val
	ldr r1, [r13],#4
	bl reg_printing

	ldr r1, =sr13
	bl print_val
	ldr r1, [r13],#4
	add r1, r1, #8 //저장할때 8 감소한 sp를 저장했기 때문
	bl reg_printing

	ldr r1, =sr14
	bl print_val
	ldr r1, [r13],#4
	bl reg_printing

	ldr r1, =sr15
	bl print_val
	ldr r1, [r13],#4
	bl reg_printing // r0부터 r15까지 print

	ldr r1, =scpsr
	bl print_val

	bl uart_print_cpsr // print_cpsr로 진입
	mov r14, r10
	mov pc, lr


uart_print_cpsr:
	mov r11, r14

	ldr r1, [r13]
	bl checking
	//nzcr 부분 출력
	and r4, r1, #0x80000000
	cmp r4, #0x80000000
	movne r3, #110  //아스키 n 출력
	moveq r3, #78  //아스키 N 출력
	strb	r3, [r0, #0x30]

	bl checking

	and r4, r1, #0x40000000
	cmp r4, #0x40000000
	movne r3, #122	//아스키 z 출력
	moveq r3, #90	//아스키 Z 출력
	strb	r3, [r0, #0x30]

	bl checking

	and r4, r1, #0x20000000
	cmp r4, #0x20000000
	movne r3, #99	// 아스키 c 출력
	moveq r3, #67 	//아스키 C 출력
	strb r3, [r0, #0x30]

	bl checking

	and r4, r1, #0x10000000
	cmp r4, #0x10000000
	movne r3, #118	//아스키 v 출력
	moveq r3, #86 	//아스키 V 출력
	strb r3, [r0, #0x30]

	ldr r1, =scomma
	bl print_val

	ldr r1, [r13]
	bl checking

	//IF 출력을 위해

	and r4, r1, #0x00000080
	cmp r4, #0x80
	moveq r3, #73 //아스키 'I'
	movne r3, #0
	strb r3, [r0, #0x30]

	bl checking

	and r4, r1, #0x00000040
	cmp r4, #0x40
	moveq r3, #70 //아스키 'F'
	movne r3, #0
	strb r3, [r0, #0x30]

	ldr r1, [r13]


	ldr r8, =#0x01000020
	and r4, r1, r8
	cmp r4, #0x01000000
	ldreq r1, =Jazellemode // 같으면 Jazelle
	ldrgt r1, =ThumbEEmode // 크면 ThumbEE
	cmplt r4, #0x00000020  // 0x20과 cmp
	ldrlt r1, =ARMmode // 작으면 ARM
	ldreq r1, =Thumbmode // 같으면 Thumb

	bl print_val

	ldr r1, =scmode
	bl print_val

	ldr r1, [r13]

	// 비교를 통해 current mode를 파악한 뒤
	and r4, r1, #0x0000001F
	cmp r4, #0x1F
	ldreq r1, =SYSpr
	cmpne r4, #0x1B
	ldreq r1, =UNDpr
	cmpne r4, #0x1A
	ldreq r1, =HYPpr
	cmpne r4, #0x17
	ldreq r1, =ABTpr
	cmpne r4, #0x16
	ldreq r1, =MONpr
	cmpne r4, #0x13
	ldreq r1, =SVCpr
	cmpne r4, #0x12
	ldreq r1, =IRQpr
	cmpne r4, #0x11
	ldreq r1, =FIQpr
	cmpne r4, #0x10
	ldreq r1, =USRpr

	// 알맞은 current_mode를 프린트한다
	bl print_val

	ldr r1, =sopen
	bl print_val

	ldr r1, [r13]
	bl reg_printing

	ldr r1, =sclose
	bl print_val

	mov r14, r11
	mov pc, lr



//uart_print_string:
print_val:
	ldr r0, =0xE0001000

	check_loop:

		ldr 	r2, [r0, #0x2c]	//새로운 값을 받을 수 있도록 비어있는지 확인
		and	r2, r2, #0x8
		cmp	r2, #0x8
		bne check_loop

		ldrb r3, [r1], #1
		cmp r3, #0x00
		beq exit_loop		// 0x00이 로드됐다면 loop를 탈출

		strb r3, [r0, #0x30]	@ 로드된 byte를 저장
		b check_loop

	exit_loop:
	mov pc, lr



reg_printing:

		ldr r0, =0xE0001000
		mov r5, #9

	starting_loop:
		ldr 	r2, [r0, #0x2c]	 //비어있는지 확인
		and	r2, r2, #0x8
		cmp	r2, #0x8
		bne	starting_loop

		cmp r5, #9
		moveq r4, #48	//r5가 9와 같으면, ASCII 코드 48 (문자 '0')를 r3 레지스터에 저장
		streq r4, [r0, #0x30]
		cmp r5, #8
		moveq r4, #120	//r5가 8과 같으면, ASCII 코드 120 (문자 'x')를 r3 레지스터에 저장
		streq r4, [r0, #0x30]
		sub r5, r5, #1 //r5의 값을 1씩 감소
		bne starting_loop

	give_loop:

		ldr 	r2, [r0, #0x2c]
		and	r2, r2, #0x8		//레지스터가 비어있는지 확인
		cmp	r2, #0x8			//비어 있다면 진행
		bne	give_loop

		mov r7, #0  // making_format을 위해
		mov r8, #1
		mov r8, r8, LSL r5
		mov r8, r8, LSL r5
		mov r8, r8, LSL r5
		mov r8, r8, LSL r5
		subs r9, r1, #0x80000000 //나누기 연산을 수행하기 전에 몇 가지 레지스터를 초기화하고 값을 조정
		subpls r1, r1, #0x80000000
		cmp r9, #0
		movge r9, #8
		movlt r9, #0

		//각 자릿수를 분리하는 과정을 수행
		//주어진 숫자를 16진수 형식의 각 자릿수로 나눔
		making_format:
			subs r1, r1, r8
			addge r7, r7, #1
			bge making_format //r1의 값이 양수일 경우 루프를 계속 수행

		add r1, r1, r8	//r1에 r8을 더하여 원래 값을 복원

		//ASCII 변환
		to_ascii:
			add r7, r7, r9
			cmp r7, #10
			addge r7, r7, #87	//r7이 10 이상이면 r7에 87을 더하여 ASCII 코드로 변환
			addlt r7, r7, #48	//r7이 9보다 작으면 r7에 48을 더하여 ASCII 코드로 변환

		mov r6, #3
		cmp r5, r6
		bne skip_underscore
		mov r4, #0x5F // 아스키  '_'
		str r4, [r0, #0x30] // '_'를 4개와 4개 사이에 출력한다
		ldr r2, [r0, #0x2c]
		and	r2, r2, #0x8
		cmp	r2, #0x8
		bne skip_underscore

	skip_underscore:
		sub r5, r5, #1
		str	r7, [r0, #0x30]	// 0x48을 채워넣음
		cmp r5, #-1
		bgt	give_loop		//모든 레지스터를 출력할 때까지 반복

	mov pc, lr




//비었는지 확인하고 괜찮으면 탈출시킴
checking:
	ldr 	r2, [r0, #0x2c]	@ get Channel Status Register
	and	r2, r2, #0x8		@ get Transmit Buffer Empty bit(bit[3:3])
	cmp	r2, #0x8
	moveq pc, lr				@ check if TxFIFO is empty and ready to receive new data
	bne checking



.data
line:
	.byte 0x0D
	.byte 0x0A
	.ascii "--------------------------------------------------------------------------------------"
	.byte 0x0D
	.byte 0x0A
	.byte 0x00
scomma:
	.ascii ", "
	.byte 0x00
sr0:
	.ascii "r0  = "
	.byte 0x00
sr1:
	.ascii ", r1  = "
	.byte 0x00
sr2:
	.ascii ", r2  = "
	.byte 0x00
sr3:
	.ascii ", r3  = "
	.byte 0x00
sr4:
	.byte 0x0D
	.byte 0x0A
	.ascii "r4  = "
	.byte 0x00
sr5:
	.ascii ", r5  = "
	.byte 0x00
sr6:
	.ascii ", r6  = "
	.byte 0x00
sr7:
	.ascii ", r7  = "
	.byte 0x00
sr8:
	.byte 0x0D
	.byte 0x0A
	.ascii "r8  = "
	.byte 0x00
sr9:
	.ascii ", r9  = "
	.byte 0x00
sr10:
	.ascii ", r10 = "
	.byte 0x00
sr11:
	.ascii ", r11 = "
	.byte 0x00
sr12:
	.byte 0x0D
	.byte 0x0A
	.ascii "r12 = "
	.byte 0x00
sr13:
	.ascii ", r13 = "
	.byte 0x00
sr14:
	.ascii ", r14 = "
	.byte 0x00
sr15:
	.ascii ", r15 = "
	.byte 0x00
scpsr:
	.byte 0x0D
	.byte 0x0A
	.ascii "cpsr = "
	.byte 0x00
scmode:
	.ascii ", current mode = "
	.byte 0x00
sopen:
	.ascii " ( ="
	.byte 0x00
sclose:
	.ascii ")"
	.byte 0x0D
	.byte 0x0A
	.ascii "--------------------------------------------------------------------------------------"
	.byte 0x0D
	.byte 0x0A
	.byte 0x00

Thumbmode:
	.ascii ", Thumb mode"
	.byte 0x00
ThumbEEmode:
	.ascii ", ThumbEE mode"
	.byte 0x00
ARMmode:
	.ascii ", ARM mode"
	.byte 0x00
Jazellemode:
	.ascii ", Jazelle mode"
	.byte 0x00

SYSpr:
	.ascii "SYS"
	.byte 0x00
USRpr:
	.ascii "USR"
	.byte 0x00
FIQpr:
	.ascii "FIQ"
	.byte 0x00
IRQpr:
	.ascii "IRQ"
	.byte 0x00
SVCpr:
	.ascii "SVC"
	.byte 0x00
MONpr:
	.ascii "MON"
	.byte 0x00
ABTpr:
	.ascii "ABT"
	.byte 0x00
UNDpr:
	.ascii "UND"
	.byte 0x00
HYPpr:
	.ascii "HYP"
	.byte 0x00


.text
