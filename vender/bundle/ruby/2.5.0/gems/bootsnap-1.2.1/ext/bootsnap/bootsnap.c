/*
 * Suggested reading order:
 * 1. Skim Init_bootsnap
 * 2. Skim bs_fetch
 * 3. The rest of everything
 *
 * Init_bootsnap sets up the ruby objects and binds bs_fetch to
 * Bootsnap::CompileCache::Native.fetch.
 *
 * bs_fetch is the ultimate caller for for just about every other function in
 * here.
 */

#include "bootsnap.h"
#include "ruby.h"
#include <stdint.h>
#include <sys/types.h>
#include <errno.h>
#include <fcntl.h>
#include <sys/stat.h>
#ifndef _WIN32
#include <sys/utsname.h>
#endif

/* 1000 is an arbitrary limit; FNV64 plus some slashes brings the cap down to
 * 981 for the cache dir */
#define MAX_CACHEPATH_SIZE 1000
#define MAX_CACHEDIR_SIZE  981

#define KEY_SIZE 64

/*
 * An instance of this key is written as the first 64 bytes of each cache file.
 * The mtime and size members track whether the file contents have changed, and
 * the version, ruby_platform, compile_option, and ruby_revision members track
 * changes to the environment that could invalidate compile results without
 * file contents having changed. The data_size member is not truly part of the
 * "key". Really, this could be called a "header" with the first six members
 * being an embedded "key" struct and an additional data_size member.
 *
 * The data_size indicates the remaining number of bytes in the cache file
 * after the header (the size of the cached artifact).
 *
 * After data_size, the struct is padded to 64 bytes.
 */
struct bs_cache_key {
  uint32_t version;
  uint32_t ruby_platform;
  uint32_t compile_option;
  uint32_t ruby_revision;
  uint64_t size;
  uint64_t mtime;
  uint64_t data_size; /* not used for equality */
  uint8_t  pad[24];
} __attribute__((packed));

/*
 * If the struct padding isn't correct to pad the key to 64 bytes, refuse to
 * compile.
 */
#define STATIC_ASSERT(X)            STATIC_ASSERT2(X,__LINE__)
#define STATIC_ASSERT2(X,L)         STATIC_ASSERT3(X,L)
#define STATIC_ASSERT3(X,L)         STATIC_ASSERT_MSG(X,at_line_##L)
#define STATIC_ASSERT_MSG(COND,MSG) typedef char static_assertion_##MSG[(!!(COND))*2-1]
STATIC_ASSERT(sizeof(struct bs_cache_key) == KEY_SIZE);

/* Effectively a schema version. Bumping invalidates all previous caches */
static const uint32_t current_version = 2;

/* hash of e.g. "x86_64-darwin17", invalidating when ruby is recompiled on a
 * new OS ABI, etc. */
static uint32_t current_ruby_platform;
/* Invalidates cache when switching ruby versions */
static uint32_t current_ruby_revision;
/* Invalidates cache when RubyVM::InstructionSequence.compile_option changes */
static uint32_t current_compile_option_crc32 = 0;

/* Bootsnap::CompileCache::{Native, Uncompilable} */
static VALUE rb_mBootsnap;
static VALUE rb_mBootsnap_CompileCache;
static VALUE rb_mBootsnap_CompileCache_Native;
static VALUE rb_eBootsnap_CompileCache_Uncompilable;
static ID uncompilable;

/* Functions exposed as module functions on Bootsnap::CompileCache::Native */
static VALUE bs_compile_option_crc32_set(VALUE self, VALUE crc32_v);
static VALUE bs_rb_fetch(VALUE self, VALUE cachedir_v, VALUE path_v, VALUE handler);

/* Helpers */
static uint64_t fnv1a_64(const char *str);
static void bs_cache_path(const char * cachedir, const char * path, char ** cache_path);
static int bs_read_key(int fd, struct bs_cache_key * key);
static int cache_key_equal(struct bs_cache_key * k1, struct bs_cache_key * k2);
static VALUE bs_fetch(char * path, VALUE path_v, char * cache_path, VALUE handler);
static int open_current_file(char * path, struct bs_cache_key * key, char ** errno_provenance);
static int fetch_cached_data(int fd, ssize_t data_size, VALUE handler, VALUE * output_data, int * exception_tag, char ** errno_provenance);
static uint32_t get_ruby_platform(void);

