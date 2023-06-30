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
	cpsID i	//인터럽트 비활성화

	cps #0x12	   	       // IRQ 모드
	ldr	r13,=irq_stack_top // Stack pointer setup for IRQ mode

	cps #0x11		       // FIQ 모드
	ldr	r13,=fiq_stack_top // stack pointer setup for FIQ mode

	cps #0x13		       // supervisor 모드
	ldr	r13,=svc_stack_top // stack pointer setup for SVC mode */


	//task1, 2, 3에 대한 같은 작업 반복
	// task1 setup
	ldr r1, =task1_c	//각 task에 대해, 우선 해당 task의 코드의 시작 주소를 로드
	mov r4, r1
	add r4, r4, #4
	ldr r2, =task1_stack_top	//각 task의 stack의 맨 위 주소를 load
	mov r5, r2
	ldr r3, =task1_block_pointer	//해당 task의 PCB의 주소를 load
	str r4, [r6, #-4]
	str r5, [r6, #52]		//PCB에 task 정보 저장
	mov r1, #0x10			//spsr을 user mode로 설정
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

	cps #0x1F	             // SYS mode로 설정

	// Set VBAR
	ldr     r0, =csd_table
	mcr     p15, 0, r0, c12, c0, 0
	dsb
	isb

	// 인터럽트 활성화
	cpsIE i

// ---------------------------
// Generic Interrupt Controller (GIC) setup - Begin
// ---------------------------

	// Distributor Control Register
	ldr r0, =GICD_CTLR
	ldr r1, [r0]
	mov r2, #1       //GIC Distributor를 활성화
	orr r1, r1, r2
	str r1, [r0]
	ldr r3, [r0]

	 // Interrupt Set-Enable Register 0
	ldr r0, =GICD_ISENABLER0
	ldr r1, [r0]
	mov r2, #1 << 29   //비트 29를 설정하여 Private Timer 인터럽트를 활성화
	orr r1, r1, r2
	str r1, [r0]
	ldr r3, [r0]

	// Interrupt Priority Register #7
	ldr r0, =GICD_PRIOR7
	ldr r1, [r0]		//인터럽트 소스의 우선순위를 설정
	mov r2, #0x1 << 8    // Private Timer의 우선순위 설정
	orr r1, r1, r2
	str r1, [r0]
	ldr r3, [r0]

	// CPU Interface Control Register
	ldr r0, =GICC_CTLR
	ldr r1, [r0]
	mov r2, #1        //GIC의 CPU 인터페이스를 활성화
	orr r1, r1, r2
	str r1, [r0]
	ldr r3, [r0]

 	// Priority Mask Register
	ldr r0, =GICC_PMR
	ldr r1, [r0]
	mov r2, #0xFF     // GICC_PMR 레지스터에 0xFF를 쓰는 것으로 모든 인터럽트를 허용
	orr r1, r1, r2
	str r1, [r0]
	ldr r3, [r0]


	// Private Timer 설정

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
	ldr sp, =task1_stack_top	//task1_stack_top에 있는 값을 sp로 load
	b task1_c	//task1 코드로 넘어감

csd_IRQ_ISR:
	stmfd sp!, {r0-r12}	// ISR에 들어가기 전에 일반 레지스터의 내용을 스택에 저장
	mrs r0, spsr	//현재 상태 레지스터(SPSR)와 링크 레지스터(LR)를 스택에 저장
	stmfd sp!, {r0, lr}

	// interrupt load
	ldr r0, =GICC_IAR
	ldr r1, [r0]

	//타이머 인터럽트의 상태 bit를 클리어
	ldr r0, =PRIVATE_STATUS
	mov r2, #1
	str r2, [r0]

	// end of interrupt
	ldr r0, =GICC_EOIR
	str r1, [r0]

	ldr r0, =tasknow	//현재 task의 번호를 로드
	ldr r1, [r0]

	//tasknow의 번호에 따라 task를 결정
	cmp r1, #1
	beq task2

	cmp r1, #2
	beq task3

	cmp r1, #3
	beq task1

task1:
	// 현재 task를 1로
	cmp r1, #3
	moveq r1, #1
	streq r1, [r0]

	// 현재 레지스터의 상태를 pcb에 저장
	ldmfd sp!, {r0, r1}
	ldreq r2, =task3_block_pointer
	stmdb r2, {r0, r1}
	ldmfd sp!, {r0-r12}
	ldreq sp, =task3_block_pointer
	stmia sp, {r0-lr}^

	// pcb로부터 레지스터 복원
	ldreq sp, =task1_block_pointer
	ldmdb sp, {r0, lr}
	msr spsr, r0
	ldmia sp, {r0-lr}^

	// sp 값 가져옴
	ldreq sp, =irq_stack_top
	subs pc, lr, #4

task2:
	//현재 task를 2로
	cmp r1, #1
	moveq r1, #2
	streq r1, [r0]

	// 현재 레지스터의 상태를 pcb에 저장
	ldmfd sp!, {r0, r1}
	ldreq r2, =task1_block_pointer
	stmdb r2, {r0, r1}
	ldmfd sp!, {r0-r12}
	ldreq sp, =task1_block_pointer
	stmia sp, {r0-lr}^

	// pcb로부터 레지스터 복원
	ldreq sp, =task2_block_pointer
	ldmdb sp, {r0, lr}
	msr spsr, r0
	ldmia sp, {r0-lr}^

	// sp 값 가져옴
	ldreq sp, =irq_stack_top
	subs pc, lr, #4

task3:
	// 현재 task를 3으로
	cmp r1, #2
	moveq r1, #3
	streq r1, [r0]

	// 현재 레지스터의 상태를 pcb에 저장
	ldmfd sp!, {r0, r1}
	ldreq r2, =task2_block_pointer
	stmdb r2, {r0, r1}
	ldmfd sp!, {r0-r12}
	ldreq sp, =task2_block_pointer
	stmia sp, {r0-lr}^

	// pcb로부터 레지스터 복원
	ldreq sp, =task3_block_pointer
	ldmdb sp, {r0, lr}
	msr spsr, r0
	ldmia sp, {r0-lr}^

	// sp 값 가져옴
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
