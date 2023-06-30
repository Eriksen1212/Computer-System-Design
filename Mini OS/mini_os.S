#include "csd_zynq_peripherals.h"
#include "uart_init.s"

#define	TIMER_INITIAL	30302

.align 5

csd_table:
	b .
	b .
	b .
	b .
	b .
	b .
	b csd_IRQ_ISR
	b .

.extern task1_c
.extern task2_c
.extern task3_c

.global main
main:

	// Disable interrupt: CPSR'I = 1
	cpsID i	//���ͷ�Ʈ ��Ȱ��ȭ

	cps #0x12	   	       // IRQ ���
	ldr	r13,=irq_stack_top // Stack pointer setup for IRQ mode

	cps #0x11		       // FIQ ���
	ldr	r13,=fiq_stack_top // stack pointer setup for FIQ mode

	cps #0x13		       // supervisor ���
	ldr	r13,=svc_stack_top // stack pointer setup for SVC mode */


	//task1, 2, 3�� ���� ���� �۾� �ݺ�
	// task1 setup
	ldr r1, =task1_c	//�� task�� ����, �켱 �ش� task�� �ڵ��� ���� �ּҸ� �ε�
	mov r4, r1
	add r4, r4, #4
	ldr r2, =task1_stack_top	//�� task�� stack�� �� �� �ּҸ� load
	mov r5, r2
	ldr r3, =task1_block_pointer	//�ش� task�� PCB�� �ּҸ� load
	str r4, [r6, #-4]
	str r5, [r6, #52]		//PCB�� task ���� ����
	mov r1, #0x10			//spsr�� user mode�� ����
	str r1, [r6, #-8]

	// task2 setup
	ldr r1, =task2_c
	mov r4, r1
	add r4, r4, #4
	ldr r2, =task2_stack_top
	mov r5, r2
	ldr r3, =task2_block_pointer
	mov r6, r3
	str r4, [r6, #-4]
	str r5, [r6, #52]
	mov r1, #0x10
	str r1, [r6, #-8]

	// task3 setup
	ldr r1, =task3_c
	mov r4, r1
	add r4, r4, #4
	ldr r2, =task3_stack_top
	mov r5, r2
	ldr r3, =task3_block_pointer
	mov r6, r3
	str r4, [r6, #-4]
	str r5, [r6, #52]
	mov r1, #0x10
	str r1, [r6, #-8]


	ldr	r13,=svc_stack_top // Stack pointer setup for SVC mode

	cps #0x1F	             // SYS mode�� ����

	// Set VBAR
	ldr     r0, =csd_table
	mcr     p15, 0, r0, c12, c0, 0
	dsb
	isb

	// ���ͷ�Ʈ Ȱ��ȭ
	cpsIE i

// ---------------------------
// Generic Interrupt Controller (GIC) setup - Begin
// ---------------------------

	// Distributor Control Register
	ldr r0, =GICD_CTLR
	ldr r1, [r0]
	mov r2, #1       //GIC Distributor�� Ȱ��ȭ
	orr r1, r1, r2
	str r1, [r0]
	ldr r3, [r0]

	 // Interrupt Set-Enable Register 0
	ldr r0, =GICD_ISENABLER0
	ldr r1, [r0]
	mov r2, #1 << 29   //��Ʈ 29�� �����Ͽ� Private Timer ���ͷ�Ʈ�� Ȱ��ȭ
	orr r1, r1, r2
	str r1, [r0]
	ldr r3, [r0]

	// Interrupt Priority Register #7
	ldr r0, =GICD_PRIOR7
	ldr r1, [r0]		//���ͷ�Ʈ �ҽ��� �켱������ ����
	mov r2, #0x1 << 8    // Private Timer�� �켱���� ����
	orr r1, r1, r2
	str r1, [r0]
	ldr r3, [r0]

	// CPU Interface Control Register
	ldr r0, =GICC_CTLR
	ldr r1, [r0]
	mov r2, #1        //GIC�� CPU �������̽��� Ȱ��ȭ
	orr r1, r1, r2
	str r1, [r0]
	ldr r3, [r0]

 	// Priority Mask Register
	ldr r0, =GICC_PMR
	ldr r1, [r0]
	mov r2, #0xFF     // GICC_PMR �������Ϳ� 0xFF�� ���� ������ ��� ���ͷ�Ʈ�� ���
	orr r1, r1, r2
	str r1, [r0]
	ldr r3, [r0]


	// Private Timer ����

 	// Private Timer Load Register
	ldr r0, =PRIVATE_LOAD
 	ldr r1, =#350000
 	str r1, [r0]

 	// Private Timer Control Register
  	ldr r0, =PRIVATE_CONTROL
 	mov r1, #10 << 8   // Prescalar
 	orr r1, r1, #7     // IRQ Enable, Auto-Reload, Timer Enable
 	str r1, [r0]

	UART_init

	cps #0x10	//user mode
	ldr sp, =task1_stack_top	//task1_stack_top�� �ִ� ���� sp�� load
	b task1_c	//task1 �ڵ�� �Ѿ

csd_IRQ_ISR:
	stmfd sp!, {r0-r12}	// ISR�� ���� ���� �Ϲ� ���������� ������ ���ÿ� ����
	mrs r0, spsr	//���� ���� ��������(SPSR)�� ��ũ ��������(LR)�� ���ÿ� ����
	stmfd sp!, {r0, lr}

	// interrupt load
	ldr r0, =GICC_IAR
	ldr r1, [r0]

	//Ÿ�̸� ���ͷ�Ʈ�� ���� bit�� Ŭ����
	ldr r0, =PRIVATE_STATUS
	mov r2, #1
	str r2, [r0]

	// end of interrupt
	ldr r0, =GICC_EOIR
	str r1, [r0]

	ldr r0, =tasknow	//���� task�� ��ȣ�� �ε�
	ldr r1, [r0]

	//tasknow�� ��ȣ�� ���� task�� ����
	cmp r1, #1
	beq task2

	cmp r1, #2
	beq task3

	cmp r1, #3
	beq task1

task1:
	// ���� task�� 1��
	cmp r1, #3
	moveq r1, #1
	streq r1, [r0]

	// ���� ���������� ���¸� pcb�� ����
	ldmfd sp!, {r0, r1}
	ldreq r2, =task3_block_pointer
	stmdb r2, {r0, r1}
	ldmfd sp!, {r0-r12}
	ldreq sp, =task3_block_pointer
	stmia sp, {r0-lr}^

	// pcb�κ��� �������� ����
	ldreq sp, =task1_block_pointer
	ldmdb sp, {r0, lr}
	msr spsr, r0
	ldmia sp, {r0-lr}^

	// sp �� ������
	ldreq sp, =irq_stack_top
	subs pc, lr, #4

task2:
	//���� task�� 2��
	cmp r1, #1
	moveq r1, #2
	streq r1, [r0]

	// ���� ���������� ���¸� pcb�� ����
	ldmfd sp!, {r0, r1}
	ldreq r2, =task1_block_pointer
	stmdb r2, {r0, r1}
	ldmfd sp!, {r0-r12}
	ldreq sp, =task1_block_pointer
	stmia sp, {r0-lr}^

	// pcb�κ��� �������� ����
	ldreq sp, =task2_block_pointer
	ldmdb sp, {r0, lr}
	msr spsr, r0
	ldmia sp, {r0-lr}^

	// sp �� ������
	ldreq sp, =irq_stack_top
	subs pc, lr, #4

task3:
	// ���� task�� 3����
	cmp r1, #2
	moveq r1, #3
	streq r1, [r0]

	// ���� ���������� ���¸� pcb�� ����
	ldmfd sp!, {r0, r1}
	ldreq r2, =task2_block_pointer
	stmdb r2, {r0, r1}
	ldmfd sp!, {r0-r12}
	ldreq sp, =task2_block_pointer
	stmia sp, {r0-lr}^

	// pcb�κ��� �������� ����
	ldreq sp, =task3_block_pointer
	ldmdb sp, {r0, lr}
	msr spsr, r0
	ldmia sp, {r0-lr}^

	// sp �� ������
	ldreq sp, =irq_stack_top
	subs pc, lr, #4

.data
.align 4

user_stack:    .space 1024
user_tack_top:
irq_stack:     .space 1024
irq_stack_top:
fiq_stack:     .space 1024
fiq_stack_top:
svc_stack:     .space 1024
svc_stack_top:

task1_stack:   .space 1024
task1_stack_top:
task2_stack:   .space 1024
task2_stack_top:
task3_stack:   .space 1024
task3_stack_top:

task1_block:     .space 8
task1_block_pointer: .space 60
task2_block:     .space 8
task2_block_pointer: .space 60
task3_block:     .space 8
task3_block_pointer: .space 60

tasknow: .word 1