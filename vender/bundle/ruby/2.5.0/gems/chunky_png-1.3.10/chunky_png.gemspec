# -*- encoding: utf-8 -*-

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'chunky_png/version'

Gem::Specification.new do |s|
  s.name    = 'chunky_png'

  # Do not change the version and date fields by hand. This will be done
  # automatically by the gem release script.
  s.version = ChunkyPNG::VERSION

  s.summary     = "Pure ruby library for read/write, chunk-level access to PNG files"
  s.description = <<-EOT
    This pure Ruby library can read and write PNG images without depending on an external
    image library, like RMagick. It tries to be memory efficient and reasonably fast.

    It supports reading and writing all PNG variants that are defined in the specification,
    with one limitation: only 8-bit color depth is supported. It supports all transparency,
    interlacing and filtering options the PNG specifications allows. It can also read and
    write textual metadata from PNG files. Low-level read/write access to PNG chunks is
    also possible.

    This library supports simple drawing on the image canvas and simple operations like
    alpha composition and cropping. Finally, it can import from and export to RMagick for
    interoperability.

    Also, have a look at OilyPNG at http://github.com/wvanbergen/oily_png. OilyPNG is a
    drop in mixin module that implements some of the ChunkyPNG algorithms in C, which
    provides a massive speed boost to encoding and decoding.
  EOT

  s.authors  = ['Willem van Bergen']
  s.email    = ['willem@railsdoctors.com']
  s.homepage = 'http://wiki.github.com/wvanbergen/chunky_png'
  s.license  = 'MIT'

  s.add_development_dependency('rake')
  s.add_development_dependency('rspec', '~> 3')

  s.rdoc_options << '--title' << s.name << '--main' << 'README.rdoc' << '--line-numbers' << '--inline-source'
  s.extra_rdoc_files = ['README.md', 'BENCHMARKING.rdoc', 'CONTRIBUTING.rdoc', 'CHANGELOG.rdoc']

  s.files = `git ls-files`.split($/)
  s.test_files = s.files.grep(%r{^(test|spec|features)/})
end
