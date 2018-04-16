Version 1.2.5 - 4-Feb-2018
--------------------------

* Support recursively (deep) freezing Country and Timezone instances. #80.
* Allow negative daylight savings time offsets to be derived when reading from
  zoneinfo files. The utc_offset and std_offset are now derived correctly for
  Europe/Dublin in the 2018a and 2018b releases of the Time Zone Database.


Version 1.2.4 - 26-Oct-2017
---------------------------

* Ignore the leapseconds file that is included in zoneinfo directories installed
  with version 2017c and later of the Time Zone Database.


Version 1.2.3 - 25-Mar-2017
---------------------------

* Reduce the number of String objects allocated when loading zoneinfo files.
  #54.
* Make Timezone#friendly_identifier compatible with frozen string literals.
* Improve the algorithm for deriving the utc_offset from zoneinfo files. This
  now correctly handles Pacific/Apia switching from one side of the
  International Date Line to the other whilst observing daylight savings time.
  #66.
* Fix an UnknownTimezone exception when calling transitions_up_to or
  offsets_up_to on a TimezoneProxy instance obtained from Timezone.get_proxy.
* Allow the Factory zone to be obtained from the Zoneinfo data source.
* Ignore the /usr/share/zoneinfo/timeconfig symlink included in Slackware
  distributions. #64.
* Fix Timezone#strftime handling of %Z expansion when %Z is prefixed with more
  than one percent. #31.
* Support expansion of %z, %:z, %::z and %:::z to the UTC offset of the time
  zone in Timezone#strftime. #31 and #67.


Version 1.2.2 - 8-Aug-2014
--------------------------

* Fix an error with duplicates being returned by Timezone#all_country_zones
  and Timezone#all_country_zone_identifiers when used with tzinfo-data
  v1.2014.6 or later.
* Use the zone1970.tab file for country timezone data if it is found in the
  zoneinfo directory (and fallback to zone.tab if not). zone1970.tab was added
  in tzdata 2014f. zone.tab is now deprecated.


Version 1.2.1 - 1-Jun-2014
--------------------------

* Support zoneinfo files generated with zic version 2014c and later.
* On platforms that only support positive 32-bit timestamps, ensure that
  conversions are accurate from the epoch instead of just from the first
  transition after the epoch.
* Minor documentation improvements.


Version 1.2.0 - 26-May-2014
---------------------------

* Raise the minimum supported Ruby version to 1.8.7.
* Support loading system zoneinfo data on FreeBSD, OpenBSD and Solaris.
  Resolves #15.
* Add canonical_identifier and canonical_zone methods to Timezone. Resolves #16.
* Add a link to a DataSourceNotFound help page in the TZInfo::DataSourceNotFound
  exception message.
* Load iso3166.tab and zone.tab files as UTF-8.
* Fix Timezone#local_to_utc returning local Time instances on systems using UTC
  as the local time zone. Resolves #13.
* Fix == methods raising an exception when passed an instance of a different
  class by making <=> return nil if passed a non-comparable argument.
* Eliminate "require 'rational'" warnings. Resolves #10.
* Eliminate "assigned but unused variable - info" warnings. Resolves #11.
* Switch to minitest v5 for unit tests. Resolves #18.


Version 1.1.0 - 25-Sep-2013
---------------------------

* TZInfo is now thread safe. ThreadSafe::Cache is now used instead of Hash
  to cache Timezone and Country instances returned by Timezone.get and
  Country.get. The tzinfo gem now depends on thread_safe ~> 0.1.
* Added a transitions_up_to method to Timezone that returns a list of the times
  where the UTC offset of the timezone changes.
* Added an offsets_up_to method to Timezone that returns the set of offsets
  that have been observed in a defined timezone.
* Fixed a "can't modify frozen String" error when loading a Timezone from a
  zoneinfo file using an identifier String that is both tainted and frozen.
  Resolves #3.
