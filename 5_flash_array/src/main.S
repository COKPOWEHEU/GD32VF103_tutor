.equ RCU_APB2EN, 0x40021018
.equ RCU_APB2EN_PBEN, (1<<3)
.equ GPIOB_CTL0, 0x40010C00
.equ GPIO_MASK,		0b1111
.equ GPIO_HIZ,		0b0100
.equ GPIO_PP50,		0b0011
.equ GPIOB_OCTL, 0x40010C0C

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
  la sp, 0x20008000
  
  la a5, RCU_APB2EN
  lw	a4, 0(a5)
    ori	a4, a4, RCU_APB2EN_PBEN
  sw	a4, 0(a5)

  la a5, GPIOB_CTL0
  lw	a4, 0(a5)
    la  a6, ~(GPIO_MASK << (RLED*4) | GPIO_MASK << (YLED*4) | GPIO_MASK << (GLED*4))
    and a3, a4, a6
    la  a4, (GPIO_PP50 << (RLED*4) | GPIO_PP50 << (YLED*4) | GPIO_PP50 << (GLED*4))
    or    a4, a4, a3
  sw	a4, 0(a5)
  
MAIN_LOOP:
  la s0, GPIOB_OCTL
  lh s1, 0(s0)
  la s2, ~(1<<GLED | 1<<YLED | 1<<RLED)
  
  la s3, led_arr
  la s4, led_arr_end
led_loop:
  lh t0, 0(s3)
  and s1, s1, s2
  or s1, s1, t0
    sh s1, 0(s0)
    
  la a0, 300000
  call sleep
  
  addi s3, s3, 2
  bltu s3, s4, led_loop
  
  j MAIN_LOOP
  
sleep:
  addi	a0, a0, -1
  bnez a0, sleep
ret

.text
led_arr:
  .short (0<<GLED | 0<<YLED | 1<<RLED)
  .short (0<<GLED | 1<<YLED | 0<<RLED)
  .short (1<<GLED | 0<<YLED | 0<<RLED)
  .short (0<<GLED | 1<<YLED | 0<<RLED)
led_arr_end:

