#ifndef __APP_HAL__
#define __APP_HAL__

#include <stdint.h>

namespace hal {

void setup();
void loop();
void backlight(bool on);

} // namespace

#endif
