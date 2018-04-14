Gem::Specification.new do |s|
  s.name = "http_parser.rb"
  s.version = "0.6.0"
  s.summary = "Simple callback-based HTTP request/response parser"
  s.description = "Ruby bindings to http://github.com/ry/http-parser and http://github.com/a2800276/http-parser.java"

  s.authors = ["Marc-Andre Cournoyer", "Aman Gupta"]
  s.email   = ["macournoyer@gmail.com", "aman@tmm1.net"]
  s.license = 'MIT'

  s.homepage = "http://github.com/tmm1/http_parser.rb"
  s.files = `git ls-files`.split("\n") + Dir['ext/ruby_http_parser/vendor/**/*']

  s.require_paths = ["lib"]
  s.extensions    = ["ext/ruby_http_parser/extconf.rb"]

  s.add_development_dependency 'rake-compiler', '>= 0.7.9'
  s.add_development_dependency 'rspec', '>= 2.0.1'
  s.add_development_dependency 'json', '>= 1.4.6'
  s.add_development_dependency 'benchmark_suite'
  s.add_development_dependency 'ffi'

  if RUBY_PLATFORM =~ /java/
    s.add_development_dependency 'jruby-openssl'
  else
    s.add_development_dependency 'yajl-ruby', '>= 0.8.1'
  end
end
