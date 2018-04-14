# encoding: utf-8

begin
  require "rspec/core/rake_task"
  RSpec::Core::RakeTask.new(:spec) do |spec|
    spec.pattern = 'spec/**{,/*/**}/*_spec.rb'
  end
rescue LoadError
  $stderr.puts("Cannot load rspec task.")
end
