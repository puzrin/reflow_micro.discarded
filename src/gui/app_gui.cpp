#include "app_hal.h"
#include "lvgl.h"

int main () {
    lv_init();
    hal::setup();
    hal::backlight(true);
    //load_settings();

    //create_styles();
    //lv_obj_set_style(lv_scr_act(), &app_data.styles.main);

    //app_screen_create(false);

    //hal::set_hires_timer_cb(hires_tick_handler);

    hal::loop();
}
