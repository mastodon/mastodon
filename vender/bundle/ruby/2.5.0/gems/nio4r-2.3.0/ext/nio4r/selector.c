/*
 * Copyright (c) 2011 Tony Arcieri. Distributed under the MIT License. See
 * LICENSE.txt for further details.
 */

#include "nio4r.h"
#ifdef HAVE_RUBYSIG_H
# include "rubysig.h"
#endif

#ifdef HAVE_UNISTD_H
#include <unistd.h>
#else
#include <io.h>
#endif

#include <fcntl.h>
#include <assert.h>

static VALUE mNIO = Qnil;
static VALUE cNIO_Monitor  = Qnil;
static VALUE cNIO_Selector = Qnil;

/* Allocator/deallocator */
static VALUE NIO_Selector_allocate(VALUE klass);
static void NIO_Selector_mark(struct NIO_Selector *loop);
static void NIO_Selector_shutdown(struct NIO_Selector *selector);
static void NIO_Selector_free(struct NIO_Selector *loop);

/* Class methods */
static VALUE NIO_Selector_supported_backends(VALUE klass);

/* Instance methods */
static VALUE NIO_Selector_initialize(int argc, VALUE *argv, VALUE self);
static VALUE NIO_Selector_backend(VALUE self);
static VALUE NIO_Selector_register(VALUE self, VALUE selectable, VALUE interest);
static VALUE NIO_Selector_deregister(VALUE self, VALUE io);
static VALUE NIO_Selector_is_registered(VALUE self, VALUE io);
static VALUE NIO_Selector_select(int argc, VALUE *argv, VALUE self);
static VALUE NIO_Selector_wakeup(VALUE self);
static VALUE NIO_Selector_close(VALUE self);
static VALUE NIO_Selector_closed(VALUE self);
static VALUE NIO_Selector_is_empty(VALUE self);

/* Internal functions */
static VALUE NIO_Selector_synchronize(VALUE self, VALUE (*func)(VALUE *args), VALUE *args);
static VALUE NIO_Selector_unlock(VALUE lock);
static VALUE NIO_Selector_register_synchronized(VALUE *args);
static VALUE NIO_Selector_deregister_synchronized(VALUE *args);
static VALUE NIO_Selector_select_synchronized(VALUE *args);
static VALUE NIO_Selector_close_synchronized(VALUE *args);
static VALUE NIO_Selector_closed_synchronized(VALUE *args);

static int NIO_Selector_run(struct NIO_Selector *selector, VALUE timeout);
static void NIO_Selector_timeout_callback(ev_loop *ev_loop, struct ev_timer *timer, int revents);
static void NIO_Selector_wakeup_callback(ev_loop *ev_loop, struct ev_io *io, int revents);

/* Default number of slots in the buffer for selected monitors */
#define INITIAL_READY_BUFFER 32

/* Ruby 1.8 needs us to busy wait and run the green threads scheduler every 10ms */
#define BUSYWAIT_INTERVAL 0.01

/* Selectors wait for events */
void Init_NIO_Selector()
{
    mNIO = rb_define_module("NIO");
    cNIO_Selector = rb_define_class_under(mNIO, "Selector", rb_cObject);
    rb_define_alloc_func(cNIO_Selector, NIO_Selector_allocate);

    rb_define_singleton_method(cNIO_Selector, "backends", NIO_Selector_supported_backends, 0);
    rb_define_method(cNIO_Selector, "initialize", NIO_Selector_initialize, -1);
    rb_define_method(cNIO_Selector, "backend", NIO_Selector_backend, 0);
    rb_define_method(cNIO_Selector, "register", NIO_Selector_register, 2);
    rb_define_method(cNIO_Selector, "deregister", NIO_Selector_deregister, 1);
    rb_define_method(cNIO_Selector, "registered?", NIO_Selector_is_registered, 1);
    rb_define_method(cNIO_Selector, "select", NIO_Selector_select, -1);
    rb_define_method(cNIO_Selector, "wakeup", NIO_Selector_wakeup, 0);
    rb_define_method(cNIO_Selector, "close", NIO_Selector_close, 0);
    rb_define_method(cNIO_Selector, "closed?", NIO_Selector_closed, 0);
    rb_define_method(cNIO_Selector, "empty?", NIO_Selector_is_empty, 0);

    cNIO_Monitor = rb_define_class_under(mNIO, "Monitor",  rb_cObject);
}

