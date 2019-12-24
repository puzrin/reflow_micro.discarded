#include "app_hal.h"
#include "app_io.h"

#include "main.h"
#include "adc.h"
#include "usart.h"
#include "gpio.h"

extern "C" void SystemClock_Config(void);

namespace hal {

void setup() {
    HAL_Init();
    SystemClock_Config();

    MX_GPIO_Init();
    MX_USART2_UART_Init();
    MX_ADC_Init();
}

//
// Main loop
//

void loop(void)
{
    while(1) {
    }
}


}
