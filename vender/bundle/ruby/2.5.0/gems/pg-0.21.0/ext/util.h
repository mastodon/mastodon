/*
 * utils.h
 *
 */

#ifndef __utils_h
#define __utils_h

#define write_nbo16(l,c) ( \
		*((unsigned char*)(c)+0)=(unsigned char)(((l)>>8)&0xff), \
		*((unsigned char*)(c)+1)=(unsigned char)(((l)   )&0xff)\
	)

#define write_nbo32(l,c) ( \
		*((unsigned char*)(c)+0)=(unsigned char)(((l)>>24L)&0xff), \
		*((unsigned char*)(c)+1)=(unsigned char)(((l)>>16L)&0xff), \
		*((unsigned char*)(c)+2)=(unsigned char)(((l)>> 8L)&0xff), \
		*((unsigned char*)(c)+3)=(unsigned char)(((l)     )&0xff)\
	)

#define write_nbo64(l,c) ( \
		*((unsigned char*)(c)+0)=(unsigned char)(((l)>>56LL)&0xff), \
		*((unsigned char*)(c)+1)=(unsigned char)(((l)>>48LL)&0xff), \
		*((unsigned char*)(c)+2)=(unsigned char)(((l)>>40LL)&0xff), \
		*((unsigned char*)(c)+3)=(unsigned char)(((l)>>32LL)&0xff), \
		*((unsigned char*)(c)+4)=(unsigned char)(((l)>>24LL)&0xff), \
		*((unsigned char*)(c)+5)=(unsigned char)(((l)>>16LL)&0xff), \
		*((unsigned char*)(c)+6)=(unsigned char)(((l)>> 8LL)&0xff), \
		*((unsigned char*)(c)+7)=(unsigned char)(((l)      )&0xff)\
	)

#define read_nbo16(c) ((int16_t)( \
		(((uint16_t)(*((unsigned char*)(c)+0)))<< 8L) | \
		(((uint16_t)(*((unsigned char*)(c)+1)))     ) \
	))

#define read_nbo32(c) ((int32_t)( \
		(((uint32_t)(*((unsigned char*)(c)+0)))<<24L) | \
		(((uint32_t)(*((unsigned char*)(c)+1)))<<16L) | \
		(((uint32_t)(*((unsigned char*)(c)+2)))<< 8L) | \
		(((uint32_t)(*((unsigned char*)(c)+3)))     ) \
	))

#define read_nbo64(c) ((int64_t)( \
		(((uint64_t)(*((unsigned char*)(c)+0)))<<56LL) | \
		(((uint64_t)(*((unsigned char*)(c)+1)))<<48LL) | \
		(((uint64_t)(*((unsigned char*)(c)+2)))<<40LL) | \
		(((uint64_t)(*((unsigned char*)(c)+3)))<<32LL) | \
		(((uint64_t)(*((unsigned char*)(c)+4)))<<24LL) | \
		(((uint64_t)(*((unsigned char*)(c)+5)))<<16LL) | \
		(((uint64_t)(*((unsigned char*)(c)+6)))<< 8LL) | \
		(((uint64_t)(*((unsigned char*)(c)+7)))      ) \
	))



#define BASE64_ENCODED_SIZE(strlen) (((strlen) + 2) / 3 * 4)
#define BASE64_DECODED_SIZE(base64len) (((base64len) + 3) / 4 * 3)

void base64_encode( char *out, char *in, int len);
int base64_decode( char *out, char *in, unsigned int len);

int rbpg_strncasecmp(const char *s1, const char *s2, size_t n);

#endif /* end __utils_h */
