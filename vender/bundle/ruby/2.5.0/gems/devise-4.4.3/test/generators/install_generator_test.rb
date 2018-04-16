# frozen_string_literal: true

require "test_helper"

class InstallGeneratorTest < Rails::Generators::TestCase
  tests Devise::Generators::InstallGenerator
  destination File.expand_path("../../tmp", __FILE__)
  setup :prepare_destination

  test "assert all files are properly created" do
    run_generator(["--orm=active_record"])
    assert_file "config/initializers/devise.rb", /devise\/orm\/active_record/
    assert_file "config/locales/devise.en.yml"
  end

  test "fails if no ORM is specified" do
    stderr = capture(:stderr) do
      run_generator
    end

    assert_match %r{An ORM must be set to install Devise}, stderr

    assert_no_file "config/initializers/devise.rb"
    assert_no_file "config/locales/devise.en.yml"
  end
end
