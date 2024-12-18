require_relative "lib/subscription/version"

Gem::Specification.new do |spec|
  spec.name        = "subscription"
  spec.version     = Subscription::VERSION
  spec.authors     = ["Jesse Karmani"]
  spec.email       = ["jessekarmani@gmail.com"]
  spec.homepage    = "https://github.com/jesseplusplus/decodon/subscription"
  spec.summary     = "Subscription management engine for stripe and mastodon."
  spec.description = "Subscription management engine for stripe and mastodon."
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = spec.homepage

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "rails", "~> 7.1.1"
  spec.add_dependency "stripe"
end
