
require 'bundler'
Bundler::GemHelper.install_tasks

require 'fileutils'

require 'rspec/core'
require 'rspec/core/rake_task'
require 'yard'

task :spec => :compile

desc 'Run RSpec code examples and measure coverage'
task :coverage do |t|
  ENV['SIMPLE_COV'] = '1'
  Rake::Task["spec"].invoke
end

desc 'Generate YARD document'
YARD::Rake::YardocTask.new(:doc) do |t|
  t.files   = ['lib/msgpack/version.rb','doclib/**/*.rb']
  t.options = []
  t.options << '--debug' << '--verbose' if $trace
end

spec = eval File.read("msgpack.gemspec")

if RUBY_PLATFORM =~ /java/
  require 'rake/javaextensiontask'

  Rake::JavaExtensionTask.new('msgpack', spec) do |ext|
    ext.ext_dir = 'ext/java'
    jruby_home = RbConfig::CONFIG['prefix']
    jars = ["#{jruby_home}/lib/jruby.jar"]
    ext.classpath = jars.map { |x| File.expand_path(x) }.join(':')
    ext.lib_dir = File.join(*['lib', 'msgpack', ENV['FAT_DIR']].compact)
    ext.source_version = '1.6'
    ext.target_version = '1.6'
  end
else
  require 'rake/extensiontask'

  Rake::ExtensionTask.new('msgpack', spec) do |ext|
    ext.ext_dir = 'ext/msgpack'
    ext.cross_compile = true
    ext.lib_dir = File.join(*['lib', 'msgpack', ENV['FAT_DIR']].compact)
    # cross_platform names are of MRI's platform name
    ext.cross_platform = ['x86-mingw32', 'x64-mingw32']
  end
end

test_pattern = case
               when RUBY_PLATFORM =~ /java/ then 'spec/{,jruby/}*_spec.rb'
               when RUBY_ENGINE =~ /rbx/ then 'spec/*_spec.rb'
               else 'spec/{,cruby/}*_spec.rb' # MRI
               end
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = ["-c", "-f progress"]
  t.rspec_opts << "-Ilib"
  t.pattern = test_pattern
  t.verbose = true
end

namespace :build do
  desc 'Build gems for Windows per rake-compiler-dock'
  task :windows do
    require 'rake_compiler_dock'
    # See RUBY_CC_VERSION in https://github.com/rake-compiler/rake-compiler-dock/blob/master/Dockerfile
    RakeCompilerDock.sh 'bundle && gem i json && rake cross native gem RUBY_CC_VERSION=2.0.0:2.1.6:2.2.2:2.3.0:2.4.0:2.5.0'
  end
end

CLEAN.include('lib/msgpack/msgpack.*')

task :default => [:spec, :build, :doc]
