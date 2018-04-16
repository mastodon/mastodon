# Concurrent Ruby

[![Gem Version](https://badge.fury.io/rb/concurrent-ruby.svg)](http://badge.fury.io/rb/concurrent-ruby)
[![Build Status](https://travis-ci.org/ruby-concurrency/concurrent-ruby.svg?branch=master)](https://travis-ci.org/ruby-concurrency/concurrent-ruby)
[![Build status](https://ci.appveyor.com/api/projects/status/iq8aboyuu3etad4w?svg=true)](https://ci.appveyor.com/project/rubyconcurrency/concurrent-ruby)
[![Code Climate](https://codeclimate.com/github/ruby-concurrency/concurrent-ruby.svg)](https://codeclimate.com/github/ruby-concurrency/concurrent-ruby)
[![Inline docs](http://inch-ci.org/github/ruby-concurrency/concurrent-ruby.svg)](http://inch-ci.org/github/ruby-concurrency/concurrent-ruby)
[![Dependency Status](https://gemnasium.com/ruby-concurrency/concurrent-ruby.svg)](https://gemnasium.com/ruby-concurrency/concurrent-ruby)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](http://opensource.org/licenses/MIT)
[![Gitter chat](https://img.shields.io/badge/IRC%20(gitter)-devs%20%26%20users-brightgreen.svg)](https://gitter.im/ruby-concurrency/concurrent-ruby)

Modern concurrency tools for Ruby. Inspired by
[Erlang](http://www.erlang.org/doc/reference_manual/processes.html),
[Clojure](http://clojure.org/concurrent_programming),
[Scala](http://akka.io/),
[Haskell](http://www.haskell.org/haskellwiki/Applications_and_libraries/Concurrency_and_parallelism#Concurrent_Haskell),
[F#](http://blogs.msdn.com/b/dsyme/archive/2010/02/15/async-and-parallel-design-patterns-in-f-part-3-agents.aspx),
[C#](http://msdn.microsoft.com/en-us/library/vstudio/hh191443.aspx),
[Java](http://docs.oracle.com/javase/7/docs/api/java/util/concurrent/package-summary.html),
and classic concurrency patterns.

<img src="https://raw.githubusercontent.com/ruby-concurrency/concurrent-ruby/master/doc/logo/concurrent-ruby-logo-300x300.png" align="right" style="margin-left: 20px;" />

The design goals of this gem are:

* Be an 'unopinionated' toolbox that provides useful utilities without debating which is better or why
* Remain free of external gem dependencies
* Stay true to the spirit of the languages providing inspiration
* But implement in a way that makes sense for Ruby
* Keep the semantics as idiomatic Ruby as possible
* Support features that make sense in Ruby
* Exclude features that don't make sense in Ruby
* Be small, lean, and loosely coupled

### Supported Ruby versions

MRI 1.9.3, 2.0 and above, JRuby 1.7x in 1.9 mode, JRuby 9000, and Rubinius 2.x are supported.
This gem should be fully compatible with any interpreter that is compliant with Ruby 1.9.3 or newer.
Java 8 is preferred for JRuby but every Java version on which JRuby 9000 runs is supported.

## Thread Safety

*Concurrent Ruby makes the strongest thread safety guarantees of any Ruby concurrency library. We are the only library with a published [memory model](https://github.com/ruby-concurrency/concurrent-ruby/blob/master/doc/synchronization.md) which provides consistent behavior and guarantees on all three of the main Ruby interpreters (MRI/CRuby, JRuby, and Rubinius).*

Every abstraction in this library is thread safe. Similarly, all are deadlock free and many are fully lock free. Specific thread safety guarantees are documented with each abstraction.

It is critical to remember, however, that Ruby is a language of mutable references. *No* concurrency library for Ruby can ever prevent the user from making thread safety mistakes (such as sharing a mutable object between threads and modifying it on both threads) or from creating deadlocks through incorrect use of locks. All the library can do is provide safe abstractions which encourage safe practices. Concurrent Ruby provides more safe concurrency abstractions than any other Ruby library, many of which support the mantra of ["Do not communicate by sharing memory; instead, share memory by communicating"](https://blog.golang.org/share-memory-by-communicating). Concurrent Ruby is also the only Ruby library which provides a full suite of thread safe and immutable variable types and data structures.

## Features & Documentation

The primary site for documentation is the automatically generated [API documentation](http://ruby-concurrency.github.io/concurrent-ruby/frames.html)

We also have a [mailing list](http://groups.google.com/group/concurrent-ruby) and [IRC (gitter)](https://gitter.im/ruby-concurrency/concurrent-ruby).

#### General-purpose Concurrency Abstractions

* [Async](http://ruby-concurrency.github.io/concurrent-ruby/Concurrent/Async.html): A mixin module that provides simple asynchronous behavior to a class. Loosely based on Erlang's [gen_server](http://www.erlang.org/doc/man/gen_server.html).
* [Future](http://ruby-concurrency.github.io/concurrent-ruby/Concurrent/Future.html): An asynchronous operation that produces a value.
  * [Dataflow](http://ruby-concurrency.github.io/concurrent-ruby/Concurrent.html#dataflow-class_method): Built on Futures, Dataflow allows you to create a task that will be scheduled when all of its data dependencies are available.
* [Promise](http://ruby-concurrency.github.io/concurrent-ruby/Concurrent/Promise.html): Similar to Futures, with more features.
* [ScheduledTask](http://ruby-concurrency.github.io/concurrent-ruby/Concurrent/ScheduledTask.html): Like a Future scheduled for a specific future time.
* [TimerTask](http://ruby-concurrency.github.io/concurrent-ruby/Concurrent/TimerTask.html): A Thread that periodically wakes up to perform work at regular intervals.

#### Thread-safe Value Objects, Structures, and Collections

Collection classes that were originally part of the (deprecated) `thread_safe` gem:

* [Array](http://ruby-concurrency.github.io/concurrent-ruby/Concurrent/Array.html) A thread-safe subclass of Ruby's standard [Array](http://ruby-doc.org/core-2.2.0/Array.html).
* [Hash](http://ruby-concurrency.github.io/concurrent-ruby/Concurrent/Hash.html) A thread-safe subclass of Ruby's standard [Hash](http://ruby-doc.org/core-2.2.0/Hash.html).
* [Map](http://ruby-concurrency.github.io/concurrent-ruby/Concurrent/Map.html) A hash-like object that should have much better performance characteristics, especially under high concurrency, than `Concurrent::Hash`.
* [Tuple](http://ruby-concurrency.github.io/concurrent-ruby/Concurrent/Tuple.html) A fixed size array with volatile (synchronized, thread safe) getters/setters.

Value objects inspired by other languages:

* [Maybe](http://ruby-concurrency.github.io/concurrent-ruby/Concurrent/Maybe.html) A thread-safe, immutable object representing an optional value, based on
  [Haskell Data.Maybe](https://hackage.haskell.org/package/base-4.2.0.1/docs/Data-Maybe.html).
* [Delay](http://ruby-concurrency.github.io/concurrent-ruby/Concurrent/Delay.html) Lazy evaluation of a block yielding an immutable result. Based on Clojure's [delay](http://ruby-concurrency.github.io/concurrent-ruby/Concurrent/Delay.html).

Structure classes derived from Ruby's [Struct](http://ruby-doc.org/core-2.2.0/Struct.html):

* [ImmutableStruct](http://ruby-concurrency.github.io/concurrent-ruby/Concurrent/ImmutableStruct.html) Immutable struct where values are set at construction and cannot be changed later.
* [MutableStruct](http://ruby-concurrency.github.io/concurrent-ruby/Concurrent/MutableStruct.html) Synchronized, mutable struct where values can be safely changed at any time.
* [SettableStruct](http://ruby-concurrency.github.io/concurrent-ruby/Concurrent/SettableStruct.html) Synchronized, write-once struct where values can be set at most once, either at construction or any time thereafter.

Thread-safe variables:

* [Agent](http://ruby-concurrency.github.io/concurrent-ruby/Concurrent/Agent.html): A way to manage shared, mutable, *asynchronous*, independent state. Based on Clojure's [Agent](http://clojure.org/agents).
* [Atom](http://ruby-concurrency.github.io/concurrent-ruby/Concurrent/Atom.html): A way to manage shared, mutable, *synchronous*, independent state. Based on Clojure's [Atom](http://clojure.org/atoms).
* [AtomicBoolean](http://ruby-concurrency.github.io/concurrent-ruby/Concurrent/AtomicBoolean.html) A boolean value that can be updated atomically.
* [AtomicFixnum](http://ruby-concurrency.github.io/concurrent-ruby/Concurrent/AtomicFixnum.html) A numeric value that can be updated atomically.
* [AtomicReference](http://ruby-concurrency.github.io/concurrent-ruby/Concurrent/MutexAtomic.html) An object reference that may be updated atomically.
* [Exchanger](http://ruby-concurrency.github.io/concurrent-ruby/Concurrent/Exchanger.html) A synchronization point at which threads can pair and swap elements within pairs. Based on Java's [Exchanger](http://docs.oracle.com/javase/7/docs/api/java/util/concurrent/Exchanger.html).
* [MVar](http://ruby-concurrency.github.io/concurrent-ruby/Concurrent/MVar.html) A synchronized single element container. Based on Haskell's [MVar](https://hackage.haskell.org/package/base-4.8.1.0/docs/Control-Concurrent-MVar.html) and Scala's [MVar](http://docs.typelevel.org/api/scalaz/nightly/index.html#scalaz.concurrent.MVar$).
* [ThreadLocalVar](http://ruby-concurrency.github.io/concurrent-ruby/Concurrent/ThreadLocalVar.html) A variable where the value is different for each thread.
* [TVar](http://ruby-concurrency.github.io/concurrent-ruby/Concurrent/TVar.html) A transactional variable implementing software transactional memory (STM). Based on Clojure's [Ref](http://clojure.org/refs).

#### Java-inspired ThreadPools and Other Executors

* See the [thread pool](http://ruby-concurrency.github.io/concurrent-ruby/file.thread_pools.html) overview, which also contains a list of other Executors available.

#### Thread Synchronization Classes and Algorithms

* [CountDownLatch](http://ruby-concurrency.github.io/concurrent-ruby/Concurrent/CountDownLatch.html) A synchronization object that allows one thread to wait on multiple other threads.
* [CyclicBarrier](http://ruby-concurrency.github.io/concurrent-ruby/Concurrent/CyclicBarrier.html) A synchronization aid that allows a set of threads to all wait for each other to reach a common barrier point.
* [Event](http://ruby-concurrency.github.io/concurrent-ruby/Concurrent/Event.html) Old school kernel-style event.
* [IVar](http://ruby-concurrency.github.io/concurrent-ruby/Concurrent/IVar.html) Similar to a "future" but can be manually assigned once, after which it becomes immutable.
* [ReadWriteLock](http://ruby-concurrency.github.io/concurrent-ruby/Concurrent/ReadWriteLock.html) A lock that supports multiple readers but only one writer.
* [ReentrantReadWriteLock](http://ruby-concurrency.github.io/concurrent-ruby/Concurrent/ReentrantReadWriteLock.html) A read/write lock with reentrant and upgrade features.
* [Semaphore](http://ruby-concurrency.github.io/concurrent-ruby/Concurrent/Semaphore.html) A counting-based locking mechanism that uses permits.

### Edge Features

These are available in the `concurrent-ruby-edge` companion gem.

These features are under active development and may change frequently. They are expected not to
keep backward compatibility (there may also lack tests and documentation). Semantic versions will
be obeyed though. Features developed in `concurrent-ruby-edge` are expected to move to `concurrent-ruby` when final.

* [Promises Framework](http://ruby-concurrency.github.io/concurrent-ruby/Concurrent/Promises.html):
  Unified implementation of futures and promises which combines features of previous `Future`,
  `Promise`, `IVar`, `Event`, `dataflow`, `Delay`, and `TimerTask` into a single framework. It extensively uses the
  new synchronization layer to make all the features **non-blocking** and **lock-free**, with the exception of obviously blocking
  operations like `#wait`, `#value`. It also offers better performance.
* [Actor](http://ruby-concurrency.github.io/concurrent-ruby/Concurrent/Actor.html):
  Implements the Actor Model, where concurrent actors exchange messages.
* [Channel](http://ruby-concurrency.github.io/concurrent-ruby/Concurrent/Edge/Channel.html):
  Communicating Sequential Processes ([CSP](https://en.wikipedia.org/wiki/Communicating_sequential_processes)).
  Functionally equivalent to Go [channels](https://tour.golang.org/concurrency/2) with additional
  inspiration from Clojure [core.async](https://clojure.github.io/core.async/).
* [LazyRegister](http://ruby-concurrency.github.io/concurrent-ruby/Concurrent/LazyRegister.html)
* [AtomicMarkableReference](http://ruby-concurrency.github.io/concurrent-ruby/Concurrent/Edge/AtomicMarkableReference.html)
* [LockFreeLinkedSet](http://ruby-concurrency.github.io/concurrent-ruby/Concurrent/Edge/LockFreeLinkedSet.html)
* [LockFreeStack](http://ruby-concurrency.github.io/concurrent-ruby/Concurrent/LockFreeStack.html)

#### Statuses:

*Why are these not in core?*

- **Promises Framework** - They are being finalized to be able to be moved to core. They'll deprecate old 
  implementation.
- **Actor** - Partial documentation and tests; depends on new future/promise framework; stability is good.
- **Channel** - Brand new implementation; partial documentation and tests; stability is good.
- **LazyRegister** - Missing documentation and tests.
- **AtomicMarkableReference, LockFreeLinkedSet, LockFreeStack** - Need real world battle testing.

## Usage

Everything within this gem can be loaded simply by requiring it:

```ruby
require 'concurrent'
```

To use the tools in the Edge gem it must be required separately:

```ruby
require 'concurrent-edge'
```

If the library does not behave as expected, `Concurrent.use_stdlib_logger(Logger::DEBUG)` could help to reveal the problem.

## Installation

```shell
gem install concurrent-ruby
```

or add the following line to Gemfile:

```ruby
gem 'concurrent-ruby', require: 'concurrent'
```

and run `bundle install` from your shell.

### Edge Gem Installation

The Edge gem must be installed separately from the core gem:

```shell
gem install concurrent-ruby-edge
```

or add the following line to Gemfile:

```ruby
gem 'concurrent-ruby-edge', require: 'concurrent-edge'
```

and run `bundle install` from your shell.


### C Extensions for MRI

Potential performance improvements may be achieved under MRI by installing optional C extensions.
To minimize installation errors the C extensions are available in the `concurrent-ruby-ext` extension
gem. `concurrent-ruby` and `concurrent-ruby-ext` are always released together with same version.
Simply install the extension gem too:

```ruby
gem install concurrent-ruby-ext
```

or add the following line to Gemfile:

```ruby
gem 'concurrent-ruby-ext'
```

and run `bundle install` from your shell.

In code it is only necessary to

```ruby
require 'concurrent'
```

The `concurrent-ruby` gem will automatically detect the presence of the `concurrent-ruby-ext` gem
and load the appropriate C extensions.

#### Note For gem developers

No gems should depend on `concurrent-ruby-ext`. Doing so will force C extensions on your users.
The best practice is to depend on `concurrent-ruby` and let users to decide if they want C extensions.

## Maintainers

* [Petr Chalupa](https://github.com/pitr-ch) (lead maintainer)
* [Jerry D'Antonio](https://github.com/jdantonio) (creator)
* [Michele Della Torre](https://github.com/mighe)
* [Chris Seaton](https://github.com/chrisseaton)
* [Paweł Obrok](https://github.com/obrok)
* [Lucas Allan](https://github.com/lucasallan)

### Special Thanks

* [Brian Durand](https://github.com/bdurand) for the `ref` gem
* [Charles Oliver Nutter](https://github.com/headius) for the `atomic` and `thread_safe` gems
* [thedarkone](https://github.com/thedarkone) for the `thread_safe` gem

## License and Copyright

*Concurrent Ruby* is free software released under the [MIT License](http://www.opensource.org/licenses/MIT).

The *Concurrent Ruby* [logo](https://github.com/ruby-concurrency/concurrent-ruby/wiki/Logo)
was designed by [David Jones](https://twitter.com/zombyboy).
It is Copyright &copy; 2014 [Jerry D'Antonio](https://twitter.com/jerrydantonio). All Rights Reserved.
