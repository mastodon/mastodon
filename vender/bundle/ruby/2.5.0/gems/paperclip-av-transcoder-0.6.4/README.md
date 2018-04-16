# Paperclip Transcoder

Audio/Video Transcoder for Paperclip using FFMPEG/Avconv.

This is a replacement for ( https://github.com/owahab/paperclip-ffmpeg ).

## Status

[![Build Status](https://travis-ci.org/ruby-av/paperclip-av-transcoder.svg?branch=master)](https://travis-ci.org/ruby-av/paperclip-av-transcoder)
[![Coverage Status](https://coveralls.io/repos/ruby-av/paperclip-av-transcoder/badge.png?branch=master)](https://coveralls.io/r/ruby-av/paperclip-av-transcoder?branch=master)
[![Code Climate](https://codeclimate.com/github/ruby-av/paperclip-av-transcoder/badges/gpa.svg)](https://codeclimate.com/github/ruby-av/paperclip-av-transcoder)
[![Dependency Status](https://gemnasium.com/ruby-av/paperclip-av-transcoder.svg)](https://gemnasium.com/ruby-av/paperclip-av-transcoder)
[![Gem Version](https://badge.fury.io/rb/paperclip-av-transcoder.svg)](http://badge.fury.io/rb/paperclip-av-transcoder)

## Installation

Add this line to your application's Gemfile:

    gem 'paperclip-av-transcoder'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install paperclip-av-transcoder

## Usage

In your model:

    # app/models/user.rb
    class User < ActiveRecord::Base
      has_attached_file :avatar, :styles => {
        :medium => { :geometry => "640x480", :format => 'flv' },
        :thumb => { :geometry => "100x100#", :format => 'jpg', :time => 10 }
      }, :processors => [:transcoder]
    end

This will produce:

1. A transcoded `:medium` FLV file with the requested dimensions if they will match the aspect ratio of the original file, otherwise, width will be maintained and height will be recalculated to keep the original aspect ration.
2. A screenshot `:thumb` with the requested dimensions regardless of the aspect ratio.

You may optionally add `<attachment>_meta` to your model and it will get populated with information about the processed video.

The geometry parameters are:

1. '!' - Keep the same aspect of the image/video, but with the passed dimesion.
2. '#' - Pad the image/video.
3. '<' - Enlarge the image/video.
4. '>' - Shrink the image/video.

## Contributing

1. Fork it ( https://github.com/ruby-av/paperclip-av-transcoder/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
