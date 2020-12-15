.equ RCU_APB2EN, 0x40021018
.equ RCU_APB2EN_PBEN, (1<<3)
.equ GPIOB_CTL0, 0x40010C00
.equ GPIO_MASK,		0b1111
.equ GPIO_HIZ,		0b0100
.equ GPIO_PP50,		0b0011
.equ GPIOB_OCTL, 0x40010C0C
.equ GPIOB_ISTAT, 0x40010C08

.equ RLED, 5
.equ YLED, 6
.equ GLED, 7
.equ SBTN, 0
.equ RBTN, 1

.text
.global _start
_start:
  //RCU_APB2EN |= RCU_APB2EN_PBEN
  la a5, RCU_APB2EN
  lw	a4, 0(a5)
    ori	a4, a4, RCU_APB2EN_PBEN
  sw	a4, 0(a5)

  //LEDs
  la a5, GPIOB_CTL0
  lw	a4, 0(a5)
    la  a6, ~(GPIO_MASK << (RLED*4))
    and a3, a4, a6
    la  a4, (GPIO_PP50 << (RLED*4))
    or    a4, a4, a3
    
    la  a6, ~(GPIO_MASK << (YLED*4))
    and a3, a4, a6
    la  a4, (GPIO_PP50 << (YLED*4))
    or    a4, a4, a3
    
    la  a6, ~(GPIO_MASK << (GLED*4))
    and a3, a4, a6
    la  a4, (GPIO_PP50 << (GLED*4))
    or    a4, a4, a3
  sw	a4, 0(a5)
  //Buttons
  la a5, GPIOB_CTL0
  lw	a4, 0(a5)
    la  a6, ~(GPIO_MASK << (RBTN*4))
    and a3, a4, a6
    la  a4, (GPIO_HIZ << (RBTN*4))
    or    a4, a4, a3
    
    la  a6, ~(GPIO_MASK << (SBTN*4))
    and a3, a4, a6
    la  a4, (GPIO_HIZ << (SBTN*4))
    or    a4, a4, a3
  sw	a4, 0(a5)
  
  la a3, 0
MAIN_LOOP:
  la a5, GPIOB_OCTL
  lw	a4, 0(a5)
    andi	a4, a4, ~(1<<RLED | 1<<YLED | 1<<GLED)
    or a4, a4, a6
  sw	a4, 0(a5)
  
  add a3, a3, (1<<RLED)
  andi a6, a3, (1<<RLED | 1<<YLED)
  
  la a5, GPIOB_ISTAT
  lw a4, 0(a5)
    andi a4, a4, (1<<SBTN)
    bnez a4, SBTN_SKIP
      ori a6, a6, (1<<GLED)
SBTN_SKIP:
  
  //sleep
  la a5, 200000
sleep:
  addi	a5, a5, -1
  bnez a5, sleep

  j MAIN_LOOP
