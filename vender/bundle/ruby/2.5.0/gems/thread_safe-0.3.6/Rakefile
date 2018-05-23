require 'bundler/gem_tasks'
require 'rspec'
require 'rspec/core/rake_task'

## safely load all the rake tasks in the `tasks` directory
def safe_load(file)
  begin
    load file
  rescue LoadError => ex
    puts "Error loading rake tasks from '#{file}' but will continue..."
    puts ex.message
  end
end

Dir.glob('tasks/**/*.rake').each do |rakefile|
  safe_load rakefile
end

task :default => :test

if defined?(JRUBY_VERSION)
  require 'ant'

  directory 'pkg/classes'
  directory 'pkg/tests'

  desc "Clean up build artifacts"
  task :clean do
    rm_rf "pkg/classes"
    rm_rf "pkg/tests"
    rm_rf "lib/thread_safe/jruby_cache_backend.jar"
  end

  desc "Compile the extension"
  task :compile => "pkg/classes" do |t|
    ant.javac :srcdir => "ext", :destdir => t.prerequisites.first,
      :source => "1.5", :target => "1.5", :debug => true,
      :classpath => "${java.class.path}:${sun.boot.class.path}"
  end

  desc "Build the jar"
  task :jar => :compile do
    ant.jar :basedir => "pkg/classes", :destfile => "lib/thread_safe/jruby_cache_backend.jar", :includes => "**/*.class"
  end

  desc "Build test jar"
  task 'test-jar' => 'pkg/tests' do |t|
    ant.javac :srcdir => 'spec/src', :destdir => t.prerequisites.first,
      :source => "1.5", :target => "1.5", :debug => true

    ant.jar :basedir => 'pkg/tests', :destfile => 'spec/package.jar', :includes => '**/*.class'
  end

  task :package => [ :clean, :compile, :jar, 'test-jar' ]
else
  # No need to package anything for non-jruby rubies
  task :package
end

RSpec::Core::RakeTask.new :test => :package do |t|
  t.rspec_opts = '--color --backtrace --tag ~unfinished --seed 1 --format documentation ./spec'
end