/* Create the libev event loop and incoming event buffer */
static VALUE NIO_Selector_allocate(VALUE klass)
{
    struct NIO_Selector *selector;
    int fds[2];

    /* Use a pipe to implement the wakeup mechanism. I know libev provides
       async watchers that implement this same behavior, but I'm getting
       segvs trying to use that between threads, despite claims of thread
       safety. Pipes are nice and safe to use between threads.

       Note that Java NIO uses this same mechanism */
    if(pipe(fds) < 0) {
        rb_sys_fail("pipe");
    }

    /* Use non-blocking reads/writes during wakeup, in case the buffer is full */
    if(fcntl(fds[0], F_SETFL, O_NONBLOCK) < 0 ||
       fcntl(fds[1], F_SETFL, O_NONBLOCK) < 0) {
        rb_sys_fail("fcntl");
    }

    selector = (struct NIO_Selector *)xmalloc(sizeof(struct NIO_Selector));

    /* Defer initializing the loop to #initialize */
    selector->ev_loop = 0;

    ev_init(&selector->timer, NIO_Selector_timeout_callback);

    selector->wakeup_reader = fds[0];
    selector->wakeup_writer = fds[1];

    ev_io_init(&selector->wakeup, NIO_Selector_wakeup_callback, selector->wakeup_reader, EV_READ);
    selector->wakeup.data = (void *)selector;

    selector->closed = selector->selecting = selector->wakeup_fired = selector->ready_count = 0;
    selector->ready_array = Qnil;

    return Data_Wrap_Struct(klass, NIO_Selector_mark, NIO_Selector_free, selector);
}

/* NIO selectors store all Ruby objects in instance variables so mark is a stub */
static void NIO_Selector_mark(struct NIO_Selector *selector)
{
    if(selector->ready_array != Qnil) {
        rb_gc_mark(selector->ready_array);
    }
}

/* Free a Selector's system resources.
   Called by both NIO::Selector#close and the finalizer below */
static void NIO_Selector_shutdown(struct NIO_Selector *selector)
{
    if(selector->closed) {
        return;
    }

    close(selector->wakeup_reader);
    close(selector->wakeup_writer);

    if(selector->ev_loop) {
        ev_loop_destroy(selector->ev_loop);
        selector->ev_loop = 0;
    }

    selector->closed = 1;
}

/* Ruby finalizer for selector objects */
static void NIO_Selector_free(struct NIO_Selector *selector)
{
    NIO_Selector_shutdown(selector);
    xfree(selector);
}

/* Return an array of symbols for supported backends */
static VALUE NIO_Selector_supported_backends(VALUE klass) {
    unsigned int backends = ev_supported_backends();
    VALUE result = rb_ary_new();

    if(backends & EVBACKEND_EPOLL) {
        rb_ary_push(result, ID2SYM(rb_intern("epoll")));
    }

    if(backends & EVBACKEND_POLL) {
        rb_ary_push(result, ID2SYM(rb_intern("poll")));
    }

    if(backends & EVBACKEND_KQUEUE) {
        rb_ary_push(result, ID2SYM(rb_intern("kqueue")));
    }

    if(backends & EVBACKEND_SELECT) {
        rb_ary_push(result, ID2SYM(rb_intern("select")));
    }

    if(backends & EVBACKEND_PORT) {
        rb_ary_push(result, ID2SYM(rb_intern("port")));
    }

    return result;
}

/* Create a new selector. This is more or less the pure Ruby version
   translated into an MRI cext */
