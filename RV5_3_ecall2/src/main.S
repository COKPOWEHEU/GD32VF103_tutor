.include "gd32vf103.inc"

#GPIOB
.equ RLED, 5
.equ YLED, 6
.equ GLED, 7

.equ LED, GLED

.text
.global main
main:
  //RCU_APB2EN |= RCU_APB2EN_PBEN
  PORT_AND_OR RCU_APB2EN, 0xFFFFFFFF, ( RCU_APB2EN_PBEN )
  
  PORT_AND_OR GPIOB_CTL0, (~(GPIO_MASK<<(RLED*4))), (GPIO_PP50<<(RLED*4))
  PORT_AND_OR GPIOB_CTL0, (~(GPIO_MASK<<(GLED*4))), (GPIO_PP50<<(GLED*4))
  PORT_AND_OR GPIOB_CTL0, (~(GPIO_MASK<<(YLED*4))), (GPIO_PP50<<(YLED*4))

  li a7, 4
  la a0, outstr
  ecall
  
  la a0, promtstr
  li a7, ECALL_PRINT_STR
  ecall
  
  li a7, ECALL_READ_INT
  ecall
  mv s0, a0
  
  li a7, ECALL_READ_INT
  ecall
  
  add s0, a0, s0
  
  la a0, crlf
  li a7, ECALL_PRINT_STR
  ecall
  
  mv a0, s0
  li a7, ECALL_PRINT_INT
  ecall
  
  la a0, crlf
  li a7, ECALL_PRINT_STR
  ecall
  
MAIN_LOOP:
  li s0, GPIOB_OCTL
  lw s1, 0(s0)
    xori s1, s1, (1<<LED)
  sw s1, 0(s0)
  
  li t0, 200000
sleep:
  addi t0, t0, -1
  bnez t0, sleep
  
  j MAIN_LOOP
  


.text
crlf: .asciz "\r\n"
outstr: .asciz "Hello world\r\n"
promtstr: .asciz "Input a, b > "

.bss
buf: .space 100

