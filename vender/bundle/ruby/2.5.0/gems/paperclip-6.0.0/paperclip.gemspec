$LOAD_PATH.push File.expand_path("../lib", __FILE__)
require 'paperclip/version'

Gem::Specification.new do |s|
  s.name              = "paperclip"
  s.version           = Paperclip::VERSION
  s.platform          = Gem::Platform::RUBY
  s.author            = "Jon Yurek"
  s.email             = ["jyurek@thoughtbot.com"]
  s.homepage          = "https://github.com/thoughtbot/paperclip"
  s.summary           = "File attachments as attributes for ActiveRecord"
  s.description       = "Easy upload management for ActiveRecord"
  s.license           = "MIT"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  if File.exist?('UPGRADING')
    s.post_install_message = File.read("UPGRADING")
  end

  s.requirements << "ImageMagick"
  s.required_ruby_version = ">= 2.1.0"

  s.add_dependency('activemodel', '>= 4.2.0')
  s.add_dependency('activesupport', '>= 4.2.0')
  s.add_dependency('terrapin', '~> 0.6.0')
  s.add_dependency('mime-types')
  s.add_dependency('mimemagic', '~> 0.3.0')

  s.add_development_dependency('activerecord', '>= 4.2.0')
  s.add_development_dependency('shoulda')
  s.add_development_dependency('rspec', '~> 3.0')
  s.add_development_dependency('appraisal')
  s.add_development_dependency('mocha')
  s.add_development_dependency('aws-sdk-s3')
  s.add_development_dependency('bourne')
  s.add_development_dependency('cucumber-rails')
  s.add_development_dependency('cucumber-expressions', '4.0.3') # TODO: investigate failures on 4.0.4
  s.add_development_dependency('aruba', '~> 0.9.0')
  s.add_development_dependency('nokogiri')
  s.add_development_dependency('capybara')
  s.add_development_dependency('bundler')
  s.add_development_dependency('fog-aws')
  s.add_development_dependency('fog-local')
  s.add_development_dependency('launchy')
  s.add_development_dependency('rake')
  s.add_development_dependency('fakeweb')
  s.add_development_dependency('railties')
  s.add_development_dependency('generator_spec')
  s.add_development_dependency('timecop')
end
