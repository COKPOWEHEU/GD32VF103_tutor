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
#GPIOA
.equ UART0_TX, 9
.equ UART0_RX, 10

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

#GPIOB
.equ RLED, 5
.equ YLED, 6
.equ GLED, 7

.equ LED, GLED

.text
.global _start
_start:
  la sp, _stack_end
  
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
  
  la a0, outstr
  call uart_puts
  /*
  la a0, buf
  li a1, 100
  call uart_gets
  
  la a0, buf
  call uart_puts
  */
  call uart_get_i32
  
  mv a3, a0
  la a0, crlf
  call uart_puts
  
  mv a0, a3
  call uart_put_i32
  
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
  
uart_putc:
  li t0, USART0_BASE
uart_putc_wait_flag:
  lh t2, USART_STAT_OFFSET( t0 )
  andi t2, t2, USART_STAT_TBE
    beqz t2, uart_putc_wait_flag
  sb a0, USART_DATA_OFFSET( t0 )
ret

uart_puts:
  li t0, USART0_BASE
uart_puts_loop:
  lb t1, 0(a0)
    beqz t1, uart_puts_end
uart_puts_wait_flag:
  lh t2, USART_STAT_OFFSET( t0 )
  andi t2, t2, USART_STAT_TBE
    beqz t2, uart_puts_wait_flag
  sb t1, USART_DATA_OFFSET( t0 )
  addi a0, a0, 1
    j uart_puts_loop
uart_puts_end:
ret

.bss
uart_buf: .space 12
.text
uart_put_i32:
  li t0, 0
    bgez a0, uart_put_i32_pos
    li t0, '-'
    sub a0, zero, a0
uart_put_i32_pos:
  la t1, uart_buf
  addi t1, t1, 11
  sb zero, 0(t1)
  li t2, 10
uart_put_i32_loop:
  rem t3, a0, t2
  div a0, a0, t2
  addi t3, t3, '0'
  addi t1, t1, -1
  sb t3, 0(t1)
    bnez a0, uart_put_i32_loop
  beqz t0, uart_pus_i32_pos2
    addi t1, t1, -1
    sb t0, 0(t1)
uart_pus_i32_pos2:
  mv a0, t1
  j uart_puts
  
uart_getc:
  li t0, USART0_BASE
uart_getc_loop:
  lw t1, USART_STAT_OFFSET( t0 )
  andi t1, t1, USART_STAT_RBNE
    beqz t1, uart_getc_loop
  lb a0, USART_DATA_OFFSET( t0 )
ret
  
uart_gets:
  li t0, USART0_BASE
  add t1, a0, a1 #max buffer address
  li t2, '\r'
  li t3, '\n'
uart_gets_loop:
  lw t4, USART_STAT_OFFSET( t0 )
  andi t4, t4, USART_STAT_RBNE
    beqz t4, uart_gets_loop
  lb t4, USART_DATA_OFFSET( t0 )
    beq t4, t2, uart_gets_end
    beq t4, t3, uart_gets_end
  sb t4, 0(a0)
  addi a0, a0, 1
    bltu a0, t1, uart_gets_loop
uart_gets_end:
  sb zero, 0(a0)
ret

uart_get_i32:
  li t0, USART0_BASE
  li a0, 0 #result
  li t1, 0 #negative flag
  li t4, '0'
  li t5, '9'
  li t6, '-'
uart_get_i32_start:
  lw t2, USART_STAT_OFFSET( t0 )
  andi t2, t2, USART_STAT_RBNE
    beqz t2, uart_get_i32_start
  lb t2, USART_DATA_OFFSET( t0 )
  sb t2, USART_DATA_OFFSET( t0 )
  beq t2, t6, uart_get_i32_test_neg #if data=='-' : try negative
  blt t2, t4, uart_get_i32_start #if data < '0' : ignore
  bgt t2, t5, uart_get_i32_start #if data > '9' : ignore
  li t6, 10
uart_get_i32_loop:
  mul a0, a0, t6 #res *= 10
  add a0, a0, t2 #res += data
  sub a0, a0, t4 #res -= '0'
uart_get_i32_geti:
  lw t2, USART_STAT_OFFSET( t0 )
  andi t2, t2, USART_STAT_RBNE
    beqz t2, uart_get_i32_geti
  lb t2, USART_DATA_OFFSET( t0 )
  sb t2, USART_DATA_OFFSET( t0 )
  blt t2, t4, uart_get_i32_neg2 #if data < '0' : end of number
  bgt t2, t5, uart_get_i32_neg2 #if data > '9' : end of number
  j uart_get_i32_loop
uart_get_i32_neg2:
  beqz t1, uart_get_i32_end
  sub a0, zero, a0
uart_get_i32_end:
  ret

uart_get_i32_test_neg:
  lw t2, USART_STAT_OFFSET( t0 )
  andi t2, t2, USART_STAT_RBNE
    beqz t2, uart_get_i32_test_neg
  lb t2, USART_DATA_OFFSET( t0 )
  sb t2, USART_DATA_OFFSET( t0 )
  blt t2, t4, uart_get_i32_start
  bgt t2, t5, uart_get_i32_start
  li t1, 1
  li t6, 10
j uart_get_i32_loop

.text
crlf: .asciz "\r\n"
outstr: .asciz "Hello world\r\n"

.bss
buf: .space 100

