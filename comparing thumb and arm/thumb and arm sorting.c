#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#pragma GCC target ("thumb") 	// thumb 모드를 실행
//#pragma GCC target ("arm")	// arm 모드를 실행




int csd_main()
{
	int indata[32] = { 2, 0, -7, -1, 3, 8, -4, 10,		// indata
	 -9, -16, 15, 13, 1, 4, -3, 14,
	 -8, -10, -15, 6, -13, -5, 9, 12,
	 -11, -14, -6, 11, 5, 7, -2, -12 };

	int outdata[32];

	int i, j, save;

	for (i=0; i<31; i++){						//비교군에서 가장 큰 데이터를 맨 뒤에 보냄
		for (j=0; j<31-i; j++){					//이미 확정된 뒤에 정렬된 데이터는 제외하고 비교함
			if (indata[j] > indata[j+1]){		//앞에 것보다 뒤에 것이 작다면 위치를 바꿈
				save = indata[j];
				indata[j] = indata[j+1];
				indata[j+1] = save;
			}
		}
	}

	for (int k=0; k<32; k++){			//정렬한 indata를 outdata로 옮겨줌
		outdata[k] = indata[k];
	}

	return 0;
}
