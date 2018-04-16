# -*- encoding: utf-8 -*-
# stub: net-ldap 0.16.1 ruby lib

Gem::Specification.new do |s|
  s.name = "net-ldap".freeze
  s.version = "0.16.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Francis Cianfrocca".freeze, "Emiel van de Laar".freeze, "Rory O'Connell".freeze, "Kaspar Schiess".freeze, "Austin Ziegler".freeze, "Michael Schaarschmidt".freeze]
  s.date = "2017-10-31"
  s.description = "Net::LDAP for Ruby (also called net-ldap) implements client access for the\nLightweight Directory Access Protocol (LDAP), an IETF standard protocol for\naccessing distributed directory services. Net::LDAP is written completely in\nRuby with no external dependencies. It supports most LDAP client features and a\nsubset of server features as well.\n\nNet::LDAP has been tested against modern popular LDAP servers including\nOpenLDAP and Active Directory. The current release is mostly compliant with\nearlier versions of the IETF LDAP RFCs (2251-2256, 2829-2830, 3377, and 3771).\nOur roadmap for Net::LDAP 1.0 is to gain full <em>client</em> compliance with\nthe most recent LDAP RFCs (4510-4519, plutions of 4520-4532).".freeze
  s.email = ["blackhedd@rubyforge.org".freeze, "gemiel@gmail.com".freeze, "rory.ocon@gmail.com".freeze, "kaspar.schiess@absurd.li".freeze, "austin@rubyforge.org".freeze]
  s.extra_rdoc_files = ["Contributors.rdoc".freeze, "Hacking.rdoc".freeze, "History.rdoc".freeze, "License.rdoc".freeze, "README.rdoc".freeze]
  s.files = ["Contributors.rdoc".freeze, "Hacking.rdoc".freeze, "History.rdoc".freeze, "License.rdoc".freeze, "README.rdoc".freeze]
  s.homepage = "http://github.com/ruby-ldap/ruby-net-ldap".freeze
  s.licenses = ["MIT".freeze]
  s.rdoc_options = ["--main".freeze, "README.rdoc".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.0.0".freeze)
  s.rubygems_version = "2.7.6".freeze
  s.summary = "Net::LDAP for Ruby (also called net-ldap) implements client access for the Lightweight Directory Access Protocol (LDAP), an IETF standard protocol for accessing distributed directory services".freeze

  s.installed_by_version = "2.7.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<flexmock>.freeze, ["~> 1.3"])
      s.add_development_dependency(%q<rake>.freeze, ["~> 10.0"])
      s.add_development_dependency(%q<rubocop>.freeze, ["~> 0.42.0"])
      s.add_development_dependency(%q<test-unit>.freeze, [">= 0"])
      s.add_development_dependency(%q<byebug>.freeze, [">= 0"])
    else
      s.add_dependency(%q<flexmock>.freeze, ["~> 1.3"])
      s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
      s.add_dependency(%q<rubocop>.freeze, ["~> 0.42.0"])
      s.add_dependency(%q<test-unit>.freeze, [">= 0"])
      s.add_dependency(%q<byebug>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<flexmock>.freeze, ["~> 1.3"])
    s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
    s.add_dependency(%q<rubocop>.freeze, ["~> 0.42.0"])
    s.add_dependency(%q<test-unit>.freeze, [">= 0"])
    s.add_dependency(%q<byebug>.freeze, [">= 0"])
  end
end
