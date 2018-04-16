# frozen_string_literal: true
require 'test_helper'

class BuilderTest < ActionView::TestCase
  def with_custom_form_for(object, *args, &block)
    with_concat_custom_form_for(object) do |f|
      assert f.instance_of?(CustomFormBuilder)
      yield f
    end
  end

  def with_collection_radio_buttons(object, attribute, collection, value_method, text_method, options = {}, html_options = {}, &block)
    with_concat_form_for(object) do |f|
      f.collection_radio_buttons attribute, collection, value_method, text_method, options, html_options, &block
    end
  end

  def with_collection_check_boxes(object, attribute, collection, value_method, text_method, options = {}, html_options = {}, &block)
    with_concat_form_for(object) do |f|
      f.collection_check_boxes attribute, collection, value_method, text_method, options, html_options, &block
    end
  end

  # COLLECTION RADIO
  test "collection radio accepts a collection and generate inputs from value method" do
    with_collection_radio_buttons @user, :active, [true, false], :to_s, :to_s

    assert_select 'form input[type=radio][value=true]#user_active_true'
    assert_select 'form input[type=radio][value=false]#user_active_false'
  end

  test "collection radio accepts a collection and generate inputs from label method" do
    with_collection_radio_buttons @user, :active, [true, false], :to_s, :to_s

    assert_select 'form label.collection_radio_buttons[for=user_active_true]', 'true'
    assert_select 'form label.collection_radio_buttons[for=user_active_false]', 'false'
  end

  test "collection radio handles camelized collection values for labels correctly" do
    with_collection_radio_buttons @user, :active, %w[Yes No], :to_s, :to_s

    assert_select 'form label.collection_radio_buttons[for=user_active_yes]', 'Yes'
    assert_select 'form label.collection_radio_buttons[for=user_active_no]', 'No'
  end

  test "collection radio sanitizes collection values for labels correctly" do
    with_collection_radio_buttons @user, :name, ['$0.99', '$1.99'], :to_s, :to_s
    assert_select 'label.collection_radio_buttons[for=user_name_099]', '$0.99'
    assert_select 'label.collection_radio_buttons[for=user_name_199]', '$1.99'
  end

  test "collection radio checks the correct value to local variables" do
    user = User.build(active: false)
    with_collection_radio_buttons user, :active, [true, false], :to_s, :to_s

    assert_select 'form input[type=radio][value=true]'
    assert_select 'form input[type=radio][value=false][checked=checked]'
  end

  test "collection radio accepts checked item" do
    with_collection_radio_buttons @user, :active, [[1, true], [0, false]], :last, :first, checked: true

    assert_select 'form input[type=radio][value=true][checked=checked]'
    assert_no_select 'form input[type=radio][value=false][checked=checked]'
  end

  test "collection radio accepts checked item which has a value of false" do
    with_collection_radio_buttons @user, :active, [[1, true], [0, false]], :last, :first, checked: false
    assert_no_select 'form input[type=radio][value=true][checked=checked]'
    assert_select 'form input[type=radio][value=false][checked=checked]'
  end

  test "collection radio accepts multiple disabled items" do
    collection = [[1, true], [0, false], [2, 'other']]
    with_collection_radio_buttons @user, :active, collection, :last, :first, disabled: [true, false]

    assert_select 'form input[type=radio][value=true][disabled=disabled]'
    assert_select 'form input[type=radio][value=false][disabled=disabled]'
    assert_no_select 'form input[type=radio][value=other][disabled=disabled]'
  end

  test "collection radio accepts single disable item" do
    collection = [[1, true], [0, false]]
    with_collection_radio_buttons @user, :active, collection, :last, :first, disabled: true

    assert_select 'form input[type=radio][value=true][disabled=disabled]'
    assert_no_select 'form input[type=radio][value=false][disabled=disabled]'
  end

  test "collection radio accepts html options as input" do
    collection = [[1, true], [0, false]]
    with_collection_radio_buttons @user, :active, collection, :last, :first, {}, class: 'special-radio'

    assert_select 'form input[type=radio][value=true].special-radio#user_active_true'
    assert_select 'form input[type=radio][value=false].special-radio#user_active_false'
  end

  test "collection radio wraps the collection in the given collection wrapper tag" do
    with_collection_radio_buttons @user, :active, [true, false], :to_s, :to_s, collection_wrapper_tag: :ul

    assert_select 'form ul input[type=radio]', count: 2
  end

  test "collection radio does not render any wrapper tag by default" do
    with_collection_radio_buttons @user, :active, [true, false], :to_s, :to_s

    assert_select 'form input[type=radio]', count: 2
    assert_no_select 'form ul'
  end

  test "collection radio does not wrap the collection when given falsy values" do
    with_collection_radio_buttons @user, :active, [true, false], :to_s, :to_s, collection_wrapper_tag: false

    assert_select 'form input[type=radio]', count: 2
    assert_no_select 'form ul'
  end

  test "collection radio uses the given class for collection wrapper tag" do
    with_collection_radio_buttons @user, :active, [true, false], :to_s, :to_s,
      collection_wrapper_tag: :ul, collection_wrapper_class: "items-list"

    assert_select 'form ul.items-list input[type=radio]', count: 2
  end

  test "collection radio uses no class for collection wrapper tag when no wrapper tag is given" do
    with_collection_radio_buttons @user, :active, [true, false], :to_s, :to_s,
      collection_wrapper_class: "items-list"

    assert_select 'form input[type=radio]', count: 2
    assert_no_select 'form ul'
    assert_no_select '.items-list'
  end

  test "collection radio uses no class for collection wrapper tag by default" do
    with_collection_radio_buttons @user, :active, [true, false], :to_s, :to_s, collection_wrapper_tag: :ul

    assert_select 'form ul'
    assert_no_select 'form ul[class]'
  end

  test "collection radio wrap items in a span tag by default" do
    with_collection_radio_buttons @user, :active, [true, false], :to_s, :to_s

    assert_select 'form span input[type=radio][value=true]#user_active_true + label'
    assert_select 'form span input[type=radio][value=false]#user_active_false + label'
  end

  test "collection radio wraps each item in the given item wrapper tag" do
    with_collection_radio_buttons @user, :active, [true, false], :to_s, :to_s, item_wrapper_tag: :li

    assert_select 'form li input[type=radio]', count: 2
  end

  test "collection radio does not wrap each item when given explicitly falsy value" do
    with_collection_radio_buttons @user, :active, [true, false], :to_s, :to_s, item_wrapper_tag: false

    assert_select 'form input[type=radio]'
    assert_no_select 'form span input[type=radio]'
  end

  test "collection radio uses the given class for item wrapper tag" do
    with_collection_radio_buttons @user, :active, [true, false], :to_s, :to_s,
      item_wrapper_tag: :li, item_wrapper_class: "inline"

    assert_select "form li.inline input[type=radio]", count: 2
  end

  test "collection radio uses no class for item wrapper tag when no wrapper tag is given" do
    with_collection_radio_buttons @user, :active, [true, false], :to_s, :to_s,
      item_wrapper_tag: nil, item_wrapper_class: "inline"

    assert_select 'form input[type=radio]', count: 2
    assert_no_select 'form li'
    assert_no_select '.inline'
  end

  test "collection radio uses no class for item wrapper tag by default" do
    with_collection_radio_buttons @user, :active, [true, false], :to_s, :to_s,
      item_wrapper_tag: :li

    assert_select "form li", count: 2
    assert_no_select "form li[class]"
  end

  test "collection radio does not wrap input inside the label" do
    with_collection_radio_buttons @user, :active, [true, false], :to_s, :to_s

    assert_select 'form input[type=radio] + label'
    assert_no_select 'form label input'
  end

  test "collection radio accepts a block to render the label as radio button wrapper" do
    with_collection_radio_buttons :user, :active, [true, false], :to_s, :to_s do |b|
      b.label { b.radio_button }
    end

    assert_select 'label[for=user_active_true] > input#user_active_true[type=radio]'
    assert_select 'label[for=user_active_false] > input#user_active_false[type=radio]'
  end

  test "collection radio accepts a block to change the order of label and radio button" do
    with_collection_radio_buttons :user, :active, [true, false], :to_s, :to_s do |b|
      b.label + b.radio_button
    end

    assert_select 'label[for=user_active_true] + input#user_active_true[type=radio]'
    assert_select 'label[for=user_active_false] + input#user_active_false[type=radio]'
  end

  test "collection radio with block helpers accept extra html options" do
    with_collection_radio_buttons :user, :active, [true, false], :to_s, :to_s do |b|
      b.label(class: "radio_button") + b.radio_button(class: "radio_button")
    end

    assert_select 'label.radio_button[for=user_active_true] + input#user_active_true.radio_button[type=radio]'
    assert_select 'label.radio_button[for=user_active_false] + input#user_active_false.radio_button[type=radio]'
  end

  test "collection radio with block helpers allows access to current text and value" do
    with_collection_radio_buttons :user, :active, [true, false], :to_s, :to_s do |b|
      b.label(:"data-value" => b.value) { b.radio_button + b.text }
    end

    assert_select 'label[for=user_active_true][data-value=true]', 'true' do
      assert_select 'input#user_active_true[type=radio]'
    end
    assert_select 'label[for=user_active_false][data-value=false]', 'false' do
      assert_select 'input#user_active_false[type=radio]'
    end
  end

  test "collection radio with block helpers allows access to the current object item in the collection to access extra properties" do
    with_collection_radio_buttons :user, :active, [true, false], :to_s, :to_s do |b|
      b.label(class: b.object) { b.radio_button + b.text }
    end

    assert_select 'label.true[for=user_active_true]', 'true' do
      assert_select 'input#user_active_true[type=radio]'
    end
    assert_select 'label.false[for=user_active_false]', 'false' do
      assert_select 'input#user_active_false[type=radio]'
    end
  end

  test "collection radio with block helpers does not leak the template" do
    with_concat_form_for(@user) do |f|
      collection_input = f.collection_radio_buttons :active, [true, false], :to_s, :to_s do |b|
        b.label(class: b.object) { b.radio_button + b.text }
      end
      concat collection_input

      concat f.hidden_field :name
    end

    assert_select 'label.true[for=user_active_true]', text: 'true', count: 1 do
      assert_select 'input#user_active_true[type=radio]'
    end
    assert_select 'label.false[for=user_active_false]', text: 'false', count: 1 do
      assert_select 'input#user_active_false[type=radio]'
    end
  end
  # COLLECTION CHECK BOX
  test "collection check box accepts a collection and generate a serie of checkboxes for value method" do
    collection = [Tag.new(1, 'Tag 1'), Tag.new(2, 'Tag 2')]
    with_collection_check_boxes @user, :tag_ids, collection, :id, :name

    assert_select 'form input#user_tag_ids_1[type=checkbox][value="1"]'
    assert_select 'form input#user_tag_ids_2[type=checkbox][value="2"]'
  end

  test "collection check box generates only one hidden field for the entire collection, to ensure something will be sent back to the server when posting an empty collection" do
    collection = [Tag.new(1, 'Tag 1'), Tag.new(2, 'Tag 2')]
    with_collection_check_boxes @user, :tag_ids, collection, :id, :name

    assert_select "form input[type=hidden][name='user[tag_ids][]'][value='']", count: 1
  end

  test "collection check box accepts a collection and generate a serie of checkboxes with labels for label method" do
    collection = [Tag.new(1, 'Tag 1'), Tag.new(2, 'Tag 2')]
    with_collection_check_boxes @user, :tag_ids, collection, :id, :name

    assert_select 'form label.collection_check_boxes[for=user_tag_ids_1]', 'Tag 1'
    assert_select 'form label.collection_check_boxes[for=user_tag_ids_2]', 'Tag 2'
  end

  test "collection check box handles camelized collection values for labels correctly" do
    with_collection_check_boxes @user, :active, %w[Yes No], :to_s, :to_s

    assert_select 'form label.collection_check_boxes[for=user_active_yes]', 'Yes'
    assert_select 'form label.collection_check_boxes[for=user_active_no]', 'No'
  end

  test "collection check box sanitizes collection values for labels correctly" do
    with_collection_check_boxes @user, :name, ['$0.99', '$1.99'], :to_s, :to_s
    assert_select 'label.collection_check_boxes[for=user_name_099]', '$0.99'
    assert_select 'label.collection_check_boxes[for=user_name_199]', '$1.99'
  end

  test "collection check box checks the correct value to local variables" do
    user = User.build(tag_ids: [1, 3])
    collection = (1..3).map { |i| [i, "Tag #{i}"] }

    with_collection_check_boxes user, :tag_ids, collection, :first, :last

    assert_select 'form input[type=checkbox][value="1"][checked=checked]'
    assert_select 'form input[type=checkbox][value="3"][checked=checked]'
    assert_no_select 'form input[type=checkbox][value="2"][checked=checked]'
  end

  test "collection check box accepts selected values as :checked option" do
    collection = (1..3).map { |i| [i, "Tag #{i}"] }
    with_collection_check_boxes @user, :tag_ids, collection, :first, :last, checked: [1, 3]

    assert_select 'form input[type=checkbox][value="1"][checked=checked]'
    assert_select 'form input[type=checkbox][value="3"][checked=checked]'
    assert_no_select 'form input[type=checkbox][value="2"][checked=checked]'
  end

  test "collection check boxes accepts selected string values as :checked option" do
    collection = (1..3).map { |i| [i, "Category #{i}"] }
    with_collection_check_boxes :user, :category_ids, collection, :first, :last, checked: %w[1 3]

    assert_select 'input[type=checkbox][value="1"][checked=checked]'
    assert_select 'input[type=checkbox][value="3"][checked=checked]'
    assert_no_select 'input[type=checkbox][value="2"][checked=checked]'
  end

  test "collection check box accepts a single checked value" do
    collection = (1..3).map { |i| [i, "Tag #{i}"] }
    with_collection_check_boxes @user, :tag_ids, collection, :first, :last, checked: 3

    assert_select 'form input[type=checkbox][value="3"][checked=checked]'
    assert_no_select 'form input[type=checkbox][value="1"][checked=checked]'
    assert_no_select 'form input[type=checkbox][value="2"][checked=checked]'
  end

  test "collection check box accepts selected values as :checked option and override the model values" do
    collection = (1..3).map { |i| [i, "Tag #{i}"] }
    @user.tag_ids = [2]
    with_collection_check_boxes @user, :tag_ids, collection, :first, :last, checked: [1, 3]

    assert_select 'form input[type=checkbox][value="1"][checked=checked]'
    assert_select 'form input[type=checkbox][value="3"][checked=checked]'
    assert_no_select 'form input[type=checkbox][value="2"][checked=checked]'
  end

  test "collection check box accepts multiple disabled items" do
    collection = (1..3).map { |i| [i, "Tag #{i}"] }
    with_collection_check_boxes @user, :tag_ids, collection, :first, :last, disabled: [1, 3]

    assert_select 'form input[type=checkbox][value="1"][disabled=disabled]'
    assert_select 'form input[type=checkbox][value="3"][disabled=disabled]'
    assert_no_select 'form input[type=checkbox][value="2"][disabled=disabled]'
  end

  test "collection check box accepts single disable item" do
    collection = (1..3).map { |i| [i, "Tag #{i}"] }
    with_collection_check_boxes @user, :tag_ids, collection, :first, :last, disabled: 1

    assert_select 'form input[type=checkbox][value="1"][disabled=disabled]'
    assert_no_select 'form input[type=checkbox][value="3"][disabled=disabled]'
    assert_no_select 'form input[type=checkbox][value="2"][disabled=disabled]'
  end

  test "collection check box accepts a proc to disabled items" do
    collection = (1..3).map { |i| [i, "Tag #{i}"] }
    with_collection_check_boxes @user, :tag_ids, collection, :first, :last, disabled: proc { |i| i.first == 1 }

    assert_select 'form input[type=checkbox][value="1"][disabled=disabled]'
    assert_no_select 'form input[type=checkbox][value="3"][disabled=disabled]'
    assert_no_select 'form input[type=checkbox][value="2"][disabled=disabled]'
  end

  test "collection check box accepts html options" do
    collection = [[1, 'Tag 1'], [2, 'Tag 2']]
    with_collection_check_boxes @user, :tag_ids, collection, :first, :last, {}, class: 'check'

    assert_select 'form input.check[type=checkbox][value="1"]'
    assert_select 'form input.check[type=checkbox][value="2"]'
  end

  test "collection check box with fields for" do
    collection = [Tag.new(1, 'Tag 1'), Tag.new(2, 'Tag 2')]
    with_concat_form_for(@user) do |f|
      f.fields_for(:post) do |p|
        p.collection_check_boxes :tag_ids, collection, :id, :name
      end
    end

    assert_select 'form input#user_post_tag_ids_1[type=checkbox][value="1"]'
    assert_select 'form input#user_post_tag_ids_2[type=checkbox][value="2"]'

    assert_select 'form label.collection_check_boxes[for=user_post_tag_ids_1]', 'Tag 1'
    assert_select 'form label.collection_check_boxes[for=user_post_tag_ids_2]', 'Tag 2'
  end

  test "collection check boxes wraps the collection in the given collection wrapper tag" do
    with_collection_check_boxes @user, :active, [true, false], :to_s, :to_s, collection_wrapper_tag: :ul

    assert_select 'form ul input[type=checkbox]', count: 2
  end

  test "collection check boxes does not render any wrapper tag by default" do
    with_collection_check_boxes @user, :active, [true, false], :to_s, :to_s

    assert_select 'form input[type=checkbox]', count: 2
    assert_no_select 'form ul'
  end

  test "collection check boxes does not wrap the collection when given falsy values" do
    with_collection_check_boxes @user, :active, [true, false], :to_s, :to_s, collection_wrapper_tag: false

    assert_select 'form input[type=checkbox]', count: 2
    assert_no_select 'form ul'
  end

  test "collection check boxes uses the given class for collection wrapper tag" do
    with_collection_check_boxes @user, :active, [true, false], :to_s, :to_s,
      collection_wrapper_tag: :ul, collection_wrapper_class: "items-list"

    assert_select 'form ul.items-list input[type=checkbox]', count: 2
  end

  test "collection check boxes uses no class for collection wrapper tag when no wrapper tag is given" do
    with_collection_check_boxes @user, :active, [true, false], :to_s, :to_s,
      collection_wrapper_class: "items-list"

    assert_select 'form input[type=checkbox]', count: 2
    assert_no_select 'form ul'
    assert_no_select '.items-list'
  end

  test "collection check boxes uses no class for collection wrapper tag by default" do
    with_collection_check_boxes @user, :active, [true, false], :to_s, :to_s, collection_wrapper_tag: :ul

    assert_select 'form ul'
    assert_no_select 'form ul[class]'
  end

  test "collection check boxes wrap items in a span tag by default" do
    with_collection_check_boxes @user, :active, [true, false], :to_s, :to_s

    assert_select 'form span input[type=checkbox]', count: 2
  end

  test "collection check boxes wraps each item in the given item wrapper tag" do
    with_collection_check_boxes @user, :active, [true, false], :to_s, :to_s, item_wrapper_tag: :li

    assert_select 'form li input[type=checkbox]', count: 2
  end

  test "collection check boxes does not wrap each item when given explicitly falsy value" do
    with_collection_check_boxes @user, :active, [true, false], :to_s, :to_s, item_wrapper_tag: false

    assert_select 'form input[type=checkbox]'
    assert_no_select 'form span input[type=checkbox]'
  end

  test "collection check boxes uses the given class for item wrapper tag" do
    with_collection_check_boxes @user, :active, [true, false], :to_s, :to_s,
      item_wrapper_tag: :li, item_wrapper_class: "inline"

    assert_select "form li.inline input[type=checkbox]", count: 2
  end

  test "collection check boxes uses no class for item wrapper tag when no wrapper tag is given" do
    with_collection_check_boxes @user, :active, [true, false], :to_s, :to_s,
      item_wrapper_tag: nil, item_wrapper_class: "inline"

    assert_select 'form input[type=checkbox]', count: 2
    assert_no_select 'form li'
    assert_no_select '.inline'
  end

  test "collection check boxes uses no class for item wrapper tag by default" do
    with_collection_check_boxes @user, :active, [true, false], :to_s, :to_s,
      item_wrapper_tag: :li

    assert_select "form li", count: 2
    assert_no_select "form li[class]"
  end

  test "collection check box does not wrap input inside the label" do
    with_collection_check_boxes @user, :active, [true, false], :to_s, :to_s

    assert_select 'form input[type=checkbox] + label'
    assert_no_select 'form label input'
  end

  test "collection check boxes accepts a block to render the label as check box wrapper" do
    with_collection_check_boxes :user, :active, [true, false], :to_s, :to_s do |b|
      b.label { b.check_box }
    end

    assert_select 'label[for=user_active_true] > input#user_active_true[type=checkbox]'
    assert_select 'label[for=user_active_false] > input#user_active_false[type=checkbox]'
  end

  test "collection check boxes accepts a block to change the order of label and check box" do
    with_collection_check_boxes :user, :active, [true, false], :to_s, :to_s do |b|
      b.label + b.check_box
    end

    assert_select 'label[for=user_active_true] + input#user_active_true[type=checkbox]'
    assert_select 'label[for=user_active_false] + input#user_active_false[type=checkbox]'
  end

  test "collection check boxes with block helpers accept extra html options" do
    with_collection_check_boxes :user, :active, [true, false], :to_s, :to_s do |b|
      b.label(class: "check_box") + b.check_box(class: "check_box")
    end

    assert_select 'label.check_box[for=user_active_true] + input#user_active_true.check_box[type=checkbox]'
    assert_select 'label.check_box[for=user_active_false] + input#user_active_false.check_box[type=checkbox]'
  end

  test "collection check boxes with block helpers allows access to current text and value" do
    with_collection_check_boxes :user, :active, [true, false], :to_s, :to_s do |b|
      b.label(:"data-value" => b.value) { b.check_box + b.text }
    end

    assert_select 'label[for=user_active_true][data-value=true]', 'true' do
      assert_select 'input#user_active_true[type=checkbox]'
    end
    assert_select 'label[for=user_active_false][data-value=false]', 'false' do
      assert_select 'input#user_active_false[type=checkbox]'
    end
  end

  test "collection check boxes with block helpers allows access to the current object item in the collection to access extra properties" do
    with_collection_check_boxes :user, :active, [true, false], :to_s, :to_s do |b|
      b.label(class: b.object) { b.check_box + b.text }
    end

    assert_select 'label.true[for=user_active_true]', 'true' do
      assert_select 'input#user_active_true[type=checkbox]'
    end
    assert_select 'label.false[for=user_active_false]', 'false' do
      assert_select 'input#user_active_false[type=checkbox]'
    end
  end

  test "collection check boxes with block helpers does not leak the template" do
    with_concat_form_for(@user) do |f|
      collection_input = f.collection_check_boxes :active, [true, false], :to_s, :to_s do |b|
        b.label(class: b.object) { b.check_box + b.text }
      end
      concat collection_input

      concat f.hidden_field :name
    end

    assert_select 'label.true[for=user_active_true]', text: 'true', count: 1 do
      assert_select 'input#user_active_true[type=checkbox]'
    end
    assert_select 'label.false[for=user_active_false]', text: 'false', count: 1 do
      assert_select 'input#user_active_false[type=checkbox]'
    end
  end

  # SIMPLE FIELDS
  test "simple fields for is available and yields an instance of FormBuilder" do
    with_concat_form_for(@user) do |f|
      f.simple_fields_for(:posts) do |posts_form|
        assert posts_form.instance_of?(SimpleForm::FormBuilder)
      end
    end
  end

  test "fields for with a hash like model yeilds an instance of FormBuilder" do
    with_concat_form_for(:user) do |f|
      f.simple_fields_for(:author, HashBackedAuthor.new) do |author|
        assert author.instance_of?(SimpleForm::FormBuilder)
        author.input :name
      end
    end

    assert_select "input[name='user[author][name]'][value='hash backed author']"
  end

  test "fields for yields an instance of CustomBuilder if main builder is a CustomBuilder" do
    with_custom_form_for(:user) do |f|
      f.simple_fields_for(:company) do |company|
        assert company.instance_of?(CustomFormBuilder)
      end
    end
  end

  test "fields for yields an instance of FormBuilder if it was set in options" do
    with_custom_form_for(:user) do |f|
      f.simple_fields_for(:company, builder: SimpleForm::FormBuilder) do |company|
        assert company.instance_of?(SimpleForm::FormBuilder)
      end
    end
  end

  test "fields inherits wrapper option from the parent form" do
    swap_wrapper :another do
      simple_form_for(:user, wrapper: :another) do |f|
        f.simple_fields_for(:company) do |company|
          assert_equal :another, company.options[:wrapper]
        end
      end
    end
  end

  test "fields overrides wrapper option from the parent form" do
    swap_wrapper :another do
      simple_form_for(:user, wrapper: :another) do |f|
        f.simple_fields_for(:company, wrapper: false) do |company|
          assert_equal false, company.options[:wrapper]
        end
      end
    end
  end
end
