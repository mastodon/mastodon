# frozen_string_literal: true

require 'test_helper'

class OmniAuthConfigTest < ActiveSupport::TestCase
  class MyStrategy
    include OmniAuth::Strategy
  end

  test 'strategy_name returns provider if no options given' do
    config = Devise::OmniAuth::Config.new :facebook, [{}]
    assert_equal :facebook, config.strategy_name
  end

  test 'strategy_name returns provider if no name option are given' do
    config = Devise::OmniAuth::Config.new :facebook, [{ other: :option }]
    assert_equal :facebook, config.strategy_name
  end

  test 'returns name option when have a name' do
    config = Devise::OmniAuth::Config.new :facebook, [{ name: :github }]
    assert_equal :github, config.strategy_name
  end

  test "finds contrib strategies" do
    config = Devise::OmniAuth::Config.new :facebook, [{}]
    assert_equal OmniAuth::Strategies::Facebook, config.strategy_class
  end

  class NamedTestStrategy
    include OmniAuth::Strategy
    option :name, :the_one
  end

  test "finds the strategy in OmniAuth's list by name" do
    config = Devise::OmniAuth::Config.new :the_one, [{}]
    assert_equal NamedTestStrategy, config.strategy_class
  end

  class UnNamedTestStrategy
    include OmniAuth::Strategy
  end

  test "finds the strategy in OmniAuth's list by class name" do
    config = Devise::OmniAuth::Config.new :un_named_test_strategy, [{}]
    assert_equal UnNamedTestStrategy, config.strategy_class
  end

  test 'raises an error if strategy cannot be found' do
    config = Devise::OmniAuth::Config.new :my_other_strategy, [{}]
    assert_raise Devise::OmniAuth::StrategyNotFound do
      config.strategy_class
    end
  end

  test 'allows the user to define a custom require path' do
    config = Devise::OmniAuth::Config.new :my_strategy, [{strategy_class: MyStrategy}]
    config_class = config.strategy_class
    assert_equal MyStrategy, config_class
  end
end
