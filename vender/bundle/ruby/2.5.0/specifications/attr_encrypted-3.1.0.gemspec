# -*- encoding: utf-8 -*-
# stub: attr_encrypted 3.1.0 ruby lib

Gem::Specification.new do |s|
  s.name = "attr_encrypted".freeze
  s.version = "3.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Sean Huber".freeze, "S. Brent Faulkner".freeze, "William Monk".freeze, "Stephen Aghaulor".freeze]
  s.cert_chain = ["-----BEGIN CERTIFICATE-----\nMIIDdDCCAlygAwIBAgIBATANBgkqhkiG9w0BAQUFADBAMRIwEAYDVQQDDAlzYWdo\nYXVsb3IxFTATBgoJkiaJk/IsZAEZFgVnbWFpbDETMBEGCgmSJomT8ixkARkWA2Nv\nbTAeFw0xODAyMTIwMzMzMThaFw0xOTAyMTIwMzMzMThaMEAxEjAQBgNVBAMMCXNh\nZ2hhdWxvcjEVMBMGCgmSJomT8ixkARkWBWdtYWlsMRMwEQYKCZImiZPyLGQBGRYD\nY29tMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAvOLqbSmj5txfw39a\nKi0g3BJWGrfGBiSRq9aThUGzoiaqyDo/m1WMQdgPioZG+P923okChEWFjhSymBQU\neMdys6JRPm5ortp5sh9gesOWoozqb8R55d8rr1V7pY533cCut53Kb1wiitjkfXjR\nefT2HPh6nV6rYjGMJek/URaCNzsZo7HCkRsKdezP+BKr4V4wOka69tfJX5pcvFvR\niiqfaiP4RK12hYdsFnSVKiKP7SAFTFiYcohbL8TUW6ezQQqJCK0M6fu74EWVCnBS\ngFVjj931BuD8qhuxMiB6uC6FKxemB5TRGBLzn7RcrOMAo2inMAopjkGeQJUAyVCm\nJ5US3wIDAQABo3kwdzAJBgNVHRMEAjAAMAsGA1UdDwQEAwIEsDAdBgNVHQ4EFgQU\nhJEuSZgvuuIhIsxQ/0pRQTBVzokwHgYDVR0RBBcwFYETc2FnaGF1bG9yQGdtYWls\nLmNvbTAeBgNVHRIEFzAVgRNzYWdoYXVsb3JAZ21haWwuY29tMA0GCSqGSIb3DQEB\nBQUAA4IBAQCsBS2cxqTmV4nXJEH/QbdgjVDAZbK6xf2gpM3vCRlYsy7Wz6GEoOpD\nbzRkjxZwGNbhXShMUZwm6zahYQ/L1/HFztLoMBMkm8EIfPxH0PDrP4aWl0oyWxmU\nOLm0/t9icSWRPPJ1tLJvuAaDdVpY5dEHd6VdnNJGQC5vHKRInt1kEyqEttIJ/xmJ\nleSEFyMeoFsR+C/WPG9WSC+xN0eXqakCu6YUJoQzCn/7znv8WxpHEbeZjNIHq0qb\nnbqZ/ZW1bwzj1T/NIbnMr37wqV29XwkI4+LbewMkb6/bDPYl0qZpAkCxKtGYCCJp\nl6KPs9K/72yH00dxuAhiTXikTkcLXeQJ\n-----END CERTIFICATE-----\n".freeze]
  s.date = "2018-02-11"
  s.description = "Generates attr_accessors that encrypt and decrypt attributes transparently".freeze
  s.email = ["seah@shuber.io".freeze, "sbfaulkner@gmail.com".freeze, "billy.monk@gmail.com".freeze, "saghaulor@gmail.com".freeze]
  s.homepage = "http://github.com/attr-encrypted/attr_encrypted".freeze
  s.licenses = ["MIT".freeze]
  s.post_install_message = "\n\n\nWARNING: Several insecure default options and features were deprecated in attr_encrypted v2.0.0.\n\nAdditionally, there was a bug in Encryptor v2.0.0 that insecurely encrypted data when using an AES-*-GCM algorithm.\n\nThis bug was fixed but introduced breaking changes between v2.x and v3.x.\n\nPlease see the README for more information regarding upgrading to attr_encrypted v3.0.0.\n\n\n".freeze
  s.rdoc_options = ["--line-numbers".freeze, "--inline-source".freeze, "--main".freeze, "README.rdoc".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.0.0".freeze)
  s.rubygems_version = "2.7.6".freeze
  s.summary = "Encrypt and decrypt attributes".freeze

  s.installed_by_version = "2.7.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<encryptor>.freeze, ["~> 3.0.0"])
      s.add_development_dependency(%q<activerecord>.freeze, ["~> 4.1.16"])
      s.add_development_dependency(%q<actionpack>.freeze, ["~> 4.1.16"])
      s.add_development_dependency(%q<datamapper>.freeze, [">= 0"])
      s.add_development_dependency(%q<rake>.freeze, [">= 0"])
      s.add_development_dependency(%q<minitest>.freeze, [">= 0"])
      s.add_development_dependency(%q<sequel>.freeze, [">= 0"])
      s.add_development_dependency(%q<sqlite3>.freeze, [">= 0"])
      s.add_development_dependency(%q<dm-sqlite-adapter>.freeze, [">= 0"])
      s.add_development_dependency(%q<simplecov>.freeze, [">= 0"])
      s.add_development_dependency(%q<simplecov-rcov>.freeze, [">= 0"])
      s.add_development_dependency(%q<codeclimate-test-reporter>.freeze, ["<= 0.6.0"])
    else
      s.add_dependency(%q<encryptor>.freeze, ["~> 3.0.0"])
      s.add_dependency(%q<activerecord>.freeze, ["~> 4.1.16"])
      s.add_dependency(%q<actionpack>.freeze, ["~> 4.1.16"])
      s.add_dependency(%q<datamapper>.freeze, [">= 0"])
      s.add_dependency(%q<rake>.freeze, [">= 0"])
      s.add_dependency(%q<minitest>.freeze, [">= 0"])
      s.add_dependency(%q<sequel>.freeze, [">= 0"])
      s.add_dependency(%q<sqlite3>.freeze, [">= 0"])
      s.add_dependency(%q<dm-sqlite-adapter>.freeze, [">= 0"])
      s.add_dependency(%q<simplecov>.freeze, [">= 0"])
      s.add_dependency(%q<simplecov-rcov>.freeze, [">= 0"])
      s.add_dependency(%q<codeclimate-test-reporter>.freeze, ["<= 0.6.0"])
    end
  else
    s.add_dependency(%q<encryptor>.freeze, ["~> 3.0.0"])
    s.add_dependency(%q<activerecord>.freeze, ["~> 4.1.16"])
    s.add_dependency(%q<actionpack>.freeze, ["~> 4.1.16"])
    s.add_dependency(%q<datamapper>.freeze, [">= 0"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
    s.add_dependency(%q<minitest>.freeze, [">= 0"])
    s.add_dependency(%q<sequel>.freeze, [">= 0"])
    s.add_dependency(%q<sqlite3>.freeze, [">= 0"])
    s.add_dependency(%q<dm-sqlite-adapter>.freeze, [">= 0"])
    s.add_dependency(%q<simplecov>.freeze, [">= 0"])
    s.add_dependency(%q<simplecov-rcov>.freeze, [">= 0"])
    s.add_dependency(%q<codeclimate-test-reporter>.freeze, ["<= 0.6.0"])
  end
end
