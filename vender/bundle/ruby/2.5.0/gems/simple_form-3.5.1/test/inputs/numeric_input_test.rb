# frozen_string_literal: true
# encoding: UTF-8
require 'test_helper'

class NumericInputTest < ActionView::TestCase
  test 'input generates an integer text field for integer attributes ' do
    with_input_for @user, :age, :integer
    assert_select 'input[type=number].integer#user_age'
  end

  test 'input generates a float text field for float attributes ' do
    with_input_for @user, :age, :float
    assert_select 'input[type=number].float#user_age'
  end

  test 'input generates a decimal text field for decimal attributes ' do
    with_input_for @user, :age, :decimal
    assert_select 'input[type=number].decimal#user_age'
  end

  test 'input does not generate min attribute by default' do
    with_input_for @user, :age, :integer
    assert_no_select 'input[min]'
  end

  test 'input does not generate max attribute by default' do
    with_input_for @user, :age, :integer
    assert_no_select 'input[max]'
  end

  test 'input infers min value from integer attributes with greater than validation' do
    with_input_for @other_validating_user, :age, :float
    assert_no_select 'input[min]'

    with_input_for @other_validating_user, :age, :integer
    assert_select 'input[min="18"]'
  end

  test 'input infers min value from integer attributes with greater than validation using symbol' do
    with_input_for @validating_user, :amount, :float
    assert_no_select 'input[min]'

    with_input_for @validating_user, :amount, :integer
    assert_select 'input[min="11"]'
  end

  test 'input infers min value from integer attributes with greater than or equal to validation using symbol' do
    with_input_for @validating_user, :attempts, :float
    assert_select 'input[min="1"]'

    with_input_for @validating_user, :attempts, :integer
    assert_select 'input[min="1"]'
  end

  test 'input infers min value from integer attributes with greater than validation using proc' do
    with_input_for @other_validating_user, :amount, :float
    assert_no_select 'input[min]'

    with_input_for @other_validating_user, :amount, :integer
    assert_select 'input[min="20"]'
  end

  test 'input infers min value from integer attributes with greater than or equal to validation using proc' do
    with_input_for @other_validating_user, :attempts, :float
    assert_select 'input[min="19"]'

    with_input_for @other_validating_user, :attempts, :integer
    assert_select 'input[min="19"]'
  end

  test 'input infers max value from attributes with less than validation' do
    with_input_for @other_validating_user, :age, :float
    assert_no_select 'input[max]'

    with_input_for @other_validating_user, :age, :integer
    assert_select 'input[max="99"]'
  end

  test 'input infers max value from attributes with less than validation using symbol' do
    with_input_for @validating_user, :amount, :float
    assert_no_select 'input[max]'

    with_input_for @validating_user, :amount, :integer
    assert_select 'input[max="99"]'
  end

  test 'input infers max value from attributes with less than or equal to validation using symbol' do
    with_input_for @validating_user, :attempts, :float
    assert_select 'input[max="100"]'

    with_input_for @validating_user, :attempts, :integer
    assert_select 'input[max="100"]'
  end

  test 'input infers max value from attributes with less than validation using proc' do
    with_input_for @other_validating_user, :amount, :float
    assert_no_select 'input[max]'

    with_input_for @other_validating_user, :amount, :integer
    assert_select 'input[max="118"]'
  end

  test 'input infers max value from attributes with less than or equal to validation using proc' do
    with_input_for @other_validating_user, :attempts, :float
    assert_select 'input[max="119"]'

    with_input_for @other_validating_user, :attempts, :integer
    assert_select 'input[max="119"]'
  end

  test 'input has step value of any except for integer attribute' do
    with_input_for @validating_user, :age, :float
    assert_select 'input[step="any"]'

    with_input_for @validating_user, :age, :integer
    assert_select 'input[step="1"]'

    with_input_for @validating_user, :age, :integer, as: :decimal, input_html: { step: 0.5 }
    assert_select 'input[step="0.5"]'
  end

  test 'numeric input does not generate placeholder by default' do
    with_input_for @user, :age, :integer
    assert_no_select 'input[placeholder]'
  end

  test 'numeric input accepts the placeholder option' do
    with_input_for @user, :age, :integer, placeholder: 'Put in your age'
    assert_select 'input.integer[placeholder="Put in your age"]'
  end

  test 'numeric input uses i18n to translate placeholder text' do
    store_translations(:en, simple_form: { placeholders: { user: {
      age: 'Age goes here'
    } } }) do
      with_input_for @user, :age, :integer
      assert_select 'input.integer[placeholder="Age goes here"]'
    end
  end

  # Numeric input but HTML5 disabled
  test 'when not using HTML5 input does not generate field with type number and use text instead' do
    swap_wrapper do
      with_input_for @user, :age, :integer
      assert_no_select "input[type=number]"
      assert_no_select "input#user_age[text]"
    end
  end

  test 'when not using HTML5 input does not use min or max or step attributes' do
    swap_wrapper do
      with_input_for @validating_user, :age, :integer
      assert_no_select "input[type=number]"
      assert_no_select "input[min]"
      assert_no_select "input[max]"
      assert_no_select "input[step]"
    end
  end

  %i[integer float decimal].each do |type|
    test "#{type} input infers min value from attributes with greater than or equal validation" do
      with_input_for @validating_user, :age, type
      assert_select 'input[min="18"]'
    end

    test "#{type} input infers the max value from attributes with less than or equal to validation" do
      with_input_for @validating_user, :age, type
      assert_select 'input[max="99"]'
    end
  end

  test 'min_max does not emit max value as bare string' do
    with_input_for @other_validating_user, :age, :integer
    assert_select 'input[max]'
    assert_no_select 'div', %r{^99}
  end
end
