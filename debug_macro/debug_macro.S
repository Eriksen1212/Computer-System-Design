#include "uart_init.s"

.macro debug_macro
	sub sp, sp, #8 //sp�� ���� ���ҽ�Ŵ
	stmdb sp!, {r13, r14}
	stmdb sp!, {r0-r12}	//���������� ������ ��Ƴ��� ���� ����
	add sp, sp, #68
	mrs r0, cpsr	// r0�� cpsr�� ���
	stmdb sp!, {r0}	//�����Ѵ�
	mov r0, r15
	sub r0, r0, #32
	stmdb sp!, {r0}
	sub sp, sp, #60

	uart_init
	bl printing_uart

	ldr r1, [r13]		//�����ߴ� cpsr�� �����´�
	msr cpsr, r1
	sub r13, r13, #64

	ldmia sp!, {r0-r12}  //��� ���Ҵ� ������ �ҷ��´�
	add sp, sp, #4
	ldmia sp!, {r14}
	add sp, sp, #8


.endm

printing_uart:		//r0���� ���� ������ ����ϱ� ���� ����, �ݺ��۾�
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
	add r1, r1, #8 //�����Ҷ� 8 ������ sp�� �����߱� ����
	bl reg_printing

	ldr r1, =sr14
	bl print_val
	ldr r1, [r13],#4
	bl reg_printing

	ldr r1, =sr15
	bl print_val
	ldr r1, [r13],#4
	bl reg_printing // r0���� r15���� print

	ldr r1, =scpsr
	bl print_val

	bl uart_print_cpsr // print_cpsr�� ����
	mov r14, r10
	mov pc, lr


uart_print_cpsr:
	mov r11, r14

	ldr r1, [r13]
	bl checking
	//nzcr �κ� ���
	and r4, r1, #0x80000000
	cmp r4, #0x80000000
	movne r3, #110  //�ƽ�Ű n ���
	moveq r3, #78  //�ƽ�Ű N ���
	strb	r3, [r0, #0x30]

	bl checking

	and r4, r1, #0x40000000
	cmp r4, #0x40000000
	movne r3, #122	//�ƽ�Ű z ���
	moveq r3, #90	//�ƽ�Ű Z ���
	strb	r3, [r0, #0x30]

	bl checking

	and r4, r1, #0x20000000
	cmp r4, #0x20000000
	movne r3, #99	// �ƽ�Ű c ���
	moveq r3, #67 	//�ƽ�Ű C ���
	strb r3, [r0, #0x30]

	bl checking

	and r4, r1, #0x10000000
	cmp r4, #0x10000000
	movne r3, #118	//�ƽ�Ű v ���
	moveq r3, #86 	//�ƽ�Ű V ���
	strb r3, [r0, #0x30]

	ldr r1, =scomma
	bl print_val

	ldr r1, [r13]
	bl checking

	//IF ����� ����

	and r4, r1, #0x00000080
	cmp r4, #0x80
	moveq r3, #73 //�ƽ�Ű 'I'
	movne r3, #0
	strb r3, [r0, #0x30]

	bl checking

	and r4, r1, #0x00000040
	cmp r4, #0x40
	moveq r3, #70 //�ƽ�Ű 'F'
	movne r3, #0
	strb r3, [r0, #0x30]

	ldr r1, [r13]


	ldr r8, =#0x01000020
	and r4, r1, r8
	cmp r4, #0x01000000
	ldreq r1, =Jazellemode // ������ Jazelle
	ldrgt r1, =ThumbEEmode // ũ�� ThumbEE
	cmplt r4, #0x00000020  // 0x20�� cmp
	ldrlt r1, =ARMmode // ������ ARM
	ldreq r1, =Thumbmode // ������ Thumb

	bl print_val

	ldr r1, =scmode
	bl print_val

	ldr r1, [r13]

	// �񱳸� ���� current mode�� �ľ��� ��
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

	// �˸��� current_mode�� ����Ʈ�Ѵ�
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

		ldr 	r2, [r0, #0x2c]	//���ο� ���� ���� �� �ֵ��� ����ִ��� Ȯ��
		and	r2, r2, #0x8
		cmp	r2, #0x8
		bne check_loop

		ldrb r3, [r1], #1
		cmp r3, #0x00
		beq exit_loop		// 0x00�� �ε�ƴٸ� loop�� Ż��

		strb r3, [r0, #0x30]	@ �ε�� byte�� ����
		b check_loop

	exit_loop:
	mov pc, lr



reg_printing:

		ldr r0, =0xE0001000
		mov r5, #9

	starting_loop:
		ldr 	r2, [r0, #0x2c]	 //����ִ��� Ȯ��
		and	r2, r2, #0x8
		cmp	r2, #0x8
		bne	starting_loop

		cmp r5, #9
		moveq r4, #48	//r5�� 9�� ������, ASCII �ڵ� 48 (���� '0')�� r3 �������Ϳ� ����
		streq r4, [r0, #0x30]
		cmp r5, #8
		moveq r4, #120	//r5�� 8�� ������, ASCII �ڵ� 120 (���� 'x')�� r3 �������Ϳ� ����
		streq r4, [r0, #0x30]
		sub r5, r5, #1 //r5�� ���� 1�� ����
		bne starting_loop

	give_loop:

		ldr 	r2, [r0, #0x2c]
		and	r2, r2, #0x8		//�������Ͱ� ����ִ��� Ȯ��
		cmp	r2, #0x8			//��� �ִٸ� ����
		bne	give_loop

		mov r7, #0  // making_format�� ����
		mov r8, #1
		mov r8, r8, LSL r5
		mov r8, r8, LSL r5
		mov r8, r8, LSL r5
		mov r8, r8, LSL r5
		subs r9, r1, #0x80000000 //������ ������ �����ϱ� ���� �� ���� �������͸� �ʱ�ȭ�ϰ� ���� ����
		subpls r1, r1, #0x80000000
		cmp r9, #0
		movge r9, #8
		movlt r9, #0

		//�� �ڸ����� �и��ϴ� ������ ����
		//�־��� ���ڸ� 16���� ������ �� �ڸ����� ����
		making_format:
			subs r1, r1, r8
			addge r7, r7, #1
			bge making_format //r1�� ���� ����� ��� ������ ��� ����

		add r1, r1, r8	//r1�� r8�� ���Ͽ� ���� ���� ����

		//ASCII ��ȯ
		to_ascii:
			add r7, r7, r9
			cmp r7, #10
			addge r7, r7, #87	//r7�� 10 �̻��̸� r7�� 87�� ���Ͽ� ASCII �ڵ�� ��ȯ
			addlt r7, r7, #48	//r7�� 9���� ������ r7�� 48�� ���Ͽ� ASCII �ڵ�� ��ȯ

		mov r6, #3
		cmp r5, r6
		bne skip_underscore
		mov r4, #0x5F // �ƽ�Ű  '_'
		str r4, [r0, #0x30] // '_'�� 4���� 4�� ���̿� ����Ѵ�
		ldr r2, [r0, #0x2c]
		and	r2, r2, #0x8
		cmp	r2, #0x8
		bne skip_underscore

	skip_underscore:
		sub r5, r5, #1
		str	r7, [r0, #0x30]	// 0x48�� ä������
		cmp r5, #-1
		bgt	give_loop		//��� �������͸� ����� ������ �ݺ�

	mov pc, lr




//������� Ȯ���ϰ� �������� Ż���Ŵ
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