# Contributing

Thank you for considering contributing to Mastodon 🐘

You can contribute in the following ways:

- Finding and reporting bugs
- Translating the Mastodon interface into various languages
- Contributing code to Mastodon by fixing bugs or implementing features
- Improving the documentation

If your contributions are accepted into Mastodon, you can request to be paid through [our OpenCollective](https://opencollective.com/mastodon).

## Bug reports

Bug reports and feature suggestions must use descriptive and concise titles and be submitted to [GitHub Issues](https://github.com/mastodon/mastodon/issues). Please use the search function to make sure that you are not submitting duplicates, and that a similar report or request has not already been resolved or rejected.

## Translations

You can submit translations via [Crowdin](https://crowdin.com/project/mastodon). They are periodically merged into the codebase.

[![Crowdin](https://d322cqt584bo4o.cloudfront.net/mastodon/localized.svg)](https://crowdin.com/project/mastodon)

## Pull requests

**Please use clean, concise titles for your pull requests.** Unless the pull request is about refactoring code, updating dependencies or other internal tasks, assume that the person reading the pull request title is not a programmer or Mastodon developer, but instead a Mastodon user or server administrator, and **try to describe your change or fix from their perspective**. We use commit squashing, so the final commit in the main branch will carry the title of the pull request, and commits from the main branch are fed into the changelog. The changelog is separated into [keepachangelog.com categories](https://keepachangelog.com/en/1.0.0/), and while that spec does not prescribe how the entries ought to be named, for easier sorting, start your pull request titles using one of the verbs "Add", "Change", "Deprecate", "Remove", or "Fix" (present tense).

Example:

| Not ideal                            | Better                                                        |
| ------------------------------------ | ------------------------------------------------------------- |
| Fixed NoMethodError in RemovalWorker | Fix nil error when removing statuses caused by race condition |

It is not always possible to phrase every change in such a manner, but it is desired.

**The smaller the set of changes in the pull request is, the quicker it can be reviewed and merged.** Splitting tasks into multiple smaller pull requests is often preferable.

**Pull requests that do not pass automated checks may not be reviewed**. In particular, you need to keep in mind:

- Unit and integration tests (rspec, jest)
- Code style rules (rubocop, eslint)
- Normalization of locale files (i18n-tasks)

**Note**: You may need to log in and authorise the GitHub account your fork of this repository belongs to with CircleCI to enable some of the automated checks to run.

## Documentation

The [Mastodon documentation](https://docs.joinmastodon.org) is a statically generated site. You can [submit merge requests to mastodon/documentation](https://github.com/mastodon/documentation).
