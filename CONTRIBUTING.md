CONTRIBUTING
============

There are three ways in which you can contribute to this repository:

1. By improving the documentation
2. By working on the back-end application
3. By working on the front-end application

Choosing what to work on in a large open source project is not easy. The list of [GitHub issues](https://github.com/tootsuite/mastodon/issues) may provide some ideas, but not every feature request has been greenlit. Likewise, not every change or feature that resolves a personal itch will be merged into the main repository. Some communication ahead of time may be wise. If your addition creates a new feature or setting, or otherwise changes how things work in some substantial way, please remember to submit a correlating pull request to document your changes in the [documentation](http://github.com/tootsuite/documentation).

Below are the guidelines for working on pull requests:

## General

- 2 spaces indentation

## Documentation

- No spelling mistakes
- No orthographic mistakes
- No Markdown syntax errors

## Requirements

- Ruby
- Node.js
- PostgreSQL
- Redis
- Nginx (optional)

## Back-end application

It is expected that you have a working development environment set up. The development environment includes [rubocop](https://github.com/bbatsov/rubocop), which checks your Ruby code for compliance with our style guide and best practices. Sublime Text, likely like other editors, has a [Rubocop plugin](https://github.com/pderichs/sublime_rubocop) that runs checks on files as you edit them. The codebase also has a test suite.

* The codebase is not perfect, at the time of writing, but it is expected that you do not introduce new code style violations
* The rspec test suite must pass
* To the extent that it is possible, verify your changes. In the best case, by adding new tests to the test suite. At the very least, by running the server or console and checking it manually
* If you are introducing new strings to the user interface, they must be using localization methods

If your code has syntax errors that won't let it run, it's a good sign that the pull request isn't ready for submission yet.

## Front-end application

It is expected that you have a working development environment set up (see back-end application section). This project includes an ESLint configuration file, with which you can lint your changes.

* Avoid grave ESLint violations
* Verify that your changes work
* If you are introducing new strings, they must be using localization methods

If the JavaScript or CSS assets won't compile due to a syntax error, it's a good sign that the pull request isn't ready for submission yet.
