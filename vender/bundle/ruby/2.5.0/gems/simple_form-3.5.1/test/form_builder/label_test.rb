# frozen_string_literal: true
# encoding: UTF-8
require 'test_helper'

class LabelTest < ActionView::TestCase
  def with_label_for(object, *args, &block)
    with_concat_form_for(object) do |f|
      f.label(*args, &block)
    end
  end

  test 'builder generates a label for the attribute' do
    with_label_for @user, :name
    assert_select 'label.string[for=user_name]', /Name/
  end

  test 'builder generates a label for the attribute with decorated object responsive to #to_model' do
    with_label_for @decorated_user, :name
    assert_select 'label.string[for=user_name]', /Name/
  end

  test 'builder generates a label for the boolean attrbiute' do
    with_label_for @user, :name, as: :boolean
    assert_select 'label.boolean[for=user_name]', /Name/
    assert_no_select 'label[as=boolean]'
  end

  test 'builder generates a label component tag with a clean HTML' do
    with_label_for @user, :name
    assert_no_select 'label.string[label_html]'
  end

  test 'builder adds a required class to label if the attribute is required' do
    with_label_for @validating_user, :name
    assert_select 'label.string.required[for=validating_user_name]', /Name/
  end

  test 'builder adds a disabled class to label if the attribute is disabled' do
    with_label_for @validating_user, :name, disabled: true
    assert_select 'label.string.disabled[for=validating_user_name]', /Name/
  end

  test 'builder does not add a disabled class to label if the attribute is not disabled' do
    with_label_for @validating_user, :name, disabled: false
    assert_no_select 'label.string.disabled[for=validating_user_name]', /Name/
  end

  test 'builder escapes label text' do
    with_label_for @user, :name, label: '<script>alert(1337)</script>', required: false
    assert_no_select 'label.string script'
  end

  test 'builder does not escape label text if it is safe' do
    with_label_for @user, :name, label: '<script>alert(1337)</script>'.html_safe, required: false
    assert_select 'label.string script', "alert(1337)"
  end

  test 'builder allows passing options to label tag' do
    with_label_for @user, :name, label: 'My label', id: 'name_label'
    assert_select 'label.string#name_label', /My label/
  end

  test 'builder label generates label tag with clean HTML' do
    with_label_for @user, :name, label: 'My label', required: true, id: 'name_label'
    assert_select 'label.string#name_label', /My label/
    assert_no_select 'label[label]'
    assert_no_select 'label[required]'
  end

  test 'builder does not modify the options hash' do
    options = { label: 'My label', id: 'name_label' }
    with_label_for @user, :name, options
    assert_select 'label.string#name_label', /My label/
    assert_equal({ label: 'My label', id: 'name_label' }, options)
  end

  test 'builder fallbacks to default label when string is given' do
    with_label_for @user, :name, 'Nome do usuário'
    assert_select 'label', 'Nome do usuário'
    assert_no_select 'label.string'
  end

  test 'builder fallbacks to default label when block is given' do
    with_label_for @user, :name do
      'Nome do usuário'
    end
    assert_select 'label', 'Nome do usuário'
    assert_no_select 'label.string'
  end

  test 'builder allows label order to be changed' do
    swap SimpleForm, label_text: proc { |l, r| "#{l}:" } do
      with_label_for @user, :age
      assert_select 'label.integer[for=user_age]', "Age:"
    end
  end

  test 'configuration allow set label text for wrappers' do
    swap_wrapper :default, custom_wrapper_with_label_text do
      with_concat_form_for(@user) do |f|
        concat f.input :age
      end
      assert_select "label.integer[for=user_age]", "**Age**"
    end
  end

  test 'configuration allow set rewrited label tag for wrappers' do
    swap_wrapper :default, custom_wrapper_with_custom_label_component do
      with_concat_form_for(@user) do |f|
        concat f.input :age
      end
      assert_select "span.integer.user_age", /Age/
    end
  end

  test 'builder allows custom formatting when label is explicitly specified' do
    swap SimpleForm, label_text: ->(l, r, explicit_label) { explicit_label ? l : "#{l.titleize}:" } do
      with_label_for @user, :time_zone, 'What is your home time zone?'
      assert_select 'label[for=user_time_zone]', 'What is your home time zone?'
    end
  end

  test 'builder allows custom formatting when label is generated' do
    swap SimpleForm, label_text: ->(l, r, explicit_label) { explicit_label ? l : "#{l.titleize}:" } do
      with_label_for @user, :time_zone
      assert_select 'label[for=user_time_zone]', 'Time Zone:'
    end
  end

  test 'builder allows label specific `label_text` option' do
    with_label_for @user, :time_zone, label_text: ->(l, _, _) { "#{l.titleize}:" }

    assert_no_select 'label[label_text]'
    assert_select 'label[for=user_time_zone]', 'Time Zone:'
  end
end
