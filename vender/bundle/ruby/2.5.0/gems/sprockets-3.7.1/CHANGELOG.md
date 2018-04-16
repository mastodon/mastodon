**3.7.1** (December 19, 2016)

* Ruby 2.4 support for Sprockets 3.

**3.7.0** (July 21, 2016)

* Deprecated interfaces now emit deprecation warnings #345

**3.6.3** (July 1, 2016)

* Faster asset lookup in large directories #336
* Faster PathUtils.match_path_extname https://github.com/rails/sprockets/commit/697269cf81e5261fdd7072e32bd489403027fd7e
* Fixed uglifier comment stripping #326
* Error messages now show load path info #313

**3.6.2** (June 21, 2016)

* More performance improvements.

**3.6.1** (June 17, 2016)

* Some performance improvements.

**3.6.0** (April 6, 2016)

* Add `Manifest#find_sources` to return the source of the compiled assets.
* Fix the list of compressable mime types.
* Improve performance of the `FileStore` cache.

**3.5.2** (December 8, 2015)

* Fix JRuby bug with concurrent-ruby.
* Fix disabling gzip generation in cached environments.

**3.5.1** (December 5, 2015)

* Fix gzip asset generation for assets already on disk.

**3.5.0** (December 3, 2015)

* Reintroduce Gzip file generation for non-binary assets.

**3.4.1** (November 25, 2015)

* PathUtils::Entries will no longer error on an empty directory.

**3.4.0** (October 5, 2015)

* Expose method to override the sass cache in the SassProcessor.

**3.3.5** (September 25, 2015)

* Fix bug related to absolute path being reintroduced into history cache #141.

**3.3.4** (September 1, 2015)

* Relative cache contents now work with windows.

**3.3.3** (August 21, 2015)

* Remove more absolute paths from cache contents.

**3.3.2** (August 19, 2015)

* Fix cache contents to use relative paths instead of absolute paths.

**3.3.1** (August 15, 2015)

* Fix legacy Tilt integration when locals is required argument.

**3.3.0** (August 12, 2015)

* Change internal cache key to use relative asset paths instead of absolute paths.

**3.2.0** (June 2, 2015)

* Updated SRI integrity to align with spec changes
* Deprecated Manifest integrity attribute
* Cleanup concatenating JS sources with newlines

**3.1.0** (May 10, 2015)

* Removed "index" logical path normalization. Asset#logical_path is always the
  full logical path to the index file.
* Fixed static asset mtimes
* Fix manifest cleanup by age
* Removed redundant minifier level cache
* Updated SRI format according to spec changes

**3.0.3** (April 27, 2015)

* Fix static asset mtime fallback
* Only warn when specified asset version can not be loaded.

**3.0.2** (April 22, 2015)

* Ensure legacy Tilt handlers return String class data. Fixes issues with Haml
  Tilt handler.
* Type check and improve error messages raised on bad processor returned results.
* Improve error message for relative paths not under load path.
* Changed HTML encoding fallback from ISO-8859-1 to default external.
* Avoid falling back to 0 mtimes which may cause warnings with tar

**3.0.1** (April 14, 2015)

* Fixed `Context#depend_on` with paths outside the load path

**3.0.0** (April 12, 2015)

