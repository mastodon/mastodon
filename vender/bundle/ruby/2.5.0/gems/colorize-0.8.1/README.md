colorize [![Gem Version](https://badge.fury.io/rb/colorize.svg)](http://badge.fury.io/rb/colorize) [![Build Status](https://travis-ci.org/fazibear/colorize.svg?branch=master)](https://travis-ci.org/fazibear/colorize) [![Code Climate](https://codeclimate.com/github/fazibear/colorize/badges/gpa.svg)](https://codeclimate.com/github/fazibear/colorize) [![Test Coverage](https://codeclimate.com/github/fazibear/colorize/badges/coverage.svg)](https://codeclimate.com/github/fazibear/colorize)
========

Ruby gem for colorizing text using ANSI escape sequences.
Extends `String` class or add a `ColorizedString` with methods to set text color, background color and text effects.

modes
-----

* `require 'colorize'` - Extends String class
* `require 'colorized_string'` - add ColorizedString class

features
--------

* change string color
* change string background
* change string effect
* display color samples
* disable colorization

usage
-----

```ruby
require 'colorize'

String.colors                       # return array of all possible colors names
String.modes                        # return array of all possible modes
String.color_samples                # displays color samples in all combinations
String.disable_colorization         # check if colorization is disabled
String.disable_colorization = false # enable colorization
String.disable_colorization false   # enable colorization
String.disable_colorization = true  # disable colorization
String.disable_colorization true    # disable colorization

puts "This is blue".colorize(:blue)
puts "This is light blue".colorize(:light_blue)
puts "This is also blue".colorize(:color => :blue)
puts "This is light blue with red background".colorize(:color => :light_blue, :background => :red)
puts "This is light blue with red background".colorize(:light_blue ).colorize( :background => :red)
puts "This is blue text on red".blue.on_red
puts "This is red on blue".colorize(:red).on_blue
puts "This is red on blue and underline".colorize(:red).on_blue.underline
puts "This is blue text on red".blue.on_red.blink
puts "This is uncolorized".blue.on_red.uncolorize
```

```ruby
require 'colorized_string'

ColorizedString.colors                       # return array of all possible colors names
ColorizedString.modes                        # return array of all possible modes
ColorizedString.color_samples                # displays color samples in all combinations
ColorizedString.disable_colorization         # check if colorization is disabled
ColorizedString.disable_colorization = false # enable colorization
ColorizedString.disable_colorization false   # enable colorization
ColorizedString.disable_colorization = true  # disable colorization
ColorizedString.disable_colorization true    # disable colorization

puts ColorizedString["This is blue"].colorize(:blue)
puts ColorizedString["This is light blue"].colorize(:light_blue)
puts ColorizedString["This is also blue"].colorize(:color => :blue)
puts ColorizedString["This is light blue with red background"].colorize(:color => :light_blue, :background => :red)
puts ColorizedString["This is light blue with red background"].colorize(:light_blue ).colorize( :background => :red)
puts ColorizedString["This is blue text on red"].blue.on_red
puts ColorizedString["This is red on blue"].colorize(:red).on_blue
puts ColorizedString["This is red on blue and underline"].colorize(:red).on_blue.underline
puts ColorizedString["This is blue text on red"].blue.on_red.blink
puts ColorizedString["This is uncolorized"].blue.on_red.uncolorize

puts ColorizedString.new("This is blue").blue
puts ColorizedString.new("This is light blue").colorize(:light_blue)
```

requirements
------------

* Win32/Console/ANSI (for Windows)

install
-------

* gem install colorize

*Note:* You may need to use sudo to install gems

license
-------

Copyright (C) 2007-2016 Michał Kalbarczyk

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along
    with this program; if not, write to the Free Software Foundation, Inc.,
    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
