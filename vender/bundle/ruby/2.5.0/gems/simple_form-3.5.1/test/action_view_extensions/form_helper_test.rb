# frozen_string_literal: true
require 'test_helper'

class FormHelperTest < ActionView::TestCase

  test 'SimpleForm for yields an instance of FormBuilder' do
    simple_form_for :user do |f|
      assert f.instance_of?(SimpleForm::FormBuilder)
    end
  end

  test 'SimpleForm adds default class to form' do
    with_concat_form_for(:user)
    assert_select 'form.simple_form'
  end

  test 'SimpleForm allows overriding default form class' do
    swap SimpleForm, default_form_class: "my_custom_class" do
      with_concat_form_for :user, html: { class: "override_class" }
      assert_no_select 'form.my_custom_class'
      assert_select 'form.override_class'
    end
  end

  # Remove this test when SimpleForm.form_class is removed in 4.x
  test 'SimpleForm allows overriding default form class, but not form class' do
    ActiveSupport::Deprecation.silence do
      swap SimpleForm, form_class: "fixed_class", default_form_class: "my_custom_class" do
        with_concat_form_for :user, html: { class: "override_class" }
        assert_no_select 'form.my_custom_class'
        assert_select 'form.fixed_class.override_class'
      end
    end
  end

  test 'SimpleForm uses default browser validations by default' do
    with_concat_form_for(:user)
    assert_no_select 'form[novalidate]'
  end

  test 'SimpleForm does not use default browser validations if specified in the configuration options' do
    swap SimpleForm, browser_validations: false do
      with_concat_form_for(:user)
      assert_select 'form[novalidate="novalidate"]'
    end
  end

  test 'disabled browser validations overrides default configuration' do
    with_concat_form_for(:user, html: { novalidate: true })
    assert_select 'form[novalidate="novalidate"]'
  end

  test 'enabled browser validations overrides disabled configuration' do
    swap SimpleForm, browser_validations: false do
      with_concat_form_for(:user, html: { novalidate: false })
      assert_no_select 'form[novalidate]'
    end
  end

  test 'SimpleForm adds object name as css class to form when object is not present' do
    with_concat_form_for(:user, html: { novalidate: true })
    assert_select 'form.simple_form.user'
  end

  test 'SimpleForm adds :as option as css class to form when object is not present' do
    with_concat_form_for(:user, as: 'superuser')
    assert_select 'form.simple_form.superuser'
  end

  test 'SimpleForm adds object class name with new prefix as css class to form if record is not persisted' do
    @user.new_record!
    with_concat_form_for(@user)
    assert_select 'form.simple_form.new_user'
  end

  test 'SimpleForm adds :as option with new prefix as css class to form if record is not persisted' do
    @user.new_record!
    with_concat_form_for(@user, as: 'superuser')
    assert_select 'form.simple_form.new_superuser'
  end

  test 'SimpleForm adds edit class prefix as css class to form if record is persisted' do
    with_concat_form_for(@user)
    assert_select 'form.simple_form.edit_user'
  end

  test 'SimpleForm adds :as options with edit prefix as css class to form if record is persisted' do
    with_concat_form_for(@user, as: 'superuser')
    assert_select 'form.simple_form.edit_superuser'
  end

  test 'SimpleForm adds last object name as css class to form when there is array of objects' do
    with_concat_form_for([Company.new, @user])
    assert_select 'form.simple_form.edit_user'
  end

  test 'SimpleForm does not add object class to form if css_class is specified' do
    with_concat_form_for(:user, html: { class: nil })
    assert_no_select 'form.user'
  end

  test 'SimpleForm adds custom class to form if css_class is specified' do
    with_concat_form_for(:user, html: { class: 'my_class' })
    assert_select 'form.my_class'
  end

  test 'passes options to SimpleForm' do
    with_concat_form_for(:user, url: '/account', html: { id: 'my_form' })
    assert_select 'form#my_form'
    assert_select 'form[action="/account"]'
  end

  test 'form_for yields an instance of FormBuilder' do
    with_concat_form_for(:user) do |f|
      assert f.instance_of?(SimpleForm::FormBuilder)
    end
  end

  test 'fields_for with a hash like model yields an instance of FormBuilder' do
    with_concat_fields_for(:author, HashBackedAuthor.new) do |f|
      assert f.instance_of?(SimpleForm::FormBuilder)
      f.input :name
    end

    assert_select "input[name='author[name]'][value='hash backed author']"
  end

  test 'custom error proc is not destructive' do
    swap_field_error_proc do
      result = nil
      simple_form_for :user do |f|
        result = simple_fields_for 'address' do
          'hello'
        end
      end

      assert_equal 'hello', result
    end
  end

  test 'custom error proc survives an exception' do
    swap_field_error_proc do
      begin
        simple_form_for :user do |f|
          simple_fields_for 'address' do
            raise 'an exception'
          end
        end
      rescue StandardError
      end
    end
  end

  test 'SimpleForm for swaps default action view field_error_proc' do
    expected_error_proc = -> {}
    swap SimpleForm, field_error_proc: expected_error_proc do
      simple_form_for :user do |f|
        assert_equal expected_error_proc, ::ActionView::Base.field_error_proc
      end
    end
  end

  private

  def swap_field_error_proc(expected_error_proc = -> {})
    swap ActionView::Base, field_error_proc: expected_error_proc do
      yield

      assert_equal expected_error_proc, ActionView::Base.field_error_proc
    end
  end
end
