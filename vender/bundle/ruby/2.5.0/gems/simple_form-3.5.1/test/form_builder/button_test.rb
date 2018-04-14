# frozen_string_literal: true
# encoding: UTF-8
require 'test_helper'

class ButtonTest < ActionView::TestCase
  def with_button_for(object, *args)
    with_concat_form_for(object) do |f|
      f.button(*args)
    end
  end

  test 'builder creates buttons' do
    with_button_for :post, :submit
    assert_select 'form input.button[type=submit][value="Save Post"]'
  end

  test 'builder creates buttons with options' do
    with_button_for :post, :submit, class: 'my_button'
    assert_select 'form input.button.my_button[type=submit][value="Save Post"]'
  end

  test 'builder does not modify the options hash' do
    options = { class: 'my_button' }
    with_button_for :post, :submit, options
    assert_select 'form input.button.my_button[type=submit][value="Save Post"]'
    assert_equal({ class: 'my_button' }, options)
  end

  test 'builder creates buttons for records' do
    @user.new_record!
    with_button_for @user, :submit
    assert_select 'form input.button[type=submit][value="Create User"]'
  end

  test "builder uses the default class from the configuration" do
    swap SimpleForm, button_class: 'btn' do
      with_button_for :post, :submit
      assert_select 'form input.btn[type=submit][value="Save Post"]'
    end
  end

  if ActionView::Helpers::FormBuilder.method_defined?(:button)
    test "allows to use Rails button helper when available" do
      with_button_for :post, :button, 'Save!'
      assert_select 'form button.button[type=submit]', 'Save!'
    end
  end
end
