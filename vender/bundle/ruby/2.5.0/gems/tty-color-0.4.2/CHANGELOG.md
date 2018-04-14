# Change log

## [v0.4.2] - 2017-02-06

### Fixed
* Fix File namespaces

## [v0.4.1] - 2017-01-22

### Fixed
* Fix #windows? to reference top level constant

## [v0.4.0] - 2016-12-27

### Added
* Add #command? helper
* Add #windows? helper

### Changed
* Change to stop checking curses on Windows

### Fixed
* Fix Support#from_tput check to fail gracefully on non-unix systems
* Fix Mode#from_tput check to fail gracefuly on non-unix systems

## [v0.3.0] - 2016-01-13

### Fixed

* Fix #tty? check

## [v0.2.0] - 2016-01-13

### Changed

* Change ordering of color support checks by @janlelis
* Change ordering of color mode
* Change Support#from_env to check ansicon
* Ensure #tty? works for non-terminal devices
* Remove color executable

## [v0.1.0] - 2016-01-02

* Initial implementation and release

[v0.4.2]: https://github.com/peter-murach/tty-color/compare/v0.4.1...v0.4.2
[v0.4.1]: https://github.com/peter-murach/tty-color/compare/v0.4.0...v0.4.1
[v0.4.0]: https://github.com/peter-murach/tty-color/compare/v0.3.0...v0.4.0
[v0.3.0]: https://github.com/peter-murach/tty-color/compare/v0.2.0...v0.3.0
[v0.2.0]: https://github.com/peter-murach/tty-color/compare/v0.1.0...v0.2.0
[v0.1.0]: https://github.com/peter-murach/tty-color/compare/v0.1.0
