# Contributing to Mastodon Glitch Edition

Thank you for your interest in contributing to the `glitch-soc` project!
Here are some guidelines, and ways you can help.

> (This document is a bit of a work-in-progress, so please bear with us.
> If you don't see what you're looking for here, please don't hesitate to reach out!)

## Translations

You can submit glitch-soc-specific translations via [Crowdin](https://crowdin.com/project/glitch-soc). They are periodically merged into the codebase.

[![Crowdin](https://badges.crowdin.net/glitch-soc/localized.svg)](https://crowdin.com/project/glitch-soc)

## Planning

Right now a lot of the planning for this project takes place in our development Discord, or through GitHub Issues and Projects.
We're working on ways to improve the planning structure and better solicit feedback, and if you feel like you can help in this respect, feel free to give us a holler.

## Documentation

The documentation for this repository is available at [`glitch-soc/docs`](https://github.com/glitch-soc/docs) (online at [glitch-soc.github.io/docs/](https://glitch-soc.github.io/docs/)).
Right now, we've mostly focused on the features that make this fork different from upstream in some manner.
Adding screenshots, improving descriptions, and so forth are all ways to help contribute to the project even if you don't know any code.

## Frontend Development

Check out [the documentation here](https://glitch-soc.github.io/docs/contributing/frontend/) for more information.

## Backend Development

See the guidelines below.

---

You should also try to follow the guidelines set out in the original `CONTRIBUTING.md` from `mastodon/mastodon`, reproduced below.

<blockquote>

# Contributing

Thank you for considering contributing to Mastodon 🐘

You can contribute in the following ways:

- Finding and reporting bugs
- Translating the Mastodon interface into various languages
- Contributing code to Mastodon by fixing bugs or implementing features
- Improving the documentation

Please review the org-level [contribution guidelines] for high-level acceptance
criteria guidance and the [DEVELOPMENT] guide for environment-specific details.
You should also read the project's [AI Contribution Policy] to understand how we approach
AI-assisted contributions.

## API Changes and Additions

Any changes or additions made to the API should have an accompanying pull
request on our [documentation repository].

## Bug Reports

Bug reports and feature suggestions must use descriptive and concise titles and
be submitted to [GitHub Issues]. Please use the search function to make sure
there are not duplicate bug reports or feature requests.

## Security Issues

If you believe you have identified a security issue in Mastodon or our own apps,
check [SECURITY].

## Translations

Translations are community contributed via [Crowdin]. They are periodically
reviewed and merged into the codebase.

[![Crowdin](https://d322cqt584bo4o.cloudfront.net/mastodon/localized.svg)](https://crowdin.com/project/mastodon)

## Pull Requests

### Size and Scope

Our time is limited and PRs making large, unsolicited changes are unlikely to
get a response. Changes which link to an existing confirmed issue, or which come
from a "help wanted" issue or other request, are more likely to be reviewed.

The smaller and more narrowly focused the changes in a PR are, the easier they
are to review and potentially merge. If the change only makes sense in some
larger context of future ongoing work, note that in the description, but still
aim to keep each distinct PR to a "smallest viable change" chunk of work.

### Description of Changes

Unless the Pull Request is about refactoring code, updating dependencies or
other internal tasks, assume that the audience are not developers, but a
Mastodon user or server admin, and try to describe it from their perspective.

The final commit in the main branch will carry the title from the PR. The main
branch is then fed into the changelog and ultimately into release notes. We try
to follow the [keepachangelog] spec, and while that does not prescribe how
exactly the entries ought to be named, starting titles using one of the verbs
"Add", "Change", "Deprecate", "Remove", or "Fix" (present tense) is helpful.

Example:

| Not ideal                            | Better                                                        |
| ------------------------------------ | ------------------------------------------------------------- |
| Fixed NoMethodError in RemovalWorker | Fix nil error when removing statuses caused by race condition |

### Technical Requirements

Pull requests that do not pass automated checks on CI may not be reviewed. In
particular, please keep in mind:

- Unit and integration tests (rspec, vitest)
- Code style rules (rubocop, eslint)
- Normalization of locale files (i18n-tasks)
- Relevant accessibility or performance concerns

## Documentation

The [Mastodon documentation] is a statically generated site that contains guides
and API docs. Improvements are made via PRs to the [documentation repository].

</blockquote>

[contribution guidelines]: https://github.com/mastodon/.github/blob/main/CONTRIBUTING.md
[Crowdin]: https://crowdin.com/project/mastodon
[DEVELOPMENT]: docs/DEVELOPMENT.md
[documentation repository]: https://github.com/mastodon/documentation
[GitHub Issues]: https://github.com/mastodon/mastodon/issues
[keepachangelog]: https://keepachangelog.com/en/1.0.0/
[Mastodon documentation]: https://docs.joinmastodon.org
[SECURITY]: SECURITY.md
[AI Contribution Policy]: https://github.com/mastodon/.github/blob/main/AI_POLICY.md
