#include <asm/vmlinux.lds.h>
#include <asm/page.h>

OUTPUT_ARCH(csky)
ENTRY(_start)

#ifndef __cskyBE__
jiffies = jiffies_64;
#else
jiffies = jiffies_64 + 4;
#endif

#define VBR_BASE \
	. = ALIGN(1024); \
	VMLINUX_SYMBOL(vec_base) = .; \
	. += 512;

SECTIONS
{
	. = PAGE_OFFSET + (CONFIG_RAM_BASE - PHYS_OFFSET);
	_text = .;
	HEAD_TEXT_SECTION
	VBR_BASE

	_stext = .;
	.text : AT(ADDR(.text) - LOAD_OFFSET) {
		IRQENTRY_TEXT
		SOFTIRQENTRY_TEXT
		TEXT_TEXT
		SCHED_TEXT
		CPUIDLE_TEXT
		LOCK_TEXT
		KPROBES_TEXT
		*(.fixup)
		*(.gnu.warning)
	} = 0
	_etext = .;

	_sdata = .;
	RO_DATA_SECTION(PAGE_SIZE)
	RW_DATA_SECTION(L1_CACHE_BYTES, PAGE_SIZE, THREAD_SIZE)
	_edata = .;

	NOTES
	EXCEPTION_TABLE(L1_CACHE_BYTES)
	BSS_SECTION(L1_CACHE_BYTES, PAGE_SIZE, L1_CACHE_BYTES)

	/* __init_begin __init_end must be page aligned for free_initmem */
	. = ALIGN(PAGE_SIZE);
	__init_begin = .;

	INIT_TEXT_SECTION(PAGE_SIZE)
	INIT_DATA_SECTION(PAGE_SIZE)
	PERCPU_SECTION(L1_CACHE_BYTES)

	. = ALIGN(PAGE_SIZE);
	__init_end = .;

	_end = . ;

	STABS_DEBUG
	DWARF_DEBUG

	DISCARDS
}

