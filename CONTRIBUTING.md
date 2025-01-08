# Contributing

Thank you for considering contributing to Mastodon 🐘

You can contribute in the following ways:

- Finding and reporting bugs
- Translating the Mastodon interface into various languages
- Contributing code to Mastodon by fixing bugs or implementing features
- Improving the documentation

Please review the org-level [contribution guidelines] for high-level acceptance
criteria guidance and the [DEVELOPMENT] guide for environment-specific details.

## API Changes and Additions

Any changes or additions made to the API should have an accompanying pull
request on our [documentation repository].

## Bug reports

Bug reports and feature suggestions must use descriptive and concise titles and
be submitted to [GitHub Issues]. Please use the search function to make sure
that you are not submitting duplicate bug reports or feature requests.

## Translations

Translations are community contributed via [Crowdin]. They are periodically
reviewed and merged into the codebase.

[![Crowdin](https://d322cqt584bo4o.cloudfront.net/mastodon/localized.svg)](https://crowdin.com/project/mastodon)

## Pull requests

### Size and scope

The smaller and more focused a set of changes in a Pull Request is, the easier
it is to review. Splitting tasks into multiple smaller PRs is often preferable.
Team time is limited and pull requests making large sprawling changes are harder
to review and less likely to get any feedback at all. If your change only makes
sense in some larger context of future changes, note that in the description,
but still aim to keep each distinct PR to a "smallest viable change" size.

### Description of changes

Unless the Pull Request is about refactoring code, updating dependencies or
other internal tasks, assume that the person reading the PR is not a programmer
or Mastodon developer, but a Mastodon user or server admin, and try to describe
things from their perspective.

We use commit squashing, so the final commit in the main branch will carry the
title and description from the Pull Request. Commits from the main branch are
then fed into the changelog and ultimately into release notes. We try to follow
the [keepachangelog] spec, and while that does not prescribe how the entries
ought to be named, for easier sorting, starting your pull request titles using
one of the verbs "Add", "Change", "Deprecate", "Remove", or "Fix" (present
tense) is helpful when it makes sense.

Example:

| Not ideal                            | Better                                                        |
| ------------------------------------ | ------------------------------------------------------------- |
| Fixed NoMethodError in RemovalWorker | Fix nil error when removing statuses caused by race condition |

### Technical requirements

Pull requests that do not pass automated checks on CI may not be reviewed. In
particular, please keep in mind:

- Unit and integration tests (rspec, jest)
- Code style rules (rubocop, eslint)
- Normalization of locale files (i18n-tasks)
- Relevant accessibility or performance concerns

## Documentation

The [Mastodon documentation](https://docs.joinmastodon.org) is a statically generated site. You can [submit merge requests to mastodon/documentation](https://github.com/mastodon/documentation).

[Crowdin]: https://crowdin.com/project/mastodon
[contribution guidelines]: https://github.com/mastodon/.github/blob/main/CONTRIBUTING.md
[DEVELOPMENT]: docs/DEVELOPMENT.md
[documentation repository]: https://github.com/mastodon/documentation
[GitHub Issues]: https://github.com/mastodon/mastodon/issues
[keepachangelog]: https://keepachangelog.com/en/1.0.0/
