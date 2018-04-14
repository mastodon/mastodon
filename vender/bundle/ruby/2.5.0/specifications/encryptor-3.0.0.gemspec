# -*- encoding: utf-8 -*-
# stub: encryptor 3.0.0 ruby lib

Gem::Specification.new do |s|
  s.name = "encryptor".freeze
  s.version = "3.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Sean Huber".freeze, "S. Brent Faulkner".freeze, "William Monk".freeze, "Stephen Aghaulor".freeze]
  s.cert_chain = ["-----BEGIN CERTIFICATE-----\nMIIDdDCCAlygAwIBAgIBATANBgkqhkiG9w0BAQUFADBAMRIwEAYDVQQDDAlzYWdo\nYXVsb3IxFTATBgoJkiaJk/IsZAEZFgVnbWFpbDETMBEGCgmSJomT8ixkARkWA2Nv\nbTAeFw0xNjAxMTEyMjQyMDFaFw0xNzAxMTAyMjQyMDFaMEAxEjAQBgNVBAMMCXNh\nZ2hhdWxvcjEVMBMGCgmSJomT8ixkARkWBWdtYWlsMRMwEQYKCZImiZPyLGQBGRYD\nY29tMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAx0xdQYk2GwCpQ1n/\nn2mPVYHLYqU5TAn/82t5kbqBUWjbcj8tHAi41tJ19+fT/hH0dog8JHvho1zmOr71\nZIqreJQo60TqP6oE9a5HncUpjqbRp7tOmHo9E+mOW1yT4NiXqFf1YINExQKy2XND\nWPQ+T50ZNUsGMfHFWB4NAymejRWXlOEY3bvKW0UHFeNmouP5he51TjoP8uCc9536\n4AIWVP/zzzjwrFtC7av7nRw4Y+gX2bQjrkK2k2JS0ejiGzKBIEMJejcI2B+t79zT\nkUQq9SFwp2BrKSIy+4kh4CiF20RT/Hfc1MbvTxSIl/bbIxCYEOhmtHExHi0CoCWs\nYCGCXQIDAQABo3kwdzAJBgNVHRMEAjAAMAsGA1UdDwQEAwIEsDAdBgNVHQ4EFgQU\nSCpVzSBvYbO6B3oT3n3RCZmurG8wHgYDVR0RBBcwFYETc2FnaGF1bG9yQGdtYWls\nLmNvbTAeBgNVHRIEFzAVgRNzYWdoYXVsb3JAZ21haWwuY29tMA0GCSqGSIb3DQEB\nBQUAA4IBAQAeiGdC3e0WiZpm0cF/b7JC6hJYXC9Yv9VsRAWD9ROsLjFKwOhmonnc\n+l/QrmoTjMakYXBCai/Ca3L+k5eRrKilgyITILsmmFxK8sqPJXUw2Jmwk/dAky6x\nhHKVZAofT1OrOOPJ2USoZyhR/VI8epLaD5wUmkVDNqtZWviW+dtRa55aPYjRw5Pj\nwuj9nybhZr+BbEbmZE//2nbfkM4hCuMtxxxilPrJ22aYNmeWU0wsPpDyhPYxOUgU\nZjeLmnSDiwL6doiP5IiwALH/dcHU67ck3NGf6XyqNwQrrmtPY0mv1WVVL4Uh+vYE\nkHoFzE2no0BfBg78Re8fY69P5yES5ncC\n-----END CERTIFICATE-----\n".freeze]
  s.date = "2016-03-26"
  s.description = "A simple wrapper for the standard ruby OpenSSL library to encrypt and decrypt strings".freeze
  s.email = ["sean@shuber.io".freeze, "sbfaulkner@gmail.com".freeze, "billy.monk@gmail.com".freeze, "saghaulor@gmail.com".freeze]
  s.homepage = "http://github.com/attr-encrypted/encryptor".freeze
  s.licenses = ["MIT".freeze]
  s.post_install_message = "\n\n\nPlease be aware that Encryptor v2.0.0 had a major security bug when using AES-*-GCM algorithms.\n\nBy default You will not be able to decrypt data that was previously encrypted using an AES-*-GCM algorithm.\n\nPlease see the README and https://github.com/attr-encrypted/encryptor/pull/22 for more information.\n\n\n".freeze
  s.rdoc_options = ["--charset=UTF-8".freeze, "--inline-source".freeze, "--line-numbers".freeze, "--main".freeze, "README.md".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.0.0".freeze)
  s.requirements = ["openssl, >= v1.0.1".freeze]
  s.rubygems_version = "2.7.6".freeze
  s.summary = "A simple wrapper for the standard ruby OpenSSL library".freeze

  s.installed_by_version = "2.7.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<minitest>.freeze, [">= 0"])
      s.add_development_dependency(%q<rake>.freeze, [">= 0"])
      s.add_development_dependency(%q<simplecov>.freeze, [">= 0"])
      s.add_development_dependency(%q<simplecov-rcov>.freeze, [">= 0"])
      s.add_development_dependency(%q<codeclimate-test-reporter>.freeze, [">= 0"])
    else
      s.add_dependency(%q<minitest>.freeze, [">= 0"])
      s.add_dependency(%q<rake>.freeze, [">= 0"])
      s.add_dependency(%q<simplecov>.freeze, [">= 0"])
      s.add_dependency(%q<simplecov-rcov>.freeze, [">= 0"])
      s.add_dependency(%q<codeclimate-test-reporter>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<minitest>.freeze, [">= 0"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
    s.add_dependency(%q<simplecov>.freeze, [">= 0"])
    s.add_dependency(%q<simplecov-rcov>.freeze, [">= 0"])
    s.add_dependency(%q<codeclimate-test-reporter>.freeze, [">= 0"])
  end
end
