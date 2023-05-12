#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#pragma GCC target ("thumb") 	// thumb ��带 ����
//#pragma GCC target ("arm")	// arm ��带 ����




int csd_main()
{
	int indata[32] = { 2, 0, -7, -1, 3, 8, -4, 10,		// indata
	 -9, -16, 15, 13, 1, 4, -3, 14,
	 -8, -10, -15, 6, -13, -5, 9, 12,
	 -11, -14, -6, 11, 5, 7, -2, -12 };

	int outdata[32];

	int i, j, save;

	for (i=0; i<31; i++){						//�񱳱����� ���� ū �����͸� �� �ڿ� ����
		for (j=0; j<31-i; j++){					//�̹� Ȯ���� �ڿ� ���ĵ� �����ʹ� �����ϰ� ����
			if (indata[j] > indata[j+1]){		//�տ� �ͺ��� �ڿ� ���� �۴ٸ� ��ġ�� �ٲ�
				save = indata[j];
				indata[j] = indata[j+1];
				indata[j+1] = save;
			}
		}
	}

	for (int k=0; k<32; k++){			//������ indata�� outdata�� �Ű���
		outdata[k] = indata[k];
	}

	return 0;
}
