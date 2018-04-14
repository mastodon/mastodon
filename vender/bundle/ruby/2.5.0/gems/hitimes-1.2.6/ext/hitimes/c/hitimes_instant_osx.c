#ifdef USE_INSTANT_OSX

#include "hitimes_interval.h"
#include <mach/mach.h>
#include <mach/mach_time.h>

/* All this OSX code is adapted from http://developer.apple.com/library/mac/#qa/qa1398/_index.html */

/*
 * returns the conversion factor, this value is used to convert
 * the value from hitimes_get_current_instant() into seconds
 */
long double hitimes_instant_conversion_factor()
{
    static mach_timebase_info_data_t  s_timebase_info;
    static long double                conversion_factor;
    static uint64_t                   nano_conversion;

    /**
     * If this is the first time we've run, get the timebase.
     * We can use denom == 0 to indicate that s_timebase_info is
     * uninitialised because it makes no sense to have a zero
     * denominator is a fraction.
     */

    if ( s_timebase_info.denom == 0 ) {
        mach_timebase_info(&s_timebase_info);
        nano_conversion   = s_timebase_info.numer / s_timebase_info.denom;
        conversion_factor = (long double) (nano_conversion) * (1e9l);
    }

    return conversion_factor;
}

/*
 * returns the mach absolute time, which has no meaning outside of a conversion
 * factor.
 */
hitimes_instant_t hitimes_get_current_instant()
{
    return mach_absolute_time();
}


#endif
