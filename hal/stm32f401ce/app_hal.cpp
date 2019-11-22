#include "app.h"
#include "app_hal.h"

#include "main.h"
#include "adc.h"
#include "gpio.h"
#include "i2c.h"
#include "spi.h"
#include "tim.h"
#include "usb_otg.h"

extern "C" void SystemClock_Config(void);

namespace hal {

void setup() {
    HAL_Init();
    SystemClock_Config();

    // Attach display buffer and display driver
    static lv_disp_buf_t disp_buf;
    static lv_color_t buf[LV_HOR_RES_MAX * 10];
    lv_disp_buf_init(&disp_buf, buf, NULL, LV_HOR_RES_MAX * 10);

    lv_disp_drv_t disp_drv;
    lv_disp_drv_init(&disp_drv);
    // TODO:
    //disp_drv.flush_cb = monitor_flush;
    disp_drv.buffer = &disp_buf;
    lv_disp_drv_register(&disp_drv);

    //
    // Init touchscreen
    //
    // TODO


    MX_GPIO_Init();
    MX_I2C1_Init();
    MX_I2C3_Init();
    MX_SPI1_Init();
    MX_ADC1_Init();
    MX_TIM2_Init();
    MX_TIM4_Init();
    MX_TIM11_Init();
    MX_USB_OTG_FS_PCD_Init();
}

//
// Main loop
//

void loop(void)
{
    uint32_t tick_start = HAL_GetTick();

    while(1) {
        uint32_t tick_current = HAL_GetTick();

        if (tick_current - tick_start >= 5)
        {
            // Call ~ every 5ms
            tick_start = tick_current;
        	lv_task_handler();
        }
    }
}


// Enable/Disable LCD backlight
void backlight(bool on)
{
    HAL_GPIO_WritePin(GPIOB, GPIO_PIN_0, on ? GPIO_PIN_SET : GPIO_PIN_RESET);
}

}
