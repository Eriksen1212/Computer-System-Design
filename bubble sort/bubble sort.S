// ------------------------------------------
//  Author: Prof. Taeweon Suh
//          Computer Science & Engineering
//          College of Informatics, Korea Univ.
//  Date:   March 29, 2020
// ------------------------------------------
// Define the input and output data sections
/* Define variables */
.data
.align 4
Input_data:
    .word 2, 0, -7, -1, 3, 8, -4, 10
    .word -9, -16, 15, 13, 1, 4, -3, 14
    .word -8, -10, -15, 6, -13, -5, 9, 12
    .word -11, -14, -6, 11, 5, 7, -2, -12

Output_data:
    .word 0, 0, 0, 0, 0, 0, 0, 0
    .word 0, 0, 0, 0, 0, 0, 0, 0
    .word 0, 0, 0, 0, 0, 0, 0, 0
    .word 0, 0, 0, 0, 0, 0, 0, 0

#define csd_LED_ADDR 0x41200000
.extern csd_main
.global main

main:

	ldr r1, =Input_data		//	r1 = Input_data의 주소
	ldr r0, =Output_data	//	r0 = Output_data 주소 -> 이곳을 확인하면 결과를 알 수 있다
	mov r2, #32			//루프를 돌아야 되는 횟수

	mov r4, #0				// r4 = copy 루프를 위한 카운터
	mov r5, r1				// r5 = src_addr
	mov r6, r0				// r6 = dst_addr
copy:

	add r4, r4, #1
	ldr r7, [r5], #4		// 주소를 4씩 올린다
	str r7, [r6], #4
	cmp r4, r2				//주소를 돌 때까지 값을 받는다
	blt copy
	mov r4, #0
				// r4 = outer_loop의 카운터
outer_loop:
	sub 	r12, r2, r4			// r10 = inner_counter가 돌 횟수
	sub		r12, r12, #1
	mov 	r5, #0				// r5 = inner_loop를 위한 카운터
	mov 	r6, r0				// r6 = 현재 위치
	ldr 	r7, [r6]			// r7 = 현재 숫자
	mov 	r8, r0				// r8 = 가장 큰 숫자의 포인터를 넣는다
	ldr 	r9, [r6]			// r9에 가장 큰 숫자를 넣는다

inner_loop:
	add r5, r5, #1		//	inner_couter++
	mov r11, r5, LSL#2
	add r6, r0, r11		// 현재 주소를 r6에 준다
	ldr	r7, [r6]		// 	r7에 현재 숫자를 받는다

	cmp	r9, r7				//	현재 숫자와 가장 큰 숫자 비교
	movle r9, r7			//	r9가 적다면 현재 값을 r9에 넣는다
	movle r8, r6			// 	포인터도 맞게 바꿔준다

	cmp r5, r12				// inner_loop의 카운터가 찰 때까지 inner_loop를 반복한다
	bne	inner_loop

swap:
	str r7, [r8]
	str r9, [r6]			//	현재 값과 가장 큰 값을 swap 해준다

	add	r4, r4, #1
	cmp	r2, r4
	bne	outer_loop		//r4이 r2 값이 될 때까지 루프를 다시 돈다