* Support TZif3 format zoneinfo files (now produced by zic from tzcode version
  2013e onwards).
* Support using YARD to generate documentation (added a .yardopts file).
* Ignore the +VERSION file included in the zoneinfo directory on Mac OS X.
* Added a note to the documentation concerning 32-bit zoneinfo files (as 
  included with Mac OS X).


Version 1.0.1 - 22-Jun-2013
---------------------------

* Fix a test case failure when tests are run from a directory that contains a
  dot in the path (issue #29751).


Version 1.0.0 - 2-Jun-2013
--------------------------

* Allow TZInfo to be used with different data sources instead of just the
  built-in Ruby module data files.
* Include a data source that allows TZInfo to load data from the binary
  zoneinfo files produced by zic and included with many Linux and Unix-like
  distributions.
* Remove the definition and index Ruby modules from TZInfo and move them into
  a separate TZInfo::Data library (available as the tzinfo-data gem).
* Default to using the TZInfo::Data library as the data source if it is 
  installed, otherwise use zoneinfo files instead.
* Preserve the nanoseconds of local timezone Time objects when performing 
  conversions (issue #29705).
* Don't add the tzinfo lib directory to the search path when requiring 'tzinfo'.
  The tzinfo lib directory must now be in the search path before 'tzinfo' is
  required.
* Add utc_start_time, utc_end_time, local_start_time and local_end_time instance
  methods to TimezonePeriod. These return an identical value as the existing
  utc_start, utc_end, local_start and local_end methods, but return Time
  instances instead of DateTime.
* Make the start_transition, end_transition and offset properties of
  TimezonePeriod protected. To access properties of the period, callers should
  use other TimezonePeriod instance methods instead (issue #7655).


Version 0.3.53 (tzdata v2017b) - 23-Mar-2017
--------------------------------------------

* Updated to tzdata version 2017b
  (https://mm.icann.org/pipermail/tz-announce/2017-March/000046.html).


Version 0.3.52 (tzdata v2016h) - 28-Oct-2016
--------------------------------------------

* Updated to tzdata version 2016h
  (https://mm.icann.org/pipermail/tz-announce/2016-October/000042.html).


Version 0.3.51 (tzdata v2016f) - 5-Jul-2016
-------------------------------------------

* Updated to tzdata version 2016f
  (https://mm.icann.org/pipermail/tz-announce/2016-July/000040.html).


Version 0.3.50 (tzdata v2016e) - 14-Jun-2016
--------------------------------------------

* Updated to tzdata version 2016e
  (https://mm.icann.org/pipermail/tz-announce/2016-June/000039.html).


Version 0.3.49 (tzdata v2016d) - 18-Apr-2016
--------------------------------------------

* Updated to tzdata version 2016d
  (https://mm.icann.org/pipermail/tz-announce/2016-April/000038.html).


Version 0.3.48 (tzdata v2016c) - 23-Mar-2016
--------------------------------------------

* Updated to tzdata version 2016c
  (https://mm.icann.org/pipermail/tz-announce/2016-March/000037.html).


Version 0.3.47 (tzdata v2016b) - 15-Mar-2016
--------------------------------------------

* Updated to tzdata version 2016b
  (https://mm.icann.org/pipermail/tz-announce/2016-March/000036.html).


Version 0.3.46 (tzdata v2015g) - 2-Dec-2015
-------------------------------------------

* From version 2015e, the IANA time zone database uses non-ASCII characters in
  country names. Backport the encoding handling from TZInfo::Data to allow
  TZInfo 0.3.x to support Ruby 1.9 (which would otherwise fail with an invalid
  byte sequence error when loading the countries index). Resolves #41.


Version 0.3.45 (tzdata v2015g) - 3-Oct-2015
-------------------------------------------

* Updated to tzdata version 2015g
  (http://mm.icann.org/pipermail/tz-announce/2015-October/000034.html).


Version 0.3.44 (tzdata v2015d) - 24-Apr-2015
--------------------------------------------

* Updated to tzdata version 2015d
  (http://mm.icann.org/pipermail/tz-announce/2015-April/000031.html).


Version 0.3.43 (tzdata v2015a) - 31-Jan-2015
--------------------------------------------

* Updated to tzdata version 2015a
  (http://mm.icann.org/pipermail/tz-announce/2015-January/000028.html).


Version 0.3.42 (tzdata v2014i) - 23-Oct-2014
--------------------------------------------

* Updated to tzdata version 2014i
  (http://mm.icann.org/pipermail/tz-announce/2014-October/000026.html).


Version 0.3.41 (tzdata v2014f) - 8-Aug-2014
-------------------------------------------

* Updated to tzdata version 2014f
  (http://mm.icann.org/pipermail/tz-announce/2014-August/000023.html).


Version 0.3.40 (tzdata v2014e) - 10-Jul-2014
--------------------------------------------

* Updated to tzdata version 2014e
  (http://mm.icann.org/pipermail/tz-announce/2014-June/000022.html).


Version 0.3.39 (tzdata v2014a) - 9-Mar-2014
-------------------------------------------

* Updated to tzdata version 2014a
  (http://mm.icann.org/pipermail/tz-announce/2014-March/000018.html).


Version 0.3.38 (tzdata v2013g) - 8-Oct-2013
-------------------------------------------

* Updated to tzdata version 2013g
  (http://mm.icann.org/pipermail/tz-announce/2013-October/000015.html).


Version 0.3.37 (tzdata v2013b) - 11-Mar-2013
--------------------------------------------

* Updated to tzdata version 2013b
  (http://mm.icann.org/pipermail/tz-announce/2013-March/000010.html).


Version 0.3.36 (tzdata v2013a) - 3-Mar-2013
-------------------------------------------

* Updated to tzdata version 2013a
  (http://mm.icann.org/pipermail/tz-announce/2013-March/000009.html).
* Fix TimezoneTransitionInfo#eql? incorrectly returning false when running on 
  Ruby 2.0.
* Change eql? and == implementations to test the class of the passed in object
  instead of checking individual properties with 'respond_to?'.


Version 0.3.35 (tzdata v2012i) - 4-Nov-2012
-------------------------------------------

* Updated to tzdata version 2012i
  (http://mm.icann.org/pipermail/tz-announce/2012-November/000007.html).


Version 0.3.34 (tzdata v2012h) - 27-Oct-2012
--------------------------------------------

* Updated to tzdata version 2012h
  (http://mm.icann.org/pipermail/tz-announce/2012-October/000006.html).


Version 0.3.33 (tzdata v2012c) - 8-Apr-2012
-------------------------------------------

* Updated to tzdata version 2012c
  (http://article.gmane.org/gmane.comp.time.tz/4859).


Version 0.3.32 (tzdata v2012b) - 4-Mar-2012
-------------------------------------------

* Updated to tzdata version 2012b
  (http://article.gmane.org/gmane.comp.time.tz/4756).


Version 0.3.31 (tzdata v2011n) - 6-Nov-2011
-------------------------------------------

* Updated to tzdata version 2011n
  (http://article.gmane.org/gmane.comp.time.tz/4434).


Version 0.3.30 (tzdata v2011k) - 29-Sep-2011
--------------------------------------------

* Updated to tzdata version 2011k
  (http://article.gmane.org/gmane.comp.time.tz/4084).


Version 0.3.29 (tzdata v2011h) - 27-Jun-2011
--------------------------------------------

* Updated to tzdata version 2011h
  (http://article.gmane.org/gmane.comp.time.tz/3814).
* Allow the default value of the local_to_utc and period_for_local dst 
  parameter to be specified globally with a Timezone.default_dst attribute.
  Thanks to Kurt Werle for the suggestion and patch.


 Version 0.3.28 (tzdata v2011g) - 13-Jun-2011
---------------------------------------------

* Add support for Ruby 1.9.3 (trunk revision 31668 and later). Thanks to 
  Aaron Patterson for reporting the problems running on the new version.
  Closes #29233.


Version 0.3.27 (tzdata v2011g) - 26-Apr-2011
--------------------------------------------

* Updated to tzdata version 2011g
  (http://article.gmane.org/gmane.comp.time.tz/3758).


Version 0.3.26 (tzdata v2011e) - 2-Apr-2011
-------------------------------------------

* Updated to tzdata version 2011e
  (http://article.gmane.org/gmane.comp.time.tz/3707).


Version 0.3.25 (tzdata v2011d) - 14-Mar-2011
--------------------------------------------

* Updated to tzdata version 2011d
  (http://article.gmane.org/gmane.comp.time.tz/3662).


Version 0.3.24 (tzdata v2010o) - 15-Jan-2011
--------------------------------------------

* Updated to tzdata version 2010o
  (http://article.gmane.org/gmane.comp.time.tz/3473).


Version 0.3.23 (tzdata v2010l) - 19-Aug-2010
--------------------------------------------

* Updated to tzdata version 2010l
  (http://article.gmane.org/gmane.comp.time.tz/3354).


Version 0.3.22 (tzdata v2010j) - 29-May-2010
--------------------------------------------

* Corrected file permissions issue with 0.3.21 release.


Version 0.3.21 (tzdata v2010j) - 28-May-2010
--------------------------------------------

* Updated to tzdata version 2010j
  (http://article.gmane.org/gmane.comp.time.tz/3225).
* Change invalid timezone check to exclude characters not used in timezone
  identifiers and avoid 'character class has duplicated range' warnings with
  Ruby 1.9.2.
* Ruby 1.9.2 has deprecated "require 'rational'", but older versions of
  Ruby need rational to be required. Require rational only when the Rational
  module has not already been loaded.
* Remove circular requires (now a warning in Ruby 1.9.2). Instead of using
  requires in each file for dependencies, tzinfo.rb now requires all tzinfo
  files. If you were previously requiring files within the tzinfo directory
  (e.g. require 'tzinfo/timezone'), then you will now have to
  require 'tzinfo' instead.


Version 0.3.20 (tzdata v2010i) - 19-Apr-2010
--------------------------------------------

* Updated to tzdata version 2010i
  (http://article.gmane.org/gmane.comp.time.tz/3202).


Version 0.3.19 (tzdata v2010h) - 5-Apr-2010
-------------------------------------------

* Updated to tzdata version 2010h
  (http://article.gmane.org/gmane.comp.time.tz/3188).


Version 0.3.18 (tzdata v2010g) - 29-Mar-2010
--------------------------------------------

* Updated to tzdata version 2010g
  (http://article.gmane.org/gmane.comp.time.tz/3172).


Version 0.3.17 (tzdata v2010e) - 8-Mar-2010
-------------------------------------------

* Updated to tzdata version 2010e
  (http://article.gmane.org/gmane.comp.time.tz/3128).


Version 0.3.16 (tzdata v2009u) - 5-Jan-2010
-------------------------------------------

* Support the use of '-' to denote '0' as an offset in the tz data files.
  Used for the first time in the SAVE field in tzdata v2009u.
* Updated to tzdata version 2009u
  (http://article.gmane.org/gmane.comp.time.tz/3053).


Version 0.3.15 (tzdata v2009p) - 26-Oct-2009
--------------------------------------------

* Updated to tzdata version 2009p
  (http://article.gmane.org/gmane.comp.time.tz/2953).
* Added a description to the gem spec.
* List test files in test_files instead of files in the gem spec.


Version 0.3.14 (tzdata v2009l) - 19-Aug-2009
--------------------------------------------

* Updated to tzdata version 2009l
  (http://article.gmane.org/gmane.comp.time.tz/2818).
* Include current directory in load path to allow running tests on
  Ruby 1.9.2, which doesn't include it by default any more.


Version 0.3.13 (tzdata v2009f) - 15-Apr-2009
--------------------------------------------

* Updated to tzdata version 2009f
  (http://article.gmane.org/gmane.comp.time.tz/2668).
* Untaint the timezone module filename after validation to allow use
  with $SAFE == 1 (e.g. under mod_ruby). Thanks to Dmitry Borodaenko for
  the suggestion. Closes #25349.


Version 0.3.12 (tzdata v2008i) - 12-Nov-2008
--------------------------------------------

* Updated to tzdata version 2008i
  (http://article.gmane.org/gmane.comp.time.tz/2440).


Version 0.3.11 (tzdata v2008g) - 7-Oct-2008
-------------------------------------------

* Updated to tzdata version 2008g
  (http://article.gmane.org/gmane.comp.time.tz/2335).
* Support Ruby 1.9.0-5. Rational.new! has now been removed in Ruby 1.9.
  Only use Rational.new! if it is available (it is preferable in Ruby 1.8
  for performance reasons). Thanks to Jeremy Kemper and Pratik Naik for
  reporting this. Closes #22312.
* Apply a patch from Pratik Naik to replace assert calls that have been
  deprecated in the Ruby svn trunk. Closes #22308.


Version 0.3.10 (tzdata v2008f) - 16-Sep-2008
--------------------------------------------

* Updated to tzdata version 2008f
  (http://article.gmane.org/gmane.comp.time.tz/2293).


Version 0.3.9 (tzdata v2008c) - 27-May-2008
-------------------------------------------

* Updated to tzdata version 2008c
  (http://article.gmane.org/gmane.comp.time.tz/2183).
* Support loading timezone data in the latest trunk versions of Ruby 1.9.
  Rational.new! is now private, so call it using Rational.send :new! instead.
  Thanks to Jeremy Kemper and Pratik Naik for spotting this. Closes #19184.
* Prevent warnings from being output when running Ruby with the -v or -w
  command line options. Thanks to Paul McMahon for the patch. Closes #19719.


Version 0.3.8 (tzdata v2008b) - 24-Mar-2008
-------------------------------------------

* Updated to tzdata version 2008b
  (http://article.gmane.org/gmane.comp.time.tz/2149).
* Support loading timezone data in Ruby 1.9.0. Use DateTime.new! if it is
  available instead of DateTime.new0 when constructing transition times.
  DateTime.new! was added in Ruby 1.8.6. DateTime.new0 was removed in
  Ruby 1.9.0. Thanks to Joshua Peek for reporting this. Closes #17606.
* Modify some of the equality test cases to cope with the differences
  between Ruby 1.8.6 and Ruby 1.9.0.


Version 0.3.7 (tzdata v2008a) - 10-Mar-2008
-------------------------------------------

* Updated to tzdata version 2008a
  (http://article.gmane.org/gmane.comp.time.tz/2071).


Version 0.3.6 (tzdata v2007k) - 1-Jan-2008
------------------------------------------

* Updated to tzdata version 2007k
  (http://article.gmane.org/gmane.comp.time.tz/2029).
* Removed deprecated RubyGems autorequire option.


Version 0.3.5 (tzdata v2007h) - 1-Oct-2007
------------------------------------------

* Updated to tzdata version 2007h
  (http://article.gmane.org/gmane.comp.time.tz/1878).


Version 0.3.4 (tzdata v2007g) - 21-Aug-2007
-------------------------------------------

* Updated to tzdata version 2007g
  (http://article.gmane.org/gmane.comp.time.tz/1810).


Version 0.3.3 (tzdata v2006p) - 27-Nov-2006
-------------------------------------------

* Updated to tzdata version 2006p
  (http://article.gmane.org/gmane.comp.time.tz/1358).


Version 0.3.2 (tzdata v2006n) - 11-Oct-2006
-------------------------------------------

* Updated to tzdata version 2006n
  (http://article.gmane.org/gmane.comp.time.tz/1288). Note that this release of
  tzdata removes the country Serbia and Montenegro (CS) and replaces it with
  separate Serbia (RS) and Montenegro (ME) entries.


Version 0.3.1 (tzdata v2006j) - 21-Aug-2006
-------------------------------------------

* Remove colon from case statements to avoid warning in Ruby 1.8.5. #5198.
* Use temporary variable to avoid dynamic string warning from rdoc.
* Updated to tzdata version 2006j
  (http://article.gmane.org/gmane.comp.time.tz/1175).


Version 0.3.0 (tzdata v2006g) - 17-Jul-2006
-------------------------------------------

* New timezone data format. Timezone data now occupies less space on disk and
  takes less memory once loaded. #4142, #4144.
* Timezone data is defined in modules rather than classes. Timezone instances 
  returned by Timezone.get are no longer instances of data classes, but are
  instead instances of new DataTimezone and LinkedTimezone classes.
* Timezone instances can now be used with Marshal.dump and Marshal.load. #4240.
* Added a Timezone.get_proxy method that returns a TimezoneProxy object for a 
  given identifier.
* Country index data is now defined in a single module that is independent
  of the Country class implementation.
* Country instances can now be used with Marshal.dump and Marshal.load. #4240.
* Country has a new zone_info method that returns CountryTimezone objects
  containing additional information (latitude, longitude and a description) 
  relating to each Timezone. #4140.
* Timezones within a Country are now returned in an order that makes 
  geographic sense.
* The zdumptest utility now checks local to utc conversions in addition to
  utc to local conversions.
* eql? method defined on Country and Timezone that is equivalent to ==.
* The == method of Timezone no longer raises an exception when passed an object
  with no identifier method.
* The == method of Country no longer raises an exception when passed an object
  with no code method.
* hash method defined on Country that returns the hash of the code.
* hash method defined on Timezone that returns the hash of the identifier.
* Miscellaneous API documentation corrections and improvements.
* Timezone definition and indexes are now excluded from rdoc (the contents were
  previously ignored with #:nodoc: anyway).
* Removed no longer needed #:nodoc: directives from timezone data files (which
  are now excluded from the rdoc build).
* Installation of the gem now causes rdoc API documentation to be generated. 
  #4905.
* When optimizing transitions to generate zone definitions, check the
  UTC and standard offsets separately rather than just the total offset to UTC.
  Fixes an incorrect abbreviation issue with Europe/London, Europe/Dublin and 
  Pacific/Auckland.
* Eliminated unnecessary .nil? calls to give a minor performance gain.
* Timezone.all and Timezone.all_identifiers now return all the 
  Timezones/identifiers rather than just those associated with countries. #4146.
* Added all_data_zones, all_data_zone_identifiers, all_linked_zones and
  all_linked_zone_identifiers class methods to Timezone.
* Added a strftime method to Timezone that converts a time in UTC to local
  time and then returns it formatted. %Z is replaced with the Timezone 
  abbreviation for the given time (for example, EST or EDT). #4143.
* Fix escaping of quotes in TZDataParser. This affected country names and
  descriptions of timezones within countries.


Version 0.2.2 (tzdata v2006g) - 17-May-2006
-------------------------------------------

* Use class-scoped instance variables to store the Timezone identifier and 
  singleton instance. Loading a linked zone no longer causes the parent
  zone's identifier to be changed. The instance method of a linked zone class
  also now returns an instance of the linked zone class rather than the parent
  class. #4502.
* The zdumptest utility now compares the TZInfo zone identifier with the zdump
  zone identifier.
* The zdumptestall utility now exits if not supplied with enough parameters.
* Updated to tzdata version 2006g
  (http://article.gmane.org/gmane.comp.time.tz/1008).


Version 0.2.1 (tzdata v2006d) - 17-Apr-2006
-------------------------------------------

* Fix a performance issue caused in 0.2.0 with Timezone.local_to_utc. 
  Conversions performed on TimeOrDateTime instances passed to <=> are now
  cached as originally intended. Thanks to Michael Smedberg for spotting this.
* Fix a performance issue with the local_to_utc period search algorithm 
  originally implemented in 0.1.0. The condition that was supposed to cause
  the search to terminate when enough periods had been found was only being
  evaluated in a small subset of cases. Thanks to Michael Smedberg and 
  Jamis Buck for reporting this.
* Added abbreviation as an alias for TimezonePeriod.zone_identifier.
* Updated to tzdata version 2006d
  (http://article.gmane.org/gmane.comp.time.tz/936).
* Ignore any offset in DateTimes passed in (as is already done for Times).
  All of the following now refer to the same UTC time (15:40 on 17 April 2006). 
  Previously, the DateTime in the second line would have been interpreted 
  as 20:40.
  
    tz.utc_to_local(DateTime.new(2006, 4, 17, 15, 40, 0))
    tz.utc_to_local(DateTime.new(2006, 4, 17, 15, 40, 0).new_offset(Rational(5, 24)))
    tz.utc_to_local(Time.utc(2006, 4, 17, 15, 40, 0))
    tz.utc_to_local(Time.local(2006, 4, 17, 15, 40, 0))


Version 0.2.0 (tzdata v2006c) - 3-Apr-2006
------------------------------------------

* Use timestamps rather than DateTime objects in zone files for times between
  1970 and 2037 (the range of Time).
* Don't convert passed in Time objects to DateTime in most cases (provides 
  a substantial performance improvement).
* Allow integer timestamps (time in seconds since 1970-1-1) to be used as well 
  as Time and DateTime objects in all public methods that take times as 
  parameters.
* Tool to compare TZInfo conversions with output from zdump.
* TZDataParser zone generation algorithm rewritten. Now based on the zic code.
  TZInfo is now 100% compatible with zic/zdump output.
* Riyadh Solar Time zones now included again (generation time has been reduced
  with TZDataParser changes).
* Use binary mode when writing zone and country files to get Unix (\n) new
  lines.
* Omit unnecessary quotes in zone identifier symbols.
* Omit the final transition to DST if there is a prior transition in the last
  year processed to standard time.
* Updated to tzdata version 2006c
  (http://article.gmane.org/gmane.comp.time.tz/920).


Version 0.1.2 (tzdata v2006a) - 5-Feb-2006
------------------------------------------

* Add lib directory to the load path when tzinfo is required. Makes it easier
  to use tzinfo gem when unpacked to vendor directory in rails. 
* Updated to tzdata version 2006a 
  (http://article.gmane.org/gmane.comp.time.tz/738).
* build_tz_classes rake task now handles running svn add and svn delete as new 
  timezones and countries are added and old ones are removed.
* Return a better error when attempting to use a Timezone instance that was
  constructed with Timezone.new(nil). This will occur when using Rails'
  composed_of. When the timezone identifier in the database is null, attempting
  to use the Timezone will now result in an UnknownTimezone exception rather 
  than a NameError.


Version 0.1.1 (tzdata v2005q) - 18-Dec-2005
-------------------------------------------

* Timezones that are defined by a single unbounded period (e.g. UTC) now 
  work again.
* Updated to tzdata version 2005q.


Version 0.1.0 (tzdata v2005n) - 27-Nov-2005
-------------------------------------------

* period_for_local and local_to_utc now allow resolution of ambiguous
  times (e.g. when switching from daylight savings to standard time). 
  The behaviour of these methods when faced with an ambiguous local time
  has now changed. If you are using these methods you should check
  the documentation. Thanks to Cliff Matthews for suggesting this change.
* Added require 'date' to timezone.rb (date isn't loaded by default in all
  environments).
* Use rake to build packages and documentation.
* License file is now included in gem distribution.
* Dates in definitions stored as Astronomical Julian Day numbers rather than
  as civil dates (improves performance creating DateTime instances).
* Added options to TZDataParser to allow generation of specific zones and
  countries.
* Moved TimezonePeriod class to timezone_period.rb.
* New TimezonePeriodList class to store TimezonePeriods for a timezone and
  perform searches for periods.
* Timezones now defined using blocks. TimezonePeriods are only instantiated
  when they are needed. Thanks to Jamis Buck for the suggestion.
* Add options to TZDataParser to allow exclusion of specific zones and 
  countries.
* Exclude the Riyadh Solar Time zones. The rules are only for 1987 to 1989 and
  take a long time to generate and process. Riyadh Solar Time is no longer
  observed.
* The last TimezonePeriod for each Timezone is now written out with an
  unbounded rather than arbitrary end time.
* Construct the Rational offset in TimezonePeriod once when the TimezonePeriod
  is constructed rather than each time it is needed.
* Timezone and Country now keep a cache of loaded instances to avoid running
  require which can be slow on some platforms.
* Updated to tzdata version 2005n.


Version 0.0.4 (tzdata v2005m) - 18-Sep-2005
-------------------------------------------

* Removed debug output accidentally included in the previous release.
* Fixed a bug in the generation of friendly zone identifiers (was inserting
  apostrophes into UTC, GMT, etc).
* Fixed Country <=> operator (was comparing non-existent attribute)
* Fixed Timezone.period_for_local error when period not found.
* Added testcases for Timezone, TimezoneProxy, TimezonePeriod, Country and
  some selected timezones.

  
Version 0.0.3 (tzdata v2005m) - 17-Sep-2005
-------------------------------------------

* Reduced visibility of some methods added in Timezone#setup and Country#setup.
* Added name method to Timezone (returns the identifier).
* Added friendly_identifier method to Timezone. Returns a more friendly version
  of the identifier.
* Added to_s method to Timezone. Returns the friendly identifier.
* Added == and <=> operators to Timezone (compares identifiers).
* Timezone now includes Comparable.
* Added to_s method to Country.
* Added == and <=> operators to Country (compares ISO 3166 country codes).
* Country now includes Comparable.
* New TimezoneProxy class that behaves the same as a Timezone but doesn't
  actually load in its definition until it is actually required.
* Modified Timezone and Country methods that return Timezones to return
  TimezoneProxy instances instead. This makes these methods much quicker.
  
  In Ruby on Rails, you can now show a drop-down list of all timezones using the
  Rails time_zone_select helper method:
  
  <%= time_zone_select 'user', 'time_zone', TZInfo::Timezone.all.sort, :model => TZInfo::Timezone %>


Version 0.0.2 (tzdata v2005m) - 13-Sep-2005 
-------------------------------------------

* Country and Timezone data is now loaded into class rather than instance 
  variables. This makes Timezone links more efficient and saves memory if
  creating specific Timezone and Country classes directly.
* TimezonePeriod zone_identifier is now defined as a symbol to save memory
  (was previously a string).
* TimezonePeriod zone_identifiers that were previously '' are now :Unknown.
* Timezones and Countries can now be returned using Timezone.new(identifier)
  and Country.new(identifier). When passed an identifier, the new method
  calls get to return an instance of the specified timezone or country.
* Added new class methods to Timezone to return sets of zones and identifiers.

Thanks to Scott Barron of Lunchbox Software for the suggestions in his
article about using TZInfo with Rails 
(http://lunchroom.lunchboxsoftware.com/pages/tzinfo_rails)


Version 0.0.1 (tzdata v2005m) - 29-Aug-2005
-------------------------------------------

* First release.
