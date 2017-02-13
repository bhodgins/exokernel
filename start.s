[global _start]
extern __bss_end
extern __data_end

section .boot_header
_start:
	; Clear eax & ebx in a fancy way:
	xor eax, eax
	xor ebx, ebx

	; jump to the real beginning:
	jmp start32

%define FLAG_ALIGN	1 << 0
%define FLAG_MEMINFO	1 << 1
%define FLAG_USEAF	1 << 16

; Multiboot 1:
%define MB1_MAGIC	0x1BADB002
%define MB1_FLAGS	(FLAG_USEAF | FLAG_ALIGN | FLAG_MEMINFO)
%define MB1_CHECKSUM	-(MB1_MAGIC + MB1_FLAGS)

align 16
multiboot1:
	dd MB1_MAGIC
	dd MB1_FLAGS
	dd MB1_CHECKSUM
	dd multiboot1
	dd _start
	dd __data_end
	dd __bss_end
	dd start32
	dd 0
	dd 0
	dd 0
	dd 0
.end:

section .bss
align 4

stack_bottom:
resb 16384
stack_top:

section .data

GDT64:                           ; Global Descriptor Table (64-bit).
    .Null: equ $ - GDT64         ; The null descriptor.
    dw 0                         ; Limit (low).
    dw 0                         ; Base (low).
    db 0                         ; Base (middle)
    db 0                         ; Access.
    db 0                         ; Granularity.
    db 0                         ; Base (high).
    .Code: equ $ - GDT64         ; The code descriptor.
    dw 0                         ; Limit (low).
    dw 0                         ; Base (low).
    db 0                         ; Base (middle)
    db 10011010b                 ; Access (exec/read).
    db 00100000b                 ; Granularity.
    db 0                         ; Base (high).
    .Data: equ $ - GDT64         ; The data descriptor.
    dw 0                         ; Limit (low).
    dw 0                         ; Base (low).
    db 0                         ; Base (middle)
    db 10010010b                 ; Access (read/write).
    db 00000000b                 ; Granularity.
    db 0                         ; Base (high).
    .Pointer:                    ; The GDT-pointer.
    dw $ - GDT64 - 1             ; Limit.
    dq GDT64                     ; Base.
	
section .boot_text
[BITS 32]

align 16
start32:
	;; Fast A20:
	in al, 0x92
	test al, 2
	jnz .disable_paging
	or al, 2
	and al, 0xFE
	out 0x92, al
	
.disable_paging:
	mov eax, cr0 ; Set the A-register to control register 0.
	and eax, 01111111111111111111111111111111b     ; Clear the PG-bit, which is bit 31.
	mov cr0, eax     ; Set control register 0 to the A-register.

.clear_tables:
	mov edi, 0x1000    ; Set the destination index to 0x1000.
	mov cr3, edi       ; Set control register 3 to the destination index.
	xor eax, eax       ; Nullify the A-register.
	mov ecx, 4096      ; Set the C-register to 4096.
	rep stosd          ; Clear the memory.
	mov edi, cr3       ; Set the destination index to control register 3.

	mov DWORD [edi], 0x2003 ; Set the uint32_t at the destination index to 0x2003.
	add edi, 0x1000         ; Add 0x1000 to the destination index.
	mov DWORD [edi], 0x3003 ; Set the uint32_t at the destination index to 0x3003.
	add edi, 0x1000         ; Add 0x1000 to the destination index.
	mov DWORD [edi], 0x4003 ; Set the uint32_t at the destination index to 0x4003.
	add edi, 0x1000         ; Add 0x1000 to the destination index.

	mov ebx, 0x00000003     ; Set the B-register to 0x00000003.
	mov ecx, 512            ; Set the C-register to 512.
 
.SetEntry:
	mov DWORD [edi], ebx    ; Set the uint32_t at the destination index to the B-register.
	add ebx, 0x1000         ; Add 0x1000 to the B-register.
	add edi, 8              ; Add eight to the destination index.
	loop .SetEntry          ; Set the next entry.

.enable_pae:
	mov eax, cr4            ; Set the A-register to control register 4.
	or eax, 1 << 5          ; Set the PAE-bit, which is the 6th bit (bit 5).
	mov cr4, eax            ; Set control register 4 to the A-register.

	mov ecx, 0xC0000080     ; Set the C-register to 0xC0000080, which is the EFER MSR.
	rdmsr                   ; Read from the model-specific register.
	or eax, 1 << 8          ; Set the LM-bit which is the 9th bit (bit 8).
	wrmsr                   ; Write to the model-specific register.

.enable_paging:
	mov eax, cr0            ; Set the A-register to control register 0.
	or eax, 1 << 31 | 1<< 0 ; Set the PG-bit, which is the 31nd bit, and the PM-bit, which is the 0th bit.
	mov cr0, eax            ; Set control register 0 to the A-register.

.enter_64:
	lgdt [GDT64.Pointer]         ; Load the 64-bit global descriptor table.
	jmp GDT64.Code:Realm64       ; Set the code segment and enter 64-bit long mode.
	
	cli
.halt:	hlt
	jmp .halt

Realm64:
[bits 64]
	extern _main
	call _main