static VALUE NIO_Selector_initialize(int argc, VALUE *argv, VALUE self)
{
    ID backend_id;
    VALUE backend;
    VALUE lock;

    struct NIO_Selector *selector;
    unsigned int flags = 0;

    Data_Get_Struct(self, struct NIO_Selector, selector);

    rb_scan_args(argc, argv, "01", &backend);

    if(backend != Qnil) {
        if(!rb_ary_includes(NIO_Selector_supported_backends(CLASS_OF(self)), backend)) {
            rb_raise(rb_eArgError, "unsupported backend: %s",
                RSTRING_PTR(rb_funcall(backend, rb_intern("inspect"), 0)));
        }

        backend_id = SYM2ID(backend);

        if(backend_id == rb_intern("epoll")) {
            flags = EVBACKEND_EPOLL;
        } else if(backend_id == rb_intern("poll")) {
            flags = EVBACKEND_POLL;
        } else if(backend_id == rb_intern("kqueue")) {
            flags = EVBACKEND_KQUEUE;
        } else if(backend_id == rb_intern("select")) {
            flags = EVBACKEND_SELECT;
        } else if(backend_id == rb_intern("port")) {
            flags = EVBACKEND_PORT;
        } else {
            rb_raise(rb_eArgError, "unsupported backend: %s",
                RSTRING_PTR(rb_funcall(backend, rb_intern("inspect"), 0)));
        }
    }

    /* Ensure the selector loop has not yet been initialized */
    assert(!selector->ev_loop);

    selector->ev_loop = ev_loop_new(flags);
    if(!selector->ev_loop) {
        rb_raise(rb_eIOError, "error initializing event loop");
    }

    ev_io_start(selector->ev_loop, &selector->wakeup);

    rb_ivar_set(self, rb_intern("selectables"), rb_hash_new());
    rb_ivar_set(self, rb_intern("lock_holder"), Qnil);

    lock = rb_class_new_instance(0, 0, rb_const_get(rb_cObject, rb_intern("Mutex")));
    rb_ivar_set(self, rb_intern("lock"), lock);
    rb_ivar_set(self, rb_intern("lock_holder"), Qnil);

    return Qnil;
}

static VALUE NIO_Selector_backend(VALUE self) {
    struct NIO_Selector *selector;

    Data_Get_Struct(self, struct NIO_Selector, selector);
    if(selector->closed) {
        rb_raise(rb_eIOError, "selector is closed");
    }

    switch (ev_backend(selector->ev_loop)) {
        case EVBACKEND_EPOLL:
            return ID2SYM(rb_intern("epoll"));
        case EVBACKEND_POLL:
            return ID2SYM(rb_intern("poll"));
        case EVBACKEND_KQUEUE:
            return ID2SYM(rb_intern("kqueue"));
        case EVBACKEND_SELECT:
            return ID2SYM(rb_intern("select"));
        case EVBACKEND_PORT:
            return ID2SYM(rb_intern("port"));
    }

    return ID2SYM(rb_intern("unknown"));
}

/* Synchronize around a reentrant selector lock */
static VALUE NIO_Selector_synchronize(VALUE self, VALUE (*func)(VALUE *args), VALUE *args)
{
    VALUE current_thread, lock_holder, lock;

    current_thread = rb_thread_current();
    lock_holder = rb_ivar_get(self, rb_intern("lock_holder"));

    if(lock_holder != current_thread) {
        lock = rb_ivar_get(self, rb_intern("lock"));
        rb_funcall(lock, rb_intern("lock"), 0);
        rb_ivar_set(self, rb_intern("lock_holder"), current_thread);

        /* We've acquired the lock, so ensure we unlock it */
        return rb_ensure(func, (VALUE)args, NIO_Selector_unlock, self);
    } else {
        /* We already hold the selector lock, so no need to unlock it */
        return func(args);
    }
}

/* Unlock the selector mutex */
static VALUE NIO_Selector_unlock(VALUE self)
{
    VALUE lock;

    rb_ivar_set(self, rb_intern("lock_holder"), Qnil);

    lock = rb_ivar_get(self, rb_intern("lock"));
    rb_funcall(lock, rb_intern("unlock"), 0);

    return Qnil;
}

