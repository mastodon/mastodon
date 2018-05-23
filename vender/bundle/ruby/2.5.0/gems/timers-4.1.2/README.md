# Timers for Ruby [![Gem Version][gem-image]][gem-link] [![Build Status][build-image]][build-link] [![Code Climate][codeclimate-image]][codeclimate-link] [![Coverage Status][coverage-image]][coverage-link] [![MIT licensed][license-image]][license-link]

[gem-image]: https://badge.fury.io/rb/timers.svg
[gem-link]: http://rubygems.org/gems/timers
[build-image]: https://secure.travis-ci.org/celluloid/timers.svg?branch=master
[build-link]: https://travis-ci.org/celluloid/timers
[codeclimate-image]: https://codeclimate.com/github/celluloid/timers.svg
[codeclimate-link]: https://codeclimate.com/github/celluloid/timers
[coverage-image]: https://coveralls.io/repos/celluloid/timers/badge.svg?branch=master
[coverage-link]: https://coveralls.io/r/celluloid/timers
[license-image]: https://img.shields.io/badge/license-MIT-blue.svg
[license-link]: https://github.com/celluloid/timers/master/LICENSE.txt

Collections of one-shot and periodic timers, intended for use with event loops.

**Does not require Celluloid!** Though this gem was originally written
to provide the timer subsystem for [Celluloid], it can be used independently
in any sort of event loop context, or can provide a purely timer-based event
loop itself.

[Celluloid]: https://github.com/celluloid/celluloid/

## Supported platforms

* Ruby 2.0, 2.1, 2.2, and 2.3
* JRuby 9000

## Usage

Create a new timer group with `Timers::Group.new`:

```ruby
require 'timers'

timers = Timers::Group.new
```

Schedule a proc to run after 5 seconds with `Timers::Group#after`:

```ruby
five_second_timer = timers.after(5) { puts "Take five" }
```

The `five_second_timer` variable is now bound to a Timers::Timer object. To
cancel a timer, use `Timers::Timer#cancel`

Once you've scheduled a timer, you can wait until the next timer fires with `Timers::Group#wait`:

```ruby
# Waits 5 seconds
timers.wait

# The script will now print "Take five"
```

You can schedule a block to run periodically with `Timers::Group#every`:

```ruby
every_five_seconds = timers.every(5) { puts "Another 5 seconds" }

loop { timers.wait }
```

You can also schedule a block to run immediately and periodically with `Timers::Group#now_and_every`:
```ruby
now_and_every_five_seconds = timers.now_and_every(5) { puts "Now and in another 5 seconds" }

loop { timers.wait }
```

If you'd like another method to do the waiting for you, e.g. `Kernel.select`,
you can use `Timers::Group#wait_interval` to obtain the amount of time to wait. When
a timeout is encountered, you can fire all pending timers with `Timers::Group#fire`:

```ruby
loop do
  interval = timers.wait_interval
  ready_readers, ready_writers = select readers, writers, nil, interval

  if ready_readers || ready_writers
    # Handle IO
    ...
  else
    # Timeout!
    timers.fire
  end
end
```

You can also pause and continue individual timers, or all timers:

```ruby
paused_timer = timers.every(5) { puts "I was paused" }

paused_timer.pause
10.times { timers.wait } # will not fire paused timer

paused_timer.resume
10.times { timers.wait } # will fire timer

timers.pause
10.times { timers.wait } # will not fire any timers

timers.resume
10.times { timers.wait } # will fire all timers
```

## License

Copyright (c) 2012-2016 Celluloid timers project developers (given in the file
AUTHORS.md).

Distributed under the MIT License. See LICENSE file for further details.
