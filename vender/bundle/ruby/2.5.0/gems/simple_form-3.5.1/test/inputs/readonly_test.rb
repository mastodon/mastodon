# frozen_string_literal: true
require 'test_helper'

class ReadonlyTest < ActionView::TestCase
  test 'string input generates readonly elements when readonly option is true' do
    with_input_for @user, :name, :string, readonly: true
    assert_select 'input.string.readonly[readonly]'
  end

  test 'text input generates readonly elements when readonly option is true' do
    with_input_for @user, :description, :text, readonly: true
    assert_select 'textarea.text.readonly[readonly]'
  end

  test 'numeric input generates readonly elements when readonly option is true' do
    with_input_for @user, :age, :integer, readonly: true
    assert_select 'input.integer.readonly[readonly]'
  end

  test 'date input generates readonly elements when readonly option is true' do
    with_input_for @user, :born_at, :date, readonly: true
    assert_select 'select.date.readonly[readonly]'
  end

  test 'datetime input generates readonly elements when readonly option is true' do
    with_input_for @user, :created_at, :datetime, readonly: true
    assert_select 'select.datetime.readonly[readonly]'
  end

  test 'string input generates readonly elements when readonly option is false' do
    with_input_for @user, :name, :string, readonly: false
    assert_no_select 'input.string.readonly[readonly]'
  end

  test 'text input generates readonly elements when readonly option is false' do
    with_input_for @user, :description, :text, readonly: false
    assert_no_select 'textarea.text.readonly[readonly]'
  end

  test 'numeric input generates readonly elements when readonly option is false' do
    with_input_for @user, :age, :integer, readonly: false
    assert_no_select 'input.integer.readonly[readonly]'
  end

  test 'date input generates readonly elements when readonly option is false' do
    with_input_for @user, :born_at, :date, readonly: false
    assert_no_select 'select.date.readonly[readonly]'
  end

  test 'datetime input generates readonly elements when readonly option is false' do
    with_input_for @user, :created_at, :datetime, readonly: false
    assert_no_select 'select.datetime.readonly[readonly]'
  end

  test 'string input generates readonly elements when readonly option is not present' do
    with_input_for @user, :name, :string
    assert_no_select 'input.string.readonly[readonly]'
  end

  test 'text input generates readonly elements when readonly option is not present' do
    with_input_for @user, :description, :text
    assert_no_select 'textarea.text.readonly[readonly]'
  end

  test 'numeric input generates readonly elements when readonly option is not present' do
    with_input_for @user, :age, :integer
    assert_no_select 'input.integer.readonly[readonly]'
  end

  test 'date input generates readonly elements when readonly option is not present' do
    with_input_for @user, :born_at, :date
    assert_no_select 'select.date.readonly[readonly]'
  end

  test 'datetime input generates readonly elements when readonly option is not present' do
    with_input_for @user, :created_at, :datetime
    assert_no_select 'select.datetime.readonly[readonly]'
  end

  test 'input generates readonly attribute when the field is readonly and the object is persisted' do
    with_input_for @user, :credit_card, :string, readonly: :lookup
    assert_select 'input.string.readonly[readonly]'
  end

  test 'input does not generate readonly attribute when the field is readonly and the object is not persisted' do
    @user.new_record!
    with_input_for @user, :credit_card, :string, readonly: :lookup
    assert_no_select 'input.string.readonly[readonly]'
  end

  test 'input does not generate readonly attribute when the field is not readonly and the object is persisted' do
    with_input_for @user, :name, :string
    assert_no_select 'input.string.readonly[readonly]'
  end

  test 'input does not generate readonly attribute when the component is not used' do
    swap_wrapper do
      with_input_for @user, :credit_card, :string
      assert_no_select 'input.string.readonly[readonly]'
    end
  end
end
