
unsigned volatile char * gpio_led = (unsigned char *) 0x41200000;

int csd_main()
{

 int count;

 while (1) {

	for (count=0; count < 0x400000; count++) ;

	*gpio_led = 0xC3;

	for (count=0; count < 0x400000; count++) ;

	*gpio_led = 0x3C;

 }
	return 0;
}
