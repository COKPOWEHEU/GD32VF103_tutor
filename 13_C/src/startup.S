.equ CSR_MMISC_CTL, 0x7d0
.equ CSR_MNVEC, 0x7C3
.equ CSR_MTVT,  0x307
.equ CSR_MTVT2, 0x7EC
.equ CSR_MTVEC, 0x305
.equ CSR_MCAUSE,0x342
.equ CSR_MEPC,  0x341
.equ CSR_MTVEC_ECLIC, 3
.equ CSR_MSTATUS, 0x300
.equ MSTATUS_MIE, (1<<3)

.text
.section .isr_vectors
    .weak  eclic_msip_handler
    .weak  eclic_mtip_handler
    .weak  eclic_bwei_handler
    .weak  eclic_pmovi_handler
    .weak  WWDGT_IRQHandler
    .weak  LVD_IRQHandler
    .weak  TAMPER_IRQHandler
    .weak  RTC_IRQHandler
    .weak  FMC_IRQHandler
    .weak  RCU_IRQHandler
    .weak  EXTI0_IRQHandler
    .weak  EXTI1_IRQHandler
    .weak  EXTI2_IRQHandler
    .weak  EXTI3_IRQHandler
    .weak  EXTI4_IRQHandler
    .weak  DMA0_Channel0_IRQHandler
    .weak  DMA0_Channel1_IRQHandler
    .weak  DMA0_Channel2_IRQHandler
    .weak  DMA0_Channel3_IRQHandler
    .weak  DMA0_Channel4_IRQHandler
    .weak  DMA0_Channel5_IRQHandler
    .weak  DMA0_Channel6_IRQHandler
    .weak  ADC0_1_IRQHandler
    .weak  CAN0_TX_IRQHandler
    .weak  CAN0_RX0_IRQHandler
    .weak  CAN0_RX1_IRQHandler
    .weak  CAN0_EWMC_IRQHandler
    .weak  EXTI5_9_IRQHandler
    .weak  TIMER0_BRK_IRQHandler
    .weak  TIMER0_UP_IRQHandler
    .weak  TIMER0_TRG_CMT_IRQHandler
    .weak  TIMER0_Channel_IRQHandler
    .weak  TIMER1_IRQHandler
    .weak  TIMER2_IRQHandler
    .weak  TIMER3_IRQHandler
    .weak  I2C0_EV_IRQHandler
    .weak  I2C0_ER_IRQHandler
    .weak  I2C1_EV_IRQHandler
    .weak  I2C1_ER_IRQHandler
    .weak  SPI0_IRQHandler
    .weak  SPI1_IRQHandler
    .weak  USART0_IRQHandler
    .weak  USART1_IRQHandler
    .weak  USART2_IRQHandler
    .weak  EXTI10_15_IRQHandler
    .weak  RTC_Alarm_IRQHandler
    .weak  USBFS_WKUP_IRQHandler
    .weak  EXMC_IRQHandler
    .weak  TIMER4_IRQHandler
    .weak  SPI2_IRQHandler
    .weak  UART3_IRQHandler
    .weak  UART4_IRQHandler
    .weak  TIMER5_IRQHandler
    .weak  TIMER6_IRQHandler
    .weak  DMA1_Channel0_IRQHandler
    .weak  DMA1_Channel1_IRQHandler
    .weak  DMA1_Channel2_IRQHandler
    .weak  DMA1_Channel3_IRQHandler
    .weak  DMA1_Channel4_IRQHandler
    .weak  CAN1_TX_IRQHandler
    .weak  CAN1_RX0_IRQHandler
    .weak  CAN1_RX1_IRQHandler
    .weak  CAN1_EWMC_IRQHandler
    .weak  USBFS_IRQHandler
    
