# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'redis_lock/version'

Gem::Specification.new do |spec|
  spec.name          = "mario-redis-lock"
  spec.version       = RedisLock::VERSION
  spec.authors       = ["Mario Izquierdo"]
  spec.email         = ["tomario@gmail.com"]
  spec.summary       = %q{Yet another Ruby distributed lock using Redis, with emphasis in transparency.}
  spec.description   = %q{Yet another Ruby distributed lock using Redis, with emphasis in transparency. Requires Redis >= 2.6.12, because it uses the new syntax for SET to easily implement the robust algorithm described in the SET command documentation (http://redis.io/commands/set).}
  spec.homepage      = "https://github.com/marioizquierdo/mario-redis-lock"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'redis', '>= 3.0.5' # Needed support for SET with EX, PX, NX, XX options: https://github.com/redis/redis-rb/pull/343

  spec.add_development_dependency 'bundler', '>= 1'
  spec.add_development_dependency 'rake', '>= 10'
end
