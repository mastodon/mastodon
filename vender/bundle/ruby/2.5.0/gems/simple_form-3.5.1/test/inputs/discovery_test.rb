# frozen_string_literal: true
require 'test_helper'

class DiscoveryTest < ActionView::TestCase
  # Setup new inputs and remove them after the test.
  def discovery(value = false)
    swap SimpleForm, cache_discovery: value do
      begin
        load "support/discovery_inputs.rb"
        yield
      ensure
        SimpleForm::FormBuilder.discovery_cache.clear
        Object.send :remove_const, :StringInput
        Object.send :remove_const, :NumericInput
        Object.send :remove_const, :CustomizedInput
        Object.send :remove_const, :DeprecatedInput
        Object.send :remove_const, :CollectionSelectInput
        CustomInputs.send :remove_const, :CustomizedInput
        CustomInputs.send :remove_const, :PasswordInput
        CustomInputs.send :remove_const, :NumericInput
      end
    end
  end

  test 'builder does not discover new inputs if cached' do
    with_form_for @user, :name
    assert_select 'form input#user_name.string'

    discovery(true) do
      with_form_for @user, :name
      assert_no_select 'form section input#user_name.string'
    end
  end

  test 'builder discovers new inputs' do
    discovery do
      with_form_for @user, :name, as: :customized
      assert_select 'form section input#user_name.string'
    end
  end

  test 'builder does not discover new inputs if discovery is off' do
    with_form_for @user, :name
    assert_select 'form input#user_name.string'

    swap SimpleForm, inputs_discovery: false do
      discovery do
        with_form_for @user, :name
        assert_no_select 'form section input#user_name.string'
      end
    end
  end

  test 'builder discovers new inputs from mappings if not cached' do
    discovery do
      with_form_for @user, :name
      assert_select 'form section input#user_name.string'
    end
  end

  test 'builder discovers new inputs from internal fallbacks if not cached' do
    discovery do
      with_form_for @user, :age
      assert_select 'form section input#user_age.numeric.integer'
    end
  end

  test 'builder discovers new maped inputs from configured namespaces if not cached' do
    discovery do
      swap SimpleForm, custom_inputs_namespaces: ['CustomInputs'] do
        with_form_for @user, :password
        assert_select 'form input#user_password.password-custom-input'
      end
    end
  end

  test 'builder discovers new maped inputs from configured namespaces before the ones from top level namespace' do
    discovery do
      swap SimpleForm, custom_inputs_namespaces: ['CustomInputs'] do
        with_form_for @user, :age
        assert_select 'form input#user_age.numeric-custom-input'
      end
    end
  end

  test 'builder discovers new custom inputs from configured namespace before the ones from top level namespace' do
    discovery do
      swap SimpleForm, custom_inputs_namespaces: ['CustomInputs'] do
        with_form_for @user, :name, as: 'customized'
        assert_select 'form input#user_name.customized-namespace-custom-input'
      end
    end
  end

  test 'raises error when configured namespace does not exists' do
    discovery do
      swap SimpleForm, custom_inputs_namespaces: ['InvalidNamespace'] do
        assert_raise NameError do
          with_form_for @user, :age
        end
      end
    end
  end

  test 'new inputs can override the input_html_options' do
    discovery do
      with_form_for @user, :active, as: :select
      assert_select 'form select#user_active.select.chosen'
    end
  end

  test 'inputs method without wrapper_options are deprecated' do
    discovery do
      assert_deprecated do
        with_form_for @user, :name, as: :deprecated
      end

      assert_select 'form section input#user_name.string'
    end
  end
end
