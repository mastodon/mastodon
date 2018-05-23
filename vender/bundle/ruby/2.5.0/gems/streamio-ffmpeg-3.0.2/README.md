Streamio FFMPEG
===============

[![Build Status](https://travis-ci.org/bikeath1337/streamio-ffmpeg.svg?branch=master)](https://travis-ci.org/bikeath1337/streamio-ffmpeg)
[![Code Climate](https://codeclimate.com/github/bikeath1337/streamio-ffmpeg/badges/gpa.svg)](https://codeclimate.com/github/bikeath1337/streamio-ffmpeg)
[![Test Coverage](https://codeclimate.com/github/bikeath1337/streamio-ffmpeg/badges/coverage.svg)](https://codeclimate.com/github/bikeath1337/streamio-ffmpeg/coverage)

Simple yet powerful wrapper around the ffmpeg command for reading metadata and transcoding movies.

All work on this project is sponsored by the online video platform [Streamio](http://streamio.com).

[![Streamio](http://d253c4ja9jigvu.cloudfront.net/assets/small-logo.png)](http://streamio.com)

Installation
------------

    gem install streamio-ffmpeg

Compatibility
-------------

### Ruby

Only guaranteed to work with MRI Ruby 1.9.3 or later.
Should work with rubinius head in 1.9 mode.
Will not work in jruby until they fix: http://goo.gl/Z4UcX (should work in the upcoming 1.7.5)

### ffmpeg

The current gem is tested against ffmpeg 2.8.4. So no guarantees with earlier (or much later) 
versions. Output and input standards have inconveniently changed rather a lot between versions 
of ffmpeg. My goal is to keep this library in sync with new versions of ffmpeg as they come along.

On macOS: `brew install ffmpeg`.

Usage
-----

### Require the gem

``` ruby
require 'streamio-ffmpeg'
```

### Reading Metadata

``` ruby
movie = FFMPEG::Movie.new("path/to/movie.mov")

movie.duration # 7.5 (duration of the movie in seconds)
movie.bitrate # 481 (bitrate in kb/s)
movie.size # 455546 (filesize in bytes)

movie.video_stream # "h264, yuv420p, 640x480 [PAR 1:1 DAR 4:3], 371 kb/s, 16.75 fps, 15 tbr, 600 tbn, 1200 tbc" (raw video stream info)
movie.video_codec # "h264"
movie.colorspace # "yuv420p"
movie.resolution # "640x480"
movie.width # 640 (width of the movie in pixels)
movie.height # 480 (height of the movie in pixels)
movie.frame_rate # 16.72 (frames per second)

movie.audio_stream # "aac, 44100 Hz, stereo, s16, 75 kb/s" (raw audio stream info)
movie.audio_codec # "aac"
movie.audio_sample_rate # 44100
movie.audio_channels # 2

# Multiple audio streams
movie.audio_streams[0] # "aac, 44100 Hz, stereo, s16, 75 kb/s" (raw audio stream info)

movie.valid? # true (would be false if ffmpeg fails to read the movie)
```

### Transcoding

First argument is the output file path.

``` ruby
movie.transcode("tmp/movie.mp4") # Default ffmpeg settings for mp4 format
```

Keep track of progress with an optional block.

``` ruby
movie.transcode("movie.mp4") { |progress| puts progress } # 0.2 ... 0.5 ... 1.0
```

Give custom command line options with an array.

``` ruby
movie.transcode("movie.mp4", %w(-ac aac -vc libx264 -ac 2 ...))
```

Use the EncodingOptions parser for humanly readable transcoding options. Below you'll find most of the supported options.
Note that the :custom key is an array so that it can be used for FFMpeg options like
`-map` that can be repeated:

``` ruby
options = {
  video_codec: "libx264", frame_rate: 10, resolution: "320x240", video_bitrate: 300, video_bitrate_tolerance: 100,
  aspect: 1.333333, keyframe_interval: 90, x264_vprofile: "high", x264_preset: "slow",
  audio_codec: "libfaac", audio_bitrate: 32, audio_sample_rate: 22050, audio_channels: 1,
  threads: 2, custom: %w(-vf crop=60:60:10:10 -map 0:0 -map 0:1)
}

movie.transcode("movie.mp4", options)
```

The transcode function returns a Movie object for the encoded file.

``` ruby
transcoded_movie = movie.transcode("tmp/movie.flv")

transcoded_movie.video_codec # "flv"
transcoded_movie.audio_codec # "mp3"
```

Aspect ratio is added to encoding options automatically if none is specified.

``` ruby
options = { resolution: "320x180" } # Will add -aspect 1.77777777777778 to ffmpeg
```

Preserve aspect ratio on width or height by using the preserve_aspect_ratio transcoder option.

``` ruby
widescreen_movie = FFMPEG::Movie.new("path/to/widescreen_movie.mov")

options = { resolution: "320x240" }

transcoder_options = { preserve_aspect_ratio: :width }
widescreen_movie.transcode("movie.mp4", options, transcoder_options) # Output resolution will be 320x180

transcoder_options = { preserve_aspect_ratio: :height }
widescreen_movie.transcode("movie.mp4", options, transcoder_options) # Output resolution will be 426x240
```

For constant bitrate encoding use video_min_bitrate and video_max_bitrate with buffer_size.

``` ruby
options = {video_min_bitrate: 600, video_max_bitrate: 600, buffer_size: 2000}
movie.transcode("movie.flv", options)
```

### Specifying Input Options

To specify which options apply the input, such as changing the input framerate, use `input_options` hash
in the transcoder_options.

``` ruby
movie = FFMPEG::Movie.new("path/to/movie.mov")

transcoder_options = { input_options: { framerate: '1/5' } }
movie.transcode("movie.mp4", {}, transcoder_options)

# FFMPEG Command will look like this:
# ffmpeg -y -framerate 1/5 -i path/to/movie.mov movie.mp4
```

### Overriding the Input Path

If FFMPEG's input path needs to specify a sequence of files, rather than a path to a single movie, transcoding_options
`input` can be set. If this option is present, the path of the original movie will not be used.

``` ruby
movie = FFMPEG::Movie.new("path/to/movie.mov")

transcoder_options = { input: 'img_%03d.png' }
movie.transcode("movie.mp4", {}, transcoder_options)

# FFMPEG Command will look like this:
# ffmpeg -y -i img_%03d.png movie.mp4
```

### Watermarking

Add watermark image on the video.

For example, you want to add a watermark on the video at right top corner with 10px padding.

``` ruby
options = {
  watermark: "full_path_of_watermark.png", resolution: "640x360",
  watermark_filter: { position: "RT", padding_x: 10, padding_y: 10 }
}
```

Position can be "LT" (Left Top Corner), "RT" (Right Top Corner), "LB" (Left Bottom Corner), "RB" (Right Bottom Corner).
The watermark will not appear unless `watermark_options` specifies the position. `padding_x` and `padding_y` default to
`10`.

### Taking Screenshots

You can use the screenshot method to make taking screenshots a bit simpler.

``` ruby
movie.screenshot("screenshot.jpg")
```

The screenshot method has the very same API as transcode so the same options will work.

``` ruby
movie.screenshot("screenshot.bmp", seek_time: 5, resolution: '320x240')
```

To generate multiple screenshots in a single pass, specify `vframes` and a wildcard filename. Make
sure to disable output file validation. The following code generates up to 20 screenshots every 10 seconds:

``` ruby
movie.screenshot("screenshot_%d.jpg", { vframes: 20, frame_rate: '1/6' }, validate: false)
```

To specify the quality when generating compressed screenshots (.jpg), use `quality` which specifies
ffmpeg `-v:q` option. Quality is an integer between 1 and 31, where lower is better quality:

``` ruby
movie.screenshot("screenshot_%d.jpg", quality: 3)
```

You can preserve aspect ratio the same way as when using transcode.

``` ruby
movie.screenshot("screenshot.png", { seek_time: 2, resolution: '200x120' }, preserve_aspect_ratio: :width)
```

### Create a Slideshow from Stills
Creating a slideshow from stills uses named sequences of files and stiches the result together in a slideshow
video.

Since there is not movie to transcode, the Transcoder class needs to be used. The input and input_options are
provided through transcoder options.

``` ruby
slideshow_transcoder = FFMPEG::Transcoder.new(
  '',
  'slideshow.mp4',
  { resolution: "320x240" },
  input: 'img_%03d.jpeg',
  input_options: { framerate: '1/5' }
)

slideshow = slideshow_transcoder.run
```

Specify the path to ffmpeg
--------------------------

By default, the gem assumes that the ffmpeg binary is available in the execution path and named ffmpeg and so will run commands that look something like `ffmpeg -i /path/to/input.file ...`. Use the FFMPEG.ffmpeg_binary setter to specify the full path to the binary if necessary:

``` ruby
FFMPEG.ffmpeg_binary = '/usr/local/bin/ffmpeg'
```

This will cause the same command to run as `/usr/local/bin/ffmpeg -i /path/to/input.file ...` instead.


Automatically kill hung processes
---------------------------------

By default, the gem will wait for 30 seconds between IO feedback from the FFMPEG process. After which an error is logged and the process killed.
It is possible to modify this behaviour by setting a new default:

``` ruby
# Change the timeout
Transcoder.timeout = 10

# Disable the timeout altogether
Transcoder.timeout = false
```

Disabling output file validation
------------------------------

By default Transcoder validates the output file, in case you use FFMPEG for HLS
format that creates multiple outputs you can disable the validation by passing
`validate: false` to transcoder_options.

Note that transcode will not return the encoded movie object in this case since
attempting to open a (possibly) invalid output file might result in an error being raised.

```ruby
transcoder_options = { validate: false }
movie.transcode("movie.mp4", options, transcoder_options) # returns nil
```

Copyright
---------

Copyright (c) Streamio AB. See LICENSE for details.
