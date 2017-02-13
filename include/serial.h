#ifndef __SERIAL_H__
#define __SERIAL_H__

#define SERIAL_COM1 0x3f8

void sputc(short port, char const c);
void sputs(short port, char const *msg);
void serial_init(short port);

#endif
