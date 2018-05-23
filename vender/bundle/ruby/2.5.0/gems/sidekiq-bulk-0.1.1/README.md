# sidekiq-bulk

[![Build Status](https://travis-ci.org/aprescott/sidekiq-bulk.svg?branch=master)](https://travis-ci.org/aprescott/sidekiq-bulk) [![Code Climate](https://codeclimate.com/github/aprescott/sidekiq-bulk/badges/gpa.svg)](https://codeclimate.com/github/aprescott/sidekiq-bulk)

Give your workers more to do!

Augments Sidekiq job classes with a `push_bulk` method for easier bulk pushing.

Sidekiq comes with `Sidekiq::Client.push_bulk` which can be faster than `perform_async` if you have lots and lots of jobs to enqueue.

This gem provides a wrapper around `Sidekiq::Client.push_bulk` so that instead of

```ruby
Sidekiq::Client.push_bulk("class" => FooJob, "args" => [[1], [2], [3]])
```

You can write

```ruby
FooJob.push_bulk([1, 2, 3])
```

More stuff is supported!

### Installing

With Bundler:

```ruby
# in Gemfile
gem "sidekiq-bulk"
```

Either `require "sidekiq-bulk"` or `require "sidekiq/bulk"`.

### To use

To enqueue a job for each element of an array:

```ruby
# enqueues 3 jobs for FooJob, each with 1 argument
FooJob.push_bulk([1, 2, 3])

# equivalent to:
Sidekiq::Client.push_bulk("class" => FooJob, "args" => [[1], [2], [3]])

# which is a more efficient version of
[1, 2, 3].each do |i|
  FooJob.perform_async(i)
end
```

To enqueue jobs with more than one argument:

```ruby
FooJob.push_bulk(all_users) do |user|
  [user.id, "foobar"]
end

# enqueues one job for each element of `all_users`, where each job
# has two arguments: the user ID and the string "foobar".
#
# equivalent to, but faster than:

all_users.each do |user|
  FooJob.perform_async(user.id, "foobar")
end
```

## Job count splitting

`push_bulk` will only enqueue at most 10,000 jobs at a time. That is, if `items` has 20,000 elements, `push_bulk(items)` will push the first 10,000, then the second 20,000. You can control the threshold with `limit:`.

```ruby
# push in groups of 50,000 jobs at a time
FooJob.push_bulk(items, limit: 50_000)

# equivalent to FooJob.push_bulk(items, limit: 10_000)
FooJob.push_bulk(items)
```

This also works with a block.

```ruby
# this results in 5 pushes

users.length # => 100_000
FooJob.push_bulk(users, limit: 20_000) do |user|
  [user.id, "some-value"]
end
```

And to disable push splitting, use `push_bulk!`.

```ruby
# one single push of 500,000 jobs, no splitting

users.length # => 500_000
FooJob.push_bulk!(users) do |user|
  [user.id, "some-value"]
end
```

### License

Copyright (c) 2015 Adam Prescott, licensed under the MIT license. See LICENSE.

### Development

Issues (bugs, questions, etc.) should be opened with [the GitHub project](https://github.com/aprescott/sidekiq-bulk).

To contribute changes:

1. Visit the [GitHub repository for `sidekiq-bulk`](https://github.com/aprescott/sidekiq-bulk).
2. [Fork the repository](https://help.github.com/articles/fork-a-repo).
3. Make new feature branch: `git checkout -b master new-feature` (do not add on top of `master`!)
4. Implement the feature, along with tests.
5. [Send a pull request](https://help.github.com/articles/fork-a-repo).

Make sure to `bundle install`.

Tests live in `spec/`. Run them with `bundle exec rspec`.

To run tests against various Sidekiq versions, use `appraisal rspec`, after `appraisal bundle` if necessary. (See the [Appraisal](https://github.com/thoughtbot/appraisal) project and the `Appraisals` file for more details.)
