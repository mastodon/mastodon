## 4.1.2 (2016-11-26)

* RuboCop reformatting

## 4.1.1 (2015-08-21)

* Remove `RubyProf` from Gemfile and a test, due to it providing no substantial benefit while increasing problems building bundles under Rubinius.

## 4.1.0 (2015-08-16)

* Addition of `now_and_every` method; fires block immediately, then sets recurring timer.
* Includes `now_and_after` method; does the same as above for one-shot timers: essentially a "two-shot" timer.

# 4.0.4 (2015-09-01)

* Re-release of the `4.1.1` version under the `4.0.4` designation to work-around issues caused by yanking `4.0.2` a couple weeks ago.

## 4.0.1 (2014-09-10)

* Memory leak fixes
* mathn fix for those crazy enough to use it

## 4.0.0 (2014-07-27)

* Replace Timers::Timeout with Timers::Wait
* Timers::Group#wait_interval now returns nil when no timers, a positive or
  negative interval which if positive is the amount of time required to wait
  and if negative, how far in the past the latest timer should have fired
* Performance improvements

## 3.0.1 (2014-06-27)

* Require 'set' automatically

# 3.0.0 (2014-06-14)

* Refactor `Timers` class into `Timers::Group`
* Add `Timers::Timeout` class for implementing timeouts
* Fix timer fudging
* Update to RSpec 3

## 2.0.0 (2013-12-30)

* Switch to Hitimes for high precision monotonic counters
* Removed Timers#time. Replaced with Timers#current_offset which provides a
  monotonic time counter.

## 1.1.0

* Timers#after_milliseconds and #after_ms for waiting in milliseconds

## 1.0.2

* Handle overdue timers correctly

## 1.0.1

* Explicitly require Forwardable from stdlib

## 1.0.0

* Initial release
