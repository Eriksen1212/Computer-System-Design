#include "csd_zynq_peripherals.h"

#define csd_SWI_ADDR 0x41210000

.extern csd_main

.section .csd_boot,"ax"

.align 8
csd_entry:
	b csd_reset
	b .
	b .
	b .
	b .
	b .
	b csd_irq
	b .

.global main
csd_reset:
main:
	bl using_cache
	mov r2, #0

forever:
	ldr r0,  =csd_SWI_ADDR	//����ġ�� ����
	ldr r1, [r0]	//r0 �������Ϳ� ����� �ּҿ��� ���� �о� r1 �������Ϳ� ����
	and r3, r1, #0x1	//����ġ�� ���� ������ r3�� 1, ���� ������ 0

	cmp r3, #1		//����ġ�� ���� �ִٸ�
	tsteq r2, #1
	moveq r2, #0
	bleq using_cache	//using_cache�� �Ѿ

	cmp r3, #0		//����ġ�� ���� �ִٸ�
	tsteq r2, #0
	moveq r2, #1
	bleq no_cache		//no_cache�� �Ѿ


	bl  csd_main
	b forever

no_cache:

	// Read Cache Type Register (CTR)
	mrc p15, 0, r1, c0, c0, 1

	// Read Cache Level ID Register (CLIDR)
	mrc p15, 1, r2, c0, c0, 1
	@------------------------
	@ Disable Caches (L2)
	@------------------------
	ldreq r0, =L2_reg1_ctrl
    moveq r1, #0x0
    streq r1, [r0]
	@------------------------
	@ Disable Caches (IL1, DL1)
	@------------------------
	mrceq		p15, 0, r0, c1, c0, 0	@ read control register (CP15 register1)
	biceq		r0, r0, #4096		    @ disable I bit (Instruction Cache)
	biceq		r0, r0, #4		        @ disable C bit (Data and Unified Caches)
	mcreq		p15, 0, r0, c1, c0, 0	@ write control register (CP15 register2)


	// read SCTLR (System Control Register) to r0
	mrc	p15, 0, r0, c1, c0, 0

	mov pc, lr


using_cache:

	// Read Cache Type Register (CTR)
	mrc p15, 0, r1, c0, c0, 1

	// Read Cache Level ID Register (CLIDR)
	mrc p15, 1, r2, c0, c0, 1

		@------------------------
	@ Enable Caches (L2)
	@------------------------
	ldreq r0, =L2_reg1_ctrl
    moveq r1, #0x1
    streq r1, [r0]

	@------------------------
	@ Enable Caches (IL1, DL1)
	@------------------------
	mrceq		p15, 0, r0, c1, c0, 0	@ read control register (CP15 register1)
	orreq		r0, r0, #(1<<12)	    @ Enable I bit (Instruction Cache)
	orreq		r0, r0, #(1<<2)         @ Enable C bit (Data and Unified Caches)
	mcreq		p15, 0, r0, c1, c0, 0	@ write control register (CP15 register2)



	// read SCTLR (System Control Register) to r0
	mrc	p15, 0, r0, c1, c0, 0

	mov pc, lr


csd_irq:
	b .

.end