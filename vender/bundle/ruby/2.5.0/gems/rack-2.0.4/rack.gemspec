Gem::Specification.new do |s|
  s.name            = "rack"
  s.version = File.read('lib/rack.rb')[/RELEASE += +([\"\'])([\d][\w\.]+)\1/, 2]
  s.platform        = Gem::Platform::RUBY
  s.summary         = "a modular Ruby webserver interface"
  s.license         = "MIT"

  s.description = <<-EOF
Rack provides a minimal, modular and adaptable interface for developing
web applications in Ruby.  By wrapping HTTP requests and responses in
the simplest way possible, it unifies and distills the API for web
servers, web frameworks, and software in between (the so-called
middleware) into a single method call.

Also see https://rack.github.io/.
EOF

  s.files           = Dir['{bin/*,contrib/*,example/*,lib/**/*,test/**/*}'] +
                        %w(COPYING rack.gemspec Rakefile README.rdoc SPEC)
  s.bindir          = 'bin'
  s.executables     << 'rackup'
  s.require_path    = 'lib'
  s.extra_rdoc_files = ['README.rdoc', 'HISTORY.md']
  s.test_files      = Dir['test/spec_*.rb']

  s.author          = 'Christian Neukirchen'
  s.email           = 'chneukirchen@gmail.com'
  s.homepage        = 'https://rack.github.io/'
  s.required_ruby_version = '>= 2.2.2'

  s.add_development_dependency 'minitest', "~> 5.0"
  s.add_development_dependency 'minitest-sprint'
  s.add_development_dependency 'rake'
end
