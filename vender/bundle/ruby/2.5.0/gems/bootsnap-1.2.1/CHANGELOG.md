# 1.2.1

* Fix method visibility of `Kernel#require`.

# 1.2.0

* Add `LoadedFeaturesIndex` to preserve fix a common bug related to `LOAD_PATH` modifications after
  loading bootsnap.

# 1.1.8

* Don't cache YAML documents with `!ruby/object`
* Fix cache write mode on Windows

# 1.1.7

* Create cache entries as 0775/0664 instead of 0755/0644
* Better handling around cache updates in highly-parallel workloads

# 1.1.6

* Assortment of minor bugfixes

# 1.1.5

* bugfix re-release of 1.1.4

# 1.1.4 (yanked)

* Avoid loading a constant twice by checking if it is already defined

# 1.1.3

* Properly resolve symlinked path entries

# 1.1.2

* Minor fix: deprecation warning

# 1.1.1

* Fix crash in `Native.compile_option_crc32=` on 32-bit platforms.

# 1.1.0

* Add `bootsnap/setup`
* Support jruby (without compile caching features)
* Better deoptimization when Coverage is enabled
* Consider `Bundler.bundle_path` to be stable

# 1.0.0

* (none)

# 0.3.2

* Minor performance savings around checking validity of cache in the presence of relative paths.
* When coverage is enabled, skips optimization instead of exploding.

# 0.3.1

* Don't whitelist paths under `RbConfig::CONFIG['prefix']` as stable; instead use `['libdir']` (#41).
* Catch `EOFError` when reading load-path-cache and regenerate cache.
* Support relative paths in load-path-cache.

# 0.3.0

* Migrate CompileCache from xattr as a cache backend to a cache directory
    * Adds support for Linux and FreeBSD

# 0.2.15

* Support more versions of ActiveSupport (`depend_on`'s signature varies; don't reiterate it)
* Fix bug in handling autoloaded modules that raise NoMethodError
