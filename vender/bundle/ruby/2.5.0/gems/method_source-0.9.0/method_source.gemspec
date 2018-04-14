# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "method_source"
  s.version = "0.8.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["John Mair (banisterfiend)"]
  s.licenses = ['MIT']
  s.date = "2012-10-17"
  s.description = "retrieve the sourcecode for a method"
  s.email = "jrmair@gmail.com"
  s.files = [".gemtest", ".travis.yml", ".yardopts", "Gemfile", "LICENSE", "README.markdown", "Rakefile", "lib/method_source.rb", "lib/method_source/code_helpers.rb", "lib/method_source/source_location.rb", "lib/method_source/version.rb", "method_source.gemspec", "spec/method_source/code_helpers_spec.rb", "spec/method_source_spec.rb", "spec/spec_helper.rb"]
  s.homepage = "http://banisterfiend.wordpress.com"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.23"
  s.summary = "retrieve the sourcecode for a method"
  s.test_files = ["spec/method_source/code_helpers_spec.rb", "spec/method_source_spec.rb", "spec/spec_helper.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rspec>, ["~> 3.6"])
      s.add_development_dependency(%q<rake>, ["~> 0.9"])
    else
      s.add_dependency(%q<rspec>, ["~> 3.6"])
      s.add_dependency(%q<rake>, ["~> 0.9"])
    end
  else
    s.add_dependency(%q<rspec>, ["~> 3.6"])
    s.add_dependency(%q<rake>, ["~> 0.9"])
  end
end
