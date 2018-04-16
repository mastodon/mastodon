TZInfo - Ruby Timezone Library
==============================

[![Gem Version](https://badge.fury.io/rb/tzinfo.svg)](http://badge.fury.io/rb/tzinfo) [![Build Status](https://travis-ci.org/tzinfo/tzinfo.svg?branch=master)](https://travis-ci.org/tzinfo/tzinfo)

[TZInfo](http://tzinfo.github.io) provides daylight savings aware 
transformations between times in different timezones.


Data Sources
------------

TZInfo requires a source of timezone data. There are two built-in options:

1. The TZInfo::Data library (the tzinfo-data gem). TZInfo::Data contains a set 
   of Ruby modules that are generated from the [IANA Time Zone Database](http://www.iana.org/time-zones).
2. A zoneinfo directory. Most Unix-like systems include a zoneinfo directory 
   containing timezone definitions. These are also generated from the 
   [IANA Time Zone Database](http://www.iana.org/time-zones).

By default, TZInfo::Data will be used. If TZInfo::Data is not available (i.e. 
if `require 'tzinfo/data'` fails), then TZInfo will search for a zoneinfo
directory instead (using the search path specified by 
`TZInfo::ZoneinfoDataSource::DEFAULT_SEARCH_PATH`).

If no data source can be found, a `TZInfo::DataSourceNotFound` exception will be
raised when TZInfo is used. Further information is available 
[in the wiki](http://tzinfo.github.io/datasourcenotfound) to help with 
resolving `TZInfo::DataSourceNotFound` errors.

The default data source selection can be overridden using 
`TZInfo::DataSource.set`.

Custom data sources can also be used. See `TZInfo::DataSource.set` for
further details.


Installation
------------

The TZInfo gem can be installed by running:

    gem install tzinfo

To use the Ruby modules as the data source, TZInfo::Data will also need to be
installed:

    gem install tzinfo-data
  

Example Usage
-------------

The following code will obtain the America/New_York timezone (as an instance
of `TZInfo::Timezone`) and convert a time in UTC to local New York time:

    require 'tzinfo'
    
    tz = TZInfo::Timezone.get('America/New_York')
    local = tz.utc_to_local(Time.utc(2005,8,29,15,35,0))

Note that the local Time returned will have a UTC timezone (`local.zone` will 
return `"UTC"`). This is because the Ruby Time class only supports two timezones: 
UTC and the current system local timezone.
  
To convert from a local time to UTC, the `local_to_utc` method can be used as
follows:

    utc = tz.local_to_utc(local)

Note that the timezone information of the local Time object is ignored (TZInfo
will just read the date and time and treat them as if there were in the `tz`
timezone). The following two lines will return the same result regardless of 
the system's local timezone:

    tz.local_to_utc(Time.local(2006,6,26,1,0,0))
    tz.local_to_utc(Time.utc(2006,6,26,1,0,0))
  
To obtain information about the rules in force at a particular UTC or local 
time, the `TZInfo::Timezone.period_for_utc` and 
`TZInfo::Timezone.period_for_local` methods can be used. Both of these methods 
return `TZInfo::TimezonePeriod` objects. The following gets the identifier for 
the period (in this case EDT).

    period = tz.period_for_utc(Time.utc(2005,8,29,15,35,0))
    id = period.zone_identifier
  
The current local time in a `Timezone` can be obtained with the 
`TZInfo::Timezone#now` method:

    now = tz.now

All methods in TZInfo that operate on a time can be used with either `Time` or 
`DateTime` instances or with Integer timestamps (i.e. as returned by 
`Time#to_i`). The type of the values returned will match the type passed in.

A list of all the available timezone identifiers can be obtained using the
`TZInfo::Timezone.all_identifiers` method. `TZInfo::Timezone.all` can be called
to get an `Array` of all the `TZInfo::Timezone` instances.

Timezones can also be accessed by country (using an ISO 3166-1 alpha-2 country 
code). The following code retrieves the `TZInfo::Country` instance representing 
the USA (country code 'US') and then gets all the timezone identifiers used in 
the USA.

    us = TZInfo::Country.get('US')
    timezones = us.zone_identifiers
  
The `TZInfo::Country#zone_info` method provides an additional description and 
geographic location for each timezone in a country.

A list of all the available country codes can be obtained using the
`TZInfo::Country.all_codes` method. `TZInfo::Country.all` can be called to get 
an `Array` of all the `Country` instances.
  
For further detail, please refer to the API documentation for the 
`TZInfo::Timezone` and `TZInfo::Country` classes.


Thread-Safety
-------------

The `TZInfo::Country` and `TZInfo::Timezone` classes are thread-safe. It is safe
to use class and instance methods of `TZInfo::Country` and `TZInfo::Timezone` in 
concurrently executing threads. Instances of both classes can be shared across 
thread boundaries.


Documentation
-------------

API documentation for TZInfo is available on [RubyDoc.info](http://rubydoc.info/gems/tzinfo/frames).


License
-------

TZInfo is released under the MIT license, see LICENSE for details.


Source Code
-----------

Source code for TZInfo is available on [GitHub](https://github.com/tzinfo/tzinfo).


Issue Tracker
-------------

Please post any bugs, issues, feature requests or questions to the 
[GitHub issue tracker](https://github.com/tzinfo/tzinfo/issues).
