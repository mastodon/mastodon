/**
 * Copyright (c) 2008 Jeremy Hinegardner
 * All rights reserved.  See LICENSE and/or COPYING for details.
 *
 * vim: shiftwidth=4 
 */ 

#ifndef __HITIMES_STATS_H__
#define __HITIMES_STATS_H__

#include <ruby.h>
#include <math.h>

/* classes and modules defined elswhere */
extern VALUE mH;        /* Hitimes */
extern VALUE eH_Error;  /* Hitimes::Error */
extern VALUE cH_Stats;  /* Hitimes::Stats */


typedef struct hitimes_stats {
    long double min;
    long double max;
    long double sum;
    long double sumsq;
    long long   count;
} hitimes_stats_t;

#endif


