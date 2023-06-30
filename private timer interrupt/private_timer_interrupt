#include "csd_zynq_peripherals.h"
#include "uart_regs.h"
#include "uart_init.s"

#define TIMER_INITIAL	0x3000000

.align 5

csd_vector_table:
	b .
	b .
	b .
	b .
	b .
	b .
	b timer_call
	b .

.global main
main:

	// Disable interrupt: CPSR'I = 1
    cpsid i

    cps #0x12	// IRQ mode
    ldr sp, =irq_stack_top	// Stack pointer setup for IRQ mode

    cps #0x1F	// SYS mode

 	// Set VBAR (Vector Base Address Register) to my vector table
    ldr r0, =csd_vector_table
    mcr p15, 0, r0, c12, c0, 0
    dsb
    isb

	// Enable interrupt: CPSR'I = 0
    cpsie i

// ---------------------------
// Generic Interrupt Controller (GIC) setup - Begin
// ---------------------------

	// Distributor Control Register
	ldr r0, =GICD_CTLR
	ldr r1, [r0]
	mov r2, #1       // Enable
	orr r1, r1, r2
	str r1, [r0]

	 // Interrupt Set-Enable Register 0
	ldr r0, =GICD_ISENABLER0
	ldr r1, [r0]
	mov r2, #1 << 29	// Enable #29 (Private Timer)
	orr r1, r1, r2
	str r1, [r0]

	// Interrupt Priority Register #7
	ldr r0, =GICD_PRIOR7
	ldr r1, [r0]
	mov r2, #0x10 << 8	// Priority 16 for ID# 29 (Private Timer)
	orr r1, r1, r2
	str r1, [r0]

	// CPU Interface Control Register
	ldr r0, =GICC_CTLR
	ldr r1, [r0]
	mov r2, #1	// Enable
	orr r1, r1, r2
	str r1, [r0]

	// CPU Interface Interrupt Priority Mask Register
	ldr r0, =GICC_PMR
	ldr r1, [r0]
	mov r2, #0xFF	//Lowest
	orr r1, r1, r2
	str r1, [r0]

// ---------------------------
// Generic Interrupt Controller (GIC) setup - End
// ---------------------------

// ---------------------------
// Private Timer setup - Begin
// ---------------------------

	// Private Timer Load Register
    ldr r0, =PRIVATE_LOAD
    ldr r1, =TIMER_INITIAL
    str r1, [r0]

 	// Private Timer Control Register
  	ldr r0, =PRIVATE_CONTROL
 	mov r1, #10 << 8   // Prescalar
 	orr r1, r1, #7     // IRQ Enable, Auto-Reload, Timer Enable
 	str r1, [r0]


// ----------------------------
// Private Timer setup - End
// ----------------------------


forever:
	b forever

timer_call:
    cpsid i

	ldr r0, =GICC_IAR
	ldr r12, [r0]

    ldr r0, =uart_TX_RX_FIFO0	//UART 송수신 FIFO 레지스터
    ldr r1, =uart_Channel_sts_reg0	//UART 채널 상태 레지스터
	ldr r2, =time_format	//시간 정보
	ldr r3, =time_limit
	mov r4, #1

time_modify:
	ldrb r5, [r2], #1
	ldr r6, [r3], #4

	teq r6, #0
	blt time_modify
	beq display_time

	add r5, r5, r4
	teq r5, r6
	subeq r5, r5, r5
	addeq r5, r5, #48
	addeq r4, r4, #0
	subne r4, r4, r4

	//현재 시간 값을 증가시키고, 증가된 시간 값이 한계값을 초과하는지 확인
	//초과하면 시간 값을 0으로 초기화
	//시간 값을 증가시킬 변수 r4를 1로 설정, 초과하지 않으면 r4를 0으로 설정


	strb r5, [r2, #-1]
	b time_modify

display_time:
    ldr r7, [r1]
	tst r7, #0b10000
	bne display_time

	ldrb r6, [r2, #-1]!
	strb r6, [r0]
	teq r6, #0x00
	bne display_time

	//시간 정보를 읽어서 UART 송수신 FIFO에 쓰는 부분
	//읽어온 시간 정보가 NULL 문자가 아니면 계속해서 시간 정보를 UART로 전송

	@ clear interrupt status bit
	ldr r0, =PRIVATE_STATUS
	mov r1, #1			//타이머 인터럽트의 상태를 클리어
	str r1, [r0]

	@ end of interrupt
	ldr r0, =GICC_EOIR
	str r12, [r0]

    cpsie i		//인터럽트 루틴을 종료
	subs pc, lr, #4

.data
.align 4

time_format:
	.byte 0x00
	.ascii "00:00:00\r"
	.byte 0x0D

time_limit:	.word -1, 58, 54, -1, 58, 54, -1, 58, 54, 0

irq_stack:		.space 1024
irq_stack_top:
