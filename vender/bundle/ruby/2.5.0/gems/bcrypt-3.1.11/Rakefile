require 'rspec/core/rake_task'
require 'rubygems/package_task'
require 'rake/extensiontask'
require 'rake/javaextensiontask'
require 'rake/clean'
require 'rdoc/task'
require 'benchmark'

CLEAN.include(
  "tmp",
  "lib/1.8",
  "lib/1.9",
  "lib/2.0",
  "lib/2.1",
  "lib/bcrypt_ext.jar",
  "lib/bcrypt_ext.so"
)
CLOBBER.include(
  "doc",
  "pkg"
)

GEMSPEC = Gem::Specification.load("bcrypt.gemspec")

task :default => [:compile, :spec]

desc "Run all specs"
RSpec::Core::RakeTask.new do |t|
  t.pattern = 'spec/**/*_spec.rb'
  t.ruby_opts = '-w'
end

desc "Run all specs, with coverage testing"
RSpec::Core::RakeTask.new(:rcov) do |t|
  t.pattern = 'spec/**/*_spec.rb'
  t.rcov = true
  t.rcov_path = 'doc/coverage'
  t.rcov_opts = ['--exclude', 'rspec,diff-lcs,rcov,_spec,_helper']
end

desc 'Generate RDoc'
RDoc::Task.new do |rdoc|
  rdoc.rdoc_dir = 'doc/rdoc'
  rdoc.options += GEMSPEC.rdoc_options
  rdoc.template = ENV['TEMPLATE'] if ENV['TEMPLATE']
  rdoc.rdoc_files.include(*GEMSPEC.extra_rdoc_files)
end

Gem::PackageTask.new(GEMSPEC) do |pkg|
  pkg.need_zip = true
  pkg.need_tar = true
end

if RUBY_PLATFORM =~ /java/
  Rake::JavaExtensionTask.new('bcrypt_ext', GEMSPEC) do |ext|
    ext.ext_dir = 'ext/jruby'
  end
else
  Rake::ExtensionTask.new("bcrypt_ext", GEMSPEC) do |ext|
    ext.ext_dir = 'ext/mri'
    ext.cross_compile = true
    ext.cross_platform = ['x86-mingw32', 'x64-mingw32']
  end

  ENV['RUBY_CC_VERSION'].to_s.split(':').each do |ruby_version|
    platforms = {
      "x86-mingw32" => "i686-w64-mingw32",
      "x64-mingw32" => "x86_64-w64-mingw32"
    }
    platforms.each do |platform, prefix|
      task "copy:bcrypt_ext:#{platform}:#{ruby_version}" do |t|
        %w[lib tmp/#{platform}/stage/lib].each do |dir|
          so_file = "#{dir}/#{ruby_version[/^\d+\.\d+/]}/bcrypt_ext.so"
          if File.exists?(so_file)
            sh "#{prefix}-strip -S #{so_file}"
          end
        end
      end
    end
  end
end

desc "Run a set of benchmarks on the compiled extension."
task :benchmark do
  TESTS = 100
  TEST_PWD = "this is a test"
  require File.expand_path(File.join(File.dirname(__FILE__), "lib", "bcrypt"))
  Benchmark.bmbm do |results|
    4.upto(10) do |n|
      results.report("cost #{n}:") { TESTS.times { BCrypt::Password.create(TEST_PWD, :cost => n) } }
    end
  end
end
