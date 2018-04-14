require 'shindo/rake'
require 'rspec/core/rake_task'
require 'bundler/gem_tasks'
require 'rdoc/task'

Shindo::Rake.new

RSpec::Core::RakeTask.new(:spec, :format) do |t, args|
  format = args[:format] || 'doc'
  t.rspec_opts = ["-c", "-f #{format}", "-r ./spec/spec_helper.rb"]
  t.pattern = 'spec/**/*_spec.rb'
end

task :default => [:tests, :test]
task :test => :spec

desc "update bundled certs"
task :update_certs do
  # update curl bundle for end-users
  require File.join(File.dirname(__FILE__), 'lib', 'excon')
  File.open(File.join(File.dirname(__FILE__), 'data', 'cacert.pem'), 'w') do |file|
    data = Excon.get("https://curl.haxx.se/ca/cacert.pem").body
    file.write(data)
  end

  # update self-signed certs for tests
  sh "openssl req -subj '/CN=excon/O=excon' -new -newkey rsa:2048 -sha256 -days 365 -nodes -x509 -keyout tests/data/excon.cert.key -out tests/data/excon.cert.crt"
  sh "openssl req -subj '/CN=127.0.0.1/O=excon' -new -newkey rsa:2048 -sha256 -days 365 -nodes -x509 -keyout tests/data/127.0.0.1.cert.key -out tests/data/127.0.0.1.cert.crt"
end

desc "Open an irb session preloaded with this library"
task :console do
  sh "irb -rubygems -r ./lib/#{name}.rb"
end

desc "check ssl settings"
task :hows_my_ssl do
  require File.join(File.dirname(__FILE__), 'lib', 'excon')
  data = Excon.get("https://www.howsmyssl.com/a/check").body
  puts data
end
