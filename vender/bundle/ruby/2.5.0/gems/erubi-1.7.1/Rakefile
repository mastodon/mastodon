require "rake"
require "rake/clean"

NAME = 'erubi'
CLEAN.include ["#{NAME}-*.gem", "rdoc", "coverage"]

# Gem Packaging and Release

desc "Packages #{NAME}"
task :package=>[:clean] do |p|
  sh %{gem build #{NAME}.gemspec}
end

### RDoc

RDOC_DEFAULT_OPTS = ["--line-numbers", "--inline-source", '--title', 'Erubi: Small ERB Implementation']

begin
  gem 'hanna-nouveau'
  RDOC_DEFAULT_OPTS.concat(['-f', 'hanna'])
rescue Gem::LoadError
end

rdoc_task_class = begin
  require "rdoc/task"
  RDoc::Task
rescue LoadError
  require "rake/rdoctask"
  Rake::RDocTask
end

RDOC_OPTS = RDOC_DEFAULT_OPTS + ['--main', 'README.rdoc']
RDOC_FILES = %w"README.rdoc CHANGELOG MIT-LICENSE lib/**/*.rb"

rdoc_task_class.new do |rdoc|
  rdoc.rdoc_dir = "rdoc"
  rdoc.options += RDOC_OPTS
  rdoc.rdoc_files.add RDOC_FILES
end

### Specs

spec = proc do |env|
  env.each{|k,v| ENV[k] = v}
  sh "#{FileUtils::RUBY} test/test.rb"
  env.each{|k,v| ENV.delete(k)}
end

desc "Run specs"
task "spec" do
  spec.call({})
end

task :default=>:spec

desc "Run specs with coverage"
task "spec_cov" do
  spec.call('COVERAGE'=>'1')
end
  
desc "Run specs with -w, some warnings filtered"
task "spec_w" do
  ENV['RUBYOPT'] ? (ENV['RUBYOPT'] += " -w") : (ENV['RUBYOPT'] = '-w')
  rake = ENV['RAKE'] || "#{FileUtils::RUBY} -S rake"
  sh %{#{rake} 2>&1 | egrep -v \": warning: instance variable @.* not initialized|: warning: method redefined; discarding old|: warning: previous definition of|: warning: statement not reached"}
end

### Other

desc "Start an IRB shell using the extension"
task :irb do
  require 'rbconfig'
  ruby = ENV['RUBY'] || File.join(RbConfig::CONFIG['bindir'], RbConfig::CONFIG['ruby_install_name'])
  irb = ENV['IRB'] || File.join(RbConfig::CONFIG['bindir'], File.basename(ruby).sub('ruby', 'irb'))
  sh %{#{irb} -I lib -r #{NAME}}
end


