#ifdef USE_INSTANT_CLOCK_GETTIME

#include "hitimes_interval.h"

#include <time.h>
#ifndef CLOCK_MONOTONIC
#  include <sys/time.h>
#  ifndef CLOCK_MONOTONIC
#    ifdef __linux__
#      include <linux/time.h>
#    endif
#  endif
#endif

hitimes_instant_t hitimes_get_current_instant( )
{
    struct timespec time;
    int rc;

    rc = clock_gettime( CLOCK_MONOTONIC, &time);
    if ( 0 != rc )  {
        char* e = strerror( rc );
        rb_raise(eH_Error, "Unable to retrieve time for CLOCK_MONOTONIC :  %s", e );
    }

    return ( ( NANOSECONDS_PER_SECOND * (long)time.tv_sec ) + time.tv_nsec );
}
#endif
