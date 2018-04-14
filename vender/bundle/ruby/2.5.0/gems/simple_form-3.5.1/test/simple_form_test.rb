# frozen_string_literal: true
require 'test_helper'

class SimpleFormTest < ActiveSupport::TestCase
  test 'setup block yields self' do
    SimpleForm.setup do |config|
      assert_equal SimpleForm, config
    end
  end

  test 'setup block configure Simple Form' do
    SimpleForm.setup do |config|
      assert_equal SimpleForm, config
    end

    assert_equal true, SimpleForm.configured?
  end
end
