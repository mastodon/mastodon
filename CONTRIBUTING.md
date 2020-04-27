Contributing
============

Thank you for considering contributing to Mastodon 🐘

You can contribute in the following ways:

- Finding and reporting bugs
- Translating the Mastodon interface into various languages
- Contributing code to Mastodon by fixing bugs or implementing features
- Improving the documentation

If your contributions are accepted into Mastodon, you can request to be paid through [our OpenCollective](https://opencollective.com/mastodon).

## Bug reports

Bug reports and feature suggestions must use descriptive and concise titles and be submitted to [GitHub Issues](https://github.com/tootsuite/mastodon/issues). Please use the search function to make sure that you are not submitting duplicates, and that a similar report or request has not already been resolved or rejected.

## Translations

You can submit translations via [Crowdin](https://crowdin.com/project/mastodon). They are periodically merged into the codebase.

[![Crowdin](https://d322cqt584bo4o.cloudfront.net/mastodon/localized.svg)](https://crowdin.com/project/mastodon)

## Pull requests

Please use clean, concise titles for your pull requests. We use commit squashing, so the final commit in the master branch will carry the title of the pull request.

The smaller the set of changes in the pull request is, the quicker it can be reviewed and merged. Splitting tasks into multiple smaller pull requests is often preferable.

**Pull requests that do not pass automated checks may not be reviewed**. In particular, you need to keep in mind:

- Unit and integration tests (rspec, jest)
- Code style rules (rubocop, eslint)
- Normalization of locale files (i18n-tasks)

## Documentation

The [Mastodon documentation](https://docs.joinmastodon.org) is a statically generated site. You can [submit merge requests to mastodon/docs](https://source.joinmastodon.org/mastodon/docs).
