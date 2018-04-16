# Change log

## [v0.2.0] - 2018-01-01

### Added
* Add home & end keys support in #read_line
* Add tty-screen & tty-cursor dependencies

### Changed
* Change Codes to Keys and inverse keys lookup to allow for different system keys matching same name.
* Change Reader#initialize to only accept options and make input and output options as well.
* Change #read_line to print newline character in noecho mode
* Change Reader::Line to include prompt prefix
* Change Reader#initialize to only accept options in place of positional arguments
* Change Reader to expose history options

### Fixed
* Fix issues with recognising :home & :end keys on different terminals
* Fix #read_line to work with strings spanning multiple screen widths and allow copy-pasting a long string without repeating prompt
* Fix backspace keystroke in cooked mode
* Fix history to only save lines in echo mode

## [v0.1.0] - 2017-08-30

* Initial implementation and release

[v0.2.0]: https://github.com/piotrmurach/tty-reader/compare/v0.1.0...v0.2.0
[v0.1.0]: https://github.com/piotrmurach/tty-reader/compare/v0.1.0
