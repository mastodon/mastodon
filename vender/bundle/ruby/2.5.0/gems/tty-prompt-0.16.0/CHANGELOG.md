# Change log

## [v0.16.0] - 2018-03-11

### Added
* Add :disabled key to Choice
* Add ability to disable choices in #select, #multi_selct & #enum_select prompts
* Add #frozen_string_literal to all files

### Changed
* Change Choice#from to allow parsing different data strucutures
* Change all classes to prevent strings mutations
* Change Timeout to cleanly terminate keypress input without raising errors

### Fixed
* Fix #select, #enum_select & #multi_select navigation to work correctly with items longer than terminal screen width
* Fix timeout on Ruby 2.5 and stop raising Timeout::Error

## [v0.15.0] - 2018-02-08

### Added
* Add ability to filter list items in #select, #multi_select & #enum_selct prompts by Saverio Miroddi(@saveriomiroddi)
* Add support for array of values for an answer collector key by Danny Hadley(@dadleyy)

### Changed
* Relax dependency on timers by Andy Brody(@brodygov)

## [v0.14.0] - 2018-01-01

### Added
* Add :cycle option to #select, #multi_select & #enum_select prompts to allow toggling between infinite and bounded list by Jonas Müller(@muellerj)

### Changed
* Change #multi_selct, #select & #enum_select to stop cycling options by default by Jona Müller(@muellerj)
* Change gemspec to require ruby >= 2.0.0
* Change #slider prompt to display slider next to query and help underneath
* Change to use tty-reader v0.2.0 with new line editing features for processing long inputs

### Fixed
* Fix Paginator & EnumPaginator to allow only positive integer values by Andy Brody(@ab)
* Fix EnumSelect to report on default option out of range and raise correctly
* Fix #ask :file & :path converters to correctly locate the files
* Fix #ask, #multiline to correctly handle long strings that wrap around screen
* Fix #slider prompt to correctly scale sliding

## [v0.13.2] - 2017-08-30

### Changed
* Change to extract TTY::Prompt::Reader to its own dependency

## [v0.13.1] - 2017-08-16

### Added
* Add ability to manually cancel the time scheduler

### Changed
* Change #keypress to use new scheduler cancelling
* Change Reader to inline interrupt to allow for early exit

### Fix
* Fix keypress reading on Windows to distinguish between blocking & non-blocking IO

## [v0.13.0] - 2017-08-11

### Changed
* Change Timeout to use clock time instead of sleep to measure interval
* Upgrade tty-cursor to fix save & restore

### Fixed
* Fix keypress with timeout option to cleanly stop timeout thread
* Fix Reader on Windows to stop blocking when waiting for key press

## [v0.12.0] - 2017-03-19

### Added
* Add Multiline question type
* Add Keypress question type
* Add Reader::History for storing buffered lines
* Add Reader::Line for line abstraction

### Changed
* Remove :read option from Question
* Chnage Reader#read_line to handle raw mode for processing special
  characters such as Ctrl+x, navigate through history buffer
  using up/down arrows, allow editing current line by moving left/right
  with arrow keys and inserting content
* Change Reader#read_multiline to gather multi line input correctly,
  skip empty lines and terminate when Ctrl+d and Ctrl+z are pressed
* Change Reader::Mode to check if tty is available by Matt Martyn (@MMartyn)
* Change #keypress prompt to correctly refresh line and accept :keys & :timeout options

### Fixed
* Fix issue with #select, #multi_selct, #enum_select when choices are
  provided as hash object together with prompt options.
* Fix issue with default parameter for yes?/no? prompt by Carlos Fonseca (@carlosefonseca)
* Fix List#help to allow setting help text through DSL

## [v0.11.0] - 2017-02-26

### Added
* Add Console for reading input characters on Unix systems
* Add WinConsole for reading input characters on Windows systems
* Add WindowsApi to allow for calls to external Windows api
* Add echo support to multilist by Keith Keith T. Garner(@ktgeek)