/*
 * Helper functions to call ruby methods on handler object without crashing on
 * exception.
 */
static int bs_storage_to_output(VALUE handler, VALUE storage_data, VALUE * output_data);
static VALUE prot_storage_to_output(VALUE arg);
static VALUE prot_input_to_output(VALUE arg);
static void bs_input_to_output(VALUE handler, VALUE input_data, VALUE * output_data, int * exception_tag);
static VALUE prot_input_to_storage(VALUE arg);
static int bs_input_to_storage(VALUE handler, VALUE input_data, VALUE pathval, VALUE * storage_data);
struct s2o_data;
struct i2o_data;
struct i2s_data;

/* https://bugs.ruby-lang.org/issues/13667 */
extern VALUE rb_get_coverages(void);
static VALUE
bs_rb_coverage_running(VALUE self)
{
  VALUE cov = rb_get_coverages();
  return RTEST(cov) ? Qtrue : Qfalse;
}

/*
 * Ruby C extensions are initialized by calling Init_<extname>.
 *
 * This sets up the module hierarchy and attaches functions as methods.
 *
 * We also populate some semi-static information about the current OS and so on.
 */
void
Init_bootsnap(void)
{
  rb_mBootsnap = rb_define_module("Bootsnap");
  rb_mBootsnap_CompileCache = rb_define_module_under(rb_mBootsnap, "CompileCache");
  rb_mBootsnap_CompileCache_Native = rb_define_module_under(rb_mBootsnap_CompileCache, "Native");
  rb_eBootsnap_CompileCache_Uncompilable = rb_define_class_under(rb_mBootsnap_CompileCache, "Uncompilable", rb_eStandardError);

  current_ruby_revision = FIX2INT(rb_const_get(rb_cObject, rb_intern("RUBY_REVISION")));
  current_ruby_platform = get_ruby_platform();

  uncompilable = rb_intern("__bootsnap_uncompilable__");

  rb_define_module_function(rb_mBootsnap_CompileCache_Native, "coverage_running?", bs_rb_coverage_running, 0);
  rb_define_module_function(rb_mBootsnap_CompileCache_Native, "fetch", bs_rb_fetch, 3);
  rb_define_module_function(rb_mBootsnap_CompileCache_Native, "compile_option_crc32=", bs_compile_option_crc32_set, 1);
}

/*
 * Bootsnap's ruby code registers a hook that notifies us via this function
 * when compile_option changes. These changes invalidate all existing caches.
 *
 * Note that on 32-bit platforms, a CRC32 can't be represented in a Fixnum, but
 * can be represented by a uint.
 */
static VALUE
bs_compile_option_crc32_set(VALUE self, VALUE crc32_v)
{
  if (!RB_TYPE_P(crc32_v, T_BIGNUM) && !RB_TYPE_P(crc32_v, T_FIXNUM)) {
    Check_Type(crc32_v, T_FIXNUM);
  }
  current_compile_option_crc32 = NUM2UINT(crc32_v);
  return Qnil;
}

/*
 * We use FNV1a-64 to derive cache paths. The choice is somewhat arbitrary but
 * it has several nice properties:
 *
 *   - Tiny implementation
 *   - No external dependency
 *   - Solid performance
 *   - Solid randomness
 *   - 32 bits doesn't feel collision-resistant enough; 64 is nice.
 */
static uint64_t
fnv1a_64_iter(uint64_t h, const char *str)
{
  unsigned char *s = (unsigned char *)str;

  while (*s) {
    h ^= (uint64_t)*s++;
    h += (h << 1) + (h << 4) + (h << 5) + (h << 7) + (h << 8) + (h << 40);
  }

  return h;
}

