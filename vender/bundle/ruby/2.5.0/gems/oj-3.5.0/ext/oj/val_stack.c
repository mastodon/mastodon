/* val_stack.c
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

#include "oj.h"
#include "val_stack.h"

static void
mark(void *ptr) {
    ValStack	stack = (ValStack)ptr;
    Val		v;

    if (0 == ptr) {
	return;
    }
#if USE_PTHREAD_MUTEX
    pthread_mutex_lock(&stack->mutex);
#elif USE_RB_MUTEX
    rb_mutex_lock(stack->mutex);
    rb_gc_mark(stack->mutex);
#endif
    for (v = stack->head; v < stack->tail; v++) {
	if (Qnil != v->val && Qundef != v->val) {
	    rb_gc_mark(v->val);
	}
	if (Qnil != v->key_val && Qundef != v->key_val) {
	    rb_gc_mark(v->key_val);
	}
    }
#if USE_PTHREAD_MUTEX
    pthread_mutex_unlock(&stack->mutex);
#elif USE_RB_MUTEX
    rb_mutex_unlock(stack->mutex);
#endif
}

VALUE
oj_stack_init(ValStack stack) {
#if USE_PTHREAD_MUTEX
    pthread_mutex_init(&stack->mutex, 0);
#elif USE_RB_MUTEX
    stack->mutex = rb_mutex_new();
#endif
    stack->head = stack->base;
    stack->end = stack->base + sizeof(stack->base) / sizeof(struct _Val);
    stack->tail = stack->head;
    stack->head->val = Qundef;
    stack->head->key = 0;
    stack->head->key_val = Qundef;
    stack->head->classname = 0;
    stack->head->klen = 0;
    stack->head->clen = 0;
    stack->head->next = NEXT_NONE;
    return Data_Wrap_Struct(oj_cstack_class, mark, 0, stack);
}

const char*
oj_stack_next_string(ValNext n) {
    switch (n) {
    case NEXT_ARRAY_NEW:	return "array element or close";
    case NEXT_ARRAY_ELEMENT:	return "array element";
    case NEXT_ARRAY_COMMA:	return "comma";
    case NEXT_HASH_NEW:		return "hash pair or close";
    case NEXT_HASH_KEY:		return "hash key";
    case NEXT_HASH_COLON:	return "colon";
    case NEXT_HASH_VALUE:	return "hash value";
    case NEXT_HASH_COMMA:	return "comma";
    case NEXT_NONE:		break;
    default:			break;
    }
    return "nothing";
}
