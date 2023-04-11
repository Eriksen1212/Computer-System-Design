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
	ldr r4, =csd_LED_ADDR // LED 주소 저장
	mov r5, #1  // 값으로 1을 준다
	str r5, [r4] // 1 값을 r4에 저장.
	loop:
		ldr r3, =csd_SWITCH_ADDR // csd_main으로 주소를 보내기 위해 r0을 사용
		bl csd_main // csd_main 호출

		add r5, r5, r5 // 그 다음 스위치로 접근하기 위해 값을 두배씩 올림
		cmp r5, #0x0000080 // 0x00000080까지는 괜찮은데 그 이상이면 1로 초기화해줘야 함
		movgt r5, #1 // 벗어났다면 1로 초기화
		str r5, [r4] //R5를 R4에 저장
		b loop
