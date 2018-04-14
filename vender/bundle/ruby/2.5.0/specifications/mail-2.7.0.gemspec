# -*- encoding: utf-8 -*-
# stub: mail 2.7.0 ruby lib

Gem::Specification.new do |s|
  s.name = "mail".freeze
  s.version = "2.7.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Mikel Lindsaar".freeze]
  s.date = "2017-11-01"
  s.description = "A really Ruby Mail handler.".freeze
  s.email = "raasdnil@gmail.com".freeze
  s.extra_rdoc_files = ["README.md".freeze]
  s.files = ["README.md".freeze]
  s.homepage = "https://github.com/mikel/mail".freeze
  s.licenses = ["MIT".freeze]
  s.rdoc_options = ["--exclude".freeze, "lib/mail/values/unicode_tables.dat".freeze]
  s.rubygems_version = "2.7.6".freeze
  s.summary = "Mail provides a nice Ruby DSL for making, sending and reading emails.".freeze

  s.installed_by_version = "2.7.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<mini_mime>.freeze, [">= 0.1.1"])
      s.add_development_dependency(%q<bundler>.freeze, [">= 1.0.3"])
      s.add_development_dependency(%q<rake>.freeze, ["> 0.8.7"])
      s.add_development_dependency(%q<rspec>.freeze, ["~> 3.0"])
      s.add_development_dependency(%q<rdoc>.freeze, [">= 0"])
    else
      s.add_dependency(%q<mini_mime>.freeze, [">= 0.1.1"])
      s.add_dependency(%q<bundler>.freeze, [">= 1.0.3"])
      s.add_dependency(%q<rake>.freeze, ["> 0.8.7"])
      s.add_dependency(%q<rspec>.freeze, ["~> 3.0"])
      s.add_dependency(%q<rdoc>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<mini_mime>.freeze, [">= 0.1.1"])
    s.add_dependency(%q<bundler>.freeze, [">= 1.0.3"])
    s.add_dependency(%q<rake>.freeze, ["> 0.8.7"])
    s.add_dependency(%q<rspec>.freeze, ["~> 3.0"])
    s.add_dependency(%q<rdoc>.freeze, [">= 0"])
  end
end
