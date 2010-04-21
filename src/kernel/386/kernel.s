//
// boot.s -- Kernel start location. Also defines multiboot header.
// Based on Bran's kernel development tutorial file start.asm
//

#define MBOOT_PAGE_ALIGN    $1       // Load kernel and modules on a page boundary
#define MBOOT_MEM_INFO      $2       // Provide your kernel with memory info
#define MBOOT_HEADER_MAGIC  $0x1BADB002 // Multiboot Magic value
// NOTE: We do not use MBOOT_AOUT_KLUDGE. It means that GRUB does not
// pass us a symbol table.
#define MBOOT_HEADER_FLAGS  MBOOT_PAGE_ALIGN | MBOOT_MEM_INFO
#define MBOOT_CHECKSUM      -(MBOOT_HEADER_MAGIC + MBOOT_HEADER_FLAGS)

//[BITS 32]                       // All instructions should be 32-bit.

//[GLOBAL mboot]                  // Make 'mboot' accessible from C.
//[EXTERN code]                   // Start of the '.text' section.
//[EXTERN bss]                    // Start of the .bss section.
//[EXTERN end]                    // End of the last loadable section.

mboot:
  LONG  MBOOT_HEADER_MAGIC        // GRUB will search for this value on each
                                  // 4-byte boundary in your kernel file
  LONG  MBOOT_HEADER_FLAGS        // How GRUB should load your file / settings
  LONG  MBOOT_CHECKSUM            // To ensure that the above values are correct
   
  LONG  $mboot                    // Location of this descriptor
  LONG  $.text                    // Start of kernel '.text' (code) section.
  LONG  $.data                    // End of kernel '.data' section.
  LONG  $end                      // End of kernel.
  LONG  $star                     // Kernel entry point (initial EIP).

//[GLOBAL start]                  // Kernel entry point.
//[EXTERN main]                   // This is the entry point of our C code

start:
  PUSH    ebx                   // Load multiboot header location

  // Execute the kernel:
  CLI                         // Disable interrupts.
  // call main                   // call our main() function.
  JMP start                   // Enter an infinite loop, to stop the processor
                              // executing whatever rubbish is in the memory
                              // after our kernel! 
end:

