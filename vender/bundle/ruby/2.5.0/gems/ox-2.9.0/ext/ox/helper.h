/* helper.h
 * Copyright (c) 2011, Peter Ohler
 * All rights reserved.
 */

#ifndef __OX_HELPER_H__
#define __OX_HELPER_H__

#include "type.h"

#define HELPER_STACK_INC	16

typedef struct _Helper {
    ID		var;	/* Object var ID */
    VALUE	obj;	/* object created or Qundef if not appropriate */
    Type	type;	/* type of object in obj */
} *Helper;

typedef struct _HelperStack {
    struct _Helper	base[HELPER_STACK_INC];
    Helper		head;	/* current stack */
    Helper		end;	/* stack end */
    Helper		tail;	/* pointer to one past last element name on stack */
} *HelperStack;

inline static void
helper_stack_init(HelperStack stack) {
    stack->head = stack->base;
    stack->end = stack->base + sizeof(stack->base) / sizeof(struct _Helper);
    stack->tail = stack->head;
}

inline static int
helper_stack_empty(HelperStack stack) {
    return (stack->head == stack->tail);
}

inline static int
helper_stack_depth(HelperStack stack) {
    return (int)(stack->tail - stack->head);
}

inline static void
helper_stack_cleanup(HelperStack stack) {
    if (stack->base != stack->head) {
        xfree(stack->head);
	stack->head = stack->base;
    }
}

inline static Helper
helper_stack_push(HelperStack stack, ID var, VALUE obj, Type type) {
    if (stack->end <= stack->tail) {
	size_t	len = stack->end - stack->head;
	size_t	toff = stack->tail - stack->head;

	if (stack->base == stack->head) {
	    stack->head = ALLOC_N(struct _Helper, len + HELPER_STACK_INC);
	    memcpy(stack->head, stack->base, sizeof(struct _Helper) * len);
	} else {
	    REALLOC_N(stack->head, struct _Helper, len + HELPER_STACK_INC);
	}
	stack->tail = stack->head + toff;
	stack->end = stack->head + len + HELPER_STACK_INC;
    }
    stack->tail->var = var;
    stack->tail->obj = obj;
    stack->tail->type = type;
    stack->tail++;

    return stack->tail - 1;
}

inline static Helper
helper_stack_peek(HelperStack stack) {
    if (stack->head < stack->tail) {
	return stack->tail - 1;
    }
    return 0;
}

inline static Helper
helper_stack_pop(HelperStack stack) {
    if (stack->head < stack->tail) {
	stack->tail--;
	return stack->tail;
    }
    return 0;
}

#endif /* __OX_HELPER_H__ */
