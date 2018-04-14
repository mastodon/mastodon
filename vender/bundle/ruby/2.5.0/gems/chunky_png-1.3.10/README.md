# ChunkyPNG [![Build Status](https://travis-ci.org/wvanbergen/chunky_png.svg?branch=master)](https://travis-ci.org/wvanbergen/chunky_png)

This library can read and write PNG files. It is written in pure Ruby for
maximum portability. Let me rephrase: it does NOT require RMagick or any other
memory leaking image library.

- [Source code](http://github.com/wvanbergen/chunky_png/tree)
- [RDoc](http://rdoc.info/gems/chunky_png/frames)
- [Wiki](http://github.com/wvanbergen/chunky_png/wiki)
- [Issue tracker](http://github.com/wvanbergen/chunky_png/issues)

## Features

- Decodes any image that the PNG standard allows. This includes all standard
  color modes, all bit depths, all transparency, and interlacing and filtering
  options.
- Encodes images supports all color modes (true color, grayscale, and indexed)
  and transparency for all these color modes. The best color mode will be
  chosen automatically, based on the amount of used colors.
- R/W access to the image's pixels.
- R/W access to all image metadata that is stored in chunks.
- Memory efficient (uses a Fixnum, i.e. 4 or 8 bytes of memory per pixel,
  depending on the hardware)
- Reasonably fast for Ruby standards, by only using integer math and a highly
  optimized saving routine.
- Interoperability with RMagick if you really have to.

Also, have a look at [OilyPNG](http://github.com/wvanbergen/oily_png) which
is a mixin module that implements some of the ChunkyPNG algorithms in C, which
provides a massive speed boost to encoding and decoding.

## Usage

```ruby
require 'chunky_png'

# Creating an image from scratch, save as an interlaced PNG
png = ChunkyPNG::Image.new(16, 16, ChunkyPNG::Color::TRANSPARENT)
png[1,1] = ChunkyPNG::Color.rgba(10, 20, 30, 128)
png[2,1] = ChunkyPNG::Color('black @ 0.5')
png.save('filename.png', :interlace => true)

# Compose images using alpha blending.
avatar = ChunkyPNG::Image.from_file('avatar.png')
badge  = ChunkyPNG::Image.from_file('no_ie_badge.png')
avatar.compose!(badge, 10, 10)
avatar.save('composited.png', :fast_rgba) # Force the fast saving routine.

# Accessing metadata
image = ChunkyPNG::Image.from_file('with_metadata.png')
puts image.metadata['Title']
image.metadata['Author'] = 'Willem van Bergen'
image.save('with_metadata.png') # Overwrite file

# Low level access to PNG chunks
png_stream = ChunkyPNG::Datastream.from_file('filename.png')
png_stream.each_chunk { |chunk| p chunk.type }
```

Also check out the screencast on the ChunkyPNG homepage by John Davison,
which illustrates basic usage of the library on the [ChunkyPNG
website](http://chunkypng.com/).

For more information, see the [project
wiki](https://github.com/wvanbergen/chunky_png/wiki) or the [RDOC
documentation](http://www.rubydoc.info/gems/chunky_png/frames).

## Security warning

ChunkyPNG is vulnerable to decompression bombs, which means that ChunkyPNG is
vulnerable to DOS attacks by running out of memory when loading a specifically
crafted PNG file. Because of the pure-Ruby nature of the library it is very hard
to fix this problem in the library itself.

In order to safely deal with untrusted images, you should make sure to do the
image processing using ChunkyPNG in a separate process, e.g. by using fork or a
background processing library.

## About

The library is written by Willem van Bergen for Floorplanner.com, and released
under the MIT license (see LICENSE). Please contact me for questions or
remarks. Patches are greatly appreciated!

Please check out CHANGELOG.rdoc to see what changed in all versions.

P.S.: The name of this library is intentionally similar to Chunky Bacon and
Chunky GIF. Use Google if you want to know _why_. :-)
