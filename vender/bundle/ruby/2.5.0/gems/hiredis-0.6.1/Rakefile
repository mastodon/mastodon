require "bundler"
Bundler::GemHelper.install_tasks

require "rbconfig"
require "rake/testtask"
require "rake/extensiontask"

if RUBY_PLATFORM =~ /java|mswin|mingw/i

  task :rebuild do
    # no-op
  end

else

  Rake::ExtensionTask.new('hiredis_ext') do |task|
    # Pass --with-foo-config args to extconf.rb
    task.config_options = ARGV[1..-1] || []
    task.lib_dir = File.join(*['lib', 'hiredis', 'ext'])
  end

  namespace :hiredis do
    task :clean do
      # Fetch hiredis if not present
      if !File.directory?("vendor/hiredis/.git")
        system("git submodule update --init")
      end
      RbConfig::CONFIG['configure_args'] =~ /with-make-prog\=(\w+)/
      make_program = $1 || ENV['make']
      unless make_program then
        make_program = (/mswin/ =~ RUBY_PLATFORM) ? 'nmake' : 'make'
      end
      system("cd vendor/hiredis && #{make_program} clean")
    end
  end

  # "rake clean" should also clean bundled hiredis
  Rake::Task[:clean].enhance(['hiredis:clean'])

  # Build from scratch
  task :rebuild => [:clean, :compile]

end



task :default => [:rebuild, :test]

desc "Run tests"
Rake::TestTask.new(:test) do |t|
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end
