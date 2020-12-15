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
  
  //RCU_APB2EN |= RCU_APB2EN_PBEN
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
  li a0, 5000000
  li a1, 0
  call blink_led
  
  j MAIN_LOOP
  

sleep:
  addi	a0, a0, -1
  bnez a0, sleep
ret

blink_led: #a0 time, a1 - led mask
  push ra
  push s0
  push s1
  push s2
  
  mv s2, a0 #save time
  mv s1, a1 #save led mask
  #GPIOB_OCTL ^= a1
  la s0, GPIOB_OCTL
  lw t0, 0(s0)
    xor t0, t0, s1
  sw t0, 0(s0)
  
  #циклическое переключение светодиодов R->Y->G->R
  slli s1, s1, 1
  andi s1, s1, (1<<RLED | 1<<YLED | 1<<GLED)
    bnez s1, blink_next
  la s1, (1<<RLED)
blink_next:

  #T = T*0,75
  #sleep(T)
  srli t0, s2, 2
  add s2, t0, t0
  add s2, s2, t0
    beqz s2, blink_end
  mv a0, s2
  call sleep

  mv a0, s2
  mv a1, s1
  call blink_led
  
blink_end:
  pop s2
  pop s1
  pop s0
  pop ra
ret
