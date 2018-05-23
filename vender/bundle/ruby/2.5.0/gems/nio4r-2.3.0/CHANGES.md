## 2.3.0 (2018-03-15)

* [#183](https://github.com/socketry/nio4r/pull/183)
  Allow `Monitor#interests` to be nil
  ([@ioquatix])

## 2.2.0 (2017-12-27)

* [#151](https://github.com/socketry/nio4r/pull/151)
  `NIO::Selector`: Support for enumerating and configuring backend
  ([@tarcieri])

* [#153](https://github.com/socketry/nio4r/pull/153)
  Fix builds on Windows
  ([@unak])

* [#157](https://github.com/socketry/nio4r/pull/157)
  Windows / MinGW test failure - fix spec_helper.rb
  ([@MSP-Greg])

* [#162](https://github.com/socketry/nio4r/pull/162)
  Don't build the C extension on Windows
  ([@larskanis])

* [#164](https://github.com/socketry/nio4r/pull/164)
  Fix NIO::ByteBuffer leak
  ([@HoneyryderChuck])

* [#170](https://github.com/socketry/nio4r/pull/170)
  Avoid CancelledKeyExceptions on JRuby
  ([@HoneyryderChuck])

* [#177](https://github.com/socketry/nio4r/pull/177)
  Fix `NIO::ByteBuffer` string conversions on JRuby
  ([@tarcieri])

* [#179](https://github.com/socketry/nio4r/pull/179)
  Fix argument error when running on ruby 2.5.0
  ([@tompng])

* [#180](https://github.com/socketry/nio4r/pull/180)
  ext/nio4r/extconf.rb: check for port_event_t in port.h (fixes #178)
  ([@tarcieri])

## 2.1.0 (2017-05-28)

* [#130](https://github.com/socketry/nio4r/pull/130)
  Add -fno-strict-aliasing flag when compiling C ext.
  ([@junaruga])
  
* [#146](https://github.com/socketry/nio4r/pull/146)
  Use non-blocking select when a timeout of 0 is given.
  ([@tarcieri])

* [#147](https://github.com/socketry/nio4r/pull/147)
  Update to libev 4.24.
  ([@tarcieri])

* [#148](https://github.com/socketry/nio4r/pull/148)
  Switch to the libev 4 API internally.
  ([@tarcieri])

## 2.0.0 (2016-12-28)

* [#53](https://github.com/socketry/nio4r/pull/53)
  Limit lock scope to prevent recursive locking.
  ([@johnnyt])

* [#95](https://github.com/socketry/nio4r/pull/95)
   NIO::ByteBuffer Google Summer of Code project.
   ([@UpeksheJay], [@tarcieri])

* [#111](https://github.com/socketry/nio4r/pull/111)
  NIO::Selector#backend introspection support.
  ([@tarcieri])

* [#112](https://github.com/socketry/nio4r/pull/112)
  Upgrade to libev 4.23.
  ([@tarcieri])

* [#119](https://github.com/socketry/nio4r/pull/119)
  Disambiguate wakeup vs timeout (fixes #63, #66).
  ([@tarcieri])

* [#124](https://github.com/socketry/nio4r/pull/124)
  Monitor interests API improvements.
  ([@tarcieri])

* Drop Ruby 2.0 and 2.1 support, require Ruby 2.2.2+.
  ([@tarcieri])

## 1.2.1 (2016-01-31)

* Fix bug in the JRuby backend which cases indefinite blocking when small
  timeout values are passed to the selector

## 1.2.0 (2015-12-22)

* Add NIO::Monitor#interests= API for changing interests. Contributed by
  Upekshe Jayasekera as a Google Summer of Code project.
* Update to libev 4.22

## 1.1.1 (2015-07-17)

* Update to libev 4.20
* Fall back to io.h if unistd.h is not found
* RSpec updates
* RuboCop

## 1.1.0 (2015-01-10)

* Update to libev 4.19
* Do not call ev_io_stop on monitors if the loop is already closed

## 1.0.1 (2014-09-01)

* Fix C compiler warnings
* Eliminate Ruby warnings about @lock_holder
* Windows improvements
* Better support for Ruby 2.1
* Automatically require 'set'
* Update to RSpec 3

## 1.0.0 (2014-01-14)

* Have Selector#register obtain the actual IO from a Monitor object
  because Monitor#initialize might convert it.
* Drop 1.8 support

## 0.5.0 (2013-08-06)

* Fix segv when attempting to register to a closed selector
* Fix Windows support on Ruby 2.0.0
* Upgrade to libev 4.15

## 0.4.6 (2013-05-27)

* Fix for JRuby on Windows

## 0.4.5

* Fix botched gem release

## 0.4.4

* Fix return values for Selector_synchronize and Selector_unlock

## 0.4.3

* REALLY have thread synchronization when closing selectors ;)

## 0.4.2

* Attempt to work around packaging problems with bundler-api o_O

## 0.4.1

* Thread synchronization when closing selectors

## 0.4.0

* OpenSSL::SSL::SSLSocket support

## 0.3.3

* NIO::Selector#select_each removed
* Remove event buffer
* Patch GIL unlock directly into libev
* Re-release since 0.3.2 was botched :(

## 0.3.1

* Prevent CancelledKeyExceptions on JRuby

## 0.3.0

* NIO::Selector#select now takes a block and behaves like select_each
* NIO::Selector#select_each is now deprecated and will be removed
* Closing monitors detaches them from their selector
* Java extension for JRuby
* Upgrade to libev 4.11
* Bugfixes for zero/negative select timeouts
* Handle OP_CONNECT properly on JRuby

## 0.2.2

* Raise IOError if asked to wake up a closed selector

## 0.2.1

* Implement wakeup mechanism using raw pipes instead of ev_async, since
  ev_async likes to cause segvs when used across threads (despite claims
  in the documentation to the contrary)

## 0.2.0

* NIO::Monitor#readiness API to query readiness, along with #readable? and
  #writable? helper methods
* NIO::Selector#select_each API which avoids memory allocations if possible
* Bugfixes for the JRuby implementation

## 0.1.0

* Initial release. Merry Christmas!

[@tarcieri]: https://github.com/tarcieri
[@johnnyt]: https://github.com/johnnyt
[@UpeksheJay]: https://github.com/UpeksheJay
[@junaruga]: https://github.com/junaruga
[@unak]: https://github.com/unak
[@MSP-Greg]: https://github.com/MSP-Greg
[@larskanis]: https://github.com/larskanis
[@HoneyryderChuck]: https://github.com/HoneyryderChuck
[@tompng]: https://github.com/tompng
[@ioquatix]: https://github.com/ioquatix
