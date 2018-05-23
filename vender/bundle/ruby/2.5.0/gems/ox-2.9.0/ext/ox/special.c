/* special.c
 * Copyright (c) 2011, Peter Ohler
 * All rights reserved.
 */

#include "special.h"

/*
u0000..u007F                00000000000000xxxxxxx  0xxxxxxx
u0080..u07FF                0000000000yyyyyxxxxxx  110yyyyy 10xxxxxx
u0800..uD7FF, uE000..uFFFF  00000zzzzyyyyyyxxxxxx  1110zzzz 10yyyyyy 10xxxxxx
u10000..u10FFFF             uuuzzzzzzyyyyyyxxxxxx  11110uuu 10zzzzzz 10yyyyyy 10xxxxxx
*/
char*
ox_ucs_to_utf8_chars(char *text, uint64_t u) {
    int			reading = 0;
    int			i;
    unsigned char	c;

    if (u <= 0x000000000000007FULL) {
	/* 0xxxxxxx */
	*text++ = (char)u;
    } else if (u <= 0x00000000000007FFULL) {
	/* 110yyyyy 10xxxxxx */
	*text++ = (char)(0x00000000000000C0ULL | (0x000000000000001FULL & (u >> 6)));
	*text++ = (char)(0x0000000000000080ULL | (0x000000000000003FULL & u));
    } else if (u <= 0x000000000000D7FFULL || (0x000000000000E000ULL <= u && u <= 0x000000000000FFFFULL)) {
	/* 1110zzzz 10yyyyyy 10xxxxxx */
	*text++ = (char)(0x00000000000000E0ULL | (0x000000000000000FULL & (u >> 12)));
	*text++ = (char)(0x0000000000000080ULL | (0x000000000000003FULL & (u >> 6)));
	*text++ = (char)(0x0000000000000080ULL | (0x000000000000003FULL & u));
    } else if (0x0000000000010000ULL <= u && u <= 0x000000000010FFFFULL) {
	/* 11110uuu 10zzzzzz 10yyyyyy 10xxxxxx */
	*text++ = (char)(0x00000000000000F0ULL | (0x0000000000000007ULL & (u >> 18)));
	*text++ = (char)(0x0000000000000080ULL | (0x000000000000003FULL & (u >> 12)));
	*text++ = (char)(0x0000000000000080ULL | (0x000000000000003FULL & (u >> 6)));
	*text++ = (char)(0x0000000000000080ULL | (0x000000000000003FULL & u));
    } else {
	/* assume it is UTF-8 encoded directly and not UCS */
	for (i = 56; 0 <= i; i -= 8) {
	    c = (unsigned char)((u >> i) & 0x00000000000000FFULL);
	    if (reading) {
		*text++ = (char)c;
	    } else if ('\0' != c) {
		*text++ = (char)c;
		reading = 1;
	    }
	}
    }
    return text;
}
