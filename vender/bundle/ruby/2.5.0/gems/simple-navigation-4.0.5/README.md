# Simple Navigation

[![Gem Version](https://badge.fury.io/rb/simple-navigation.png)](http://badge.fury.io/rb/simple-navigation)
[![Build Status](https://secure.travis-ci.org/codeplant/simple-navigation.png?branch=master)](http://travis-ci.org/codeplant/simple-navigation)
[![Code Climate](https://codeclimate.com/github/codeplant/simple-navigation.png)](https://codeclimate.com/github/codeplant/simple-navigation)
[![Coverage Status](https://coveralls.io/repos/codeplant/simple-navigation/badge.png)](https://coveralls.io/r/codeplant/simple-navigation)

Simple Navigation is a ruby library for creating navigations (with multiple levels) for your Rails, Sinatra or Padrino applications. It runs with all ruby versions (including ruby 2.x).

## Documentation

For the complete documentation, take a look at the [project's wiki](http://wiki.github.com/codeplant/simple-navigation).

## RDoc

You can consult the project's RDoc on [RubyDoc.info](http://rubydoc.info/github/codeplant/simple-navigation/frames).

If you need to generate the RDoc files locally, check out the repository and simply call the `rake rdoc` in the project's folder.

## Online Demo

You can try simple-navigation with the [online demo](http://simple-navigation-demo.codeplant.ch).

The source code of this online demo is [available on Github](http://github.com/codeplant/simple-navigation-demo).

## Feedback and Questions

Don't hesitate to come talk on the [project's group](http://groups.google.com/group/simple-navigation).

## Contributing

Fork, fix, then send a Pull Request.

To run the test suite locally against all supported frameworks:

    % bundle install
    % rake spec:all

To target the test suite against one framework:

    % rake spec:rails-4-2-stable

You can find a list of supported spec tasks by running rake -T. You may also find it useful to run a specific test for a specific framework. To do so, you'll have to first make sure you have bundled everything for that configuration, then you can run the specific test:

% BUNDLE_GEMFILE='gemfiles/rails-4-2-stable.gemfile' bundle install -j 4
% BUNDLE_GEMFILE='gemfiles/rails-4-2-stable.gemfile' bundle exec rspec ./spec/requests/users_spec.rb

### Rake and Bundler

If you use a shell plugin (like oh-my-zsh:bundler) that auto-prefixes commands with `bundle exec` using the `rake` command will fail.

Get the original command with `type -a rake`:

    % type -a rake
    rake is an alias for bundled_rake
    rake is /Users/username/.rubies/ruby-2.2.3/bin/rake
    rake is /usr/bin/rake

In this situation `/Users/username/.rubies/ruby-2.2.3/bin/rake` is the command you should use.

## License

Copyright (c) 2017 codeplant GmbH, released under the MIT license
