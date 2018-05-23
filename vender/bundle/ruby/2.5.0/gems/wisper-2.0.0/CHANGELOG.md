## HEAD (unreleased)

## 2.0.0 (7th Mar 2017)

Authors: Sergey Mostovoy

* fix: logger raises exception if hash is passed as an argument to a listener

## 2.0.0.rc1 (17 Dec 2014)

Authors: Kris Leech

* remove: deprecated methods
* remove: rspec matcher and stubbing (moved to [wisper-rspec](https://github.com/krisleech/wisper-rspec))
* feature: add regexp support to `on` argument
* remove: announce alias for broadcasting
* docs: add Code of Conduct
* drop support for Ruby 1.9

## 1.6.0 (25 Oct 2014)

Authors: Kris Leech

* deprecate: add_listener, add_block_listener and respond_to
* internal: make method naming more consistent

## 1.5.0 (6th Oct 2014)

Authors: Kris Leech

* feature: allow events to be published asynchronously
* feature: broadcasting of events is plugable and configurable
* feature: broadcasters can be aliased via a symbol
* feature: logging broadcaster

## 1.4.0 (8th Sept 2014)

Authors: Kris Leech, Marc Ignacio, Ahmed Abdel Razzak, kmehkeri, Jake Hoffner

* feature: matcher for rspec 3
* fix: temporary global listeners are cleared if an exception is raised
* refactor: update all specs to rspec 3 expect syntax
* docs: update README to rspec 3 expect syntax
* feature: combine global and temporary listener methods as `Wisper.subscribe`
* deprecate: `Wisper.add_listener` and `Wisper.with_listeners,` use `Wisper.subscribe` instead

## 1.3.0 (18th Jan 2014)

Authors: Kris Leech, Yan Pritzker, Charlie Tran

* feature: global subscriptions can be scoped to a class (and sub-classes)
* upgrade: use rspec 3
* feature: allow prefixing of events with 'on'
* feature: Allow stubbed publisher method to accept arbitrary args

## 1.2.1 (7th Oct 2013)

Authors: Kris Leech, Tomasz Szymczyszyn, Alex Heeton

* feature: global subscriptions can be passed options
* docs: improve README examples
* docs: add license to gemspec

## 1.2.0 (21st July 2013)

Authors: Kris Leech, Darren Coxall

* feature: support for multiple events at once
* fix: clear global listeners after each spec

## 1.1.0 (7th June 2013)

Authors: Kris Leech, chatgris

* feature: add temporary global listeners
* docs: improve ActiveRecord example
* refactor: improve specs
* upgrade: add Ruby 2.0 support
* fix: make listener collection immutable
* remove: async publishing and Celluloid dependency
* fix: Make global listeners getter and setter threadsafe [9]

## 1.0.1 (2nd May 2013)

Authors: Kris Leech, Yan Pritzker

* feature: add async publishing using Celluloid
* docs: improve README examples
* feature: `stub_wisper_publisher` rspec helper
* feature: global listeners
* refactor: improve specs

## 1.0.0 (7th April 2013)

Authors: Kris Leech

* refactor: specs
* refactor: registrations
* feature: Add `with` argument to `subscribe`
* docs: improve README examples
* feature: Allow subscriptions to be chainable
* feature: Add `on` syntax for block subscription
* remove: Remove support for Ruby 1.8.7
* docs: Add badges to README

## 0.0.2 (30th March 2013)

Authors: Kris Leech

* remove: ActiveSupport dependency
* docs: fix syntax highlighting in README

## 0.0.1 (30th March 2013)

Authors: Kris Leech

* docs: add README
* feature: registration of objects and blocks
