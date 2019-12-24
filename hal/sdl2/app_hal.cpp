#define SDL_MAIN_HANDLED        /*To fix SDL's "undefined reference to WinMain" issue*/
#include <SDL2/SDL.h>
#include "display/monitor.h"
#include "indev/mouse.h"

#include "app_hal.h"
#include "app_gui.h"

namespace hal {

// Debug log writer
#if LV_USE_LOG
void log(lv_log_level_t level, const char * file, uint32_t line, const char * dsc) {
    static const char * lvl_prefix[] = {"Trace", "Info", "Warn", "Error"};
    printf("%s: %s \t(%s #%d)\n", lvl_prefix[level], dsc, file, line);
}
#endif


#if MEM_USE_LOG != 0
static void sysmon_task(lv_task_t * param)
{
    (void) param;    /*Unused*/

    uint8_t mem_used_pct = 0;
    lv_mem_monitor_t mem_mon;
    lv_mem_monitor(&mem_mon);
    mem_used_pct = mem_mon.used_pct;

    printf(
        "[Memory] total: %d bytes, free: %d bytes, use: %d%%\n",
        (int)mem_mon.total_size,
        (int)mem_mon.free_size,
        (int)mem_used_pct
    );
}
#endif


static int tick_thread(void * data)
{
    (void)data;

    while(1) {
        SDL_Delay(5);
        lv_tick_inc(5);
    }

    return 0;
}

//
// HiRes timer to create software PWM-s.
//

static void (*hires_timer_cb)(void) = NULL;

void set_hires_timer_cb(void (*handler)(void))
{
    hires_timer_cb = handler;
}

static SDL_mutex * mutex;

static Uint32 hires_timer_executor(Uint32 interval, void *param)
{
    //if (SDL_TryLockMutex(mutex) != 0) return interval;
    if (hires_timer_cb != NULL) hires_timer_cb();

    (void)param;
    return interval;
}

//
// Hardware setup
//

void setup(void)
{
    // Register debug log fn, write all to console
#if LV_USE_LOG
    lv_log_register_print_cb(log);
#endif

    //
    // Init display
    //

    monitor_init();

    static lv_disp_buf_t disp_buf;
    static lv_color_t buf[LV_HOR_RES_MAX * 10];
    lv_disp_buf_init(&disp_buf, buf, NULL, LV_HOR_RES_MAX * 10);

    lv_disp_drv_t disp_drv;
    lv_disp_drv_init(&disp_drv);

    disp_drv.flush_cb = monitor_flush;
    disp_drv.buffer = &disp_buf;
    lv_disp_drv_register(&disp_drv);

    //
    // Init mouse
    //

    mouse_init();

    lv_indev_drv_t indev_drv;
    lv_indev_drv_init(&indev_drv);

    indev_drv.type = LV_INDEV_TYPE_POINTER;
    indev_drv.read_cb = mouse_read;
    lv_indev_drv_register(&indev_drv);

    //
    // Emulate HiRes timer. Here we use 1000 Hz instead of 10000 Hz on bare metal.
    //
    mutex = SDL_CreateMutex();
    SDL_AddTimer(1, hires_timer_executor, NULL);

#if MEM_USE_LOG != 0
    lv_task_create(sysmon_task, 500, LV_TASK_PRIO_LOW, NULL);
#endif

    SDL_CreateThread(tick_thread, "tick", NULL);
}

//
// Main loop
//

void loop(void)
{
    // Loop
    while(1) {
        SDL_Delay(5);
        lv_task_handler();
    }
}


// Enable/Disable LCD backlight. Do nothing in emulator
void backlight(bool on)
{
    (void)on;
}


} // namespace
