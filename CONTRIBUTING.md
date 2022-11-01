#  Contributing to Mastodon Glitch Edition  #

Thank you for your interest in contributing to the `glitch-soc` project!
Here are some guidelines, and ways you can help.

>   (This document is a bit of a work-in-progress, so please bear with us.
>   If you don't see what you're looking for here, please don't hesitate to reach out!)

##  Planning  ##

Right now a lot of the planning for this project takes place in our development Discord, or through GitHub Issues and Projects.
We're working on ways to improve the planning structure and better solicit feedback, and if you feel like you can help in this respect, feel free to give us a holler.

##  Documentation  ##

The documentation for this repository is available at [`glitch-soc/docs`](https://github.com/glitch-soc/docs) (online at [glitch-soc.github.io/docs/](https://glitch-soc.github.io/docs/)).
Right now, we've mostly focused on the features that make this fork different from upstream in some manner.
Adding screenshots, improving descriptions, and so forth are all ways to help contribute to the project even if you don't know any code.

##  Frontend Development  ##

Check out [the documentation here](https://glitch-soc.github.io/docs/contributing/frontend/) for more information.

##  Backend Development  ##

See the guidelines below.

 - - -

You should also try to follow the guidelines set out in the original `CONTRIBUTING.md` from `mastodon/mastodon`, reproduced below.

<blockquote>

CONTRIBUTING
=======
Contributing

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

|Not ideal|Better|
|---|----|
|Fixed NoMethodError in RemovalWorker|Fix nil error when removing statuses caused by race condition|

It is not always possible to phrase every change in such a manner, but it is desired.

**The smaller the set of changes in the pull request is, the quicker it can be reviewed and merged.** Splitting tasks into multiple smaller pull requests is often preferable.

**Pull requests that do not pass automated checks may not be reviewed**. In particular, you need to keep in mind:

- Unit and integration tests (rspec, jest)
- Code style rules (rubocop, eslint)
- Normalization of locale files (i18n-tasks)

## Documentation

The [Mastodon documentation](https://docs.joinmastodon.org) is a statically generated site. You can [submit merge requests to mastodon/documentation](https://github.com/mastodon/documentation).

</blockquote>
