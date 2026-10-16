# frozen_string_literal: true

# Enable file_fixture usage from within fabricators
Fabrication::Schematic::Runner.class_eval do
  include RSpec::Rails::FileFixtureSupport
end
