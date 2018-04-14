# -*- encoding: utf-8 -*-
# stub: idn-ruby 0.1.0 ruby lib
# stub: ext/extconf.rb

Gem::Specification.new do |s|
  s.name = "idn-ruby".freeze
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Erik Abele".freeze, "Bharanee Rathna".freeze]
  s.date = "2011-05-31"
  s.description = "\n    Ruby Bindings for the GNU LibIDN library, an implementation of the\n    Stringprep, Punycode and IDNA specifications defined by the IETF\n    Internationalized Domain Names (IDN) working group.\n\n    Included are the most important parts of the Stringprep, Punycode\n    and IDNA APIs like performing Stringprep processings, encoding to\n    and decoding from Punycode strings and converting entire domain names\n    to and from the ACE encoded form.\n  ".freeze
  s.email = "deepfryed@gmail.com".freeze
  s.extensions = ["ext/extconf.rb".freeze]
  s.extra_rdoc_files = ["LICENSE".freeze, "README".freeze]
  s.files = ["LICENSE".freeze, "README".freeze, "ext/extconf.rb".freeze]
  s.homepage = "http://github.com/deepfryed/idn-ruby".freeze
  s.rubygems_version = "2.7.6".freeze
  s.summary = "LibIDN Ruby Bindings.".freeze

  s.installed_by_version = "2.7.6" if s.respond_to? :installed_by_version
end
