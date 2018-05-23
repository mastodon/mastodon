# frozen_string_literal: true

directories %w[lib spec]
clearing :on

guard :rspec, cmd: "bundle exec rspec" do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})    { |m| "spec/#{m[1]}_spec.rb" }
  watch("spec/spec_helper.rb") { "spec" }
end
