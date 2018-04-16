#include <ruby.h>
#include "hitimes_interval.h"

/* Module and Classes */
VALUE mH;           /* module Hitimes            */
VALUE eH_Error;     /* class  Hitimes::Error     */

/*
 * Document-class: Hitimes::Error
 *
 * General error class for the Hitimes module
 */
void Init_hitimes( )
{
    mH = rb_define_module("Hitimes");
     
    eH_Error = rb_define_class_under(mH, "Error", rb_eStandardError);

    Init_hitimes_interval();
    Init_hitimes_stats( );
}
