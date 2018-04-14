/*
 * Copyright (c) 2008, 2009, Wayne Meissner
 *
 * Copyright (c) 2008-2013, Ruby FFI project contributors
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of the Ruby FFI project nor the
 *       names of its contributors may be used to endorse or promote products
 *       derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#ifndef _MSC_VER
# include <stdint.h>
# include <stdbool.h>
#else
# include "win32/stdint.h"
# include "win32/stdbool.h"
#endif
#include <limits.h>
#include <ruby.h>
#include "rbffi.h"
#include "rbffi_endian.h"
#include "AbstractMemory.h"
#include "Pointer.h"

#define POINTER(obj) rbffi_AbstractMemory_Cast((obj), rbffi_PointerClass)

VALUE rbffi_PointerClass = Qnil;
VALUE rbffi_NullPointerSingleton = Qnil;

static void ptr_release(Pointer* ptr);
static void ptr_mark(Pointer* ptr);

VALUE
rbffi_Pointer_NewInstance(void* addr)
{
    Pointer* p;
    VALUE obj;

    if (addr == NULL) {
        return rbffi_NullPointerSingleton;
    }

    obj = Data_Make_Struct(rbffi_PointerClass, Pointer, NULL, -1, p);
    p->memory.address = addr;
    p->memory.size = LONG_MAX;
    p->memory.flags = (addr == NULL) ? 0 : (MEM_RD | MEM_WR);
    p->memory.typeSize = 1;
    p->rbParent = Qnil;

    return obj;
}

static VALUE
ptr_allocate(VALUE klass)
{
    Pointer* p;
    VALUE obj;

    obj = Data_Make_Struct(klass, Pointer, ptr_mark, ptr_release, p);
    p->rbParent = Qnil;
    p->memory.flags = MEM_RD | MEM_WR;

    return obj;
}

/*
 * @overload initialize(pointer)
 *  @param [Pointer] pointer another pointer to initialize from
 *  Create a new pointer from another {Pointer}.
 * @overload initialize(type, address)
 *  @param [Type] type type for pointer
 *  @param [Integer] address base address for pointer
 *  Create a new pointer from a {Type} and a base address
 * @return [self]
 * A new instance of Pointer.
 */
static VALUE
ptr_initialize(int argc, VALUE* argv, VALUE self)
{
    Pointer* p;
    VALUE rbType = Qnil, rbAddress = Qnil;
    int typeSize = 1;

    Data_Get_Struct(self, Pointer, p);

    switch (rb_scan_args(argc, argv, "11", &rbType, &rbAddress)) {
        case 1:
            rbAddress = rbType;
            typeSize = 1;
            break;
        case 2:
            typeSize = rbffi_type_size(rbType);
            break;
        default:
            rb_raise(rb_eArgError, "Invalid arguments");
    }

    switch (TYPE(rbAddress)) {
        case T_FIXNUM:
        case T_BIGNUM:
            p->memory.address = (void*) (uintptr_t) NUM2LL(rbAddress);
            p->memory.size = LONG_MAX;
            if (p->memory.address == NULL) {
                p->memory.flags = 0;
            }
            break;

        default:
            if (rb_obj_is_kind_of(rbAddress, rbffi_PointerClass)) {
                Pointer* orig;

                p->rbParent = rbAddress;
                Data_Get_Struct(rbAddress, Pointer, orig);
                p->memory = orig->memory;
            } else {
                rb_raise(rb_eTypeError, "wrong argument type, expected Integer or FFI::Pointer");
            }
            break;
    }

    p->memory.typeSize = typeSize;

    return self;
}

/*
 * call-seq: ptr.initialize_copy(other)
 * @param [Pointer] other source for cloning or dupping
 * @return [self]
 * @raise {RuntimeError} if +other+ is an unbounded memory area, or is unreadable/unwritable
 * @raise {NoMemError} if failed to allocate memory for new object
 * DO NOT CALL THIS METHOD.
 *
 * This method is internally used by #dup and #clone. Memory content is copied from +other+.
 */
static VALUE
ptr_initialize_copy(VALUE self, VALUE other)
{
    AbstractMemory* src;
    Pointer* dst;
    
    Data_Get_Struct(self, Pointer, dst);
    src = POINTER(other);
    if (src->size == LONG_MAX) {
        rb_raise(rb_eRuntimeError, "cannot duplicate unbounded memory area");
        return Qnil;
    }
    
    if ((dst->memory.flags & (MEM_RD | MEM_WR)) != (MEM_RD | MEM_WR)) {
        rb_raise(rb_eRuntimeError, "cannot duplicate unreadable/unwritable memory area");
        return Qnil;
    }

    if (dst->storage != NULL) {
        xfree(dst->storage);
        dst->storage = NULL;
    }

    dst->storage = xmalloc(src->size + 7);
    if (dst->storage == NULL) {
        rb_raise(rb_eNoMemError, "failed to allocate memory size=%lu bytes", src->size);
        return Qnil;
    }
    
    dst->allocated = true;
    dst->autorelease = true;
    dst->memory.address = (void *) (((uintptr_t) dst->storage + 0x7) & (uintptr_t) ~0x7UL);
    dst->memory.size = src->size;
    dst->memory.typeSize = src->typeSize;
    
    /* finally, copy the actual memory contents */
    memcpy(dst->memory.address, src->address, src->size);

    return self;
}

