#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "hescape.h"

static const char *ESCAPED_STRING[] = {
  "",
  "&quot;",
  "&amp;",
  "&#39;",
  "&lt;",
  "&gt;",
};

// This is strlen(ESCAPED_STRING[x]) optimized specially.
// Mapping: 1 => 6, 2 => 5, 3 => 5, 4 => 4, 5 => 4
#define ESC_LEN(x) ((13 - x) / 2)

/*
 * Given ASCII-compatible character, return index of ESCAPED_STRING.
 *
 * " (34) => 1 (&quot;)
 * & (38) => 2 (&amp;)
 * ' (39) => 3 (&#39;)
 * < (60) => 4 (&lt;)
 * > (62) => 5 (&gt;)
 */
static const char HTML_ESCAPE_TABLE[] = {
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 1, 0, 0, 0, 2, 3, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4, 0, 5, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
};

static char*
ensure_allocated(char *buf, size_t size, size_t *asize)
{
  size_t new_size;

  if (size < *asize)
    return buf;

  if (*asize == 0) {
    new_size = size;
  } else {
    new_size = *asize;
  }

  // Increase buffer size by 1.5x if realloced multiple times.
  while (new_size < size)
    new_size = (new_size << 1) - (new_size >> 1);

  // Round allocation up to multiple of 8.
  new_size = (new_size + 7) & ~7;

  *asize = new_size;
  return realloc(buf, new_size);
}

size_t
hesc_escape_html(char **dest, const char *buf, size_t size)
{
  size_t asize = 0, esc_i = 0, esize = 0, i = 0, rbuf_end = 0;
  const char *esc;
  char *rbuf = NULL;

  while (i < size) {
    // Loop here to skip non-escaped characters fast.
    while (i < size && (esc_i = HTML_ESCAPE_TABLE[(unsigned char)buf[i]]) == 0)
      i++;

    if (i < size && esc_i) {
      esc = ESCAPED_STRING[esc_i];
      rbuf = ensure_allocated(rbuf, sizeof(char) * (size + esize + ESC_LEN(esc_i) + 1), &asize);

      // Copy pending characters and escaped string.
      memmove(rbuf + rbuf_end, buf + (rbuf_end - esize), i - (rbuf_end - esize));
      memmove(rbuf + i + esize, esc, ESC_LEN(esc_i));
      rbuf_end = i + esize + ESC_LEN(esc_i);
      esize += ESC_LEN(esc_i) - 1;
    }
    i++;
  }

  if (rbuf_end == 0) {
    // Return given buf and size if there are no escaped characters.
    *dest = (char *)buf;
    return size;
  } else {
    // Copy pending characters including NULL character.
    memmove(rbuf + rbuf_end, buf + (rbuf_end - esize), (size + 1) - (rbuf_end - esize));

    *dest = rbuf;
    return size + esize;
  }
}
