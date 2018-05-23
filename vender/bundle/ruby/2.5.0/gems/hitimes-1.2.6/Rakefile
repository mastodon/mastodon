# vim: syntax=ruby
load 'tasks/this.rb'

This.name     = "hitimes"
This.author   = "Jeremy Hinegardner"
This.email    = "jeremy@copiousfreetime.org"
This.homepage = "http://github.com/copiousfreetime/#{ This.name }"

This.ruby_gemspec do |spec|
  spec.add_development_dependency( 'rake'         , '~> 12.0')
  spec.add_development_dependency( 'minitest'     , '~> 5.5' )
  spec.add_development_dependency( 'rdoc'         , '~> 5.0'  )
  spec.add_development_dependency( 'json'         , '~> 2.0' )
  spec.add_development_dependency( 'rake-compiler', '~> 1.0' )
  spec.add_development_dependency( 'rake-compiler-dock', '~> 0.6' )
  spec.add_development_dependency( 'simplecov'    , '~> 0.14' )

  spec.extensions.concat This.extension_conf_files
  spec.license = "ISC"
end

This.java_gemspec( This.ruby_gemspec ) do |spec|
  spec.extensions.clear
  spec.files << "lib/hitimes/hitimes.jar"
end

load 'tasks/default.rake'
load 'tasks/extension.rake'
