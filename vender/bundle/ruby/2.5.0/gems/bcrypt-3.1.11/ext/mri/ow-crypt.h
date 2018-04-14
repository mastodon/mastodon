/*
 * Written by Solar Designer and placed in the public domain.
 * See crypt_blowfish.c for more information.
 */

#ifndef _OW_CRYPT_H
#define _OW_CRYPT_H

#undef __CONST
#if defined __GNUC__
#define __CONST __const
#elif defined _MSC_VER
#define __CONST const
#else
#endif

#ifndef __SKIP_GNU
extern char *crypt(__CONST char *key, __CONST char *setting);
extern char *crypt_r(__CONST char *key, __CONST char *setting, void *data);
#endif

#ifndef __SKIP_OW
extern char *crypt_rn(__CONST char *key, __CONST char *setting,
	void *data, int size);
extern char *crypt_ra(__CONST char *key, __CONST char *setting,
	void **data, int *size);
extern char *crypt_gensalt(__CONST char *prefix, unsigned long count,
	__CONST char *input, int size);
extern char *crypt_gensalt_rn(__CONST char *prefix, unsigned long count,
	__CONST char *input, int size, char *output, int output_size);
extern char *crypt_gensalt_ra(__CONST char *prefix, unsigned long count,
	__CONST char *input, int size);
#endif

#endif
