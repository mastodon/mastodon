# frozen_string_literal: true

require "rspec/core/rake_task"

RSpec::Core::RakeTask.new

RSpec::Core::RakeTask.new(:rcov) do |task|
  task.rcov = true
end