static uint64_t
fnv1a_64(const char *str)
{
  uint64_t h = (uint64_t)0xcbf29ce484222325ULL;
  return fnv1a_64_iter(h, str);
}

/*
 * When ruby's version doesn't change, but it's recompiled on a different OS
 * (or OS version), we need to invalidate the cache.
 *
 * We actually factor in some extra information here, to be extra confident
 * that we don't try to re-use caches that will not be compatible, by factoring
 * in utsname.version.
 */
static uint32_t
get_ruby_platform(void)
{
  uint64_t hash;
  VALUE ruby_platform;

  ruby_platform = rb_const_get(rb_cObject, rb_intern("RUBY_PLATFORM"));
  hash = fnv1a_64(RSTRING_PTR(ruby_platform));

#ifdef _WIN32
  return (uint32_t)(hash >> 32) ^ (uint32_t)GetVersion();
#else
  struct utsname utsname;

  /* Not worth crashing if this fails; lose extra cache invalidation potential */
  if (uname(&utsname) >= 0) {
    hash = fnv1a_64_iter(hash, utsname.version);
  }

  return (uint32_t)(hash >> 32);
#endif
}

/*
 * Given a cache root directory and the full path to a file being cached,
 * generate a path under the cache directory at which the cached artifact will
 * be stored.
 *
 * The path will look something like: <cachedir>/12/34567890abcdef
 */
static void
bs_cache_path(const char * cachedir, const char * path, char ** cache_path)
{
  uint64_t hash = fnv1a_64(path);

  uint8_t first_byte = (hash >> (64 - 8));
  uint64_t remainder = hash & 0x00ffffffffffffff;

  sprintf(*cache_path, "%s/%02x/%014llx", cachedir, first_byte, remainder);
}

/*
 * Test whether a newly-generated cache key based on the file as it exists on
 * disk matches the one that was generated when the file was cached (or really
 * compare any two keys).
 *
 * The data_size member is not compared, as it serves more of a "header"
 * function.
 */
static int
cache_key_equal(struct bs_cache_key * k1, struct bs_cache_key * k2)
{
  return (
    k1->version        == k2->version        &&
    k1->ruby_platform  == k2->ruby_platform  &&
    k1->compile_option == k2->compile_option &&
    k1->ruby_revision  == k2->ruby_revision  &&
    k1->size           == k2->size           &&
    k1->mtime          == k2->mtime
  );
}

/*
 * Entrypoint for Bootsnap::CompileCache::Native.fetch. The real work is done
 * in bs_fetch; this function just performs some basic typechecks and
 * conversions on the ruby VALUE arguments before passing them along.
 */
static VALUE
bs_rb_fetch(VALUE self, VALUE cachedir_v, VALUE path_v, VALUE handler)
{
  Check_Type(cachedir_v, T_STRING);
  Check_Type(path_v, T_STRING);

  if (RSTRING_LEN(cachedir_v) > MAX_CACHEDIR_SIZE) {
    rb_raise(rb_eArgError, "cachedir too long");
  }

  char * cachedir = RSTRING_PTR(cachedir_v);
  char * path     = RSTRING_PTR(path_v);
  char cache_path[MAX_CACHEPATH_SIZE];

  { /* generate cache path to cache_path */
    char * tmp = (char *)&cache_path;
    bs_cache_path(cachedir, path, &tmp);
  }

  return bs_fetch(path, path_v, cache_path, handler);
}

/*
 * Open the file we want to load/cache and generate a cache key for it if it
 * was loaded.
 */
static int
open_current_file(char * path, struct bs_cache_key * key, char ** errno_provenance)
{
  struct stat statbuf;
  int fd;

  fd = open(path, O_RDONLY);
  if (fd < 0) {
    *errno_provenance = (char *)"bs_fetch:open_current_file:open";
    return fd;
  }
  #ifdef _WIN32
  setmode(fd, O_BINARY);
  #endif

  if (fstat(fd, &statbuf) < 0) {
    *errno_provenance = (char *)"bs_fetch:open_current_file:fstat";
    close(fd);
    return -1;
  }

  key->version        = current_version;
  key->ruby_platform  = current_ruby_platform;
  key->compile_option = current_compile_option_crc32;
  key->ruby_revision  = current_ruby_revision;
  key->size           = (uint64_t)statbuf.st_size;
  key->mtime          = (uint64_t)statbuf.st_mtime;

  return fd;
}

