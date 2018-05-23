version = File.read(File.expand_path("../../VERSION", __FILE__)).strip

Gem::Specification.new do |s|
  # general infos
  s.name        = "rack-protection"
  s.version     = version
  s.description = "Protect against typical web attacks, works with all Rack apps, including Rails."
  s.homepage    = "http://www.sinatrarb.com/protection/"
  s.summary     = s.description
  s.license     = 'MIT'
  s.authors     = ["https://github.com/sinatra/sinatra/graphs/contributors"]
  s.email       = "sinatrarb@googlegroups.com"
  s.files       = Dir["lib/**/*.rb"] + [
    "License",
    "README.md",
    "Rakefile",
    "Gemfile",
    "rack-protection.gemspec"
  ]

  # dependencies
  s.add_dependency "rack"
  s.add_development_dependency "rack-test"
  s.add_development_dependency "rspec", "~> 3.6"
end
