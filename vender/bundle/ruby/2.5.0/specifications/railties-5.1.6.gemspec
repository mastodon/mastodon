# -*- encoding: utf-8 -*-
# stub: railties 5.1.6 ruby lib

Gem::Specification.new do |s|
  s.name = "railties".freeze
  s.version = "5.1.6"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "changelog_uri" => "https://github.com/rails/rails/blob/v5.1.6/railties/CHANGELOG.md", "source_code_uri" => "https://github.com/rails/rails/tree/v5.1.6/railties" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["David Heinemeier Hansson".freeze]
  s.bindir = "exe".freeze
  s.date = "2018-03-29"
  s.description = "Rails internals: application bootup, plugins, generators, and rake tasks.".freeze
  s.email = "david@loudthinking.com".freeze
  s.executables = ["rails".freeze]
  s.files = ["exe/rails".freeze]
  s.homepage = "http://rubyonrails.org".freeze
  s.licenses = ["MIT".freeze]
  s.rdoc_options = ["--exclude".freeze, ".".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.2.2".freeze)
  s.rubygems_version = "2.7.6".freeze
  s.summary = "Tools for creating, working with, and running Rails applications.".freeze

  s.installed_by_version = "2.7.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>.freeze, ["= 5.1.6"])
      s.add_runtime_dependency(%q<actionpack>.freeze, ["= 5.1.6"])
      s.add_runtime_dependency(%q<rake>.freeze, [">= 0.8.7"])
      s.add_runtime_dependency(%q<thor>.freeze, ["< 2.0", ">= 0.18.1"])
      s.add_runtime_dependency(%q<method_source>.freeze, [">= 0"])
      s.add_development_dependency(%q<actionview>.freeze, ["= 5.1.6"])
    else
      s.add_dependency(%q<activesupport>.freeze, ["= 5.1.6"])
      s.add_dependency(%q<actionpack>.freeze, ["= 5.1.6"])
      s.add_dependency(%q<rake>.freeze, [">= 0.8.7"])
      s.add_dependency(%q<thor>.freeze, ["< 2.0", ">= 0.18.1"])
      s.add_dependency(%q<method_source>.freeze, [">= 0"])
      s.add_dependency(%q<actionview>.freeze, ["= 5.1.6"])
    end
  else
    s.add_dependency(%q<activesupport>.freeze, ["= 5.1.6"])
    s.add_dependency(%q<actionpack>.freeze, ["= 5.1.6"])
    s.add_dependency(%q<rake>.freeze, [">= 0.8.7"])
    s.add_dependency(%q<thor>.freeze, ["< 2.0", ">= 0.18.1"])
    s.add_dependency(%q<method_source>.freeze, [">= 0"])
    s.add_dependency(%q<actionview>.freeze, ["= 5.1.6"])
  end
end