static VALUE
slice(VALUE self, long offset, long size)
{
    AbstractMemory* ptr;
    Pointer* p;
    VALUE retval;
    
    Data_Get_Struct(self, AbstractMemory, ptr);
    checkBounds(ptr, offset, size == LONG_MAX ? 1 : size);

    retval = Data_Make_Struct(rbffi_PointerClass, Pointer, ptr_mark, -1, p);

    p->memory.address = ptr->address + offset;
    p->memory.size = size;
    p->memory.flags = ptr->flags;
    p->memory.typeSize = ptr->typeSize;
    p->rbParent = self;

    return retval;
}

/* 
 * Document-method: +
 * call-seq: ptr + offset
 * @param [Numeric] offset
 * @return [Pointer]
 * Return a new {Pointer} from an existing pointer and an +offset+.
 */
static VALUE
ptr_plus(VALUE self, VALUE offset)
{
    AbstractMemory* ptr;
    long off = NUM2LONG(offset);

    Data_Get_Struct(self, AbstractMemory, ptr);

    return slice(self, off, ptr->size == LONG_MAX ? LONG_MAX : ptr->size - off);
}

/*
 * call-seq: ptr.slice(offset, length)
 * @param [Numeric] offset
 * @param [Numeric] length
 * @return [Pointer]
 * Return a new {Pointer} from an existing one. This pointer points on same contents 
 * from +offset+ for a length +length+.
 */
static VALUE
ptr_slice(VALUE self, VALUE rbOffset, VALUE rbLength)
{
    return slice(self, NUM2LONG(rbOffset), NUM2LONG(rbLength));
}

/*
 * call-seq: ptr.inspect
 * @return [String]
 * Inspect pointer object.
 */
static VALUE
ptr_inspect(VALUE self)
{
    char buf[100];
    Pointer* ptr;
    
    Data_Get_Struct(self, Pointer, ptr);

    if (ptr->memory.size != LONG_MAX) {
        snprintf(buf, sizeof(buf), "#<%s address=%p size=%lu>",
                rb_obj_classname(self), ptr->memory.address, ptr->memory.size);
    } else {
        snprintf(buf, sizeof(buf), "#<%s address=%p>", rb_obj_classname(self), ptr->memory.address);
    }

    return rb_str_new2(buf);
}

/*
 * Document-method: null?
 * call-seq: ptr.null?
 * @return [Boolean]
 * Return +true+ if +self+ is a {NULL} pointer.
 */
static VALUE
ptr_null_p(VALUE self)
{
    Pointer* ptr;

    Data_Get_Struct(self, Pointer, ptr);

    return ptr->memory.address == NULL ? Qtrue : Qfalse;
}

/*
 * Document-method: ==
 * call-seq: ptr == other
 * @param [Pointer] other
 * Check equality between +self+ and +other+. Equality is tested on {#address}.
 */
static VALUE
ptr_equals(VALUE self, VALUE other)
{
    Pointer* ptr;
    
    Data_Get_Struct(self, Pointer, ptr);

    if (NIL_P(other)) {
        return ptr->memory.address == NULL ? Qtrue : Qfalse;
    }

    return ptr->memory.address == POINTER(other)->address ? Qtrue : Qfalse;
}

/*
 * call-seq: ptr.address
 * @return [Numeric] pointer's base address
 * Return +self+'s base address (alias: #to_i).
 */
static VALUE
ptr_address(VALUE self)
{
    Pointer* ptr;
    
    Data_Get_Struct(self, Pointer, ptr);

    return ULL2NUM((uintptr_t) ptr->memory.address);
}

#if BYTE_ORDER == LITTLE_ENDIAN
# define SWAPPED_ORDER BIG_ENDIAN
#else
# define SWAPPED_ORDER LITTLE_ENDIAN
#endif

/*
 * Get or set +self+'s endianness
 * @overload order
 *  @return [:big, :little] endianness of +self+
 * @overload order(order)
 *  @param  [Symbol] order endianness to set (+:little+, +:big+ or +:network+). +:big+ and +:network+ 
 *   are synonymous.
 *  @return [self]
 */
static VALUE
ptr_order(int argc, VALUE* argv, VALUE self)
{
    Pointer* ptr;

    Data_Get_Struct(self, Pointer, ptr);
    if (argc == 0) {
        int order = (ptr->memory.flags & MEM_SWAP) == 0 ? BYTE_ORDER : SWAPPED_ORDER;
        return order == BIG_ENDIAN ? ID2SYM(rb_intern("big")) : ID2SYM(rb_intern("little"));
    } else {
        VALUE rbOrder = Qnil;
        int order = BYTE_ORDER;

        if (rb_scan_args(argc, argv, "1", &rbOrder) < 1) {
            rb_raise(rb_eArgError, "need byte order");
        }
        if (SYMBOL_P(rbOrder)) {
            ID id = SYM2ID(rbOrder);
            if (id == rb_intern("little")) {
                order = LITTLE_ENDIAN;

            } else if (id == rb_intern("big") || id == rb_intern("network")) {
                order = BIG_ENDIAN;
            }
        }
        if (order != BYTE_ORDER) {
            Pointer* p2;
            VALUE retval = slice(self, 0, ptr->memory.size);

            Data_Get_Struct(retval, Pointer, p2);
            p2->memory.flags |= MEM_SWAP;
            return retval;
        }

        return self;
    }
}


