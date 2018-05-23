# Change log

## [v0.7.2] - 2017-11-09

### Changed
* Change to load relative file paths
* Change to allow `#alias_color` to accept multiple colors by Jared Ning (@ordinaryzelig)

## [v0.7.1] - 2017-01-09

### Changed
* Change to load specfic files when needed
* Change to freeze ANSI attributes
* Change to directly assign enabled attribute

## [v0.7.0] - 2016-12-27

### Changed
* Enabled colors on Windows by default
* Update tty-color dependency

### Fixed
* Fix Color#decorate to prevent redecoration with the same color

## [v0.6.1] - 2016-04-09

### Fixed
* Fix #decorate to apply color to non zero length strings

## [v0.6.0] - 2016-01-15

### Added
* Add helper functions #foreground?, #backgroud?, #style to ANSI module
* Add ColorParser for parsing color symbols out of text
* Add Pastel#undecorate for parsing color names out of strings

### Changed
* Change to use tty-color for color capabilities detection
* Change to move enabled option to Pastel#new
* Improve performance of Color#lookup
* Change Color#decorate performance to be 6x faster!
* Change Color DSL styling to be 3x faster!

### Fixed
* Fix #strip to only remove color sequences
* Fix #decorate to pass through original text when decorating without colors
* Fix #decorate to work correctly with nested background colors

## [v0.5.3] - 2015-01-05

### Fixed
* Change gemspec to fix dependencies requirement

## [v0.5.2] - 2015-11-27 (Nov 27, 2015)

* Change Color#decorate to accept non-string values and immediately return

## [v0.5.1] - 2015-09-18

### Added
* Add ability to call detached instance with array access

## [v0.5.0] - 2015-09-13

### Added
* Add external dependency to check for color support
* Add #colored? to check if string has color escape codes
* Add #eachline option to allow coloring of multiline strings

### Changed
* Further refine #strip method accuracy

### Fixed
* Fix redefining inspect method
* Fix string representation for pastel instance

## [v0.4.0] - 2014-11-22

### Added
* Add ability to #detach color combination for later reuse
* Add ability to nest styles with blocks

### Fixed
* Fix Delegator#respond_to method to correctly report existence of methods

## [v0.3.0] - 2014-11-08

### Added
* Add ability to alias colors through #alias_color method
* Add ability to alias colors through the environment variable
* Improve performance of Pastel::Color styles and lookup methods

### Fixed
* Fix bug concerned with lack of escaping for nested styles

## [v0.2.1] - 2014-10-13

### Fixed
* Fix issue #1 with unitialize dependency

## [v0.2.0] - 2014-10-12

### Added
* Add #supports? to Color to check for terminal color support
* Add ability to force color support through :enabled option

### Changed
* Change gemspec to include equatable as dependency
* Change Delegator to stop creating instances and improve performance

[v0.7.2]: https://github.com/peter-murach/pastel/compare/v0.7.1...v0.7.2
[v0.7.1]: https://github.com/peter-murach/pastel/compare/v0.7.0...v0.7.1
[v0.7.0]: https://github.com/peter-murach/pastel/compare/v0.6.1...v0.7.0
[v0.6.1]: https://github.com/peter-murach/pastel/compare/v0.6.0...v0.6.1
[v0.6.0]: https://github.com/peter-murach/pastel/compare/v0.5.3...v0.6.0
[v0.5.3]: https://github.com/peter-murach/pastel/compare/v0.5.2...v0.5.3
[v0.5.2]: https://github.com/peter-murach/pastel/compare/v0.5.1...v0.5.2
[v0.5.1]: https://github.com/peter-murach/pastel/compare/v0.5.0...v0.5.1
[v0.5.0]: https://github.com/peter-murach/pastel/compare/v0.4.0...v0.5.0
[v0.4.0]: https://github.com/peter-murach/pastel/compare/v0.3.0...v0.4.0
[v0.3.0]: https://github.com/peter-murach/pastel/compare/v0.2.1...v0.3.0
[v0.2.1]: https://github.com/peter-murach/pastel/compare/v0.2.0...v0.2.1
[v0.2.0]: https://github.com/peter-murach/pastel/compare/v0.1.0...v0.2.0
[v0.1.0]: https://github.com/peter-murach/pastel/compare/v0.1.0
