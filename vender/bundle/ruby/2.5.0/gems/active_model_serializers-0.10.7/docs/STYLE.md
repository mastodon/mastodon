# STYLE

## Code and comments

- We are actively working to identify tasks under the label [**Good for New
  Contributors**](https://github.com/rails-api/active_model_serializers/labels/Good%20for%20New%20Contributors).
  - [Changelog
      Missing](https://github.com/rails-api/active_model_serializers/issues?q=label%3A%22Changelog+Missing%22+is%3Aclosed) is
    an easy way to help out.

- [Fix a bug](https://github.com/rails-api/active_model_serializers/labels/Ready%20for%20PR).
  - Ready for PR - A well defined bug, needs someone to PR a fix.
  - Bug - Anything that is broken.
  - Regression - A bug that did not exist in previous versions and isn't a new feature (applied in tandem with Bug).
  - Performance - A performance related issue. We could track this as a bug, but usually these would have slightly lower priority than standard bugs.

- [Develop new features](https://github.com/rails-api/active_model_serializers/labels/Feature).

- [Improve code quality](https://codeclimate.com/github/rails-api/active_model_serializers/code?sort=smell_count&sort_direction=desc).

- [Improve amount of code exercised by tests](https://codeclimate.com/github/rails-api/active_model_serializers/coverage?sort=covered_percent&sort_direction=asc).

- [Fix RuboCop (Style) TODOS](https://github.com/rails-api/active_model_serializers/blob/master/.rubocop_todo.yml).
  - Delete and offsense, run `rake rubocop` (or possibly `rake rubocop:auto_correct`),
    and [submit a PR](CONTRIBUTING.md#submitting-a-pull-request-pr).

- We are also encouraging comments to substantial changes (larger than bugfixes and simple features) under an
  "RFC" (Request for Comments) process before we start active development.
   Look for the [**RFC**](https://github.com/rails-api/active_model_serializers/labels/RFC) label.


## Pull requests

- If the tests pass and the pull request looks good, a maintainer will merge it.
- If the pull request needs to be changed,
  - you can change it by updating the branch you generated the pull request from
    - either by adding more commits, or
    - by force pushing to it
  - A maintainer can make any changes themselves and manually merge the code in.

## Commit messages

- [A Note About Git Commit Messages](http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html)
- [http://stopwritingramblingcommitmessages.com/](http://stopwritingramblingcommitmessages.com/)
- [ThoughtBot style guide](https://github.com/thoughtbot/guides/tree/master/style#git)

#### About Pull Requests (PR's)

- [Using Pull Requests](https://help.github.com/articles/using-pull-requests)
- [Github pull requests made easy](http://www.element84.com/github-pull-requests-made-easy.html)
- [Exercism Git Workflow](http://help.exercism.io/git-workflow.html).
- [Level up your Git](http://rakeroutes.com/blog/deliberate-git/)
- [All Your Open Source Code Are Belong To Us](http://www.benjaminfleischer.com/2013/07/30/all-your-open-source-code-are-belong-to-us/)

## Issue Labeling

ActiveModelSerializers uses a subset of [StandardIssueLabels](https://github.com/wagenet/StandardIssueLabels) for Github Issues. You can [see our labels here](https://github.com/rails-api/active_model_serializers/labels).

