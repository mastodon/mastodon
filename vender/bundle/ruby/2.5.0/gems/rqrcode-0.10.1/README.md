# rQRCode, Encode QRCodes 

[![Build Status](https://travis-ci.org/whomwah/rqrcode.svg?branch=master)](https://travis-ci.org/whomwah/rqrcode)

**All users of rqrcode are highly recomended to upgrade to version 0.5.5 ore later!**

## Short changelog

*0.10.1* (Feb 11, 2016)

- Changed so that gem wont include images and tests.

*0.10.0* (Feb 11, 2016)

- Merged as_ansi by [Andy Brody](https://github.com/ab)

*0.9.0* (Jan 3, 2016)

- Added support for auto selecting qrcode size up to level 40. (only worked up to level 10 before)
- Added numeric support during auto selection of qrcode mode.

*0.8.1* (Jan 3, 2016)

- Remove active support specific `present?`.
- Fix so that all tests are run.

*0.8.0* (Dec 18, 2015)

- Added numeric QR code support
- Dropped Ruby v1.8 support

## Overview

rQRCode is a library for encoding QR Codes in Ruby. It has a simple interface with all the standard qrcode options. It was adapted from the Javascript library by Kazuhiko Arase.

Let's clear up some rQRCode stuff.

* rQRCode is a __ruby only library__ It requires no native libraries. Just Ruby!
* It is an encoding library. You can't decode QR codes with it.
* The interface is simple and assumes you just want to encode a string into a QR code
* QR code is trademarked by Denso Wave inc

## Installing

You may get the latest stable version from Rubygems.

```ruby
gem install rqrcode
```

## Using rQRCode

```ruby
require 'rqrcode'

qrcode = RQRCode::QRCode.new("http://github.com/")
image = qrcode.as_png
svg = qrcode.as_svg
html = qrcode.as_html
string = qrcode.as_ansi
string = qrcode.to_s
```

## Image Rendering
### SVG

The SVG renderer will produce a stand-alone SVG as a `String`

```ruby
qrcode = RQRCode::QRCode.new("http://github.com/")
# With default options specified explicitly
svg = qrcode.as_svg(offset: 0, color: '000', 
                    shape_rendering: 'crispEdges', 
                    module_size: 11)
```

![QR code with github url](./images/github-qrcode.svg)

### ANSI

The ANSI renderer will produce as a string with ANSI color codes.

```ruby
qrcode = RQRCode::QRCode.new("http://github.com/")
# With default options specified explicitly
svg = qrcode.as_ansi_(light: "\033[47m", dark: "\033[40m",
                    fill_character: '  ',
                    quiet_zone_size: 4)
```

![QR code with github url](./images/ansi-screen-shot.png)

### PNG

The library can produce a PNG. Result will be a `ChunkyPNG::Image` instance.

```ruby
qrcode = RQRCode::QRCode.new("http://github.com/")
# With default options specified explicitly
png = qrcode.as_png(
          resize_gte_to: false,
          resize_exactly_to: false,
          fill: 'white',
          color: 'black',
          size: 120,
          border_modules: 4,
          module_px_size: 6,
          file: nil # path to write
          )
IO.write("/tmp/github-qrcode.png", png.to_s)
```

![QR code with github url](./images/github-qrcode.png)

## HTML Rendering
### In your controller
```ruby
@qr = RQRCode::QRCode.new( 'https://github.com/whomwah/rqrcode', :size => 4, :level => :h )
```

### In your view
```html
<%= raw @qr.as_html %>
```

### CSS
```css
table {
  border-width: 0;
  border-style: none;
  border-color: #0000ff;
  border-collapse: collapse;
}

td {
  border-left: solid 10px #000;
  padding: 0; 
  margin: 0; 
  width: 0px; 
  height: 10px; 
}

td.black { border-color: #000; }
td.white { border-color: #fff; }
```
    
## On the console

```ruby
qr = RQRCode::QRCode.new( 'my string to generate', :size => 4, :level => :h )
puts qr.to_s
```

Output:

```
xxxxxxx x  x x   x x  xx  xxxxxxx
x     x  xxx  xxxxxx xxx  x     x
x xxx x  xxxxx x       xx x xxx x
... etc 
```

## Doing your own rendering
```ruby
qr = RQRCode::QRCode.new( 'my string to generate', :size => 4, :level => :h )
qr.modules.each do |row|
    row.each do |col| 
        print col ? "X" : " "
    end
    print "\n"
end
```

## Specifying QR code mode

Sometimes you may want to specify the QR code mode explicitly. 

It is done via the `mode` option. Allowed values are: `number`, `alphanumeric` and `byte_8bit`.

```ruby
qr = RQRCode::QRCode.new( '1234567890', :size => 2, :level => :m, :mode => :number )
```


## API Documentation

[http://www.rubydoc.info/gems/rqrcode](http://www.rubydoc.info/gems/rqrcode)

## Resources

* wikipedia:: http://en.wikipedia.org/wiki/QR_Code
* Denso-Wave website:: http://www.denso-wave.com/qrcode/index-e.html
* kaywa:: http://qrcode.kaywa.com

## Authors

Original author: Duncan Robertson

Special thanks to the following people for submitting patches:

* [Andy Brody](https://github.com/ab)
* [Chris Mowforth](http://blog.99th.st)
* [Daniel Schierbeck](https://github.com/dasch)
* [Gioele Barabucci](https://github.com/gioele)
* [Ken Collins](https://github.com/metaskills)
* [Rob la Lau](https://github.com/ohreally)
* [Tore Darell](http://tore.darell.no)
* Vladislav Gorodetskiy

## Contributing
* Fork the project
* Send a pull request
* Don't touch the .gemspec, I'll do that when I release a new version

## Copyright

MIT License (http://www.opensource.org/licenses/mit-license.html)
