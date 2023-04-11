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

	ldr r1, =Input_data		//	r1 = Input_data�� �ּ�
	ldr r0, =Output_data	//	r0 = Output_data �ּ� -> �̰��� Ȯ���ϸ� ����� �� �� �ִ�
	mov r2, #32			//������ ���ƾ� �Ǵ� Ƚ��

	mov r4, #0				// r4 = copy ������ ���� ī����
	mov r5, r1				// r5 = src_addr
	mov r6, r0				// r6 = dst_addr
copy:

	add r4, r4, #1
	ldr r7, [r5], #4		// �ּҸ� 4�� �ø���
	str r7, [r6], #4
	cmp r4, r2				//�ּҸ� �� ������ ���� �޴´�
	blt copy
	mov r4, #0
				// r4 = outer_loop�� ī����
outer_loop:
	sub 	r12, r2, r4			// r10 = inner_counter�� �� Ƚ��
	sub		r12, r12, #1
	mov 	r5, #0				// r5 = inner_loop�� ���� ī����
	mov 	r6, r0				// r6 = ���� ��ġ
	ldr 	r7, [r6]			// r7 = ���� ����
	mov 	r8, r0				// r8 = ���� ū ������ �����͸� �ִ´�
	ldr 	r9, [r6]			// r9�� ���� ū ���ڸ� �ִ´�

inner_loop:
	add r5, r5, #1		//	inner_couter++
	mov r11, r5, LSL#2
	add r6, r0, r11		// ���� �ּҸ� r6�� �ش�
	ldr	r7, [r6]		// 	r7�� ���� ���ڸ� �޴´�

	cmp	r9, r7				//	���� ���ڿ� ���� ū ���� ��
	movle r9, r7			//	r9�� ���ٸ� ���� ���� r9�� �ִ´�
	movle r8, r6			// 	�����͵� �°� �ٲ��ش�

	cmp r5, r12				// inner_loop�� ī���Ͱ� �� ������ inner_loop�� �ݺ��Ѵ�
	bne	inner_loop

swap:
	str r7, [r8]
	str r9, [r6]			//	���� ���� ���� ū ���� swap ���ش�

	add	r4, r4, #1
	cmp	r2, r4
	bne	outer_loop		//r4�� r2 ���� �� ������ ������ �ٽ� ����