(note: this was originally a blog post published at http://blog.flavorjon.es/2012/03/y-u-no-gemspec.html)

## tl;dr

1. Team Nokogiri are not 10-foot-tall code-crunching robots, so `master` is usually unstable.
2. Unstable code can corrupt your data and crash your application, which would make everybody look bad.
3. Therefore, the _risk_ associated with using unstable code is severe; for you _and_ for Team Nokogiri.
4. The absence of a gemspec is a risk mitigation tactic.
5. You can always ask for an RC release.


## Why Isn't There a Gemspec!?

OHAI! Thank you for asking this question!

Team Nokogiri gets asked this pretty frequently. Just a sample from
the historical record:

* [Issue #274](https://github.com/sparklemotion/nokogiri/issues/274)
* [Issue #371](https://github.com/sparklemotion/nokogiri/issues/371)
* [A commit removing nokogiri.gemspec](https://github.com/sparklemotion/nokogiri/commit/7f17a643a05ca381d65131515b54d4a3a61ca2e1#commitcomment-667477)
* [A nokogiri-talk thread](http://groups.google.com/group/nokogiri-talk/browse_thread/thread/4706b002e492d23f)
* [Another nokogiri-talk thread](http://groups.google.com/group/nokogiri-talk/browse_thread/thread/0b201bb80ea3eea0)

Sometimes people imply that we've forgotten, or that we don't know how to
properly manage our codebase. Those people are super fun to respond
to!

We've gone back and forth a couple of times over the past few years,
but the current policy of Team Nokogiri is to **not** provide a
gemspec in the Github repo. This is a conscious choice, not an
oversight.


## But You Didn't Answer the Question!

Ah, I was hoping you wouldn't notice. Well, OK, let's do this, if
you're serious about it.

I'd like to start by talking about _risk_. Specifically, the risk
associated with using a known-unstable version of Nokogiri.


### Risk

One common way to evaluate the _risk_ of an incident is:

    risk = probability x impact

You can read more about this on [the internets](http://en.wikipedia.org/wiki/Risk_Matrix).

The _risk_ associated with a Nokogiri bug could be loosely defined by
answering the questions:

* "How likely is it that a bug exists?" (probability)
* "How severe will the consequences of a bug be?" (impact)


### Probability

The `master` branch should be considered unstable. Team Nokogiri are
not 10-foot-tall code-crunching robots; we are humans. We make
mistakes, and as a result, any arbitrary commit on `master` is likely
to contain bugs.

Just as an example, Nokogiri `master` was unstable for about five
months between November 2011 and March 2012. It was unstable not
because we were sloppy, or didn't care, but because the fixes were
hard and unobvious.

When we release Nokogiri, we test for memory leaks and invalid memory
access on all kinds of platforms with many flavors of Ruby and lots of
versions of libxml2. Because these tests are time-consuming, we don't
run them on every commit. We run them often when preparing a release.

If we're releasing Nokogiri, it means we think it's rock solid.

And if we're not releasing it, it means there are probably bugs.


### Impact

Nokogiri is a gem with native extensions. This means it's not pure
Ruby -- there's C or Java code being compiled and run, which means
that there's always a chance that the gem will crash your application,
or worse. Possible outcomes include:

* leaking memory
* corrupting data
* making benign code crash (due to memory corruption)

So, then, a bug in a native extension can have much worse downside
than you might think. It's not just going to do something unexpected;
it's possibly going to do terrible, awful things to your application
and data.

**Nobody** wants that to happen. Especially Team Nokogiri.


### Risk, Redux

So, if you accept the equation

    risk = probability x impact

and you believe me when I say that:

* the probablility of a bug in unreleased code is high, and
* the impact of a bug is likely to be severe,

then you should easily see that the _risk_ associated with a bug in
Nokogiri is quite high.

Part of Team Nokogiri's job is to try to mitigate this risk. We have a
number of tactics that we use to accomplish this:

* we respond quickly to bug reports, particularly when they are possible memory issues
* we review each others' commits
* we have a thorough test suite, and we test-drive new features
* we discuss code design and issues on a core developer mailing list
* we use valgrind to test for memory issues (leaks and invalid
  access) on multiple combinations of OS, libxml2 and Ruby
* we package release candidates, and encourage devs to use them
* **we do NOT commit a gemspec in our git repository**

Yes, that's right, the absence of a gemspec is a risk mitigation
tactic. Not only does Team Nokogiri not want to imply support for
`master`, we want to **actively discourage** people from using
it. Because it's not stable.


## But I Want to Do It Anyway

Another option, is to email the [nokogiri-talk
list](http://groups.google.com/group/nokogiri-talk) and ask for a
release candidate to be built. We're pretty accommodating if there's a
bugfix that's a blocker for you. And if we can't release an RC, we'll
tell you why.

And in the end, nothing is stopping you from cloning the repo and
generating a private gemspec. This is an extra step or two, but it has
the benefit of making sure developers have thought through the costs
and risks involved; and it tends to select for developers who know
what they're doing.


## In Conclusion

Team Nokogiri takes stability very seriously. We want everybody who
uses Nokogiri to have a pleasant experience. And so we want to make
sure that you're using the best software we can make.

Please keep in mind that we're trying very hard to do the right thing
for all Nokogiri users out there in Rubyland. Nokogiri loves you very
much, and we hope you love it back.
