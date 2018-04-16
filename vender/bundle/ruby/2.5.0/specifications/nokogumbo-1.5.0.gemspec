# -*- encoding: utf-8 -*-
# stub: nokogumbo 1.5.0 ruby lib
# stub: ext/nokogumboc/extconf.rb

Gem::Specification.new do |s|
  s.name = "nokogumbo".freeze
  s.version = "1.5.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Sam Ruby".freeze]
  s.date = "2018-01-27"
  s.description = "Nokogumbo allows a Ruby program to invoke the Gumbo HTML5 parser and access the result as a Nokogiri parsed document.".freeze
  s.email = "rubys@intertwingly.net".freeze
  s.extensions = ["ext/nokogumboc/extconf.rb".freeze]
  s.files = ["ext/nokogumboc/extconf.rb".freeze]
  s.homepage = "https://github.com/rubys/nokogumbo/#readme".freeze
  s.licenses = ["Apache-2.0".freeze]
  s.rubygems_version = "2.7.6".freeze
  s.summary = "Nokogiri interface to the Gumbo HTML5 parser".freeze

  s.installed_by_version = "2.7.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<nokogiri>.freeze, [">= 0"])
    else
      s.add_dependency(%q<nokogiri>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<nokogiri>.freeze, [">= 0"])
  end
end
