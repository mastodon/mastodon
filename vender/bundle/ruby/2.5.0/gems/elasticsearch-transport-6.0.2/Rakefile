require "bundler/gem_tasks"

desc "Run unit tests"
task :default => 'test:unit'
task :test    => 'test:unit'

# ----- Test tasks ------------------------------------------------------------

require 'rake/testtask'
namespace :test do
  Rake::TestTask.new(:unit) do |test|
    test.libs << 'lib' << 'test'
    test.test_files = FileList["test/unit/**/*_test.rb"]
    test.verbose = false
    test.warning = false
  end

  Rake::TestTask.new(:integration) do |test|
    test.libs << 'lib' << 'test'
    test.test_files = FileList["test/integration/**/*_test.rb"]
    test.verbose = false
    test.warning = false
  end

  Rake::TestTask.new(:all) do |test|
    test.libs << 'lib' << 'test'
    test.test_files = FileList["test/unit/**/*_test.rb", "test/integration/**/*_test.rb"]
  end

  Rake::TestTask.new(:profile) do |test|
    test.libs << 'lib' << 'test'
    test.test_files = FileList["test/profile/**/*_test.rb"]
  end

  namespace :cluster do
    desc "Start Elasticsearch nodes for tests"
    task :start do
      $LOAD_PATH << File.expand_path('../lib', __FILE__) << File.expand_path('../test', __FILE__)
      require 'elasticsearch/extensions/test/cluster'
      Elasticsearch::Extensions::Test::Cluster.start
    end

    desc "Stop Elasticsearch nodes for tests"
    task :stop do
      $LOAD_PATH << File.expand_path('../lib', __FILE__) << File.expand_path('../test', __FILE__)
      require 'elasticsearch/extensions/test/cluster'
      Elasticsearch::Extensions::Test::Cluster.stop
    end
  end
end

# ----- Documentation tasks ---------------------------------------------------

require 'yard'
YARD::Rake::YardocTask.new(:doc) do |t|
  t.options = %w| --embed-mixins --markup=markdown |
end

# ----- Code analysis tasks ---------------------------------------------------

if defined?(RUBY_VERSION) && RUBY_VERSION > '1.9'
  require 'cane/rake_task'
  Cane::RakeTask.new(:quality) do |cane|
    cane.abc_max = 15
    cane.no_style = true
  end
end
