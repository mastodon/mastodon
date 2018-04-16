# Welcome to Sidekiq Pro 4.0!

Sidekiq Pro 4.0 is designed to work with Sidekiq 5.0.

## What's New

* Batches now "die" if any of their jobs die.  You can enumerate the set
  of dead batches and their associated dead jobs.  The success callback
  for a dead batch will never fire unless these jobs are fixed.
```ruby
Sidekiq::Batch::DeadSet.new.each do |status|
  status.dead? # => true
  status.dead_jobs # => [...]
end
```
This API allows you to enumerate the batches which need help.
If you fix the issue and the dead jobs succeed, the batch will succeed.
* The older `reliable_fetch` and `timed_fetch` algorithms have been
  removed.  Only super\_fetch is available in 4.0.
* The statsd middleware has been tweaked to remove support for legacy,
  pre-3.6.0 configuration and add relevant tags.
* Requires Sidekiq 5.0.5+.

## Upgrade

* Upgrade to the latest Sidekiq Pro 3.x.
```ruby
gem 'sidekiq-pro', '< 4'
```
* Fix any deprecation warnings you see.
* Upgrade to 4.x.
```ruby
gem 'sidekiq-pro', '< 5'
```

