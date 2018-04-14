# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'net/ldap/version'

Gem::Specification.new do |s|
  s.name = %q{net-ldap}
  s.version = Net::LDAP::VERSION
  s.license = "MIT"
  s.authors = ["Francis Cianfrocca", "Emiel van de Laar", "Rory O'Connell", "Kaspar Schiess", "Austin Ziegler", "Michael Schaarschmidt"]
  s.description = %q{Net::LDAP for Ruby (also called net-ldap) implements client access for the
Lightweight Directory Access Protocol (LDAP), an IETF standard protocol for
accessing distributed directory services. Net::LDAP is written completely in
Ruby with no external dependencies. It supports most LDAP client features and a
subset of server features as well.

Net::LDAP has been tested against modern popular LDAP servers including
OpenLDAP and Active Directory. The current release is mostly compliant with
earlier versions of the IETF LDAP RFCs (2251-2256, 2829-2830, 3377, and 3771).
Our roadmap for Net::LDAP 1.0 is to gain full <em>client</em> compliance with
the most recent LDAP RFCs (4510-4519, plutions of 4520-4532).}
  s.email = ["blackhedd@rubyforge.org", "gemiel@gmail.com", "rory.ocon@gmail.com", "kaspar.schiess@absurd.li", "austin@rubyforge.org"]
  s.extra_rdoc_files = ["Contributors.rdoc", "Hacking.rdoc", "History.rdoc", "License.rdoc", "README.rdoc"]
  s.files = `git ls-files`.split $/
  s.test_files = s.files.grep(%r{^test})
  s.homepage = %q{http://github.com/ruby-ldap/ruby-net-ldap}
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.required_ruby_version = ">= 2.0.0"
  s.summary = %q{Net::LDAP for Ruby (also called net-ldap) implements client access for the Lightweight Directory Access Protocol (LDAP), an IETF standard protocol for accessing distributed directory services}

  s.add_development_dependency("flexmock", "~> 1.3")
  s.add_development_dependency("rake", "~> 10.0")
  s.add_development_dependency("rubocop", "~> 0.42.0")
  s.add_development_dependency("test-unit")
  s.add_development_dependency("byebug")
end
