# frozen_string_literal: true
# encoding: UTF-8
require 'test_helper'

class FormBuilderTest < ActionView::TestCase
  def with_custom_form_for(object, *args, &block)
    with_concat_custom_form_for(object) do |f|
      f.input(*args, &block)
    end
  end

  test 'nested simple fields yields an instance of FormBuilder' do
    simple_form_for :user do |f|
      f.simple_fields_for :posts do |posts_form|
        assert posts_form.instance_of?(SimpleForm::FormBuilder)
      end
    end
  end

  test 'builder input is html safe' do
    simple_form_for @user do |f|
      assert f.input(:name).html_safe?
    end
  end

  test 'builder works without controller' do
    stub_any_instance ActionView::TestCase, :controller, nil do
      simple_form_for @user do |f|
        assert f.input(:name)
      end
    end
  end

  test 'builder works with decorated object responsive to #to_model' do
    assert_nothing_raised do
      with_form_for @decorated_user, :name
    end
  end

  test 'builder input allows a block to configure input' do
    with_form_for @user, :name do
      text_field_tag :foo, :bar, id: :cool
    end
    assert_no_select 'input.string'
    assert_select 'input#cool'
  end

  test 'builder allows adding custom input mappings for default input types' do
    swap SimpleForm, input_mappings: { /count$/ => :integer } do
      with_form_for @user, :post_count
      assert_no_select 'form input#user_post_count.string'
      assert_select 'form input#user_post_count.numeric.integer'
    end
  end

  test 'builder does not override custom input mappings for custom collection' do
    swap SimpleForm, input_mappings: { /gender$/ => :check_boxes } do
      with_concat_form_for @user do |f|
        f.input :gender, collection: %i[male female]
      end

      assert_no_select 'select option', 'Male'
      assert_select 'input[type=checkbox][value=male]'
    end
  end

  test 'builder allows to skip input_type class' do
    swap SimpleForm, generate_additional_classes_for: %i[label wrapper] do
      with_form_for @user, :post_count
      assert_no_select "form input#user_post_count.integer"
      assert_select "form input#user_post_count"
    end
  end

  test 'builder allows to add additional classes only for wrapper' do
    swap SimpleForm, generate_additional_classes_for: [:wrapper] do
      with_form_for @user, :post_count
      assert_no_select "form input#user_post_count.string"
      assert_no_select "form label#user_post_count.string"
      assert_select "form div.input.string"
    end
  end

  test 'builder allows adding custom input mappings for integer input types' do
    swap SimpleForm, input_mappings: { /lock_version/ => :hidden } do
      with_form_for @user, :lock_version
      assert_no_select 'form input#user_lock_version.integer'
      assert_select 'form input#user_lock_version.hidden'
    end
  end

  test 'builder uses the first matching custom input map when more than one matches' do
    swap SimpleForm, input_mappings: { /count$/ => :integer, /^post_/ => :password } do
      with_form_for @user, :post_count
      assert_no_select 'form input#user_post_count.password'
      assert_select 'form input#user_post_count.numeric.integer'
    end
  end

  test 'builder uses the custom map only for matched attributes' do
    swap SimpleForm, input_mappings: { /lock_version/ => :hidden } do
      with_form_for @user, :post_count
      assert_no_select 'form input#user_post_count.hidden'
      assert_select 'form input#user_post_count.string'
    end
  end

  test 'builder allow to use numbers in the model name' do
    user = UserNumber1And2.build(tags: [Tag.new(nil, 'Tag1')])

    with_concat_form_for(user, url: '/') do |f|
      f.simple_fields_for(:tags) do |tags|
        tags.input :name
      end
    end

    assert_select 'form .user_number1_and2_tags_name'
    assert_no_select 'form .user_number1_and2_tags_1_name'
  end

  # INPUT TYPES
  test 'builder generates text fields for string columns' do
    with_form_for @user, :name
    assert_select 'form input#user_name.string'
  end

  test 'builder generates text areas for text columns' do
    with_form_for @user, :description
    assert_no_select 'form input#user_description.string'
    assert_select 'form textarea#user_description.text'
  end

  test 'builder generates text areas for text columns when hinted' do
    with_form_for @user, :description, as: :text
    assert_no_select 'form input#user_description.string'
    assert_select 'form textarea#user_description.text'
  end

  test 'builder generates text field for text columns when hinted' do
    with_form_for @user, :description, as: :string
    assert_no_select 'form textarea#user_description.text'
    assert_select 'form input#user_description.string'
  end

  test 'builder generates a checkbox for boolean columns' do
    with_form_for @user, :active
    assert_select 'form input[type=checkbox]#user_active.boolean'
  end

  test 'builder uses integer text field for integer columns' do
    with_form_for @user, :age
    assert_select 'form input#user_age.numeric.integer'
  end

  test 'builder generates decimal text field for decimal columns' do
    with_form_for @user, :credit_limit
    assert_select 'form input#user_credit_limit.numeric.decimal'
  end

  test 'builder generates uuid fields for uuid columns' do
    with_form_for @user, :uuid
    if defined? ActiveModel::Type
      assert_select 'form input#user_uuid.string.string'
    else
      assert_select 'form input#user_uuid.string.uuid'
    end
  end

  test 'builder generates password fields for columns that matches password' do
    with_form_for @user, :password
    assert_select 'form input#user_password.password'
  end

  test 'builder generates country fields for columns that matches country' do
    with_form_for @user, :residence_country
    assert_select 'form select#user_residence_country.country'
  end

  test 'builder generates time_zone fields for columns that matches time_zone' do
    with_form_for @user, :time_zone
    assert_select 'form select#user_time_zone.time_zone'
  end

  test 'builder generates email fields for columns that matches email' do
    with_form_for @user, :email
    assert_select 'form input#user_email.string.email'
  end

  test 'builder generates tel fields for columns that matches phone' do
    with_form_for @user, :phone_number
    assert_select 'form input#user_phone_number.string.tel'
  end

  test 'builder generates url fields for columns that matches url' do
    with_form_for @user, :url
    assert_select 'form input#user_url.string.url'
  end

  test 'builder generates date select for date columns' do
    with_form_for @user, :born_at
    assert_select 'form select#user_born_at_1i.date'
  end

  test 'builder generates time select for time columns' do
    with_form_for @user, :delivery_time
    assert_select 'form select#user_delivery_time_4i.time'
  end

  test 'builder generates datetime select for datetime columns' do
    with_form_for @user, :created_at
    assert_select 'form select#user_created_at_1i.datetime'
  end

  test 'builder generates datetime select for timestamp columns' do
    with_form_for @user, :updated_at
    assert_select 'form select#user_updated_at_1i.datetime'
  end

  test 'builder generates file for file columns' do
    @user.avatar = MiniTest::Mock.new
    @user.avatar.expect(:public_filename, true)

    with_form_for @user, :avatar
    assert_select 'form input#user_avatar.file'
  end

  test 'builder generates file for attributes that are real db columns but have file methods' do
    @user.home_picture = MiniTest::Mock.new
    @user.home_picture.expect(:mounted_as, true)

    with_form_for @user, :home_picture
    assert_select 'form input#user_home_picture.file'
  end

  test 'build generates select if a collection is given' do
    with_form_for @user, :age, collection: 1..60
    assert_select 'form select#user_age.select'
  end

  test 'builder allows overriding default input type for text' do
    with_form_for @user, :name, as: :text
    assert_no_select 'form input#user_name'
    assert_select 'form textarea#user_name.text'
  end

  test 'builder allows overriding default input type for radio_buttons' do
    with_form_for @user, :active, as: :radio_buttons
    assert_no_select 'form input[type=checkbox]'
    assert_select 'form input.radio_buttons[type=radio]', count: 2
  end

  test 'builder allows overriding default input type for string' do
    with_form_for @user, :born_at, as: :string
    assert_no_select 'form select'
    assert_select 'form input#user_born_at.string'
  end

  # COMMON OPTIONS
  # Remove this test when SimpleForm.form_class is removed in 4.x
  test 'builder adds chosen form class' do
    ActiveSupport::Deprecation.silence do
      swap SimpleForm, form_class: :my_custom_class do
        with_form_for @user, :name
        assert_select 'form.my_custom_class'
      end
    end
  end

  # Remove this test when SimpleForm.form_class is removed in 4.x
  test 'builder adds chosen form class and default form class' do
    ActiveSupport::Deprecation.silence do
      swap SimpleForm, form_class: "my_custom_class", default_form_class: "my_default_class" do
        with_form_for @user, :name
        assert_select 'form.my_custom_class.my_default_class'
      end
    end
  end

  test 'builder adds default form class' do
    swap SimpleForm, default_form_class: "default_class" do
      with_form_for @user, :name
      assert_select 'form.default_class'
    end
  end

  test 'builder allows passing options to input' do
    with_form_for @user, :name, input_html: { class: 'my_input', id: 'my_input' }
    assert_select 'form input#my_input.my_input.string'
  end

  test 'builder does not propagate input options to wrapper' do
    with_form_for @user, :name, input_html: { class: 'my_input', id: 'my_input' }
    assert_no_select 'form div.input.my_input.string'
    assert_select 'form input#my_input.my_input.string'
  end

  test 'builder does not propagate input options to wrapper with custom wrapper' do
    swap_wrapper :default, custom_wrapper_with_wrapped_input do
      with_form_for @user, :name, input_html: { class: 'my_input' }
      assert_no_select 'form div.input.my_input'
      assert_select 'form input.my_input.string'
    end
  end

  test 'builder does not propagate label options to wrapper with custom wrapper' do
    swap_wrapper :default, custom_wrapper_with_wrapped_label do
      with_form_for @user, :name, label_html: { class: 'my_label' }
      assert_no_select 'form div.label.my_label'
      assert_select 'form label.my_label.string'
    end
  end

  test 'builder generates an input with label' do
    with_form_for @user, :name
    assert_select 'form label.string[for=user_name]', /Name/
  end

  test 'builder is able to disable the label for an input' do
    with_form_for @user, :name, label: false
    assert_no_select 'form label'
  end

  test 'builder is able to disable the label for an input and return a html safe string' do
    with_form_for @user, :name, label: false, wrapper: custom_wrapper_with_wrapped_label_input
    assert_select 'form input#user_name'
  end

  test 'builder uses custom label' do
    with_form_for @user, :name, label: 'Yay!'
    assert_select 'form label', /Yay!/
  end

  test 'builder passes options to label' do
    with_form_for @user, :name, label_html: { id: "cool" }
    assert_select 'form label#cool', /Name/
  end

  test 'builder does not generate hints for an input' do
    with_form_for @user, :name
    assert_no_select 'span.hint'
  end

  test 'builder is able to add a hint for an input' do
    with_form_for @user, :name, hint: 'test'
    assert_select 'span.hint', 'test'
  end

  test 'builder is able to disable a hint even if it exists in i18n' do
    store_translations(:en, simple_form: { hints: { name: 'Hint test' } }) do
      stub_any_instance(SimpleForm::Inputs::Base, :hint, -> { raise 'Never' }) do
        with_form_for @user, :name, hint: false
        assert_no_select 'span.hint'
      end
    end
  end

  test 'builder passes options to hint' do
    with_form_for @user, :name, hint: 'test', hint_html: { id: "cool" }
    assert_select 'span.hint#cool', 'test'
  end

  test 'builder generates errors for attribute without errors' do
    with_form_for @user, :credit_limit
    assert_no_select 'span.errors'
  end

  test 'builder generates errors for attribute with errors' do
    with_form_for @user, :name
    assert_select 'span.error', "cannot be blank"
  end

  test 'builder is able to disable showing errors for an input' do
    with_form_for @user, :name, error: false
    assert_no_select 'span.error'
  end

  test 'builder passes options to errors' do
    with_form_for @user, :name, error_html: { id: "cool" }
    assert_select 'span.error#cool', "cannot be blank"
  end

  test 'placeholder does not be generated when set to false' do
    store_translations(:en, simple_form: { placeholders: { user: {
      name: 'Name goes here'
    } } }) do
      with_form_for @user, :name, placeholder: false
      assert_no_select 'input[placeholder]'
    end
  end

  # DEFAULT OPTIONS
  %i[input input_field].each do |method|
    test "builder receives a default argument and pass it to the inputs when calling '#{method}'" do
      with_concat_form_for @user, defaults: { input_html: { class: 'default_class' } } do |f|
        f.public_send(method, :name)
      end
      assert_select 'input.default_class'
    end

    test "builder receives a default argument and pass it to the inputs without changing the defaults when calling '#{method}'" do
      with_concat_form_for @user, defaults: { input_html: { class: 'default_class', id: 'default_id' } } do |f|
        concat(f.public_send(method, :name))
        concat(f.public_send(method, :credit_limit))
      end

      assert_select "input.string.default_class[name='user[name]']"
      assert_no_select "input.string[name='user[credit_limit]']"
    end

    test "builder receives a default argument and pass it to the inputs and nested form when calling '#{method}'" do
      @user.company = Company.new(1, 'Empresa')

      with_concat_form_for @user, defaults: { input_html: { class: 'default_class' } } do |f|
        concat(f.public_send(method, :name))
        concat(f.simple_fields_for(:company) do |company_form|
          concat(company_form.public_send(method, :name))
        end)
      end

      assert_select "input.string.default_class[name='user[name]']"
      assert_select "input.string.default_class[name='user[company_attributes][name]']"
    end
  end

  test "builder receives a default argument and pass it to the inputs when calling 'input', respecting the specific options" do
    with_concat_form_for @user, defaults: { input_html: { class: 'default_class' } } do |f|
      f.input :name, input_html: { id: 'specific_id' }
    end
    assert_select 'input.default_class#specific_id'
  end

  test "builder receives a default argument and pass it to the inputs when calling 'input_field', respecting the specific options" do
    with_concat_form_for @user, defaults: { input_html: { class: 'default_class' } } do |f|
      f.input_field :name, id: 'specific_id'
    end
    assert_select 'input.default_class#specific_id'
  end

  test "builder receives a default argument and pass it to the inputs when calling 'input', overwriting the defaults with specific options" do
    with_concat_form_for @user, defaults: { input_html: { class: 'default_class', id: 'default_id' } } do |f|
      f.input :name, input_html: { id: 'specific_id' }
    end
    assert_select 'input.default_class#specific_id'
  end

  test "builder receives a default argument and pass it to the inputs when calling 'input_field', overwriting the defaults with specific options" do
    with_concat_form_for @user, defaults: { input_html: { class: 'default_class', id: 'default_id' } } do |f|
      f.input_field :name, id: 'specific_id'
    end
    assert_select 'input.default_class#specific_id'
  end

  # WITHOUT OBJECT
  test 'builder generates properly when object is not present' do
    with_form_for :project, :name
    assert_select 'form input.string#project_name'
  end

  test 'builder generates password fields based on attribute name when object is not present' do
    with_form_for :project, :password_confirmation
    assert_select 'form input[type=password].password#project_password_confirmation'
  end

  test 'builder generates text fields by default for all attributes when object is not present' do
    with_form_for :project, :created_at
    assert_select 'form input.string#project_created_at'
    with_form_for :project, :budget
    assert_select 'form input.string#project_budget'
  end

  test 'builder allows overriding input type when object is not present' do
    with_form_for :project, :created_at, as: :datetime
    assert_select 'form select.datetime#project_created_at_1i'
    with_form_for :project, :budget, as: :decimal
    assert_select 'form input.decimal#project_budget'
  end

  # CUSTOM FORM BUILDER
  test 'custom builder inherits mappings' do
    with_custom_form_for @user, :email
    assert_select 'form input[type=email]#user_email.custom'
  end

  test 'form with CustomMapTypeFormBuilder uses custom map type builder' do
    with_concat_custom_mapping_form_for(:user) do |user|
      assert user.instance_of?(CustomMapTypeFormBuilder)
    end
  end

  test 'form with CustomMapTypeFormBuilder uses custom mapping' do
    with_concat_custom_mapping_form_for(:user) do |user|
      assert_equal SimpleForm::Inputs::StringInput, user.class.mappings[:custom_type]
    end
  end

  test 'form without CustomMapTypeFormBuilder does not use custom mapping' do
    with_concat_form_for(:user) do |user|
      assert_nil user.class.mappings[:custom_type]
    end
  end
end
