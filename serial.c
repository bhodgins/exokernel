
#include <serial.h>
#include <io.h>

static int serial_transmit_empty(short port);

void serial_init(short port) {
  outb(port + 1, 0x00);       // Disable all interrupts
  outb(port + 3, (char)0x80); // Enable DLAB (set baud rate divisor)
  outb(port + 0, 0x03);       // Set divisor to 3 (lo byte) 38400 baud
  outb(port + 1, 0x00);       //                  (hi byte)
  outb(port + 3, 0x03);       // 8 bits, no parity, one stop bit
  outb(port + 2, (char)0xC7); // Enable FIFO, clear them, with 14-byte threshold
  outb(port + 4, 0x0B);       // IRQs enabled, RTS/DSR set
}

static int serial_transmit_empty(short port) {
  return inb(port + 5) & 0x20;
}
 
void sputc(short port, char const c) {
  for(;;) { if (serial_transmit_empty(port)) break; } 
  outb(port,c);
}

void sputs(short port, char const *msg) {
  for (; *msg != '\0'; ++msg) sputc(port, *msg);
}
