# -*- encoding: utf-8 -*-
# stub: paperclip-av-transcoder 0.6.4 ruby lib

Gem::Specification.new do |s|
  s.name = "paperclip-av-transcoder".freeze
  s.version = "0.6.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Omar Abdel-Wahab".freeze]
  s.date = "2015-04-09"
  s.description = "Audio/Video Transcoder for Paperclip using FFMPEG/Avconv".freeze
  s.email = ["owahab@gmail.com".freeze]
  s.homepage = "https://github.com/ruby-av/paperclip-av-transcoder".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "2.7.6".freeze
  s.summary = "Audio/Video Transcoder for Paperclip using FFMPEG/Avconv".freeze

  s.installed_by_version = "2.7.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bundler>.freeze, ["~> 1.6"])
      s.add_development_dependency(%q<rake>.freeze, [">= 0"])
      s.add_development_dependency(%q<rspec>.freeze, ["~> 3.0.0"])
      s.add_development_dependency(%q<rails>.freeze, [">= 4.0.0"])
      s.add_development_dependency(%q<sqlite3>.freeze, [">= 0"])
      s.add_development_dependency(%q<coveralls>.freeze, [">= 0"])
      s.add_runtime_dependency(%q<paperclip>.freeze, [">= 2.5.2"])
      s.add_runtime_dependency(%q<av>.freeze, ["~> 0.9.0"])
    else
      s.add_dependency(%q<bundler>.freeze, ["~> 1.6"])
      s.add_dependency(%q<rake>.freeze, [">= 0"])
      s.add_dependency(%q<rspec>.freeze, ["~> 3.0.0"])
      s.add_dependency(%q<rails>.freeze, [">= 4.0.0"])
      s.add_dependency(%q<sqlite3>.freeze, [">= 0"])
      s.add_dependency(%q<coveralls>.freeze, [">= 0"])
      s.add_dependency(%q<paperclip>.freeze, [">= 2.5.2"])
      s.add_dependency(%q<av>.freeze, ["~> 0.9.0"])
    end
  else
    s.add_dependency(%q<bundler>.freeze, ["~> 1.6"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
    s.add_dependency(%q<rspec>.freeze, ["~> 3.0.0"])
    s.add_dependency(%q<rails>.freeze, [">= 4.0.0"])
    s.add_dependency(%q<sqlite3>.freeze, [">= 0"])
    s.add_dependency(%q<coveralls>.freeze, [">= 0"])
    s.add_dependency(%q<paperclip>.freeze, [">= 2.5.2"])
    s.add_dependency(%q<av>.freeze, ["~> 0.9.0"])
  end
end
