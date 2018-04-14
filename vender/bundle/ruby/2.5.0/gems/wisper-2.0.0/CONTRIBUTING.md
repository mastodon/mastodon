# How to Contribute

We very much welcome contributions to Wisper.

This project is intended to be a safe, welcoming space for collaboration,
and contributors are expected to adhere to the
[Contributor Covenant](http://contributor-covenant.org) code of conduct.

## Getting started

Please first check the existing [Issues](https://github.com/krisleech/wisper/issues) 
and [Pull Requests](https://github.com/krisleech/wisper/pulls) to ensure your
issue has not already been discused.

## Bugs

Please submit a bug report to the issue tracker, with the version of Wisper
and Ruby you are using and a small code sample (or better yet a failing test).

## Features

Please open an issue with your proposed feature. We can discuss the feature and
if it is acceptable we can also discuss implimentation details. You will in
most cases have to submit a PR which adds the feature. 

Wisper is a micro library and will remain lean. Some features would be most
appropriate as an extension to Wisper.

We also have a [Gitter channel](https://gitter.im/krisleech/wisper) if you wish to discuss your ideas.

## Backlog /  Roadmap

The backlog for Wisper and related gems is on [Waffle](https://waffle.io/krisleech/wisper).

## Questions

Try the [Wiki](https://github.com/krisleech/wisper/wiki) first, the examples
and how to sections have lots of information.

Please ask questions on StackOverflow, [tagged wisper](https://stackoverflow.com/questions/tagged/wisper).

Feel free to ping me the URL on [Twitter](https://twitter.com/krisleech).

## Pull requests

* Fork the project, create a new branch from `v1` or `master`.
* Squash commits which are related.
* Write a [good commit message](http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html)
* Documentation only changes should have `[skip ci]` in the commit message
* Follow existing code style in terms of syntax, indentation etc.
* Add an entry to the CHANGELOG
* Do not bump the VERSION, but do indicate in the CHANGELOG if the change is
not backwards compatible.
* Issue a Pull Request

## Versions

The `v1` branch is a long lived branch and you should
branch from this if you wish to fix an issue in version `~> 1.0`.

The `master` branch will target the next version of Wisper.
