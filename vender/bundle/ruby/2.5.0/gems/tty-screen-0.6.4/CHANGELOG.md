# Change log

## [v0.6.4] - 2017-12-22

### Fixed
* Fix to suppress stderr output from run_command by Tero Marttila(@SpComb)

## [v0.6.3] - 2017-11-22

### Changed
* Change #size_from_tput & #size_from_stty to capture generic IO and command execution errors to make the calls more robust

### Fixed
* Fix #size_from_ioctl to handle Errno errors and deal with Errno::EOPNOTSUPP

## [v0.6.2] - 2017-11-04

### Fixed
* Fix #size_from_java to provide size only for non-zero values
* Fix #size_from_ioctl to provide size only for non-zero values

## [v0.6.1] - 2017-10-29

### Fixed
* Fix #size_from_win_api to provide size if non zero to avoid [1,1] size

## [v0.6.0] - 2017-10-29

### Added
* Add #size_from_ioctl check for reading terminal size with Unix ioctl
* Add #size_from_java check for reading terminal size from Java on JRuby
* Add #size_from_win_api check for reading terminal size from Windows C API

### Changed
* Change TTY::Screen to a module without any state
* Change to prefix all checks with `size` keyword
* Change gemspec to require ruby >= 2.0.0
* Remove #try_io_console and inline with io-console check
* Remove #default_size and replace with constant
* Remove TTY::Screen::Size class

## [v0.5.1] - 2017-10-26

### Changed
* Change #from_io_console to return nil when no size present
* Change #run_command to silently ignore any errors

### Fixed
* Fix #from_readline check to prevent from failing on missing api call
* Fix #from_stty to only extract size when stty command returns output
* Fix #run_command to correctly capture command output and fix #from_tput check

## [v0.5.0] - 2016-01-03

### Changed
* Change size to accept environment as input
* Remove Color detection, available as tty-color gem dependency

## [v0.4.3] - 2015-11-01

### Added
* Add NoValue to Color class to mark failure of reading color value

### Changed
* Change Color class supports? to recognize lack of color value

### Fixed
* Fix issue with #from_curses method and remove ensure block

## [v0.4.2] - 2015-10-31

### Changed
* Change visibility of output to prevent warnings

## [v0.4.1] - 2015-10-31

### Changed
* Change to switch off verbose mode by default

## [v0.4.0] - 2015-09-12

### Added
* Add terminal color support detection

## [v0.3.0] - 2015-09-11

### Fixed
* Fix bug loading standard library

## [v0.2.0] - 2015-05-11

### Changed
* Change to stop memoization of screen class instance method

### Fixed
* Fix bug with screen detection from_io_console by @luxflux

[v0.6.4]: https://github.com/peter-murach/tty-screen/compare/v0.6.3...v0.6.4
[v0.6.3]: https://github.com/peter-murach/tty-screen/compare/v0.6.2...v0.6.3
[v0.6.2]: https://github.com/peter-murach/tty-screen/compare/v0.6.1...v0.6.2
[v0.6.1]: https://github.com/peter-murach/tty-screen/compare/v0.6.0...v0.6.1
[v0.6.0]: https://github.com/peter-murach/tty-screen/compare/v0.5.1...v0.6.0
[v0.5.1]: https://github.com/peter-murach/tty-screen/compare/v0.5.0...v0.5.1
[v0.5.0]: https://github.com/peter-murach/tty-screen/compare/v0.4.3...v0.5.0
[v0.4.3]: https://github.com/peter-murach/tty-screen/compare/v0.4.2...v0.4.3
[v0.4.2]: https://github.com/peter-murach/tty-screen/compare/v0.4.1...v0.4.2
[v0.4.1]: https://github.com/peter-murach/tty-screen/compare/v0.4.0...v0.4.1
[v0.4.0]: https://github.com/peter-murach/tty-screen/compare/v0.3.0...v0.4.0
[v0.3.0]: https://github.com/peter-murach/tty-screen/compare/v0.2.0...v0.3.0
[v0.2.0]: https://github.com/peter-murach/tty-screen/compare/v0.1.0...v0.2.0
[v0.1.0]: https://github.com/peter-murach/tty-screen/compare/v0.1.0
