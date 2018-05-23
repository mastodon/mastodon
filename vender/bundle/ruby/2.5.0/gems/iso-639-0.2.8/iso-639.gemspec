# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "iso-639"
  s.version = "0.2.8"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["William Melody"]
  s.date = "2016-06-26"
  s.description = "ISO 639-1 and ISO 639-2 language code entries and convenience methods"
  s.email = "hi@williammelody.com"
  s.extra_rdoc_files = [
    "LICENSE",
    "README.md"
  ]
  s.files = [
    ".document",
    "Gemfile",
    "Gemfile.lock",
    "LICENSE",
    "README.md",
    "Rakefile",
    "iso-639.gemspec",
    "lib/iso-639.rb",
    "test/helper.rb",
    "test/test_iso_639.rb"
  ]
  s.homepage = "http://github.com/alphabetum/iso-639"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.24"
  s.summary = "ISO 639-1 and ISO 639-2 language code entries and convenience methods"

  if s.respond_to? :specification_version
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0')
      s.add_development_dependency("minitest", [">= 0"])
      s.add_development_dependency("mocha", [">= 0"])
      s.add_development_dependency("rdoc", [">= 0"])
      s.add_development_dependency("rubocop", [">= 0"])
      s.add_development_dependency("test-unit", [">= 0"])
    else
      s.add_dependency("minitest", [">= 0"])
      s.add_dependency("mocha", [">= 0"])
      s.add_dependency("rdoc", [">= 0"])
      s.add_dependency("rubocop", [">= 0"])
      s.add_dependency("test-unit", [">= 0"])
    end
  else
    s.add_dependency("minitest", [">= 0"])
    s.add_dependency("mocha", [">= 0"])
    s.add_dependency("rdoc", [">= 0"])
    s.add_dependency("rubocop", [">= 0"])
    s.add_dependency("test-unit", [">= 0"])
  end
end
