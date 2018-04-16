# frozen_string_literal: true
# encoding: UTF-8
require 'test_helper'

class CollectionCheckBoxesInputTest < ActionView::TestCase
  setup do
    SimpleForm::Inputs::CollectionCheckBoxesInput.reset_i18n_cache :boolean_collection
  end

  test 'input check boxes does not include for attribute by default' do
    with_input_for @user, :gender, :check_boxes, collection: %i[male female]
    assert_select 'label'
    assert_no_select 'label[for=user_gender]'
  end

  test 'input check boxes includes for attribute when giving as html option' do
    with_input_for @user, :gender, :check_boxes, collection: %i[male female], label_html: { for: 'gender' }
    assert_select 'label[for=gender]'
  end

  test 'collection input with check_boxes type does not generate required html attribute' do
    with_input_for @user, :name, :check_boxes, collection: %w[Jose Carlos]
    assert_select 'input.required'
    assert_no_select 'input[required]'
  end

  test 'collection input with check_boxes type does not generate aria-required html attribute' do
    with_input_for @user, :name, :check_boxes, collection: %w[Jose Carlos]
    assert_select 'input.required'
    assert_no_select 'input[aria-required]'
  end

  test 'input does automatic collection translation for check_box types using defaults key' do
    store_translations(:en, simple_form: { options: { defaults: {
      gender: { male: 'Male', female: 'Female' }
    } } } ) do
      with_input_for @user, :gender, :check_boxes, collection: %i[male female]
      assert_select 'input[type=checkbox][value=male]'
      assert_select 'input[type=checkbox][value=female]'
      assert_select 'label.collection_check_boxes', 'Male'
      assert_select 'label.collection_check_boxes', 'Female'
    end
  end

  test 'input does automatic collection translation for check_box types using specific object key' do
    store_translations(:en, simple_form: { options: { user: {
      gender: { male: 'Male', female: 'Female' }
    } } } ) do
      with_input_for @user, :gender, :check_boxes, collection: %i[male female]
      assert_select 'input[type=checkbox][value=male]'
      assert_select 'input[type=checkbox][value=female]'
      assert_select 'label.collection_check_boxes', 'Male'
      assert_select 'label.collection_check_boxes', 'Female'
    end
  end

  test 'input that uses automatic collection translation for check_boxes properly sets checked values' do
    store_translations(:en, simple_form: { options: { defaults: {
      gender: { male: 'Male', female: 'Female' }
    } } } ) do
      @user.gender = 'male'

      with_input_for @user, :gender, :check_boxes, collection: %i[male female]
      assert_select 'input[type=checkbox][value=male][checked=checked]'
      assert_select 'input[type=checkbox][value=female]'
      assert_select 'label.collection_check_boxes', 'Male'
      assert_select 'label.collection_check_boxes', 'Female'
    end
  end

  test 'input check boxes does not wrap the collection by default' do
    with_input_for @user, :active, :check_boxes

    assert_select 'form input[type=checkbox]', count: 2
    assert_no_select 'form ul'
  end

  test 'input check boxes accepts html options as the last element of collection' do
    with_input_for @user, :name, :check_boxes, collection: [['Jose', 'jose', class: 'foo']]
    assert_select 'input.foo[type=checkbox][value=jose]'
  end

  test 'input check boxes wraps the collection in the configured collection wrapper tag' do
    swap SimpleForm, collection_wrapper_tag: :ul do
      with_input_for @user, :active, :check_boxes

      assert_select 'form ul input[type=checkbox]', count: 2
    end
  end

  test 'input check boxes does not wrap the collection when configured with falsy values' do
    swap SimpleForm, collection_wrapper_tag: false do
      with_input_for @user, :active, :check_boxes

      assert_select 'form input[type=checkbox]', count: 2
      assert_no_select 'form ul'
    end
  end

  test 'input check boxes allows overriding the collection wrapper tag at input level' do
    swap SimpleForm, collection_wrapper_tag: :ul do
      with_input_for @user, :active, :check_boxes, collection_wrapper_tag: :section

      assert_select 'form section input[type=checkbox]', count: 2
      assert_no_select 'form ul'
    end
  end

  test 'input check boxes allows disabling the collection wrapper tag at input level' do
    swap SimpleForm, collection_wrapper_tag: :ul do
      with_input_for @user, :active, :check_boxes, collection_wrapper_tag: false

      assert_select 'form input[type=checkbox]', count: 2
      assert_no_select 'form ul'
    end
  end

  test 'input check boxes renders the wrapper tag with the configured wrapper class' do
    swap SimpleForm, collection_wrapper_tag: :ul, collection_wrapper_class: 'inputs-list' do
      with_input_for @user, :active, :check_boxes

      assert_select 'form ul.inputs-list input[type=checkbox]', count: 2
    end
  end

  test 'input check boxes allows giving wrapper class at input level only' do
    swap SimpleForm, collection_wrapper_tag: :ul do
      with_input_for @user, :active, :check_boxes, collection_wrapper_class: 'items-list'

      assert_select 'form ul.items-list input[type=checkbox]', count: 2
    end
  end

  test 'input check boxes uses both configured and given wrapper classes for wrapper tag' do
    swap SimpleForm, collection_wrapper_tag: :ul, collection_wrapper_class: 'inputs-list' do
      with_input_for @user, :active, :check_boxes, collection_wrapper_class: 'items-list'

      assert_select 'form ul.inputs-list.items-list input[type=checkbox]', count: 2
    end
  end

  test 'input check boxes wraps each item in the configured item wrapper tag' do
    swap SimpleForm, item_wrapper_tag: :li do
      with_input_for @user, :active, :check_boxes

      assert_select 'form li input[type=checkbox]', count: 2
    end
  end

  test 'input check boxes does not wrap items when configured with falsy values' do
    swap SimpleForm, item_wrapper_tag: false do
      with_input_for @user, :active, :check_boxes

      assert_select 'form input[type=checkbox]', count: 2
      assert_no_select 'form li'
    end
  end

  test 'input check boxes allows overriding the item wrapper tag at input level' do
    swap SimpleForm, item_wrapper_tag: :li do
      with_input_for @user, :active, :check_boxes, item_wrapper_tag: :dl

      assert_select 'form dl input[type=checkbox]', count: 2
      assert_no_select 'form li'
    end
  end

  test 'input check boxes allows disabling the item wrapper tag at input level' do
    swap SimpleForm, item_wrapper_tag: :ul do
      with_input_for @user, :active, :check_boxes, item_wrapper_tag: false

      assert_select 'form input[type=checkbox]', count: 2
      assert_no_select 'form li'
    end
  end

  test 'input check boxes wraps items in a span tag by default' do
    with_input_for @user, :active, :check_boxes

    assert_select 'form span input[type=checkbox]', count: 2
  end

  test 'input check boxes renders the item wrapper tag with a default class "checkbox"' do
    with_input_for @user, :active, :check_boxes, item_wrapper_tag: :li

    assert_select 'form li.checkbox input[type=checkbox]', count: 2
  end

  test 'input check boxes renders the item wrapper tag with the configured item wrapper class' do
    swap SimpleForm, item_wrapper_tag: :li, item_wrapper_class: 'item' do
      with_input_for @user, :active, :check_boxes

      assert_select 'form li.checkbox.item input[type=checkbox]', count: 2
    end
  end

  test 'input check boxes allows giving item wrapper class at input level only' do
    swap SimpleForm, item_wrapper_tag: :li do
      with_input_for @user, :active, :check_boxes, item_wrapper_class: 'item'

      assert_select 'form li.checkbox.item input[type=checkbox]', count: 2
    end
  end

  test 'input check boxes uses both configured and given item wrapper classes for item wrapper tag' do
    swap SimpleForm, item_wrapper_tag: :li, item_wrapper_class: 'item' do
      with_input_for @user, :active, :check_boxes, item_wrapper_class: 'inline'

      assert_select 'form li.checkbox.item.inline input[type=checkbox]', count: 2
    end
  end

  test 'input check boxes respects the nested boolean style config, generating nested label > input' do
    swap SimpleForm, boolean_style: :nested do
      with_input_for @user, :active, :check_boxes

      assert_select 'span.checkbox > label > input#user_active_true[type=checkbox]'
      assert_select 'span.checkbox > label', 'Yes'
      assert_select 'span.checkbox > label > input#user_active_false[type=checkbox]'
      assert_select 'span.checkbox > label', 'No'
      assert_no_select 'label.collection_radio_buttons'
    end
  end

  test 'input check boxes with nested style does not overrides configured item wrapper tag' do
    swap SimpleForm, boolean_style: :nested, item_wrapper_tag: :li do
      with_input_for @user, :active, :check_boxes

      assert_select 'li.checkbox > label > input'
    end
  end

  test 'input check boxes with nested style does not overrides given item wrapper tag' do
    swap SimpleForm, boolean_style: :nested do
      with_input_for @user, :active, :check_boxes, item_wrapper_tag: :li

      assert_select 'li.checkbox > label > input'
    end
  end

  test 'input check boxes with nested style accepts giving extra wrapper classes' do
    swap SimpleForm, boolean_style: :nested do
      with_input_for @user, :active, :check_boxes, item_wrapper_class: "inline"

      assert_select 'span.checkbox.inline > label > input'
    end
  end

  test 'input check boxes with nested style renders item labels with specified class' do
    swap SimpleForm, boolean_style: :nested do
      with_input_for @user, :active, :check_boxes, item_label_class: "test"

      assert_select 'span.checkbox > label.test > input'
    end
  end

  test 'input check boxes with nested style and falsey input wrapper renders item labels with specified class' do
    swap SimpleForm, boolean_style: :nested, item_wrapper_tag: false do
      with_input_for @user, :active, :check_boxes, item_label_class: "checkbox-inline"

      assert_select 'label.checkbox-inline > input'
      assert_no_select 'span.checkbox'
    end
  end

  test 'input check boxes wrapper class are not included when set to falsey' do
    swap SimpleForm, include_default_input_wrapper_class: false, boolean_style: :nested do
      with_input_for @user, :gender, :check_boxes, collection: %i[male female]

      assert_no_select 'label.checkbox'
    end
  end

  test 'input check boxes custom wrapper class is included when include input wrapper class is falsey' do
    swap SimpleForm, include_default_input_wrapper_class: false, boolean_style: :nested do
      with_input_for @user, :gender, :check_boxes, collection: %i[male female], item_wrapper_class: 'custom'

      assert_no_select 'label.checkbox'
      assert_select 'span.custom'
    end
  end

  test 'input check boxes with nested style and namespace uses the right for attribute' do
    swap SimpleForm, include_default_input_wrapper_class: false, boolean_style: :nested do
      with_concat_form_for @user, namespace: :foo do |f|
        concat f.input :gender, as: :check_boxes, collection: %i[male female]
      end

      assert_select 'label[for=foo_user_gender_male]'
      assert_select 'label[for=foo_user_gender_female]'
    end
  end

  test 'input check boxes with nested style and index uses the right for attribute' do
    swap SimpleForm, include_default_input_wrapper_class: false, boolean_style: :nested do
      with_concat_form_for @user, index: 1 do |f|
        concat f.input :gender, as: :check_boxes, collection: %i[male female]
      end

      assert_select 'label[for=user_1_gender_male]'
      assert_select 'label[for=user_1_gender_female]'
    end
  end

  test 'input check boxes with nested style accepts non-string attribute as label' do
    swap SimpleForm, boolean_style: :nested do
      with_input_for @user, :amount,
                            :check_boxes,
                            collection: { 100 => 'hundred', 200 => 'two_hundred' },
                            label_method: :first,
                            value_method: :second

      assert_select 'input[type=checkbox][value=hundred]'
      assert_select 'input[type=checkbox][value=two_hundred]'
      assert_select 'span.checkbox > label', '100'
      assert_select 'span.checkbox > label', '200'
    end
  end
end
