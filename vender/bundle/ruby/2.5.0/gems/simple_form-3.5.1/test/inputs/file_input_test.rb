# frozen_string_literal: true
# encoding: UTF-8
require 'test_helper'

class FileInputTest < ActionView::TestCase
  test 'input generates a file field' do
    with_input_for @user, :name, :file
    assert_select 'input#user_name[type=file]'
  end

  test "input generates a file field that doesn't accept placeholder" do
    store_translations(:en, simple_form: { placeholders: { user: { name: "text" } } }) do
      with_input_for @user, :name, :file
      assert_no_select 'input[placeholder]'
    end
  end
end
