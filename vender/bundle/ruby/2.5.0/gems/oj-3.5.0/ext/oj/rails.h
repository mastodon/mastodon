/* rails.h
 * Copyright (c) 2017, Peter Ohler
 * All rights reserved.
 */

#ifndef __OJ_RAILS_H__
#define __OJ_RAILS_H__

#include "dump.h"

extern void	oj_mimic_rails_init();
extern ROpt	oj_rails_get_opt(ROptTable rot, VALUE clas);

extern bool	oj_rails_hash_opt;
extern bool	oj_rails_array_opt;
extern bool	oj_rails_float_opt;

extern VALUE	oj_optimize_rails(VALUE self);


#endif /* __OJ_RAILS_H__ */
