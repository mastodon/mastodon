require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'test'
end

desc 'Run tests'
task :default do
  ENV['TEST'] = 'test/test_colorize.rb'
  Rake::Task[:test].execute
  ENV['TEST'] = 'test/test_colorized_string.rb'
  Rake::Task[:test].execute
end
