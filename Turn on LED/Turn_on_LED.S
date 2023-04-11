// ------------------------------------------
//  Author: Prof. Taeweon Suh
//          Computer Science & Engineering
//          College of Informatics, Korea Univ.
//  Date:   March 29, 2020
// ------------------------------------------
// Define the input and output data sections
/* Define variables */

#define csd_LED_ADDR	0x41200000
#define csd_SWITCH_ADDR	0x41210000
.extern csd_main

.global main
main:
	ldr r4, =csd_LED_ADDR // LED �ּ� ����
	mov r5, #1  // ������ 1�� �ش�
	str r5, [r4] // 1 ���� r4�� ����.
	loop:
		ldr r3, =csd_SWITCH_ADDR // csd_main���� �ּҸ� ������ ���� r0�� ���
		bl csd_main // csd_main ȣ��

		add r5, r5, r5 // �� ���� ����ġ�� �����ϱ� ���� ���� �ι辿 �ø�
		cmp r5, #0x0000080 // 0x00000080������ �������� �� �̻��̸� 1�� �ʱ�ȭ����� ��
		movgt r5, #1 // ����ٸ� 1�� �ʱ�ȭ
		str r5, [r4] //R5�� R4�� ����
		b loop