# frozen_string_literal: true
# encoding: UTF-8
require 'test_helper'

class AssociationTest < ActionView::TestCase
  def with_association_for(object, *args)
    with_concat_form_for(object) do |f|
      f.association(*args)
    end
  end

  test 'builder does not allow creating an association input when no object exists' do
    assert_raise ArgumentError do
      with_association_for :post, :author
    end
  end

  test 'builder association works with decorated object responsive to #to_model' do
    assert_nothing_raised do
      with_association_for @decorated_user, :company
    end
  end

  test 'builder association with a block calls simple_fields_for' do
    simple_form_for @user do |f|
      f.association :posts do |posts_form|
        assert posts_form.instance_of?(SimpleForm::FormBuilder)
      end
    end
  end

  test 'builder association forwards collection to simple_fields_for' do
    calls = 0
    simple_form_for @user do |f|
      f.association :company, collection: Company.all do |c|
        calls += 1
      end
    end

    assert_equal 3, calls
  end

  test 'builder association marks input as required based on both association and attribute' do
    swap SimpleForm, required_by_default: false do
      with_association_for @validating_user, :company, collection: []
      assert_select 'label.required'
    end
  end

  test 'builder preloads collection association' do
    value = @user.tags = MiniTest::Mock.new
    value.expect(:to_a, value)

    with_association_for @user, :tags
    assert_select 'form select.select#user_tag_ids'
    assert_select 'form select option[value="1"]', 'Tag 1'
    assert_select 'form select option[value="2"]', 'Tag 2'
    assert_select 'form select option[value="3"]', 'Tag 3'

    value.verify
  end

  test 'builder does not preload collection association if preload is false' do
    value = @user.tags = MiniTest::Mock.new
    value.expect(:to_a, nil)

    with_association_for @user, :tags, preload: false
    assert_select 'form select.select#user_tag_ids'
    assert_select 'form select option[value="1"]', 'Tag 1'
    assert_select 'form select option[value="2"]', 'Tag 2'
    assert_select 'form select option[value="3"]', 'Tag 3'

    assert_raises MockExpectationError do
      value.verify
    end
  end

  test 'builder does not preload non-collection association' do
    value = @user.company = MiniTest::Mock.new
    value.expect(:to_a, nil)

    with_association_for @user, :company
    assert_select 'form select.select#user_company_id'
    assert_select 'form select option[value="1"]', 'Company 1'
    assert_select 'form select option[value="2"]', 'Company 2'
    assert_select 'form select option[value="3"]', 'Company 3'

    assert_raises MockExpectationError do
      value.verify
    end
  end

  # ASSOCIATIONS - BELONGS TO
  test 'builder creates a select for belongs_to associations' do
    with_association_for @user, :company
    assert_select 'form select.select#user_company_id'
    assert_select 'form select option[value="1"]', 'Company 1'
    assert_select 'form select option[value="2"]', 'Company 2'
    assert_select 'form select option[value="3"]', 'Company 3'
  end

  test 'builder creates blank select if collection is nil' do
    with_association_for @user, :company, collection: nil
    assert_select 'form select.select#user_company_id'
    assert_no_select 'form select option[value="1"]', 'Company 1'
  end

  test 'builder allows collection radio for belongs_to associations' do
    with_association_for @user, :company, as: :radio_buttons
    assert_select 'form input.radio_buttons#user_company_id_1'
    assert_select 'form input.radio_buttons#user_company_id_2'
    assert_select 'form input.radio_buttons#user_company_id_3'
  end

  test 'builder allows collection to have a proc as a condition' do
    with_association_for @user, :extra_special_company
    assert_select 'form select.select#user_extra_special_company_id'
    assert_select 'form select option[value="1"]'
    assert_no_select 'form select option[value="2"]'
    assert_no_select 'form select option[value="3"]'
  end

  test 'builder allows collection to have a scope' do
    with_association_for @user, :special_pictures
    assert_select 'form select.select#user_special_picture_ids'
    assert_select 'form select option[value="3"]', '3'
    assert_no_select 'form select option[value="1"]'
    assert_no_select 'form select option[value="2"]'
  end

  test 'builder allows collection to have a scope with parameter' do
    with_association_for @user, :special_tags
    assert_select 'form select.select#user_special_tag_ids'
    assert_select 'form select[multiple=multiple]'
    assert_select 'form select option[value="1"]', 'Tag 1'
    assert_no_select 'form select option[value="2"]'
    assert_no_select 'form select option[value="3"]'
  end

  test 'builder marks the record which already belongs to the user' do
    @user.company_id = 2
    with_association_for @user, :company, as: :radio_buttons
    assert_no_select 'form input.radio_buttons#user_company_id_1[checked=checked]'
    assert_select 'form input.radio_buttons#user_company_id_2[checked=checked]'
    assert_no_select 'form input.radio_buttons#user_company_id_3[checked=checked]'
  end

  # ASSOCIATIONS - FINDERS
  test 'builder uses reflection conditions to find collection' do
    with_association_for @user, :special_company
    assert_select 'form select.select#user_special_company_id'
    assert_select 'form select option[value="1"]'
    assert_no_select 'form select option[value="2"]'
    assert_no_select 'form select option[value="3"]'
  end

  test 'builder allows overriding collection to association input' do
    with_association_for @user, :company, include_blank: false,
                         collection: [Company.new(999, 'Teste')]
    assert_select 'form select.select#user_company_id'
    assert_no_select 'form select option[value="1"]'
    assert_select 'form select option[value="999"]', 'Teste'
    assert_select 'form select option', count: 1
  end

  # ASSOCIATIONS - has_*
  test 'builder does not allow has_one associations' do
    assert_raise ArgumentError do
      with_association_for @user, :first_company, as: :radio_buttons
    end
  end

  test 'builder does not call where if the given association does not respond to it' do
    with_association_for @user, :friends
    assert_select 'form select.select#user_friend_ids'
    assert_select 'form select[multiple=multiple]'
    assert_select 'form select option[value="1"]', 'Friend 1'
    assert_select 'form select option[value="2"]', 'Friend 2'
    assert_select 'form select option[value="3"]', 'Friend 3'
  end

  test 'builder does not call order if the given association does not respond to it' do
    with_association_for @user, :pictures
    assert_select 'form select.select#user_picture_ids'
    assert_select 'form select[multiple=multiple]'
    assert_select 'form select option[value="1"]', 'Picture 1'
    assert_select 'form select option[value="2"]', 'Picture 2'
    assert_select 'form select option[value="3"]', 'Picture 3'
  end

  test 'builder creates a select with multiple options for collection associations' do
    with_association_for @user, :tags
    assert_select 'form select.select#user_tag_ids'
    assert_select 'form select[multiple=multiple]'
    assert_select 'form select option[value="1"]', 'Tag 1'
    assert_select 'form select option[value="2"]', 'Tag 2'
    assert_select 'form select option[value="3"]', 'Tag 3'
  end

  test 'builder allows size to be overwritten for collection associations' do
    with_association_for @user, :tags, input_html: { size: 10 }
    assert_select 'form select[multiple=multiple][size="10"]'
  end

  test 'builder marks all selected records which already belongs to user' do
    @user.tag_ids = [1, 2]
    with_association_for @user, :tags
    assert_select 'form select option[value="1"][selected=selected]'
    assert_select 'form select option[value="2"][selected=selected]'
    assert_no_select 'form select option[value="3"][selected=selected]'
  end

  test 'builder allows a collection of check boxes for collection associations' do
    @user.tag_ids = [1, 2]
    with_association_for @user, :tags, as: :check_boxes
    assert_select 'form input#user_tag_ids_1[type=checkbox]'
    assert_select 'form input#user_tag_ids_2[type=checkbox]'
    assert_select 'form input#user_tag_ids_3[type=checkbox]'
  end

  test 'builder marks all selected records for collection boxes' do
    @user.tag_ids = [1, 2]
    with_association_for @user, :tags, as: :check_boxes
    assert_select 'form input[type=checkbox][value="1"][checked=checked]'
    assert_select 'form input[type=checkbox][value="2"][checked=checked]'
    assert_no_select 'form input[type=checkbox][value="3"][checked=checked]'
  end

  test 'builder with collection support giving collection and item wrapper tags' do
    with_association_for @user, :tags, as: :check_boxes,
      collection_wrapper_tag: :ul, item_wrapper_tag: :li

    assert_select 'form ul', count: 1
    assert_select 'form ul li', count: 3
  end

  test 'builder with collection support does not change the options hash' do
    options = { as: :check_boxes, collection_wrapper_tag: :ul, item_wrapper_tag: :li }
    with_association_for @user, :tags, options

    assert_select 'form ul', count: 1
    assert_select 'form ul li', count: 3
    assert_equal({ as: :check_boxes, collection_wrapper_tag: :ul, item_wrapper_tag: :li },
                 options)
  end
end
