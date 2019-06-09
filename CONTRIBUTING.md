Contributing
============

Thank you for considering contributing to Mastodon 🐘

You can contribute in the following ways:

- Finding and reporting bugs
- Translating the Mastodon interface into various languages
- Contributing code to Mastodon by fixing bugs or implementing features
- Improving the documentation

If your contributions are accepted into Mastodon, you can request to be paid through [our OpenCollective](https://opencollective.com/mastodon).

## New to Open Source? START HERE

We want all members of the GitHub community to feel welcome when it comes to contributing to our project. You can follow these step-by-step instructions to make a contribution via a pull request.

1. Fork a repository from Mastodon and create a branch to build new features or test out ideas - instructions available here: https://help.github.com/en/articles/fork-a-repo
2. Navigate to the original repository you created your fork from.
3. To the right of the Branch menu, click New pull request.
4. On the Compare page, click compare across forks.
5. Confirm that the base fork is the repository you'd like to merge changes into. Use the base branch drop-down menu to select the branch of the upstream repository you'd like to merge changes into.
6. Use the head fork drop-down menu to select your fork, then use the compare branch drop-down menu to select the branch you made your changes in.
7. Type a title and description for your pull request.
8. If you do not want to allow anyone with push access to the upstream repository to make changes to your PR, unselect Allow edits from maintainers.
9. To create a pull request that is ready for review, click Create Pull Request. To create a draft pull request, use the drop-down and select Create Draft Pull Request, then click Draft Pull Request.

## Bug reports

Bug reports and feature suggestions can be submitted to [GitHub Issues](https://github.com/tootsuite/mastodon/issues). Please make sure that you are not submitting duplicates, and that a similar report or request has not already been resolved or rejected in the past using the search function. Please also use descriptive, concise titles.

## Translations

You can submit translations via pull request.

## Pull requests

Please use clean, concise titles for your pull requests. We use commit squashing, so the final commit in the master branch will carry the title of the pull request.

The smaller the set of changes in the pull request is, the quicker it can be reviewed and merged. Splitting tasks into multiple smaller pull requests is often preferable.

**Pull requests that do not pass automated checks may not be reviewed**. In particular, you need to keep in mind:

- Unit and integration tests (rspec, jest)
- Code style rules (rubocop, eslint)
- Normalization of locale files (i18n-tasks)

## Documentation

The [Mastodon documentation](https://docs.joinmastodon.org) is a statically generated site. You can [submit merge requests to mastodon/docs](https://source.joinmastodon.org/mastodon/docs).
