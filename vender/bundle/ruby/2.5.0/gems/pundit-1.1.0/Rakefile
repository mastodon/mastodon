require "rubygems"
require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "yard"
require "rubocop/rake_task"

RuboCop::RakeTask.new

desc "Run all examples"
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = %w[--color]
end

YARD::Rake::YardocTask.new do |t|
  t.files = ["lib/**/*.rb"]
end

task default: :spec
task default: :rubocop unless RUBY_ENGINE == "rbx"
