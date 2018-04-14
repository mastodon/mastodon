<div align="center">
  <img width="215" src="https://cdn.rawgit.com/piotrmurach/pastel/master/assets/pastel_logo.png" alt="pastel logo" />
</div>

# Pastel

[![Gem Version](https://badge.fury.io/rb/pastel.svg)][gem]
[![Build Status](https://secure.travis-ci.org/piotrmurach/pastel.svg?branch=master)][travis]
[![Build status](https://ci.appveyor.com/api/projects/status/9blbjfq42o4v1rk4?svg=true)][appveyor]
[![Code Climate](https://codeclimate.com/github/piotrmurach/pastel/badges/gpa.svg)][codeclimate]
[![Coverage Status](https://coveralls.io/repos/github/piotrmurach/pastel/badge.svg)][coverage]
[![Inline docs](http://inch-ci.org/github/piotrmurach/pastel.svg?branch=master)][inchpages]

[gem]: http://badge.fury.io/rb/pastel
[travis]: http://travis-ci.org/piotrmurach/pastel
[appveyor]: https://ci.appveyor.com/project/piotrmurach/pastel
[codeclimate]: https://codeclimate.com/github/piotrmurach/pastel
[coverage]: https://coveralls.io/github/piotrmurach/pastel
[inchpages]: http://inch-ci.org/github/piotrmurach/pastel

> Terminal output styling with intuitive and clean API that doesn't monkey patch String class.

**Pastel** is minimal and focused to work in all terminal emulators.

![screenshot](https://github.com/piotrmurach/pastel/raw/master/assets/screenshot.png)

**Pastel** provides independent coloring component for [TTY](https://github.com/piotrmurach/tty) toolkit.

## Features

* Doesn't monkey patch `String`
* Intuitive and expressive API
* Minimal and focused to work on all terminal emulators
* Auto-detection of color support
* Allows nested styles
* Performant

## Installation

Add this line to your application's Gemfile:

    gem 'pastel'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pastel

## Contents

* [1. Usage](#1-usage)
* [2. Interface](#2-interface)
  * [2.1 Color](#21-color)
  * [2.2 Decorate](#22-decorate)
  * [2.3 Undecorate](#23-undecorate)
  * [2.4 Detach](#24-detach)
  * [2.5 Strip](#25-strip)
  * [2.6 Styles](#26-styles)
  * [2.7 Lookup](#27-lookup)
  * [2.8 Valid?](#28-valid)
  * [2.9 Colored?](#29-colored)
  * [2.10 Enabled?](#210-enabled)
  * [2.11 Eachline](#211-eachline)
  * [2.12 Alias Color](#212-alias-color)
* [3. Supported Colors](#3-supported-colors)
* [4. Environment](#4-environment)
* [5. Command line](#5-command-line)

## 1 Usage

**Pastel** provides a simple, minimal and intuitive API for styling your strings:

```ruby
pastel = Pastel.new

puts pastel.red('Unicorns!')
```

**Pastel** doesn't print the colored string out, just returns it, you'll have to print it yourself.

You can compose multiple styles through chainable API:

```ruby
pastel.red.on_green.bold('Unicorns!')
```

It allows you to combine styled strings with unstyled ones:

```ruby
pastel.red('Unicorns') + ' will rule ' + pastel.green('the World!')
```

It supports variable number of arguments:

```ruby
pastel.red('Unicorns', 'are', 'running', 'everywhere!')
```

You can also nest styles as follows:

```ruby
pastel.red('Unicorns ', pastel.on_green('everywhere!'))
```

Nesting is smart enough to know where one color ends and another one starts:

```ruby
pastel.red('Unicorns ' + pastel.green('everywhere') + pastel.on_yellow('!'))
```

You can also nest styles inside blocks:

```ruby
pastel.red.on_green('Unicorns') {
  green.on_red('will ', 'dominate') {
    yellow('the world!')
  }
}
```

When dealing with multiline strings you can set `eachline` option(more info see [eachline](#211-eachline)):

```
pastel = Pastel.new(eachline: "\n")
```

You can also predefine needed styles and reuse them:

```ruby
error    = pastel.red.bold.detach
warning  = pastel.yellow.detach

puts error.('Error!')
puts warning.('Warning')
```

If your output is redirected to a file, you probably don't want Pastel to add color to your text.
See https://github.com/piotrmurach/pastel#210-enabled for a way to easily accomplish this.

**Pastel** has companion library called `pastel-cli` that allows you to style text in terminal via `pastel` executable:

```bash
$ pastel green 'Unicorns & rainbows!'
```

## 2 Interface

### 2.1 Color

pastel.`<color>[.<color>...](string, [string...])`

Color styles are invoked as method calls with a string argument. A given color can take any number of strings as arguments. Then it returns a colored string which isn't printed out to terminal. You need to print it yourself if you need to. This is done so that you can save it as a string, pass to something else, send it to a file handle and so on.

```ruby
pastel.red('Unicorns ', pastel.bold.underline('everywhere'), '!')
```

Please refer to [3. Supported Colors](#3-supported-colors) section for full list of supported styles.

### 2.2 Decorate

This method is a lower level string styling call that takes as the first argument the string to style followed by any number of color attributes, and returns string wrapped in styles.

```ruby
pastel.decorate('Unicorn', :green, :on_blue, :bold)
```

This method will be useful in situations where colors are provided as a list of parameters that have been generated dynamically.

### 2.3 Undecorate

It performs the opposite to `decorate` method by turning color escape sequences found in the string into a list of hash objects corresponding with the attribute names set by those sequences. Depending on the parsed string, each hash object may contain `:foreground`, `:background`, `:text` and/or `:style` keys.

```ruby
pastel.undecorate("\e[32mfoo\e[0m \e[31mbar\e[0m")
# => [{foreground: :green, text: 'foo'}, {text: ' '}, {foreground: :red, text: 'bar'}]
```

To translate the color name into sequence use [lookup](#27-lookup)

### 2.4 Detach

The `detach` method allows to keep all the associated colors with the detached instance for later reference. This method is useful when detached colors are being reused frequently and thus shorthand version is preferred. The detached object can be invoked using `call` method or it's shorthand `.()`, as well as array like access `[]`. For example, the following are equivalent examples of detaching colors:

```ruby
notice = pastel.blue.bold.detach

notice.call('Unicorns running')
notice.('Unicorns running')
notice['Unicorns running']
```

### 2.5 Strip

Strip only color sequence characters from the provided strings and preserve any movement codes or other escape sequences. The return value will be either array of modified strings or a single string. The arguments are not modified.

```ruby
pastel.strip("\e[1A\e[1m\e[34mbold blue text\e[0m")  # => "\e[1Abold blue text"
```

### 2.6 Styles

To get a full list of supported styles with the corresponding color codes do:

```ruby
pastel.styles
```

### 2.7 Lookup

To perform translation of color name into ansi escape code use `lookup`:

```ruby
color.lookup(:red)  # => "\e[31m"
```

### 2.8 Valid?

Determine whether a color or a list of colors are valid. `valid?` takes one or more attribute strings or symbols and returns true if all attributes are known and false otherwise.

```ruby
pastel.valid?(:red, :blue) # => true
pastel.valid?(:unicorn)    # => false
```

### 2.9 Colored?

In order to determine if string has color escape codes use `colored?` like so

```ruby
pastel.colored?("\e[31mcolorful\e[0m")  # => true
```

### 2.10 Enabled?

In order to detect if your terminal supports coloring do:

```ruby
pastel.enabled?   # => false
```

In cases when the color support is not provided no styling will be applied to the colored string. Moreover, you can force **Pastel** to always print out string with coloring switched on:

```ruby
pastel = Pastel.new(enabled: true)
pastel.enabled?   # => true
```

If you are outputting to stdout or stderr, and want to suppress color if output is redirected to a file, 
you can set the enabled attribute dynamically, as in:

```ruby
stdout_pastel = Pastel.new(enabled: $stdout.tty?)
stderr_pastel = Pastel.new(enabled: $stderr.tty?)
```

### 2.11 Eachline

Normally **Pastel** colors string by putting color codes at the beginning and end of the string, but if you provide `eachline` option set to some string, that string will be considered the line delimiter. Consequently, each line will be separately colored with escape sequence and reset code at the end. This option is desirable if the output string contains newlines and you're using background colors. Since color code that spans more than one line is often interpreted by terminal as providing background for all the lines that follow. This in turn may cause programs such as pagers to spill the colors throughout the text. In most cases you will want to set `eachline` to `\n` character like so:

```ruby
pastel = Pastel.new(eachline: "\n")
pastel.red("foo\nbar")  # => "\e[31mfoo\e[0m\n\e[31mbar\e[0m"
```

### 2.12 Alias Color

In order to setup an alias for standard colors do:

```ruby
pastel.alias_color(:funky, :red, :bold)
```

From that point forward, `:funky` alias can be passed to `decorate`, `valid?` with the same meaning as standard colors:

```ruby
pastel.funky.on_green('unicorn')   # => will use :red, :bold color
```

This method allows you to give more meaningful names to existing colors.

You can also use the `PASTEL_COLORS_ALIASES` environment variable (see [Environment](#4-environment)) to specify aliases.

Note: Aliases are global and affect all callers in the same process.

## 3 Supported Colors

**Pastel** works with terminal emulators that support minimum sixteen colors. It provides `16` basic colors and `8` styles with further `16` bright color pairs. The corresponding bright color is obtained by prepending the `bright` to the normal color name. For example, color `red` will have `bright_red` as its pair.

The variant with `on_` prefix will style the text background color.

The foreground colors:

* `black`
* `red`
* `green`
* `yellow`
* `blue`
* `magenta`
* `cyan`
* `white`
* `bright_black`
* `bright_red`
* `bright_green`
* `bright_yellow`
* `bright_blue`
* `bright_magenta`
* `bright_cyan`
* `bright_white`

The background colors:

* `on_black`
* `on_red`
* `on_green`
* `on_yellow`
* `on_blue`
* `on_magenta`
* `on_cyan`
* `on_white`
* `on_bright_black`
* `on_bright_red`
* `on_bright_green`
* `on_bright_yellow`
* `on_bright_blue`
* `on_bright_magenta`
* `on_bright_cyan`
* `on_bright_white`

Generic styles:

* `clear`
* `bold`
* `dim`
* `italic`
* `underline`
* `inverse`
* `hidden`
* `strikethrough`

## 4 Environment

### 4.1 PASTEL_COLORS_ALIASES

This environment variable allows you to specify custom color aliases at runtime that will be understood by **Pastel**. The environment variable is read and used when the instance of **Pastel** is created. You can also use `alias_color` to create aliases.

Only alphanumeric and `_` and `.` are allowed in the alias names with the following format:

```ruby
PASTEL_COLORS_ALIASES='newcolor_1=red,newcolor_2=on_green,funky=red.bold'
```

## 5. Command line

You can also install [pastel-cli](https://github.com/piotrmurach/pastel-cli) to use `pastel` executable in terminal:

```bash
$ pastel green 'Unicorns & rainbows!'
```

## Contributing

1. Fork it ( https://github.com/piotrmurach/pastel/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Copyright

Copyright (c) 2014-2017 Piotr Murach. See LICENSE for further details.
