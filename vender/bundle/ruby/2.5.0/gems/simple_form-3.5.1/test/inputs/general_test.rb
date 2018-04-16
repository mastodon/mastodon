# frozen_string_literal: true
# encoding: UTF-8
require 'test_helper'

class InputTest < ActionView::TestCase
  test 'input generates css class based on default input type' do
    with_input_for @user, :name, :string
    assert_select 'input.string'
    with_input_for @user, :description, :text
    assert_select 'textarea.text'
    with_input_for @user, :age, :integer
    assert_select 'input.integer'
    with_input_for @user, :born_at, :date
    assert_select 'select.date'
    with_input_for @user, :created_at, :datetime
    assert_select 'select.datetime'
  end

  test 'string input generates autofocus attribute when autofocus option is true' do
    with_input_for @user, :name, :string, autofocus: true
    assert_select 'input.string[autofocus]'
  end

  test 'input accepts input_class configuration' do
    swap SimpleForm, input_class: :xlarge do
      with_input_for @user, :name, :string
      assert_select 'input.xlarge'
      assert_no_select 'div.xlarge'
    end
  end

  test 'input does not add input_class when configured to not generate additional classes for input' do
    swap SimpleForm, input_class: 'xlarge', generate_additional_classes_for: [:wrapper] do
      with_input_for @user, :name, :string
      assert_select 'input'
      assert_no_select '.xlarge'
    end
  end

  test 'text input generates autofocus attribute when autofocus option is true' do
    with_input_for @user, :description, :text, autofocus: true
    assert_select 'textarea.text[autofocus]'
  end

  test 'numeric input generates autofocus attribute when autofocus option is true' do
    with_input_for @user, :age, :integer, autofocus: true
    assert_select 'input.integer[autofocus]'
  end

  test 'date input generates autofocus attribute when autofocus option is true' do
    with_input_for @user, :born_at, :date, autofocus: true
    assert_select 'select.date[autofocus]'
  end

  test 'datetime input generates autofocus attribute when autofocus option is true' do
    with_input_for @user, :created_at, :datetime, autofocus: true
    assert_select 'select.datetime[autofocus]'
  end

  test 'string input generates autofocus attribute when autofocus option is false' do
    with_input_for @user, :name, :string, autofocus: false
    assert_no_select 'input.string[autofocus]'
  end

  test 'text input generates autofocus attribute when autofocus option is false' do
    with_input_for @user, :description, :text, autofocus: false
    assert_no_select 'textarea.text[autofocus]'
  end

  test 'numeric input generates autofocus attribute when autofocus option is false' do
    with_input_for @user, :age, :integer, autofocus: false
    assert_no_select 'input.integer[autofocus]'
  end

  test 'date input generates autofocus attribute when autofocus option is false' do
    with_input_for @user, :born_at, :date, autofocus: false
    assert_no_select 'select.date[autofocus]'
  end

  test 'datetime input generates autofocus attribute when autofocus option is false' do
    with_input_for @user, :created_at, :datetime, autofocus: false
    assert_no_select 'select.datetime[autofocus]'
  end

  test 'string input generates autofocus attribute when autofocus option is not present' do
    with_input_for @user, :name, :string
    assert_no_select 'input.string[autofocus]'
  end

  test 'text input generates autofocus attribute when autofocus option is not present' do
    with_input_for @user, :description, :text
    assert_no_select 'textarea.text[autofocus]'
  end

  test 'numeric input generates autofocus attribute when autofocus option is not present' do
    with_input_for @user, :age, :integer
    assert_no_select 'input.integer[autofocus]'
  end

  test 'date input generates autofocus attribute when autofocus option is not present' do
    with_input_for @user, :born_at, :date
    assert_no_select 'select.date[autofocus]'
  end

  test 'datetime input generates autofocus attribute when autofocus option is not present' do
    with_input_for @user, :created_at, :datetime
    assert_no_select 'select.datetime[autofocus]'
  end

  # With no object
  test 'input is generated properly when object is not present' do
    with_input_for :project, :name, :string
    assert_select 'input.string.required#project_name'
  end

  test 'input as radio is generated properly when object is not present ' do
    with_input_for :project, :name, :radio_buttons
    assert_select 'input.radio_buttons#project_name_true'
    assert_select 'input.radio_buttons#project_name_false'
  end

  test 'input as select with collection is generated properly when object is not present' do
    with_input_for :project, :name, :select, collection: %w[Jose Carlos]
    assert_select 'select.select#project_name'
  end

  test 'input does not generate empty css class' do
    swap SimpleForm, generate_additional_classes_for: %i[wrapper label] do
      with_input_for :project, :name, :string
      assert_no_select 'input#project_name[class]'
    end
  end
end
