require 'bundler/setup'

task :default => [:test]

require "rake/testtask"

Rake::TestTask.new do |t|
  t.libs << "lib"
  t.libs << "spec"
  t.pattern = "spec/**/*_spec.rb"
end

task :travis do
  mock = 'true' || ENV['FOG_MOCK']
  sh("export FOG_MOCK=#{mock} && rake")

  if ENV['COVERAGE']
    require 'coveralls/rake/task'

    Coveralls::RakeTask.new
    Rake::Task["coveralls:push"].invoke
  end
end