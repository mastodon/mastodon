# frozen_string_literal: true

require 'test_helper'

class RailsTest < ActiveSupport::TestCase
  test 'correct initializer position' do
    initializer = Devise::Engine.initializers.detect { |i| i.name == 'devise.omniauth' }
    assert_equal :load_config_initializers, initializer.after
    assert_equal :build_middleware_stack, initializer.before
  end
end
