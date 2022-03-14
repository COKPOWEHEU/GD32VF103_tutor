.equ RCU_APB2EN, 0x40021018
.equ RCU_APB2EN_PBEN, (1<<3)
.equ GPIOB_CTL0, 0x40010C00
.equ GPIO_MASK, 0b1111
.equ GPIO_PP_50MHz, 0b0011
.equ GPIOB_OCTL, 0x40010C0C

.equ RLED, 6#5
.equ YLED, 6
.equ GLED, 7

.text
.global _start
_start:
  //RCU_APB2EN |= RCU_APB2EN_PBEN
  li t0, RCU_APB2EN
  lw	t1, 0(t0)
    ori	t1, t1, RCU_APB2EN_PBEN
  sw	t1, 0(t0)

  //GPIOB_CTL0 = (GPIOB_CTL0 & (0b1111<<RLED*4)) | 0b0011 << (RLED*4)
  li t0, GPIOB_CTL0
  lw	t1, 0(t0)
    li  t2, ~(0b1111 << (RLED*4))
    and t1, t1, t2
    li  t2, (0b0011 << (RLED*4))
    or    t1, t1, t2
  sw	t1, 0(t0)
  
MAIN_LOOP:
  //GPIO_OCTL(GPIOB) ^= (1<<RLED)
  li t0, GPIOB_OCTL
  lw	t1, 0(t0)
    xori	t1, t1, (1<<RLED)
  sw	t1, 0(t0)
  
  //sleep
  la t0, 200000
sleep:
  addi	t0, t0, -1
  bnez t0, sleep

  j MAIN_LOOP
