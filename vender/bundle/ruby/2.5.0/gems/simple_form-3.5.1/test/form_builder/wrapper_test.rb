# frozen_string_literal: true
require 'test_helper'

class WrapperTest < ActionView::TestCase
  test 'wrapper does not have error class for attribute without errors' do
    with_form_for @user, :active
    assert_no_select 'div.field_with_errors'
  end

  test 'wrapper does not have error class when object is not present' do
    with_form_for :project, :name
    assert_no_select 'div.field_with_errors'
  end

  test 'wrapper adds the attribute name class' do
    with_form_for @user, :name
    assert_select 'div.user_name'
  end

  test 'wrapper adds the attribute name class for nested forms' do
    @user.company = Company.new(1, 'Empresa')
    with_concat_form_for @user do |f|
      concat(f.simple_fields_for(:company) do |company_form|
        concat(company_form.input :name)
      end)
    end

    assert_select 'div.user_company_name'
  end

  test 'wrapper adds the association name class' do
    with_form_for @user, :company
    assert_select 'div.user_company'
  end

  test 'wrapper adds error class for attribute with errors' do
    with_form_for @user, :name
    assert_select 'div.field_with_errors'
  end

  test 'wrapper adds hint class for attribute with a hint' do
    with_form_for @user, :name, hint: 'hint'
    assert_select 'div.field_with_hint'
  end

  test 'wrapper does not have disabled class by default' do
    with_form_for @user, :active
    assert_no_select 'div.disabled'
  end

  test 'wrapper has disabled class when input is disabled' do
    with_form_for @user, :active, disabled: true
    assert_select 'div.disabled'
  end

  test 'wrapper supports no wrapping when wrapper is false' do
    with_form_for @user, :name, wrapper: false
    assert_select 'form > label[for=user_name]'
    assert_select 'form > input#user_name.string'
  end

  test 'wrapper supports no wrapping when wrapper tag is false' do
    with_form_for @user, :name, wrapper: custom_wrapper_without_top_level
    assert_select 'form > label[for=user_name]'
    assert_select 'form > input#user_name.string'
  end

  test 'wrapper wraps tag adds required/optional css classes' do
    with_form_for @user, :name
    assert_select 'form div.input.required.string'

    with_form_for @user, :age, required: false
    assert_select 'form div.input.optional.integer'
  end

  test 'wrapper allows custom options to be given' do
    with_form_for @user, :name, wrapper_html: { id: "super_cool", class: 'yay' }
    assert_select 'form #super_cool.required.string.yay'
  end

  test 'wrapper allows tag to be given on demand' do
    with_form_for @user, :name, wrapper_tag: :b
    assert_select 'form b.required.string'
  end

  test 'wrapper allows wrapper class to be given on demand' do
    with_form_for @user, :name, wrapper_class: :wrapper
    assert_select 'form div.wrapper.required.string'
  end

  test 'wrapper skips additional classes when configured' do
    swap SimpleForm, generate_additional_classes_for: %i[input label] do
      with_form_for @user, :name, wrapper_class: :wrapper
      assert_select 'form div.wrapper'
      assert_no_select 'div.required'
      assert_no_select 'div.string'
      assert_no_select 'div.user_name'
    end
  end

  test 'wrapper does not generate empty css class' do
    swap SimpleForm, generate_additional_classes_for: %i[input label] do
      swap_wrapper :default, custom_wrapper_without_class do
        with_form_for @user, :name
        assert_no_select 'div#custom_wrapper_without_class[class]'
      end
    end
  end

  # Custom wrapper test

  test 'custom wrappers works' do
    swap_wrapper do
      with_form_for @user, :name, hint: "cool"
      assert_select "section.custom_wrapper div.another_wrapper label"
      assert_select "section.custom_wrapper div.another_wrapper input.string"
      assert_no_select "section.custom_wrapper div.another_wrapper span.omg_error"
      assert_select "section.custom_wrapper div.error_wrapper span.omg_error"
      assert_select "section.custom_wrapper > div.omg_hint", "cool"
    end
  end

  test 'custom wrappers can be turned off' do
    swap_wrapper do
      with_form_for @user, :name, another: false
      assert_no_select "section.custom_wrapper div.another_wrapper label"
      assert_no_select "section.custom_wrapper div.another_wrapper input.string"
      assert_select "section.custom_wrapper div.error_wrapper span.omg_error"
    end
  end

  test 'custom wrappers can have additional attributes' do
    swap_wrapper :default, custom_wrapper_with_additional_attributes do
      with_form_for @user, :name

      assert_select "div.custom_wrapper[title='some title'][data-wrapper='test']"
    end
  end

  test 'custom wrappers can have full error message on attributes' do
    swap_wrapper :default, custom_wrapper_with_full_error do
      with_form_for @user, :name
      assert_select 'span.error', "Name cannot be blank"
    end
  end

  test 'custom wrappers on a form basis' do
    swap_wrapper :another do
      with_concat_form_for(@user) do |f|
        f.input :name
      end

      assert_no_select "section.custom_wrapper div.another_wrapper label"
      assert_no_select "section.custom_wrapper div.another_wrapper input.string"

      with_concat_form_for(@user, wrapper: :another) do |f|
        f.input :name
      end

      assert_select "section.custom_wrapper div.another_wrapper label"
      assert_select "section.custom_wrapper div.another_wrapper input.string"
    end
  end

  test 'custom wrappers on input basis' do
    swap_wrapper :another do
      with_form_for @user, :name
      assert_no_select "section.custom_wrapper div.another_wrapper label"
      assert_no_select "section.custom_wrapper div.another_wrapper input.string"
      output_buffer.replace ""

      with_form_for @user, :name, wrapper: :another
      assert_select "section.custom_wrapper div.another_wrapper label"
      assert_select "section.custom_wrapper div.another_wrapper input.string"
      output_buffer.replace ""
    end

    with_form_for @user, :name, wrapper: custom_wrapper
    assert_select "section.custom_wrapper div.another_wrapper label"
    assert_select "section.custom_wrapper div.another_wrapper input.string"
  end

  test 'access wrappers with indifferent access' do
    swap_wrapper :another do
      with_form_for @user, :name, wrapper: "another"
      assert_select "section.custom_wrapper div.another_wrapper label"
      assert_select "section.custom_wrapper div.another_wrapper input.string"
    end
  end

  test 'does not duplicate label classes for different inputs' do
    swap_wrapper :default, custom_wrapper_with_label_html_option do
      with_concat_form_for(@user) do |f|
        concat f.input :name, required: false
        concat f.input :email, as: :email, required: true
      end

      assert_select "label.string.optional.extra-label-class[for='user_name']"
      assert_select "label.email.required.extra-label-class[for='user_email']"
      assert_no_select "label.string.optional.extra-label-class[for='user_email']"
    end
  end

  test 'raise error when wrapper not found' do
    assert_raise SimpleForm::WrapperNotFound do
      with_form_for @user, :name, wrapper: :not_found
    end
  end

  test 'uses wrapper for specified in config mapping' do
    swap_wrapper :another do
      swap SimpleForm, wrapper_mappings: { string: :another } do
        with_form_for @user, :name
        assert_select "section.custom_wrapper div.another_wrapper label"
        assert_select "section.custom_wrapper div.another_wrapper input.string"
      end
    end
  end

  test 'uses custom wrapper mapping per form basis' do
    swap_wrapper :another do
      with_concat_form_for @user, wrapper_mappings: { string: :another } do |f|
        concat f.input :name
      end
    end

    assert_select "section.custom_wrapper div.another_wrapper label"
    assert_select "section.custom_wrapper div.another_wrapper input.string"
  end

  test 'simple_fields_form reuses custom wrapper mapping per form basis' do
    @user.company = Company.new(1, 'Empresa')

    swap_wrapper :another do
      with_concat_form_for @user, wrapper_mappings: { string: :another } do |f|
        concat(f.simple_fields_for(:company) do |company_form|
          concat(company_form.input(:name))
        end)
      end
    end

    assert_select "section.custom_wrapper div.another_wrapper label"
    assert_select "section.custom_wrapper div.another_wrapper input.string"
  end

  test "input attributes class will merge with wrapper_options' classes" do
    swap_wrapper :default, custom_wrapper_with_input_class do
      with_concat_form_for @user do |f|
        concat f.input :name, input_html: { class: 'another-class' }
      end
    end

    assert_select "div.custom_wrapper input.string.inline-class.another-class"
  end

  test "input with data attributes will merge with wrapper_options' data" do
    swap_wrapper :default, custom_wrapper_with_input_data_modal do
      with_concat_form_for @user do |f|
        concat f.input :name, input_html: { data: { modal: 'another-data', target: 'merge-data' } }
      end
    end

    assert_select "input[data-wrapper='data-wrapper'][data-modal='another-data'][data-target='merge-data']"
  end

  test "input with aria attributes will merge with wrapper_options' aria" do
    skip unless ActionPack::VERSION::MAJOR == '4' && ActionPack::VERSION::MINOR >= '2'

    swap_wrapper :default, custom_wrapper_with_input_aria_modal do
      with_concat_form_for @user do |f|
        concat f.input :name, input_html: { aria: { modal: 'another-aria', target: 'merge-aria' } }
      end
    end

    assert_select "input[aria-wrapper='aria-wrapper'][aria-modal='another-aria'][aria-target='merge-aria']"
  end

  test 'input accepts attributes in the DSL' do
    swap_wrapper :default, custom_wrapper_with_input_class do
      with_concat_form_for @user do |f|
        concat f.input :name
      end
    end

    assert_select "div.custom_wrapper input.string.inline-class"
  end

  test 'label accepts attributes in the DSL' do
    swap_wrapper :default, custom_wrapper_with_label_class do
      with_concat_form_for @user do |f|
        concat f.input :name
      end
    end

    assert_select "div.custom_wrapper label.string.inline-class"
  end

  test 'label_input accepts attributes in the DSL' do
    swap_wrapper :default, custom_wrapper_with_label_input_class do
      with_concat_form_for @user do |f|
        concat f.input :name
      end
    end

    assert_select "div.custom_wrapper label.string.inline-class"
    assert_select "div.custom_wrapper input.string.inline-class"
  end

  test 'input accepts data attributes in the DSL' do
    swap_wrapper :default, custom_wrapper_with_input_attributes do
      with_concat_form_for @user do |f|
        concat f.input :name
      end
    end

    assert_select "div.custom_wrapper input.string[data-modal=true]"
  end

  test 'inline wrapper displays when there is content' do
    swap_wrapper :default, custom_wrapper_with_wrapped_optional_component do
      with_form_for @user, :name, hint: "cannot be blank"
      assert_select 'section.custom_wrapper div.no_output_wrapper p.omg_hint', "cannot be blank"
      assert_select 'p.omg_hint'
    end
  end

  test 'inline wrapper does not display when there is no content' do
    swap_wrapper :default, custom_wrapper_with_wrapped_optional_component do
      with_form_for @user, :name
      assert_select 'section.custom_wrapper div.no_output_wrapper'
      assert_no_select 'p.omg_hint'
    end
  end

  test 'optional wrapper does not display when there is content' do
    swap_wrapper :default, custom_wrapper_with_unless_blank do
      with_form_for @user, :name, hint: "can't be blank"
      assert_select 'section.custom_wrapper div.no_output_wrapper'
      assert_select 'div.no_output_wrapper'
      assert_select 'p.omg_hint'
    end
  end

  test 'optional wrapper does not display when there is no content' do
    swap_wrapper :default, custom_wrapper_with_unless_blank do
      with_form_for @user, :name
      assert_no_select 'section.custom_wrapper div.no_output_wrapper'
      assert_no_select 'div.no_output_wrapper'
      assert_no_select 'p.omg_hint'
    end
  end
end
