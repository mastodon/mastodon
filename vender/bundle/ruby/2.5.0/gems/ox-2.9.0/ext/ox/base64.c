/* base64.c
 * Copyright (c) 2011, Peter Ohler
 * All rights reserved.
 */

#include <stdlib.h>
#include <stdio.h>

#include "base64.h"

static char	digits[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

/* invalid or terminating characters are set to 'X' or \x58 */
static uchar	s_digits[256] = "\
\x58\x58\x58\x58\x58\x58\x58\x58\x58\x58\x58\x58\x58\x58\x58\x58\
\x58\x58\x58\x58\x58\x58\x58\x58\x58\x58\x58\x58\x58\x58\x58\x58\
\x58\x58\x58\x58\x58\x58\x58\x58\x58\x58\x58\x3E\x58\x58\x58\x3F\
\x34\x35\x36\x37\x38\x39\x3A\x3B\x3C\x3D\x58\x58\x58\x58\x58\x58\
\x58\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0A\x0B\x0C\x0D\x0E\
\x0F\x10\x11\x12\x13\x14\x15\x16\x17\x18\x19\x58\x58\x58\x58\x58\
\x58\x1A\x1B\x1C\x1D\x1E\x1F\x20\x21\x22\x23\x24\x25\x26\x27\x28\
\x29\x2A\x2B\x2C\x2D\x2E\x2F\x30\x31\x32\x33\x58\x58\x58\x58\x58\
\x58\x58\x58\x58\x58\x58\x58\x58\x58\x58\x58\x58\x58\x58\x58\x58\
\x58\x58\x58\x58\x58\x58\x58\x58\x58\x58\x58\x58\x58\x58\x58\x58\
\x58\x58\x58\x58\x58\x58\x58\x58\x58\x58\x58\x58\x58\x58\x58\x58\
\x58\x58\x58\x58\x58\x58\x58\x58\x58\x58\x58\x58\x58\x58\x58\x58\
\x58\x58\x58\x58\x58\x58\x58\x58\x58\x58\x58\x58\x58\x58\x58\x58\
\x58\x58\x58\x58\x58\x58\x58\x58\x58\x58\x58\x58\x58\x58\x58\x58\
\x58\x58\x58\x58\x58\x58\x58\x58\x58\x58\x58\x58\x58\x58\x58\x58\
\x58\x58\x58\x58\x58\x58\x58\x58\x58\x58\x58\x58\x58\x58\x58\x58";

void
to_base64(const uchar *src, int len, char *b64) {
    const uchar	*end3;
    int		len3 = len % 3;
    uchar	b1, b2, b3;
    
    end3 = src + (len - len3);
    while (src < end3) {
	b1 = *src++;
	b2 = *src++;
	b3 = *src++;
	*b64++ = digits[(uchar)(b1 >> 2)];
	*b64++ = digits[(uchar)(((b1 & 0x03) << 4) | (b2 >> 4))];
	*b64++ = digits[(uchar)(((b2 & 0x0F) << 2) | (b3 >> 6))];
	*b64++ = digits[(uchar)(b3 & 0x3F)];
    }
    if (1 == len3) {
	b1 = *src++;
	*b64++ = digits[b1 >> 2];
	*b64++ = digits[(b1 & 0x03) << 4];
	*b64++ = '=';
	*b64++ = '=';
    } else if (2 == len3) {
	b1 = *src++;
	b2 = *src++;
	*b64++ = digits[b1 >> 2];
	*b64++ = digits[((b1 & 0x03) << 4) | (b2 >> 4)];
	*b64++ = digits[(b2 & 0x0F) << 2];
	*b64++ = '=';
    }
    *b64 = '\0';
}

unsigned long
b64_orig_size(const char *text) {
    const char          *start = text;
    unsigned long        size = 0;

    if ('\0' != *text) {
        for (; 0 != *text; text++) { }
        size = (text - start) * 3 / 4;
        text--;
        if ('=' == *text) {
            size--;
            text--;
            if ('=' == *text) {
                size--;
            }
        }
    }
    return size;
}

void
from_base64(const char *b64, uchar *str) {
    uchar	b0, b1, b2, b3;
    
    while (1) {
        if ('X' == (b0 = s_digits[(uchar)*b64++])) { break; }
        if ('X' == (b1 = s_digits[(uchar)*b64++])) { break; }
        *str++ = (b0 << 2) | ((b1 >> 4) & 0x03);
        if ('X' == (b2 = s_digits[(uchar)*b64++])) { break; }
        *str++ = (b1 << 4) | ((b2 >> 2) & 0x0F);
        if ('X' == (b3 = s_digits[(uchar)*b64++])) { break; }
        *str++ = (b2 << 6) | b3;
    }
    *str = '\0';
}
