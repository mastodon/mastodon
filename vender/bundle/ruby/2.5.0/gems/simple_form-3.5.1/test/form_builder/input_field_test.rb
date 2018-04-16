# frozen_string_literal: true
require 'test_helper'

# Tests for f.input_field
class InputFieldTest < ActionView::TestCase
  def with_input_field_for(object, *args)
    with_concat_form_for(object) do |f|
      f.input_field(*args)
    end
  end

  test "builder input_field only renders the input tag, nothing else" do
    with_input_field_for @user, :name

    assert_select 'form > input.required.string'
    assert_no_select 'div.string'
    assert_no_select 'label'
    assert_no_select '.hint'
  end

  test 'builder input_field allows overriding default input type' do
    with_input_field_for @user, :name, as: :text

    assert_no_select 'input#user_name'
    assert_select 'textarea#user_name.text'
  end

  test 'builder input_field generates input type based on column type' do
    with_input_field_for @user, :age

    assert_select 'input[type=number].integer#user_age'
  end

  test 'builder input_field is able to disable any component' do
    with_input_field_for @user, :age, html5: false

    assert_no_select 'input[html5=false]#user_age'
    assert_select 'input[type=text].integer#user_age'
  end

  test 'builder input_field allows passing options to input tag' do
    with_input_field_for @user, :name, id: 'name_input', class: 'name'

    assert_select 'input.string.name#name_input'
  end

  test 'builder input_field does not modify the options hash' do
    options = { id: 'name_input', class: 'name' }
    with_input_field_for @user, :name, options

    assert_select 'input.string.name#name_input'
    assert_equal({ id: 'name_input', class: 'name' }, options)
  end


  test 'builder input_field generates an input tag with a clean HTML' do
    with_input_field_for @user, :name, as: :integer, class: 'name'

    assert_no_select 'input.integer[input_html]'
    assert_no_select 'input.integer[as]'
  end

  test 'builder input_field uses i18n to translate placeholder text' do
    store_translations(:en, simple_form: { placeholders: { user: {
      name: 'Name goes here'
    } } }) do
      with_input_field_for @user, :name

      assert_select 'input.string[placeholder="Name goes here"]'
    end
  end

  test 'builder input_field uses min_max component' do
    with_input_field_for @other_validating_user, :age, as: :integer

    assert_select 'input[min="18"]'
  end

  test 'builder input_field does not use pattern component by default' do
    with_input_field_for @other_validating_user, :country, as: :string

    assert_no_select 'input[pattern="\w+"]'
  end

  test 'builder input_field infers pattern from attributes' do
    with_input_field_for @other_validating_user, :country, as: :string, pattern: true

    assert_select 'input[pattern="\w+"]'
  end

  test 'builder input_field accepts custom pattern' do
    with_input_field_for @other_validating_user, :country, as: :string, pattern: '\d+'

    assert_select 'input[pattern="\d+"]'
  end

  test 'builder input_field uses readonly component' do
    with_input_field_for @other_validating_user, :age, as: :integer, readonly: true

    assert_select 'input.integer.readonly[readonly]'
  end

  test 'builder input_field uses maxlength component' do
    with_input_field_for @validating_user, :name, as: :string

    assert_select 'input.string[maxlength="25"]'
  end

  test 'builder input_field uses minlength component' do
    with_input_field_for @validating_user, :name, as: :string

    assert_select 'input.string[minlength="5"]'
  end

  test 'builder collection input_field generates input tag with a clean HTML' do
    with_input_field_for @user, :status, collection: %w[Open Closed],
      class: 'status', label_method: :to_s, value_method: :to_s

    assert_no_select 'select.status[input_html]'
    assert_no_select 'select.status[collection]'
    assert_no_select 'select.status[label_method]'
    assert_no_select 'select.status[value_method]'
  end

  test 'build input_field does not treat "boolean_style" as a HTML attribute' do
    with_input_field_for @user, :active, boolean_style: :nested

    assert_no_select 'input.boolean[boolean_style]'
  end

  test 'build input_field does not treat "prompt" as a HTML attribute' do
    with_input_field_for @user, :attempts, collection: [1,2,3,4,5], prompt: :translate

    assert_no_select 'select[prompt]'
  end

  test 'build input_field without pattern component use the pattern string' do
    swap_wrapper :default, custom_wrapper_with_html5_components do
      with_input_field_for @user, :name, pattern: '\w+'

      assert_select 'input[pattern="\w+"]'
    end
  end

  test 'build input_field without placeholder component use the placeholder string' do
    swap_wrapper :default, custom_wrapper_with_html5_components do
      with_input_field_for @user, :name, placeholder: 'Placeholder'

      assert_select 'input[placeholder="Placeholder"]'
    end
  end

  test 'build input_field without maxlength component use the maxlength string' do
    swap_wrapper :default, custom_wrapper_with_html5_components do
      with_input_field_for @user, :name, maxlength: 5

      assert_select 'input[maxlength="5"]'
    end
  end

  test 'build input_field without minlength component use the minlength string' do
    swap_wrapper :default, custom_wrapper_with_html5_components do
      with_input_field_for @user, :name, minlength: 5

      assert_select 'input[minlength="5"]'
    end
  end

  test 'build input_field without readonly component use the readonly string' do
    swap_wrapper :default, custom_wrapper_with_html5_components do
      with_input_field_for @user, :name, readonly: true

      assert_select 'input[readonly="readonly"]'
    end
  end
end
