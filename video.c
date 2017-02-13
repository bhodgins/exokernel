#include <video.h>

#define VGABUF_BASE    0xb8000
#define SCREEN_MAX_X   160
#define SCREEN_MAX_Y   25
#define VGABUF_MAX     VGABUF_BASE + (2 * ( SCREEN_MAX_X * SCREEN_MAX_Y))

#define vbuf_get_offset(cur_x, cur_y) video + 2 * (cur_x * cur_y)

volatile unsigned char *video = (volatile unsigned char *) VGABUF_BASE;

struct video_state {
  unsigned char cur_x;
  unsigned char cur_y;
  unsigned char color;
} video_state;

// This vga buffer handling implementation is bufferless. (No scroll saving)

void video_init(void) {
  video_state.cur_x = 0;
  video_state.cur_y = 0;
  video_state.color = 0;
}

void vputc(unsigned char c) {
  switch (c) {
  case '\n':
    break;
    
  default:
    *video = c;
    *(vbuf_get_offset(video_state.cur_x, video_state.cur_y)) = c;
    break;
  }
}

void vputs(unsigned char *str) {
  while (*str != '\0') {
    vputc(*str);
    str++;
  }
}
