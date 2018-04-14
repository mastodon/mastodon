/**
 * Copyright (c) 2008 Jeremy Hinegardner
 * All rights reserved.  See LICENSE and/or COPYING for details.
 *
 * vim: shiftwidth=4 
 */ 

#ifndef __HITIMES_INTERVAL_H__
#define __HITIMES_INTERVAL_H__

#include <ruby.h>

#define NANOSECONDS_PER_SECOND  1e9l

#ifdef USE_INSTANT_CLOCK_GETTIME
#    define HITIMES_U64INT unsigned long long int
#    define HITIMES_INSTANT_CONVERSION_FACTOR 1e9l
#elif USE_INSTANT_OSX
#    define HITIMES_U64INT uint64_t
#    define HITIMES_INSTANT_CONVERSION_FACTOR hitimes_instant_conversion_factor()
#elif USE_INSTANT_WINDOWS
#    define HITIMES_U64INT unsigned __int64
#    define HITIMES_INSTANT_CONVERSION_FACTOR hitimes_instant_conversion_factor()
#else
#    error "Unable to build hitimes, no Instance backend available"
#endif


/* an alias for a 64bit unsigned integer.  The various sytem dependenent
 * files must define hitimes_u64int_t 
 */
typedef HITIMES_U64INT hitimes_instant_t;

typedef struct hitimes_interval {
    hitimes_instant_t start_instant;
    hitimes_instant_t stop_instant;
    long double       duration;
} hitimes_interval_t;

/* all the backends must define these methods */
hitimes_instant_t hitimes_get_current_instant( );
long double hitimes_instant_conversion_factor( );

/* init methods */
void Init_hitimes_stats();
void Init_hitimes_interval();


/* Module and Classes -- defined at the top level */
extern VALUE mH;           /* module Hitimes            */
extern VALUE eH_Error;     /* class  Hitimes::Error     */
extern VALUE cH_Interval;  /* class  Hitimes::Interval  */


/**
 * Methods for Interval
 */

VALUE hitimes_interval_free(hitimes_interval_t* i) ;
VALUE hitimes_interval_alloc(VALUE klass);
VALUE hitimes_interval_now( );
VALUE hitimes_interval_measure( );
VALUE hitimes_interval_split( VALUE self );
VALUE hitimes_interval_start( VALUE self );
VALUE hitimes_interval_stop( VALUE self );
VALUE hitimes_interval_started( VALUE self );
VALUE hitimes_interval_stopped( VALUE self );
VALUE hitimes_interval_running( VALUE self );
VALUE hitimes_interval_start_instant( VALUE self );
VALUE hitimes_interval_stop_instant( VALUE self );
VALUE hitimes_interval_duration ( VALUE self );

#endif
