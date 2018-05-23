/* buf.h
 * Copyright (c) 2014, Peter Ohler
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

#ifndef __OX_BUF_H__
#define __OX_BUF_H__

#include <stdbool.h>
#include <unistd.h>

typedef struct _Buf {
    char	*head;
    char	*end;
    char	*tail;
    int		fd;
    bool	err;
    char	base[16384];
} *Buf;

inline static void
buf_init(Buf buf, int fd, long initial_size) {
    if (sizeof(buf->base) < (size_t)initial_size) {
	buf->head = ALLOC_N(char, initial_size);
	buf->end = buf->head + initial_size - 1;
    } else {
	buf->head = buf->base;
	buf->end = buf->base + sizeof(buf->base) - 1;
    }
    buf->tail = buf->head;
    buf->fd = fd;
    buf->err = false;
}

inline static void
buf_reset(Buf buf) {
    buf->head = buf->base;
    buf->tail = buf->head;
}

inline static void
buf_cleanup(Buf buf) {
    if (buf->base != buf->head) {
        free(buf->head);
    }
}

inline static size_t
buf_len(Buf buf) {
    return buf->tail - buf->head;
}

inline static void
buf_append_string(Buf buf, const char *s, size_t slen) {
    if (buf->err) {
	return;
    }
    if (buf->end <= buf->tail + slen) {
	if (0 != buf->fd) {
	    size_t	len = buf->tail - buf->head;

	    if (len != (size_t)write(buf->fd, buf->head, len)) {
		buf->err = true;
	    }
	    buf->tail = buf->head;
	} else {
	    size_t	len = buf->end - buf->head;
	    size_t	toff = buf->tail - buf->head;
	    size_t	new_len = len + slen + len / 2;

	    if (buf->base == buf->head) {
		buf->head = ALLOC_N(char, new_len);
		memcpy(buf->head, buf->base, len);
	    } else {
		REALLOC_N(buf->head, char, new_len);
	    }
	    buf->tail = buf->head + toff;
	    buf->end = buf->head + new_len - 2;
	}
    }
    if (0 < slen) {
	memcpy(buf->tail, s, slen);
    }
    buf->tail += slen;
}
    
inline static void
buf_append(Buf buf, char c) {
    if (buf->err) {
	return;
    }
    if (buf->end <= buf->tail) {
	if (0 != buf->fd) {
	    size_t	len = buf->tail - buf->head;

	    if (len != (size_t)write(buf->fd, buf->head, len)) {
		buf->err = true;
	    }
	    buf->tail = buf->head;
	} else {
	    size_t	len = buf->end - buf->head;
	    size_t	toff = buf->tail - buf->head;
	    size_t	new_len = len + len / 2;

	    if (buf->base == buf->head) {
		buf->head = ALLOC_N(char, new_len);
		memcpy(buf->head, buf->base, len);
	    } else {
		REALLOC_N(buf->head, char, new_len);
	    }
	    buf->tail = buf->head + toff;
	    buf->end = buf->head + new_len - 2;
	}
    }
    *buf->tail++ = c;
    //*buf->tail = '\0'; // for debugging
}

inline static void
buf_finish(Buf buf) {
    if (buf->err) {
	return;
    }
    if (0 != buf->fd) {
	size_t	len = buf->tail - buf->head;

	if (0 < len && len != (size_t)write(buf->fd, buf->head, len)) {
	    buf->err = true;
	}
	fsync(buf->fd);
	buf->tail = buf->head;
    }
}

#endif /* __OX_BUF_H__ */
