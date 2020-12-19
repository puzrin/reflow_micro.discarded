#ifndef __APP__
#define __APP__
#ifdef __cplusplus
  extern "C" {
#endif

#include "lvgl.h"


typedef struct {
    // UI
    uint8_t lcd_brightness;


    struct {
        lv_style_t main;
        lv_style_t list_title;
        lv_style_t list_desc;
        lv_style_t setting_desc;
    } styles;

} app_data_t;


extern app_data_t app_data;
void app_update_settings();
void app_screen_create(bool to_settings);

#ifdef __cplusplus
  }
#endif
#endif
