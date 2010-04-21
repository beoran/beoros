/* Plan 9 asm kernel. */

#include "mem.h"
#include "x16.h"
#undef DELAY

#define PADDR(a)	((a) & ~KZERO)
#define KADDR(a)	(KZERO|(a))

/*
 * Some machine instructions not handled by 8[al].
 */
#define OP16		BYTE $0x66
#define DELAY		BYTE $0xEB; BYTE $0x00	/* JMP .+2 */
#define CPUID		BYTE $0x0F; BYTE $0xA2	/* CPUID, argument in AX */
#define WRMSR		BYTE $0x0F; BYTE $0x30	/* WRMSR, argument in AX/DX (lo/hi) */
#define RDTSC 		BYTE $0x0F; BYTE $0x31	/* RDTSC, result in AX/DX (lo/hi) */
#define RDMSR		BYTE $0x0F; BYTE $0x32	/* RDMSR, result in AX/DX (lo/hi) */
#define HLT		BYTE $0xF4
#define INVLPG	BYTE $0x0F; BYTE $0x01; BYTE $0x39	/* INVLPG (%ecx) */
#define WBINVD	BYTE $0x0F; BYTE $0x09

/*
 * Macros for calculating offsets within the page directory base
 * and page tables. Note that these are assembler-specific hence
 * the '<<2'.
 */
#define PDO(a)		(((((a))>>22) & 0x03FF)<<2)
#define PTO(a)		(((((a))>>12) & 0x03FF)<<2)

/*
 * Must be 4-byte aligned.
 */
TEXT _multibootheader(SB), $0
	LONG	$0x1BADB002			/* magic */
	LONG	$0x00010003			/* flags */
	LONG	$-(0x1BADB002 + 0x00010003)	/* checksum */
	LONG	$_multibootheader-KZERO(SB)	/* header_addr */
	LONG	$_start-KZERO(SB)		/* load_addr */
	LONG	$edata-KZERO(SB)		/* load_end_addr */
	LONG	$end-KZERO(SB)			/* bss_end_addr */
	LONG	$_start-KZERO(SB)		/* entry_addr */
	LONG	$0				/* mode_type */
	LONG	$0				/* width */
	LONG	$0				/* height */
	LONG	$0				/* depth */

/*
 * In protected mode with paging turned off and segment registers setup
 * to linear map all memory. Entered via a jump to PADDR(entry),
 * the physical address of the virtual kernel entry point of KADDR(entry).
 * Make the basic page tables for processor 0. Six pages are needed for
 * the basic set:
 *	a page directory;
 *	page tables for mapping the first 8MB of physical memory to KZERO;
 *	a page for the GDT;
 *	virtual and physical pages for mapping the Mach structure.
 * The remaining PTEs will be allocated later when memory is sized.
 * An identity mmu map is also needed for the switch to virtual mode.
 * This identity mapping is removed once the MMU is going and the JMP has
 * been made to virtual memory.
 */
TEXT _start(SB), $0
_loop_start:
	CLI					/* make sure interrupts are off */
        JMP _loop_start  /* loop forever */
