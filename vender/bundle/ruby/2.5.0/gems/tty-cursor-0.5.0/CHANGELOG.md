# Change log

## [v0.5.0] - 2017-08-01

### Changed
* Change #save & #restore to work on major systems by Austin Blatt[@austb]

## [v0.4.0] - 2017-01-08

### Added
* Add #clear_char for erasing characters
* Add #clear_line_before for erasing line before the cursor
* Add #clear_line_after for erasing line after the cursor
* Add #column to move the cursor horizontally in the current line
* Add #row to move the cursor vertically in the current column

### Changed
* Remove #move_start
* Change #next_line to move the cursor to beginning of the line
* Change #clear_line to move the cursor to beginning of the line
* Change alias_method to alias

### Fixed
* Fix #clear_line to correctly clear whole line

## [v0.3.0] - 2016-05-21

### Fixed
* Fix prev_line to work in iTerm2 and Putty by @m-o-e

## [v0.2.0] - 2015-12-28

### Changed
* Change #clear_lines to clear first and move up/down

## [v0.1.0] - 2015-11-28

* Initial implementation and release

[v0.5.0]: https://github.com/peter-murach/tty-cursor/compare/v0.4.0...v0.5.0
[v0.4.0]: https://github.com/peter-murach/tty-cursor/compare/v0.3.0...v0.4.0
[v0.3.0]: https://github.com/peter-murach/tty-cursor/compare/v0.2.0...v0.3.0
[v0.2.0]: https://github.com/peter-murach/tty-cursor/compare/v0.1.0...v0.2.0
[v0.1.0]: https://github.com/peter-murach/tty-cursor/compare/v0.1.0
