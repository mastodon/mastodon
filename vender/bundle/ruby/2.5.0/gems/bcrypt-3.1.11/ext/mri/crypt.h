/*
 * Written by Solar Designer and placed in the public domain.
 * See crypt_blowfish.c for more information.
 */

#include <gnu-crypt.h>

#if defined(_OW_SOURCE) || defined(__USE_OW)
#define __SKIP_GNU
#undef __SKIP_OW
#include <ow-crypt.h>
#undef __SKIP_GNU
#endif
