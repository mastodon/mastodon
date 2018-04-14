/* val_stack.h
 * Copyright (c) 2011, Peter Ohler
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 
 *  - Redistributions of source code must retain the above copyright notice, this
 *    list of conditions and the following disclaimer.
 * 
 *  - Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 * 
 *  - Neither the name of Peter Ohler nor the names of its contributors may be
 *    used to endorse or promote products derived from this software without
 *    specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#ifndef __OJ_VAL_STACK_H__
#define __OJ_VAL_STACK_H__

#include "ruby.h"
#include "odd.h"
#include <stdint.h>
#if USE_PTHREAD_MUTEX
#include <pthread.h>
#endif

#define STACK_INC	64

typedef enum {
    NEXT_NONE		= 0,
    NEXT_ARRAY_NEW	= 'a',
    NEXT_ARRAY_ELEMENT	= 'e',
    NEXT_ARRAY_COMMA	= ',',
    NEXT_HASH_NEW	= 'h',
    NEXT_HASH_KEY	= 'k',
    NEXT_HASH_COLON	= ':',
    NEXT_HASH_VALUE	= 'v',
    NEXT_HASH_COMMA	= 'n',
} ValNext;

typedef struct _Val {
    volatile VALUE	val;
    const char		*key;
    char		karray[32];
    volatile VALUE	key_val;
    union {
	struct {
	    const char	*classname;
	    VALUE	clas;
	};
	OddArgs		odd_args;
    };
    uint16_t		klen;
    uint16_t		clen;
    char		next; // ValNext
    char		k1;   // first original character in the key
    char		kalloc;
} *Val;

typedef struct _ValStack {
    struct _Val		base[STACK_INC];
    Val			head;	// current stack
    Val			end;	// stack end
    Val			tail;	// pointer to one past last element name on stack
#if USE_PTHREAD_MUTEX
    pthread_mutex_t	mutex;
#elif USE_RB_MUTEX
    VALUE		mutex;
#endif

} *ValStack;

extern VALUE	oj_stack_init(ValStack stack);

inline static int
stack_empty(ValStack stack) {
    return (stack->head == stack->tail);
}

inline static void
stack_cleanup(ValStack stack) {
    if (stack->base != stack->head) {
        xfree(stack->head);
	stack->head = NULL;
    }
}

inline static void
stack_push(ValStack stack, VALUE val, ValNext next) {
    if (stack->end <= stack->tail) {
	size_t	len = stack->end - stack->head;
	size_t	toff = stack->tail - stack->head;
	Val	head = stack->head;

	// A realloc can trigger a GC so make sure it happens outside the lock
	// but lock before changing pointers.
	if (stack->base == stack->head) {
	    head = ALLOC_N(struct _Val, len + STACK_INC);
	    memcpy(head, stack->base, sizeof(struct _Val) * len);
	} else {
	    REALLOC_N(head, struct _Val, len + STACK_INC);
	}
#if USE_PTHREAD_MUTEX
	pthread_mutex_lock(&stack->mutex);
#elif USE_RB_MUTEX
	rb_mutex_lock(stack->mutex);
#endif
	stack->head = head;
	stack->tail = stack->head + toff;
	stack->end = stack->head + len + STACK_INC;
#if USE_PTHREAD_MUTEX
	pthread_mutex_unlock(&stack->mutex);
#elif USE_RB_MUTEX
	rb_mutex_unlock(stack->mutex);
#endif
    }
    stack->tail->val = val;
    stack->tail->next = next;
    stack->tail->classname = NULL;
    stack->tail->clas = Qundef;
    stack->tail->key = 0;
    stack->tail->key_val = Qundef;
    stack->tail->clen = 0;
    stack->tail->klen = 0;
    stack->tail->kalloc = 0;
    stack->tail++;
}

inline static size_t
stack_size(ValStack stack) {
    return stack->tail - stack->head;
}

inline static Val
stack_peek(ValStack stack) {
    if (stack->head < stack->tail) {
	return stack->tail - 1;
    }
    return 0;
}

inline static Val
stack_peek_up(ValStack stack) {
    if (stack->head < stack->tail - 1) {
	return stack->tail - 2;
    }
    return 0;
}

inline static Val
stack_prev(ValStack stack) {
    return stack->tail;
}

inline static VALUE
stack_head_val(ValStack stack) {
    if (Qundef != stack->head->val) {
	return stack->head->val;
    }
    return Qnil;
}

inline static Val
stack_pop(ValStack stack) {
    if (stack->head < stack->tail) {
	stack->tail--;
	return stack->tail;
    }
    return 0;
}

extern const char*	oj_stack_next_string(ValNext n);

#endif /* __OJ_VAL_STACK_H__ */
