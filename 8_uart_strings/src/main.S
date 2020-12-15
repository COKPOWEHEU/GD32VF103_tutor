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
.equ GPIO_PP50,		0b0011
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
#GPIOB
.equ RLED, 5
.equ YLED, 6
.equ GLED, 7
.equ SBTN, 0
.equ RBTN, 1


.macro push val
  addi sp, sp, -4
  sw \val, 0(sp)
.endm

.macro pop val
  lw \val, 0(sp)
  addi sp, sp, 4
.endm

.text
.global _start
_start:
  la sp, _stack_end
#copy data section
  la a0, _data_load
  la a1, _data_start
  la a2, _data_end
  bgeu a1, a2, copy_data_end
copy_data_loop:
  lw t0, (a0)
  sw t0, (a1)
  addi a0, a0, 4
  addi a1, a1, 4
  bltu a1, a2, copy_data_loop
copy_data_end:
# Clear [bss] section
  la a0, _bss_start
  la a1, _bss_end
    bgeu a0, a1, clear_bss_end
clear_bss_loop:
  sw zero, (a0)
  addi a0, a0, 4
    bltu a0, a1, clear_bss_loop
clear_bss_end:
  
  
  la t0, RCU_APB2EN
  lw	t1, 0(t0)
    la t2, RCU_APB2EN_AFEN | RCU_APB2EN_PAEN | RCU_APB2EN_PBEN | RCU_APB2EN_USART0EN
    or	t1, t1, t2
  sw	t1, 0(t0)

  la a5, GPIOB_CTL0
  lw	a4, 0(a5)
    la  a6, ~(GPIO_MASK << (RLED*4) | GPIO_MASK << (YLED*4) | GPIO_MASK << (GLED*4))
    and a3, a4, a6
    la  a4, (GPIO_PP50 << (RLED*4) | GPIO_PP50 << (YLED*4) | GPIO_PP50 << (GLED*4))
    or    a4, a4, a3
  sw	a4, 0(a5)
  
  la t0, GPIOA_CTL1
  lw	t1, 0(t0)
    la  t2, ~(GPIO_MASK << ((UART0_RX-8)*4) | GPIO_MASK << ((UART0_TX-8)*4))
    and t3, t1, t2
    la  t1, (GPIO_HIZ << ((UART0_RX-8)*4) | GPIO_APP50 << ((UART0_TX-8)*4))
    or    t1, t1, t3
  sw	t1, 0(t0)
  
  la t0, USART0_BASE
    li t1, 8000000 / 9600
  sw t1, USART_BAUD_OFFSET(t0)
    li t1, USART_CTL0_UEN | USART_CTL0_REN | USART_CTL0_TEN
  sw t1, USART_CTL0_OFFSET(t0)
  
  la a0, hwstr
  call uart_puts
  
MAIN_LOOP:
  la a0, uart_rx_buf
  li a1, 99
  call uart_gets
  
  #чтобы выведенная строка отличалась от исходной, переведем заменим в ней строчные буквы на заглавные
  la a0, uart_rx_buf
  call toupper
  
  la a0, uart_rx_buf
  call uart_puts
  #добавим терминирующую последовательность
  la a0, termbytes
  call uart_puts
  
  j MAIN_LOOP
  
sleep:
  addi	a0, a0, -1
  bnez a0, sleep
ret

toupper:
  la t1, 'a'
  la t2, 'z'
toupper_loop:
  lb t0, 0(a0)
    beqz t0, toupper_end #если дошли до терминирующего нуля, выходим
    bltu t0, t1, toupper_skip_up #если буква меньше 'a' или больше 'z' то игнорируем
    bgtu t0, t2, toupper_skip_up
  addi t0, t0, ('A'-'a')
  sb t0, 0(a0)
toupper_skip_up:
  addi a0, a0, 1
    j toupper_loop
toupper_end:
ret

uart_puts: #a0 - строка для передачи
  la t0, USART0_BASE
uart_str_loop:
  lb t1, 0(a0)
  beqz t1, uart_str_end
uart_str_wait_flag:
  lh t2, USART_STAT_OFFSET(t0)
  andi t2, t2, USART_STAT_TBE
    beqz t2, uart_str_wait_flag
  sb t1, USART_DATA_OFFSET(t0)
  addi a0, a0, 1
    j uart_str_loop
uart_str_end:
ret

uart_gets: #a0 - buffer, a1 - max len
  la t0, USART0_BASE
  add t1, a0, a1
  li t2, '\r'
  li t3, '\n'
uart_gets_loop:
  lw t4, USART_STAT_OFFSET(t0)
  andi t4, t4, USART_STAT_RBNE
    beqz t4, uart_gets_loop
  lb t4, USART_DATA_OFFSET(t0)
    beq t4, t2, uart_gets_end
    beq t4, t3, uart_gets_end
  sb t4, 0(a0)
  addi a0, a0, 1
    bltu a0, t1, uart_gets_loop
uart_gets_end:
  sb zero, 0(a0)
ret

.text
termbytes: .asciz "\r\n"
hwstr: .asciz "Hello world\r\n"

.bss
uart_rx_buf: .space 100
