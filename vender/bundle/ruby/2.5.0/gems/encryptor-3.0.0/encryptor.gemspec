# -*- encoding: utf-8 -*-

lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'encryptor/version'
require 'date'

Gem::Specification.new do |s|
  s.name     = 'encryptor'
  s.version  = Encryptor::Version
  s.date     = Date.today
  s.platform = Gem::Platform::RUBY

  s.summary     = 'A simple wrapper for the standard ruby OpenSSL library'
  s.description = 'A simple wrapper for the standard ruby OpenSSL library to encrypt and decrypt strings'

  s.authors   = ['Sean Huber', 'S. Brent Faulkner', 'William Monk', 'Stephen Aghaulor']
  s.email    = ['sean@shuber.io', 'sbfaulkner@gmail.com', 'billy.monk@gmail.com', 'saghaulor@gmail.com']
  s.homepage = 'http://github.com/attr-encrypted/encryptor'
  s.license = 'MIT'
  s.rdoc_options = %w(--charset=UTF-8 --inline-source --line-numbers --main README.md)

  s.require_paths = ['lib']

  s.files      = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- test/*`.split("\n")

  s.required_ruby_version = '>= 2.0.0'

  s.add_development_dependency('minitest', '>= 0')
  s.add_development_dependency('rake', '>= 0')
  s.add_development_dependency('simplecov', '>= 0')
  s.add_development_dependency('simplecov-rcov', '>= 0')
  s.add_development_dependency('codeclimate-test-reporter', '>= 0')

  s.requirements << 'openssl, >= v1.0.1'

  s.cert_chain  = ['certs/saghaulor.pem']
  s.signing_key = File.expand_path("~/.ssh/gem-private_key.pem") if $0 =~ /gem\z/

  s.post_install_message  = "\n\n\nPlease be aware that Encryptor v2.0.0 had a major security bug when using AES-*-GCM algorithms.\n
By default You will not be able to decrypt data that was previously encrypted using an AES-*-GCM algorithm.\n
Please see the README and https://github.com/attr-encrypted/encryptor/pull/22 for more information.\n\n\n"

end
