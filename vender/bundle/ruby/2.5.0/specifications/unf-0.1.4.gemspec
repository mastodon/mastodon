# -*- encoding: utf-8 -*-
# stub: unf 0.1.4 ruby lib

Gem::Specification.new do |s|
  s.name = "unf".freeze
  s.version = "0.1.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Akinori MUSHA".freeze]
  s.date = "2014-04-04"
  s.description = "This is a wrapper library to bring Unicode Normalization Form support\nto Ruby/JRuby.\n".freeze
  s.email = ["knu@idaemons.org".freeze]
  s.extra_rdoc_files = ["README.md".freeze, "LICENSE".freeze]
  s.files = ["LICENSE".freeze, "README.md".freeze]
  s.homepage = "https://github.com/knu/ruby-unf".freeze
  s.licenses = ["2-clause BSDL".freeze]
  s.rubygems_version = "2.7.6".freeze
  s.summary = "A wrapper library to bring Unicode Normalization Form support to Ruby/JRuby".freeze

  s.installed_by_version = "2.7.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<unf_ext>.freeze, [">= 0"])
      s.add_development_dependency(%q<shoulda>.freeze, [">= 0"])
      s.add_development_dependency(%q<bundler>.freeze, [">= 1.2.0"])
      s.add_development_dependency(%q<rake>.freeze, [">= 0.9.2.2"])
      s.add_development_dependency(%q<rdoc>.freeze, ["> 2.4.2"])
    else
      s.add_dependency(%q<unf_ext>.freeze, [">= 0"])
      s.add_dependency(%q<shoulda>.freeze, [">= 0"])
      s.add_dependency(%q<bundler>.freeze, [">= 1.2.0"])
      s.add_dependency(%q<rake>.freeze, [">= 0.9.2.2"])
      s.add_dependency(%q<rdoc>.freeze, ["> 2.4.2"])
    end
  else
    s.add_dependency(%q<unf_ext>.freeze, [">= 0"])
    s.add_dependency(%q<shoulda>.freeze, [">= 0"])
    s.add_dependency(%q<bundler>.freeze, [">= 1.2.0"])
    s.add_dependency(%q<rake>.freeze, [">= 0.9.2.2"])
    s.add_dependency(%q<rdoc>.freeze, ["> 2.4.2"])
  end
end
