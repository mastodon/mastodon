# frozen_string_literal: true
# encoding: UTF-8
require 'test_helper'

class HiddenInputTest < ActionView::TestCase
  test 'input generates a hidden field' do
    with_input_for @user, :name, :hidden
    assert_no_select 'input[type=text]'
    assert_select 'input#user_name[type=hidden]'
  end

  test 'hint does not be generated for hidden fields' do
    store_translations(:en, simple_form: { hints: { user: { name: "text" } } }) do
      with_input_for @user, :name, :hidden
      assert_no_select 'span.hint'
    end
  end

  test 'label does not be generated for hidden inputs' do
    with_input_for @user, :name, :hidden
    assert_no_select 'label'
  end

  test 'required/aria-required/optional options does not be generated for hidden inputs' do
    with_input_for @user, :name, :hidden
    assert_no_select 'input.required'
    assert_no_select 'input[required]'
    assert_no_select 'input[aria-required]'
    assert_no_select 'input.optional'
    assert_select 'input.hidden#user_name'
  end
end
