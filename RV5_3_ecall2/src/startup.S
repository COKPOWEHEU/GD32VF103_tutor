.include "gd32vf103.inc"

.text
.section .start
.global _start
_start:
  la sp, _stack_end
  
  la t0, trap_entry
    andi t0, t0, ~(64-1) #выравнивание адреса должно быть минимум на 64 байта
    ori t0, t0, CSR_MTVEC_ECLIC
  csrw CSR_MTVEC, t0
  
  call trap_uart_init
  
  j main
