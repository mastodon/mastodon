require "./lib/browser/version"

Gem::Specification.new do |s|
  s.required_ruby_version = ">= 2.0"
  s.name                  = "browser"
  s.version               = Browser::VERSION
  s.platform              = Gem::Platform::RUBY
  s.authors               = ["Nando Vieira"]
  s.email                 = ["fnando.vieira@gmail.com"]
  s.homepage              = "http://github.com/fnando/browser"
  s.summary               = "Do some browser detection with Ruby."
  s.description           = s.summary
  s.license               = "MIT"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- exe/*`
                    .split("\n")
                    .map {|f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "bundler", ">= 0"
  s.add_development_dependency "rake"
  s.add_development_dependency "rails"
  s.add_development_dependency "rack-test"
  s.add_development_dependency "minitest"
  s.add_development_dependency "minitest-utils"
  s.add_development_dependency "pry-meta"
  s.add_development_dependency "minitest-autotest"
  s.add_development_dependency "codeclimate-test-reporter"
  s.add_development_dependency "rubocop"
end