/* Register an IO object with the selector for the given interests */
static VALUE NIO_Selector_register(VALUE self, VALUE io, VALUE interests)
{
    VALUE args[3] = {self, io, interests};
    return NIO_Selector_synchronize(self, NIO_Selector_register_synchronized, args);
}

/* Internal implementation of register after acquiring mutex */
static VALUE NIO_Selector_register_synchronized(VALUE *args)
{
    VALUE self, io, interests, selectables, monitor;
    VALUE monitor_args[3];
    struct NIO_Selector *selector;

    self = args[0];
    io = args[1];
    interests = args[2];

    Data_Get_Struct(self, struct NIO_Selector, selector);
    if(selector->closed) {
        rb_raise(rb_eIOError, "selector is closed");
    }

    selectables = rb_ivar_get(self, rb_intern("selectables"));
    monitor = rb_hash_lookup(selectables, io);

    if(monitor != Qnil)
        rb_raise(rb_eArgError, "this IO is already registered with selector");

    /* Create a new NIO::Monitor */
    monitor_args[0] = io;
    monitor_args[1] = interests;
    monitor_args[2] = self;

    monitor = rb_class_new_instance(3, monitor_args, cNIO_Monitor);
    rb_hash_aset(selectables, rb_funcall(monitor, rb_intern("io"), 0), monitor);

    return monitor;
}

/* Deregister an IO object from the selector */
static VALUE NIO_Selector_deregister(VALUE self, VALUE io)
{
    VALUE args[2] = {self, io};
    return NIO_Selector_synchronize(self, NIO_Selector_deregister_synchronized, args);
}

/* Internal implementation of register after acquiring mutex */
static VALUE NIO_Selector_deregister_synchronized(VALUE *args)
{
    VALUE self, io, selectables, monitor;

    self = args[0];
    io = args[1];

    selectables = rb_ivar_get(self, rb_intern("selectables"));
    monitor = rb_hash_delete(selectables, io);

    if(monitor != Qnil) {
        rb_funcall(monitor, rb_intern("close"), 1, Qfalse);
    }

    return monitor;
}

/* Is the given IO object registered with the selector */
static VALUE NIO_Selector_is_registered(VALUE self, VALUE io)
{
    VALUE selectables = rb_ivar_get(self, rb_intern("selectables"));

    /* Perhaps this should be holding the mutex? */
    return rb_funcall(selectables, rb_intern("has_key?"), 1, io);
}

/* Select from all registered IO objects */
static VALUE NIO_Selector_select(int argc, VALUE *argv, VALUE self)
{
    VALUE timeout;
    VALUE args[2];

    rb_scan_args(argc, argv, "01", &timeout);

    if(timeout != Qnil && NUM2DBL(timeout) < 0) {
        rb_raise(rb_eArgError, "time interval must be positive");
    }

    args[0] = self;
    args[1] = timeout;

    return NIO_Selector_synchronize(self, NIO_Selector_select_synchronized, args);
}

/* Internal implementation of select with the selector lock held */
static VALUE NIO_Selector_select_synchronized(VALUE *args)
{
    int ready;
    VALUE ready_array;
    struct NIO_Selector *selector;

    Data_Get_Struct(args[0], struct NIO_Selector, selector);

    if(selector->closed) {
        rb_raise(rb_eIOError, "selector is closed");
    }

    if(!rb_block_given_p()) {
        selector->ready_array = rb_ary_new();
    }

    ready = NIO_Selector_run(selector, args[1]);

    /* Timeout */
    if(ready < 0) {
        if(!rb_block_given_p()) {
            selector->ready_array = Qnil;
        }

        return Qnil;
    }

    if(rb_block_given_p()) {
        return INT2NUM(ready);
    } else {
        ready_array = selector->ready_array;
        selector->ready_array = Qnil;
        return ready_array;
    }
}