#define ERROR_WITH_ERRNO -1
#define CACHE_MISSING_OR_INVALID -2

/*
 * Read the cache key from the given fd, which must have position 0 (e.g.
 * freshly opened file).
 *
 * Possible return values:
 *   - 0 (OK, key was loaded)
 *   - CACHE_MISSING_OR_INVALID (-2)
 *   - ERROR_WITH_ERRNO (-1, errno is set)
 */
static int
bs_read_key(int fd, struct bs_cache_key * key)
{
  ssize_t nread = read(fd, key, KEY_SIZE);
  if (nread < 0)        return ERROR_WITH_ERRNO;
  if (nread < KEY_SIZE) return CACHE_MISSING_OR_INVALID;
  return 0;
}

/*
 * Open the cache file at a given path, if it exists, and read its key into the
 * struct.
 *
 * Possible return values:
 *   - 0 (OK, key was loaded)
 *   - CACHE_MISSING_OR_INVALID (-2)
 *   - ERROR_WITH_ERRNO (-1, errno is set)
 */
static int
open_cache_file(const char * path, struct bs_cache_key * key, char ** errno_provenance)
{
  int fd, res;

  fd = open(path, O_RDONLY);
  if (fd < 0) {
    *errno_provenance = (char *)"bs_fetch:open_cache_file:open";
    if (errno == ENOENT) return CACHE_MISSING_OR_INVALID;
    return ERROR_WITH_ERRNO;
  }
  #ifdef _WIN32
  setmode(fd, O_BINARY);
  #endif

  res = bs_read_key(fd, key);
  if (res < 0) {
    *errno_provenance = (char *)"bs_fetch:open_cache_file:read";
    close(fd);
    return res;
  }

  return fd;
}

/*
 * The cache file is laid out like:
 *   0...64 : bs_cache_key
 *   64..-1 : cached artifact
 *
 * This function takes a file descriptor whose position is pre-set to 64, and
 * the data_size (corresponding to the remaining number of bytes) listed in the
 * cache header.
 *
 * We load the text from this file into a buffer, and pass it to the ruby-land
 * handler with exception handling via the exception_tag param.
 *
 * Data is returned via the output_data parameter, which, if there's no error
 * or exception, will be the final data returnable to the user.
 */
static int
fetch_cached_data(int fd, ssize_t data_size, VALUE handler, VALUE * output_data, int * exception_tag, char ** errno_provenance)
{
  char * data = NULL;
  ssize_t nread;
  int ret;

  VALUE storage_data;

  if (data_size > 100000000000) {
    *errno_provenance = (char *)"bs_fetch:fetch_cached_data:datasize";
    errno = EINVAL; /* because wtf? */
    ret = -1;
    goto done;
  }
  data = ALLOC_N(char, data_size);
  nread = read(fd, data, data_size);
  if (nread < 0) {
    *errno_provenance = (char *)"bs_fetch:fetch_cached_data:read";
    ret = -1;
    goto done;
  }
  if (nread != data_size) {
    ret = CACHE_MISSING_OR_INVALID;
    goto done;
  }

  storage_data = rb_str_new_static(data, data_size);

  *exception_tag = bs_storage_to_output(handler, storage_data, output_data);
  ret = 0;
done:
  if (data != NULL) xfree(data);
  return ret;
}

/*
 * Like mkdir -p, this recursively creates directory parents of a file. e.g.
 * given /a/b/c, creates /a and /a/b.
 */
