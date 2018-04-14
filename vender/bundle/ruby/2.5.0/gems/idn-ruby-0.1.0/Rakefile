require 'rubygems'
require 'rake'
require 'rake/clean'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rake/extensiontask'

CLEAN << FileList[ 'ext/Makefile', 'ext/*.so', 'ext/*.o' ]

begin
  require 'jeweler'
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

Jeweler::Tasks.new do |gem|
  gem.name        = 'idn-ruby'
  gem.summary     = 'LibIDN Ruby Bindings.'
  gem.description = %q{
    Ruby Bindings for the GNU LibIDN library, an implementation of the
    Stringprep, Punycode and IDNA specifications defined by the IETF
    Internationalized Domain Names (IDN) working group.

    Included are the most important parts of the Stringprep, Punycode
    and IDNA APIs like performing Stringprep processings, encoding to
    and decoding from Punycode strings and converting entire domain names
    to and from the ACE encoded form.
  }
  gem.email       = 'deepfryed@gmail.com'
  gem.homepage    = 'http://github.com/deepfryed/idn-ruby'
  gem.authors     = ['Erik Abele', 'Bharanee Rathna']
  gem.files       = FileList['CHANGES', 'LICENSE', 'NOTICE', 'Rakefile', 'README', 'ext/*.{c,h}']
  gem.extensions  = FileList[ 'ext/**/extconf.rb' ]
  gem.test_files  = FileList[ 'test/*.rb' ]
end

Jeweler::GemcutterTasks.new

Rake::ExtensionTask.new do |ext|
  ext.name    = 'idn'
  ext.ext_dir = 'ext'
  ext.lib_dir = 'ext'
end

Rake::RDocTask.new do |rdoc|
  version       = File.exist?('VERSION') ? File.read('VERSION') : ""
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = "idn-ruby #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

Rake::TestTask.new(:test) do |test|
  test.libs    << 'ext'
  test.pattern = 'test/*.rb'
  test.verbose = true
end

task :test    => [ :compile, :check_dependencies ]
task :default => :test