static int NIO_Selector_run(struct NIO_Selector *selector, VALUE timeout)
{
    int ev_run_flags = EVRUN_ONCE;
    int result;
    double timeout_val;

    selector->selecting = 1;
    selector->wakeup_fired = 0;

    if(timeout == Qnil) {
        /* Don't fire a wakeup timeout if we weren't passed one */
        ev_timer_stop(selector->ev_loop, &selector->timer);
    } else {
        timeout_val = NUM2DBL(timeout);
        if(timeout_val == 0) {
            /* If we've been given an explicit timeout of 0, perform a non-blocking
               select operation */
            ev_run_flags = EVRUN_NOWAIT;
        } else {
            selector->timer.repeat = timeout_val;
            ev_timer_again(selector->ev_loop, &selector->timer);
        }
    }

    /* libev is patched to release the GIL when it makes its system call */
    ev_run(selector->ev_loop, ev_run_flags);

    result = selector->ready_count;
    selector->selecting = selector->ready_count = 0;

    if(result > 0 || selector->wakeup_fired) {
        selector->wakeup_fired = 0;
        return result;
    } else {
        return -1;
    }
}

/* Wake the selector up from another thread */
static VALUE NIO_Selector_wakeup(VALUE self)
{
    struct NIO_Selector *selector;
    Data_Get_Struct(self, struct NIO_Selector, selector);

    if(selector->closed) {
        rb_raise(rb_eIOError, "selector is closed");
    }

    selector->wakeup_fired = 1;
    write(selector->wakeup_writer, "\0", 1);

    return Qnil;
}

/* Close the selector and free system resources */
static VALUE NIO_Selector_close(VALUE self)
{
    VALUE args[1] = {self};
    return NIO_Selector_synchronize(self, NIO_Selector_close_synchronized, args);
}

static VALUE NIO_Selector_close_synchronized(VALUE *args)
{
    struct NIO_Selector *selector;
    VALUE self = args[0];
    Data_Get_Struct(self, struct NIO_Selector, selector);

    NIO_Selector_shutdown(selector);

    return Qnil;
}

/* Is the selector closed? */
static VALUE NIO_Selector_closed(VALUE self)
{
    VALUE args[1] = {self};
    return NIO_Selector_synchronize(self, NIO_Selector_closed_synchronized, args);
}

static VALUE NIO_Selector_closed_synchronized(VALUE *args)
{
    struct NIO_Selector *selector;
    VALUE self = args[0];
    Data_Get_Struct(self, struct NIO_Selector, selector);

    return selector->closed ? Qtrue : Qfalse;
}

/* True if there are monitors on the loop */
static VALUE NIO_Selector_is_empty(VALUE self)
{
    VALUE selectables = rb_ivar_get(self, rb_intern("selectables"));

    return rb_funcall(selectables, rb_intern("empty?"), 0) == Qtrue ? Qtrue : Qfalse;
}


/* Called whenever a timeout fires on the event loop */
static void NIO_Selector_timeout_callback(ev_loop *ev_loop, struct ev_timer *timer, int revents)
{
}

/* Called whenever a wakeup request is sent to a selector */
static void NIO_Selector_wakeup_callback(ev_loop *ev_loop, struct ev_io *io, int revents)
{
    char buffer[128];
    struct NIO_Selector *selector = (struct NIO_Selector *)io->data;
    selector->selecting = 0;

    /* Drain the wakeup pipe, giving us level-triggered behavior */
    while(read(selector->wakeup_reader, buffer, 128) > 0);
}

/* libev callback fired whenever a monitor gets an event */
void NIO_Selector_monitor_callback(ev_loop *ev_loop, struct ev_io *io, int revents)
{
    struct NIO_Monitor *monitor_data = (struct NIO_Monitor *)io->data;
    struct NIO_Selector *selector = monitor_data->selector;
    VALUE monitor = monitor_data->self;

    assert(selector != 0);
    selector->ready_count++;
    monitor_data->revents = revents;

    if(rb_block_given_p()) {
        rb_yield(monitor);
    } else {
        assert(selector->ready_array != Qnil);
        rb_ary_push(selector->ready_array, monitor);
    }
}
