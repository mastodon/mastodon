### 2.2.1 / 2017-09-13

#### Enhancements

* Verify checksums of files at extraction time (in addition to at download time). (#56)
* Clarify error message if a `tar` command can't be found. (#81)


### 2.2.0 / 2017-06-04

#### Enhancements

* Remove MD5 hashing of configure options, not avialbale in FIPS mode. (#78)
* Add experimental support for cmake-based projects.
* Retry on HTTP failures during downloads. [#63] (Thanks, @jtarchie and @jvshahid!)
* Support Ruby 2.4 frozen string literals.
* Support applying patches for users with misconfigured git worktree. [#69]
* Support gpg signature verification of download resources.


### 2.1.0 / 2016-01-06

#### Enhancements

* Add support for `file:` protocol for tarballs


#### Bugfixes

* Raise exception on unsupported URI protocols
* Ignore git whitespace config when patching (Thanks, @e2!) (#67)


### 2.0.0 / 2015-11-30

Many thanks to @larskanis, @knu, and @kirikak2, who all contributed
code, ideas, or both to this release.

Note that the 0.7.0.rc* series was not released as 0.7.0 final, and
instead became 2.0.0 due to backwards-incompatible behavioral changes
which can appear because rubygems doesn't enforce loading the declared
dependency version at installation-time (only run-time).

If you use MiniPortile in an `extconf.rb` file, please make sure you're
setting a gem version constraint before `require "mini_portile2"` .

Note also that 2.0.0 doesn't include the backwards-compatible "escaped
string" behavior from 0.7.0.rc3.


#### Enhancements

* In patch task, use git(1) or patch(1), whichever is available.
* Append outputs to patch.log instead of clobbering it for every patch command.
* Take `configure_options` literally without running a subshell.
  This changes allows for embedded spaces in a path, among other things.
  Please unescape `configure_options` where you have been doing it yourself.
* Print last 20 lines of the given log file, for convenience.
* Allow SHA1, SHA256 and MD5 hash verification of downloads


#### Bugfixes

* Fix issue when proxy username/password use escaped characters.
* Fix use of https and ftp proxy.


### 0.7.0.rc4 / 2015-08-24

* Updated tests for Windows. No functional change. Final release candidate?


### 0.7.0.rc3 / 2015-08-24

* Restore backwards-compatible behavior with respect to escaped strings.


### 0.7.0.rc2 / 2015-08-24

* Restore support for Ruby 1.9.2
* Add Ruby 2.0.0 and Ruby 2.1.x to Appveyor suite


### 0.7.0.rc1 / 2015-08-24

Many thanks to @larskanis, @knu, and @kirikak2, who all contributed
code, ideas, or both to this release.

#### Enhancements

* In patch task, use git(1) or patch(1), whichever is available.
* Append outputs to patch.log instead of clobbering it for every patch command.
* Take `configure_options` literally without running a subshell.
  This changes allows for embedded spaces in a path, among other things.
  Please unescape `configure_options` where you have been doing it yourself.
* Print last 20 lines of the given log file, for convenience.
* Allow SHA1, SHA256 and MD5 hash verification of downloads


#### Bugfixes

* Fix issue when proxy username/password use escaped characters.
* Fix use of https and ftp proxy.


### 0.6.2 / 2014-12-30

* Updated gemspec, license and README to reflect new maintainer.


### 0.6.1 / 2014-08-03

* Enhancements:
  * Expand path to logfile to easier debugging on failures.
    Pull #33 [marvin2k]

### 0.6.0 / 2014-04-18

* Enhancements:
  * Add default cert store and custom certs from `SSL_CERT_FILE` if present.
    This increases compatibility with Ruby 1.8.7.

* Bugfixes:
  * Specify Accept-Encoding to make sure a raw file content is downloaded.
    Pull #30. [knu]

* Internal:
  * Improve examples and use them as test harness.

### 0.5.3 / 2014-03-24

* Bugfixes:
  * Shell escape paths in tar command. Pull #29. [quickshiftin]
  * Support older versions of tar that cannot auto-detect
    the compression type. Pull #27. Closes #21. [b-dean]
  * Try RbConfig's CC before fall back to 'gcc'. Ref #28.

### 0.5.2 / 2013-10-23

* Bugfixes:
  * Change tar detection order to support NetBSD 'gtar'. Closes #24
  * Trick 'git-apply' when applying patches on nested Git checkouts. [larskanis]
  * Respect ENV's MAKE before fallback to 'make'. [larskanis]
  * Respect ENV's CC variable before fallback to 'gcc'.
  * Avoid non-ASCII output of GCC cause host detection issues. Closes #22

### 0.5.1 / 2013-07-07

* Bugfixes:
  * Detect tar executable without shelling out. [jtimberman]

### 0.5.0 / 2012-11-17

* Enhancements:
  * Allow patching extracted files using `git apply`. [metaskills]

### 0.4.1 / 2012-10-24

* Bugfixes:
  * Syntax to process FTp binary chunks differs between Ruby 1.8.7 and 1.9.x

### 0.4.0 / 2012-10-24

* Enhancements:
  * Allow fetching of FTP URLs along HTTP ones. [metaskills]

### 0.3.0 / 2012-03-23

* Enhancements:
  * Use `gcc -v` to determine original host (platform) instead of Ruby one.

* Deprecations:
  * Dropped support for Rubies older than 1.8.7

### 0.2.2 / 2011-04-11

* Minor enhancements:
  * Use LDFLAGS when activating recipes for cross-compilation. Closes #6

* Bugfixes:
  * Remove memoization of *_path helpers. Closes #7

### 0.2.1 / 2011-04-06

* Minor enhancements:
  * Provide MiniPortile#path to obtain full path to installation directory. Closes GH-5

### 0.2.0 / 2011-04-05

* Enhancements:
  * Improve tar detection
  * Improve and refactor configure_options
  * Detect configure_options changes. Closes GH-1
  * Add recipe examples

* Bugfixes:
  * MiniPortile#target can be changed now. Closes GH-2
  * Always redirect tar output properly

### 0.1.0 / 2011-03-08

* Initial release. Welcome to this world!
