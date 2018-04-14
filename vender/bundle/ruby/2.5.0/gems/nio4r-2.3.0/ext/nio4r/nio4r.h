/*
 * Copyright (c) 2011 Tony Arcieri. Distributed under the MIT License. See
 * LICENSE.txt for further details.
 */

#ifndef NIO4R_H
#define NIO4R_H

#include "ruby.h"
#include "ruby/io.h"
#include "libev.h"

struct NIO_Selector
{
    ev_loop *ev_loop;
    struct ev_timer timer; /* for timeouts */
    struct ev_io wakeup;

    int ready_count;
    int closed, selecting;
    int wakeup_reader, wakeup_writer;
    volatile int wakeup_fired;

    VALUE ready_array;
};

struct NIO_callback_data
{
    VALUE *monitor;
    struct NIO_Selector *selector;
};

struct NIO_Monitor
{
    VALUE self;
    int interests, revents;
    struct ev_io ev_io;
    struct NIO_Selector *selector;
};

struct NIO_ByteBuffer
{
    char *buffer;
    int position, limit, capacity, mark;
};


#ifdef GetReadFile
# define FPTR_TO_FD(fptr) (fileno(GetReadFile(fptr)))
#else
# define FPTR_TO_FD(fptr) fptr->fd
#endif /* GetReadFile */

/* Thunk between libev callbacks in NIO::Monitors and NIO::Selectors */
void NIO_Selector_monitor_callback(struct ev_loop *ev_loop, struct ev_io *io, int revents);

#endif /* NIO4R_H */
