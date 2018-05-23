begin
  require 'rubocop'
  require 'rubocop/rake_task'
rescue LoadError # rubocop:disable Lint/HandleExceptions
else
  require 'rbconfig'
  # https://github.com/bundler/bundler/blob/1b3eb2465a/lib/bundler/constants.rb#L2
  windows_platforms = /(msdos|mswin|djgpp|mingw)/
  if RbConfig::CONFIG['host_os'] =~ windows_platforms
    desc 'No-op rubocop on Windows-- unsupported platform'
    task :rubocop do
      puts 'Skipping rubocop on Windows'
    end
  elsif defined?(::Rubinius)
    desc 'No-op rubocop to avoid rbx segfault'
    task :rubocop do
      puts 'Skipping rubocop on rbx due to segfault'
      puts 'https://github.com/rubinius/rubinius/issues/3499'
    end
  else
    Rake::Task[:rubocop].clear if Rake::Task.task_defined?(:rubocop)
    patterns = [
      'Gemfile',
      'Rakefile',
      'lib/**/*.{rb,rake}',
      'config/**/*.rb',
      'app/**/*.rb',
      'test/**/*.rb'
    ]
    desc 'Execute rubocop'
    RuboCop::RakeTask.new(:rubocop) do |task|
      task.options = ['--rails', '--display-cop-names', '--display-style-guide']
      task.formatters = ['progress']
      task.patterns = patterns
      task.fail_on_error = true
    end

    namespace :rubocop do
      desc 'Auto-gen rubocop config'
      task :auto_gen_config do
        options = ['--auto-gen-config'].concat patterns
        require 'benchmark'
        result = 0
        cli = RuboCop::CLI.new
        time = Benchmark.realtime do
          result = cli.run(options)
        end
        puts "Finished in #{time} seconds" if cli.options[:debug]
        abort('RuboCop failed!') if result.nonzero?
      end
    end
  end
end
