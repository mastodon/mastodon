require 'bundler'
Bundler::GemHelper.install_tasks

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)
task :test => :spec

begin
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new
rescue LoadError
  task :rubocop do
    warn 'RuboCop is disabled'
  end
end

task :default => %i[spec rubocop]

namespace :perf do
  task :setup do
    require 'omniauth'
    require 'rack/test'
    app = Rack::Builder.new do |b|
      b.use Rack::Session::Cookie, :secret => 'abc123'
      b.use OmniAuth::Strategies::Developer
      b.run lambda { |_env| [200, {}, ['Not Found']] }
    end.to_app
    @app = Rack::MockRequest.new(app)

    def call_app(path = ENV['GET_PATH'] || '/')
      result = @app.get(path)
      raise "Did not succeed #{result.body}" unless result.status == 200
      result
    end
  end

  task :ips => :setup do
    require 'benchmark/ips'
    Benchmark.ips do |x|
      x.report('ips') { call_app }
    end
  end

  task :mem => :setup do
    require 'memory_profiler'
    num = Integer(ENV['CNT'] || 1)
    report = MemoryProfiler.report do
      num.times { call_app }
    end
    report.pretty_print
  end
end
