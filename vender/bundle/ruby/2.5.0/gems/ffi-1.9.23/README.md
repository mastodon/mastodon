# ruby-ffi https://wiki.github.com/ffi/ffi [![Build Status](https://travis-ci.org/ffi/ffi.png?branch=master)](https://travis-ci.org/ffi/ffi) [![Build status Windows](https://ci.appveyor.com/api/projects/status/r8wxn1sd4s794gg1/branch/master?svg=true)](https://ci.appveyor.com/project/larskanis/ffi-aofqa/branch/master)

## Description

Ruby-FFI is a ruby extension for programmatically loading dynamic
libraries, binding functions within them, and calling those functions
from Ruby code. Moreover, a Ruby-FFI extension works without changes
on Ruby and JRuby. [Discover why you should write your next extension
using Ruby-FFI](https://wiki.github.com/ffi/ffi/why-use-ffi).

## Features/problems

* Intuitive DSL
* Supports all C native types
* C structs (also nested), enums and global variables
* Callbacks from C to ruby
* Automatic garbage collection of native memory

## Synopsis

```ruby
require 'ffi'

module MyLib
  extend FFI::Library
  ffi_lib 'c'
  attach_function :puts, [ :string ], :int
end

MyLib.puts 'Hello, World using libc!'
```

For less minimalistic and more sane examples you may look at:

* the samples/ folder
* the examples on the [wiki](https://wiki.github.com/ffi/ffi)
* the projects using FFI listed on this page (https://wiki.github.com/ffi/ffi/projects-using-ffi)

## Requirements

You need a sane building environment in order to compile the extension.
At a minimum, you will need:
* A C compiler (e.g. Xcode on OSX, gcc on everything else)
* libffi development library - this is commonly in the libffi-dev or libffi-devel

## Installation

From rubygems:

    [sudo] gem install ffi

or from the git repository on github:

    git clone git://github.com/ffi/ffi.git
    git submodule update --init --recursive
    cd ffi
    rake install

## License

The ffi library is covered by the BSD license, also see the LICENSE file.
The specs are shared with Rubyspec and are licensed by the same license
as Rubyspec, see the LICENSE.SPECS file.

## Credits

The following people have submitted code, bug reports, or otherwise contributed to the success of this project:

* Alban Peignier <alban.peignier@free.fr>
* Aman Gupta <aman@tmm1.net>
* Andrea Fazzi <andrea.fazzi@alcacoop.it>
* Andreas Niederl <rico32@gmx.net>
* Andrew Cholakian <andrew@andrewvc.com>
* Antonio Terceiro <terceiro@softwarelivre.org>
* Brian Candler <B.Candler@pobox.com>
* Brian D. Burns <burns180@gmail.com>
* Bryan Kearney <bkearney@redhat.com>
* Charlie Savage <cfis@zerista.com>
* Chikanaga Tomoyuki <nagachika00@gmail.com>
* Hongli Lai <hongli@phusion.nl>
* Ian MacLeod <ian@nevir.net>
* Jake Douglas <jake@shiftedlabs.com>
* Jean-Dominique Morani <jdmorani@mac.com>
* Jeremy Hinegardner <jeremy@hinegardner.org>
* Jesús García Sáez <blaxter@gmail.com>
* Joe Khoobyar <joe@ankhcraft.com>
* Jurij Smakov <jurij@wooyd.org>
* KISHIMOTO, Makoto <ksmakoto@dd.iij4u.or.jp>
* Kim Burgestrand <kim@burgestrand.se>
* Lars Kanis <kanis@comcard.de>
* Luc Heinrich <luc@honk-honk.com>
* Luis Lavena <luislavena@gmail.com>
* Matijs van Zuijlen <matijs@matijs.net>
* Matthew King <automatthew@gmail.com>
* Mike Dalessio <mike.dalessio@gmail.com>
* NARUSE, Yui <naruse@airemix.jp>
* Park Heesob <phasis@gmail.com>
* Shin Yee <shinyee@speedgocomputing.com>
* Stephen Bannasch <stephen.bannasch@gmail.com>
* Suraj N. Kurapati <sunaku@gmail.com>
* Sylvain Daubert <sylvain.daubert@laposte.net>
* Victor Costan
* beoran@gmail.com
* ctide <christide@christide.com>
* emboss <Martin.Bosslet@googlemail.com>
* hobophobe <unusualtears@gmail.com>
* meh <meh@paranoici.org>
* postmodern <postmodern.mod3@gmail.com>
* wycats@gmail.com <wycats@gmail.com>
* Wayne Meissner <wmeissner@gmail.com>