.align 9
vector_base:
  j _start
  .align    2
  .word  0
  .word  0
  .word  eclic_msip_handler
  .word  0
  .word  0
  .word  0
  .word  eclic_mtip_handler
  .word  0
  .word  0
  .word  0
  .word  0
  .word  0
  .word  0
  .word  0
  .word  0
  .word  0
  .word  eclic_bwei_handler
  .word  eclic_pmovi_handler
  .word  WWDGT_IRQHandler
  .word  LVD_IRQHandler
  .word  TAMPER_IRQHandler
  .word  RTC_IRQHandler
  .word  FMC_IRQHandler
  .word  RCU_IRQHandler
  .word  EXTI0_IRQHandler
  .word  EXTI1_IRQHandler
  .word  EXTI2_IRQHandler
  .word  EXTI3_IRQHandler
  .word  EXTI4_IRQHandler
  .word  DMA0_Channel0_IRQHandler
  .word  DMA0_Channel1_IRQHandler
  .word  DMA0_Channel2_IRQHandler
  .word  DMA0_Channel3_IRQHandler
  .word  DMA0_Channel4_IRQHandler
  .word  DMA0_Channel5_IRQHandler
  .word  DMA0_Channel6_IRQHandler
  .word  ADC0_1_IRQHandler
  .word  CAN0_TX_IRQHandler
  .word  CAN0_RX0_IRQHandler
  .word  CAN0_RX1_IRQHandler
  .word  CAN0_EWMC_IRQHandler
  .word  EXTI5_9_IRQHandler
  .word  TIMER0_BRK_IRQHandler
  .word  TIMER0_UP_IRQHandler
  .word  TIMER0_TRG_CMT_IRQHandler
  .word  TIMER0_Channel_IRQHandler
  .word  TIMER1_IRQHandler
  .word  TIMER2_IRQHandler
  .word  TIMER3_IRQHandler
  .word  I2C0_EV_IRQHandler
  .word  I2C0_ER_IRQHandler
  .word  I2C1_EV_IRQHandler
  .word  I2C1_ER_IRQHandler
  .word  SPI0_IRQHandler
  .word  SPI1_IRQHandler
  .word  USART0_IRQHandler
  .word  USART1_IRQHandler
  .word  USART2_IRQHandler
  .word  EXTI10_15_IRQHandler
  .word  RTC_Alarm_IRQHandler
  .word  USBFS_WKUP_IRQHandler
  .word  0
  .word  0
  .word  0
  .word  0
  .word  0
  .word  EXMC_IRQHandler
  .word  0
  .word  TIMER4_IRQHandler
  .word  SPI2_IRQHandler
  .word  UART3_IRQHandler
  .word  UART4_IRQHandler
  .word  TIMER5_IRQHandler
  .word  TIMER6_IRQHandler
  .word  DMA1_Channel0_IRQHandler
  .word  DMA1_Channel1_IRQHandler
  .word  DMA1_Channel2_IRQHandler
  .word  DMA1_Channel3_IRQHandler
  .word  DMA1_Channel4_IRQHandler
  .word  0
  .word  0
  .word  CAN1_TX_IRQHandler
  .word  CAN1_RX0_IRQHandler
  .word  CAN1_RX1_IRQHandler
  .word  CAN1_EWMC_IRQHandler
  .word  USBFS_IRQHandler

.align 2
.text
.section .start
.global _start
_start:
  la sp, _stack_end
  
  # NIM (немаскируемые прерывания)
  la t0, NMIHandler
  csrs CSR_MNVEC, t0
  li t0, (1<<9) #0 - reset, 1 - interrupt
  csrs CSR_MMISC_CTL, t0
  
  la t0, vector_base
  csrw CSR_MTVT, t0 #выравнивание на степень двойки, большей количества прерываний, умноженного на 4 байта, то есть 512
  
  la t0, IRQHandler
  csrw CSR_MTVT2, t0 #выравнивание минимум на 4 байта
  csrs CSR_MTVT2, 1
  
  la t0, TrapHandler
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

#вызываем MAIN
  li a0, 0
  li a1, 0
  call main
  
INF_LOOP:
.weak UnhandledInterruptHandler
UnhandledInterruptHandler:
  j INF_LOOP
  
#заглушки для прерываний
.weak IRQHandler
IRQHandler:
.weak NMIHandler
NMIHandler:
.weak TrapHandler
TrapHandler:
j UnhandledInterruptHandler
