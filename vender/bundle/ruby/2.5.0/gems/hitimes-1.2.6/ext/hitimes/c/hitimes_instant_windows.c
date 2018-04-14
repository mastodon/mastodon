#ifdef USE_INSTANT_WINDOWS

#include "hitimes_interval.h"


/*
 * returns the conversion factor, this value is used to convert
 * the value from hitimes_get_current_instant() into seconds
 */
long double hitimes_instant_conversion_factor()
{
    LARGE_INTEGER ticks_per_second;
    QueryPerformanceFrequency( &ticks_per_second );
    return (double)ticks_per_second.QuadPart;
}

/*
 * returns the number of ticks
 */
hitimes_instant_t hitimes_get_current_instant()
{
    LARGE_INTEGER tick;
    QueryPerformanceCounter(&tick);
    return (hitimes_instant_t)tick.QuadPart;
}

#endif
