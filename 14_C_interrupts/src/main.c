#include "gd32vf103.h"
#include "pinmacro.h"
#include "interrupt_util.h"

#define RLED B, 5, 1, GPIO_PP50
#define YLED B, 6, 1, GPIO_PP50
#define GLED B, 7, 1, GPIO_PP50
#define SBTN B, 0, 0, GPIO_HIZ
#define RBTN B, 1, 0, GPIO_HIZ

#define UART0_TX A,9,0, GPIO_APP50
#define UART0_RX A,10,0,GPIO_HIZ

uint32_t SystemCoreClock = 8000000;

void sleep(uint32_t time){
  for(;time;time--)asm volatile("nop");
}

int main(){
  //сбрасываем настройки прерываний
  eclic_init(ECLIC_NUM_INTERRUPTS);
  
  //настройка портов ввода-вывода
  RCU_APB2EN |= RCU_APB2EN_PAEN | RCU_APB2EN_PBEN | RCU_APB2EN_PCEN;
  GPIO_config(RLED); GPIO_config(YLED); GPIO_config(GLED);
  GPIO_config(SBTN); GPIO_config(RBTN);
  
  //настройка UART
  GPIO_config(UART0_RX); GPIO_config(UART0_TX);
  RCU_APB2EN |= RCU_APB2EN_USART0EN | RCU_APB2EN_AFEN;
  USART_BAUD(USART0) = 8000000 / 9600;
  USART_CTL0(USART0) = USART_CTL0_UEN | USART_CTL0_REN | USART_CTL0_TEN;
  //переключаем прерывание в векторный режим
  eclic_set_vmode( USART0_IRQn );
  eclic_enable_interrupt( USART0_IRQn );
  
  eclic_global_interrupt_enable();
  
  while(1){
    GPO_T(YLED);
    if( GPI_ON(SBTN) )GPO_ON(GLED); else GPO_OFF(GLED);
    if( GPI_ON(RBTN) )USART_CTL0(USART0) |= USART_CTL0_TBEIE;
    sleep(100000);
  }
}

void USART0_IRQHandler(void){
  USART_CTL0(USART0) &=~ USART_CTL0_TBEIE;
  USART_DATA(USART0) = 'U';
  GPO_T(RLED);
  sleep(300000);
}