static int
mkpath(char * file_path, mode_t mode)
{
  /* It would likely be more efficient to count back until we
   * find a component that *does* exist, but this will only run
   * at most 256 times, so it seems not worthwhile to change. */
  char * p;
  for (p = strchr(file_path + 1, '/'); p; p = strchr(p + 1, '/')) {
    *p = '\0';
    #ifdef _WIN32
    if (mkdir(file_path) == -1) {
    #else
    if (mkdir(file_path, mode) == -1) {
    #endif
      if (errno != EEXIST) {
        *p = '/';
        return -1;
      }
    }
    *p = '/';
  }
  return 0;
}

/*
 * Write a cache header/key and a compiled artifact to a given cache path by
 * writing to a tmpfile and then renaming the tmpfile over top of the final
 * path.
 */
static int
atomic_write_cache_file(char * path, struct bs_cache_key * key, VALUE data, char ** errno_provenance)
{
  char template[MAX_CACHEPATH_SIZE + 20];
  char * dest;
  char * tmp_path;
  int fd, ret;
  ssize_t nwrite;

  dest = strncpy(template, path, MAX_CACHEPATH_SIZE);
  strcat(dest, ".tmp.XXXXXX");

  tmp_path = mktemp(template);
  fd = open(tmp_path, O_WRONLY | O_CREAT, 0664);
  if (fd < 0) {
    if (mkpath(path, 0775) < 0) {
      *errno_provenance = (char *)"bs_fetch:atomic_write_cache_file:mkpath";
      return -1;
    }
    fd = open(tmp_path, O_WRONLY | O_CREAT, 0664);
    if (fd < 0) {
      *errno_provenance = (char *)"bs_fetch:atomic_write_cache_file:open";
      return -1;
    }
  }
  #ifdef _WIN32
  setmode(fd, O_BINARY);
  #endif

  key->data_size = RSTRING_LEN(data);
  nwrite = write(fd, key, KEY_SIZE);
  if (nwrite < 0) {
    *errno_provenance = (char *)"bs_fetch:atomic_write_cache_file:write";
    return -1;
  }
  if (nwrite != KEY_SIZE) {
    *errno_provenance = (char *)"bs_fetch:atomic_write_cache_file:keysize";
    errno = EIO; /* Lies but whatever */
    return -1;
  }

  nwrite = write(fd, RSTRING_PTR(data), RSTRING_LEN(data));
  if (nwrite < 0) return -1;
  if (nwrite != RSTRING_LEN(data)) {
    *errno_provenance = (char *)"bs_fetch:atomic_write_cache_file:writelength";
    errno = EIO; /* Lies but whatever */
    return -1;
  }

  close(fd);
  ret = rename(tmp_path, path);
  if (ret < 0) {
    *errno_provenance = (char *)"bs_fetch:atomic_write_cache_file:rename";
  }
  return ret;
}


/* Read contents from an fd, whose contents are asserted to be +size+ bytes
 * long, into a buffer */
static ssize_t
bs_read_contents(int fd, size_t size, char ** contents, char ** errno_provenance)
{
  ssize_t nread;
  *contents = ALLOC_N(char, size);
  nread = read(fd, *contents, size);
  if (nread < 0) {
    *errno_provenance = (char *)"bs_fetch:bs_read_contents:read";
  }
  return nread;
}

/*
 * This is the meat of the extension. bs_fetch is
 * Bootsnap::CompileCache::Native.fetch.
 *
 * There are three "formats" in use here:
 *   1. "input" format, which is what we load from the source file;
 *   2. "storage" format, which we write to the cache;
 *   3. "output" format, which is what we return.
 *
 * E.g., For ISeq compilation:
 *   input:   ruby source, as text
 *   storage: binary string (RubyVM::InstructionSequence#to_binary)
 *   output:  Instance of RubyVM::InstructionSequence
 *
 * And for YAML:
 *   input:   yaml as text
 *   storage: MessagePack or Marshal text
 *   output:  ruby object, loaded from yaml/messagepack/marshal
 *
 * A handler<I,S,O> passed in must support three messages:
 *   * storage_to_output(S) -> O
 *   * input_to_output(I)   -> O
 *   * input_to_storage(I)  -> S
 *     (input_to_storage may raise Bootsnap::CompileCache::Uncompilable, which
 *     will prevent caching and cause output to be generated with
 *     input_to_output)
 *
 * The semantics of this function are basically:
 *
 *   return storage_to_output(cache[path]) if cache[path]
 *   storage = input_to_storage(input)
 *   cache[path] = storage
 *   return storage_to_output(storage)
 *
 * Or expanded a bit:
 *
 *   - Check if the cache file exists and is up to date.
 *   - If it is, load this data to storage_data.
 *   - return storage_to_output(storage_data)
 *   - Read the file to input_data
 *   - Generate storage_data using input_to_storage(input_data)
 *   - Write storage_data data, with a cache key, to the cache file.
 *   - Return storage_to_output(storage_data)
 */
static VALUE
bs_fetch(char * path, VALUE path_v, char * cache_path, VALUE handler)
{
  struct bs_cache_key cached_key, current_key;
  char * contents = NULL;
  int cache_fd = -1, current_fd = -1;
  int res, valid_cache = 0, exception_tag = 0;
  char * errno_provenance = NULL;

  VALUE input_data;   /* data read from source file, e.g. YAML or ruby source */
  VALUE storage_data; /* compiled data, e.g. msgpack / binary iseq */
  VALUE output_data;  /* return data, e.g. ruby hash or loaded iseq */

  VALUE exception; /* ruby exception object to raise instead of returning */

  /* Open the source file and generate a cache key for it */
  current_fd = open_current_file(path, &current_key, &errno_provenance);
  if (current_fd < 0) goto fail_errno;

  /* Open the cache key if it exists, and read its cache key in */
  cache_fd = open_cache_file(cache_path, &cached_key, &errno_provenance);
  if (cache_fd == CACHE_MISSING_OR_INVALID) {
    /* This is ok: valid_cache remains false, we re-populate it. */
  } else if (cache_fd < 0) {
    goto fail_errno;
  } else {
    /* True if the cache existed and no invalidating changes have occurred since
     * it was generated. */
    valid_cache = cache_key_equal(&current_key, &cached_key);
  }

  if (valid_cache) {
    /* Fetch the cache data and return it if we're able to load it successfully */
    res = fetch_cached_data(
      cache_fd, (ssize_t)cached_key.data_size, handler,
      &output_data, &exception_tag, &errno_provenance
    );
    if (exception_tag != 0)                   goto raise;
    else if (res == CACHE_MISSING_OR_INVALID) valid_cache = 0;
    else if (res == ERROR_WITH_ERRNO)         goto fail_errno;
    else if (!NIL_P(output_data))             goto succeed; /* fast-path, goal */
  }
  close(cache_fd);
  cache_fd = -1;
  /* Cache is stale, invalid, or missing. Regenerate and write it out. */

  /* Read the contents of the source file into a buffer */
  if (bs_read_contents(current_fd, current_key.size, &contents, &errno_provenance) < 0) goto fail_errno;
  input_data = rb_str_new_static(contents, current_key.size);

  /* Try to compile the input_data using input_to_storage(input_data) */
  exception_tag = bs_input_to_storage(handler, input_data, path_v, &storage_data);
  if (exception_tag != 0) goto raise;
  /* If input_to_storage raised Bootsnap::CompileCache::Uncompilable, don't try
   * to cache anything; just return input_to_output(input_data) */
  if (storage_data == uncompilable) {
    bs_input_to_output(handler, input_data, &output_data, &exception_tag);
    if (exception_tag != 0) goto raise;
    goto succeed;
  }
  /* If storage_data isn't a string, we can't cache it */
  if (!RB_TYPE_P(storage_data, T_STRING)) goto invalid_type_storage_data;

  /* Write the cache key and storage_data to the cache directory */
  res = atomic_write_cache_file(cache_path, &current_key, storage_data, &errno_provenance);
  if (res < 0) goto fail_errno;

  /* Having written the cache, now convert storage_data to output_data */
  exception_tag = bs_storage_to_output(handler, storage_data, &output_data);
  if (exception_tag != 0) goto raise;

  /* If output_data is nil, delete the cache entry and generate the output
   * using input_to_output */
  if (NIL_P(output_data)) {
    if (unlink(cache_path) < 0) {
      errno_provenance = (char *)"bs_fetch:unlink";
      goto fail_errno;
    }
    bs_input_to_output(handler, input_data, &output_data, &exception_tag);
    if (exception_tag != 0) goto raise;
  }

  goto succeed; /* output_data is now the correct return. */

#define CLEANUP \
  if (contents != NULL) xfree(contents);   \
  if (current_fd >= 0)  close(current_fd); \
  if (cache_fd >= 0)    close(cache_fd);

succeed:
  CLEANUP;
  return output_data;
fail_errno:
  CLEANUP;
  exception = rb_syserr_new(errno, errno_provenance);
  rb_exc_raise(exception);
  __builtin_unreachable();
raise:
  CLEANUP;
  rb_jump_tag(exception_tag);
  __builtin_unreachable();
invalid_type_storage_data:
  CLEANUP;
  Check_Type(storage_data, T_STRING);
  __builtin_unreachable();

#undef CLEANUP
}

/*****************************************************************************/
/********************* Handler Wrappers **************************************/
/*****************************************************************************
 * Everything after this point in the file is just wrappers to deal with ruby's
 * clunky method of handling exceptions from ruby methods invoked from C:
 *
 * In order to call a ruby method from C, while protecting against crashing in
 * the event of an exception, we must call the method with rb_protect().
 *
 * rb_protect takes a C function and precisely one argument; however, we want
 * to pass multiple arguments, so we must create structs to wrap them up.
 *
 * These functions return an exception_tag, which, if non-zero, indicates an
 * exception that should be jumped to with rb_jump_tag after cleaning up
 * allocated resources.
 */

struct s2o_data {
  VALUE handler;
  VALUE storage_data;
};

struct i2o_data {
  VALUE handler;
  VALUE input_data;
};

struct i2s_data {
  VALUE handler;
  VALUE input_data;
  VALUE pathval;
};

static VALUE
prot_storage_to_output(VALUE arg)
{
  struct s2o_data * data = (struct s2o_data *)arg;
  return rb_funcall(data->handler, rb_intern("storage_to_output"), 1, data->storage_data);
}

static int
bs_storage_to_output(VALUE handler, VALUE storage_data, VALUE * output_data)
{
  int state;
  struct s2o_data s2o_data = {
    .handler      = handler,
    .storage_data = storage_data,
  };
  *output_data = rb_protect(prot_storage_to_output, (VALUE)&s2o_data, &state);
  return state;
}

static void
bs_input_to_output(VALUE handler, VALUE input_data, VALUE * output_data, int * exception_tag)
{
  struct i2o_data i2o_data = {
    .handler    = handler,
    .input_data = input_data,
  };
  *output_data = rb_protect(prot_input_to_output, (VALUE)&i2o_data, exception_tag);
}

static VALUE
prot_input_to_output(VALUE arg)
{
  struct i2o_data * data = (struct i2o_data *)arg;
  return rb_funcall(data->handler, rb_intern("input_to_output"), 1, data->input_data);
}

static VALUE
try_input_to_storage(VALUE arg)
{
  struct i2s_data * data = (struct i2s_data *)arg;
  return rb_funcall(data->handler, rb_intern("input_to_storage"), 2, data->input_data, data->pathval);
}

static VALUE
rescue_input_to_storage(VALUE arg)
{
  return uncompilable;
}

static VALUE
prot_input_to_storage(VALUE arg)
{
  struct i2s_data * data = (struct i2s_data *)arg;
  return rb_rescue2(
      try_input_to_storage, (VALUE)data,
      rescue_input_to_storage, Qnil,
      rb_eBootsnap_CompileCache_Uncompilable, 0);
}

static int
bs_input_to_storage(VALUE handler, VALUE input_data, VALUE pathval, VALUE * storage_data)
{
  int state;
  struct i2s_data i2s_data = {
    .handler    = handler,
    .input_data = input_data,
    .pathval    = pathval,
  };
  *storage_data = rb_protect(prot_input_to_storage, (VALUE)&i2s_data, &state);
  return state;
}
