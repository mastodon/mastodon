# frozen_string_literal: true
# encoding: UTF-8
require 'test_helper'

# Isolated tests for label without triggering f.label.
class IsolatedLabelTest < ActionView::TestCase
  setup do
    SimpleForm::Inputs::Base.reset_i18n_cache :translate_required_html
  end

  def with_label_for(object, attribute_name, type, options = {})
    with_concat_form_for(object) do |f|
      options[:reflection] = Association.new(Company, :company, {}) if options.delete(:setup_association)
      SimpleForm::Inputs::Base.new(f, attribute_name, nil, type, options).label
    end
  end

  test 'label generates a default humanized description' do
    with_label_for @user, :name, :string
    assert_select 'label[for=user_name]', /Name/
  end

  test 'label allows a customized description' do
    with_label_for @user, :name, :string, label: 'My label!'
    assert_select 'label[for=user_name]', /My label!/
  end

  test 'label uses human attribute name from object when available' do
    with_label_for @user, :description, :text
    assert_select 'label[for=user_description]', /User Description!/
  end

  test 'label uses human attribute name based on association name' do
    with_label_for @user, :company_id, :string, setup_association: true
    assert_select 'label', /Company Human Name!/
  end

  test 'label uses i18n based on model, action, and attribute to lookup translation' do
    @controller.action_name = "new"
    store_translations(:en, simple_form: { labels: { user: {
      new: { description: 'Nova descrição' }
    } } }) do
      with_label_for @user, :description, :text
      assert_select 'label[for=user_description]', /Nova descrição/
    end
  end

  test 'label fallbacks to new when action is create' do
    @controller.action_name = "create"
    store_translations(:en, simple_form: { labels: { user: {
      new: { description: 'Nova descrição' }
    } } }) do
      with_label_for @user, :description, :text
      assert_select 'label[for=user_description]', /Nova descrição/
    end
  end

  test 'label does not explode while looking for i18n translation when action is not set' do
    def @controller.action_name; nil; end

    assert_nothing_raised do
      with_label_for @user, :description, :text
    end
    assert_select 'label[for=user_description]'
  end

  test 'label uses i18n based on model and attribute to lookup translation' do
    store_translations(:en, simple_form: { labels: { user: {
      description: 'Descrição'
    } } }) do
      with_label_for @user, :description, :text
      assert_select 'label[for=user_description]', /Descrição/
    end
  end

  test 'label uses i18n under defaults to lookup translation' do
    store_translations(:en, simple_form: { labels: { defaults: { age: 'Idade' } } }) do
      with_label_for @user, :age, :integer
      assert_select 'label[for=user_age]', /Idade/
    end
  end

  test 'label does not use i18n label if translate is false' do
    swap SimpleForm, translate_labels: false do
      store_translations(:en, simple_form: { labels: { defaults: { age: 'Idade' } } }) do
        with_label_for @user, :age, :integer
        assert_select 'label[for=user_age]', /Age/
      end
    end
  end

  test 'label uses i18n with lookup for association name' do
    store_translations(:en, simple_form: { labels: {
      user: { company: 'My company!' }
    } }) do
      with_label_for @user, :company_id, :string, setup_association: true
      assert_select 'label[for=user_company_id]', /My company!/
    end
  end

  test 'label uses i18n under defaults namespace to lookup for association name' do
    store_translations(:en, simple_form: { labels: {
      defaults: { company: 'Plataformatec' }
    } }) do
      with_label_for @user, :company, :string, setup_association: true

      assert_select 'form label', /Plataformatec/
    end
  end

  test 'label does correct i18n lookup for nested models with nested translation' do
    @user.company = Company.new(1, 'Empresa')

    store_translations(:en, simple_form: { labels: {
      user: { name: 'Usuario', company: { name: 'Nome da empresa' } }
    } }) do
      with_concat_form_for @user do |f|
        concat f.input :name
        concat(f.simple_fields_for(:company) do |company_form|
          concat(company_form.input :name)
        end)
      end

      assert_select 'label[for=user_name]', /Usuario/
      assert_select 'label[for=user_company_attributes_name]', /Nome da empresa/
    end
  end

  test 'label does correct i18n lookup for nested models with no nested translation' do
    @user.company = Company.new(1, 'Empresa')

    store_translations(:en, simple_form: { labels: {
      user: { name: 'Usuario' },
      company: { name: 'Nome da empresa' }
    } }) do
      with_concat_form_for @user do |f|
        concat f.input :name
        concat(f.simple_fields_for(:company) do |company_form|
          concat(company_form.input :name)
        end)
      end

      assert_select 'label[for=user_name]', /Usuario/
      assert_select 'label[for=user_company_attributes_name]', /Nome da empresa/
    end
  end

  test 'label does correct i18n lookup for nested has_many models with no nested translation' do
    @user.tags = [Tag.new(1, 'Empresa')]

    store_translations(:en, simple_form: { labels: {
      user: { name: 'Usuario' },
      tags: { name: 'Nome da empresa' }
    } }) do
      with_concat_form_for @user do |f|
        concat f.input :name
        concat(f.simple_fields_for(:tags, child_index: "new_index") do |tags_form|
          concat(tags_form.input :name)
        end)
      end

      assert_select 'label[for=user_name]', /Usuario/
      assert_select 'label[for=user_tags_attributes_new_index_name]', /Nome da empresa/
    end
  end

  test 'label has css class from type' do
    with_label_for @user, :name, :string
    assert_select 'label.string'
    with_label_for @user, :description, :text
    assert_select 'label.text'
    with_label_for @user, :age, :integer
    assert_select 'label.integer'
    with_label_for @user, :born_at, :date
    assert_select 'label.date'
    with_label_for @user, :created_at, :datetime
    assert_select 'label.datetime'
  end

  test 'label does not have css class from type when generate_additional_classes_for does not include :label' do
    swap SimpleForm, generate_additional_classes_for: %i[wrapper input] do
      with_label_for @user, :name, :string
      assert_no_select 'label.string'
      with_label_for @user, :description, :text
      assert_no_select 'label.text'
      with_label_for @user, :age, :integer
      assert_no_select 'label.integer'
      with_label_for @user, :born_at, :date
      assert_no_select 'label.date'
      with_label_for @user, :created_at, :datetime
      assert_no_select 'label.datetime'
    end
  end

  test 'label does not generate empty css class' do
    swap SimpleForm, generate_additional_classes_for: %i[wrapper input] do
      with_label_for @user, :name, :string
      assert_no_select 'label[class]'
    end
  end

  test 'label obtains required from ActiveModel::Validations when it is included' do
    with_label_for @validating_user, :name, :string
    assert_select 'label.required'
    with_label_for @validating_user, :status, :string
    assert_select 'label.optional'
  end

  test 'label does not obtain required from ActiveModel::Validations when generate_additional_classes_for does not include :label' do
    swap SimpleForm, generate_additional_classes_for: %i[wrapper input] do
      with_label_for @validating_user, :name, :string
      assert_no_select 'label.required'
      with_label_for @validating_user, :status, :string
      assert_no_select 'label.optional'
    end
  end

  test 'label allows overriding required when ActiveModel::Validations is included' do
    with_label_for @validating_user, :name, :string, required: false
    assert_select 'label.optional'
    with_label_for @validating_user, :status, :string, required: true
    assert_select 'label.required'
  end

  test 'label is required by default when ActiveModel::Validations is not included' do
    with_label_for @user, :name, :string
    assert_select 'label.required'
  end

  test 'label is able to disable required when ActiveModel::Validations is not included' do
    with_label_for @user, :name, :string, required: false
    assert_no_select 'label.required'
  end

  test 'label adds required text when required' do
    with_label_for @user, :name, :string
    assert_select 'label.required abbr[title=required]', '*'
  end

  test 'label does not have required text in no required inputs' do
    with_label_for @user, :name, :string, required: false
    assert_no_select 'form label abbr'
  end

  test 'label uses i18n to find required text' do
    store_translations(:en, simple_form: { required: { text: 'campo requerido' } }) do
      with_label_for @user, :name, :string
      assert_select 'form label abbr[title="campo requerido"]', '*'
    end
  end

  test 'label uses i18n to find required mark' do
    store_translations(:en, simple_form: { required: { mark: '*-*' } }) do
      with_label_for @user, :name, :string
      assert_select 'form label abbr', '*-*'
    end
  end

  test 'label uses i18n to find required string tag' do
    store_translations(:en, simple_form: { required: { html: '<span class="required" title="requerido">*</span>' } }) do
      with_label_for @user, :name, :string
      assert_no_select 'form label abbr'
      assert_select 'form label span.required[title=requerido]', '*'
    end
  end

  test 'label allows overwriting input id' do
    with_label_for @user, :name, :string, input_html: { id: 'my_new_id' }
    assert_select 'label[for=my_new_id]'
  end

  test 'label allows overwriting of for attribute' do
    with_label_for @user, :name, :string, label_html: { for: 'my_new_id' }
    assert_select 'label[for=my_new_id]'
  end

  test 'label allows overwriting of for attribute with input_html not containing id' do
    with_label_for @user, :name, :string, label_html: { for: 'my_new_id' }, input_html: { class: 'foo' }
    assert_select 'label[for=my_new_id]'
  end

  test 'label uses default input id when it was not overridden' do
    with_label_for @user, :name, :string, input_html: { class: 'my_new_id' }
    assert_select 'label[for=user_name]'
  end

  test 'label is generated properly when object is not present' do
    with_label_for :project, :name, :string
    assert_select 'label[for=project_name]', /Name/
  end

  test 'label includes for attribute for select collection' do
    with_label_for @user, :sex, :select, collection: %i[male female]
    assert_select 'label[for=user_sex]'
  end

  test 'label uses i18n properly when object is not present' do
    store_translations(:en, simple_form: { labels: {
      project: { name: 'Nome' }
    } }) do
      with_label_for :project, :name, :string
      assert_select 'label[for=project_name]', /Nome/
    end
  end

  test 'label adds required by default when object is not present' do
    with_label_for :project, :name, :string
    assert_select 'label.required[for=project_name]'
    with_label_for :project, :description, :string, required: false
    assert_no_select 'label.required[for=project_description]'
  end

  test 'label adds chosen label class' do
    swap SimpleForm, label_class: :my_custom_class do
      with_label_for @user, :name, :string
      assert_select 'label.my_custom_class'
    end
  end

  test 'label strips extra classes even when label_class is nil' do
    swap SimpleForm, label_class: nil do
      with_label_for @user, :name, :string
      assert_select "label[class='string required']"
      assert_no_select "label[class='string required ']"
      assert_no_select "label[class=' string required']"
    end
  end
end
