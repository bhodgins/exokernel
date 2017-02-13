 
#include <types.h>
#include <video.h>
#include <serial.h>

void _main(void);

void _main(void) {
  //video_init();
  //vputs("Hello, World!");
  serial_init(SERIAL_COM1);
  vputc('X');
  sputc(SERIAL_COM1, 'A');
  sputs(SERIAL_COM1, "Hello, World!");
  
  for(;;);
}
