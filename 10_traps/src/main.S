.equ CSR_MTVEC, 0x305
.equ CSR_MCAUSE,0x342
.equ CSR_MEPC,  0x341
.equ CSR_MTVEC_ECLIC, 3
.equ CSR_MSTATUS, 0x300
.equ MSTATUS_MIE, (1<<3)

.equ ECLIC_ADDR_BASE, 0xd2000000
.equ ECLIC_INT_IP_OFFSET, 0x1000
.equ ECLIC_INT_IE_OFFSET, 0x1001
.equ ECLIC_INT_ATTR_OFFSET, 0x1002
.equ USART0_IRQn, 56

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
.equ GPIOB_ISTAT,(GPIOB_BASE + 0x08)

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
.equ USART_CTL0_TBEIE, (1<<7)
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
  
  la t0, trap_entry
    andi t0, t0, ~(64-1) #выравнивание адреса должно быть минимум на 64 байта
    ori t0, t0, CSR_MTVEC_ECLIC
  csrw CSR_MTVEC, t0

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
    la a6, ~(GPIO_MASK << (RBTN*4) | GPIO_MASK << (SBTN*4))
    and a3, a4, a6
    la a6, (GPIO_HIZ << (RBTN*4) | GPIO_HIZ << (SBTN*4))
    or a4, a4, a3
  sw a4, 0(a5)
  
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
    li t1, USART_CTL0_UEN | USART_CTL0_REN | USART_CTL0_TEN # | USART_CTL0_TBEIE
  sw t1, USART_CTL0_OFFSET(t0)
  
  li t1, 'S'
  sb t1, USART_DATA_OFFSET(t0)
  
  # Локальное разрешение прерывания USART0 (eclic_int_ie[i] = 1)
  la t0, (ECLIC_ADDR_BASE + ECLIC_INT_IE_OFFSET + USART0_IRQn*4)
    la t1, 1
  sb t1, 0(t0)
  
  #глобальное разрешение прерываний
  csrrs zero, CSR_MSTATUS, MSTATUS_MIE

  la s1, GPIOB_ISTAT
MAIN_LOOP:
  lh t0, 0(s1)
  andi t1, t0, (1<<SBTN)
    bnez t1, TEST_RBTN
    
  #пытаемся выполнить заведомую чушь - команду с кодом 0xFFFFFFFF
  #.word 0xFFFFFFFF
  ecall
  
TEST_RBTN:
  andi t1, t0, (1<<RBTN)
    bnez t1, MAIN_LOOP
    
  la t2, USART0_BASE
    la t3, USART_CTL0_UEN | USART_CTL0_REN | USART_CTL0_TEN  | USART_CTL0_TBEIE
  sw t3, USART_CTL0_OFFSET(t2)
  
  j MAIN_LOOP
  
sleep:
  addi	a0, a0, -1
  bnez a0, sleep
ret

.text
.align 6
trap_entry:
  push t0
  push t1
  push a0
  
  csrr a0, CSR_MCAUSE
  la t1, (1<<31)
  and t1, a0, t1 #t1 - interrupt / trap
    beqz t1, trap_exception
 #interrupt
  
  la t0, GPIOB_OCTL
  lh t1, 0(t0)
    xori t1, t1, (1<<GLED)
  sh t1, 0(t0)
  
  la t0, 0xFFF
  and a0, a0, t0
  la t0, USART0_IRQn
    bne t0, a0, trap_end
  
  la t0, USART0_BASE
    la t1, USART_CTL0_UEN | USART_CTL0_REN | USART_CTL0_TEN
  sw t1, USART_CTL0_OFFSET(t0)
    la t1, 'I'
  sw t1, USART_DATA_OFFSET(t0)
  
trap_end:
  la a0, 100000
  call sleep
  
  pop a0
  pop t1
  pop t0
mret
trap_exception:
  la t0, GPIOB_OCTL
  lh t1, 0(t0)
    xori t1, t1, (1<<RLED)
  sh t1, 0(t0)
  
  csrr t0, CSR_MEPC
  addi t0, t0, 4
  csrw CSR_MEPC, t0
j trap_end
