
# rufus-scheduler

[![Build Status](https://secure.travis-ci.org/jmettraux/rufus-scheduler.svg)](http://travis-ci.org/jmettraux/rufus-scheduler)
[![Gem Version](https://badge.fury.io/rb/rufus-scheduler.svg)](http://badge.fury.io/rb/rufus-scheduler)

Job scheduler for Ruby (at, cron, in and every jobs).

It uses threads.

**Note**: maybe are you looking for the [README of rufus-scheduler 2.x](https://github.com/jmettraux/rufus-scheduler/blob/two/README.rdoc)? (especially if you're using [Dashing](https://github.com/Shopify/dashing) which is [stuck](https://github.com/Shopify/dashing/blob/master/dashing.gemspec) on rufus-scheduler 2.0.24)

Quickstart:
```ruby
# quickstart.rb

require 'rufus-scheduler'

scheduler = Rufus::Scheduler.new

scheduler.in '3s' do
  puts 'Hello... Rufus'
end

scheduler.join
  # let the current thread join the scheduler thread
```
(run with `ruby quickstart.rb`)

Various forms of scheduling are supported:
```ruby
require 'rufus-scheduler'

scheduler = Rufus::Scheduler.new

# ...

scheduler.in '10d' do
  # do something in 10 days
end

scheduler.at '2030/12/12 23:30:00' do
  # do something at a given point in time
end

scheduler.every '3h' do
  # do something every 3 hours
end

scheduler.cron '5 0 * * *' do
  # do something every day, five minutes after midnight
  # (see "man 5 crontab" in your terminal)
end

# ...
```

## non-features

Rufus-scheduler (out of the box) is an in-process, in-memory scheduler. It uses threads.

It does not persist your schedules. When the process is gone and the scheduler instance with it, the schedules are gone.

A rufus-scheduler instance will go on scheduling while it is present among the object in a Ruby process. To make it stop scheduling you have to call its [`#shutdown` method](#schedulershutdown).


## related and similar gems

* [Whenever](https://github.com/javan/whenever) - let cron call back your Ruby code, trusted and reliable cron drives your schedule
* [Clockwork](https://github.com/Rykian/clockwork) - rufus-scheduler inspired gem
* [Crono](https://github.com/plashchynski/crono) - an in-Rails cron scheduler
* [PerfectSched](https://github.com/treasure-data/perfectsched) - highly available distributed cron built on [Sequel](http://sequel.jeremyevans.net) and more

(please note: rufus-scheduler is not a cron replacement)


## note about the 3.0 line

It's a complete rewrite of rufus-scheduler.

There is no EventMachine-based scheduler anymore.


## I don't know what this Ruby thing is, where are my Rails?

I'll drive you right to the [tracks](#so-rails).


## Notable changes:

* As said, no more EventMachine-based scheduler
* ```scheduler.every('100') {``` will schedule every 100 seconds (previously, it would have been 0.1s). This aligns rufus-scheduler on Ruby's ```sleep(100)```
* The scheduler isn't catching the whole of Exception anymore, only StandardError
* The error_handler is [#on_error](#rufusscheduleron_errorjob-error) (instead of #on_exception), by default it now prints the details of the error to $stderr (used to be $stdout)
* Rufus::Scheduler::TimeOutError renamed to Rufus::Scheduler::TimeoutError
* Introduction of "interval" jobs. Whereas "every" jobs are like "every 10 minutes, do this", interval jobs are like "do that, then wait for 10 minutes, then do that again, and so on"
* Introduction of a :lockfile => true/filename mechanism to prevent multiple schedulers from executing
* "discard_past" is on by default. If the scheduler (its host) sleeps for 1 hour and a ```every '10m'``` job is on, it will trigger once at wakeup, not 6 times (discard_past was false by default in rufus-scheduler 2.x). No intention to re-introduce ```:discard_past => false``` in 3.0 for now.
* Introduction of Scheduler #on_pre_trigger and #on_post_trigger callback points


## getting help

So you need help. People can help you, but first help them help you, and don't waste their time. Provide a complete description of the issue. If it works on A but not on B and others have to ask you: "so what is different between A and B" you are wasting everyone's time.

"hello", "please" and "thanks" are not swear words.

Go read [how to report bugs effectively](http://www.chiark.greenend.org.uk/~sgtatham/bugs.html), twice.

Update: [help_help.md](https://gist.github.com/jmettraux/310fed75f568fd731814) might help help you.

### on IRC

I sometimes haunt #ruote on freenode.net. The channel is not dedicated to rufus-scheduler, so if you ask a question, first mention it's about rufus-scheduler.

Please note that I prefer helping over Stack Overflow because it's more searchable than the ruote IRC archive.

### issues

Yes, issues can be reported in [rufus-scheduler issues](https://github.com/jmettraux/rufus-scheduler/issues), I'd actually prefer bugs in there. If there is nothing wrong with rufus-scheduler, a [Stack Overflow question](http://stackoverflow.com/questions/ask?tags=rufus-scheduler+ruby) is better.

### faq

* [It doesn't work...](http://www.chiark.greenend.org.uk/~sgtatham/bugs.html)
* [I want a refund](http://blog.nodejitsu.com/getting-refunds-on-open-source-projects)
* [Passenger and rufus-scheduler](http://stackoverflow.com/questions/18108719/debugging-rufus-scheduler/18156180#18156180)
* [Passenger and rufus-scheduler (2)](http://stackoverflow.com/questions/21861387/rufus-cron-job-not-working-in-apache-passenger#answer-21868555)
* [Passenger in-depth spawn methods](https://www.phusionpassenger.com/library/indepth/ruby/spawn_methods/)
* [Passenger in-depth spawn methods (smart spawning)](https://www.phusionpassenger.com/library/indepth/ruby/spawn_methods/#smart-spawning-hooks)
* [The scheduler comes up when running the Rails console or a Rake task](https://github.com/jmettraux/rufus-scheduler#avoid-scheduling-when-running-the-ruby-on-rails-console)
* [I don't get any of this, I just want it to work in my Rails application](#so-rails)
* [I get "zotime.rb:41:in `initialize': cannot determine timezone from nil"](#i-get-zotimerb41in-initialize-cannot-determine-timezone-from-nil)


## scheduling

Rufus-scheduler supports five kinds of jobs. in, at, every, interval and cron jobs.

Most of the rufus-scheduler examples show block scheduling, but it's also OK to schedule handler instances or handler classes.

### in, at, every, interval, cron

In and at jobs trigger once.

```ruby
require 'rufus-scheduler'

scheduler = Rufus::Scheduler.new

scheduler.in '10d' do
  puts "10 days reminder for review X!"
end

scheduler.at '2014/12/24 2000' do
  puts "merry xmas!"
end
```

In jobs are scheduled with a time interval, they trigger after that time elapsed. At jobs are scheduled with a point in time, they trigger when that point in time is reached (better to choose a point in the future).

Every, interval and cron jobs trigger repeatedly.

```ruby
require 'rufus-scheduler'

scheduler = Rufus::Scheduler.new

scheduler.every '3h' do
  puts "change the oil filter!"
end

scheduler.interval '2h' do
  puts "thinking..."
  puts sleep(rand * 1000)
  puts "thought."
end

scheduler.cron '00 09 * * *' do
  puts "it's 9am! good morning!"
end
```

Every jobs try hard to trigger following the frequency they were scheduled with.

Interval jobs, trigger, execute and then trigger again after the interval elapsed. (every jobs time between trigger times, interval jobs time between trigger termination and the next trigger start).

Cron jobs are based on the venerable cron utility (```man 5 crontab```). They trigger following a pattern given in (almost) the same language cron uses.

####

### #schedule_x vs #x

schedule_in, schedule_at, schedule_cron, etc will return the new Job instance.

in, at, cron will return the new Job instance's id (a String).

```ruby
job_id =
  scheduler.in '10d' do
    # ...
  end
job = scheduler.job(job_id)

# versus

job =
  scheduler.schedule_in '10d' do
    # ...
  end

# also

job =
  scheduler.in '10d', :job => true do
    # ...
  end
```

### #schedule and #repeat

Sometimes it pays to be less verbose.

The ```#schedule``` methods schedules an at, in or cron job. It just decide based on its input. It returns the Job instance.

```ruby
scheduler.schedule '10d' do; end.class
  # => Rufus::Scheduler::InJob

scheduler.schedule '2013/12/12 12:30' do; end.class
  # => Rufus::Scheduler::AtJob

scheduler.schedule '* * * * *' do; end.class
  # => Rufus::Scheduler::CronJob
```

The ```#repeat``` method schedules and returns an EveryJob or a CronJob.

```ruby
scheduler.repeat '10d' do; end.class
  # => Rufus::Scheduler::EveryJob

scheduler.repeat '* * * * *' do; end.class
  # => Rufus::Scheduler::CronJob
```

(Yes, no combination heres gives back an IntervalJob).

### schedule blocks arguments (job, time)

A schedule block may be given 0, 1 or 2 arguments.

The first argument is "job", it's simple the Job instance involved. It might be useful if the job is to be unscheduled for some reason.

```ruby
scheduler.every '10m' do |job|

  status = determine_pie_status

  if status == 'burnt' || status == 'cooked'
    stop_oven
    takeout_pie
    job.unschedule
  end
end
```

The second argument is "time", it's the time when the job got cleared for triggering (not Time.now).

Note that time is the time when the job got cleared for triggering. If there are mutexes involved, now = mutex_wait_time + time...

#### "every" jobs and changing the next_time in-flight

It's OK to change the next_time of an every job in-flight:

```ruby
scheduler.every '10m' do |job|

  # ...

  status = determine_pie_status

  job.next_time = Time.now + 30 * 60 if status == 'burnt'
    #
    # if burnt, wait 30 minutes for the oven to cool a bit
end
```

It should work as well with cron jobs, not so with interval jobs whose next_time is computed after their block ends its current run.

### scheduling handler instances

It's OK to pass any object, as long as it respond to #call(), when scheduling:

```ruby
class Handler
  def self.call(job, time)
    p "- Handler called for #{job.id} at #{time}"
  end
end

scheduler.in '10d', Handler

# or

class OtherHandler
  def initialize(name)
    @name = name
  end
  def call(job, time)
    p "* #{time} - Handler #{name.inspect} called for #{job.id}"
  end
end

oh = OtherHandler.new('Doe')

scheduler.every '10m', oh
scheduler.in '3d5m', oh
```

The call method must accept 2 (job, time), 1 (job) or 0 arguments.

Note that time is the time when the job got cleared for triggering. If there are mutexes involved, now = mutex_wait_time + time...

### scheduling handler classes

One can pass a handler class to rufus-scheduler when scheduling. Rufus will instantiate it and that instance will be available via job#handler.

```ruby
class MyHandler
  attr_reader :count
  def initialize
    @count = 0
  end
  def call(job)
    @count += 1
    puts ". #{self.class} called at #{Time.now} (#{@count})"
  end
end

job = scheduler.schedule_every '35m', MyHandler

job.handler
  # => #<MyHandler:0x000000021034f0>
job.handler.count
  # => 0
```

If you want to keep that "block feeling":

```ruby
job_id =
  scheduler.every '10m', Class.new do
    def call(job)
      puts ". hello #{self.inspect} at #{Time.now}"
    end
  end
```


## pause and resume the scheduler

The scheduler can be paused via the #pause and #resume methods. One can determine if the scheduler is currently paused by calling #paused?.

While paused, the scheduler still accepts schedules, but no schedule will get triggered as long as #resume isn't called.


## job options

### :blocking => true

By default, jobs are triggered in their own, new thread. When :blocking => true, the job is triggered in the scheduler thread (a new thread is not created). Yes, while the job triggers, the scheduler is not scheduling.

### :overlap => false

Since, by default, jobs are triggered in their own new thread, job instances might overlap. For example, a job that takes 10 minutes and is scheduled every 7 minutes will have overlaps.

To prevent overlap, one can set :overlap => false. Such a job will not trigger if one of its instance is already running.

The `:overlap` option is considered before the `:mutex` option when the scheduler is reviewing jobs for triggering.

### :mutex => mutex_instance / mutex_name / array of mutexes

When a job with a mutex triggers, the job's block is executed with the mutex around it, preventing other jobs with the same mutex to enter (it makes the other jobs wait until it exits the mutex).

This is different from :overlap => false, which is, first, limited to instances of the same job, and, second, doesn't make the incoming job instance block/wait but give up.

:mutex accepts a mutex instance or a mutex name (String). It also accept an array of mutex names / mutex instances. It allows for complex relations between jobs.

Array of mutexes: original idea and implementation by [Rainux Luo](https://github.com/rainux)

Warning: creating lots of different mutexes is OK. Rufus-scheduler will place them in its Scheduler#mutexes hash... And they won't get garbage collected.

The `:overlap` option is considered before the `:mutex` option when the scheduler is reviewing jobs for triggering.

### :timeout => duration or point in time

It's OK to specify a timeout when scheduling some work. After the time specified, it gets interrupted via a Rufus::Scheduler::TimeoutError.

```ruby
scheduler.in '10d', :timeout => '1d' do
  begin
    # ... do something
  rescue Rufus::Scheduler::TimeoutError
    # ... that something got interrupted after 1 day
  end
end
```

The :timeout option accepts either a duration (like "1d" or "2w3d") or a point in time (like "2013/12/12 12:00").

### :first_at, :first_in, :first, :first_time

This option is for repeat jobs (cron / every) only.

It's used to specify the first time after which the repeat job should trigger for the first time.

In the case of an "every" job, this will be the first time (modulo the scheduler frequency) the job triggers.
For a "cron" job, it's the time *after* which the first schedule will trigger.

```ruby
scheduler.every '2d', :first_at => Time.now + 10 * 3600 do
  # ... every two days, but start in 10 hours
end

scheduler.every '2d', :first_in => '10h' do
  # ... every two days, but start in 10 hours
end

scheduler.cron '00 14 * * *', :first_in => '3d' do
  # ... every day at 14h00, but start after 3 * 24 hours
end
```

:first, :first_at and :first_in all accept a point in time or a duration (number or time string). Use the symbol you think make your schedule more readable.

Note: it's OK to change the first_at (a Time instance) directly:
```ruby
job.first_at = Time.now + 10
job.first_at = Rufus::Scheduler.parse('2029-12-12')
```

The first argument (in all its flavours) accepts a :now or :immediately value. That schedules the first occurrence for immediate triggering. Consider:

```ruby
require 'rufus-scheduler'

s = Rufus::Scheduler.new

n = Time.now; p [ :scheduled_at, n, n.to_f ]

s.every '3s', :first => :now do
  n = Time.now; p [ :in, n, n.to_f ]
end

s.join

```

that'll output something like:

```
[:scheduled_at, 2014-01-22 22:21:21 +0900, 1390396881.344438]
[:in, 2014-01-22 22:21:21 +0900, 1390396881.6453865]
[:in, 2014-01-22 22:21:24 +0900, 1390396884.648807]
[:in, 2014-01-22 22:21:27 +0900, 1390396887.651686]
[:in, 2014-01-22 22:21:30 +0900, 1390396890.6571937]
...
```

### :last_at, :last_in, :last

This option is for repeat jobs (cron / every) only.

It indicates the point in time after which the job should unschedule itself.

```ruby
scheduler.cron '5 23 * * *', :last_in => '10d' do
  # ... do something every evening at 23:05 for 10 days
end

scheduler.every '10m', :last_at => Time.now + 10 * 3600 do
  # ... do something every 10 minutes for 10 hours
end

scheduler.every '10m', :last_in => 10 * 3600 do
  # ... do something every 10 minutes for 10 hours
end
```
:last, :last_at and :last_in all accept a point in time or a duration (number or time string). Use the symbol you think make your schedule more readable.

Note: it's OK to change the last_at (nil or a Time instance) directly:
```ruby
job.last_at = nil
  # remove the "last" bound

job.last_at = Rufus::Scheduler.parse('2029-12-12')
  # set the last bound
```

### :times => nb of times (before auto-unscheduling)

One can tell how many times a repeat job (CronJob or EveryJob) is to execute before unscheduling by itself.

```ruby
scheduler.every '2d', :times => 10 do
  # ... do something every two days, but not more than 10 times
end

scheduler.cron '0 23 * * *', :times => 31 do
  # ... do something every day at 23:00 but do it no more than 31 times
end
```

It's OK to assign nil to :times to make sure the repeat job is not limited. It's useful when the :times is determined at scheduling time.

```ruby
scheduler.cron '0 23 * * *', :times => nolimit ? nil : 10 do
  # ...
end
```

The value set by :times is accessible in the job. It can be modified anytime.

```ruby
job =
  scheduler.cron '0 23 * * *' do
    # ...
  end

# later on...

job.times = 10
  # 10 days and it will be over
```


## Job methods

When calling a schedule method, the id (String) of the job is returned. Longer schedule methods return Job instances directly. Calling the shorter schedule methods with the :job => true also return Job instances instead of Job ids (Strings).

```ruby
  require 'rufus-scheduler'

  scheduler = Rufus::Scheduler.new

  job_id =
    scheduler.in '10d' do
      # ...
    end

  job =
    scheduler.schedule_in '1w' do
      # ...
    end

  job =
    scheduler.in '1w', :job => true do
      # ...
    end
```

Those Job instances have a few interesting methods / properties:

### id, job_id

Returns the job id.

```ruby
job = scheduler.schedule_in('10d') do; end
job.id
  # => "in_1374072446.8923042_0.0_0"
```

### scheduler

Returns the scheduler instance itself.

### opts

Returns the options passed at the Job creation.

```ruby
job = scheduler.schedule_in('10d', :tag => 'hello') do; end
job.opts
  # => { :tag => 'hello' }
```

### original

Returns the original schedule.

```ruby
job = scheduler.schedule_in('10d', :tag => 'hello') do; end
job.original
  # => '10d'
```

### callable, handler

callable() returns the scheduled block (or the call method of the callable object passed in lieu of a block)

handler() returns nil if a block was scheduled and the instance scheduled else.

```ruby
# when passing a block

job =
  scheduler.schedule_in('10d') do
    # ...
  end

job.handler
  # => nil
job.callable
  # => #<Proc:0x00000001dc6f58@/home/jmettraux/whatever.rb:115>
```
and

```ruby
# when passing something else than a block

class MyHandler
  attr_reader :counter
  def initialize
    @counter = 0
  end
  def call(job, time)
    @counter = @counter + 1
  end
end

job = scheduler.schedule_in('10d', MyHandler.new)

job.handler
  # => #<Method: MyHandler#call>
job.callable
  # => #<MyHandler:0x0000000163ae88 @counter=0>
```

### scheduled_at

Returns the Time instance when the job got created.

```ruby
job = scheduler.schedule_in('10d', :tag => 'hello') do; end
job.scheduled_at
  # => 2013-07-17 23:48:54 +0900
```

### last_time

Returns the last time the job triggered (is usually nil for AtJob and InJob).
```ruby
job = scheduler.schedule_every('10s') do; end

job.scheduled_at
  # => 2013-07-17 23:48:54 +0900
job.last_time
  # => nil (since we've just scheduled it)

# after 10 seconds

job.scheduled_at
  # => 2013-07-17 23:48:54 +0900 (same as above)
job.last_time
  # => 2013-07-17 23:49:04 +0900
```

### previous_time

Returns the previous `#next_time`
```ruby
scheduler.every('10s') do |job|
  puts "job scheduled for #{job.previous_time} triggered at #{Time.now}"
  puts "next time will be around #{job.next_time}"
  puts "."
end
```

### last_work_time, mean_work_time

The job keeps track of how long its work was in the `last_work_time` attribute. For a one time job (in, at) it's probably not very useful.

The attribute `mean_work_time` contains a computed mean work time. It's recomputed after every run (if it's a repeat job).

### unschedule

Unschedule the job, preventing it from firing again and removing it from the schedule. This doesn't prevent a running thread for this job to run until its end.

### threads

Returns the list of threads currently "hosting" runs of this Job instance.

### kill

Interrupts all the work threads currently running for this job instance. They discard their work and are free for their next run (of whatever job).

Note: this doesn't unschedule the Job instance.

Note: if the job is pooled for another run, a free work thread will probably pick up that next run and the job will appear as running again. You'd have to unschedule and kill to make sure the job doesn't run again.

### running?

Returns true if there is at least one running Thread hosting a run of this Job instance.

### scheduled?

Returns true if the job is scheduled (is due to trigger). For repeat jobs it should return true until the job gets unscheduled. "at" and "in" jobs will respond with false as soon as they start running (execution triggered).

### pause, resume, paused?, paused_at

These four methods are only available to CronJob, EveryJob and IntervalJob instances. One can pause or resume such a job thanks to them.

```ruby
job =
  scheduler.schedule_every('10s') do
    # ...
  end

job.pause
  # => 2013-07-20 01:22:22 +0900
job.paused?
  # => true
job.paused_at
  # => 2013-07-20 01:22:22 +0900

job.resume
  # => nil
```

### tags

Returns the list of tags attached to this Job instance.

By default, returns an empty array.

```ruby
job = scheduler.schedule_in('10d') do; end
job.tags
  # => []

job = scheduler.schedule_in('10d', :tag => 'hello') do; end
job.tags
  # => [ 'hello' ]
```

### []=, [], key? and keys

Threads have thread-local variables. Rufus-scheduler jobs have job-local variables.

```ruby
job =
  @scheduler.schedule_every '1s' do |job|
    job[:timestamp] = Time.now.to_f
    job[:counter] ||= 0
    job[:counter] += 1
  end

sleep 3.6

job[:counter]
  # => 3

job.key?(:timestamp)
  # => true
job.keys
  # => [ :timestamp, :counter ]
```

Job-local variables are thread-safe.

### call

Job instances have a #call method. It simply calls the scheduled block or callable immediately.

```ruby
job =
  @scheduler.schedule_every '10m' do |job|
    # ...
  end

job.call
```

Warning: the Scheduler[#on_error](#rufusscheduleron_errorjob-error) handler is not involved. Error handling is the responsibility of the caller.

If the call has to be rescued by the error handler of the scheduler, ```call(true)``` might help:

```ruby
require 'rufus-scheduler'

s = Rufus::Scheduler.new

def s.on_error(job, err)
  p [ 'error in scheduled job', job.class, job.original, err.message ]
rescue
  p $!
end

job =
  s.schedule_in('1d') do
    fail 'again'
  end

job.call(true)
  #
  # true lets the error_handler deal with error in the job call
```

## AtJob and InJob methods

### time

Returns when the job will trigger (hopefully).

### next_time

An alias to time.

## EveryJob, IntervalJob and CronJob methods

### next_time

Returns the next time the job will trigger (hopefully).

### count

Returns how many times the job fired.

## EveryJob methods

### frequency

It returns the scheduling frequency. For a job scheduled "every 20s", it's 20.

It's used to determine if the job frequency is higher than the scheduler frequency (it raises an ArgumentError if that is the case).

## IntervalJob methods

### interval

Returns the interval scheduled between each execution of the job.

Every jobs use a time duration between each start of their execution, while interval jobs use a time duration between the end of an execution and the start of the next.

## CronJob methods

### frequency

It returns the shortest interval of time between two potential occurrences of the job.

For instance:
```ruby
Rufus::Scheduler.parse('* * * * *').frequency         # ==> 60
Rufus::Scheduler.parse('* * * * * *').frequency       # ==> 1

Rufus::Scheduler.parse('5 23 * * *').frequency        # ==> 24 * 3600
Rufus::Scheduler.parse('5 * * * *').frequency         # ==> 3600
Rufus::Scheduler.parse('10,20,30 * * * *').frequency  # ==> 600

Rufus::Scheduler.parse('10,20,30 * * * * *').frequency  # ==> 10
```

It's used to determine if the job frequency is higher than the scheduler frequency (it raises an ArgumentError if that is the case).

### brute_frequency

Cron jobs also have a ```#brute_frequency``` method that looks a one year of intervals to determine the shortest delta for the cron. This method can take between 20 to 50 seconds for cron lines that go the second level. ```#frequency``` above, when encountering second level cron lines will take a shortcut to answer as quickly as possible with a usable value.


## looking up jobs

### Scheduler#job(job_id)

The scheduler ```#job(job_id)``` method can be used to lookup Job instances.

```ruby
  require 'rufus-scheduler'

  scheduler = Rufus::Scheduler.new

  job_id =
    scheduler.in '10d' do
      # ...
    end

  # later on...

  job = scheduler.job(job_id)
```

### Scheduler #jobs #at_jobs #in_jobs #every_jobs #interval_jobs and #cron_jobs

Are methods for looking up lists of scheduled Job instances.

Here is an example:

```ruby
  #
  # let's unschedule all the at jobs

  scheduler.at_jobs.each(&:unschedule)
```

### Scheduler#jobs(:tag / :tags => x)

When scheduling a job, one can specify one or more tags attached to the job. These can be used to lookup the job later on.

```ruby
  scheduler.in '10d', :tag => 'main_process' do
    # ...
  end
  scheduler.in '10d', :tags => [ 'main_process', 'side_dish' ] do
    # ...
  end

  # ...

  jobs = scheduler.jobs(:tag => 'main_process')
    # find all the jobs with the 'main_process' tag

  jobs = scheduler.jobs(:tags => [ 'main_process', 'side_dish' ]
    # find all the jobs with the 'main_process' AND 'side_dish' tags
```

### Scheduler#running_jobs

Returns the list of Job instance that have currently running instances.

Whereas other "_jobs" method scan the scheduled job list, this method scans the thread list to find the job. It thus comprises jobs that are running but are not scheduled anymore (that happens for at and in jobs).


## misc Scheduler methods

### Scheduler#unschedule(job_or_job_id)

Unschedule a job given directly or by its id.

### Scheduler#shutdown

Shuts down the scheduler, ceases any scheduler/triggering activity.

### Scheduler#shutdown(:wait)

Shuts down the scheduler, waits (blocks) until all the jobs cease running.

### Scheduler#shutdown(:kill)

Kills all the job (threads) and then shuts the scheduler down. Radical.

### Scheduler#down?

Returns true if the scheduler has been shut down.

### Scheduler#started_at

Returns the Time instance at which the scheduler got started.

### Scheduler #uptime / #uptime_s

Returns since the count of seconds for which the scheduler has been running.

```#uptime_s``` returns this count in a String easier to grasp for humans, like ```"3d12m45s123"```.

### Scheduler#join

Let's the current thread join the scheduling thread in rufus-scheduler. The thread comes back when the scheduler gets shut down.

### Scheduler#threads

Returns all the threads associated with the scheduler, including the scheduler thread itself.

### Scheduler#work_threads(query=:all/:active/:vacant)

Lists the work threads associated with the scheduler. The query option defaults to :all.

* :all : all the work threads
* :active : all the work threads currently running a Job
* :vacant : all the work threads currently not running a Job

Note that the main schedule thread will be returned if it is currently running a Job (ie one of those :blocking => true jobs).

### Scheduler#scheduled?(job_or_job_id)

Returns true if the arg is a currently scheduled job (see Job#scheduled?).

### Scheduler#occurrences(time0, time1)

Returns a hash ```{ job => [ t0, t1, ... ] }``` mapping jobs to their potential trigger time within the ```[ time0, time1 ]``` span.

Please note that, for interval jobs, the ```#mean_work_time``` is used, so the result is only a prediction.

### Scheduler#timeline(time0, time1)

Like `#occurrences` but returns a list ```[ [ t0, job0 ], [ t1, job1 ], ... ]``` of time + job pairs.


## dealing with job errors

The easy, job-granular way of dealing with errors is to rescue and deal with them immediately. The two next sections show examples. Skip them for explanations on how to deal with errors at the scheduler level.

### block jobs

As said, jobs could take care of their errors themselves.

```ruby
scheduler.every '10m' do
  begin
    # do something that might fail...
  rescue => e
    $stderr.puts '-' * 80
    $stderr.puts e.message
    $stderr.puts e.stacktrace
    $stderr.puts '-' * 80
  end
end
```

### callable jobs

Jobs are not only shrunk to blocks, here is how the above would look like with a dedicated class.

```ruby
scheduler.every '10m', Class.new do
  def call(job)
    # do something that might fail...
  rescue => e
    $stderr.puts '-' * 80
    $stderr.puts e.message
    $stderr.puts e.stacktrace
    $stderr.puts '-' * 80
  end
end
```

TODO: talk about callable#on_error (if implemented)

(see [scheduling handler instances](#scheduling-handler-instances) and [scheduling handler classes](#scheduling-handler-classes) for more about those "callable jobs")

### Rufus::Scheduler#stderr=

By default, rufus-scheduler intercepts all errors (that inherit from StandardError) and dumps abundent details to $stderr.

If, for example, you'd like to divert that flow to another file (descriptor). You can reassign $stderr for the current Ruby process

```ruby
$stderr = File.open('/var/log/myapplication.log', 'ab')
```

or, you can limit that reassignement to the scheduler itself

```ruby
scheduler.stderr = File.open('/var/log/myapplication.log', 'ab')
```

### Rufus::Scheduler#on_error(job, error)

We've just seen that, by default, rufus-scheduler dumps error information to $stderr. If one needs to completely change what happens in case of error, it's OK to overwrite #on_error

```ruby
def scheduler.on_error(job, error)

  Logger.warn("intercepted error in #{job.id}: #{error.message}")
end
```

On Rails, the `on_error` method redefinition might look like:
```ruby
def scheduler.on_error(job, error)

  Rails.logger.error(
    "err#{error.object_id} rufus-scheduler intercepted #{error.inspect}" +
    " in job #{job.inspect}")
  error.backtrace.each_with_index do |line, i|
    Rails.logger.error(
      "err#{error.object_id} #{i}: #{line}")
  end
end
```

## Rufus::Scheduler #on_pre_trigger and #on_post_trigger callbacks

One can bind callbacks before and after jobs trigger:

```ruby
s = Rufus::Scheduler.new

def s.on_pre_trigger(job, trigger_time)
  puts "triggering job #{job.id}..."
end

def s.on_post_trigger(job, trigger_time)
  puts "triggered job #{job.id}."
end

s.every '1s' do
  # ...
end
```

The ```trigger_time``` is the time at which the job triggers. It might be a bit before ```Time.now```.

Warning: these two callbacks are executed in the scheduler thread, not in the work threads (the threads were the job execution really happens).

### Rufus::Scheduler#on_pre_trigger as a guard

Returning ```false``` in on_pre_trigger will prevent the job from triggering. Returning anything else (nil, -1, true, ...) will let the job trigger.

Note: your business logic should go in the scheduled block itself (or the scheduled instance). Don't put business logic in on_pre_trigger. Return false for admin reasons (backend down, etc) not for business reasons that are tied to the job itself.

```ruby
def s.on_pre_trigger(job, trigger_time)

  return false if Backend.down?

  puts "triggering job #{job.id}..."
end
```

## Rufus::Scheduler.new options

### :frequency

By default, rufus-scheduler sleeps 0.300 second between every step. At each step it checks for jobs to trigger and so on.

The :frequency option lets you change that 0.300 second to something else.

```ruby
scheduler = Rufus::Scheduler.new(:frequency => 5)
```

It's OK to use a time string to specify the frequency.

```ruby
scheduler = Rufus::Scheduler.new(:frequency => '2h10m')
  # this scheduler will sleep 2 hours and 10 minutes between every "step"
```

Use with care.

### :lockfile => "mylockfile.txt"

This feature only works on OSes that support the flock (man 2 flock) call.

Starting the scheduler with ```:lockfile => ".rufus-scheduler.lock"``` will make the scheduler attempt to create and lock the file ```.rufus-scheduler.lock``` in the current working directory. If that fails, the scheduler will not start.

The idea is to guarantee only one scheduler (in a group of scheduler sharing the same lockfile) is running.

This is useful in environments where the Ruby process holding the scheduler gets started multiple times.

If the lockfile mechanism here is not sufficient, you can plug your custom mechanism. It's explained in [advanced lock schemes](#advanced-lock-schemes) below.

### :scheduler_lock

(since rufus-scheduler 3.0.9)

The scheduler lock is an object that responds to `#lock` and `#unlock`. The scheduler calls `#lock` when starting up. If the answer is `false`, the scheduler stops its initialization work and won't schedule anything.

Here is a sample of a scheduler lock that only lets the scheduler on host "coffee.example.com" start:
```ruby
class HostLock
  def initialize(lock_name)
    @lock_name = lock_name
  end
  def lock
    @lock_name == `hostname -f`.strip
  end
  def unlock
    true
  end
end

scheduler =
  Rufus::Scheduler.new(:scheduler_lock => HostLock.new('coffee.example.com'))
```

By default, the scheduler_lock is an instance of `Rufus::Scheduler::NullLock`, with a `#lock` that returns true.

### :trigger_lock

(since rufus-scheduler 3.0.9)

The trigger lock in an object that responds to `#lock`. The scheduler calls that method on the job lock right before triggering any job. If the answer is false, the trigger doesn't happen, the job is not done (at least not in this scheduler).

Here is a (stupid) PingLock example, it'll only trigger if an "other host" is not responding to ping. Do not use that in production, you don't want to fork a ping process for each trigger attempt...
```ruby
class PingLock
  def initialize(other_host)
    @other_host = other_host
  end
  def lock
    ! system("ping -c 1 #{@other_host}")
  end
end

scheduler =
  Rufus::Scheduler.new(:trigger_lock => PingLock.new('main.example.com'))
```

By default, the trigger_lock is an instance of `Rufus::Scheduler::NullLock`, with a `#lock` that always returns true.

As explained in [advanced lock schemes](#advanced-lock-schemes), another way to tune that behaviour is by overriding the scheduler's `#confirm_lock` method. (You could also do that with an `#on_pre_trigger` callback).

### :max_work_threads

In rufus-scheduler 2.x, by default, each job triggering received its own, brand new, thread of execution. In rufus-scheduler 3.x, execution happens in a pooled work thread. The max work thread count (the pool size) defaults to 28.

One can set this maximum value when starting the scheduler.

```ruby
scheduler = Rufus::Scheduler.new(:max_work_threads => 77)
```

It's OK to increase the :max_work_threads of a running scheduler.

```ruby
scheduler.max_work_threads += 10
```


## Rufus::Scheduler.singleton

Do not want to store a reference to your rufus-scheduler instance?
Then ```Rufus::Scheduler.singleton``` can help, it returns a singleon instance of the scheduler, initialized the first time this class method is called.

```ruby
Rufus::Scheduler.singleton.every '10s' { puts "hello, world!" }
```

It's OK to pass initialization arguments (like :frequency or :max_work_threads) but they will only be taken into account the first time ```.singleton``` is called.

```ruby
Rufus::Scheduler.singleton(:max_work_threads => 77)
Rufus::Scheduler.singleton(:max_work_threads => 277) # no effect
```

The ```.s``` is a shortcut for ```.singleton```.

```ruby
Rufus::Scheduler.s.every '10s' { puts "hello, world!" }
```


## advanced lock schemes

As seen above, rufus-scheduler proposes the [:lockfile](#lockfile--mylockfiletxt) system out of the box. If in a group of schedulers only one is supposed to run, the lockfile mecha prevents schedulers that have not set/created the lockfile from running.

There are situation where this is not sufficient.

By overriding #lock and #unlock, one can customize how his schedulers lock.

This example was provided by [Eric Lindvall](https://github.com/eric):

```ruby
class ZookeptScheduler < Rufus::Scheduler

  def initialize(zookeeper, opts={})
    @zk = zookeeper
    super(opts)
  end

  def lock
    @zk_locker = @zk.exclusive_locker('scheduler')
    @zk_locker.lock # returns true if the lock was acquired, false else
  end

  def unlock
    @zk_locker.unlock
  end

  def confirm_lock
    return false if down?
    @zk_locker.assert!
  rescue ZK::Exceptions::LockAssertionFailedError => e
    # we've lost the lock, shutdown (and return false to at least prevent
    # this job from triggering
    shutdown
    false
  end
end
```

This uses a [zookeeper](http://zookeeper.apache.org/) to make sure only one scheduler in a group of distributed schedulers runs.

The methods #lock and #unlock are overridden and #confirm_lock is provided,
to make sure that the lock is still valid.

The #confirm_lock method is called right before a job triggers (if it is provided). The more generic callback #on_pre_trigger is called right after #confirm_lock.

### :scheduler_lock and :trigger_lock

(introduced in rufus-scheduler 3.0.9).

Another way of prodiving `#lock`, `#unlock` and `#confirm_lock` to a rufus-scheduler is by using the `:scheduler_lock` and `:trigger_lock` options.

See [:trigger_lock](#trigger_lock) and [:scheduler_lock](#scheduler_lock).

The scheduler lock may be used to prevent a scheduler from starting, while a trigger lock prevents individual jobs from triggering (the scheduler goes on scheduling).

One has to be careful with what goes in `#confirm_lock` or in a trigger lock, as it gets called before each trigger.

Warning: you may think you're heading towards "high availability" by using a trigger lock and having lots of schedulers at hand. It may be so if you limit yourself to scheduling the same set of jobs at scheduler startup. But if you add schedules at runtime, they stay local to their scheduler. There is no magic that propagates the jobs to all the schedulers in your pack.


## parsing cronlines and time strings

Rufus::Scheduler provides a class method ```.parse``` to parse time durations and cron strings. It's what it's using when receiving schedules. One can use it diectly (no need to instantiate a Scheduler).

```ruby
require 'rufus-scheduler'

Rufus::Scheduler.parse('1w2d')
  # => 777600.0
Rufus::Scheduler.parse('1.0w1.0d')
  # => 777600.0

Rufus::Scheduler.parse('Sun Nov 18 16:01:00 2012').strftime('%c')
  # => 'Sun Nov 18 16:01:00 2012'

Rufus::Scheduler.parse('Sun Nov 18 16:01:00 2012 Europe/Berlin').strftime('%c %z')
  # => 'Sun Nov 18 15:01:00 2012 +0000'

Rufus::Scheduler.parse(0.1)
  # => 0.1

Rufus::Scheduler.parse('* * * * *')
  # => #<Rufus::Scheduler::CronLine:0x00000002be5198
  #        @original="* * * * *", @timezone=nil,
  #        @seconds=[0], @minutes=nil, @hours=nil, @days=nil, @months=nil,
  #        @weekdays=nil, @monthdays=nil>
```

It returns a number when the output is a duration and a CronLine instance when the input is a cron string.

It will raise an ArgumentError if it can't parse the input.

Beyond ```.parse```, there are also ```.parse_cron``` and ```.parse_duration```, for finer granularity.

There is an interesting helper method named ```.to_duration_hash```:

```ruby
require 'rufus-scheduler'

Rufus::Scheduler.to_duration_hash(60)
  # => { :m => 1 }
Rufus::Scheduler.to_duration_hash(62.127)
  # => { :m => 1, :s => 2, :ms => 127 }

Rufus::Scheduler.to_duration_hash(62.127, :drop_seconds => true)
  # => { :m => 1 }
```

### cronline notations specific to rufus-scheduler

#### first Monday, last Sunday et al

To schedule something at noon every first Monday of the month:

```ruby
scheduler.cron('00 12 * * mon#1') do
  # ...
end
```

To schedule something at noon the last Sunday of every month:

```ruby
scheduler.cron('00 12 * * sun#-1') do
  # ...
end
#
# OR
#
scheduler.cron('00 12 * * sun#L') do
  # ...
end
```

Such cronlines can be tested with scripts like:

```ruby
require 'rufus-scheduler'

Time.now
  # => 2013-10-26 07:07:08 +0900
Rufus::Scheduler.parse('* * * * mon#1').next_time
  # => 2013-11-04 00:00:00 +0900
```

#### L (last day of month)

L can be used in the "day" slot:

In this example, the cronline is supposed to trigger every last day of the month at noon:
```ruby
require 'rufus-scheduler'
Time.now
  # => 2013-10-26 07:22:09 +0900
Rufus::Scheduler.parse('00 12 L * *').next_time
  # => 2013-10-31 12:00:00 +0900
```

#### negative day (x days before the end of the month)

It's OK to pass negative values in the "day" slot:
```ruby
scheduler.cron '0 0 -5 * *' do
  # do it at 00h00 5 days before the end of the month...
end
```

Negative ranges (`-10--5-`: 10 days before the end of the month to 5 days before the end of the month) are OK, but mixed positive / negative ranges will raise an `ArgumentError`.

Negative ranges with increments (`-10---2/2`) are accepted as well.

Descending day ranges are not accepted (`10-8` or `-8--10` for example).


## a note about timezones

Cron schedules and at schedules support the specification of a timezone.

```ruby
scheduler.cron '0 22 * * 1-5 America/Chicago' do
  # the job...
end

scheduler.at '2013-12-12 14:00 Pacific/Samoa' do
  puts "it's tea time!"
end

# or even

Rufus::Scheduler.parse("2013-12-12 14:00 Pacific/Saipan")
  # => #<Rufus::Scheduler::ZoTime:0x007fb424abf4e8 @seconds=1386820800.0, @zone=#<TZInfo::DataTimezone: Pacific/Saipan>, @time=nil>
```

### I get "zotime.rb:41:in `initialize': cannot determine timezone from nil"

For when you see an error like:
```
rufus-scheduler/lib/rufus/scheduler/zotime.rb:41:
  in `initialize':
    cannot determine timezone from nil (etz:nil,tnz:"中国标准时间",tzid:nil)
      (ArgumentError)
	from rufus-scheduler/lib/rufus/scheduler/zotime.rb:198:in `new'
	from rufus-scheduler/lib/rufus/scheduler/zotime.rb:198:in `now'
	from rufus-scheduler/lib/rufus/scheduler.rb:561:in `start'
	...
```

It may happen on Windows or on systems that poorly hints to Ruby on which timezone to use. It should be solved by setting explicitly the `ENV['TZ']` before the scheduler instantiation:
```ruby
ENV['TZ'] = 'Asia/Shanghai'
scheduler = Rufus::Scheduler.new
scheduler.every '2s' do
  puts "#{Time.now} Hello #{ENV['TZ']}!"
end
```

On Rails you might want to try with:
```ruby
ENV['TZ'] = Time.zone.name # Rails only
scheduler = Rufus::Scheduler.new
scheduler.every '2s' do
  puts "#{Time.now} Hello #{ENV['TZ']}!"
end
```
(Hat tip to Alexander in [gh-230](https://github.com/jmettraux/rufus-scheduler/issues/230))

Rails sets its timezone under `config/application.rb`.

Rufus-Scheduler 3.3.3 detects the presence of Rails and uses its timezone setting (tested with Rails 4), so setting `ENV['TZ']` should not be necessary.

The value can be determined thanks to [https://en.wikipedia.org/wiki/List_of_tz_database_time_zones](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones).

Use a "continent/city" identifier (for example "Asia/Shanghai"). Do not use an abbreviation (not "CST") and do not use a local time zone name (not "中国标准时间" nor "Eastern Standard Time" which, for instance, points to a time zone in America and to another one in Australia...).

If the error persists (and especially on Windows), try to add the `tzinfo-data` to your Gemfile, as in:
```ruby
gem 'tzinfo-data'
```
or by manually requiring it before requiring rufus-scheduler (if you don't use Bundler):
```ruby
require 'tzinfo/data'
require 'rufus-scheduler'
```


## so Rails?

Yes, I know, all of the above is boring and you're only looking for a snippet to paste in your Ruby-on-Rails application to schedule...

Here is an example initializer:

```ruby
#
# config/initializers/scheduler.rb

require 'rufus-scheduler'

# Let's use the rufus-scheduler singleton
#
s = Rufus::Scheduler.singleton


# Stupid recurrent task...
#
s.every '1m' do

  Rails.logger.info "hello, it's #{Time.now}"
  Rails.logger.flush
end
```

And now you tell me that this is good, but you want to schedule stuff from your controller.

Maybe:

```ruby
class ScheController < ApplicationController

  # GET /sche/
  #
  def index

    job_id =
      Rufus::Scheduler.singleton.in '5s' do
        Rails.logger.info "time flies, it's now #{Time.now}"
      end

    render :text => "scheduled job #{job_id}"
  end
end
```

The rufus-scheduler singleton is instantiated in the ```config/initializers/scheduler.rb``` file, it's then available throughout the webapp via ```Rufus::Scheduler.singleton```.

*Warning*: this works well with single-process Ruby servers like Webrick and Thin. Using rufus-scheduler with Passenger or Unicorn requires a bit more knowledge and tuning, gently provided by a bit of googling and reading, see [Faq](#faq) above.

### avoid scheduling when running the Ruby on Rails console

(Written in reply to https://github.com/jmettraux/rufus-scheduler/issues/186 )

If you don't want rufus-scheduler to kick in when running the Ruby on Rails console or invoking a rake task, you can wrap your initializer in a conditional:

```ruby
#
# config/initializers/scheduler.rb

require 'rufus-scheduler'

s = Rufus::Scheduler.singleton


unless defined?(Rails::Console) || File.split($0).last == 'rake'

  # only schedule when not running from the Ruby on Rails console
  # or from a rake task

  s.every '1m' do

    Rails.logger.info "hello, it's #{Time.now}"
    Rails.logger.flush
  end
end
```

It should work for Ruby on Rails 3 and 4.

### rails server -d

(Written in reply to https://github.com/jmettraux/rufus-scheduler/issues/165 )

There is the handy `rails server -d` that starts a development Rails as a daemon. The annoying thing is that the scheduler as seen above is started in the main process that then gets forked and daemonized. The rufus-scheduler thread (and any other thread) gets lost, no scheduling happens.

I avoid running `-d` in development mode and bother about daemonizing only for production deployment.

These are two well crafted articles on process daemonization, please read them:

* http://www.mikeperham.com/2014/09/22/dont-daemonize-your-daemons/
* http://www.mikeperham.com/2014/07/07/use-runit/

If, anyway, you need something like `rails server -d`, why not try `bundle exec unicorn -D` instead? In my (limited) experience, it worked out of the box (well, had to add `gem 'unicorn'` to `Gemfile` first).


## support

see [getting help](#getting-help) above.


## license

MIT, see [LICENSE.txt](LICENSE.txt)

