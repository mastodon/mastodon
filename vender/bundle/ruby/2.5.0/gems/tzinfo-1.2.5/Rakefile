require 'rubygems'
require 'rubygems/package_task'
require 'fileutils'
require 'rake/testtask'

# Ignore errors loading rdoc/task (the rdoc tasks will be excluded if
# rdoc is unavailable).
begin
  require 'rdoc/task'
rescue LoadError, RuntimeError
end

BASE_DIR = File.expand_path(File.dirname(__FILE__))

task :default => [:test]

spec = eval(File.read('tzinfo.gemspec'))

class TZInfoPackageTask < Gem::PackageTask
  alias_method :orig_sh, :sh
  private :orig_sh

  def sh(*cmd, &block)
    if cmd[0] == '__tar_with_owner__' && cmd[1] =~ /\A-?[zjcvf]+\z/
      opts = cmd[1]
      cmd = ['tar', 'c', '--owner', '0', '--group', '0', "#{opts.start_with?('-') ? '' : '-'}#{opts.gsub('c', '')}"] + cmd.drop(2)
    elsif cmd.first =~ /\A__tar_with_owner__ -?([zjcvf]+)(.*)\z/
      opts = $1
      args = $2
      cmd[0] = "tar c --owner 0 --group 0 -#{opts.gsub('c', '')}#{args}"    
    end
  
    orig_sh(*cmd, &block)
  end
end

def add_signing_key(spec)
  # Attempt to find the private key and add options to sign the gem if found.
  private_key_path = File.expand_path(File.join(BASE_DIR, '..', 'key', 'gem-private_key.pem'))
  
  if File.exist?(private_key_path)
    spec = spec.clone
    spec.signing_key = private_key_path
    spec.cert_chain = [File.join(BASE_DIR, 'gem-public_cert.pem')]
  else
    puts 'WARNING: Private key not found. Not signing gem file.'
  end
  
  spec
end

package_task = TZInfoPackageTask.new(add_signing_key(spec)) do |pkg|
  pkg.need_zip = true
  pkg.need_tar_gz = true
  pkg.tar_command = '__tar_with_owner__'
end

# Skip the rdoc task if RDoc::Task is unavailable
if defined?(RDoc) && defined?(RDoc::Task)
  RDoc::Task.new do |rdoc|
    rdoc.rdoc_dir = 'doc'
    rdoc.options.concat spec.rdoc_options
    rdoc.rdoc_files.include(spec.extra_rdoc_files) 
    rdoc.rdoc_files.include('lib')  
  end
end

Rake::Task[package_task.package_dir_path].enhance do
  recurse_chmod(package_task.package_dir_path)
end

Rake::Task[:package].enhance do
  FileUtils.rm_rf(package_task.package_dir_path)
end

def recurse_chmod(dir)
  File.chmod(0755, dir)
  
  Dir.entries(dir).each do |entry|
    if entry != '.' && entry != '..'    
      path = File.join(dir, entry)
      if File.directory?(path)
        recurse_chmod(path)
      else
        File.chmod(0644, path)
      end
    end
  end
end

desc 'Run tests using RubyDataSource, then ZoneinfoDataSource'
task :test => [:test_ruby, :test_zoneinfo] do
end

def setup_tests(test_task, type)
  test_task.libs = [File.join(BASE_DIR, 'lib')]
  test_task.pattern = File.join(BASE_DIR, 'test', "ts_all_#{type}.rb")
  test_task.warning = true
end

Rake::TestTask.new(:test_ruby) do |t|
  setup_tests(t, :ruby)
end

Rake::TestTask.new(:test_zoneinfo) do |t|
  setup_tests(t, :zoneinfo)
end
