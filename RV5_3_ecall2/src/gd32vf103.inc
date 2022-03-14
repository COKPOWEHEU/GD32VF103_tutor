.equ CSR_MTVT2, 0x7EC
.equ CSR_MTVEC, 0x305
.equ CSR_MCAUSE,0x342
.equ CSR_MEPC,  0x341
.equ CSR_MTVEC_ECLIC, 3
.equ CSR_MSTATUS, 0x300
.equ MSTATUS_MIE, (1<<3)

.equ RCU_APB2EN, 0x40021018
.equ RCU_APB2EN_AFEN, (1<<0)
.equ RCU_APB2EN_PAEN, (1<<2)
.equ RCU_APB2EN_PBEN, (1<<3)
.equ RCU_APB2EN_USART0EN, (1<<14)
.equ GPIOA_BASE, 0x40010800
.equ GPIOB_BASE, 0x40010C00
.equ GPIOA_CTL0, (GPIOA_BASE + 0x00)
.equ GPIOA_CTL1, (GPIOA_BASE + 0x04)
.equ GPIOB_CTL0, (GPIOB_BASE + 0x00)
.equ GPIOB_CTL1, (GPIOB_BASE + 0x04)
.equ GPIOB_OCTL, (GPIOB_BASE + 0x0C)

.equ GPIO_MASK,		0b1111
.equ GPIO_HIZ,		0b0100
.equ GPIO_PULL,		0b1000
.equ GPIO_PP50,		0b0011
.equ GPIO_OD50,		0b0111
.equ GPIO_APP50,	0b1011

.equ USART0_BASE, 0x40013800
.equ USART_BAUD_OFFSET, 0x08
.equ USART_CTL0_OFFSET, 0x0C
.equ USART_DATA_OFFSET, 0x04
.equ USART_STAT_OFFSET, 0x00

.equ USART_CTL0_REN, (1<<2)
.equ USART_CTL0_TEN, (1<<3)
.equ USART_CTL0_UEN, (1<<13)
.equ USART_STAT_TBE, (1<<7)
.equ USART_STAT_RBNE,(1<<5)

.equ ECALL_PRINT_INT,	1
.equ ECALL_PRINT_STR,	4
.equ ECALL_READ_INT,	5
.equ ECALL_READ_STR,	8
.equ ECALL_EXIT,		10
.equ ECALL_PRINT_CH,	11
.equ ECALL_READ_CH,		12

.macro push val
  addi sp, sp, -4
  sw \val, 0(sp)
.endm

.macro pop val
  lw \val, 0(sp)
  addi sp, sp, 4
.endm

.macro PORT_AND_OR addr, mask, val
  li t0, \addr
  lw t1, 0(t0)
    .if \mask != 0xFFFFFFFF
      li t2, \mask
      and t1, t1, t2
    .endif
    li t2, \val
    or t1, t1, t2
  sw t1, 0(t0)
.endm