/*
 * call-seq: ptr.free
 * @return [self]
 * Free memory pointed by +self+.
 */
static VALUE
ptr_free(VALUE self)
{
    Pointer* ptr;

    Data_Get_Struct(self, Pointer, ptr);

    if (ptr->allocated) {
        if (ptr->storage != NULL) {
            xfree(ptr->storage);
            ptr->storage = NULL;
        }
        ptr->allocated = false;

    } else {
        VALUE caller = rb_funcall(rb_funcall(Qnil, rb_intern("caller"), 0), rb_intern("first"), 0);
        
        rb_warn("calling free on non allocated pointer %s from %s", RSTRING_PTR(ptr_inspect(self)), RSTRING_PTR(rb_str_to_str(caller)));
    }

    return self;
}

static VALUE
ptr_type_size(VALUE self)
{
    Pointer* ptr;

    Data_Get_Struct(self, Pointer, ptr);
    
    return INT2NUM(ptr->memory.typeSize);
}

/*
 * call-seq: ptr.autorelease = autorelease
 * @param [Boolean] autorelease
 * @return [Boolean] +autorelease+
 * Set +autorelease+ attribute. See also Autorelease section.
 */
static VALUE
ptr_autorelease(VALUE self, VALUE autorelease)
{
    Pointer* ptr;

    Data_Get_Struct(self, Pointer, ptr);
    ptr->autorelease = autorelease == Qtrue;

    return autorelease;
}

/*
 * call-seq: ptr.autorelease?
 * @return [Boolean]
 * Get +autorelease+ attribute. See also Autorelease section.
 */
static VALUE
ptr_autorelease_p(VALUE self)
{
    Pointer* ptr;

    Data_Get_Struct(self, Pointer, ptr);
    
    return ptr->autorelease ? Qtrue : Qfalse;
}


static void
ptr_release(Pointer* ptr)
{
    if (ptr->autorelease && ptr->allocated && ptr->storage != NULL) {
        xfree(ptr->storage);
        ptr->storage = NULL;
    }
    xfree(ptr);
}

static void
ptr_mark(Pointer* ptr)
{
    rb_gc_mark(ptr->rbParent);
}

void
rbffi_Pointer_Init(VALUE moduleFFI)
{
    VALUE rbNullAddress = ULL2NUM(0);
    VALUE ffi_AbstractMemory =  rbffi_AbstractMemoryClass;

    /*
     * Document-class: FFI::Pointer < FFI::AbstractMemory
     * Pointer class is used to manage C pointers with ease. A {Pointer} object is defined by his
     * {#address} (as a C pointer). It permits additions with an integer for pointer arithmetic.
     *
     * ==Autorelease
     * A pointer object may autorelease his contents when freed (by default). This behaviour may be
     * changed with {#autorelease=} method.
     */
    rbffi_PointerClass = rb_define_class_under(moduleFFI, "Pointer", ffi_AbstractMemory);
    /*
     * Document-variable: Pointer
     */
    rb_global_variable(&rbffi_PointerClass);

    rb_define_alloc_func(rbffi_PointerClass, ptr_allocate);
    rb_define_method(rbffi_PointerClass, "initialize", ptr_initialize, -1);
    rb_define_method(rbffi_PointerClass, "initialize_copy", ptr_initialize_copy, 1);
    rb_define_method(rbffi_PointerClass, "inspect", ptr_inspect, 0);
    rb_define_method(rbffi_PointerClass, "to_s", ptr_inspect, 0);
    rb_define_method(rbffi_PointerClass, "+", ptr_plus, 1);
    rb_define_method(rbffi_PointerClass, "slice", ptr_slice, 2);
    rb_define_method(rbffi_PointerClass, "null?", ptr_null_p, 0);
    rb_define_method(rbffi_PointerClass, "address", ptr_address, 0);
    rb_define_alias(rbffi_PointerClass, "to_i", "address");
    rb_define_method(rbffi_PointerClass, "==", ptr_equals, 1);
    rb_define_method(rbffi_PointerClass, "order", ptr_order, -1);
    rb_define_method(rbffi_PointerClass, "autorelease=", ptr_autorelease, 1);
    rb_define_method(rbffi_PointerClass, "autorelease?", ptr_autorelease_p, 0);
    rb_define_method(rbffi_PointerClass, "free", ptr_free, 0);
    rb_define_method(rbffi_PointerClass, "type_size", ptr_type_size, 0);

    rbffi_NullPointerSingleton = rb_class_new_instance(1, &rbNullAddress, rbffi_PointerClass);
    /*
     * NULL pointer
     */
    rb_define_const(rbffi_PointerClass, "NULL", rbffi_NullPointerSingleton);
}

