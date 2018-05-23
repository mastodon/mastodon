# frozen_string_literal: true
# encoding: UTF-8
require 'test_helper'

# Tests for f.error_notification
class ErrorNotificationTest < ActionView::TestCase
  def with_error_notification_for(object, options = {}, &block)
    with_concat_form_for(object) do |f|
      f.error_notification(options)
    end
  end

  test 'error notification is not generated when the object has no error' do
    assert @validating_user.valid?

    with_error_notification_for @validating_user
    assert_no_select 'p.error_notification'
  end

  test 'error notification is not generated for forms without objects' do
    with_error_notification_for :user
    assert_no_select 'p.error_notification'
  end

  test 'error notification is generated when the object has some error' do
    with_error_notification_for @user
    assert_select 'p.error_notification', 'Please review the problems below:'
  end

  test 'error notification uses I18n based on model to generate the notification message' do
    store_translations(:en, simple_form: { error_notification: { user:
      'Alguns erros foram encontrados para o usuário:'
    } }) do
      with_error_notification_for @user
      assert_select 'p.error_notification', 'Alguns erros foram encontrados para o usuário:'
    end
  end

  test 'error notification uses I18n fallbacking to default message' do
    store_translations(:en, simple_form: { error_notification: {
      default_message: 'Opa! Alguns erros foram encontrados, poderia verificar?'
    } }) do
      with_error_notification_for @user
      assert_select 'p.error_notification', 'Opa! Alguns erros foram encontrados, poderia verificar?'
    end
  end

  test 'error notification allows passing the notification message' do
    with_error_notification_for @user, message: 'Erro encontrado ao criar usuario'
    assert_select 'p.error_notification', 'Erro encontrado ao criar usuario'
  end

  test 'error notification accepts other html options' do
    with_error_notification_for @user, id: 'user_error_message', class: 'form_error'
    assert_select 'p#user_error_message.form_error.error_notification'
  end

  test 'error notification allows configuring the wrapper element' do
    swap SimpleForm, error_notification_tag: :div do
      with_error_notification_for @user
      assert_select 'div.error_notification'
    end
  end

  test 'error notification can contain HTML tags' do
    with_error_notification_for @user, message: 'Erro encontrado ao criar <b>usuário</b>'
    assert_select 'p.error_notification', 'Erro encontrado ao criar usuário'
    assert_select 'p.error_notification b', 'usuário'
  end

  test 'error notification uses I18n based on model to generate the notification message and accepts HTML' do
    store_translations(:en, simple_form: { error_notification: { user:
      'Alguns erros foram encontrados para o <b>usuário</b>:'
    } }) do
      with_error_notification_for @user
      assert_select 'p.error_notification', 'Alguns erros foram encontrados para o usuário:'
      assert_select 'p.error_notification b', 'usuário'
    end
  end
end
