# Hitimes Changelog
## Version 1.2.6 2017-08-04

* Resolve version number issue (#61) (thanks @anthraxx)

## Version 1.2.5 2017-05-25

* Update dependencies
* Add ruby 2.4 to windows fatbinary
* Update docs to indicate windows ruby before 2.0 is no longer supported

## Version 1.2.4 2016-05-01

* Fix finding the extension on ruby 2.1.10 (thanks @wpiekutowski)
* Add more readable load error (thanks @mbautin)
* Update README with what versions of ruby are supported.

## Version 1.2.3 2015-09-13

* Release new fatbinary version for windows
* Update README to indicate duration units
* Provide a more friendly error message if the gem is not installed correctly

## Version 1.2.2 2014-07-09

* fix compilation issue with clock_gettime in libc (reported by eradman and virtualfunction)
* Switch to minispec for tests

## Version 1.2.1 2013-03-12

* Update dependencies
* Ruby 2.0 fixes
* Switch to Markdown, Yeah RDoc 4.0!

## Version 1.2.0 2013-02-09

* Update dependencies
* Documentation cleanup
* Fix use of deprecated JRuby API in java extension
* Fix use of deprecated OSX system calls in C extension
* Make hitimes -w clean
* Fix ambiguity of calling duration on non-started Interval
* Use RbConfig instead of Config (eregon)
* Added Hitimes.measure
* Switch to using rake-compiler for cross compilation of gems

## Version 1.1.1 2010-09-04

* Remove the unnecessary dependencies that should be development dependencies

## Version 1.1.0 2010-07-28

* Add a pure java extension so hitimes may be used in jruby with the same API

## Version 1.0.5 2010-07-20

* Fix 'circular require considered harmful' warnings in 1.9.x (reported by Roger Pack)
* Fix 'method redefined' warnings in 1.9.x (reported by Roger Pack)

## Version 1.0.4 2009-08-01

* Add in support for x86-mingw32 gem
* Add version subdirectory for extension on all platforms

## Version 1.0.3 2009-06-28

* Fix bug with time.h on linode (reported by Roger Pack) 
* Fix potential garbage collection issue with Interval class
* Windows gem is now a fat binary to support installing in 1.8 or 1.9 from the
  same gem

## Version 1.0.1 2009-06-12

* Fix examples
* performance tuning, new Hitimes::Metric derived classes are faster than old Timer class

## Version 1.0.0 2009-06-12

* Major version bump with complete refactor of the metric collection API
* 3 types of metrics now instead of just 1 Timer
    * Hitimes::ValueMetric
    * Hitimes::TimedMetric
    * Hitimes::TimedValueMetric
* The ability to convert all metrics #to_hash
* Updated documentation with examples using each metric type

## Version 0.4.1 2009-02-19

* change to ISC License
* fix bug in compilation on gentoo

## Version 0.4.0 2008-12-20

* Added new stat 'rate'
* Added new stat method to_hash
* Added Hitimes::MutexedStats class for threadsafe stats collection 
    - not needed when used in MRI 1.8.x
* remove stale dependency on mkrf

## Version 0.3.0

* switched to extconf for building extensions
* first release of windows binary gem
* reverted back to normal rdoc

## Version 0.2.1

* added Timer#rate method
* switched to darkfish rdoc

## Version 0.2.0

* Performance improvements
* Added Hitimes::Stats class

## Version 0.1.0

* Initial completion
