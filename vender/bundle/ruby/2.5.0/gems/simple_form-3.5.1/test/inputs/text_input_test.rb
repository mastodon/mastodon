# frozen_string_literal: true
# encoding: UTF-8
require 'test_helper'

class TextInputTest < ActionView::TestCase
  test 'input generates a text area for text attributes' do
    with_input_for @user, :description, :text
    assert_select 'textarea.text#user_description'
  end

  test 'input generates a text area for text attributes that accept placeholder' do
    with_input_for @user, :description, :text, placeholder: 'Put in some text'
    assert_select 'textarea.text[placeholder="Put in some text"]'
  end

  test 'input generates a placeholder from the translations' do
    store_translations(:en, simple_form: { placeholders: { user: { name: "placeholder from i18n en.simple_form.placeholders.user.name" } } }) do
      with_input_for @user, :name, :text
      assert_select 'textarea.text[placeholder="placeholder from i18n en.simple_form.placeholders.user.name"]'
    end
  end

  test 'input gets maxlength from column definition for text attributes' do
    with_input_for @user, :description, :text
    assert_select 'textarea.text[maxlength="200"]'
  end

  test 'input infers maxlength column definition from validation when present for text attributes' do
    with_input_for @validating_user, :description, :text
    assert_select 'textarea.text[maxlength="50"]'
  end

  test 'input infers minlength column definition from validation when present for text attributes' do
    with_input_for @validating_user, :description, :text
    assert_select 'textarea.text[minlength="15"]'
  end
end
