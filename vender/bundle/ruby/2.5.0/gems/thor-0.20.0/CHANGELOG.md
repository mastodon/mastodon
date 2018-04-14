## 0.20.0
* Add `check_default_type!` to check if the default value of an option matches the defined type.
  It removes the warning on usage and gives the command authors the possibility to check for programming errors.

* Add `disable_required_check!` to disable check for required options in some commands.
  It is a substitute of `disable_class_options` that was not working as intended.

* Add `inject_into_module`.

## 0.19.4, release 2016-11-28
* Rename `Thor::Base#thor_reserved_word?` to `#is_thor_reserved_word?`

## 0.19.3, release 2016-11-27
* Output a warning instead of raising an exception when a default option value doesn't match its specified type

## 0.19.2, release 2016-11-26
* Fix bug with handling of colors passed to `ask` (and methods like `yes?` and `no?` which it underpins)
* Allow numeric arguments to be negative
* Ensure that default option values are of the specified type (e.g. you can't specify `"foo"` as the default for a numeric option), but make symbols and strings interchangeable
* Add `Thor::Shell::Basic#indent` method for intending output
* Fix `remove_command` for an inherited command (see #451)
* Allow hash arguments to only have each key provided once (see #455)
* Allow commands to disable class options, for instance for "help" commands (see #363)
* Do not generate a negative option (`--no-no-foo`) for already negative boolean options (`--no-foo`)
* Improve compatibility of `Thor::CoreExt::HashWithIndifferentAccess` with Ruby standard library `Hash`
* Allow specifying a custom binding for template evaluation (e.g. `#key?` and `#fetch`)
* Fix support for subcommand-specific "help"s
* Use a string buffer when handling ERB for Ruby 2.3 compatibility
* Update dependencies

## 0.19.1, release 2014-03-24
* Fix `say` non-String break regression

## 0.19.0, release 2014-03-22
* Add support for a default to #ask
* Avoid @namespace not initialized warning
* Avoid private attribute? warning
* Fix initializing with unknown options
* Loosen required_rubygems_version for compatibility with Ubuntu 10.04
* Shell#ask: support a noecho option for stdin
* Shell#ask: change API to be :echo => false
* Display a message without a stack trace for ambiguous commands
* Make say and say_status thread safe
* Dependency for console io version check
* Alias --help to help on subcommands
* Use mime-types 1.x for Ruby 1.8.7 compatibility for Ruby 1.8 only
* Accept .tt files as templates
* Check if numeric value is in enum
* Use Readline for user input
* Fix dispatching of subcommands (concerning :help and *args)
* Fix warnings when running specs with `$VERBOSE = true`
* Make subcommand help more consistent
* Make the current command chain accessible in command

## 0.18.1, release 2013-03-30
* Revert regressions found in 0.18.0

## 0.18.0, release 2013-03-26
* Remove rake2thor
* Only display colors if output medium supports colors
* Pass parent_options to subcommands
* Fix non-dash-prefixed aliases
* Make error messages more helpful
* Rename "task" to "command"
* Add the method to allow for custom package name

## 0.17.0, release 2013-01-24
* Add better support for tasks that accept arbitrary additional arguments (e.g. things like `bundle exec`)
* Add #stop_on_unknown_option!
* Only strip from stdin.gets if it wasn't ended with EOF
* Allow "send" as a task name
* Allow passing options as arguments after "--"
* Autoload Thor::Group

## 0.16.0, release 2012-08-14
* Add enum to string arguments

## 0.15.4, release 2012-06-29
* Fix regression when destination root contains reserved regexp characters

## 0.15.3, release 2012-06-18
* Support strict_args_position! for backwards compatibility
* Escape Dir glob characters in paths

## 0.15.2, released 2012-05-07
* Added print_in_columns
* Exposed terminal_width as a public API

## 0.15.1, release 2012-05-06
* Fix Ruby 1.8 truncation bug with unicode chars
* Fix shell delegate methods to pass their block
* Don't output trailing spaces when printing the last column in a table

## 0.15, released 2012-04-29
* Alias method_options to options
* Refactor say to allow multiple colors
* Exposed error as a public API
* Exposed file_collision as a public API
* Exposed print_wrapped as a public API
* Exposed set_color as a public API
* Fix number-formatting bugs in print_table
* Fix "indent" typo in print_table
* Fix Errno::EPIPE when piping tasks to `head`
* More friendly error messages

## 0.14, released 2010-07-25
* Added CreateLink class and #link_file method
* Made Thor::Actions#run use system as default method for system calls
* Allow use of private methods from superclass as tasks
* Added mute(&block) method which allows to run block without any output
* Removed config[:pretend]
* Enabled underscores for command line switches
* Added Thor::Base.basename which is used by both Thor.banner and Thor::Group.banner
* Deprecated invoke() without arguments
* Added :only and :except to check_unknown_options

## 0.13, released 2010-02-03
* Added :lazy_default which is only triggered if a switch is given
* Added Thor::Shell::HTML
* Added subcommands
* Decoupled Thor::Group and Thor, so it's easier to vendor
* Added check_unknown_options! in case you want error messages to be raised in valid switches
* run(command) should return the results of command

## 0.12, released 2010-01-02
* Methods generated by attr_* are automatically not marked as tasks
* inject_into_file does not add the same content twice, unless :force is set
* Removed rr in favor to rspec mock framework
* Improved output for thor -T
* [#7] Do not force white color on status
* [#8] Yield a block with the filename on directory

## 0.11, released 2009-07-01
* Added a rake compatibility layer. It allows you to use spec and rdoc tasks on
  Thor classes.
* BACKWARDS INCOMPATIBLE: aliases are not generated automatically anymore
  since it may cause wrong behavior in the invocation system.
* thor help now show information about any class/task. All those calls are
  possible:

      thor help describe
      thor help describe:amazing
  Or even with default namespaces:

      thor help :spec
* Thor::Runner now invokes the default task if none is supplied:

      thor describe # invokes the default task, usually help
* Thor::Runner now works with mappings:

      thor describe -h
* Added some documentation and code refactoring.

## 0.9.8, released 2008-10-20
* Fixed some tiny issues that were introduced lately.

## 0.9.7, released 2008-10-13
* Setting global method options on the initialize method works as expected:
  All other tasks will accept these global options in addition to their own.
* Added 'group' notion to Thor task sets (class Thor); by default all tasks
  are in the 'standard' group. Running 'thor -T' will only show the standard
  tasks - adding --all will show all tasks. You can also filter on a specific
  group using the --group option: thor -T --group advanced

## 0.9.6, released 2008-09-13
* Generic improvements

## 0.9.5, released 2008-08-27
* Improve Windows compatibility
* Update (incorrect) README and task.thor sample file
* Options hash is now frozen (once returned)
* Allow magic predicates on options object. For instance: `options.force?`
* Add support for :numeric type
* BACKWARDS INCOMPATIBLE: Refactor Thor::Options. You cannot access shorthand forms in options hash anymore (for instance, options[:f])
* Allow specifying optional args with default values: method_options(:user => "mislav")
* Don't write options for nil or false values. This allows, for example, turning color off when running specs.
* Exit with the status of the spec command to help CI stuff out some.

## 0.9.4, released 2008-08-13
* Try to add Windows compatibility.
* BACKWARDS INCOMPATIBLE: options hash is now accessed as a property in your class and is not passed as last argument anymore
* Allow options at the beginning of the argument list as well as the end.
* Make options available with symbol keys in addition to string keys.
* Allow true to be passed to Thor#method_options to denote a boolean option.
* If loading a thor file fails, don't give up, just print a warning and keep going.
* Make sure that we re-raise errors if they happened further down the pipe than we care about.
* Only delete the old file on updating when the installation of the new one is a success
* Make it Ruby 1.8.5 compatible.
* Don't raise an error if a boolean switch is defined multiple times.
* Thor::Options now doesn't parse through things that look like options but aren't.
* Add URI detection to install task, and make sure we don't append ".thor" to URIs
* Add rake2thor to the gem binfiles.
* Make sure local Thorfiles override system-wide ones.
