/* base64.h
 * Copyright (c) 2011, Peter Ohler
 * All rights reserved.
 */

#ifndef __BASE64_H__
#define __BASE64_H__

typedef unsigned char	uchar;

#define b64_size(len) ((len + 2) / 3 * 4)

extern unsigned long    b64_orig_size(const char *text);

extern void	        to_base64(const uchar *src, int len, char *b64);
extern void             from_base64(const char *b64, uchar *str);

#endif /* __BASE64_H__ */
