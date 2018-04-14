Sidekiq
==============

[![Gem Version](https://badge.fury.io/rb/sidekiq.svg)](https://rubygems.org/gems/sidekiq)
[![Code Climate](https://codeclimate.com/github/mperham/sidekiq.svg)](https://codeclimate.com/github/mperham/sidekiq)
[![Build Status](https://travis-ci.org/mperham/sidekiq.svg)](https://travis-ci.org/mperham/sidekiq)
[![Gitter Chat](https://badges.gitter.im/mperham/sidekiq.svg)](https://gitter.im/mperham/sidekiq)


Simple, efficient background processing for Ruby.

Sidekiq uses threads to handle many jobs at the same time in the
same process.  It does not require Rails but will integrate tightly with
Rails to make background processing dead simple.

Sidekiq is compatible with Resque.  It uses the exact same
message format as Resque so it can integrate into an existing Resque processing farm.
You can have Sidekiq and Resque run side-by-side at the same time and
use the Resque client to enqueue jobs in Redis to be processed by Sidekiq.

Performance
---------------

Version |	Latency | Garbage created for 10,000 jobs	| Time to process 100,000 jobs |	Throughput
-----------------|------|---------|---------|------------------------
Sidekiq 4.0.0    | 10ms	| 151 MB  | 22 sec  | **4500 jobs/sec**
Sidekiq 3.5.1    | 22ms	| 1257 MB | 125 sec | 800 jobs/sec
Resque 1.25.2    |  -	  | -       | 420 sec | 240 jobs/sec
DelayedJob 4.1.1 |  -   | -       | 465 sec | 215 jobs/sec

<small>This benchmark can be found in `bin/sidekiqload`.</small>

Requirements
-----------------

Sidekiq supports CRuby 2.2.2+ and JRuby 9k.

All Rails releases >= 4.0 are officially supported.

Redis 2.8 or greater is required.  3.0.3+ is recommended for large
installations with thousands of worker threads.


Installation
-----------------

    gem install sidekiq


Getting Started
-----------------

See the [Getting Started wiki page](https://github.com/mperham/sidekiq/wiki/Getting-Started) and follow the simple setup process.
You can watch [this Youtube playlist](https://www.youtube.com/playlist?list=PLjeHh2LSCFrWGT5uVjUuFKAcrcj5kSai1) to learn all about
Sidekiq and see its features in action.  Here's the Web UI:

![Web UI](https://github.com/mperham/sidekiq/raw/master/examples/web-ui.png)


Want to Upgrade?
-------------------

I also sell Sidekiq Pro and Sidekiq Enterprise, extensions to Sidekiq which provide more
features, a commercial-friendly license and allow you to support high
quality open source development all at the same time.  Please see the
[Sidekiq](http://sidekiq.org/) homepage for more detail.

Subscribe to the **[quarterly newsletter](https://tinyletter.com/sidekiq)** to stay informed about the latest
features and changes to Sidekiq and its bigger siblings.


Problems?
-----------------

**Please do not directly email any Sidekiq committers with questions or problems.**  A community is best served when discussions are held in public.

If you have a problem, please review the [FAQ](https://github.com/mperham/sidekiq/wiki/FAQ) and [Troubleshooting](https://github.com/mperham/sidekiq/wiki/Problems-and-Troubleshooting) wiki pages.
Searching the [issues](https://github.com/mperham/sidekiq/issues) for your problem is also a good idea.

Sidekiq Pro and Sidekiq Enterprise customers get private email support.  You can purchase at http://sidekiq.org; email support@contribsys.com for help.

Useful resources:

* Product documentation is in the [wiki](https://github.com/mperham/sidekiq/wiki).
* Release announcements are made to the [@sidekiq](https://twitter.com/sidekiq) Twitter account.
* The [Sidekiq tag](https://stackoverflow.com/questions/tagged/sidekiq) on Stack Overflow has lots of useful Q &amp; A.

**No support via Twitter**

Every Friday morning is Sidekiq happy hour: I video chat and answer questions.
See the [Sidekiq support page](http://sidekiq.org/support.html) for details.

Thanks
-----------------

Sidekiq stays fast by using the [JProfiler java profiler](http://www.ej-technologies.com/products/jprofiler/overview.html) to find and fix
performance problems on JRuby.  Unfortunately MRI does not have good multithreaded profiling tools.


License
-----------------

Please see [LICENSE](https://github.com/mperham/sidekiq/blob/master/LICENSE) for licensing details.


Author
-----------------

Mike Perham, [@mperham](https://twitter.com/mperham) / [@sidekiq](https://twitter.com/sidekiq), [http://www.mikeperham.com](http://www.mikeperham.com) / [http://www.contribsys.com](http://www.contribsys.com)
