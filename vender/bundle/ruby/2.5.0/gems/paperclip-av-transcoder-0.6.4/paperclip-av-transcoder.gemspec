# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'paperclip/av/transcoder/version'

Gem::Specification.new do |spec|
  spec.name          = "paperclip-av-transcoder"
  spec.version       = Paperclip::Av::Transcoder::VERSION
  spec.authors       = ["Omar Abdel-Wahab"]
  spec.email         = ["owahab@gmail.com"]
  spec.summary       = %q{Audio/Video Transcoder for Paperclip using FFMPEG/Avconv}
  spec.description   = %q{Audio/Video Transcoder for Paperclip using FFMPEG/Avconv}
  spec.homepage      = "https://github.com/ruby-av/paperclip-av-transcoder"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 3.0.0"
  spec.add_development_dependency "rails", ">= 4.0.0"
  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "coveralls"

  spec.add_dependency "paperclip", ">=2.5.2"
  spec.add_dependency "av", "~> 0.9.0"
end
