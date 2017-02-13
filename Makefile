AS       := nasm
CC       := clang

ifdef GENASM
TOASM     = -S -mllvm --x86-asm-syntax=intel
endif

ifdef DEBUG
DEBUGFLAGS     = -s -S
endif

ifdef CURSES
CURSESFLAGS = -nographic -curses
endif

CFLAGS   := --std=c11 -g $(TOASM) -Wall -Wwrite-strings -Wmissing-prototypes -Wmissing-declarations -Wredundant-decls -Wnested-externs -Winline -Wno-long-long -Wuninitialized -Wconversion -Wstrict-prototypes -Wno-empty-body -Wextra -pedantic -ffreestanding -I include
LDFLAGS  := -m elf_x86_64_fbsd -T link.ld -z max-page-size=0x1000
CFILES   := $(shell find . -name "*.c" -type f)
ASFLAGS  := -f elf64
ASFILES  := $(shell find . -name "*.s" -type f)
OBJFILES := $(patsubst %.s, %.o, $(ASFILES)) $(patsubst %.c, %.o, $(CFILES))

.PHONY: all clean


all: $(OBJFILES) kimage

kimage:
	$(LD) $(LDFLAGS) $(OBJFILES) -o kimage

%.c: %
	$(CC) $(CFLAGS) -o $@ $<

%.s:
	$(AS) $(ASFLAGS -o $@ $<

%.o: %.s %.c

clean:
	-rm -f $(OBJFILES) kimage *.core kimage.bin f.iso

run: clean all
	# Uncomment for grub:
	#cp ./kimage ./iso
	#grub-mkrescue -o f.iso iso
	#qemu-system-x86_64 -serial udp:127.0.0.1:4555 -cpu qemu64 -serial udp:127.0.0.1:4555 -hdb f.iso -nographic -boot b $(CURSESFLAGS) $(DEBUG)

	qemu-system-x86_64 -serial udp:127.0.0.1:4555 -cpu qemu64 $(CURSESFLAGS) $(DEBUGFLAGS) -kernel kimage

