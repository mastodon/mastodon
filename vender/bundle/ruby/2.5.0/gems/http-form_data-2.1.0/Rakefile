# frozen_string_literal: true

require "bundler/gem_tasks"

require "rspec/core/rake_task"
RSpec::Core::RakeTask.new

begin
  require "rubocop/rake_task"
  RuboCop::RakeTask.new
rescue LoadError
  task :rubocop do
    $stderr.puts "RuboCop is disabled"
  end
end

if ENV["CI"].nil?
  task :default => %i[spec rubocop]
else
  case ENV["SUITE"]
  when "rubocop" then task :default => :rubocop
  else                task :default => :spec
  end
end
