# frozen_string_literal: true
# encoding: UTF-8
require 'test_helper'

class StringInputTest < ActionView::TestCase
  test 'input maps text field to string attribute' do
    with_input_for @user, :name, :string
    assert_select "input#user_name[type=text][name='user[name]'][value='New in SimpleForm!']"
  end

  test 'input generates a password field for password attributes' do
    with_input_for @user, :password, :password
    assert_select "input#user_password.password[type=password][name='user[password]']"
  end

  test 'input gets maxlength from column definition for string attributes' do
    with_input_for @user, :name, :string
    assert_select 'input.string[maxlength="100"]'
  end

  test 'input does not get maxlength from column without size definition for string attributes' do
    with_input_for @user, :action, :string
    assert_no_select 'input.string[maxlength]'
  end

  test 'input gets maxlength from column definition for password attributes' do
    with_input_for @user, :password, :password
    assert_select 'input.password[type=password][maxlength="100"]'
  end

  test 'input infers maxlength column definition from validation when present' do
    with_input_for @validating_user, :name, :string
    assert_select 'input.string[maxlength="25"]'
  end

  test 'input infers minlength column definition from validation when present' do
    with_input_for @validating_user, :name, :string
    assert_select 'input.string[minlength="5"]'
  end

  if ActionPack::VERSION::STRING < '5'
    test 'input does not get maxlength from validation when tokenizer present' do
      with_input_for @validating_user, :action, :string
      assert_no_select 'input.string[maxlength]'
    end

    test 'input does not get minlength from validation when tokenizer present' do
      with_input_for @validating_user, :action, :string
      assert_no_select 'input.string[minlength]'
    end
  end

  test 'input gets maxlength from validation when :is option present' do
    with_input_for @validating_user, :home_picture, :string
    assert_select 'input.string[maxlength="12"]'
  end

  test 'input gets minlength from validation when :is option present' do
    with_input_for @validating_user, :home_picture, :string
    assert_select 'input.string[minlength="12"]'
  end

  test 'input maxlength is the column limit plus one to make room for decimal point' do
    with_input_for @user, :credit_limit, :string

    assert_select 'input.string[maxlength="16"]'
  end

  test 'input does not generate placeholder by default' do
    with_input_for @user, :name, :string
    assert_no_select 'input[placeholder]'
  end

  test 'input accepts the placeholder option' do
    with_input_for @user, :name, :string, placeholder: 'Put in some text'
    assert_select 'input.string[placeholder="Put in some text"]'
  end

  test 'input generates a password field for password attributes that accept placeholder' do
    with_input_for @user, :password, :password, placeholder: 'Password Confirmation'
    assert_select 'input[type=password].password[placeholder="Password Confirmation"]#user_password'
  end

  test 'input does not infer pattern from attributes by default' do
    with_input_for @other_validating_user, :country, :string
    assert_no_select 'input[pattern="\w+"]'
  end

  test 'input infers pattern from attributes' do
    with_input_for @other_validating_user, :country, :string, pattern: true
    assert_select 'input[pattern="\w+"]'
  end

  test 'input infers pattern from attributes using proc' do
    with_input_for @other_validating_user, :name, :string, pattern: true
    assert_select 'input[pattern="\w+"]'
  end

  test 'input does not infer pattern from attributes if root default is false' do
    swap_wrapper do
      with_input_for @other_validating_user, :country, :string
      assert_no_select 'input[pattern="\w+"]'
    end
  end

  test 'input uses given pattern from attributes' do
    with_input_for @other_validating_user, :country, :string, input_html: { pattern: "\\d+" }
    assert_select 'input[pattern="\d+"]'
  end

  test 'input does not use pattern if model has :without validation option' do
    with_input_for @other_validating_user, :description, :string, pattern: true
    assert_no_select 'input[pattern="\d+"]'
  end

  test 'input uses i18n to translate placeholder text' do
    store_translations(:en, simple_form: { placeholders: { user: {
      name: 'Name goes here'
    } } }) do
      with_input_for @user, :name, :string
      assert_select 'input.string[placeholder="Name goes here"]'
    end
  end

  test 'input uses custom i18n scope to translate placeholder text' do
    store_translations(:en, my_scope: { placeholders: { user: {
      name: 'Name goes here'
    } } }) do
      swap SimpleForm, i18n_scope: :my_scope do
        with_input_for @user, :name, :string
        assert_select 'input.string[placeholder="Name goes here"]'
      end
    end
  end

  %i[email url search tel].each do |type|
    test "input allows type #{type}" do
      with_input_for @user, :name, type
      assert_select "input.string.#{type}"
      assert_select "input[type=#{type}]"
    end

    test "input does not allow type #{type} if HTML5 compatibility is disabled" do
      swap_wrapper do
        with_input_for @user, :name, type
        assert_select "input[type=text]"
        assert_no_select "input[type=#{type}]"
      end
    end
  end

  test 'input strips extra spaces from class html attribute with default classes' do
    with_input_for @user, :name, :string
    assert_select "input[class='string required']"
    assert_no_select "input[class='string required ']"
    assert_no_select "input[class=' string required']"
  end

  test 'input strips extra spaces from class html attribute when giving a custom class' do
    with_input_for @user, :name, :string, input_html: { class: "my_input" }
    assert_select "input[class='string required my_input']"
    assert_no_select "input[class='string required my_input ']"
    assert_no_select "input[class=' string required my_input']"
  end
end
