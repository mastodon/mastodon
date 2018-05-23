/*
 * Written by Solar Designer and placed in the public domain.
 * See crypt_blowfish.c for more information.
 *
 * This file contains salt generation functions for the traditional and
 * other common crypt(3) algorithms, except for bcrypt which is defined
 * entirely in crypt_blowfish.c.
 */

#include <string.h>

#include <errno.h>
#ifndef __set_errno
#define __set_errno(val) errno = (val)
#endif

#undef __CONST
#ifdef __GNUC__
#define __CONST __const
#else
#define __CONST
#endif

unsigned char _crypt_itoa64[64 + 1] =
	"./0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";

char *_crypt_gensalt_traditional_rn(unsigned long count,
	__CONST char *input, int size, char *output, int output_size)
{
	if (size < 2 || output_size < 2 + 1 || (count && count != 25)) {
		if (output_size > 0) output[0] = '\0';
		__set_errno((output_size < 2 + 1) ? ERANGE : EINVAL);
		return NULL;
	}

	output[0] = _crypt_itoa64[(unsigned int)input[0] & 0x3f];
	output[1] = _crypt_itoa64[(unsigned int)input[1] & 0x3f];
	output[2] = '\0';

	return output;
}

char *_crypt_gensalt_extended_rn(unsigned long count,
	__CONST char *input, int size, char *output, int output_size)
{
	unsigned long value;

/* Even iteration counts make it easier to detect weak DES keys from a look
 * at the hash, so they should be avoided */
	if (size < 3 || output_size < 1 + 4 + 4 + 1 ||
	    (count && (count > 0xffffff || !(count & 1)))) {
		if (output_size > 0) output[0] = '\0';
		__set_errno((output_size < 1 + 4 + 4 + 1) ? ERANGE : EINVAL);
		return NULL;
	}

	if (!count) count = 725;

	output[0] = '_';
	output[1] = _crypt_itoa64[count & 0x3f];
	output[2] = _crypt_itoa64[(count >> 6) & 0x3f];
	output[3] = _crypt_itoa64[(count >> 12) & 0x3f];
	output[4] = _crypt_itoa64[(count >> 18) & 0x3f];
	value = (unsigned long)(unsigned char)input[0] |
		((unsigned long)(unsigned char)input[1] << 8) |
		((unsigned long)(unsigned char)input[2] << 16);
	output[5] = _crypt_itoa64[value & 0x3f];
	output[6] = _crypt_itoa64[(value >> 6) & 0x3f];
	output[7] = _crypt_itoa64[(value >> 12) & 0x3f];
	output[8] = _crypt_itoa64[(value >> 18) & 0x3f];
	output[9] = '\0';

	return output;
}

char *_crypt_gensalt_md5_rn(unsigned long count,
	__CONST char *input, int size, char *output, int output_size)
{
	unsigned long value;

	if (size < 3 || output_size < 3 + 4 + 1 || (count && count != 1000)) {
		if (output_size > 0) output[0] = '\0';
		__set_errno((output_size < 3 + 4 + 1) ? ERANGE : EINVAL);
		return NULL;
	}

	output[0] = '$';
	output[1] = '1';
	output[2] = '$';
	value = (unsigned long)(unsigned char)input[0] |
		((unsigned long)(unsigned char)input[1] << 8) |
		((unsigned long)(unsigned char)input[2] << 16);
	output[3] = _crypt_itoa64[value & 0x3f];
	output[4] = _crypt_itoa64[(value >> 6) & 0x3f];
	output[5] = _crypt_itoa64[(value >> 12) & 0x3f];
	output[6] = _crypt_itoa64[(value >> 18) & 0x3f];
	output[7] = '\0';

	if (size >= 6 && output_size >= 3 + 4 + 4 + 1) {
		value = (unsigned long)(unsigned char)input[3] |
			((unsigned long)(unsigned char)input[4] << 8) |
			((unsigned long)(unsigned char)input[5] << 16);
		output[7] = _crypt_itoa64[value & 0x3f];
		output[8] = _crypt_itoa64[(value >> 6) & 0x3f];
		output[9] = _crypt_itoa64[(value >> 12) & 0x3f];
		output[10] = _crypt_itoa64[(value >> 18) & 0x3f];
		output[11] = '\0';
	}

	return output;
}