### Changed
* Change Reader to use Console for input reading
* Change Codes to use codepoints instead of strings
* Change Reader#read_line to match #gets behaviour
* Change Symbols to provide Unicode support on windows
* Change Slider to display Unicode when possible
* Change ConverterRegistry to be immutable
* Change Reader to expose #trigger in place of #publish for events firing

### Fixed
* Fix `modify` throwing exception, when user enters empty input by Igor Rzegocki(@ajgon)
* Fix #clear_line behaviour by using tty-cursor 0.4.0 to work in all terminals
* Fix paging issue for lists shorter than :per_page value repeating title
* Fix #mask prompt to correctly match input on Windows
* Fix @mask to use default error messages
* Fix #select & #multi_select prompts to allow changing options with arrow keys on Windows
* Fix #echo to work correctly in zsh shell by štef(@d4be4st)
* Fix Slider#keyright event accepting max value outside of range
* Fix 2.4.0 conversion errors by using necromancer 0.4.0
* Fix #enum_select preventing selection of first item

## [v0.10.1] - 2017-02-06

### Fixed
* Fix File namespacing

## [v0.10.0] - 2017-01-01

### Added
* Add :enable_color option for toggling colors support

### Changed
* Update pastel dependency version

## [v0.9.0] - 2016-12-20

### Added
* Add ability to paginate choices list for #select, #multi_select & #enum_select
  with :per_page, :page_info and :default options
* Add ability to switch through options in #select & #multi_select using the tab key

### Fixed
* Fix readers to accept multibyte characters reported by Jaehyun Shin(@keepcosmos)

## [v0.8.0] - 2016-11-29

### Added
* Add ability to publish custom key events for VIM keybindings customisations etc...

### Fixed
* Fix Reader#read_char to use Ruby internal buffers instead of direct system call by @kke(Kimmo Lehto)
* Fix issue with #ask required & validate checks to take into account required when validating values
* Fix bug with #read_keypress to handle function keys and meta navigation keys
* Fix issue with default messages not displaying for `range`, `required` and `validate`

## [v0.7.1] - 2016-08-07

### Fixed
* Fix Reader::Mode to include standard io library

## [v0.7.0] - 2016-07-17

### Added
* Add :interrupt_handler option to customise keyboard interrupt behaviour

### Changed
* Remove tty-platform dependency

### Fixed
* Fix Reader#read_keypress issue when handling interrupt signal by Ondrej Moravcik(@ondra-m)
* Fix raw & echo modes to use standard library support by Kim Burgestrand(@Burgestrand)

## [v0.6.0] - 2016-05-21

### Changed
* Upgrade tty-cursor dependency

### Fixed
* Fix issue with reader trapping signals by @kylekyle
* Fix expand to use new prev_line implementation

## [v0.5.0] - 2016-03-28

### Added
* Add ConfirmQuestion for #yes? & #no? calls
* Add ability to collect more than one answer through #collect call
* Add Choices#find_by for selecting choice based on attribute
* Add Prompt#expand for expanding key options
* Add :active_color, :help_color, :prefix options for customizing prompts display

### Changed
* Change Choice#from to allow for coersion of complex objects with keys
* Change Choices#pluck to search through object attributes
* Change #select :enum option help text to display actual numbers range

### Fixed
* Fix #no? to correctly ask negative question by @ondra-m
* Fix #ask :default option to handle nil or empty string
* Fix #multi_select :default option and color changing

## [v0.4.0] - 2016-02-08

### Added
* Add :enum option for #select & #multi_select to allow for numerical selection by @rtoshiro
* Add new key event types to KeyEvent
* Add #slider for picking values from range of numbers
* Add #enum_select for selecting option from enumerated list
* Add ability to configure error messages for #ask call
* Add new ConversionError type

