.include "gd32vf103.inc"

#GPIOA
.equ UART0_TX, 9
.equ UART0_RX, 10

.global trap_uart_init
trap_uart_init:
  PORT_AND_OR RCU_APB2EN, 0xFFFFFFFF, ( RCU_APB2EN_AFEN | RCU_APB2EN_USART0EN | RCU_APB2EN_PAEN)
  PORT_AND_OR GPIOA_CTL1, \
              ~(GPIO_MASK << ((UART0_RX-8)*4) | GPIO_MASK  << ((UART0_TX-8)*4)), \
              (GPIO_HIZ   << ((UART0_RX-8)*4) | GPIO_APP50 << ((UART0_TX-8)*4))
              
  li t0, USART0_BASE
  li t1, 8000000 / 9600
  sw t1, USART_BAUD_OFFSET( t0 )
  li t1, ( USART_CTL0_UEN | USART_CTL0_REN | USART_CTL0_TEN )
  sw t1, USART_CTL0_OFFSET( t0 )
ret

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
.align 6
.global trap_entry
trap_entry:
  push t0
  push t1
  push ra
  
  csrr t0, CSR_MCAUSE
  andi t0, t0, 0x7FF
  li t1, 8
  beq t0, t1, trap_ecall_user
  li t1, 11
  beq t0, t1, trap_ecall_kernel
  
trap_end:
  csrr t0, CSR_MEPC
  addi t0, t0, 4
  csrw CSR_MEPC, t0

  pop ra
  pop t1
  pop t0
mret
trap_ecall_kernel:
trap_ecall_user:
  li t1, ECALL_PRINT_INT
  bne a7, t1, trap_ign_print_int
    call uart_put_i32
    j trap_end
trap_ign_print_int:
  li t1, ECALL_PRINT_STR
  bne a7, t1, trap_ign_print_string
    call uart_puts
    j trap_end
trap_ign_print_string:
  li t1, ECALL_READ_INT
  bne a7, t1, trap_ign_read_int
    call uart_get_i32
    j trap_end
trap_ign_read_int:
  li t1, ECALL_READ_STR
  bne a7, t1, trap_ign_read_str
    call uart_gets
    j trap_end
trap_ign_read_str:
  li t1, ECALL_EXIT
  bne a7, t1, trap_ign_exit
    trap_inf_loop: j trap_inf_loop
trap_ign_exit:
  li t1, ECALL_PRINT_CH
  bne a7, t1, trap_ign_putc
    call uart_putc
    j trap_end
trap_ign_putc:
  li t1, ECALL_READ_CH
  bne a7, t1, trap_ign_getc
    call uart_getc
    j trap_end
trap_ign_getc:
j trap_end
