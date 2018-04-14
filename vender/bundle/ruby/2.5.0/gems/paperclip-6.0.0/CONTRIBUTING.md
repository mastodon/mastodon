Contributing
============

We love pull requests from everyone. By participating in this project, you agree
to abide by the thoughtbot [code of conduct].

[code of conduct]: https://thoughtbot.com/open-source-code-of-conduct

Here's a quick guide for contributing:

1. Fork the repo.

1. Make sure you have ImageMagick and Ghostscript installed. See [this section]
(./README.md#image-processor) of the README.

1. Run the tests. We only take pull requests with passing tests, and it's great
to know that you have a clean slate: `bundle && bundle exec rake`

1. Add a test for your change. Only refactoring and documentation changes
require no new tests. If you are adding functionality or fixing a bug, we need
a test!

1. Make the test pass.

1. Mention how your changes affect the project to other developers and users in
   the `NEWS.md` file.

1. Push to your fork and submit a pull request.

At this point you're waiting on us. We like to at least comment on, if not
accept, pull requests within seven business days (most of the work on Paperclip
gets done on Fridays). We may suggest some changes or improvements or
alternatives.

Some things that will increase the chance that your pull request is accepted,
taken straight from the Ruby on Rails guide:

* Use Rails idioms and helpers
* Include tests that fail without your code, and pass with it
* Update the documentation, the surrounding one, examples elsewhere, guides,
  whatever is affected by your contribution

Running Tests
-------------

Paperclip uses [Appraisal](https://github.com/thoughtbot/appraisal) to aid
testing against multiple version of Ruby on Rails. This helps us to make sure
that Paperclip performs correctly with them.

Paperclip also uses [RSpec](http://rspec.info) for its unit tests. If you submit
tests that are not written for Cucumber or RSpec without a very good reason, you
will be asked to rewrite them before we'll accept.

### Bootstrapping your test suite:

    bundle install
    bundle exec appraisal install

This will install all the required gems that requires to test against each
version of Rails, which defined in `gemfiles/*.gemfile`.

### To run a full test suite:

    bundle exec appraisal rake

This will run RSpec and Cucumber against all version of Rails

### To run single Test::Unit or Cucumber test

You need to specify a `BUNDLE_GEMFILE` pointing to the gemfile before running
the normal test command:

    BUNDLE_GEMFILE=gemfiles/4.1.gemfile rspec spec/paperclip/attachment_spec.rb
    BUNDLE_GEMFILE=gemfiles/4.1.gemfile cucumber features/basic_integration.feature

Syntax
------

* Two spaces, no tabs.
* No trailing whitespace. Blank lines should not have any space.
* Prefer &&/|| over and/or.
* MyClass.my_method(my_arg) not my_method( my_arg ) or my_method my_arg.
* a = b and not a=b.
* Follow the conventions you see used in the source already.

And in case we didn't emphasize it enough: we love tests!