### Changed
* Move #blank? to Utils
* Update pastel dependency

## [v0.3.0] - 2015-12-28

### Added
* Add prefix option to prompt to customize #ask, #select, #multi_select
* Add default printing to #ask
* Add #yes?/#no? boolean queries
* Add Evaluator and Result for validation checking to Question
* Add ability for #ask to display error messages on failed validation
* Add ability to specify in-built names for validation e.i. :email
* Add KeyEvent for keyboard events publishing to Reader
* Add #read_multiline to Reader
* Add :convert option for ask configuration
* Add ability to specify custom proc converters
* Add #ask_keypress to gather character input
* Add #ask_multiline to gather multiline input
* Add MaskedQuestion & #mask method for masking input stream characters

### Changed
* Change Reader#read_keypress to be robust and read correctly byte sequences
* Change Reader#getc to #read_line and extend arguments with echo option
* Extract cursor movement to dependency tty-cursor
* Change List & MultiList to subscribe to keyboard events
* Change to move mode inside reader namespace
* Remove Response & Error objects
* Remove :char option from #ask
* Change :read option to specify mode of reading out of :line, :multiline, :keypress
* Rename #confirm to #ok

## [v0.2.0] - 2015-11-23

### Added
* Add ability to select choice form list #select
* Add ability to select multiple options #multi_select
* Add :read option to #ask for reading specific type input

### Changed
* Change #ask api to be similar to #select and #multi_select behaviour
* Change #ask :argument option to be :required
* Remove :valid option from #ask as #select is a better solution

## [v0.1.0] - 2015-11-01

* Initial implementation and release

[v0.16.0]: https://github.com/piotrmurach/tty-prompt/compare/v0.15.0...v0.16.0
[v0.15.0]: https://github.com/piotrmurach/tty-prompt/compare/v0.14.0...v0.15.0
[v0.14.0]: https://github.com/piotrmurach/tty-prompt/compare/v0.13.2...v0.14.0
[v0.13.2]: https://github.com/piotrmurach/tty-prompt/compare/v0.13.1...v0.13.2
[v0.13.1]: https://github.com/piotrmurach/tty-prompt/compare/v0.13.0...v0.13.1
[v0.13.0]: https://github.com/piotrmurach/tty-prompt/compare/v0.12.0...v0.13.0
[v0.12.0]: https://github.com/piotrmurach/tty-prompt/compare/v0.11.0...v0.12.0
[v0.11.0]: https://github.com/piotrmurach/tty-prompt/compare/v0.10.1...v0.11.0
[v0.10.1]: https://github.com/piotrmurach/tty-prompt/compare/v0.10.0...v0.10.1
[v0.10.0]: https://github.com/piotrmurach/tty-prompt/compare/v0.9.0...v0.10.0
[v0.9.0]: https://github.com/piotrmurach/tty-prompt/compare/v0.8.0...v0.9.0
[v0.8.0]: https://github.com/piotrmurach/tty-prompt/compare/v0.7.1...v0.8.0
[v0.7.1]: https://github.com/piotrmurach/tty-prompt/compare/v0.7.0...v0.7.1
[v0.7.0]: https://github.com/piotrmurach/tty-prompt/compare/v0.6.0...v0.7.0
[v0.6.0]: https://github.com/piotrmurach/tty-prompt/compare/v0.5.0...v0.6.0
[v0.5.0]: https://github.com/piotrmurach/tty-prompt/compare/v0.4.0...v0.5.0
[v0.4.0]: https://github.com/piotrmurach/tty-prompt/compare/v0.3.0...v0.4.0
[v0.3.0]: https://github.com/piotrmurach/tty-prompt/compare/v0.2.0...v0.3.0
[v0.2.0]: https://github.com/piotrmurach/tty-prompt/compare/v0.1.0...v0.2.0
[v0.1.0]: https://github.com/piotrmurach/tty-prompt/compare/v0.1.0
