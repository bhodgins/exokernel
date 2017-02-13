/*OUTPUT_FORMAT("elf64-x86-64")
OUTPUT_ARCH("i386:x86-64") */
ENTRY(_start)

SECTIONS
{
	. = 1M;

	.boot_header : { *(.boot_header) }
	.boot_text :   { *(.boot_text)   }
	.text :        { *(.text)        }

	. = ALIGN(4096);
	.data :   { *(.data)   }
	.rodata : { *(.rodata) }

	PROVIDE(__data_end = .);

	.bss : { *(.bss) }
	PROVIDE(__bss_end = .);

/*
	.debug_str      : { *(.debug_str)      }
	.debug_loc      : { *(.debug_loc)      }
	.debug_abbrev   : { *(.debug_abbrev)   }
	.debug_info     : { *(.debug_info)     }
	.debug_macinfo  : { *(.debug_macinfo)  }
	.debug_pubnames : { *(.debug_pubnames) }
	.debug_pubtypes : { *(.debug_pubtypes) }
	.debug_line     : { *(.debug_line)     }
	.debug_aranges  : { *(.debug_aranges)  }
	.debug_frame    : { *(.debug_frame)    }
	.comment        : { *(.comment)        }
/*
	/* /DISCARD/ : { *(*) } */
}

