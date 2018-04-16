# frozen_string_literal: true
require 'test_helper'

# Tests for f.error and f.full_error
class ErrorTest < ActionView::TestCase
  def with_error_for(object, *args)
    with_concat_form_for(object) do |f|
      f.error(*args)
    end
  end

  def with_full_error_for(object, *args)
    with_concat_form_for(object) do |f|
      f.full_error(*args)
    end
  end

  test 'error does not generate content for attribute without errors' do
    with_error_for @user, :active
    assert_no_select 'span.error'
  end

  test 'error does not generate messages when object is not present' do
    with_error_for :project, :name
    assert_no_select 'span.error'
  end

  test "error does not generate messages when object doesn't respond to errors method" do
    @user.instance_eval { undef errors }
    with_error_for @user, :name
    assert_no_select 'span.error'
  end

  test 'error generates messages for attribute with single error' do
    with_error_for @user, :name
    assert_select 'span.error', "cannot be blank"
  end

  test 'error generates messages with decorated object responsive to #to_model' do
    with_error_for @decorated_user, :name
    assert_select 'span.error', "cannot be blank"
  end

  test 'error generates messages for attribute with one error when using first' do
    swap SimpleForm, error_method: :first do
      with_error_for @user, :age
      assert_select 'span.error', 'is not a number'
    end
  end

  test 'error generates messages for attribute with several errors when using to_sentence' do
    swap SimpleForm, error_method: :to_sentence do
      with_error_for @user, :age
      assert_select 'span.error', 'is not a number and must be greater than 18'
    end
  end

  test 'error is able to pass html options' do
    with_error_for @user, :name, id: 'error', class: 'yay'
    assert_select 'span#error.error.yay'
  end

  test 'error does not modify the options hash' do
    options = { id: 'error', class: 'yay' }
    with_error_for @user, :name, options
    assert_select 'span#error.error.yay'
    assert_equal({ id: 'error', class: 'yay' }, options)
  end

  test 'error finds errors on attribute and association' do
    with_error_for @user, :company_id, as: :select,
      error_method: :to_sentence, reflection: Association.new(Company, :company, {})
    assert_select 'span.error', 'must be valid and company must be present'
  end

  test 'error generates an error tag with a clean HTML' do
    with_error_for @user, :name
    assert_no_select 'span.error[error_html]'
  end

  test 'error generates an error tag with a clean HTML when errors options are present' do
    with_error_for @user, :name, error_tag: :p, error_prefix: 'Name', error_method: :first
    assert_no_select 'p.error[error_html]'
    assert_no_select 'p.error[error_tag]'
    assert_no_select 'p.error[error_prefix]'
    assert_no_select 'p.error[error_method]'
  end

  test 'error escapes error prefix text' do
    with_error_for @user, :name, error_prefix: '<b>Name</b>'
    assert_no_select 'span.error b'
  end

  test 'error escapes error text' do
    @user.errors.add(:action, 'must not contain <b>markup</b>')

    with_error_for @user, :action

    assert_select 'span.error'
    assert_no_select 'span.error b', 'markup'
  end

  test 'error generates an error message with raw HTML tags' do
    with_error_for @user, :name, error_prefix: '<b>Name</b>'.html_safe
    assert_select 'span.error', "Name cannot be blank"
    assert_select 'span.error b', "Name"
  end

  test 'error adds aria-invalid attribute to inputs' do
    with_form_for @user, :name, error: true
    assert_select "input#user_name[name='user[name]'][aria-invalid='true']"

    with_form_for @user, :name, as: :text, error: true
    assert_select "textarea#user_name[name='user[name]'][aria-invalid='true']"

    @user.errors.add(:active, 'must select one')
    with_form_for @user, :active, as: :radio_buttons
    assert_select "input#user_active_true[type=radio][name='user[active]'][aria-invalid='true']"
    assert_select "input#user_active_false[type=radio][name='user[active]'][aria-invalid='true']"

    with_form_for @user, :active, as: :check_boxes
    assert_select "input#user_active_true[type=checkbox][aria-invalid='true']"
    assert_select "input#user_active_false[type=checkbox][aria-invalid='true']"

    with_form_for @user, :company_id, as: :select, error: true
    assert_select "select#user_company_id[aria-invalid='true']"

    @user.errors.add(:password, 'must not be blank')
    with_form_for @user, :password
    assert_select "input#user_password[type=password][aria-invalid='true']"
  end

  # FULL ERRORS

  test 'full error generates a full error tag for the attribute' do
    with_full_error_for @user, :name
    assert_select 'span.error', "Super User Name! cannot be blank"
  end

  test 'full error generates a full error tag with a clean HTML' do
    with_full_error_for @user, :name
    assert_no_select 'span.error[error_html]'
  end

  test 'full error allows passing options to full error tag' do
    with_full_error_for @user, :name, id: 'name_error', error_prefix: "Your name"
    assert_select 'span.error#name_error', "Your name cannot be blank"
  end

  test 'full error does not modify the options hash' do
    options = { id: 'name_error' }
    with_full_error_for @user, :name, options
    assert_select 'span.error#name_error', "Super User Name! cannot be blank"
    assert_equal({ id: 'name_error' }, options)
  end

  test 'full error escapes error text' do
    @user.errors.add(:action, 'must not contain <b>markup</b>')

    with_full_error_for @user, :action

    assert_select 'span.error'
    assert_no_select 'span.error b', 'markup'
  end

  # CUSTOM WRAPPERS

  test 'error with custom wrappers works' do
    swap_wrapper do
      with_error_for @user, :name
      assert_select 'span.omg_error', "cannot be blank"
    end
  end

  # FULL_ERROR_WRAPPER

  test 'full error finds errors on association' do
    swap_wrapper :default, custom_wrapper_with_full_error do
      with_form_for @user, :company_id, as: :select
      assert_select 'span.error', 'Company must be valid'
    end
  end

  test 'full error finds errors on association with reflection' do
    swap_wrapper :default, custom_wrapper_with_full_error do
      with_form_for @user, :company_id, as: :select,
        reflection: Association.new(Company, :company, {})
      assert_select 'span.error', 'Company must be valid'
    end
  end

  test 'full error can be disabled' do
    swap_wrapper :default, custom_wrapper_with_full_error do
      with_form_for @user, :company_id, as: :select, full_error: false
      assert_no_select 'span.error'
    end
  end

  test 'full error can be disabled setting error to false' do
    swap_wrapper :default, custom_wrapper_with_full_error do
      with_form_for @user, :company_id, as: :select, error: false
      assert_no_select 'span.error'
    end
  end

  # CUSTOM ERRORS

  test 'input with custom error works' do
    error_text = "Super User Name! cannot be blank"
    with_form_for @user, :name, error: error_text

    assert_select 'span.error', error_text
  end

  test 'input with error option as true does not use custom error' do
    with_form_for @user, :name, error: true

    assert_select 'span.error', "cannot be blank"
  end

  test 'input with custom error does not generate the error if there is no error on the attribute' do
    with_form_for @user, :active, error: "Super User Active! cannot be blank"

    assert_no_select 'span.error'
  end

  test 'input with custom error works when using full_error component' do
    swap_wrapper :default, custom_wrapper_with_full_error do
      error_text = "Super User Name! cannot be blank"
      with_form_for @user, :name, error: error_text

      assert_select 'span.error', error_text
    end
  end

  test 'input with custom error escapes the error text' do
    with_form_for @user, :name, error: 'error must not contain <b>markup</b>'

    assert_select 'span.error'
    assert_no_select 'span.error b', 'markup'
  end

  test 'input with custom error does not escape the error text if it is safe' do
    with_form_for @user, :name, error: 'error must contain <b>markup</b>'.html_safe

    assert_select 'span.error'
    assert_select 'span.error b', 'markup'
  end

  test 'input with custom error escapes the error text using full_error component' do
    swap_wrapper :default, custom_wrapper_with_full_error do
      with_form_for @user, :name, error: 'error must not contain <b>markup</b>'

      assert_select 'span.error'
      assert_no_select 'span.error b', 'markup'
    end
  end

  test 'input with custom error does not escape the error text if it is safe using full_error component' do
    swap_wrapper :default, custom_wrapper_with_full_error do
      with_form_for @user, :name, error: 'error must contain <b>markup</b>'.html_safe

      assert_select 'span.error'
      assert_select 'span.error b', 'markup'
    end
  end

  test 'input with custom error when using full_error component does not generate the error if there is no error on the attribute' do
    swap_wrapper :default, custom_wrapper_with_full_error do
      with_form_for @user, :active, error: "Super User Active! can't be blank"

      assert_no_select 'span.error'
    end
  end
end
