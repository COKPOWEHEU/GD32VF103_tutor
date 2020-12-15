#include "gd32vf103.h"
#include "pinmacro.h"

#define RLED B, 5, 1, GPIO_PP50
#define YLED B, 6, 1, GPIO_PP50
#define GLED B, 7, 1, GPIO_PP50
#define SBTN B, 0, 0, GPIO_HIZ
#define RBTN B, 1, 0, GPIO_HIZ

void sleep(uint32_t time){
  for(;time;time--)asm volatile("nop");
}

int main(){
  RCU_APB2EN |= RCU_APB2EN_PAEN | RCU_APB2EN_PBEN | RCU_APB2EN_PCEN;
  GPIO_config(RLED); GPIO_config(YLED); GPIO_config(GLED);
  GPIO_config(SBTN); GPIO_config(RBTN);
  
  while(1){
    GPO_T(YLED);
    if( GPI_ON(SBTN) )GPO_ON(GLED); else GPO_OFF(GLED);
    sleep(100000);
  }
}
