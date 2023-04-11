#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int csd_main(int* addr)
{
	int val;
	val = *addr; // csd_SWITCH_ADDR 주소에 있는 값을 전달한다

	if(val==128){ // LD7
		usleep(100000);
	}
	else if(val==64){ // LD6
		usleep(200000);
	}
	else if(val==32){ // LD5
		usleep(300000);
	}
	else if(val==16){// LD4
		usleep(400000);
	}
	else if(val==8){// LD3
		usleep(500000);
	}
	else if(val==4){// LD2
		usleep(600000);
	}
	else if(val==2){// LD1
		usleep(700000);
	}
	else if(val==1){// LD0
		usleep(800000);
	}
	else{
		usleep(1000000);
	}
}
