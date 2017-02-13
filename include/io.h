#ifndef __IO_H__
#define __IO_H__

extern inline void outb(short port, char const value);
extern inline char inb(short port);

extern inline void outb(short port, char const value) {
  __asm__ volatile ( "outb %0, %1" : : "a"(value), "Nd"(port) );
}

extern inline char inb(short port) {
  char ret;
  __asm__ volatile 	( "inb %1, %0"
			  : "=a"(ret)
			  : "Nd"(port) );
  
  return ret;
}


#endif
