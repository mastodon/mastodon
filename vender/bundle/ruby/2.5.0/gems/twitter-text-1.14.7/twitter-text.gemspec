# encoding: utf-8

Gem::Specification.new do |s|
  s.name = "twitter-text"
  s.version = "1.14.7"
  s.authors = ["Matt Sanford", "Patrick Ewing", "Ben Cherry", "Britt Selvitelle",
               "Raffi Krikorian", "J.P. Cummins", "Yoshimasa Niwa", "Keita Fujii", "James Koval"]
  s.email = ["matt@twitter.com", "patrick.henry.ewing@gmail.com", "bcherry@gmail.com", "bs@brittspace.com",
             "raffi@twitter.com", "jcummins@twitter.com", "niw@niw.at", "keita@twitter.com", "jkoval@twitter.com"]
  s.homepage = "http://twitter.com"
  s.description = s.summary = "A gem that provides text handling for Twitter"
  s.license = "Apache 2.0"

  s.platform = Gem::Platform::RUBY
  s.has_rdoc = true
  s.summary = "Twitter text handling library"

  s.add_development_dependency "test-unit"
  s.add_development_dependency "multi_json", "~> 1.3"
  s.add_development_dependency "nokogiri", "~> 1.5.10"
  s.add_development_dependency "rake", "~> 11.1" # 12 removes method named `last_comment`
  s.add_development_dependency "rdoc"
  s.add_development_dependency "rspec", "~> 2.14.0"
  s.add_development_dependency "simplecov", "~> 0.8.0"
  s.add_runtime_dependency     "unf", "~> 0.1.0"

  s.files         = `git ls-files`.split("\n") + ['lib/assets/tld_lib.yml']
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
