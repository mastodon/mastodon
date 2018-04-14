# How to contribute to Devise

Thanks for your interest on contributing to Devise! Here are a few general
guidelines on contributing and reporting bugs to Devise that we ask you to
take a look first. Notice that all of your interactions in the project are
expected to follow our [Code of Conduct](CODE_OF_CONDUCT.md).

## Reporting Issues

Before reporting a new issue, please be sure that the issue wasn't already
reported or fixed by searching on GitHub through our [issues](https://github.com/plataformatec/devise/issues).

When creating a new issue, be sure to include a **title and clear description**,
as much relevant information as possible, and either a test case example or
even better a **sample Rails app that replicates the issue** - Devise has a lot
of moving parts and it's functionality can be affected by third party gems, so
we need as much context and details as possible to identify what might be broken
for you. We have a [test case template](guides/bug_report_templates/integration_test.rb)
that can be used to replicate issues with minimal setup.

Please do not attempt to translate Devise built in views. The views are meant
to be a starting point for fresh apps and not production material - eventually
all applications will require custom views where you can write your own copy and
translate it if the application requires it . For historical references, please look into closed
[Issues/Pull Requests](https://github.com/plataformatec/devise/issues?q=i18n) regarding
internationalization.

Avoid opening new issues to ask questions in our issues tracker. Please go through
the project wiki, documentation and source code first, or try to ask your question
on [Stack Overflow](http://stackoverflow.com/questions/tagged/devise).

**If you find a security bug, do not report it through GitHub. Please send an
e-mail to [opensource@plataformatec.com.br](mailto:opensource@plataformatec.com.br)
instead.**

## Sending Pull Requests

Before sending a new Pull Request, take a look on existing Pull Requests and Issues
to see if the proposed change or fix has been discussed in the past, or if the
change was already implemented but not yet released.

We expect new Pull Requests to include enough tests for new or changed behavior,
and we aim to maintain everything as most backwards compatible as possible,
reserving breaking changes to be ship in major releases when necessary - you
can wrap the new code path with a setting toggle from the `Devise` module defined
as `false` by default to require developers to opt-in for the new behavior.

If your Pull Request includes new or changed behavior, be sure that the changes
are beneficial to a wide range of use cases or it's an application specific change
that might not be so valuable to other applications. Some changes can be introduced
as a new `devise-something` gem instead of belonging to the main codebase.

When adding new settings, you can take advantage of the [`Devise::Models.config`](https://github.com/plataformatec/devise/blob/245b1f9de0b3386b7913e14b60ea24f43b77feb0/lib/devise/models.rb#L13-L50) method to add class and instance level fallbacks
to the new setting.

We also welcome Pull Requests that improve our existing documentation (both our
`README.md` and the RDoc sections in the source code) or improve existing rough
edges in our API that might be blocking existing integrations or 3rd party gems.

## Other ways to contribute

We welcome anyone that wants to contribute to Devise to triage and reply to
open issues to help troubleshoot and fix existing bugs on Devise. Here is what
you can do:

* Help ensure that existing issues follows the recommendations from the
_[Reporting Issues](#reporting-issues)_ section, providing feeback to the issue's
author on what might be missing.
* Review and update the existing content of our [Wiki](https://github.com/plataformatec/devise/wiki)
with up to date instructions and code samples - the wiki was grown with several
different tutorials and references that we can't keep track of everything, so if
there is a page that showcases an integration or customization that you are
familiar with feel free to update it as necessary.
* Review existing Pull Requests, and testing patches against real existing
applications that use Devise.

Thanks again for your interest on contributing to the project!

:heart:
