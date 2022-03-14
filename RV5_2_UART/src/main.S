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

.equ USART_CTL0_REN, (1<<2)
.equ USART_CTL0_TEN, (1<<3)
.equ USART_CTL0_UEN, (1<<13)
#GPIOA
.equ UART0_TX, 9
.equ UART0_RX, 10

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

.equ RLED, 5
.equ YLED, 6
.equ GLED, 7

.equ LED, GLED

.text
.global _start
_start:
  //RCU_APB2EN |= RCU_APB2EN_PBEN
  PORT_AND_OR RCU_APB2EN, 0xFFFFFFFF, ( RCU_APB2EN_AFEN |  RCU_APB2EN_PAEN | RCU_APB2EN_PBEN | RCU_APB2EN_USART0EN )
  
  PORT_AND_OR GPIOB_CTL0, (~(GPIO_MASK<<(LED*4))), (GPIO_PP50<<(LED*4))
  
  PORT_AND_OR GPIOA_CTL1, \
              ~(GPIO_MASK << ((UART0_RX-8)*4) | GPIO_MASK  << ((UART0_TX-8)*4)), \
              (GPIO_HIZ   << ((UART0_RX-8)*4) | GPIO_APP50 << ((UART0_TX-8)*4))
  li t0, USART0_BASE
  li t1, 8000000 / 9600
  sw t1, USART_BAUD_OFFSET( t0 )
  li t1, ( USART_CTL0_UEN | USART_CTL0_REN | USART_CTL0_TEN )
  sw t1, USART_CTL0_OFFSET( t0 )
  
  li t1, 'S'
  sb t1, USART_DATA_OFFSET( t0 )
  
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
