# frozen_string_literal: true
# encoding: UTF-8
require 'test_helper'

class BooleanInputTest < ActionView::TestCase
  test 'input generates a checkbox by default for boolean attributes' do
    with_input_for @user, :active, :boolean
    assert_select 'input[type=checkbox].boolean#user_active'
    assert_select 'label.boolean.optional', 'Active'
  end

  test 'input does not generate the label with the checkbox when label option is false' do
    with_input_for @user, :active, :boolean, label: false
    assert_select 'input[type=checkbox].boolean#user_active'
    assert_no_select 'label'
  end

  test 'input uses custom checked value' do
    @user.action = 'on'
    with_input_for @user, :action, :boolean, checked_value: 'on', unchecked_value: 'off'
    assert_select 'input[type=checkbox][value=on][checked=checked]'
  end

  test 'input uses custom unchecked value' do
    @user.action = 'off'
    with_input_for @user, :action, :boolean, checked_value: 'on', unchecked_value: 'off'
    assert_select 'input[type=checkbox][value=on]'
    assert_no_select 'input[checked=checked][value=on]'
  end

  test 'input generates hidden input with custom unchecked value' do
    with_input_for @user, :action, :boolean, checked_value: 'on', unchecked_value: 'off'
    assert_select 'input[type=hidden][value=off]'
  end

  test 'input uses inline boolean style by default' do
    with_input_for @user, :active, :boolean
    assert_select 'input.boolean + label.boolean.optional'
    assert_no_select 'label > input'
  end

  test 'input allows changing default boolean style config to nested, generating a default label and a manual hidden field for checkbox' do
    swap SimpleForm, boolean_style: :nested do
      with_input_for @user, :active, :boolean
      assert_select 'label[for=user_active]', 'Active'
      assert_select 'label.boolean > input.boolean'
      assert_no_select 'input[type=checkbox] + label'
    end
  end

  test 'input boolean with nested allows :inline_label' do
    swap SimpleForm, boolean_style: :nested do
      with_input_for @user, :active, :boolean, inline_label: 'I am so inline.'
      assert_select 'label.checkbox', text: ' I am so inline.'
    end
  end

  test 'input boolean with nested escapes :inline_label with HTML' do
    swap SimpleForm, boolean_style: :nested do
      with_input_for @user, :active, :boolean, inline_label: '<b>I am so inline.</b>'
      assert_no_select 'label.checkbox b'
    end
  end

  test 'input boolean with nested allows :inline_label with HTML when safe' do
    swap SimpleForm, boolean_style: :nested do
      with_input_for @user, :active, :boolean, inline_label: '<b>I am so inline.</b>'.html_safe
      assert_select 'label.checkbox b', text: 'I am so inline.'
    end
  end

  test 'input boolean with nested style creates an inline label using the default label text when inline_label option set to true' do
    swap SimpleForm, boolean_style: :nested do
      with_input_for @user, :active, :boolean, inline_label: true
      assert_select 'label.checkbox', text: ' Active'
    end
  end

  test 'input boolean with nested style creates an inline label using the label text when inline_label option set to true' do
    swap SimpleForm, boolean_style: :nested do
      with_input_for @user, :active, :boolean, inline_label: true, label_text: proc { 'New Active' }
      assert_select 'label.checkbox', text: ' New Active'
    end
  end

  test 'input boolean with nested style creates an inline label using the label html when inline_label option set to true' do
    swap SimpleForm, boolean_style: :nested do
      with_input_for @user, :active, :boolean, inline_label: true, label_text: proc { '<b>New Active</b>' }
      assert_select 'label.checkbox', text: ' New Active'
    end
  end

  test 'input boolean with nested generates a manual hidden field for checkbox outside the label, to recreate Rails functionality with valid html5' do
    swap SimpleForm, boolean_style: :nested do
      with_input_for @user, :active, :boolean

      assert_select "input[type=hidden][name='user[active]'] + label.boolean > input.boolean"
      assert_no_select 'input[type=checkbox] + label'
    end
  end

  test 'input boolean with nested generates a disabled hidden field for checkbox outside the label, if the field is disabled' do
    swap SimpleForm, boolean_style: :nested do
      with_input_for @user, :active, :boolean, disabled: true

      assert_select "input[type=hidden][name='user[active]'][disabled] + label.boolean > input.boolean[disabled]"
    end
  end

  test 'input accepts changing boolean style to nested through given options' do
    with_input_for @user, :active, :boolean, boolean_style: :nested
    assert_select 'label[for=user_active]', 'Active'
    assert_select 'label.boolean > input.boolean'
    assert_no_select 'input[type=checkbox] + label'
  end

  test 'input accepts changing boolean style to inline through given options, when default is nested' do
    swap SimpleForm, boolean_style: :nested do
      with_input_for @user, :active, :boolean, boolean_style: :inline
      assert_select 'label[for=user_active]', 'Active'
      assert_select 'input.boolean + label.boolean'
      assert_no_select 'label > input'
    end
  end

  test 'input with nested style allows disabling label' do
    swap SimpleForm, boolean_style: :nested do
      with_input_for @user, :active, :boolean, label: false
      assert_select 'input.boolean'
      assert_no_select 'label.boolean'
    end
  end

  test 'input with nested style allows customizing input_html' do
    swap SimpleForm, boolean_style: :nested do
      with_input_for @user, :active, :boolean, input_html: { name: 'active_user' }
      assert_select "input[type=hidden][name=active_user] + label.boolean > input.boolean[name=active_user]"
    end
  end

  test 'input with nested style allows disabling hidden field' do
    swap SimpleForm, boolean_style: :nested do
      with_input_for @user, :active, :boolean, include_hidden: false
      assert_select "label.boolean > input.boolean"
      assert_no_select "input[type=hidden] + label.boolean"
    end
  end

  test 'input with nested style does not include hidden field when unchecked_value is false' do
    swap SimpleForm, boolean_style: :nested do
      with_input_for @user, :active, :boolean, unchecked_value: false
      assert_select "label.boolean > input.boolean"
      assert_no_select "input[type=hidden] + label.boolean"
    end
  end

  test 'input boolean works using :input only in wrapper config (no label_input)' do
    swap_wrapper do
      with_input_for @user, :active, :boolean

      assert_select 'label.boolean + input[type=hidden] + input.boolean'
      assert_no_select 'label.checkbox'
    end
  end

  test 'input boolean with nested style works using :input only in wrapper config (no label_input), adding the extra "checkbox" label wrapper' do
    swap_wrapper do
      swap SimpleForm, boolean_style: :nested do
        with_input_for @user, :active, :boolean

        assert_select 'label.boolean + input[type=hidden] + label.checkbox > input.boolean'
      end
    end
  end

  test 'input boolean allows specifying boolean_label_class on a per-input basis' do
    swap_wrapper do
      swap SimpleForm, boolean_style: :nested, boolean_label_class: 'foo' do
        with_input_for @user, :active, :boolean, boolean_label_class: 'baz'

        assert_select 'label.boolean + input[type=hidden] + label.baz > input.boolean'
      end
    end
  end

  test 'input boolean with nested style works using :input only in wrapper config (no label_input), adding the extra label wrapper with custom class' do
    swap_wrapper do
      swap SimpleForm, boolean_style: :nested, boolean_label_class: 'foo' do
        with_input_for @user, :active, :boolean

        assert_select 'label.boolean + input[type=hidden] + label.foo > input.boolean'
      end
    end
  end

  test 'input boolean with nested style works using :label_input in wrapper config, adding "checkbox" class to label' do
    swap_wrapper :default, self.custom_wrapper_without_top_level do
      swap SimpleForm, boolean_style: :nested do
        with_input_for @user, :active, :boolean

        assert_select 'input[type=hidden] + label.boolean.checkbox > input.boolean'
      end
    end
  end

  test 'input boolean with nested style works using :label_input in wrapper config, adding custom class to label' do
    swap_wrapper :default, self.custom_wrapper_without_top_level do
      swap SimpleForm, boolean_style: :nested, boolean_label_class: 'foo' do
        with_input_for @user, :active, :boolean

        assert_select 'input[type=hidden] + label.boolean.foo > input.boolean'
      end
    end
  end

  test 'input boolean without additional classes adds "checkbox" class to label' do
    swap_wrapper :default, self.custom_wrapper_without_top_level do
      swap SimpleForm, boolean_style: :nested, generate_additional_classes_for: [:input] do
        with_input_for @user, :active, :boolean

        assert_select 'label'
        assert_select 'label.checkbox'
        assert_no_select 'label.boolean'
      end
    end
  end

  test 'input boolean works with wrapper config defining a class for the input' do
    swap_wrapper :default, self.custom_wrapper_with_input_class do
      with_input_for @user, :active, :boolean

      assert_select 'input.boolean.inline-class'
    end
  end
end
