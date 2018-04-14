# frozen_string_literal: true

require "test_helper"

if DEVISE_ORM == :mongoid
  require "generators/mongoid/devise_generator"

  class MongoidGeneratorTest < Rails::Generators::TestCase
    tests Mongoid::Generators::DeviseGenerator
    destination File.expand_path("../../tmp", __FILE__)
    setup :prepare_destination

    test "all files are properly created" do
      run_generator %w(monster)
      assert_file "app/models/monster.rb", /devise/
    end

    test "all files are properly deleted" do
      run_generator %w(monster)
      run_generator %w(monster), behavior: :revoke
      assert_no_file "app/models/monster.rb"
    end
  end
end