[Guide to upgrading from Sprockets 2.x to 3.x](https://github.com/rails/sprockets/blob/3.x/UPGRADING.md)

* New processor API. Tilt interface is deprecated.
* Improved file store caching backend.
* MIME Types now accept charset custom charset detecters. Improves support for UTF-16/32 files.
* Environment#version no longer affects asset digests. Only used for busting the asset cache.
* Removed builtin support for LESS.
* Removed `//= include` directive support.
* Deprecated `BundledAsset#to_a`. Use `BundledAsset#included` to access debugging subcomponents.
* Support circular dependencies. For parity with ES6 modules.
* Manifest compilation will no longer generate .gz files by default. [Mixing
  Content-Encoding and ETags is just a bad
  idea](https://issues.apache.org/bugzilla/show_bug.cgi?id=39727)
* Added linked or referenced assets. When an asset is compiled, any of its links will be compiled as well.
* Introduce some limitations around enumerating all logical paths. 4.x will deprecate it and favor linked manifests for compliation.
* Add Asset integrity attribute for Subresource Integrity
* Default digest changed to SHA256. Configuring `digest_class` is deprecated.
* Rename `Asset#digest` to `Asset#hexdigest`. `Asset#digest` is deprecated and will
  return a raw byte String in 4.x.
* Added transitional compatibility flag to `Environment#resolve(path, compat: true)`. 2.x mode operates with `compat: true` and 4.x with `compat: false`
* `manifest-abc123.json` renamed to `.sprockets-abc123.json`

**2.12.3** (October 28, 2014)

* Security: Fix directory traversal bug in development mode server.

**2.12.2** (September 5, 2014)

* Ensure internal asset lookups calls are still restricted to load paths within
  asset compiles. Though, you should not depend on internal asset resolves to be
  completely restricted for security reasons. Assets themselves should be
  considered full scripting environments with filesystem access.

**2.12.1** (April 17, 2014)

* Fix making manifest target directory when its different than the output directory.

**2.12.0** (March 13, 2014)

* Avoid context reference in SassImporter hack so its Marshallable. Fixes
 issues with Sass 3.3.x.

**2.11.0** (February 19, 2014)

* Cache store must now be an LRU implementation.
* Default digest changed to SHA1. To continue using MD5.
  `env.digest_class = Digest::MD5`.

**2.10.0** (May 24, 2013)

* Support for `bower.json`

**2.9.3** (April 20, 2013)

* Fixed sass caching bug

**2.9.2** (April 8, 2013)

* Improve file freshness check performance
* Directive processor encoding fixes

**2.9.1** (April 6, 2013)

* Support for Uglifier 2.x

**2.9.0** (February 25, 2013)

* Write out gzipped variants of bundled assets.

**2.8.2** (December 10, 2012)

* Fixed top level Sass constant references
* Fixed manifest logger when environment is disabled

**2.8.1** (October 31, 2012)

* Fixed Sass importer bug

**2.8.0** (October 16, 2012)

* Allow manifest location to be separated from output directory
* Pass logical path and absolute path to each_logical_path iterator

**2.7.0** (October 10, 2012)

* Added --css-compressor and --js-compressor command line flags
* Added css/js compressor shorthand
* Change default manifest.json filename to be a randomized manifest-16HEXBYTES.json
* Allow nil environment to be passed to manifest
* Allow manifest instance to be set on rake task

**2.6.0** (September 19, 2012)

* Added bower component.json require support

**2.5.0** (September 4, 2012)

* Fixed Ruby 2.0 RegExp warning
* Provide stubbed implementation of context *_path helpers
* Add SassCompressor

**2.4.5** (July 10, 2012)

* Tweaked some logger levels

**2.4.4** (July 2, 2012)

* Canonicalize logical path extensions
* Check absolute paths passed to depend_on

**2.4.3** (May 16, 2012)

* Exposed :sprockets in sass options
* Include dependency paths in asset mtime

**2.4.2** (May 7, 2012)

* Fixed MultiJson feature detect

**2.4.1** (April 26, 2012)

* Fixed MultiJson API change
* Fixed gzip mtime

**2.4.0** (March 27, 2012)

* Added global path registry
* Added global processor registry

**2.3.2** (March 26, 2012)

* Fix Context#logical_path with dots

**2.3.1** (February 11, 2012)

* Added bytesize to manifest
* Added Asset#bytesize alias
* Security: Check path for forbidden access after unescaping

**2.3.0** (January 16, 2012)

* Added special Sass importer that automatically tracks any `@import`ed files.

**2.2.0** (January 10, 2012)

* Added `sprockets` command line utility.
* Added rake/sprocketstask.
* Added json manifest log of compiled assets.
* Added `stub` directive that allows you to exclude files from the bundle.
* Added per environment external encoding (Environment#default_external_encoding). Defaults to UTF-8. Fixes issues where LANG is not set correctly and Rubys default external is set to ASCII.

**2.1.2** (November 20, 2011)

* Disabled If-Modified-Since server checks. Fixes some browser caching issues when serving the asset body only. If-None-Match caching is sufficient.

**2.1.1** (November 18, 2011)

* Fix windows absolute path check bug.

**2.1.0** (November 11, 2011)

* Directive comment lines are now turned into empty lines instead of removed. This way line numbers in
  CoffeeScript syntax errors are correct.
* Performance and caching bug fixes.

**2.0.3** (October 17, 2011)

* Detect format extensions from right to left.
* Make JST namespace configurable.

**2.0.2** (October 4, 2011)

* Fixed loading stale cache from bundler gems.

**2.0.1** (September 30, 2011)

* Fixed bug with fingerprinting file names with multiple dots.
* Decode URIs as default internal.
* Fix symlinked asset directories.

**2.0.0** (August 29, 2011)

* Initial public release.
