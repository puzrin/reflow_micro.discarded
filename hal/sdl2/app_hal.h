#ifndef __APP_HAL__
#define __APP_HAL__

#include <stdint.h>

namespace hal {

void setup();
void loop();
void set_hires_timer_cb(void (*handler)(void));
void backlight(bool on);

} // namespace

#endif
